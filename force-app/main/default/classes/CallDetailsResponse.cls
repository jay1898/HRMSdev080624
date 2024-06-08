public class CallDetailsResponse{

	@AuraEnabled
	public String sessionId;
		@AuraEnabled
		public String IISHost;
		@AuraEnabled
		public String VCHost;
		@AuraEnabled
		public String type;
		@AuraEnabled
		public String eventName;
		@AuraEnabled
		public String softPhoneDNIS;
		@AuraEnabled
		public String softPhoneWsServers;
		@AuraEnabled
		public String softPhoneStunServers;
		@AuraEnabled
		public String softPhonePlatform;
		@AuraEnabled
		public String sonusID;
		@AuraEnabled
		public String sonusPassword;
		@AuraEnabled
		public String sonusEnterprise;
		@AuraEnabled
		public String ANI;
		@AuraEnabled
		public String DNIS;
		@AuraEnabled
		public String Skill;
		@AuraEnabled
		public String skillName;

	public static CallDetailsResponse parse(String json){
		return (CallDetailsResponse) System.JSON.deserialize(json, CallDetailsResponse.class);
	}
}