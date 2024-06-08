@isTest
private class LookupSearchResultTest {

    @isTest
    static void testLookupSearchResultSerialization() {
        // Create a LookupSearchResult instance
        Id testId = '001000000000000AAA';
        String testSObjectType = 'Account';
        String testIcon = '/img/icon/accountIcon.png';
        String testTitle = 'Test Account';
        String testSubtitle = '123 Main St, Anytown, USA';

        LookupSearchResult result = new LookupSearchResult(
            testId,
            testSObjectType,
            testIcon,
            testTitle,
            testSubtitle
        );

        // Serialize the instance to JSON
        String serializedResult = JSON.serialize(result);

        // Deserialize the JSON back to LookupSearchResult
        LookupSearchResult deserializedResult = (LookupSearchResult) JSON.deserialize(serializedResult, LookupSearchResult.class);

        // Verify deserialized result matches original result
        System.assertEquals(result.getId(), deserializedResult.getId(), 'Id should match');
        System.assertEquals(result.getSObjectType(), deserializedResult.getSObjectType(), 'SObjectType should match');
        System.assertEquals(result.getIcon(), deserializedResult.getIcon(), 'Icon should match');
        System.assertEquals(result.getTitle(), deserializedResult.getTitle(), 'Title should match');
        System.assertEquals(result.getSubtitle(), deserializedResult.getSubtitle(), 'Subtitle should match');
    }

    // Add more test methods as needed for edge cases or additional scenarios
}