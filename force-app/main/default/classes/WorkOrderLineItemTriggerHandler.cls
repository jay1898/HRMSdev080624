public class WorkOrderLineItemTriggerHandler {
  
/**
*   @Method:        updateServiceTerritory
*   @Purpose:       To update the service territory on WOLI based on the postal code
*   @Author:        Pallavi (eVerge)
*   @Date:          03/08/2022
*   @TaskSource:    

*   @Updates:       
*/     
    public static Boolean RUN_TRIGGER = true ;
    public static void updateServiceTerritory(List<WorkOrderLineItem> wolis, Map<Id,WorkOrderLineItem> oldMap){
        Set<String> setWOLIZipcode = new Set<String>();
        Set<String> setWOLISchType = new Set<String>();Set<String> setWOBranch = new Set<String>();
        Map<String, Id> mapSTId = new Map<String, Id>();
        List<WorkOrderLineItem> listUpdateWOLI = new List<WorkOrderLineItem>();
       
        try{
             system.debug('line 7');
                for(WorkOrderLineItem woli :wolis){
                //for new records
                if(oldMap == null && woli.PostalCode != null && woli.WorkTypeId != null){
                    //setWOLIZipcode.add(woli.PostalCode);
                    system.debug('Branch : ' + woli.WO_Branch_Id__c);
                    setWOBranch.add(woli.WO_Branch_Id__c);
                    if(woli.Country == 'US' && woli.PostalCode.length() > 5){
                        setWOLIZipcode.add(String.valueOf(woli.PostalCode).substring(0, 5)); 
                    }
                	else if((woli.Country == null  || woli.Country == 'US') && woli.PostalCode.length() <= 5){
                        setWOLIZipcode.add(woli.PostalCode);
                    }
                    if(woli.Country == 'CA' && woli.PostalCode != null ){
                        setWOLIZipcode.add(String.valueOf(woli.PostalCode).substring(0, 3)); 
                    }
                    /*else if((woli.Country == 'CA'|| woli.Country == null) && woli.PostalCode.length() == 3){
                        setWOLIZipcode.add(woli.PostalCode);
                    }*/
                    if((woli.Work_Type_s_Schedule_Type__c.contains('Install')) || (woli.Work_Type_s_Schedule_Type__c == 'Project') || (woli.Work_Type_s_Schedule_Type__c == 'Recovery')){
                    	setWOLISchType.add('Install');  
                	}
               	   else {setWOLISchType.add(woli.Work_Type_s_Schedule_Type__c); }
                   
                }
                 //for existing recods 
                 if(oldMap != null && (woli.PostalCode != oldMap.get(woli.Id).PostalCode || oldMap.get(woli.Id).WorkTypeId != woli.WorkTypeId)){
                   	//setWOLIZipcode.add(woli.PostalCode);
                   	system.debug('Branch : ' + woli.WO_Branch_Id__c);
                    setWOBranch.add(woli.WO_Branch_Id__c);
                    if(woli.Country == 'US' && woli.PostalCode.length() > 5){setWOLIZipcode.add(String.valueOf(woli.PostalCode).substring(0, 5)); }
                	else if((woli.Country == null ||woli.Country == 'US') && woli.PostalCode.length() <= 5){setWOLIZipcode.add(woli.PostalCode);} 
                    
                     if(woli.Country == 'CA' && woli.PostalCode != null){
                         setWOLIZipcode.add(String.valueOf(woli.PostalCode).substring(0, 3)); 
                     }
                     /*else if((woli.Country == 'CA'|| woli.Country == null) && woli.PostalCode.length() == 3){
                        setWOLIZipcode.add(woli.PostalCode);
                     }*/
                     
                     if((woli.Work_Type_s_Schedule_Type__c.contains('Install')) || (woli.Work_Type_s_Schedule_Type__c == 'Project')
                        || (woli.Work_Type_s_Schedule_Type__c == 'Recovery')){
                    	setWOLISchType.add('Install');  
                	}
                  
               	   else {setWOLISchType.add(woli.Work_Type_s_Schedule_Type__c); }
                     
                }
            }
            system.debug('setWOLISchType : ' + setWOLISchType);
            for(Territory_Zipcode__c tzipcode :[SELECT Id, Territory__c, Territory_Type__c, ZipCode__r.Name,Territory_Branch__c
                                                FROM Territory_Zipcode__c where ZipCode__r.Name IN :setWOLIZipcode AND 
                                                Territory_Type__c IN :setWOLISchType AND Territory_Branch__c IN :setWOBranch  ]){
                                                    
                                system.debug('Line 24 :' + ':::' + tzipcode.ZipCode__r.Name + ':::' + tzipcode.Territory_Type__c  );
                                                    //mapSTId.put(tzipcode.ZipCode__r.Name, tzipcode.Territory__c);
                               mapSTId.put((string.valueof(tzipcode.ZipCode__r.Name) + String.valueof(tzipcode.Territory_Type__c)), tzipcode.Territory__c);
            }
            system.debug('mapSTId : '+ mapSTId);
            
            for(WorkOrderLineItem wrkordln : wolis){
                String spostalcode = null;
                if(wrkordln.Country == 'US' && wrkordln.PostalCode.length() > 5){spostalcode = String.valueOf(wrkordln.PostalCode).substring(0, 5); }
                else if((wrkordln.Country == null ||wrkordln.Country == 'US') && wrkordln.PostalCode.length() <= 5){
                    spostalcode = wrkordln.PostalCode;
                }
                
                if( wrkordln.Country == 'CA' && wrkordln.PostalCode != null){
                    spostalcode = String.valueOf(wrkordln.PostalCode).substring(0, 3);
                    spostalcode = spostalcode.toUpperCase();
                }
               /* else if((wrkordln.Country == 'CA'|| wrkordln.Country == null) && wrkordln.PostalCode.length() == 3){
                        setWOLIZipcode.add(wrkordln.PostalCode);
                    }*/
                String stype = '';
				if((wrkordln.Work_Type_s_Schedule_Type__c.contains('Install')) || (wrkordln.Work_Type_s_Schedule_Type__c == 'Project') || (wrkordln.Work_Type_s_Schedule_Type__c == 'Recovery')){
					stype = 'Install';
			    }
				else {stype = wrkordln.Work_Type_s_Schedule_Type__c ;}
				system.debug(String.valueof(spostalcode) + stype );
                String sKey = String.valueof(spostalcode) + stype ;
                if(mapSTId.containskey(sKey)){
                    WorkOrderLineItem woli = new WorkOrderLineItem(Id=wrkordln.Id);
                    woli.ServiceTerritoryId = mapSTId.get(sKey);
                    listUpdateWOLI.add(woli);
            	}
               /* else {
                    WorkOrderLineItem woli = new WorkOrderLineItem(Id=wrkordln.Id);
                    woli.ServiceTerritoryId = null ;	
                    listUpdateWOLI.add(woli);
                }*/
               
        	}
       
            WorkOrderLineItemTriggerHandler.RUN_TRIGGER = FALSE;
        	if(listUpdateWOLI.size()>0){
                system.debug('WorkOrderLineItemTriggerHandler : '+ listUpdateWOLI);
                UPDATE listUpdateWOLI ;
        	}
        }
        catch(exception e){
             system.debug(e.getMessage());
        }
        
    }
    /**
*   @Method:        pdfgenerator
*   @Purpose:       To generate the PDF file with Data from Quote Line items child line items
*   @Author:        Pallavi (eVerge)
*   @Date:          03/05/2022
*   @TaskSource:    

*   @Updates:       
*/   
    public static void pdfgenerator(List<WorkOrderLineItem> wolis, Map<Id,WorkOrderLineItem> oldMap){
        List<String> listWOLIIds=new List<String>();
        Map<String,WorkOrderLineItem> mapWOLIWiseStatus=new Map<String,WorkOrderLineItem>();
        for(WorkOrderLineItem woli : wolis){
           if(oldMap != null &&  woli.Generate_POMS_File__c != oldMap.get(woli.Id).Generate_POMS_File__c && woli.Generate_POMS_File__c == TRUE){
               POMSPDFGenerator.PDFGenerator(woli.Id);
            }
            if((oldMap != null && (WOLI.Status__c =='Approved' || WOLI.Status__c =='Rejected' )) && WOLI.Status__c!=oldMap.get(woli.Id).Status__c){
                listWOLIIds.add(woli.Id);
            }
            if((oldMap != null && (WOLI.Status__c =='Approved' || WOLI.Status__c =='Rejected' ||  WOLI.Status__c =='Pending Approval' )) && WOLI.Status__c!=oldMap.get(woli.Id).Status__c){
                mapWOLIWiseStatus.put(woli.Id,WOLI);
            }
        }
        if(listWOLIIds.size()>0){
            POMSInstallerPDFGenerator.PDFGenerator(listWOLIIds,network.getNetworkId());
        }
        if(mapWOLIWiseStatus.keySet().size()>0){
            // Update Service Appointments
            String WOLIStatus='';
            List<ServiceAppointment> listSA=[SELECT Id,parentRecordId,status From ServiceAppointment where parentRecordId = :mapWOLIWiseStatus.keySet() ];
            Map<String,Map<String,String>> mapWOLIWiseRPRecords=new Map<String,Map<String,String>>();
            for(ResourcePreference RP : [SELECT Id,PreferenceType,ServiceResourceId,RelatedRecordId From ResourcePreference where RelatedRecordId = :mapWOLIWiseStatus.keySet() ]){
                if(!mapWOLIWiseRPRecords.containsKey(RP.RelatedRecordId)){
                    mapWOLIWiseRPRecords.put(RP.RelatedRecordId,new Map<String,String>());
                }
                mapWOLIWiseRPRecords.get(RP.RelatedRecordId).put(RP.ServiceResourceId,RP.Id);
            }
            
            List<ServiceAppointment> listSAToUpdate=new List<ServiceAppointment>();
            Map<String,ResourcePreference> mapRPToUpdate=new Map<String,ResourcePreference>();
            for(ServiceAppointment SA : listSA){
                if(mapWOLIWiseStatus.containsKey(SA.parentRecordId)){
                    WOLIStatus=mapWOLIWiseStatus.get(SA.parentRecordId).Status__c;
                    if(WOLIStatus=='Approved' &&  SA.status!='Accepted'){
                        SA.status='Accepted';
                        listSAToUpdate.add(SA);
                        ResourcePreference RP=new ResourcePreference();
                        RP.ServiceResourceId=mapWOLIWiseStatus.get(SA.parentRecordId).Primary_Installer__c;
                        if(mapWOLIWiseRPRecords.containsKey(SA.parentRecordId)){
                            RP.Id=mapWOLIWiseRPRecords.get(SA.parentRecordId).get(RP.ServiceResourceId);
                        }else{
                            RP.RelatedRecordId=SA.parentRecordId;
                        }
                        RP.PreferenceType='Required';
                        mapRPToUpdate.put(RP.RelatedRecordId+'_'+RP.ServiceResourceId,RP);
                    }
                    else if(WOLIStatus=='Rejected' && SA.status!='Declined'){
                        SA.status='Declined';
                        listSAToUpdate.add(SA);
                        ResourcePreference RP=new ResourcePreference();
                        RP.ServiceResourceId=mapWOLIWiseStatus.get(SA.parentRecordId).Primary_Installer__c;
                        if(mapWOLIWiseRPRecords.containsKey(SA.parentRecordId)){
                            RP.Id=mapWOLIWiseRPRecords.get(SA.parentRecordId).get(RP.ServiceResourceId);
                        }
                        RP.PreferenceType='Excluded';
                        mapRPToUpdate.put(SA.parentRecordId+'_'+RP.ServiceResourceId,RP);
                    }
                    else if(WOLIStatus=='Pending Approval' && SA.status!='Requested'){
                        SA.status='Requested';
                        listSAToUpdate.add(SA);
                    }
                }
            }
            if(listSAToUpdate.size()>0 && !Test.isRunningTest()) update listSAToUpdate;
            if(mapRPToUpdate.size()>0 ) upsert mapRPToUpdate.values();
        }
    }


}