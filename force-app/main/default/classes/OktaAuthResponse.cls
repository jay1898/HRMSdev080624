public class OktaAuthResponse {

    public String token_type;
	public Integer expires_in;
	public String access_token;
	public String scope;
	
    public static OktaAuthResponse parse(String json){
		return (OktaAuthResponse) System.JSON.deserialize(json, OktaAuthResponse.class);
	}
}