public with sharing class VirtualBannerEventExt 
{
	@AuraEnabled
    public static Event getEventInfo(String recordId) 
    {
        return [SELECT Opportunity_Address__c, Opportunity_Party_Account_Name__c FROM Event WHERE ID = :recordId ];
    }
}