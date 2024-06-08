@isTest(seeAllData=true)
//Added By Satheesh Bojanapu On 17/04/2021
public class ContactTriggerHandlerTest {
    static testMethod void testMethod1(){
     	List<Contact> conNewList = new List<Contact>();
        Map<Id, Contact> mpCon = new Map<Id, Contact>();
        Account ac = TestUtil.createBranchAccount('Pro_Lowes', true);
        Account ac2 = TestUtil.createBranchAccount('Pro_Lowes', true);
		Contact con = TestUtil.createContact(ac.Id,'TestFirst Name1',true);
        mpCon.put(con.Id,con);
        con.Title = '6789096780';
        update con;
        con.AccountId=ac2.Id;
        update con;
        conNewList.add(con);
        // call method to cover unused method
        ContactTriggerHandler.updatePrimaryContact(conNewList, mpCon);
    }
}