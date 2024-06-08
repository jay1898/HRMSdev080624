@isTest
public class CaseTriggerTest {
    
    @TestSetup
    static void makeData(){
        Account accountObj              = TestUtil.createBranchAccount('Pella Account', false);
        accountObj.BillingPostalCode    = '12345'; 
        insert accountObj;
        Contact contactObj              = TestUtil.createContact(accountObj.Id, 'test', false);
        contactObj.MailingPostalCode    = '12345';
        insert contactObj;
        Branch_Grouping__c bf           = TestUtil.createBranchGrouping('BranchGrouping', true);
        Branch__c br                    = TestUtil.createBranch('Albany', 'Albany', bf.Id, true);
        // Create Opreating Hours
        OperatingHours oh               = TestUtil.createOpreatingHours('Custom', true);
        //Create PIES Territory
        ServiceTerritory st             = TestUtil.createParentServiceTerritory('12345', oh.Id, br.Id, false );
        st.Name = '12345';
        Insert st ;

        Group grp                       = new Group();
        grp.name                        = Constant.SERVICE_GROUP_PREFIX + ' Albany Albany';
        grp.Type                        = 'Regular'; 
        Insert grp; 
        
        Branch_To_BranchGroup_Association__c branchGroupAssociationObj  = new Branch_To_BranchGroup_Association__c();
        branchGroupAssociationObj.Branch__c         = br.Id;
        branchGroupAssociationObj.BranchGroup__c    = bf.Id;
        insert branchGroupAssociationObj;
        
    }
    
    
    @isTest
    static void testCaseAssignment() {
        Case caseObj        = new Case();
        caseObj.Status      = 'Pending';
        caseObj.Origin      = 'Email';
        // caseObj.AssignedBranch__c = [Select Id from Branch__c LIMIT 1].Id;
        caseObj.ContactId   = [Select Id from Contact LIMIT 1].Id;
        CaseObj.Business_Segment__c = 'Trade';
        insert caseObj;
        Id branchId         = [Select Id from Branch__c LIMIT 1].Id;
        System.assertEquals(branchId, [Select Id, AssignedBranch__c from Case where Id =: caseObj.Id].AssignedBranch__c);
        caseObj.OwnerId     = UserInfo.getUserId();
        update caseObj;
        caseObj.OwnerId     = [Select Id from Group where Type = 'Queue' LIMIT 1].Id;
        update caseObj;
        CaseTriggerHandlerService.isCommunicationQueueMember(UserInfo.getUserId());
     /*    Case caseObj1                = new Case();
        caseObj1.AccountId              = '0015900000ZHmzmAAD';
        caseObj1.ContactId              = '0035900000U1ciGAAR';
    //   caseObj1.ContactId           = [Select Id from Contact LIMIT 1].Id;
        caseObj1.Id                    ='500O9000001SlGNIA0';
        Map<id, Case> newList = new Map<id, case>();
        newList.put(caseObj1.Id , caseObj);
        CaseTriggerHandlerService.checkAndInsertContact(newList);
        caseObj1.ContactId           = [Select Id from Contact LIMIT 1].Id;
        Contact con = new Contact();
        con.AccountId=[Select Id,AccountId  from Contact LIMIT 1].Id;
        
         caseObj1.AccountId           = [Select Id from Account LIMIT 1].Id;
      //  case updateAccount =[Select Id, Contact.AccountId, AccountId from Case where id ='500O9000001SlGNIA0'];
        
        con.AccountId    = caseObj1.Contact.AccountId;*/
       

        Contact testContact = new Contact(LastName = 'Test Contact', AccountId ='0015900000ZHmzmAAD');
        insert testContact;

        Case testCase = new Case(Subject = 'Test Case', ContactId = testContact.Id, AccountId = null);
        insert testCase;

        // Create a Map with the Case Id and Case
        Map<Id, Case> caseMap = new Map<Id, Case>();
        caseMap.put(testCase.Id, testCase);

        // Call the method to be tested
        CaseTriggerHandlerService.checkAndInsertContact(caseMap);

        // Retrieve the updated Case
        Case updatedCase = [SELECT Id, AccountId FROM Case WHERE Id = :testCase.Id];

        // Assert that the Case's AccountId was updated to match the related Contact's AccountId
        System.assertEquals(testContact.AccountId, updatedCase.AccountId);
    }
    @isTest
    static void testCheckAndInsertContact() {
        // Create a test Case record and a related Contact record
      
    }


