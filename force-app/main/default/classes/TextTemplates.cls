public with sharing class TextTemplates {
    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getTemplateList() {
        return [ SELECT NAME from EmailTemplate where name like 'Text.%' ];
    }
}