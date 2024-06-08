global class createActivity implements messaging.Inboundemailhandler {
    List <lead> leadlist;
    global messaging.InboundEmailresult handleInboundEmail(messaging.InboundEmail email, messaging.InboundEnvelope envelope) {
        leadlist = new list <lead>();
        system.debug('@@@@@email:' + email);
        system.debug('@@@@@envelope:' + envelope);
        messaging.InboundEmailresult result = new messaging.InboundEmailresult();
        string Activityname = email.fromname;
        system.debug('@@@@@Activityname:' + Activityname);
        String fromemailaddresss = email.fromAddress;
        List <lead> leadlist = [select id from lead where email = : fromemailaddresss limit 1];
        system.debug('@@@@@fromemailaddresss:' + fromemailaddresss);
        string des = email.plaintextbody;
        string tasksubject = email.subject;
        Task tkobj = new Task(Status = 'Email Response', Description = 'Email Response by Lead Owner', subject = tasksubject, Priority = 'Medium', ActivityDate = System.today(), ReminderDateTime = System.now(), WhoId = leadlist[0].id);
        insert tkobj;
        system.debug('@@@@@tkobj:' + tkobj);
        return null;
    }
}