public class ServiceTerritoryMemberTriggerHandler {
    public static void checkIfResourceExistAsPrimary(List<ServiceTerritoryMember> newSTM, Map<Id, ServiceTerritoryMember> oldConMap){
        
        List<String> listSTMIds=new List<String>();
        List<String> listSRIds=new List<String>();
        List<String> listSRExistAsSTIds=new List<String>();
        for(ServiceTerritoryMember STM : newSTM){
            if(STM.ServiceResourceId!=null && STM.TerritoryType!='P'){
                listSRIds.add(STM.ServiceResourceId);
                listSTMIds.add(STM.Id);
            }
            if(!Trigger.isDelete){
                if(STM.TerritoryType=='P'){
                    listSRExistAsSTIds.add(STM.ServiceResourceId);
                }
            }
        }
        system.debug('@@'+listSRExistAsSTIds);
        List<ServiceTerritoryMember> listSTM=[SELECT Id,ServiceResourceId FROM ServiceTerritoryMember 
                                              Where ServiceResourceId =:listSRIds 
                                              and TerritoryType = 'P'
                                              and Id!= :listSTMIds];
        for(ServiceTerritoryMember STM : listSTM){
            if(STM.ServiceResourceId!=null){
                listSRExistAsSTIds.add(STM.ServiceResourceId);
            }
        }
        system.debug('@@listSRExistAsSTIds'+listSRExistAsSTIds);
        for(ServiceTerritoryMember STM : newSTM){
            if(STM.ServiceResourceId!=null && !listSRExistAsSTIds.contains(STM.ServiceResourceId)){
                STM.addError(Label.Primary_Sales_Resource_Error);
            }
            
        }
        
    }
}