    @isTest
    static void testCaseCreation() {
        Case caseObj            = new Case();
        caseObj.Status          = 'Pending';
        caseObj.Origin          = 'Email';
        caseObj.SuppliedEmail   = 'test@test.com';
        caseObj.OwnerId         = [Select Id from Group where Type = 'Queue' LIMIT 1].Id;
        CaseObj.Business_Segment__c = 'Trade';
        insert caseObj;
    }
  
    @isTest
    public static void testCompletedCaseCannotBeMerged() {
        Account account1 = TestUtil.createAccount('Person Account', true);
        Case case1 = new Case();
        case1.Status = 'Completed';
        Case1.Business_Segment__c = 'Trade';
        // case1.Customer_Number__c = account1.Id;
        insert case1;

        Database.SaveResult saveResult = Database.update(case1, false);
    }
    
    @isTest
    public static void testCancelledCaseCannotBeMerged() {
        Account account1 = TestUtil.createAccount('Person Account', true);
        Case case1 = new Case();
        case1.Status = 'Cancelled';
        Case1.Business_Segment__c = 'Trade';
        // case1.Customer_Number__c = account1.Id;
        insert case1;

        Database.SaveResult saveResult = Database.update(case1, false);  
    } 
    
    @isTest
    public static void testCheckCcOtherEmailAddresses() {
        Account account1 = TestUtil.createAccount('Person Account', true);
        Case case1 = new Case();
        case1.Cc_Other_Email_Addresses__c = 'test@gmail.com';
        case1.Origin = 'Email';
        case1.Description = 'This is Test Class.';
        Case1.Business_Segment__c = 'Trade';
        insert case1;
    }
    
    @isTest
    public static void testSendEmailOnCaseStatusUpdate(){
        Account accountObj              = TestUtil.createBranchAccount('Pella Account', false);
        insert accountObj;
        Contact contactObj              = TestUtil.createContact(accountObj.Id, 'test', false);
        contactObj.email = 'test@gmail.com';
        insert contactObj;
        Case case1 = new Case();
        case1.ContactId = contactObj.Id;
        case1.Status = 'Pending';
        Case1.Business_Segment__c = 'Trade';
        insert case1;
        case1.Status = 'Completed';
        update case1;
        case1.Status = 'Pending';
        update case1;
        case1.Status = 'Cancelled';
        test.starttest();
        update case1;
        test.stoptest();
    }


