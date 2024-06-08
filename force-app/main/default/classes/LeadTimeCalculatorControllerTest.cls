@isTest
public class LeadTimeCalculatorControllerTest {
    
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
        system.debug('branch1: ' + br.Id);
        
        Case caseObj        = new Case(Status='Pending',Origin='Email');
        insert caseObj;
        
        list <Delivery_Method__c> methodsToInsert = new list <Delivery_Method__c>();
        Delivery_Method__c delivMethod1 = new Delivery_Method__c(Name__c = 'Pella Truck - Standard');
        methodsToInsert.add(delivMethod1);
        Delivery_Method__c delivMethod2 = new Delivery_Method__c(Name__c = 'Pella Truck - Rapid');
        methodsToInsert.add(delivMethod2);
        Delivery_Method__c delivMethod3 = new Delivery_Method__c(Name__c = 'FedEx Ground - Rapid');
        methodsToInsert.add(delivMethod3);
        Delivery_Method__c delivMethod4 = new Delivery_Method__c(Name__c = 'FedEx Overnight - Rapid');
        methodsToInsert.add(delivMethod4);
        insert methodsToInsert;
        
        list <Branch_Delivery_Time__c> deliveryTimesToInsert = new list <Branch_Delivery_Time__c>(); 
        Branch_Delivery_Time__c branchDelivery = new Branch_Delivery_Time__c();
        branchDelivery.Branch__c = br.Id;
        branchDelivery.Delivery_Method__c = methodsToInsert[0].Id;
        branchDelivery.Custom_Prefinish__c = 0;  
        branchDelivery.Load_To_Truck__c = 0; 
        branchDelivery.LRD_Wait__c = 0; 
        branchDelivery.Padding__c = 1; 
        branchDelivery.Transit_Wood__c = 2; 
        branchDelivery.Place_Order__c = 0;
        branchDelivery.Deliver_to_pod_tech__c = 0;
        branchDelivery.Pick_up_from_pod__c = 0;
        deliveryTimesToInsert.add(branchDelivery);
        
        Branch_Delivery_Time__c branchDelivery1 = new Branch_Delivery_Time__c();
        branchDelivery1.Branch__c = br.Id;
        branchDelivery1.Delivery_Method__c = methodsToInsert[1].Id;
        branchDelivery1.Custom_Prefinish__c = 0;  
        branchDelivery1.Load_To_Truck__c = 0; 
        branchDelivery1.LRD_Wait__c = 0; 
        branchDelivery1.Padding__c = 1; 
        branchDelivery1.Transit_Wood__c = 2; 
        branchDelivery1.Place_Order__c = 0;
        branchDelivery1.Deliver_to_pod_tech__c = 0;
        branchDelivery1.Pick_up_from_pod__c = 0;
        branchDelivery1.Ship_Wood__c = 'T';
        deliveryTimesToInsert.add(branchDelivery1);
        
        Branch_Delivery_Time__c branchDelivery2 = new Branch_Delivery_Time__c();
        branchDelivery2.Branch__c = br.Id;
        branchDelivery2.Delivery_Method__c = methodsToInsert[2].Id;
        branchDelivery2.Custom_Prefinish__c = 0;  
        branchDelivery2.Load_To_Truck__c = 0; 
        branchDelivery2.LRD_Wait__c = 0; 
        branchDelivery2.Padding__c = 1; 
        branchDelivery2.Transit_Wood__c = 2; 
        branchDelivery2.Place_Order__c = 0;
        branchDelivery2.Deliver_to_pod_tech__c = 0;
        branchDelivery2.Pick_up_from_pod__c = 0;
        branchDelivery2.Ship_Wood__c = 'M';
        deliveryTimesToInsert.add(branchDelivery2);
 
        Branch_Delivery_Time__c branchDelivery3 = new Branch_Delivery_Time__c();
        branchDelivery3.Branch__c = br.Id;
        branchDelivery3.Delivery_Method__c = methodsToInsert[3].Id;
        branchDelivery3.Custom_Prefinish__c = 0;  
        branchDelivery3.Load_To_Truck__c = 0; 
        branchDelivery3.LRD_Wait__c = 0; 
        branchDelivery3.Padding__c = 1; 
        branchDelivery3.Transit_Wood__c = 2;
        branchDelivery3.Place_Order__c = 0;
        branchDelivery3.Deliver_to_pod_tech__c = 0;
        branchDelivery3.Pick_up_from_pod__c = 0;
        branchDelivery3.Ship_Wood__c = 'W';
		deliveryTimesToInsert.add(branchDelivery3);   
        insert deliveryTimesToInsert;
        
