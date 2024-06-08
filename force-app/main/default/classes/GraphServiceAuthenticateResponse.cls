public class GraphServiceAuthenticateResponse {
    
    public String token_type;
	public Integer expires_in;
	public String access_token;
    public String scope;
	
    public static GraphServiceAuthenticateResponse parse(String json){
		return (GraphServiceAuthenticateResponse) System.JSON.deserialize(json, GraphServiceAuthenticateResponse.class);
	}
}