global class WOShareWithQtOwnerBatchSchedule implements Schedulable {
     global void execute(SchedulableContext sc){		
         WOShareWithQtOwnerBatch insertWOQtOwnerBatch = new WOShareWithQtOwnerBatch();
        Id BatchProcessId = Database.ExecuteBatch(new WOShareWithQtOwnerBatch(),200);
    }

}