        Brand_Shipping__c brand1 = new Brand_Shipping__c();
        brand1.Brand__c = 'Entry Systems';
        insert brand1;
        
        Category_Questions__c question1 = new Category_Questions__c();
        question1.Product_Category__c = 'Full Doors and Panels';
        question1.Brand_Shipping__c = brand1.Id;
        question1.Question_Text__c = 'Traditional - Casement / Awning';
        question1.Manufacture_Days_Rapid__c = 60;
        question1.Manufacture_Days_Standard__c = 70;
        insert question1;
        
        Brand_Shipping__c brandShipping = new Brand_Shipping__c();
        brandShipping.Name__c = 'Lifestyle Series without HGP';
        brandShipping.Brand__c = 'Lifestyle Series';
        brandShipping.Is_Wood__c = true;
        insert brandShipping;
    }
    
    
    @isTest
    static void testGetQuestions() {
        List <Category_Questions__c> returnedQuestions = LeadTimeCalculatorController.getCategoryQuestions('Entry Systems','Full Doors and Panels');
        system.assertEquals('Traditional - Casement / Awning',returnedQuestions[0].Question_Text__c);
    }
    
    @isTest
    static void testGenerateLeadTimes() {
        List <Category_Questions__c> question = [Select Id FROM Category_Questions__c WHERE Product_Category__c = 'Full Doors and Panels'];
        List <Branch__c> branch = [Select Id FROM Branch__c WHERE Name = 'Albany'];
        List <LeadTimeCalculatorController.DeliveryLeadTimes> leadTimes = LeadTimeCalculatorController.generateLeadTimes(JSON.serialize(question), branch[0].Id, System.today(), '', '', 'Lifestyle Series');
        system.assert(leadTimes.size() == 4);
        LeadTimeCalculatorController.getPartSourceOptions(branch[0].Id);
        String caseId = [Select Id from Case Limit 1].Id;
        LeadTimeCalculatorController.createStockPartCaseLines(caseId,Date.today(), 10, 'test', null, 1, '123');
        LeadTimeCalculatorController.formatDate(Date.today());
    }
    
    @isTest
    static void testGenerateLeadTimesDisabled() {
        List <Category_Questions__c> question = [Select Id FROM Category_Questions__c WHERE Product_Category__c = 'Full Doors and Panels'];
        List <Branch__c> branch = [Select Id FROM Branch__c WHERE Name = 'Albany'];
        List <Branch_Delivery_Time__c> branchDeliveryTimes = [Select Id FROM Branch_Delivery_Time__c WHERE Branch__c = :branch[0].Id];
        branchDeliveryTimes[0].Is_Disabled__c = true;
        update branchDeliveryTimes[0];
        Test.startTest();
        List <LeadTimeCalculatorController.DeliveryLeadTimes> leadTimes = LeadTimeCalculatorController.generateLeadTimes(JSON.serialize(question), branch[0].Id, System.today(), '', '', 'Lifestyle Series');
        system.assert(leadTimes.size() == 3);
        Test.stopTest();
    }
    
    @isTest
    static void testCreateCaseLines() {
        List <Category_Questions__c> question = [Select Id FROM Category_Questions__c WHERE Product_Category__c = 'Full Doors and Panels'];
        List <Branch__c> branch = [Select Id FROM Branch__c WHERE Name = 'Albany'];
        List <Branch_Delivery_Time__c> branchDeliveryTimes = [Select Id FROM Branch_Delivery_Time__c WHERE Branch__c = :branch[0].Id];
        List <Case> cases = [Select Id FROM Case WHERE Origin = 'Email'];
        branchDeliveryTimes[0].Is_Disabled__c = true;
        update branchDeliveryTimes[0];
        LeadTimeCalculatorController.DeliveryLeadTimes leadTimes = new LeadTimeCalculatorController.DeliveryLeadTimes();
        leadTimes.partReady = '1/9/2024';
        Case_Line__c caseLine = LeadTimeCalculatorController.createPartCaseLines(cases[0].Id, JSON.serialize(leadTimes), branch[0].Id, System.today());
        list <Case_Line__c> updatedCaseLine = [Select Case__c FROM Case_Line__c WHERE Id = :caseLine.Id];
        system.assert(updatedCaseLine[0].Case__c == cases[0].Id);
    }
    
    
    

}