public class ProfileBuilderController {
    /*
    @AuraEnabled(cacheable=true)
    public static string getVFOrigin() {
        String originalURL = URL.getOrgDomainUrl().toExternalForm(); // Expected Format = https://domain.my.salesforce.com
        // Split the original URL to extract organization and sandbox names
        List<String> urlParts = originalURL.split('\\.');
        String[] orgAndSandbox = urlParts[0].split('--');
        
        String organizationName = orgAndSandbox[0];
        String sandboxName = orgAndSandbox[1];
        
        // Construct the transformed URL
        String transformedURL =  organizationName + '--' + sandboxName + '--c.sandbox.vf.force.com';
        
        return transformedURL;
    }
    
    public string lexOrigin {get{ 
        return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';
    } set;}
    
    
    @AuraEnabled
    public static List<Map<String, String>> getRecordIds() {
        List<Profile_Builder_Template__mdt> templates = [SELECT Id, imageUrl__c, Template_Name__c FROM Profile_Builder_Template__mdt];
        List<Map<String, String>> recordIds = new List<Map<String, String>>();
        
        for (Profile_Builder_Template__mdt template : templates) {
            Map<String, String> mdtRec = new Map<String, String>();
            mdtRec.put('Id', template.Id);
            mdtRec.put('imageUrl__c', template.imageUrl__c);
            mdtRec.put('Template_Name__c', template.Template_Name__c);
            recordIds.add(mdtRec);
        }
        System.debug('recordIds : '+recordIds);
        return recordIds;
    }*/
    
    @AuraEnabled
    public static List<Employee__c> getEmployeeNames() {
        return [SELECT Id, Name, First_Name__c, Last_Name__c, Email__c, Phone__c FROM Employee__c ORDER BY Name ASC];
    }
    
    //Fetching values of skill from multiselect picklist
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getSkillsPicklistValues() {
        List<Map<String, String>> picklistValues = new List<Map<String, String>>();
        
        // Get the SObject Describe for Employee__c
        Schema.DescribeSObjectResult objectDescribe = Employee__c.SObjectType.getDescribe();
        
        // Get the field describe for Skills__c
        Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get('Skills__c').getDescribe();
        
        // Ensure the field is a multi-select picklist
        if (fieldDescribe.isAccessible() && fieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST) {
            // Get the picklist values
            List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
            system.debug('picklistEntries---->'+picklistEntries);
            // Iterate through picklist values
            for(Schema.PicklistEntry entry : picklistEntries) {
                Map<String, String> picklistValueMap = new Map<String, String>();
                picklistValueMap.put('label', entry.getLabel());
                picklistValueMap.put('value', entry.getValue());
                picklistValues.add(picklistValueMap);
                system.debug('picklistValues------>'+picklistValues);
                system.debug('picklistValueMap------>'+picklistValueMap);
            }
        }
        return picklistValues;
    }

    //Inserting Experience by creating record
    @AuraEnabled
    public static Experience__c saveExperience(String employer, String jobTitle, Date startDate, Date endDate, String description, string employeeId, String experienceId) {
        if(String.isBlank(employer) || String.isBlank(jobTitle) || startDate == null || endDate == null || String.isBlank(description) || String.isBlank(employeeId)) {
            //return null;
            throw new AuraHandledException('All fields are required');
        }
        
        Experience__c exp;
        if (String.isNotBlank(experienceId)) {
            system.debug('experienceId------>'+experienceId);
            // Update existing record
            List<Experience__c> expList = [SELECT Id FROM Experience__c WHERE Id = :experienceId LIMIT 1];// AND Employee__c = :(Id)employeeId
            system.debug('expList------>'+expList);
            if (!expList.isEmpty()) {
                exp = expList[0];
                system.debug('expList[0]------>'+expList[0]);
                exp.Name = employer;
                exp.Job_Title__c = jobTitle;
                exp.Start_Date__c = startDate;
                exp.End_Date__c = endDate;
                exp.Description__c = description;
                system.debug('employeeId------>'+(Id)employeeId);
                system.debug('Updated------>');
            } else {
                //return null;
                throw new AuraHandledException('No record found with the provided ID');
            }
        } else {
            // Insert new record
            exp = new Experience__c();
            exp.Name = employer;
            exp.Job_Title__c = jobTitle;
            exp.Start_Date__c = startDate;
            exp.End_Date__c = endDate;
            exp.Description__c = description;
            exp.Employee__c = (Id)employeeId;
            system.debug('Inserted------>');
        }
        
        try {
            upsert exp;
            return exp;
        } catch (Exception e) {
            System.debug('DML Exception'+e);
            return null;
            // Handle exception
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<HelpText__c> getHelpTextSummary(String inputStr){
        System.debug('inputStr: ' + inputStr);

        List<HelpText__c> helpTextList = [SELECT Id, Instructions__c, IsActive__c, Type__c FROM HelpText__c WHERE  Type__c = 'Summary' AND IsActive__c = true ];
        System.debug('helpTextList@@@@'+helpTextList);

        if(String.isBlank(inputStr) || inputStr == null ){
            return helpTextList;
        }

        List<HelpText__c> resultToReturn = new List<HelpText__c>();
        if(!helpTextList.isEmpty()){
            for(HelpText__c ht :helpTextList){
                if(ht.Instructions__c.containsIgnoreCase(inputStr)){
                    resultToReturn.add(ht);
                    System.debug('Including this text: ' + ht.Instructions__c);
                } else { 
                    System.debug('Skipping this HT>... ' + ht);
                }
            }
            System.debug('resultToReturn.. ' + resultToReturn);
        }
        return resultToReturn.size() > 0 ? resultToReturn : helpTextList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<HelpText__c> getHelpTextExperience(String inputStr){
        System.debug('inputStr: ' + inputStr);

        List<HelpText__c> helpTextList = [SELECT Id, Instructions__c, IsActive__c, Type__c FROM HelpText__c WHERE  Type__c = 'Experience' AND IsActive__c = true ];
        System.debug('helpTextList@@@@'+helpTextList);

        if(String.isBlank(inputStr) || inputStr == null ){
            return helpTextList;
        }

        List<HelpText__c> resultToReturn = new List<HelpText__c>();
        if(!helpTextList.isEmpty()){
            for(HelpText__c ht :helpTextList){
                if(ht.Instructions__c.containsIgnoreCase(inputStr)){
                    resultToReturn.add(ht);
                    System.debug('Including this text: ' + ht.Instructions__c);
                } else { 
                    System.debug('Skipping this HT>... ' + ht);
                }
            }
            System.debug('resultToReturn.. ' + resultToReturn);
        }
        return resultToReturn.size() > 0 ? resultToReturn : helpTextList;
    }
    
    @Auraenabled
    public static void updateEmployeeRecord(string wrapperText){
        //system.debug('wrapperText@@@@@'+wrapperText);
        Employee__c empRec = (Employee__c)JSON.deserialize(wrapperText, Employee__c.class);
        //system.debug('empRec@@@@@'+empRec);
        update empRec;
        //System.debug('Emp Record Updated Successfully');
    }


    @AuraEnabled
    public static List<Experience__c> getListOfExperience(String id){
      List<Experience__c> experienceList = [SELECT Id,Employee__c,Name,Job_Title__c,Start_Date__c,	End_Date__c,Description__c  FROM Experience__c WHERE Employee__c = :id ORDER BY End_Date__c DESC];
      
      return experienceList;
    }
}