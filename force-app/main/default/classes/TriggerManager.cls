public class TriggerManager {
   
    public static void handle(ITrigger handler, String metaDataControlKey) { 

        // Return if trigger has been disabled.
        if(!Utility.isFunctionalityActive(metaDataControlKey)) return;

        // Before Trigger 
        if (Trigger.isBefore) { 
            // Call the bulk before to handle any caching of data and enable bulkification 
            handler.bulkBefore(); 
            
            if (Trigger.isDelete) { 
                handler.beforeDelete(Trigger.old, Trigger.oldMap);
            } else if (Trigger.isInsert) { 
                handler.beforeInsert(Trigger.new);
            } else if (Trigger.isUpdate) { 
                handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
            } 
        } else { 
            // Call the bulk after to handle any caching of data and enable bulkification 
            handler.bulkAfter(); 
            if (Trigger.isDelete) { 
                handler.afterDelete(Trigger.old, Trigger.oldMap);
            } else if (Trigger.isInsert) { 
                handler.afterInsert(Trigger.new, Trigger.newMap);
            } else if (Trigger.isUpdate) { 
                handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
            } 
        } 
        
        // Perform any post processing 
        handler.andFinally(Trigger.new, Trigger.newMap); 
    } 
}