public without sharing class PIESWorkOrderFileShareforExistingRecords implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts {
	public set<Id> allSuccessId=new set<Id>(); 
    public Database.QueryLocator start(Database.BatchableContext BC){
          system.debug([SELECT ID FROM WorkOrder where recordtype.Name = 'OV/Install' ].size());
          return Database.getQueryLocator([SELECT ID FROM WorkOrder where recordtype.Name = 'OV/Install' ]);
     }
    public void execute(Database.BatchableContext BC, List<WorkOrder> listWO){
       Set<Id> setWOId = new Set<Id>(); List<ContentDocumentLink>  listCDL = new List<ContentDocumentLink>(); 
        for(WorkOrder w : listWO){
            setWOId.add(w.Id); 
        } 
        system.debug('setWOId :' +setWOId.size());
        //Find the cdl for the above WO's where share Type is Viewer and update it to I(Set by record)
        for(ContentDocumentLink cdl : [SELECT Id, ShareType, linkedentityid FROM ContentDocumentLink 
                               WHERE linkedentityid IN :setWOId AND ShareType = 'V' ]){
                                   system.debug('cdl');
                                    ContentDocumentLink cdlink = new ContentDocumentLink(Id=cdl.Id);
    							    cdlink.ShareType = 'I' ;
    								listCDL.add(cdlink);
		}
        system.debug('listCDL :' + listCDL);
        if(listCDL.size() >0){
			system.debug('listCDL size :' + listCDL.size());
     		Database.SaveResult[] srList = Database.update(listCDL, false);
            for (Database.SaveResult sr : srList) {
            	if (sr.isSuccess()) {
                	// Operation was successful, so get the ID of the record that was processed
                	System.debug('Successfully updated : ' + sr.getId());
                	allSuccessId.add(sr.getId());
            	}
            	else {
                	// Operation failed, so get all errors                
                	for(Database.Error err : sr.getErrors()) {
                    	System.debug('The following error has occurred.');                    
                    	System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    	System.debug('WO that errored: ' + err.getFields());
                	}
            	}
        	}
		}
    }
    public void finish(Database.BatchableContext BC){}
    public void execute(SchedulableContext sc) {
        PIESWorkOrderFileShareforExistingRecords b = new PIESWorkOrderFileShareforExistingRecords(); 
        database.executebatch(b,100);
    }
}