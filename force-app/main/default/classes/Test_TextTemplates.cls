@isTest
private class Test_TextTemplates {
    @isTest
    static void testSingleTemplate() {
        EmailTemplate template = new EmailTemplate();
        template.isActive = true;
        template.Name = 'Text.something'; // required pattern is Text.%
        template.DeveloperName = 'test_template_TextTemplates';
        template.TemplateType = 'text';
        template.FolderId = UserInfo.getUserId();
        insert template;

        EmailTemplate ignoreTemplate = new EmailTemplate();
        ignoreTemplate.Name = 'SMS.something';
        ignoreTemplate.DeveloperName = 'test_template_TextTemplates_ignore';
        ignoreTemplate.TemplateType = 'text';
        ignoreTemplate.FolderId = UserInfo.getUserId();
        insert ignoreTemplate;

        Test.startTest();
        List<EmailTemplate> foundTemplates = TextTemplates.getTemplateList();
        Test.stopTest();

        System.assertEquals(foundTemplates.size(), 1, 'Inserting only 1 template record (with name Text.%) did not yield exactly 1 result');

        EmailTemplate foundTemplate = foundTemplates[0];
        System.assertEquals(foundTemplate.Id, template.Id, 'ID of inserted template did not match');
    }
}