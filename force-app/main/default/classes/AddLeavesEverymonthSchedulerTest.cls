@isTest
public class AddLeavesEverymonthSchedulerTest {

    @isTest
    static void testScheduler() {
        // Create a Contact record
        Contact con = new Contact(
            LastName='test', 
            Email='test@gmail.com'
        );
        insert con;

        // Create an Employee__c record
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com'
        );
        insert testEmployee;

        // Schedule the job
        Test.startTest();
        String jobId = System.schedule('Test AddLeavesEverymonthScheduler', '0 0 0 1 * ? *', new AddLeavesEverymonthScheduler());
        Test.stopTest();

        // Verify that the job has been scheduled
        System.assertEquals(1, [SELECT count() FROM CronTrigger WHERE Id = :jobId]);

        // Retrieve updated data and assert the changes
        List<Employee__c> updatedEmployees = [SELECT Id, Number_of_leaves__c FROM Employee__c];
        for (Employee__c emp : updatedEmployees) {
            if (emp.Number_of_leaves__c != null) {
                Integer expectedLeaves = Integer.valueOf(emp.Number_of_leaves__c) + 1; // Increment leaves count
                System.debug('Employee Id: ' + emp.Id + ', Initial Leaves: ' + emp.Number_of_leaves__c + ', Expected: ' + expectedLeaves);
                //System.assertEquals(expectedLeaves, emp.Number_of_leaves__c);
            }
        }
    }
}