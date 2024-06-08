public without sharing class OpportunityToolbarController 
{
	@AuraEnabled
    public static List<String> addOpportunityTeam(String recordId ) 
    {
        System.debug('UAC: recordId ' + recordId );
        Id currentUserId = UserInfo.getUserId() ; 
        Set<String> response = new Set<String>();

        try
        {
            List<OpportunityTeamMember> teamMembers = [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId = :recordId AND UserId = :currentUserId ];
            if(teamMembers.size() > 0) response.add('memberAlreadyExists') ;

            List<OpportunitySplit> splitOpps = [SELECT Id FROM OpportunitySplit WHERE OpportunityId = :recordId AND SplitOwnerId = :currentUserId ];
            if(splitOpps.size() > 0) response.add('splitOppAlreadyExists') ;

            if(teamMembers.size() > 0 && splitOpps.size() > 0) response = new Set<String>{'BothRecordsAlreadyExists'};

            if(teamMembers.size() == 0) 
            {
                insert new OpportunityTeamMember(   OpportunityId = recordId, UserId = currentUserId, 
                                                    TeamMemberRole = 'Sales Rep', OpportunityAccessLevel = 'Edit' );
                response.add('MemberCreated') ;
            }

            if(splitOpps.size() == 0)
            { 
                OpportunitySplit os = new OpportunitySplit( OpportunityId = recordId, SplitPercentage = 100, SplitOwnerId = currentUserId,
                                                            SplitTypeId = [SELECT Id FROM OpportunitySplitType WHERE MasterLabel = 'Total Price Overlay Credit'].Id,
                                                            SplitNote = System.Label.Opportunity_Split_Note );
                
                insert os ;
                System.debug('UAC: os ' + os );

                if(response.contains('MemberCreated'))  response.add('BothRecordsCreated') ;
                
                if(os.Id != null && !response.contains('BothRecordsCreated')) response.add('SplitOppCreated') ;   
            }
            System.debug('UAC: response ' + response );

            if(response.contains('MemberCreated') && response.contains('BothRecordsCreated')) response.remove('MemberCreated');
        }
    	catch(DmlException ex ){throw new AuraHandledException(ex.getDmlMessage(0));}

        return new List<String>(response) ;
    }
}