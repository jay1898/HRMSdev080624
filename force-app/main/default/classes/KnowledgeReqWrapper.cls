public class KnowledgeReqWrapper{
    public cls_entry entry;
    public class cls_entry {
        public String title;	//example
        public String question;	//test Question
        public String answer;	//test answer
    }

    public static KnowledgeReqWrapper parse(String json){
        return (KnowledgeReqWrapper) System.JSON.deserialize(json, KnowledgeReqWrapper.class);
    }
}