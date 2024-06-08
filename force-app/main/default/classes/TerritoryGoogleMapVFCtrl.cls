/**
* @description       : TerritoryGoogleMapVFCtrl to manage territory google map view
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* @group             : eVerge
* History 	
* Ver   Date         Author        Modification
* 1.0   08-03-2022    Dhruv Javiya  Initial Version()
**/
global class TerritoryGoogleMapVFCtrl { 
    
    @RemoteAction  
    global static List<String> findZipcodes(decimal lngmax, decimal lngmin, decimal latmax, decimal latmin) {
        List<String> listZipcode=new List<String>();
        for(zipcode__c zipcode : [select External_Id__c  from zipcode__c where long__c >= :lngmin and long__c <= :lngmax and lat__c >= :latmin and lat__c <= :latmax]){
            listZipcode.add(zipcode.External_Id__c);
            
        }
        
        return listZipcode;
    }
    
    @RemoteAction
    global static string loaddata(string branchId){
        Map<String,String> returnData=new Map<String,String>();
        Map<String,List<String>> TerritoryWiseZipCodeList=new Map<String,List<String>>();
        Map<String,String> ZipCodeWiseCoOrdinates=new Map<String,String>();
        Map<String,String> TerritoryWiseDetail=new Map<String,String>();
        // retrive  territory Zipcode based on related branch and record type OV_Install_Territory
        for(Territory_Zipcode__c TZ :[SELECT Id,Name,Territory__c,Territory__r.Name ,ZipCode__r.Name,ZipCode__r.ZipCode_Co_Ordinates__c,ZipCode__c FROM Territory_Zipcode__c   
                                      Where Territory__r.Branch__c= :branchId 
                                      and Territory__r.RecordType.DeveloperName='OV_Install_Territory'
                                      and ZipCode__r.Name!=null and Territory__c!=null
                                      order by Name asc]){
                                          if(!TerritoryWiseZipCodeList.containsKey(TZ.Territory__c))  {
                                              TerritoryWiseZipCodeList.put(TZ.Territory__c,new List<String>());
                                          }       
                                          TerritoryWiseZipCodeList.get(TZ.Territory__c).add(TZ.ZipCode__r.Name);
                                          ZipCodeWiseCoOrdinates.put(TZ.ZipCode__r.Name,TZ.ZipCode__r.ZipCode_Co_Ordinates__c);
                                          TerritoryWiseDetail.put(TZ.Territory__c,TZ.Territory__r.Name);
                                      }
        Map<String,List<ServiceTerritoryMember>> TerritoryWiseResource=new Map<String,List<ServiceTerritoryMember>>();
        // retrive  Service Territory Member based on related Service Territory branch and record type OV_Install_Territory
        for(ServiceTerritoryMember STM :[SELECT Id,ServiceTerritory.Name,ServiceResource.Name,ServiceResource.Resource_Group__c, ServiceResource.Resource_Type__c  FROM ServiceTerritoryMember   
                                         Where ServiceTerritory.Branch__c= :branchId
                                         and ServiceTerritory.RecordType.DeveloperName='OV_Install_Territory']){
                                             if(!TerritoryWiseResource.containsKey(STM.ServiceTerritoryId))  {
                                                 TerritoryWiseResource.put(STM.ServiceTerritoryId,new List<ServiceTerritoryMember>());
                                             }       
                                             TerritoryWiseResource.get(STM.ServiceTerritoryId).add(STM);                       
                                         }
         returnData.put('ZipCodeWiseCoOrdinates',JSON.serialize(ZipCodeWiseCoOrdinates));
         returnData.put('TerritoryWiseZipCodeList',JSON.serialize(TerritoryWiseZipCodeList));
         returnData.put('TerritoryWiseResource',JSON.serialize(TerritoryWiseResource));
         returnData.put('TerritoryWiseDetail',JSON.serialize(TerritoryWiseDetail));
        
         return JSON.serialize(returnData);
        
    }
     
    
    @AuraEnabled
    public static string CreateTerritory(String recordData,String zipcodeData){
        ServiceTerritory ST=(ServiceTerritory)JSON.deserialize(recordData, ServiceTerritory.class);
        ST.recordTypeId=Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByDeveloperName().get('OV_Install_Territory').getRecordTypeId();
        Insert ST;
        List<String> listZipcode=(List<String>)JSON.deserialize(zipcodeData, List<String>.class);
        system.debug('@@'+listZipcode);
        List<Territory_Zipcode__c> listTZtoInsert=new List<Territory_Zipcode__c>();
        List<String> LogDataList=new List<String>();
        for(ServiceTerritory zipcodeST :[SELECT ID FROM ServiceTerritory Where RecordType.DeveloperName='Zone_Zipcode' and Name in :listZipcode]){
            Territory_Zipcode__c TZ=new Territory_Zipcode__c();
            TZ.Territory__c=ST.Id;
            TZ.ZipCode__c=zipcodeST.Id;
            LogDataList.addall(listZipcode);
            listTZtoInsert.add(TZ);
        }
		Database.SaveResult[] lsr=database.insert(listTZtoInsert,false); 
        String error;
        Integer successCnt=0;
        for(Database.SaveResult SR : lsr){
            if (sr.isSuccess()) {
                successCnt++;
            }
            else if(error==null){
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    error= err.getMessage();
                }
            }
        }
        if(successCnt>0){
            String recordId =new ApexDebugLog().createLog(new ApexDebugLog.Information('TerritoryGoogleMapVFCtrl','CreateTerritory','recordData: '+recordData+', Zipcodes : '+zipcodeData,'create','Map'));

        }
        if(successCnt==0 && error!=null){
            String recordErrorId = new ApexDebugLog().createLog(new ApexDebugLog.Error('TerritoryGoogleMapVFCtrl','CreateTerritory','recordData : '+recordData+', Zipcodes : '+zipcodeData,'create', error,'Map'));

            throw new AuraHandledException(error);
        }
          
		return ST.Id;      
    }
    
    @RemoteAction
    global static string relatedTerritoryWithZipcode(String territoryId,String zipcodeData){
        system.debug('@@ territoryId:'+territoryId);
        List<String> listZipcode=(List<String>)JSON.deserialize(zipcodeData, List<String>.class);
        system.debug('@@ listZipcode: '+listZipcode);
        List<Territory_Zipcode__c> listTZtoInsert=new List<Territory_Zipcode__c>();
        List<String> listSTtoExclude=new List<String>();
         List<String> LogDataList=new List<String>();
        for( Territory_Zipcode__c listExisting :[SELECT Id,ZipCode__c FROM Territory_Zipcode__c where Territory__c=:territoryId and ZipCode__r.Name in :listZipcode ]){
            listSTtoExclude.add(listExisting.ZipCode__c);        
        }
        system.debug('@@ listSTtoExclude: '+listSTtoExclude);
        for(ServiceTerritory zipcodeST :[SELECT ID,name FROM ServiceTerritory Where RecordType.DeveloperName='Zone_Zipcode' and Name in :listZipcode and Id NOT in :listSTtoExclude ]){
            Territory_Zipcode__c TZ=new Territory_Zipcode__c();
            TZ.Territory__c=territoryId;
            TZ.ZipCode__c=zipcodeST.Id;
           	LogDataList.addall(listZipcode);
            listTZtoInsert.add(TZ);
        }
        System.Debug('listTZtoInsert@@@@'+listTZtoInsert);
        System.Debug('LogDataList@@@@'+LogDataList);
		Database.SaveResult[] lsr=database.insert(listTZtoInsert,false);
        String error;
        Integer successCnt=0;
        for(Database.SaveResult SR : lsr){
            if (sr.isSuccess()) {
                successCnt++;
            }
            else if(error==null){
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    error= err.getMessage();
                }
            }
        }
        if(successCnt>0){
            String recordId =new ApexDebugLog().createLog(new ApexDebugLog.Information('TerritoryGoogleMapVFCtrl','relatedTerritoryWithZipcode','Territory Id : '+territoryId+', Zipcodes : '+zipcodeData,'create','Map'));
        }
        if(successCnt==0){
            return 'No Zipcode Found in system, please contact admin for more information';
        }
        if(error!=null){
            String recordErrorId = new ApexDebugLog().createLog(new ApexDebugLog.Error('TerritoryGoogleMapVFCtrl','relatedTerritoryWithZipcode','Territory Id : '+territoryId+', Zipcodes : '+zipcodeData,'create', error,'Map'));
            return error;
        }
		return '';      
    }
    @RemoteAction
    global static string deleterelatedTerritoryWithZipcode(String territoryId,String zipcodeData){
        List<String> listZipcode=(List<String>)JSON.deserialize(zipcodeData, List<String>.class);
        List<Territory_Zipcode__c> listTZtodelete=[select id,Zip_Code_Name__c from Territory_Zipcode__c where Territory__c=:territoryId and ZipCode__r.Name in : listZipcode];
       
        Database.DeleteResult[] lsr=database.delete(listTZtodelete,false);
        String error;
        Integer successCnt=0;
        for(Database.DeleteResult SR : lsr){
            if (sr.isSuccess()) {
                successCnt++;
            }
            else if(error==null){
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    error= err.getMessage();
                }
            }
        }
        if(successCnt>0){
            String recordId =new ApexDebugLog().createLog(new ApexDebugLog.Information('TerritoryGoogleMapVFCtrl','deleterelatedTerritoryWithZipcode','Territory Id : '+territoryId+', Zipcodes : '+zipcodeData,'delete','Map'));
        }
        if(successCnt==0){
            return 'No Zipcode Found in system, please contact admin for more information';
        }
        if(error!=null){
            String recordErrorId = new ApexDebugLog().createLog(new ApexDebugLog.Error('TerritoryGoogleMapVFCtrl','deleterelatedTerritoryWithZipcode','Territory Id : '+territoryId+', Zipcodes : '+zipcodeData,'delete', error,'Map'));
            return error;
        }
		return '';      
    }
}