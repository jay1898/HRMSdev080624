/*
Created By      : Rahul Sangwan
Created Date    : 14 Sept 2023
Purpose         : This is controller to Change Product Owner.
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class ChangeProductOwnerController {
    

    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 12 Sept 2023
    *   Purpose         : Method to Change Installation Date.
    *   User Story      : SCS-901
    *   Input Param     : 1) orderIdList  - List of Order Id's.
                          2) ownerName - Product Owner to be changed.
    *   Output Param    : ProductSearchSerialNumberRespWrapper
    */
    @AuraEnabled
    public static ProductSearchSerialNumberRespWrapper updateProductOwner(List<String> orderIdList, String ownerName) {
        OrderAPIAuthenticateController.scope                = 'purchased_products_write';
        String payload                                      = '"variables": {"input": {"id":"'+orderIdList[0] + '","name": "'+ownerName + '"}}}';
        String respBody                                     = GraphQLAPIController.getResponseFromGraphQL('Order_API_Update_Product_Owner__c', payload);
        ProductSearchSerialNumberRespWrapper respObj        = ProductSearchSerialNumberRespWrapper.parse(respBody);

        return respObj;
    }

}