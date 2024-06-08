/*
    Type:           Resource Absence custom action
    Description:    This action will delete an absence based on dispatcher request in the Gantt
*/

global class ResourceAbsenceDeleteFromGantt implements FSL.CustomGanttResourceAbsenceAction {
 
    global String action(Id absenceId, String absenceType, Datetime ganttStartDate, Datetime ganttEndDate, Map<String, Object> additionalParameters) {
       
        ResourceAbsence resourceAbsence = [SELECT Id, AbsenceNumber FROM ResourceAbsence WHERE Id =: absenceId LIMIT 1];

        delete resourceAbsence;

        return 'Resource Absence successfully deleted. Gantt will refresh momentarily.';
    }
   
}