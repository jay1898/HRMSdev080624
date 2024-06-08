@isTest
public class CaseQuickTextTest {

     @TestSetup
    static void makeData(){

        Group grp                       = new Group();
        grp.name                        = 'Test Queue';
        grp.Type                        = 'queue'; 
        Insert grp; 
        
        Group grptwo                       = new Group();
        grptwo.name                        = 'Test Queue second';
        grptwo.Type                        = 'queue'; 
        Insert grptwo; 
    }
    
     @isTest
    static void testquickQueueCheck() {
        Case_Quick_Text__c casequickTest = new Case_Quick_Text__c();
        casequickTest.Name = 'test';
        casequickTest.Queue_Name__c = 'Test Queue';
        insert casequickTest;
        casequickTest.Queue_Name__c = 'Test Queue second';
        update casequickTest;
    }
}