public class CallDetailsWrapper{

	@AuraEnabled
	public String sessionId;	//clVmMmFJMFlJam9VU0FMNDZYOFJLN2tvZXY4VDlBNjY3MHBwMFNtQVVWUTlnUzljaXpjelN5N1FlMjA9
	//public cls_events[] events;
	//public class cls_events {
		@AuraEnabled
		public String IISHost;	//AOA-C48API01
		@AuraEnabled
		public String VCHost;	//AOA-C48COR01
		@AuraEnabled
		public String type;	//CustomEvent
		@AuraEnabled
		public String eventName;	//WebRTC
		@AuraEnabled
		public String softPhoneDNIS;	//1700499991048
		@AuraEnabled
		public String softPhoneWsServers;	//global-wrtc.niceincontact.com
		@AuraEnabled
		public String softPhoneStunServers;	//uswrs.niceincontact.com:3478
		@AuraEnabled
		public String softPhonePlatform;	//Sonus
		@AuraEnabled
		public String sonusID;	//InWebRTC
		@AuraEnabled
		public String sonusPassword;	//inC0ntact4MAX1ntegrate
		@AuraEnabled
		public String sonusEnterprise;	//GLOBAL_AGENT
		@AuraEnabled
		public String ANI;	//GLOBAL_AGENT
		@AuraEnabled
		public String DNIS;	//GLOBAL_AGENT
		@AuraEnabled
		public String Skill;	//GLOBAL_AGENT
		@AuraEnabled
		public String skillName;	//GLOBAL_AGENT
	//}

	public static CallDetailsWrapper parse(String json){
		return (CallDetailsWrapper) System.JSON.deserialize(json, CallDetailsWrapper.class);
	}
}