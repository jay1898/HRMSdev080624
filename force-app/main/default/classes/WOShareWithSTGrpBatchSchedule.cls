global class WOShareWithSTGrpBatchSchedule implements Schedulable {
     global void execute(SchedulableContext sc){		
         WOShareWithSTPublicGroupBatch insertWOBatch = new WOShareWithSTPublicGroupBatch();
        Id BatchProcessId = Database.ExecuteBatch(new WOShareWithSTPublicGroupBatch(),200);
    }

}