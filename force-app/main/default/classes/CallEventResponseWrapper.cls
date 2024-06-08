/*
Created By      : Wajid Abdhulla
Created Date    : 10 January 2024
Purpose         : This is a wrapper for the response attributes in CXOne Call Event.
----------------------------------------------------------------------------------------------*/

public without sharing class CallEventResponseWrapper {
    @AuraEnabled
    public String sessionId;
    @AuraEnabled
	public List<Events> events;

	public class Events {
        @AuraEnabled
		public String DNIS;
        @AuraEnabled
		public String ANI;
        @AuraEnabled
		public String Skill;
        @AuraEnabled
		public String IISHost;
        @AuraEnabled
		public String VCHost;
        @AuraEnabled
		public String type;
        @AuraEnabled
		public String eventName;
        @AuraEnabled
		public String data;
        @AuraEnabled
		public String ContactID;
        @AuraEnabled
		public String MasterID;
        @AuraEnabled
		public String Status;
        @AuraEnabled
		public String OriginalState;
        @AuraEnabled
		public String CallType;
        @AuraEnabled
		public String IsInbound;
        @AuraEnabled
		public String StartTimeUTC;
        @AuraEnabled
		public String StartTime;
        @AuraEnabled
		public String LastStateChangeTimeUTC;
        @AuraEnabled
		public String LastStateChangeTime;
        @AuraEnabled
		public String ScreenPopUrl;
        @AuraEnabled
		public List<ScreenPopUrlVariables> ScreenPopUrlVariables;
        @AuraEnabled
		public String DisconnectCode;
        @AuraEnabled
		public String IsLogging;
        @AuraEnabled
		public String Timeout;
        @AuraEnabled
		public String AllowDispositions;
        @AuraEnabled
		public String Label;
        @AuraEnabled
		public String IsLinked;
        @AuraEnabled
		public String TimeZones;
        @AuraEnabled
		public String FinalState;
        @AuraEnabled
		public String OtherInformation;
        @AuraEnabled
		public String OtherInformationNewFormat;
        @AuraEnabled
		public String BlendingToSkillName;
        @AuraEnabled
		public String DeliveryType;
        @AuraEnabled
		public String CustomData;
        @AuraEnabled
		public String ComplianceRecord;
        @AuraEnabled
		public String ConfirmationRequired;
        @AuraEnabled
		public String ParentContactId;
        @AuraEnabled
		public String OmniGroupId;
        @AuraEnabled
		public String ExternalId;
        @AuraEnabled
		public String AnsMachineOverride;
        @AuraEnabled
		public String AnsMachineOverrideEndTime;
        @AuraEnabled
		public String CustomerCardUrl;
        @AuraEnabled
		public String InteractionId;
        @AuraEnabled
		public String IsRequireManualAccept;
        @AuraEnabled
		public String PhoneCallRefusalTimeOut;
        @AuraEnabled
		public String CurrentState;
        @AuraEnabled
		public String CurrentOutReason;
        @AuraEnabled
		public List<NextStates> NextStates;
        @AuraEnabled
		public String IsAcw;
        @AuraEnabled
		public String NextIsAcw;
        @AuraEnabled
		public String AcwTimeout;
        @AuraEnabled
		public String IsExternal;
        @AuraEnabled
		public String BusNo;
        @AuraEnabled
		public String AgentId;
        @AuraEnabled
		public String StationId;
        @AuraEnabled
		public String StationPhoneNumber;
        @AuraEnabled
		public String StationCallerId;
        @AuraEnabled
		public String SessionId;
        @AuraEnabled
		public String DialerCampaign;
        @AuraEnabled
		public String DialerCampaignStartTime;
        @AuraEnabled
		public String SupervisorPermissionLevel;
        @AuraEnabled
		public String CanMask;
        @AuraEnabled
		public String AgentSchedulePermission;
        @AuraEnabled
		public String ScoreRecordingsPermission;
        @AuraEnabled
		public String HideAgentStatePermission;
        @AuraEnabled
		public String ClientConnectorPort;
        @AuraEnabled
		public String CanMultiPartyConference;
        @AuraEnabled
		public String MaxConcurrentChats;
        @AuraEnabled
		public String CanRecord;
        @AuraEnabled
		public String EnabledForMCH;
        @AuraEnabled
		public String UseCustomerCard;
        @AuraEnabled
		public String AgentUUId;
        @AuraEnabled
		public String EntityMode;
	}

	public class NextStates {
        @AuraEnabled
		public String State;
        @AuraEnabled
		public String OutReason;
	}

	public class ScreenPopUrlVariables {
        @AuraEnabled
		public String queue;
        @AuraEnabled
		public String sfdcquery0;
        @AuraEnabled
		public String sfdcquery1;
        @AuraEnabled
		public String pervar_5;
        @AuraEnabled
		public String pervar_4;
        @AuraEnabled
		public String pervar_7;
        @AuraEnabled
		public String pervar_8;
	}

    public static CallEventResponseWrapper parse(String json) {
		return (CallEventResponseWrapper) System.JSON.deserialize(json, CallEventResponseWrapper.class);
	}
}