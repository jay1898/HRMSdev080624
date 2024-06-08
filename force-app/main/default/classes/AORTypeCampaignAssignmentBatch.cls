//Test class : ServiceGETRTATest
public class AORTypeCampaignAssignmentBatch  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(System.Label.AORTypeCampaignQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<Campaign> listCampaign){
        CampaignRecordShare.shareCampaignRecordWithSTM(listCampaign);
    }
    
    public void finish(Database.BatchableContext BC){
          
    }
    public void execute(SchedulableContext sc) {
        AORTypeCampaignAssignmentBatch b = new AORTypeCampaignAssignmentBatch(); 
        database.executebatch(b,1);
    }
}