@isTest
public class GraphqlRequestTest {
    public class testQueryInput {
        public String testValue;
    }
    
    public static testMethod void generateGraphqlRequestBodyTest() {
       	String expectedString = '{"variables":{"testValue":"testing"},"query":"query testQuery($input: TestInput!) { testQuery (input: $input) { outputOne outputTwo }}","operationName":"testOperation"}';
        String query = 'query testQuery($input: TestInput!) { testQuery (input: $input) { outputOne outputTwo }}';
        String operationName = 'testOperation';
        testQueryInput variables = new testQueryInput();
        variables.testValue = 'testing';
        
        String results = GraphqlRequest.generateGraphqlRequestBody(query, operationName, variables);

        System.assertEquals(expectedString, results);        
    }
}