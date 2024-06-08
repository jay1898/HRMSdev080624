global class P_ReportControllerMinneapolisSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        callReportProcess();
    }
    
    public void callReportProcess() {
        P_ReportController.processOptyMinneapolis();
    }
}