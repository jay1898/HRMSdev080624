@isTest
private class AccountRequestWrapperTest 
{
    static testMethod void testMethod1() 
    {
        String str = '{"accountnumber":"1235", "accountname":"TEst", "spokerecid":"12", "spokesystemcode":"123",' +
        			' "byuser":"Test", "status":"Test", "mdmaccountid":"Test", "mdmbranchid":"Test", "mdmpartyid":"Test",' +
        			' "addressasignments" : [{"objectcode":"Test", "addressusagecode":"TEst", "primaryflag":"Test", "status":"Test"'+
        									', "spokerecid":"Test", "spokesystemcode":"Test", "mdmaddressid":"Test", "mdmobjectrefid":"Test","mdmassignmentid":"Test", '+ 
        									' "address": {"addressline1":"Test", "addressline2":"Test", "addressline3":"Test", "city":"Test", "county":"Test",'+
        												' "state":"Tst", "country":"Test", "zipcode":"Test", "spokerecid":"Test", "spokesystemcode":"Test", ' +
        												' "byuser":"Test", "status":"tet", "mdmaddressid":"Test" } }], ' + 
        			' "contacts" : [{"spokerecid":"Test", "spokesystemcode":"Test", "primaryflag":"Test", "objectcode":"Test", "byuser":"Test",' +
        							' "status":"Test", "mdmcontactid":"Test", "mdmpartyid":"TEst", "mdmobjectrefid":"TEst" }]  }';
        
        try{
        	AccountRequestWrapper arw = new AccountRequestWrapper();
        	AddressAssignmentRecordType aart = new AddressAssignmentRecordType();
        	ContactRecordType crt = new ContactRecordType();
        	AddressRecordType art = new AddressRecordType();
        	arw = AccountRequestWrapper.parse(str);
        	System.debug('UAC: arw ' + arw);
        }
        catch(Exception e )
        {
        	System.debug('UAC: Exception ' + e.getMessage() );
        }
    }
}