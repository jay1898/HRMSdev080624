public class AuthRespWrapper{
    public String accountId;	//5fd8761b03c5ea2e8afa1caa
    public Integer ottExpiration;	//480
    public String token;	//hdxfvphsvy

    public static AuthRespWrapper parse(String json){
        return (AuthRespWrapper) System.JSON.deserialize(json, AuthRespWrapper.class);
    }
}