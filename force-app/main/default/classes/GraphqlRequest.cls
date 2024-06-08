public class GraphqlRequest {
    public class GraphqlRequestBody {
        public String query;
        public String operationName;
        public Object variables;
    }
    
    public static String generateGraphqlRequestBody(String query, String operationName, Object variables) {
        GraphqlRequestBody requestBody = new GraphqlRequestBody();
        
        requestBody.query = query;
        requestBody.operationName = operationName;
        requestBody.variables = variables;
        
        return JSON.serialize(requestBody, true);
    }
}