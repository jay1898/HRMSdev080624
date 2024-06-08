public class ActiveContactsWrapper{
	public Integer totalRecords;	//4
	public Integer businessUnitId;	//4602474
	public String lastPollTime;	//2024-01-24T13:08:51.758Z
	public cls_activeContacts[] activeContacts;
	
	class cls_previous {
	}
	class cls_activeContacts {
		public String agentId;	//30152852
		public String agentStartDate;	//2024-01-24T13:08:37.870Z
		public Integer campaignId;	//5714986
		public String campaignName;	//CPCC_PDSN
		public String contactId;	//477594009474
		public String contactStartDate;	//2024-01-24T13:08:29.630Z
		public String digitalContactStateName;
		public String digitalContactStateId;
		public String fileName;
		public String firstName;	//Darlene
		public String fromAddress;	//8552915735
		public Integer highProficiency;	//1
		public Integer holdCount;	//0
		public boolean isLogged;
		public boolean isOutbound;
		public boolean isTakeover;
		public String lastName;	//Wagner
		public String lastUpdateTime;	//2024-01-24T13:08:37.870Z
		public String masterContactId;	//477594009474
		public Integer lowProficiency;	//20
		public String mediaSubTypeId;
		public String mediaSubTypeName;
		public Integer mediaTypeId;	//4
		public String mediaTypeName;	//Phone Call
		public Integer pointOfContactId;	//58471550
		public String pointOfContactName;	//CPCC_PDSN_MM_641.621.3262
		public Integer routingAttribute;	//-1
		public Integer skillId;	//14355281
		public String skillName;	//IB-CPCC_PDSN_SS
		public String stateName;	//Active
		public Integer stateId;	//4
		public String contactStateCategory;	//With Agent
		public Integer targetAgentId;	//0
		public Integer teamId;	//5619216
		public String teamName;	//CPCC_PDSN_SS
		public String toAddress;	//6416213262
		public Integer transferIndicatorId;	//0
		public String transferIndicatorName;	//None
	}
	

	public static ActiveContactsWrapper parse(String json){
		return (ActiveContactsWrapper) System.JSON.deserialize(json, ActiveContactsWrapper.class);
	}

}