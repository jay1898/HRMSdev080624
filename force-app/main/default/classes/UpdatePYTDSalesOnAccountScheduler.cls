global class UpdatePYTDSalesOnAccountScheduler implements Schedulable {
    global void execute(SchedulableContext sc)
    {
        UpdatePYTDSalesOnAccount batchObj = new UpdatePYTDSalesOnAccount();     
        Database.executeBatch(batchObj, 400);     
    }
}