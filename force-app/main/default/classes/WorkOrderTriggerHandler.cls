public class WorkOrderTriggerHandler {
    
 /**
*   @Method:        wordorderRecordShare
*   @Purpose:       To share the WO with sales rep owned by PIES reosurce
*   @Author:        Pallavi (eVerge)
*   @Date:          03/05/2022
*   @TaskSource:    

*   @Updates:       
*/    
    Public static Boolean RUN_TRIGGER = TRUE ;
    public static void wordorderRecordShare(List<WorkOrder> wos, Map<Id,WorkOrder> oldMap){
        Id serviceRTId                      = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get(Constant.WO_CS_RT).getRecordTypeId();
        List<Id> woIdstoShare               = new List<Id>();
        Map<Id, Id> serviceWOAndCaseMap     = new Map<Id, Id>();

        for(WorkOrder wo: wos){
            if(oldMap == null){
                if(wo.RecordTypeId == serviceRTId) {
                    if(wo.CaseId != null) serviceWOAndCaseMap.put(wo.Id, wo.CaseId);
                }else {
                    woIdstoShare.add(wo.Id);
                }                
            }
            else if(wo.RecordTypeId == serviceRTId) {

            }
            else if(oldMap != null && 
                    ((wo.ownerid != oldmap.get(wo.id).ownerid) || (wo.ServiceTerritoryId != oldmap.get(wo.id).ServiceTerritoryId))){
				woIdstoShare.add(wo.id);
//                System.debug(woIdstoShare);
			}
           
        }
        if(woIdstoShare.size() >0){
           WorkOrderRecordShare.shareWOwihtQuoteOwner(woIdstoShare); 
        }
        if(!serviceWOAndCaseMap.isEmpty()) {
            try{
                SharingUtility.createSharingRecords_v2(serviceWOAndCaseMap, 'WorkOrderShare');
            }catch(Exception e){
                System.debug(e.getStackTraceString() + ' :::: '+ e.getLineNumber() + '  ::::: '+ e.getMessage());
            }            
        }
    }
    
    
 /**
*   @Method:        pdfgenerator
*   @Purpose:       To generate the PDF file with Data from Quote Line items child line items
*   @Author:        Pallavi (eVerge)
*   @Date:          03/05/2022
*   @TaskSource:    

*   @Updates:  code is moved to WOLI     
*/   
 /*   public static void pdfgenerator(List<WorkOrder> wos, Map<Id,WorkOrder> oldMap){
        
        for(WorkOrder wo : wos){
           if(oldMap != null &&  wo.Generate_POMS_File__c != oldMap.get(wo.Id).Generate_POMS_File__c && wo.Generate_POMS_File__c == TRUE){
               POMSPDFGenerator.PDFGenerator(wo.Id);
            }
        }
    }*/
 
/**
*   @Method:        updateServiceTerritory
*   @Purpose:       Update the Serivce Territory on New WO for PIES
*   @Author:        Pallavi (eVerge)
*   @Date:          03/05/2022
*   @TaskSource:    

*   @Updates:       
*/ 
    
    public static void updateServiceTerritory(List<WorkOrder> wos, Map<Id,WorkOrder> oldMap){
       
        Id piesRT = Schema.SObjectType.WorkOrder.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
        Set<String> setWOZipcode = new Set<String>();
        Set<String> setWOBranch = new Set<String>();
        Map<String, Id> mapSTId = new Map<String, Id>();
        Set<String> setWOSchType = new Set<String>();
        List<WorkOrder> listUpdateWO = new List<WorkOrder>();
      
        try{
            for(WorkOrder wo : wos){
                //For new records
                if(oldMap == null && wo.RecordTypeId == piesRT && wo.Branch__c != null && wo.WorkTypeId != null && wo.PostalCode != null){
                //setWOBranch.add(String.valueOf(wo.Branch__c).substring(0, 15));
                setWOBranch.add(wo.Branch__c);
                if(wo.Country == 'US' && wo.PostalCode.length() > 5){
                    setWOZipcode.add(String.valueOf(wo.PostalCode).substring(0, 5)); 
                }
                else if((wo.Country == null || wo.Country == 'US') && (wo.PostalCode.length() <= 5)){
                    setWOZipcode.add(wo.PostalCode);
                }
                
                if(wo.country == 'CA' && wo.PostalCode != null ){
                    setWOZipcode.add(String.valueOf(wo.PostalCode).substring(0, 3));
                } 
             
                if((wo.Work_Type_s_Schedule_Type__c.contains('Install')) || (wo.Work_Type_s_Schedule_Type__c == 'Project') || 
                   (wo.Work_Type_s_Schedule_Type__c == 'Recovery') ){
                    setWOSchType.add('Install');  
                }
              
                else {setWOSchType.add(wo.Work_Type_s_Schedule_Type__c); } 
      //          system.debug('setWOBranch:' + setWOBranch);
      //          system.debug('setWOZipcode:' + setWOZipcode);
            }
            //for existing records    
            if(oldMap != null && wo.RecordTypeId == piesRT && (wo.Branch__c !=oldMap.get(wo.Id).Branch__c  || wo.WorkTypeId != oldMap.get(wo.Id).WorkTypeId || wo.PostalCode != oldMap.get(wo.Id).PostalCode)){
                //setWOBranch.add(String.valueOf(wo.Branch__c).substring(0, 15));
                setWOBranch.add(wo.Branch__c);
                if(wo.Country == 'US' && wo.PostalCode.length() > 5){
                    setWOZipcode.add(String.valueOf(wo.PostalCode).substring(0, 5)); 
                }
                else if(wo.Country == null ||(wo.Country == 'US' && wo.PostalCode.length() <= 5)){
                    setWOZipcode.add(wo.PostalCode);
                }
                
                if(wo.country == 'CA' && wo.PostalCode != null ){
                    setWOZipcode.add(String.valueOf(wo.PostalCode).substring(0, 3));
                }
               
                if((wo.Work_Type_s_Schedule_Type__c.contains('Install')) || (wo.Work_Type_s_Schedule_Type__c == 'Project') 
                   || (wo.Work_Type_s_Schedule_Type__c == 'Recovery') ){
                    setWOSchType.add('Install');  
                }
                else {setWOSchType.add(wo.Work_Type_s_Schedule_Type__c); }
        //        system.debug('setWOBranch:' + setWOBranch);
        //        system.debug('setWOZipcode:' + setWOZipcode);
        //        system.debug('setWOSchType : ' + setWOSchType);
            }
        }
        //check if Territory exists for entered zip code, banch and Type.    
        for(Territory_Zipcode__c tzipcode :[SELECT Id, Territory__c, Territory_Type__c, ZipCode__r.Name,Territory_Branch__c
                                            FROM Territory_Zipcode__c where ZipCode__r.Name IN :setWOZipcode
                                            AND Territory_Branch__c IN :setWOBranch AND Territory_Type__c IN :setWOSchType]){
                                               
                                                mapSTId.put(tzipcode.ZipCode__r.Name, tzipcode.Territory__c);
        }
    //    system.debug('mapSTId:' + mapSTId);
        String sPostalcode ;   
        if(!mapSTId.isEmpty()){
            for(WorkOrder wrkord : wos){
				if(wrkord.PostalCode != null){
					if(wrkord.Country == 'US' && wrkord.PostalCode.length() > 5){
                    sPostalcode = String.valueOf(wrkord.PostalCode).substring(0, 5); 
    //                system.debug('sPostalcode :' + sPostalcode);
					}
					else if((wrkord.Country == null || wrkord.Country == 'US') && wrkord.PostalCode.length() <= 5 ){ 
                    sPostalcode = wrkord.PostalCode;
    //                system.debug('sPostalcode :' + sPostalcode);
					}
					if(wrkord.Country == 'CA' && wrkord.PostalCode != null){
                	sPostalcode = String.valueOf(wrkord.PostalCode).substring(0, 3);
                	sPostalcode = sPostalcode.toUpperCase();
    //                system.debug('sPostalcode :' + sPostalcode);
					}
	//				system.debug('sPostalcode :' + sPostalcode);
					if(mapSTId.containskey(sPostalcode)){
    //                system.debug('sPostalcode :' + mapSTId.get(sPostalcode));
               		WorkOrder wo = new WorkOrder(Id=wrkord.Id);
                	wo.ServiceTerritoryId = mapSTId.get(sPostalcode);
                	listUpdateWO.add(wo);
					} 
				}
    //            system.debug('sPostalcode :' + sPostalcode);
             	
        	}
      	}    
    //    system.debug('listUpdateWO :' + listUpdateWO);
        WorkOrderTriggerHandler.RUN_TRIGGER = FALSE;
        
        if(listUpdateWO.size()>0){
    //        system.debug(listUpdateWO);
            UPDATE listUpdateWO ;
        }
       }
        catch(exception e){
            system.debug(e.getMessage());
        }
        
    }

}