global class P_ReportControllerSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        callReportProcess();
    }
    
    public void callReportProcess() {
        P_ReportController.processOpty();
    }
}