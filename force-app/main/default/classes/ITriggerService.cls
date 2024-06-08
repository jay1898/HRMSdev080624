public Interface ITriggerService {
    
    /** 
    * This method is called prior to execution of a BEFORE trigger. Use this to cache 
    * any data required into maps prior execution of the trigger. 
    */ 
    void prepareDataBeforeEvent(List<sObject> newList);


    /** 
    * This method is called prior to execution of a AFTER trigger. Use this to cache 
    * any data required into maps prior execution of the trigger. 
    */ 
    void prepareDataAfterEvent(List<sObject> newList);
}