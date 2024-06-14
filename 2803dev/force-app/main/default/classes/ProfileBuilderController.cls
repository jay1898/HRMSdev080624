public class ProfileBuilderController {
    /*public String selectedEmployeeId { get; set; }
public Boolean showNextButton { get; set; }
public Boolean showNextSection { get; set; }

public List<SelectOption> getEmployeeOptions() {
List<Employee__c> employees = getEmployeeNames();
List<SelectOption> options = new List<SelectOption>();

for (Employee__c emp : employees) {
options.add(new SelectOption(emp.Id, emp.Name));
}

return options;
}

public void loadEmployeeData() {
showNextButton = true;
}

public void proceedToNextSection() {
showNextSection = true;
}*/
    /*
public Profile_Builder__c profileBuilder { get; set; }
public ProfileBuilderController(ApexPages.StandardController stdController) {
// Query Profile_Builder__c records
this.profileBuilder = (Profile_Builder__c)stdController.getRecord();
this.profileBuilder = [select Id, Name, PROFESSIONAL_SUMMARY__c, Employee__c, Name__c from Profile_Builder__c WHERE Id = :stdController.getId()];
System.debug('this.profileBuilder '+ this.profileBuilder);
}*/
    
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
    }
    
    @AuraEnabled
    public static List<Employee__c> getEmployeeNames() {
        return [SELECT Id, Name, First_Name__c, Last_Name__c, Email__c, Phone__c FROM Employee__c ORDER BY Name ASC];
    }
}