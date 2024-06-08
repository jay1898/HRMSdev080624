/*
Created By      : Rahul Sangwan
Created Date    : 22nd May 2023
Purpose         : This is a Controller for Product Issue Hierarchy LWC component 
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class ProductIssueHierarchyController {
    
    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 22nd May 2023
    *   Purpose         : This method will get all Products based related to Brands from Product Issue Hierarchy Object.
    *                     as we have more than 50k(90K records on 22nd May 2023). This method get called multiple times
    *                     with batch of 30k records in 1 single call, and adds the data to result of previous call.
    *   Input Param     : String lastRecordName - used to get next records based on this value.
    *                     Map<String, List<String>> - Map of Brand as Key and all related Products as value.
    *   Output Param    : ProductTreeWrapper
    *   User Story      : SCS-323
    */
    @AuraEnabled
    public static ProductTreeWrapper getProductTreeData(String lastRecordName, Map<String, List<String>> brandAndProductMap, String recordId){
        //1st call both "lastRecordName" and "brandAndProductMap" will be passed as null from UI, and then in next calls it will be
        //set from previous call result.
        String selectedBrand, selectedProduct, selectedComponent, selectedIssue, selectedDescription;
        if(brandAndProductMap == null) brandAndProductMap       = new Map<String, List<String>>();
        List<Product_Issue_Hierarchy__c> productHierarchyList   = new List<Product_Issue_Hierarchy__c>();
        Case_Line__c csLine                                         = new Case_Line__c();
        
        productHierarchyList                                    = ProductIssueHierarchyCtrlModel.getProductIssueHierarchyData(lastRecordName, 30000);

        for(Product_Issue_Hierarchy__c prodIssueHierarchyObj : productHierarchyList) {
            if(brandAndProductMap.containsKey(prodIssueHierarchyObj.Brand__c)) {
                if(!brandAndProductMap.get(prodIssueHierarchyObj.Brand__c).contains(prodIssueHierarchyObj.Product__c))
                    brandAndProductMap.get(prodIssueHierarchyObj.Brand__c).add(prodIssueHierarchyObj.Product__c);
            }                
            else 
                brandAndProductMap.put(prodIssueHierarchyObj.Brand__c, new List<String> {prodIssueHierarchyObj.Product__c});
        }        
        if(!productHierarchyList.isEmpty()) {
            return new ProductTreeWrapper(brandAndProductMap, false, productHierarchyList[productHierarchyList.size() - 1].Name, selectedBrand, selectedProduct, selectedComponent, selectedIssue, selectedDescription);
        }
        else {
            csLine = ProductIssueHierarchyCtrlModel.getCaseLineDetails(recordId);
            if(String.isNotBlank(csLine.Brand__c))   selectedBrand = csLine.Brand__c;
            if(String.isNotBlank(csLine.Product__c)) selectedProduct = csLine.Product__c;
            if(String.isNotBlank(csLine.Component__c)) selectedComponent = csLine.Component__c;
            if(String.isNotBlank(csLine.Issue__c)) selectedIssue = csLine.Issue__c;
            if(String.isNotBlank(csLine.Description__c)) selectedDescription = csLine.Description__c;
            return new ProductTreeWrapper(brandAndProductMap, true, null, selectedBrand, selectedProduct, selectedComponent, selectedIssue, selectedDescription);
        }
    }




    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 22nd May 2023
    *   Purpose         : This method will get all get All Type of Issues related to Product of a Brand.
    *   Input Param     : String brandName   - selected Brand by User.
    *                     String productName - selected Product by User.
    *   Output Param    : Map<String, List<String>> - Map of What is issue with as Key and Issue Descriptions related to What is the issue with as value.
    *   User Story      : SCS-323
    */
    @AuraEnabled
    public static Map<String, Map<String, List<String>>> getProductAndIssueData(String brandName, String productName) {
        Map<String, Map<String, List<String>>> productAndIssueMap   = new Map<String, Map<String, List<String>>>();
        List<Product_Issue_Hierarchy__c> productHierarchyList       = new List<Product_Issue_Hierarchy__c>();
        productHierarchyList                                        = ProductIssueHierarchyCtrlModel.getRelatedIssuesData(brandName, productName);
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


    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 29th May 2023
    *   Purpose         : This method will create Work Order, based on Issue selection by user from LWC Component on existing WorkOrder.
    *   Input Param     : String recordId - Record Page Work Order Id.
    *                     String selectedBrand 
    *                     String selectedProduct 
    *                     String selectedComponent 
    *                     String selectedIssue 
    *                     String selectedDescription 
    *   Output Param    : Id - newly created WorkOrder Id
    *   User Story      : SCS-170
    */
    @AuraEnabled
    public static String createWorkOrderForIssue(String recordId, String selectedBrand, String selectedProduct, String selectedComponent, String selectedIssue, String selectedDescription) {
        
        Case_Line__c caseLine = new Case_Line__c();
        caseLine.Id = recordId;
        caseLine.Brand__c = selectedBrand;
        caseLine.Issue__c = selectedIssue;
        caseLine.Description__c = selectedDescription;
        caseLine.Component__c = selectedComponent;
        caseLine.Product__c = selectedProduct;
        update caseLine;
        return 'Case Line Updated successfully.';
    }


    public class ProductTreeWrapper{
        @AuraEnabled
        public Map<String, List<String>> brandAndProductMap;
        @AuraEnabled
        public Boolean processedAllRecords;
        @AuraEnabled
        public String lastRecordName;
        @AuraEnabled
        public String selectedBrand;
        @AuraEnabled
        public String selectedProduct;
        @AuraEnabled
        public String selectedComponent;
        @AuraEnabled
        public String selectedIssue;
        @AuraEnabled
        public String selectedDescription;

        public ProductTreeWrapper(Map<String, List<String>> brandAndProductMap, Boolean processedAllRecords, String lastRecordName,
                                  String selectedBrand, String selectedProduct, String selectedComponent, String selectedIssue, String selectedDescription) {
            this.brandAndProductMap     = brandAndProductMap;   
            this.processedAllRecords    = processedAllRecords;
            this.lastRecordName         = lastRecordName;
            this.selectedBrand          = selectedBrand;
            this.selectedProduct        = selectedProduct;
            this.selectedComponent      = selectedComponent;
            this.selectedIssue          = selectedIssue;
            this.selectedDescription    = selectedDescription;
        }
    }
}