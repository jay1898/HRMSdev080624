/*
Created By      : Subhash Panchani
Created Date    : 28 July 2023
Purpose         : This is a Model Class for CaseQuickTextTriggerHandler. 
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class CaseQuickTextTriggerHandlerModel {
    /*
    *   Created By      : Subhash Panchani
    *   Added on        : 28 July 2023
    *   Purpose         : To get Group details.
    *   Input Param     : Set of Queue Name
    *   Output Param    : List of Group Sobject.
    */
 public static List<Group> getQueue (Set<String> queueList) {
        return new List<Group>([select Name,DeveloperName from Group where Type = 'queue' and Name In : queueList]);
    }
}