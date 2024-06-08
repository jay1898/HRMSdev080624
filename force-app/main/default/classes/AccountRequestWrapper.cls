/*
Created By: Anh Phan
Created Date: 11/24/2019
Purpose: The create customer request strucutre.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date :
Purpose: 
----------------------------------------------------------------------------------------------
*/

public class AccountRequestWrapper {

    private String accountnumber = null;
    
    private String accountname = null;
    
    private String spokerecid = null;
    
    private String spokesystemcode = null;
    
    private String byuser = null;
    
    private String status = null;
    
    private String mdmaccountid = null;    
    
    private String mdmbranchid = null;
    
    private String mdmpartyid = null;
    
    private List<AddressAssignmentRecordType> addressasignments = null;
    
    private List<ContactRecordType> contacts = null;
    
    public static AccountRequestWrapper parse(String customerRequest){
        return (AccountRequestWrapper) System.JSON.deserialize(customerRequest, AccountRequestWrapper.class);
    }
    
}//End of AccountRequestWrapper