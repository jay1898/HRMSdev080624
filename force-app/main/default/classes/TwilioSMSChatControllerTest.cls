/**
* @description       : TwilioSMSChatControllerTest Test class for TwilioSMSChatController
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* History   
* Ver   Date         Author        Modification
* 1.0   26-03-2023   Dhruv Javiya  Initial Version()
**/
@isTest
public class TwilioSMSChatControllerTest {
    public static String UNIQUEUERNAME = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
    @TestSetup
    public static void setupData(){  
        List<User> listUser=new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name=:Label.Send_Outbound_CRM_SMS_Profile];
        User u=TestUtil.createUser(false); 
        //u.ProfileId = p.Id;
        u.Email='Adminstrator@mail.com';
        listUser.add(u);
        User replacementUser = TestUtil.createSalesRep('Replacement Sales', 'Replacement Sales Rep', 'test_trade_comm', 'sales_rep',false);
        replacementUser.Email='replacementUser@mail.com';
        listUser.add(replacementUser);
        insert listUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :Label.Send_Outbound_CRM_SMS_Permission_Set];
        List<PermissionSetAssignment> listPSA=new List<PermissionSetAssignment>();
        //listPSA.add(new PermissionSetAssignment(AssigneeId = replacementUser.id, PermissionSetId = ps.Id));
        listPSA.add(new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id));
        insert listPSA;
        System.runAs(u) {
            // Create Account
            Account ac = TestUtil.createAccount('Person Account', false);
            ac.phone='9898989898';
            insert ac;
            
            // Create Opportunity 
            Opportunity opp = TestUtil.createOpportunity('TEst', ac.Id, UserInfo.getUserId(), false);
            opp.Opportunity_No__c = '123';
            opp.OwnerId=u.id;
            insert opp ;
            // Create Lead
            Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 
            
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
            bf.Branch_Family_Number__c = '124';
            insert bf; 
            Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
            Question_Template__c questionTemp = TestUtil.createQuestion_Template(true);
            Branch_Question_Junction__c objBQJ7 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,1);
            insert objBQJ7;
            branch.Enable_SMS_Feature__c = true;
            update branch;
            // Create Opreating Hours
            OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
            Account_Branch_Profile__c ABP = TestUtil.createAccountBranchProfile(ac.Id, branch.Id, true);
            
            // Create Time Slot
            TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
            // Create Service Appointment
            ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, false);
            insert sa;
            // Create Parent Territory
            ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
            
            // Create Child Territory under Parent Territory
            ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, true);
            
            // Create Sub Child Territory under Child Territory
            ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('Sub Child', childST.Id, oh.Id, true);
            
            opp.First_SMS_Replied__c = 'N';
            opp.Zone__c = childST.Id ;
            
            opp.Account_Branch_Profile__c = ABP.Id;
            update opp ;
            
        }
    }
    static testMethod void TestEnableSendReplyDisabledReply() {
        Test.startTest();
        
        User replacementUser=[SELECT id FROM User Where Email='replacementUser@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        String message=TwilioSMSChatController.enableSendSMS(opp.id);
        System.assert(message=='DISABLED_REPLY');
        
        Test.stopTest(); 
    } 
    static testMethod void TestEnableSendReplyBranchSMSEnabledFirstReplyIsYes() {
        Test.startTest();
        User User=[SELECT id FROM User Where Email='Adminstrator@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        opp.First_SMS_Replied__c = 'Yes';
        Update opp;
        System.runAs(User) {
            String message=TwilioSMSChatController.enableSendSMS(opp.id);
            System.assert(message=='ENABLED_REPLY');
        }
        Test.stopTest(); 
    } 
    static testMethod void TestEnableSendReplyBranchSMSEnabledSMSReplyIsY() {
        Test.startTest();
        User User=[SELECT id FROM User Where Email='Adminstrator@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        opp.First_SMS_Replied__c = 'Y';
        Update opp;
        System.runAs(User) {
            String message=TwilioSMSChatController.enableSendSMS(opp.id);
            System.assert(message=='ENABLED_REPLY');
        }
        Test.stopTest(); 
    } 
    static testMethod void TestEnableSendReplyBranchSMSEnabledTwillioMessageBodyYES() {
        Test.startTest();
        User User=[SELECT id FROM User Where Email='Adminstrator@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        
        TwilioMessage__c TW= TestUtil.createTwilioMessage('Survey','Inbound','YES','9898989898',false);
        TW.Opportunity__c=opp.id;
        Insert TW;    
        System.runAs(User) {
            String message=TwilioSMSChatController.enableSendSMS(opp.id);
            System.assert(message=='ENABLED_REPLY');
        }
        Test.stopTest(); 
    } 
    static testMethod void TestEnableSendReplyBranchSMSEnabledTwillioMessageBodyY() {
        Test.startTest();
        User User=[SELECT id FROM User Where Email='Adminstrator@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        TwilioMessage__c TW= TestUtil.createTwilioMessage('Survey','Inbound','Y','9898989898',false);
        TW.Opportunity__c=opp.id;
        Insert TW;        
        System.runAs(User) {
            String message=TwilioSMSChatController.enableSendSMS(opp.id);
            System.assert(message=='ENABLED_REPLY');
        }
        Test.stopTest(); 
    } 
    static testMethod void TestEnableSendBranchSMSDisabledNoTwillioMessage() {
        Test.startTest();
        User User=[SELECT id FROM User Where Email='Adminstrator@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        
        System.runAs(User) {
            String message=TwilioSMSChatController.enableSendSMS(opp.id);
            System.assert(message=='DISABLED_REPLY');
        }
        Test.stopTest(); 
    } 
    static testMethod void TestEnableSendBranchSMSDisabledTwillioMessageBodyYES() {
        Test.startTest();
        User User=[SELECT id FROM User Where Email='Adminstrator@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        Branch__c b = [SELECT Id, Enable_SMS_Feature__c FROM Branch__c LIMIT 1];
        b.Enable_SMS_Feature__c = false;
        update b;
        TwilioMessage__c TW= TestUtil.createTwilioMessage('Survey','Inbound','YES','9898989898',false);
        TW.Opportunity__c=opp.id;
        Insert TW;     
        System.runAs(User) {
            String message=TwilioSMSChatController.enableSendSMS(opp.id);
            System.assert(message=='ENABLED_REPLY');
        }
        Test.stopTest(); 
    } 
    static testMethod void TestEnableSendBranchSMSDisabledTwillioMessageBodyY() {
        Test.startTest();
        User User=[SELECT id FROM User Where Email='Adminstrator@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        Branch__c b = [SELECT Id, Enable_SMS_Feature__c FROM Branch__c LIMIT 1];
        b.Enable_SMS_Feature__c = false;
        update b;
        TwilioMessage__c TW= TestUtil.createTwilioMessage('Survey','Inbound','Y','9898989898',false);
        TW.Opportunity__c=opp.id;
        Insert TW;        
        System.runAs(User) {
            String message=TwilioSMSChatController.enableSendSMS(opp.id);
            System.assert(message=='ENABLED_REPLY');
        }
        Test.stopTest(); 
    } 
    static testMethod void TestEnableSendPermissionSetAssignmentMissing() {
        Test.startTest();
        User User=[SELECT id FROM User Where Email='replacementUser@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        opp.First_SMS_Replied__c = 'Yes';
        Update opp;
        System.runAs(User) {
            String message=TwilioSMSChatController.enableSendSMS(opp.id);
            System.assert(message=='DISABLED_REPLY');
        }
        Test.stopTest(); 
    } 
    static testMethod void TestGetSMSRecords() {
        Test.startTest();
        User User=[SELECT id FROM User Where Email='Adminstrator@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        Branch__c b = [SELECT Id, Enable_SMS_Feature__c FROM Branch__c LIMIT 1];
        b.Enable_SMS_Feature__c = false;
        update b;
        TwilioMessage__c TW= TestUtil.createTwilioMessage('Survey','Inbound','Y','9898989898',false);
        TW.Opportunity__c=opp.id;
        Insert TW;          
        System.runAs(User) {
            List<TwilioMessage__c> TWList=TwilioSMSChatController.getSMSRecords(opp.id,'Survey');
            system.assertNotEquals(TWList, null);
        }
        Test.stopTest(); 
    } 
    static testMethod void TestSendFirstSMSRecord() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_TwilioAPICallout ());
        User User=[SELECT id FROM User Where Email='Adminstrator@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        Branch__c b = [SELECT Id, Enable_SMS_Feature__c FROM Branch__c LIMIT 1];
        b.Enable_SMS_Feature__c = false;
        update b;
        TwilioMessage__c TW= TestUtil.createTwilioMessage('Survey','Inbound','Y','9898989898',false);
        TW.Opportunity__c=opp.id;
        Insert TW;          
        System.runAs(User) {
            TwilioSMSChatController.sendFirstSMSRecord('Survey','Testing',opp.id);
        }
        Test.stopTest(); 
    } 
    static testMethod void TestCreateSMSRecord() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_TwilioAPICallout ());
        User User=[SELECT id FROM User Where Email='Adminstrator@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        Branch__c b = [SELECT Id, Enable_SMS_Feature__c FROM Branch__c LIMIT 1];
        b.Enable_SMS_Feature__c = false;
        update b;
        TwilioMessage__c TW= TestUtil.createTwilioMessage('Survey','Inbound','Y','9898989898',false);
        TW.Opportunity__c=opp.id;
        Insert TW;          
        System.runAs(User) {
            TwilioSMSChatController.createSMSRecord('Survey','Testing',opp.id);
        }
        Test.stopTest(); 
    } 
    static testMethod void TestEnableSendBranchSMSDisabledFIRST_QUALIFICATION_SMS() {
        Test.startTest();
        User User=[SELECT id FROM User Where Email='Adminstrator@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        Branch__c b = [SELECT Id, Enable_SMS_Feature__c FROM Branch__c LIMIT 1];
        b.Enable_SMS_Feature__c = false;
        update b;
         
        System.runAs(User) {
            String message=TwilioSMSChatController.enableSendSMS(opp.id);
            System.assert(message=='FIRST_QUALIFICATION_SMS');
        }
        Test.stopTest(); 
    } 
     static testMethod void TestEnableSendBranchSMSDisabledBreak() {
        Test.startTest();
        User User=[SELECT id FROM User Where Email='Adminstrator@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        Branch__c b = [SELECT Id, Enable_SMS_Feature__c FROM Branch__c LIMIT 1];
        b.Enable_SMS_Feature__c = false;
        update b;
         TwilioMessage__c TW= TestUtil.createTwilioMessage('Survey','Inbound','test','9898989898',false);
        TW.Opportunity__c=opp.id;
        Insert TW; 
        System.runAs(User) {
            String message=TwilioSMSChatController.enableSendSMS(opp.id);
            System.assert(message=='DISABLED_REPLY');
        }
        Test.stopTest(); 
    } 
     static testMethod void TestEnableSendBranchSMSEnabledBreak() {
        Test.startTest();
        User User=[SELECT id FROM User Where Email='Adminstrator@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
         TwilioMessage__c TW= TestUtil.createTwilioMessage('Survey','Inbound','test','9898989898',false);
        TW.Opportunity__c=opp.id;
        Insert TW;
        System.runAs(User) {
            String message=TwilioSMSChatController.enableSendSMS(opp.id);
            System.assert(message=='DISABLED_REPLY');
        }
        Test.stopTest(); 
    } 
    static testMethod void TestSendFirstSMSRecordError() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_TwilioAPICallout ());
        User User=[SELECT id FROM User Where Email='replacementUser@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        Branch__c b = [SELECT Id, Enable_SMS_Feature__c FROM Branch__c LIMIT 1];
        b.Enable_SMS_Feature__c = false;
        update b;
        TwilioMessage__c TW= TestUtil.createTwilioMessage('Survey','Inbound','Y','9898989898',false);
        TW.Opportunity__c=opp.id;
        Insert TW;          
        System.runAs(User) {
            try{
                 TwilioSMSChatController.sendFirstSMSRecord('Survey','Testing',opp.id);
            }catch(Exception e){
                
            }
        }
        Test.stopTest(); 
    } 
    static testMethod void TestCreateSMSRecordError() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_TwilioAPICallout ());
        User User=[SELECT id FROM User Where Email='replacementUser@mail.com'];
        Opportunity Opp=[SELECT Id,stageName,account.phone,recordtype.developerName FROM Opportunity limit 1];
        Branch__c b = [SELECT Id, Enable_SMS_Feature__c FROM Branch__c LIMIT 1];
        b.Enable_SMS_Feature__c = false;
        update b;
        TwilioMessage__c TW= TestUtil.createTwilioMessage('Survey','Inbound','Y','9898989898',false);
        TW.Opportunity__c=opp.id;
        Insert TW;          
        System.runAs(User) {
            try{
                TwilioSMSChatController.createSMSRecord('Survey','Testing',opp.id);
            }catch(Exception e){
                
            }
        }
        Test.stopTest(); 
    } 
}