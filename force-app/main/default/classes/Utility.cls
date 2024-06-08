/*
Created By      : Rahul Sangwan
Created Date    : 8 May 2023
Purpose         : This is a Utility class to add reusable methods. 
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class Utility {
    
    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 8 May 2023
    *   Purpose         : To check whether needs to run functionality or not based on Custom setting.
    *   Input Param     : String of field API name of the Custom setting field, which needs to be checked.
    *   Output Param    : Boolean, if it retuns TRUE means functionality should not run.
    */
    // @Deprecated
    // This method is deprecated. Use isFunctionalityActive(String fieldName) instead.
    public static Boolean checkFunctionalityActiveOrNot(String fieldName) {
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.get(fieldName) == true || cs.Disable_All__c) ) return true;
        else return false; 
    }

    public static Boolean isFunctionalityActive(String fieldName) {
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.get(fieldName) == true || cs.Disable_All__c) ) return false;
        else return true; 
    }

    public static String getKeyPrefixOfObjectId(String objectName) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getKeyPrefix();
    }


    
}