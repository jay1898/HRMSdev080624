@isTest
public class LeadStatusToEBSTest {
    static testMethod void testMethod1() {
        Lead l = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 
        
        LeadStatusToEBS.Request lr = new LeadStatusToEBS.Request();
        lr.recordId = l.Id;
        
        List<LeadStatusToEBS.Request> lrList = new List<LeadStatusToEBS.Request>();
        lrList.add(lr);
        	
        LeadStatusToEBS.SendLeadStatusToEBS(lrList);
    }
}