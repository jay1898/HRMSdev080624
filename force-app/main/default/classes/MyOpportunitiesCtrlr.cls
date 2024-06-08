/*
Created By: Sachin Padhiyar
Created Date: 
Purpose: This class is fetching all the territories of logged in user.
Displaying all Accounts related in the selected territory and 
logged in user if assigned to me toggle is checked
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
----------------------------------------------------------------------------------------------
*/


public with sharing class MyOpportunitiesCtrlr {
    
    //This method is used to fetch all the territories associated to the logged in user
    @AuraEnabled
    public static List<BranchWrapper> fetchTerritories(){
        //Assigning the logged in userd id
        Id currentUserId = UserInfo.getUserId();
        Set<String> setOfTerritoriesIds = new Set<String>();
        String primary; 
        //quering junction object between territory and user      
        for(UserTerritory2Association objUserTerritory : [SELECT Id, Territory2Id, RoleInTerritory2 FROM UserTerritory2Association WHERE UserId =: currentUserId AND IsActive = True]){
            setOfTerritoriesIds.add(objUserTerritory.Territory2Id);
        }
        User u=[SELECT Id,Trade_Branch_Number__c FROM User where Id=:currentUserId];
        if(u.Trade_Branch_Number__c!=null){
            primary=u.Trade_Branch_Number__c;
        }
        //returning all the territories details associated to the log in user
        Set<String> setOfBranchnumbers = new Set<String>();
        for(Territory2 objTerritory : [SELECT Id, Name, TCBranchNumber__c FROM Territory2 WHERE Id IN :setOfTerritoriesIds]){
            //gathering all TC Branch Number of the territories
            if(String.isNotBlank(objTerritory.TCBranchNumber__c))
                setOfBranchnumbers.add(objTerritory.TCBranchNumber__c);
        }
        //checking if TC Branch Numbers are not empty
        if(!setOfBranchnumbers.isEmpty()){
            List<BranchWrapper> lstBranchWrapper = new List<BranchWrapper>();
            //Fetching all Branches based on TC Branch Numbers
            for(Branch__c objBranch : [SELECT Id, Name, T_C_Branch_Number__c FROM Branch__c WHERE T_C_Branch_Number__c IN :setOfBranchnumbers]){
                //Initializing Branch Wrapper and assigning the respective values
                BranchWrapper objBranchWrapper = new BranchWrapper();
                objBranchWrapper.branchId = objBranch.Id;
                objBranchWrapper.branchName = objBranch.Name;
                //Check to identified the primary Branch based on TC Branch Number
                if(String.isNotBlank(primary) && primary == objBranch.T_C_Branch_Number__c)
                    objBranchWrapper.isPrimary = true;
                else
                    objBranchWrapper.isPrimary = false;
                lstBranchWrapper.add(objBranchWrapper);
            }
            //returning all Branches of the logged in User
            return lstBranchWrapper;
        }
        return null;
    }
    
    //method to fetch all the accounts inside a selected territory and logged in user
    @AuraEnabled
    public static List<Markers> fetchOpportunityLocations(String selectedTerritory,Boolean assignedToMe,Boolean showOpportunities){
        system.debug('selectedTerritory=>'+selectedTerritory);
        //Checking if the screen variables are not blank
        if((String.isNotBlank(selectedTerritory) && selectedTerritory != '--None--' ) || assignedToMe == true || showOpportunities == true){
            //Creating Query string
            String sQuery;
            //Checking if the show opportunity toggle is true
            if(showOpportunities == true)
                sQuery = 'SELECT Id, Name, Geo_Location__Latitude__s, Geo_Location__Longitude__s FROM Opportunity';
            else
                sQuery = 'SELECT Id, Name, Geo_Location__Latitude__s, Geo_Location__Longitude__s FROM Account';
            
            //Check to validate if territory is selected and adding selected territory to the query
            if(String.isNotBlank(selectedTerritory) && selectedTerritory != '--None--'){
                if(showOpportunities == true)
                    sQuery += ' WHERE Account.Branch__c = \'' + selectedTerritory + '\'';
                else
                    sQuery += ' WHERE Branch__c = \'' + selectedTerritory + '\'';
            }
            //Checking if assigned to me toggle is checked
            if(assignedToMe == true || showOpportunities == true){
                //adding assigned to me in the query
                sQuery += ((String.isNotBlank(selectedTerritory) && selectedTerritory != Label.None) ? ' AND ' : ' WHERE ');
                sQuery += ' OwnerId = \'' + UserInfo.getUserId() + '\'';
            }
            //Intializing list of markers
            List<Markers> lstMarkers = new List<Markers>();
            //Queirng accounts
            for(sObject objSObject : Database.query(sQuery)){
                //Check to validate if geo location fields are not null
                if(objSObject.get('Geo_Location__Latitude__s') != Null && objSObject.get('Geo_Location__Longitude__s') != Null){
                    //intializing marker wrapper and assigning the location details
                    Markers objMarkers = new Markers();
                    objMarkers.location.lat = (Decimal) objSObject.get('Geo_Location__Latitude__s');
                    objMarkers.location.lng = (Decimal) objSObject.get('Geo_Location__Longitude__s');
                    objMarkers.title = (String) objSObject.get('Name');
                    if(showOpportunities == true)
                        objMarkers.objectId = Label.Ligtning_Url + '/' + Label.Lightning_Record_Url + '/' + Label.Opportunity_Object + '/' + (String) objSObject.get('Id') + '/view';
                    else
                        objMarkers.objectId = Label.Ligtning_Url + '/' + Label.Lightning_Record_Url + '/' + Label.Account_Object + '/' + (String) objSObject.get('Id') + '/view';
                    lstMarkers.add(objMarkers);
                }
            }
            //returning all markers
            return lstMarkers;
        }
        return null;
    }
    //Wrapper class for the Branches
    public class BranchWrapper{
        @AuraEnabled public String branchId;
        @AuraEnabled public String branchName;
        @AuraEnabled public Boolean isPrimary;
    }
    
    //Wrapper class for the location marker
    public class Markers{
        @AuraEnabled public OppLocation location;
        @AuraEnabled public String title;
        @AuraEnabled public String objectId;
        public Markers(){
            location = new OppLocation();
        }
    }
    //Wrapper class for latitude and longitude
    public class OppLocation{
        @AuraEnabled public Decimal lat;
        @AuraEnabled public Decimal lng;
    }
}