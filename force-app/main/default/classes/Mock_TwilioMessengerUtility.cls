@isTest
public class Mock_TwilioMessengerUtility {
    private Mock_TwilioMessengerUtility(){}

    public static Mock_TwilioMessengerProvider getInstance() {
        return new Mock_TwilioMessengerProvider();
    }
    
     public static Object createMock(Type typeToMock) {
        // Invoke the stub API and pass it our mock provider to create a 
        // mock class of typeToMock.
        System.debug('Creating Method Stub');
        return Test.createStub(typeToMock, Mock_TwilioMessengerUtility.getInstance());
    }
}