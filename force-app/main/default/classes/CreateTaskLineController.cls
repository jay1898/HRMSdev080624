/**
* @description       : CreateTaskLineController class Used to create work order(s)
* @author            : Balaji Ravindran | mailto:ravindramb@evergegroup.com
* History   
* Ver   Date         Author            Modification
* 1.0   29-05-2023   Balaji Ravindran  Initial Version()
**/
public class CreateTaskLineController {
    
    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 29-05-2023
    *   Purpose         : This method will insert the Product Serviced record type Case Line records.
    *   Input Param     : String caseId   - Current Case record page Id from LWC.
    *                     String recordMapValue - selected Product Search row from Product Search Warranty component.
    *   Output Param    : List of inserted Case_Line__c records.
    */
    @AuraEnabled
    public static List<Case_Line__c> createCaseLine(String caseId, String recordMapValue){
            Case cs = [Select Id, AssignedBranch__c from Case Where Id =: caseId];
            List<ProductSearchTableResponse> rowValueMap = (List<ProductSearchTableResponse>) JSON.deserialize(recordMapValue, List<ProductSearchTableResponse>.class);

            List<Case_Line__c> caseLineList = new List<Case_Line__c>();

            for(ProductSearchTableResponse recMap : rowValueMap){

                Case_Line__c caseLine = new Case_Line__c();
                caseLine.Case__c = caseId;
                caseLine.Branch__c = cs.AssignedBranch__c;
                caseLine.Brand__c = recMap.brand.value;
                caseLine.Description__c = recMap.description.value;
                caseLine.Component__c = recMap.selectedComponent;
                caseLine.Product__c = recMap.product.value;
                caseLine.RecordTypeId = Schema.SObjectType.Case_Line__c.getRecordTypeInfosByName().get('Product Serviced').getRecordTypeId(); 
                //caseLine.Task_Billing_Method__c = 'Bill by Task Labor';
                caseLine.Issue__c = recMap.selectedIssue;
                caseLineList.add(caseLine);
            }
         try {
            if(caseLineList.size() > 0) {
                insert caseLineList;
                List<Warranty__c> warrantyList  = new List<Warranty__c>();
                Integer index = 0;
                for(Case_Line__c caseLineObj : caseLineList) {

                    if(rowValueMap[index].warranties != null && rowValueMap[index].warranties.value != null && !rowValueMap[index].warranties.value.isEmpty()) {
                        for(ProductSearchTableResponse.cls_value warrantyObj : rowValueMap[index].warranties.value) {
                            Warranty__c warranty             = new Warranty__c();
                            warranty.Case_Line__c            = caseLineObj.Id;
                            warranty.Case__c                 = caseLineObj.Case__c;
                            warranty.Coverage_Description__c = warrantyObj.isTransferable != null && warrantyObj.isTransferable == true ? 'Material Transferable' : 'Material Non Transferable';
                            warranty.Customer_Name__c        = warrantyObj.customerName;
                            if(!String.isBlank(warrantyObj.endDate))
                            warranty.End_Date__c             = Date.valueOf(warrantyObj.endDate);
                            if(!String.isBlank(warrantyObj.startDate))
                            warranty.Start_Date__c           = Date.valueOf(warrantyObj.startDate); 
                            warranty.Status__c               = warrantyObj.status;
                            warranty.Legacy_Id__c            = warrantyObj.externalId;
                            warranty.Warranty_Number__c		 = warrantyObj.id;
                            String address                   = '';
                            if(warrantyObj.contractAddress != null ) {
                                if(warrantyObj.contractAddress.address1 != null) address +=warrantyObj.contractAddress.address1 + ' ';
                                if(warrantyObj.contractAddress.address2 != null) address += warrantyObj.contractAddress.address2 + ' ';
                                if(warrantyObj.contractAddress.city != null) address += warrantyObj.contractAddress.city + ' ';
                                if(warrantyObj.contractAddress.state != null) address += warrantyObj.contractAddress.state + ' ';
                                if(warrantyObj.contractAddress.postalCode != null) address += warrantyObj.contractAddress.postalCode + ' ';
                                if(warrantyObj.contractAddress.country != null) address += warrantyObj.contractAddress.country + ' ';
                                warranty.Address__c           = address;
                            }                            
                            warrantyList.add(warranty);
                        }                        
                    }
                    index++;
                }
                if(!warrantyList.isEmpty()) insert warrantyList;
                return [Select Id, Name, Branch__c, Brand__c, Description__c, Component__c, Product__c, Issue__c from Case_Line__c Where id =: caseLineList];
            }

            return new List<Case_Line__c>();

       } catch (Exception e) {
           System.debug(e.getLineNumber());
            new ApexDebugLog().createLog(new ApexDebugLog.Error('CreateTaskLineController','createWorkOrder',caseId, e,'LWC Controller'));
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 27th July 2023
    *   Purpose         : This method will insert the Labor record type Case Line records
    *   Input Param     : String caseId   - Current Case record page Id from LWC.
    *                     String recordMapValue - selected the Labor type case line records from Create Task Line component.
                          String caseLineString - already inserted product service record type case line records are parents for labor case line records
    *   Output Param    : List of inserted the Labor Case_Line__c records.
    */
    @AuraEnabled
    public static List<Case_Line__c> createLaborCaseLine(String caseId, String recordMapValue, String caseLineString){
            Integer count=0;
            List<Case_Line__c> insertedCaseLineList = (List<Case_Line__c>) JSON.deserialize(caseLineString, List<Case_Line__c>.class);

            List<ProductSearchTableResponse> rowValueMap = (List<ProductSearchTableResponse>) JSON.deserialize(recordMapValue, List<ProductSearchTableResponse>.class);

            List<Case_Line__c> caseLineList = new List<Case_Line__c>();

            for(ProductSearchTableResponse recMap : rowValueMap){

                Case_Line__c caseLine = new Case_Line__c();
                caseLine.Case__c = caseId;
                caseLine.Branch__c = insertedCaseLineList[count].Branch__c;
                caseLine.Product_Serviced__c = insertedCaseLineList[count].Id;
                caseLine.Task_Type__c = recMap.taskType;
                if(recMap.secondTechMultiplier != null){ 
                caseLine.Second_Tech_Multiplier__c = recMap.secondTechMultiplier;
                }
                caseLine.Service_Action__c = recMap.serviceAction;
                if(recMap.quantity != null){ 
                caseLine.Quantity__c = Decimal.valueOf(recMap.quantity.value);
                }
                caseLine.RecordTypeId = Schema.SObjectType.Case_Line__c.getRecordTypeInfosByName().get('Labor').getRecordTypeId(); 
                caseLineList.add(caseLine);
                count++;
            }

        try {
            if(caseLineList.size() > 0) {
                insert caseLineList;
                List<Warranty__c> warrantyList  = new List<Warranty__c>();
                Integer index = 0;
                for(Case_Line__c caseLineObj : caseLineList) {
                    if(rowValueMap[index].warranties != null && !rowValueMap[index].warranties.value.isEmpty()) {
                        for(ProductSearchTableResponse.cls_value warrantyObj : rowValueMap[index].warranties.value) {
                            Warranty__c warranty             = new Warranty__c();
                            warranty.Case_Line__c            = caseLineObj.Id;
                            warranty.Case__c                 = caseLineObj.Case__c;
                            warranty.Coverage_Description__c = warrantyObj.isTransferable != null && warrantyObj.isTransferable == true ? 'Material Transferable' : 'Material Non Transferable';
                            warranty.Customer_Name__c        = warrantyObj.customerName;
                            if(!String.isBlank(warrantyObj.endDate))
                            warranty.End_Date__c             = Date.valueOf(warrantyObj.endDate);
                            if(!String.isBlank(warrantyObj.startDate))
                            warranty.Start_Date__c           = Date.valueOf(warrantyObj.startDate); 
                            warranty.Status__c               = warrantyObj.status;
                            warranty.Legacy_Id__c            = warrantyObj.externalId;
                            warranty.Warranty_Number__c		 = warrantyObj.id;
                            String address                   = '';
                            if(warrantyObj.contractAddress != null ) {
                                if(warrantyObj.contractAddress.address1 != null) address +=warrantyObj.contractAddress.address1 + ' ';
                                if(warrantyObj.contractAddress.address2 != null) address += warrantyObj.contractAddress.address2 + ' ';
                                if(warrantyObj.contractAddress.city != null) address += warrantyObj.contractAddress.city + ' ';
                                if(warrantyObj.contractAddress.state != null) address += warrantyObj.contractAddress.state + ' ';
                                if(warrantyObj.contractAddress.postalCode != null) address += warrantyObj.contractAddress.postalCode + ' ';
                                if(warrantyObj.contractAddress.country != null) address += warrantyObj.contractAddress.country + ' ';
                                warranty.Address__c           = address;
                            }                            
                            warrantyList.add(warranty);
                        }                        
                    }
                    index++;
                }
                if(!warrantyList.isEmpty()) insert warrantyList;
                return [Select Id, Name from Case_Line__c Where id =: caseLineList];
            }

            return new List<Case_Line__c>();

        } catch (Exception e) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('CreateTaskLineController','createLaborCaseLine',caseId, e,'LWC Controller'));
            throw new AuraHandledException(e.getMessage());
        } 
    }
}