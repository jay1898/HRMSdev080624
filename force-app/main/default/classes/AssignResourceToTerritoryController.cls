/**
 * @description       : AssignResourceToTerritoryController to manage territory resource assigment
 * @author            : Dhruv Javiya | javiyad@evergegroup.com
 * @group             : eVerge
 * History 	
 * Ver   Date         Author        Modification
 * 1.0   21-02-2022    Dhruv Javiya  Initial Version()
**/
public class AssignResourceToTerritoryController {
    /*
    * Method name            	: checkLoggedinUserAccess
    * Description            	: This method is used to check and get User Access Details
    * @return Map<String,String>: Returns Success detail with user type access
    * @Param                 	: 
    */
    @AuraEnabled(cacheable=true)
    Public Static Map<String,String> checkLoggedinUserAccess(){
        
        Map<String,String> returnData=new Map<String,String>();
        returnData.put('Success','true');
        // Check Logged in User is Admin
        User currentUser=[SELECT Id,Profile.Name From User Where Id =:UserInfo.getUserId()];
        if(currentUser.Profile.Name==System.Label.AssignResource_Profile_Name){
             returnData.put('UserType','ADMIN');
        }else{
            // Check It's PM
            List<ServiceResource> listServiceResource=[SELECT ID,Primary_Branch_Family__c,Primary_Branch_Family__r.Name,Branch__c,Branch__r.Branch_Family__c,Branch__r.Branch_Family__r.Name,RecordType.DeveloperName,Manager__c,Project_Coordinator__c FROM ServiceResource where RelatedRecordId= :currentUser.Id];
            if(listServiceResource.size()>0){
                if(listServiceResource[0].RecordType.DeveloperName =='Install_OV'){
                    if(listServiceResource[0].Manager__c==true || listServiceResource[0].Project_Coordinator__c == true){
                        returnData.put('UserType','PC_MANAGER');
                        if(listServiceResource[0].Primary_Branch_Family__c!=null){
                            returnData.put('BranchFamily',listServiceResource[0].Primary_Branch_Family__c);
                            returnData.put('BranchFamilyName',listServiceResource[0].Primary_Branch_Family__r.Name);
                        }else{
                            returnData.put('BranchFamily',listServiceResource[0].Branch__r.Branch_Family__c);
                            returnData.put('BranchFamilyName',listServiceResource[0].Branch__r.Branch_Family__r.Name);
                        }
                        
                    }else{
                        returnData.put('Success','false');
                        returnData.put('ErrorMessage',System.Label.AssignResource_Product_Coordinator);
                    }
                }else{
                    returnData.put('Success','false');
                    returnData.put('ErrorMessage',System.Label.AssignResource_Associated_with_Install_OV);
                }
            }else{
                returnData.put('Success','false');
                returnData.put('ErrorMessage',System.Label.AssignResource_Associated_with_service_resource);
            }
        }
        
      
        return returnData;
    }
    
    /*
    * Method name            			: getListOfBranchFamily
    * Description            			: This method is used to get avaialble list of branch family
    * @return List<Branch_Grouping__c>  : Returns list of branch records
    * @Param                 			: 
    */
    @AuraEnabled(cacheable=false)
    public Static List<Branch_Grouping__c> getListOfBranchFamily(){
        return [SELECT Id,Name FROM Branch_Grouping__c Order by name ASC];
    }
    
    /*
    * Method name            	: getListOfBranchByBranchFamily
    * Description            	: This method is used to retrive Branch From Branch Family
    * @return List<Branch__c>   : Returns list of branches
    * @Param                 	: branchFamily
    */
    @AuraEnabled(cacheable=false)
    public Static List<Branch__c> getListOfBranchByBranchFamily(String branchFamily){
        return [SELECT ID,Name,Branch_Number__c  FROM Branch__c Where Branch_Family__c = : branchFamily Order By Branch_Number__c ,Name];
    }
    
    /*
    * Method name            	: getListOfTerritoryByBranch based on branch
    * Description            	: This method is used to retrive Branch From Branch Family
    * @return List<Branch__c>   : Returns list of Service Terriroty
    * @Param                 	: branchId
    */
    @AuraEnabled(cacheable=false)
    public Static List<ServiceTerritory> getListOfTerritoryByBranch(String branchId){
        return [SELECT ID,Name FROM ServiceTerritory Where Branch__c = : branchId and recordType.DeveloperName = 'OV_Install_Territory' and isActive=true];
    }
    
