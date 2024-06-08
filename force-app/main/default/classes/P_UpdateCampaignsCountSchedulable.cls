global class P_UpdateCampaignsCountSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        callSchedulableProcess();
    }
    
    public void callSchedulableProcess() {
        DateTime toDate = System.now().addMinutes(60);//next 10 min;
        Integer nextDay = toDate.day();
        Integer nextMonth = toDate.month();
        Integer nextYear = toDate.year();
        Integer hrNow = toDate.hour();
        Integer minNow = toDate.minute();
        
        DateTime toDateForLead = System.now().addMinutes(2);//next 10 min;
        Integer nextDayForLead = toDateForLead.day();
        Integer nextMonthForLead = toDateForLead.month();
        Integer nextYearForLead = toDateForLead.year();
        Integer hrNowForLead = toDateForLead.hour();
        Integer minNowForLead = toDateForLead.minute();
        
        String schTimeForOpps = '0 '+minNow+' '+hrNow+' '+nextDay+' '+nextMonth+' ? '+nextYear+'';
        String schTimeForLead = '0 '+minNowForLead+' '+hrNowForLead+' '+nextDayForLead+' '+nextMonthForLead+' ? '+nextYearForLead+'';
        DateTime dt = DateTime.now();
        String nowTime = dt.format('yyyy/MM/dd HH:mm:ss');
        try{
            System.debug('schTimeForOpps --> '+schTimeForOpps);
            System.debug('schTimeForLead --> '+schTimeForLead);
            //System.schedule('P_UpdateCampaignsCountBatchOpps : '+nowTime+': For :'+minNow, schTimeForOpps , new P_UpdateCampaignsCountBatchOpps());
            
            //System.schedule('P_UpdateCampaignsCountBatchLeads : '+nowTime+': For :'+minNowForLead, schTimeForLead , new P_UpdateCampaignsCountBatchLeads());
            
            P_UpdateCampaignsCountBatchOpps puccbOpps = new P_UpdateCampaignsCountBatchOpps();
            Database.executeBatch(puccbOpps);
            P_UpdateCampaignsCountBatchLeads puccbLeads = new P_UpdateCampaignsCountBatchLeads();
            Database.executeBatch(puccbLeads);
            
            System.schedule('P_UpdateCampaignsCountSchedulable : '+nowTime+': For :'+minNow, schTimeForOpps , new P_UpdateCampaignsCountSchedulable());
            
        } catch(Exception ex) {
            System.debug('Message --> '+ex.getMessage()+' :: Line --> '+ex.getLineNumber());
        }
    }
}