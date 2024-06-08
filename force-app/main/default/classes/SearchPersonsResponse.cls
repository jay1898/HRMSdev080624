public class SearchPersonsResponse {

    public class SearchPersons {
		public List<Results> results;
		public PageInfo pageInfo;
	}
	

	public class PageInfo {
		public Integer currentPage;
		public Integer totalPages;
		public Integer nextPage;
		public Integer totalRecords;
		public Integer thelimit;
		public Integer theoffset;
	}

	public Data data;

	public class Results {
		public String id;
		public String displayName;
		public String phoneNumber;
		public String email;
		public String street;
		public String city;
		public String state;
		public String postalCode;
	}

	public class Data {
		public SearchPersons searchPersons; 
	}

	
	public static SearchPersonsResponse parse(String json) {
		return (SearchPersonsResponse) System.JSON.deserialize(json, SearchPersonsResponse.class);
	}
}