public with sharing class ListViewController {

   
    public List <Account> ListSelectedAccounts {
        get;
        set;
    }
    public PageReference getTaskView() {
		return new PageReference('/lightning/o/Task/home?0.source=alohaHeader');
 	}
    public ListViewController(ApexPages.StandardSetController listcontroller) {
      
        Set <Id> accSelectedIds = new set <Id> ();
        ListSelectedAccounts = new List <Account>();
            
        for (Account acc: (Account[]) listcontroller.getSelected()) {
            accSelectedIds.add(acc.id);
        }
        
        /**Querying on the Selected records and fetching fields which are required in Flow **/
        ListSelectedAccounts = [select Id, OwnerId from Account where id in: accSelectedIds];
    }
}