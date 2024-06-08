public class GraphqlResponse {
 	public class GraphqlErrorExtensions {
        public String type;
        public String name;
        public String code;
        public List<String> stackTrace;
    }
    
    public class GraphqlError {
        public String message;
        public GraphqlErrorExtensions extensions;
    }
    
    public class GraphqlData {
        public Object data;
    }
    
    public class GraphqlResponseBody {
        public List<GraphqlError> errors;
        public GraphqlData data;
    }    
}