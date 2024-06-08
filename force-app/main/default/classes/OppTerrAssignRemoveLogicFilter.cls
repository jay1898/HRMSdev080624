/*** Apex version of the default logic.
* If opportunity's assigned account is assigned to
*  Case 1: 0 territories in active model
*            then set territory2Id = null
*  Case 2: 1 territory in active model
*            then set territory2Id = account's territory2Id
*  Case 3: 2 or more territories in active model
*            then set territory2Id = account's territory2Id that is of highest priority.
*            But if multiple territories have same highest priority, then set territory2Id = null 
*/
global class OppTerrAssignRemoveLogicFilter implements TerritoryMgmt.OpportunityTerritory2AssignmentFilter { 
    /**
     * No-arg constructor.
     */ 
     global OppTerrAssignRemoveLogicFilter() {}

     /**
      * Get mapping of opportunity to territory2Id. The incoming list of opportunityIds contains only those with IsExcludedFromTerritory2Filter=false.
      * If territory2Id = null in result map, clear the opportunity.territory2Id if set.
      * If opportunity is not present in result map, its territory2Id remains intact.
      */
    global Map<Id,Id> getOpportunityTerritory2Assignments(List<Id> opportunityIds) { 
        Map<Id, Id> OppIdTerritoryIdResult = new Map<Id, Id>();

      
        List<Opportunity> opportunities =
              [Select Id, AccountId, Territory2Id from Opportunity where Id IN :opportunityIds];
            
        for(Opportunity opp: opportunities){
             OppIdTerritoryIdResult.put(opp.Id, null);
        }
        return OppIdTerritoryIdResult;
    }
    
   
}