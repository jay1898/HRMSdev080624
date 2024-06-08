public class CXOneOAuthResponse {

    public String access_token;	
    public String token_type;	
    public Integer expires_in;	
    public String refresh_token;	
    public String id_token;	
    public String issued_token_type;
    public String error;
    public String error_description;

    public static CXOneOAuthResponse parse(String json){
        return (CXOneOAuthResponse) System.JSON.deserialize(json, CXOneOAuthResponse.class);
    }
}