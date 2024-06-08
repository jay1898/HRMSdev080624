/*
Created By      : Balaji Ravindran
Created Date    : 14th July 2023
Purpose         : This is a Model class for ProductIssueHierarchyProdSearchCtrl
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class ProductIssueHierarchyProdSearchCtrlModel {
    
     /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 14th July 2023
    *   Purpose         : To get Product_Issue_Hierarchy__c records, ORDER BY Name field and filter by greater than lastRecordName variable
    *   Input Param     : String lastRecordName - used to get next records based on this value.
    *                     Integer recordLimit
    *   Output Param    : List of Product_Issue_Hierarchy__c.
    */
    public static List<Product_Issue_Hierarchy__c> getProductIssueHierarchyData(String lastRecordName, Integer recordLimit) {
        if(String.isBlank(lastRecordName))
            return [Select Id, Name, Brand__c, Product__c from Product_Issue_Hierarchy__c ORDER BY Name LIMIT: recordLimit]; 
        else
            return [Select Id, Name, Brand__c, Product__c from Product_Issue_Hierarchy__c 
                    where Name >: lastRecordName ORDER BY Name  LIMIT: recordLimit];
    }


    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 14th July 2023
    *   Purpose         : This method will get all get All Type of Issues related to Product of a Brand.
    *   Input Param     : String brandName   - selected Brand by User.
    *                     String productName - selected Product by User.
    *   Output Param    : List of Product_Issue_Hierarchy__c.
    */
    public static List<Product_Issue_Hierarchy__c> getRelatedIssuesData(String brandName, String productName) {
        return [Select Id, Service_Category__c,  What_is_the_issue_with__c, Component_noun__c, Description_Adj__c 
                from Product_Issue_Hierarchy__c
                where Brand__c =: brandName AND Product__c =: productName];
    }

    public static Case_Line__c getCaseLineDetails(String recordId) {
        return [Select Id, Brand__c, Product__c, Case__c, Issue__c, Component__c, Description__c
                from Case_Line__c where Id =: recordId]; 
    }

}