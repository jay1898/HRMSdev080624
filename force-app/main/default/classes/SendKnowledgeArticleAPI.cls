public class SendKnowledgeArticleAPI {
    
    public static void sendKnowledgeArticle(Id articleId) {
        Content_Stack_API_Details__c stackAPI       = Content_Stack_API_Details__c.getInstance();
        Knowledge__kav knowledgeObj                 = [Select Id, Answer__c, Title, Question__c from Knowledge__kav where Id =: articleId];
        KnowledgeReqWrapper wrapObj                 = new KnowledgeReqWrapper();
        KnowledgeReqWrapper.cls_entry entryObj      = new KnowledgeReqWrapper.cls_entry();
        entryObj.title                              = knowledgeObj.Title;
        entryObj.question                           = knowledgeObj.Question__c;
        entryObj.answer                             = knowledgeObj.Answer__c;
        wrapObj.entry                               = entryObj;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(stackAPI.Knowledge_Article_URL__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', stackAPI.Authorization__c);
        req.setHeader('api_key', stackAPI.API_Key__c);
        req.setBody(JSON.serialize(wrapObj));

        Http http                   = new Http();
        HTTPResponse res            = http.send(req);
        system.debug(res.getBody());
    }
}