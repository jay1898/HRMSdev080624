/*
Created By      : Balaji Ravindran
Created Date    : 14th July 2023
Purpose         : This is a Controller for Product Issue Hierarchy Product Search LWC component 
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class ProductIssueHierarchyProdSearchCtrl {
    
    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 14th July 2023
    *   Purpose         : This method will get all Products based related to Brands from Product Issue Hierarchy Product Search Object.
    *                     as we have more than 50k(90K records on 14th July 2023). This method get called multiple times
    *                     with batch of 30k records in 1 single call, and adds the data to result of previous call.
    *   Input Param     : String lastRecordName - used to get next records based on this value.
    *                     Map<String, List<String>> - Map of Brand as Key and all related Products as value.
    *   Output Param    : ProductTreeWrapper
    *   User Story      : SCS-624
    */
    @AuraEnabled
    public static ProductTreeWrapper getProductTreeData(String lastRecordName, Map<String, List<String>> brandAndProductMap){
        //1st call both "lastRecordName" and "brandAndProductMap" will be passed as null from UI, and then in next calls it will be
        //set from previous call result.
        String selectedBrand, selectedProduct, selectedComponent, selectedIssue, selectedDescription;
        if(brandAndProductMap == null) brandAndProductMap       = new Map<String, List<String>>();
        List<Product_Issue_Hierarchy__c> productHierarchyList   = new List<Product_Issue_Hierarchy__c>();
        Case_Line__c csLine                                         = new Case_Line__c();
        
        productHierarchyList                                    = ProductIssueHierarchyProdSearchCtrlModel.getProductIssueHierarchyData(lastRecordName, 30000);

        for(Product_Issue_Hierarchy__c prodIssueHierarchyObj : productHierarchyList) {
            if(brandAndProductMap.containsKey(prodIssueHierarchyObj.Brand__c)) {
                if(!brandAndProductMap.get(prodIssueHierarchyObj.Brand__c).contains(prodIssueHierarchyObj.Product__c))
                    brandAndProductMap.get(prodIssueHierarchyObj.Brand__c).add(prodIssueHierarchyObj.Product__c);
            }                
            else 
                brandAndProductMap.put(prodIssueHierarchyObj.Brand__c, new List<String> {prodIssueHierarchyObj.Product__c});
        }        
        if(!productHierarchyList.isEmpty()) {
            return new ProductTreeWrapper(brandAndProductMap, false, productHierarchyList[productHierarchyList.size() - 1].Name);
        }
        else {
            // csLine = ProductIssueHierarchyProdSearchCtrlModel.getCaseLineDetails(recordId);
            // if(String.isNotBlank(csLine.Brand__c))   selectedBrand = csLine.Brand__c;
            // if(String.isNotBlank(csLine.Product__c)) selectedProduct = csLine.Product__c;
            // if(String.isNotBlank(csLine.Component__c)) selectedComponent = csLine.Component__c;
            // if(String.isNotBlank(csLine.Issue__c)) selectedIssue = csLine.Issue__c;
            // if(String.isNotBlank(csLine.Description__c)) selectedDescription = csLine.Description__c;
            return new ProductTreeWrapper(brandAndProductMap, true, null);
        }
    }




    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 14th July 2023
    *   Purpose         : This method will get all get All Type of Issues related to Product of a Brand.
    *   Input Param     : String brandName   - selected Brand by User.
    *                     String productName - selected Product by User.
    *   Output Param    : Map<String, List<String>> - Map of What is issue with as Key and Issue Descriptions related to What is the issue with as value.
    *   User Story      : SCS-624
    */
    @AuraEnabled
    public static Map<String, Map<String, List<String>>> getProductAndIssueData(String brandName, String productName) {
        Map<String, Map<String, List<String>>> productAndIssueMap   = new Map<String, Map<String, List<String>>>();
        List<Product_Issue_Hierarchy__c> productHierarchyList       = new List<Product_Issue_Hierarchy__c>();
        productHierarchyList                                        = ProductIssueHierarchyProdSearchCtrlModel.getRelatedIssuesData(brandName, productName);
        for(Product_Issue_Hierarchy__c issueObj : productHierarchyList) {
            if(productAndIssueMap.containsKey(issueObj.What_is_the_issue_with__c)) {
                if(productAndIssueMap.get(issueObj.What_is_the_issue_with__c).containsKey(issueObj.Component_noun__c)) {
                    if(!productAndIssueMap.get(issueObj.What_is_the_issue_with__c).get(issueObj.Component_noun__c).contains(issueObj.Description_Adj__c))
                    productAndIssueMap.get(issueObj.What_is_the_issue_with__c).get(issueObj.Component_noun__c).add(issueObj.Description_Adj__c);
                }else{
                    productAndIssueMap.get(issueObj.What_is_the_issue_with__c).put(issueObj.Component_noun__c, new List<String>{issueObj.Description_Adj__c});
                }
            }                
            else {
                Map<String, List<String>> childMap  = new Map<String, List<String>>();
                childMap.put(issueObj.Component_noun__c, new List<String>{issueObj.Description_Adj__c});
                productAndIssueMap.put(issueObj.What_is_the_issue_with__c, childMap);
            }               
        }
        return productAndIssueMap;
    }


    public class ProductTreeWrapper{
        @AuraEnabled
        public Map<String, List<String>> brandAndProductMap;
        @AuraEnabled
        public Boolean processedAllRecords;
        @AuraEnabled
        public String lastRecordName;

        public ProductTreeWrapper(Map<String, List<String>> brandAndProductMap, Boolean processedAllRecords, String lastRecordName) {
            this.brandAndProductMap     = brandAndProductMap;   
            this.processedAllRecords    = processedAllRecords;
            this.lastRecordName         = lastRecordName;
        }
    }
}