    /*
    * Method name            	: getListOfServiceResourceByBranch based on branch
    * Description            	: This method is used to retrive Branch From Branch Family
    * @return List<Branch__c>   : Returns list of service Territory
    * @Param                 	: branchId
    */
    @AuraEnabled(cacheable=false)
    public Static List<ServiceResource> getListOfServiceResourceByBranch(String branchId,String TerritoryId){
        return [SELECT ID,Name,ResourceType,Resource_Group__c,Installer__c,Installer_Third_Party__c,Order_Verifier__c,Order_Verifier_Third_Party__c,(SELECT ID,ServiceTerritoryId,TerritoryType  FROM ServiceTerritories where ServiceTerritoryId=:TerritoryId ) FROM ServiceResource Where Branch__c = : branchId and isActive=true and (Installer__c=true or Installer_Third_Party__c=true or Order_Verifier__c=true or Order_Verifier_Third_Party__c=true) ]; // temporary commented for test data // and RecordType.DeveloperName='Install_OV'
    }
    
    /*
    * Method name            	: createOrDeleteSTM based on branch
    * Description            	: This method is used to createOrUpdateSTM Records
    * @return List<Branch__c>   : Returns list of service Territory
    * @Param                 	: branchId
    */
    @AuraEnabled(cacheable=false)
    public Static Boolean createOrDeleteSTM(String STMRecords,String TerritoryId){
        
        List<STMWrapper> listSTMWrapper=(List<STMWrapper>)JSON.deserialize(STMRecords, List<STMWrapper>.class);
        List<ServiceTerritoryMember> createListSTM=new List<ServiceTerritoryMember>();
        List<String> deleteListSTM=new List<String>();
        List<String> listPrimarySTMDelete=new List<String>();
        
		List<String> listResourceIds=new List<String>();         
        for(STMWrapper STM : listSTMWrapper){
            if(STM.actionType=='Insert'){
                ServiceTerritoryMember STMRec=new ServiceTerritoryMember();
                STMRec.ServiceTerritoryId=TerritoryId;
                STMRec.ServiceResourceId =STM.resourceId;
                STMRec.TerritoryType='S';
                STMRec.EffectiveStartDate=Date.today()-1;
                createListSTM.add(STMRec);
            }else if(STM.actionType=='Delete'){
                deleteListSTM.add(STM.resourceId);
                if(STM.isPrimary){
                    listPrimarySTMDelete.add(STM.resourceId);
                }
            }
            listResourceIds.add(STM.resourceId);
        }
        
        // find existing territory member record for users
        Map<String,ServiceTerritoryMember> mapExistingSTM=new Map<String,ServiceTerritoryMember>();
        for(ServiceTerritoryMember STM : [SELECT ServiceResourceId,TerritoryType,ServiceTerritoryId FROM ServiceTerritoryMember Where ServiceResourceId in :listResourceIds and ServiceTerritoryId != :TerritoryId]){
            mapExistingSTM.put(STM.ServiceResourceId,STM);
        }
        
        // List STM To Delete
        delete [SELECT ID FROM ServiceTerritoryMember Where ServiceTerritoryId=:TerritoryId and  ServiceResourceId = :deleteListSTM];
        
        // Mark Resource to Primary if it's first STM record
        for(ServiceTerritoryMember STMRec : createListSTM){
            if(!mapExistingSTM.containsKey(STMRec.ServiceResourceId)){
                STMRec.TerritoryType='P';
            }
        }
        
        system.debug('@@'+createListSTM);
        List<ServiceTerritoryMember> listSTMtoUpdate=new List<ServiceTerritoryMember>();
        // Mark Resource exist and deleted resource is Primary then update another record as primary First
        for(String deletedResourceId : listPrimarySTMDelete){
            if(mapExistingSTM.containsKey(deletedResourceId)){
                ServiceTerritoryMember STMRec=mapExistingSTM.get(deletedResourceId);
                STMRec.TerritoryType='P';
                listSTMtoUpdate.add(STMRec);
            }
        }
        
        // update STM
        insert listSTMtoUpdate;
        
        // create STM
        insert createListSTM;
        
        return true;
    }

    public class STMWrapper{
        public String resourceId;
        public String actionType;
        public Boolean isPrimary;
    }    
}