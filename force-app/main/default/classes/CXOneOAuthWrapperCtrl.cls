public class CXOneOAuthWrapperCtrl {

    public String access_token;	
    public String token_type;	
    public Integer expires_in;	
    public String refresh_token;	
    public String id_token;	
    public String issued_token_type;
    public String error;
    public String error_description;

	public static CXOneOAuthWrapperCtrl parse(String json){
		return (CXOneOAuthWrapperCtrl) System.JSON.deserialize(json, CXOneOAuthWrapperCtrl.class);
	}
}