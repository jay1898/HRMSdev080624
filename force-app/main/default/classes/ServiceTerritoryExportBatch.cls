//Test class : ServiceGETRTATest
public class ServiceTerritoryExportBatch  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{
    
    String csvData = '';
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        // csvData='Column 1, Zip Code, Branch Number, Zone Type \n';
        csvData='';
        DateTime currentTime=DateTime.now();
        String query='SELECT Id, Name, RecordType.Name, PostalCode, ParentTerritory.ParentTerritory.Branch__r.Branch_Number__c,ParentTerritory.ParentTerritory.Branch__r.T_C_Branch_Number__c  , ParentTerritory.RecordType.Name FROM ServiceTerritory  where RecordType.Name = \'Zipcode\' and PostalCode != \'\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<ServiceTerritory> records){
        try{
            string finalstr='';
            string tcbranch='';
            for(ServiceTerritory ST: records){
                if(ST.ParentTerritory.ParentTerritory.Branch__r.T_C_Branch_Number__c!=null && String.isNotBlank(ST.ParentTerritory.ParentTerritory.Branch__r.T_C_Branch_Number__c) && ST.ParentTerritory.ParentTerritory.Branch__r.T_C_Branch_Number__c == '105')
                    tcbranch = '096';
                else
                    tcbranch =  ST.ParentTerritory.ParentTerritory.Branch__r.T_C_Branch_Number__c;
                // finalstr += '"'+'3205'+'","'+ST.PostalCode+'","'+ST.ParentTerritory.ParentTerritory.Branch__r.Branch_Number__c+'","'+(ST.ParentTerritory.RecordType.Name == 'RT Zone' ?'RT':'NRT') +'"\n';
                if(ST.ParentTerritory.RecordType.Name == 'NRT Zone')
                    finalstr += '3205'+','+ST.PostalCode+','+ST.ParentTerritory.ParentTerritory.Branch__r.Branch_Number__c+',NRT\n';
                else
                    finalstr += '3205'+','+ST.PostalCode+','+ST.ParentTerritory.ParentTerritory.Branch__r.Branch_Number__c+',RT\n';
                if(ST.ParentTerritory.ParentTerritory.Branch__r.T_C_Branch_Number__c!=null && String.isNotBlank(ST.ParentTerritory.ParentTerritory.Branch__r.T_C_Branch_Number__c)){
                    finalstr += '3213'+','+ST.PostalCode+','+tcbranch +',NRT\n';
                    finalstr += '3463'+','+ST.PostalCode+','+tcbranch+',NRT\n';
                }   
            }
            csvData+=finalstr;
        }
        catch(Exception ex){ new ApexDebugLog().createLog( new ApexDebugLog.Error( 'ServiceTerritoryExportBatch', 'execute', JSON.serialize(records), ex, 'Internal') );}
    }
    
    public void finish(Database.BatchableContext BC){
        try{
            List<Endpoint_Configuration__mdt> ebsMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'ServiceTerritory_To_EBS' ]; 
            
            system.debug('@@csvData :: '+csvData);
            String fileName='territory_zip.csv';
            HTTPResponse response=ServiceTerritoryExportBatchHandler.uploadFile(csvData,fileName,'territory_zip');
            
            // Information Log
            new ApexDebugLog().createLog(
                new ApexDebugLog.Information(
                    'ServiceTerritoryExportBatch',
                    'finish',
                    'URL : '+ebsMetaData[0].Endpoint__c+' \n'
                    +'Method : POST,\n'
                    +'fileName : '+fileName+',\n'
                    + 'Req Body : '+csvData,
                    'ServiceTerritoryExportBatchHandler Request',
                    'Integration'
                )
            );
            // Information Log
            new ApexDebugLog().createLog(
                new ApexDebugLog.Information(
                    'ServiceTerritoryExportBatch',
                    'finish',
                    'URL : '+ebsMetaData[0].Endpoint__c+' \n'
                    +'Method : POST,\n'
                    +'Response Body : ' + response.getBody(),
                    'The status code : ' + response.getStatusCode() + ' ' + response.getStatus(), 
                    'Integration'
                )
            );
        }
        catch(Exception ex){ 
            System.debug('@@ex : '+ex.getStackTraceString());
            System.debug('@@ex : '+ex.getMessage());
            new ApexDebugLog().createLog( new ApexDebugLog.Error( 'ServiceTerritoryExportBatch', 'execute', (csvData), ex, 'Internal') );}
        
    }
    public void execute(SchedulableContext sc) {
        ServiceTerritoryExportBatch b = new ServiceTerritoryExportBatch(); 
        database.executebatch(b,200);
    }
}