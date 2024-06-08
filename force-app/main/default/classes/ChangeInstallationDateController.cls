/*
Created By      : Rahul Sangwan
Created Date    : 12 Sept 2023
Purpose         : This is controller to Change Installation Date.
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class ChangeInstallationDateController {
    
    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 12 Sept 2023
    *   Purpose         : Method to Change Installation Date.
    *   User Story      : SCS-901
    *   Input Param     : 1) serialNoList  - List of Order Id's.
                          2) installdate - Date to be changed.
    *   Output Param    : String (SUCCESS or Error Message)
    */
    @AuraEnabled
    public static ProductSearchSerialNumberRespWrapper updateInstallationDate(List<String> serialNoList, String installdate) {
        OrderAPIAuthenticateController.scope                = 'purchased_products_write';
        String payload                                      = '"variables": {"input": {"purchasedProductIds":'+JSON.serialize(serialNoList) + ',"installDate": "'+installdate + '"}}}';
        String respBody                                     = GraphQLAPIController.getResponseFromGraphQL('Order_API_Update_Install_Date__c', payload);
        ProductSearchSerialNumberRespWrapper respObj        = ProductSearchSerialNumberRespWrapper.parse(respBody);
        return respObj;
    }
}