    @isTest
    static void testCaseSharing() {
        Case caseObj                = new Case();
        caseObj.Status              = 'Pending';
        caseObj.Origin              = 'Email';
        caseObj.AssignedBranch__c   = [Select Id from Branch__c LIMIT 1].Id;
        caseObj.ContactId           = [Select Id from Contact LIMIT 1].Id;
        CaseObj.Business_Segment__c = 'Trade';
        insert caseObj;
        Id oldBranch                = caseObj.AssignedBranch__c;
        //Case_Escalation__c caseEscObj = new Case_Escalation__c(Case__c = caseObj.Id, Name = 'test'); 
        Case_Escalation__c caseEscObj = new Case_Escalation__c(Case__c = caseObj.Id);    // Getting error when deploying  Field is not writeable: Case_Escalation__c.Name 
        insert caseEscObj;
        Id serviceRTId                = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get(Constant.WO_CS_RT).getRecordTypeId();
        WorkOrder wo = new WorkOrder(recordtypeId = serviceRTId, CaseId = caseObj.Id);
        insert wo;
        Id csRecordTypeId        = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(Constant.SA_CS_RT).getRecordTypeId();
        ServiceAppointment rec = new ServiceAppointment(RecordTypeId = csRecordTypeId, Subject = 'test', 
                                                        Description = 'Test', ParentRecordId = wo.Id );
        insert rec;
        Branch_Grouping__c bf           = TestUtil.createBranchGrouping('BranchGrouping2', true);
        Branch__c br                    = TestUtil.createBranch('Albany 2', 'Albany 2', bf.Id, true);
        Group grp                       = new Group();
        grp.name                        = Constant.SERVICE_GROUP_PREFIX + ' Albany 2 Albany 2';
        grp.Type                        = 'Regular'; 
        Insert grp; 
        caseObj.AssignedBranch__c       = br.Id;
        update caseObj;

        Map<Id, Id> woAndCaseMap        = new Map<Id, Id>();
        woAndCaseMap.put(wo.Id, caseObj.Id);

        Map<Id, Id> caseAndRelatedOldBranchMap = new Map<Id, Id>();
        caseAndRelatedOldBranchMap.put(caseObj.Id, oldBranch);

        Map<Id, Id> saAndCaseMap               = new Map<Id, Id>();
        saAndCaseMap.put(rec.Id, caseObj.Id);

        Map<Id, Id> ceAndCaseMap               = new Map<Id, Id>();
        ceAndCaseMap.put(caseEscObj.Id, caseObj.Id);

        System.enqueueJob(new WorkOrderNewBranchSharingQueueable(woAndCaseMap, caseAndRelatedOldBranchMap));

        System.enqueueJob(new SABranchSharingQueueable(caseAndRelatedOldBranchMap));

        System.enqueueJob(new SANewBranchSharingQueueable(saAndCaseMap, caseAndRelatedOldBranchMap));

        System.enqueueJob(new CaseEscalationBranchSharingQueueable(caseAndRelatedOldBranchMap));

        System.enqueueJob(new CaseEscNewBranchSharingQueueable(ceAndCaseMap, caseAndRelatedOldBranchMap));
    }
    
    @isTest
    public static void testAssignedQueue() {
        Case caseObj        = new Case();
        caseObj.Status      = 'Pending';
        caseObj.Origin      = 'Email';
        CaseObj.Business_Segment__c = 'Trade';
        caseObj.ContactId   = [Select Id from Contact LIMIT 1].Id;
        insert caseObj;
        
        // Case 1 : if inserted by user
        System.assertEquals(caseObj.Assigned_Queue__c, null);
        
        // Case 2 :  if updated by user
        caseObj.Origin = 'WhatsApp';
        update caseObj;
        System.assertEquals(caseObj.Assigned_Queue__c, null);
        
        Group ownerRec = [Select Id, Name from Group where Type = 'Queue' LIMIT 1];
        // Case 3 : if Owner updated as Queue
        caseObj.OwnerId = ownerRec.Id;
        update caseObj; 
        System.assertEquals([Select Assigned_Queue__c from Case where Id = :caseObj.Id LIMIT 1].Assigned_Queue__c, ownerRec.Name);
    }
/**************************/    
@isTest
    public static void testcreateUpdateCaseStatus() {
        Test.startTest();
        Account accountObj              = TestUtil.createBranchAccount('Pella Account', false);
        insert accountObj;
        Contact contactObj              = TestUtil.createContact(accountObj.Id, 'test', false);
        contactObj.email = 'test@gmail.com';
        insert contactObj;
        List<case> caselist = new List<Case>();
        Case case1 = new Case();
        case1.Status = 'Closed';
        case1.OwnerId= [Select Id from Group where Type = 'Queue' LIMIT 1].Id;        
        case1.Origin = 'Email';
        case1.Description = 'This is Test Class.';
        Case1.Business_Segment__c = 'Trade';
        caseList.add(case1);
        insert caselist;
        case1 = [SELECT CaseNumber FROM Case WHERE Id = :case1.Id LIMIT 1];
        Case_Status_Change__c case2 = new Case_Status_Change__c();
        case2.Name = 'test';
        case2.Case_Number__c = case1.Id;
        case2.Field_Value__c = 'Status';
        case2.Field_Type__c = 'Status';
        case2.Start_Time__c = datetime.now();
        case2.End_Time__c = datetime.now();
        insert case2;
        Test.stopTest();
        
    }
}