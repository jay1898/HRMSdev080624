/**
  * @date 10/9/2020
* @author Pallavi
* @description this class is used to Update Account YTD Fields
*/
global class UpdateAccountYTDFieldsScheduler implements Schedulable {
    global void execute(SchedulableContext sc)
	{
		UpdateAccountYTDFields batchObj = new UpdateAccountYTDFields();		
        Database.executeBatch(batchObj,200);     
	}

}