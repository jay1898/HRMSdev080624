public class GraphQLAddressResponse {

	public Data data;

	public class GetStreetAddressesForPersonById {
		public String id;
		public String associationType;
		public List<String> streets;
		public String city;
		public String state;
		public String postalCode;
		public String country;
		public Boolean isIdentifying;
        public Boolean isPrimary;
        public String  branch;
	}

	public class Data {
		public List<GetStreetAddressesForPersonById> getStreetAddressesForPersonById;
	}

	
	public static GraphQLAddressResponse parse(String json) {
		return (GraphQLAddressResponse) System.JSON.deserialize(json, GraphQLAddressResponse.class);
	}
}