@isTest
public class AccountTriggerHandlerTest {
    static testMethod void testMethod1(){
        User usr = TestUtil.createUser(true);
        Account ac = TestUtil.createAccount('Person Account', false);
        ac.Fax='1234569879';
        insert ac;
        ac.Mail_Opt_Out__c=true;
        ac.Fax='1234569878';
        ac.OwnerId = usr.id;
        update ac;
        AccountTriggerHandler.updateCustomerEBSCallout();
        AccountTriggerHandler.createCustomerEBSCallout(ac.Id);
    }
    
    //Added By Dhruv Javiya On 29/10/2020
    static testMethod void testMethod2(){
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c br = TestUtil.createBranch('Test Branch', '100', bf.Id, true);
        
        Account parentAcc = TestUtil.createBranchAccount('Pella Account', false);
        parentAcc.Temp_branch_Number__c = '5';
        parentAcc.Branch_Number__c = '10';
        insert parentAcc;
        
        Account childAcc = TestUtil.createBranchAccount('Branch Account', false);
        childAcc.ParentId = parentAcc.Id;
        childAcc.Branch__c = br.Id;
        childAcc.Temp_branch_Number__c = '5';
        childAcc.Branch_Number__c = '10';
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
        Database.SaveResult saveResult = Database.insert(childAcc, dml);
        
        Address__c ad = TestUtil.createAddress(true);
        
        Address_Assignment__c aa = TestUtil.createAddressAssignment(ad.Id, null, false);
        aa.Identifying_Address__c=true;
        aa.Primary_Flag__c = true;
        aa.Address_Usage_Type__c = 'Bill To';
        aa.Account__c = childAcc.Id;
        insert aa;
        
        Address_Assignment__c aa1 = TestUtil.createAddressAssignment(ad.Id, null, false);
        aa1.Identifying_Address__c=true;
        aa1.Primary_Flag__c = true;
        aa1.Address_Usage_Type__c = 'Ship To';
        aa1.Account__c = childAcc.Id;
        insert aa1;
        
        childAcc.BillingCity = 'Test City';
        childAcc.ShippingCity = 'Test Ship';
        saveResult = Database.update(childAcc, dml);
        
        /*Account ac = TestUtil.createAccount('Person Account', false);
        ac.Branch__c = br.Id;
        insert ac;
        
        ac.Mail_Opt_Out__c=true;
        update ac;*/
        
        //AccountTriggerHandler.updateCustomerEBSCallout();
        //AccountTriggerHandler.createCustomerEBSCallout(ac.Id);
        AccountTriggerHandler.updateBrancIdsOnParentAccount(new List<Account> {childAcc});
    }
    //Added by Satheesh on 06/04/2021
    static testMethod void testMethod3(){
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c br = TestUtil.createBranch('Test Branch', '100', bf.Id, true);
        
        Account parentAcc = TestUtil.createBranchAccount('Pro_Lowes', false);
        parentAcc.Temp_branch_Number__c = '5';
        parentAcc.Branch_Number__c = '10';
        insert parentAcc;
        
        Account childAcc = TestUtil.createBranchAccount('Pro_Lowes', true);
        
    
        User usr = TestUtil.createUser(true);
        Address__c ad = TestUtil.createAddress(true);
        
        Address_Assignment__c aa = TestUtil.createAddressAssignment(ad.Id, null, false);
        aa.Identifying_Address__c=true;
        aa.Primary_Flag__c = true;
        aa.Address_Usage_Type__c = 'Bill To';
        aa.Account__c = childAcc.Id;
        insert aa;
        
        childAcc.BillingCity = 'Test City';
        childAcc.ShippingCity = 'Test Ship';
      //  childAcc.Mail_Opt_Out__c=true;
        childAcc.OwnerId=usr.Id;
        childAcc.ParentId = parentAcc.Id;
        childAcc.Branch__c = br.Id;
        childAcc.Temp_branch_Number__c = '5';
        childAcc.Branch_Number__c = '10';
        childAcc.RBM_Overwrite__c = usr.id;
        update childAcc;
        
        AccountTriggerHandler.updateCustomerEBSCallout();
        AccountTriggerHandler.createCustomerEBSCallout(childAcc.Id);
    }
}