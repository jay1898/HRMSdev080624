public class BranchDataExportBatch  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{
    string oppData = '';
    string leadData = '';
    string appointmentData = '';
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id FROM ServiceTerritory where name in ( '766 - Pittsburge Retail WME' , '764 - Philadelphia Retail WME', '759 - Cleveland Retail WME', '750 - Columbus Retail WME', '791 - Harrisburg WME' ) 
                                          ]);
    }
    
    public void execute(Database.BatchableContext BC, List<ServiceTerritory>scope){
        Dom.Document docOpp = new Dom.Document(); 
        Dom.Xmlnode rootNodeOpp = docOpp.createRootElement('DATA_DS', null, null); 
        system.debug('Execute');
        for(Opportunity opp : [SELECT  Id,Owner.name, Name,Account.name, Status__c,Createddate,CloseDate,Close_Comments__c,StageName, Response_Channel__c,
                               Campaign.Name ,Total_Price_Quote__C, Quote_Date__c, Zone__r.Name,Zone__r.ParentTerritory.Name,Appointment_dateTime__C 
                               FROM Opportunity where Zone__r.ParentTerritory.Id in :scope
                               and createddate = LAST_N_DAYS:60 ]){
                                   Dom.Xmlnode headerOppNode = rootNodeOpp.addChildElement('DETAIL', null, null); 
                                   headerOppNode.addChildElement('GROUP_NAME', null, null).addTextNode(opp.Zone__r.ParentTerritory.Name == null ? '' : opp.Zone__r.ParentTerritory.Name);
                                   headerOppNode.addChildElement('RT_GROUP', null, null).addTextNode(Opp.Zone__r.Name == null ? '' : Opp.Zone__r.Name);
                                  headerOppNode.addChildElement('REP_NAME', null, null).addTextNode(opp.Owner.name == null ? '' : opp.Owner.name);
                                 headerOppNode.addChildElement('OPP_ID', null, null).addTextNode(Opp.Id == null ? '' : Opp.Id);
                                  headerOppNode.addChildElement('OPP_NAME', null, null).addTextNode(opp.Name == null ? '' : opp.Name);
                                   headerOppNode.addChildElement('CUSTOMER_NAME', null, null).addTextNode(Opp.Account.name == null ? '' : Opp.Account.name);
                                   headerOppNode.addChildElement('STATUS', null, null).addTextNode(Opp.Status__c == null ? '' : Opp.Status__c);
                                   headerOppNode.addChildElement('CREATION_DATE', null, null).addTextNode(Opp.Createddate == null ? '' : string.valueOfGmt(Opp.Createddate));
                                   headerOppNode.addChildElement('CLOSED_DATE', null, null).addTextNode(opp.CloseDate == null ? '' : string.valueOfGmt(opp.CloseDate));
                                  headerOppNode.addChildElement('VEHICLE_RESPONSE_CODE', null, null).addTextNode(Opp.Response_Channel__c == null ? '' : Opp.Response_Channel__c);
                                  headerOppNode.addChildElement('CLOSE_REASON', null, null).addTextNode(opp.Close_Comments__c == null ? '' : opp.Close_Comments__c);
                                  headerOppNode.addChildElement('SALES_STAGE', null, null).addTextNode(Opp.StageName == null ? '' : Opp.StageName);
                                   //headerOppNode.addChildElement('LEAD_SOURCE', null, null).addTextNode(opp.Response_Channel__c == null ? '' : opp.Response_Channel__c);
                                   //headerOppNode.addChildElement('CAMPAIGN_NAME', null, null).addTextNode(Opp.Campaign.Name == null ? '' : Opp.Campaign.Name);
                                   //headerOppNode.addChildElement('TOTAL_AMOUNT', null, null).addTextNode(opp.Total_Price_Quote__C == null ? '' : String.valueOf(opp.Total_Price_Quote__C));
                                   //headerOppNode.addChildElement('QUOTE_DATE', null, null).addTextNode(Opp.Quote_Date__c == null ? '' : string.valueOfGmt(Opp.Quote_Date__c));
                                   //headerOppNode.addChildElement('APPT_DATE', null, null).addTextNode(Opp.Appointment_dateTime__C == null ? '' : string.valueOfGmt(Opp.Appointment_dateTime__C));
                               }   
        oppData = docOpp.toXmlString();
    } 
    public void finish(Database.BatchableContext BC){

        // Zippex zip = new Zippex();
        //zip.addFile('Gunton_Opportunities.xml', Blob.valueOf(oppData), null);
        //zip.addFile('Gunton_Leads.xml', Blob.valueOf(leadData), null);
        //zip.addFile('Gunton_Appointments.xml', Blob.valueOf(appointmentData), null);
        //Blob zipBlob = zip.getZipArchive();
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        String zipName = 'Gunton' + Date.today() + '.xml'; 
        List<Endpoint_Configuration__mdt> ebsMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'ServiceTerritory_To_EBS' ];    
       // HTTPResponse response=ServiceTerritoryExportBatchHandler.uploadFile(oppData,zipName);
        //attachment.setFileName(zipName);
        // attachment.setBody(zipBlob);
        // Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        // message.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
        // message.setSubject('Gunton Files');
        // message.setPlainTextBody('The report is attached.');
        // message.setToAddresses( new String[] { 'adhamk@pella.com' } );
        //Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
        
    }
    public void execute(SchedulableContext sc) {
        BranchDataExportBatch b = new BranchDataExportBatch(); 
        database.executebatch(b,200);
    }
}