@isTest
public class Mock_TwilioMessengerProvider implements System.StubProvider {
    public Object handleMethodCall(Object stubbedObject, String stubbedMethodName,
            Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames,
            List<Object> listOfArgs) {
        System.debug('Name of stubbed method: ' + stubbedMethodName);
        System.debug('Return type of stubbed method: ' + returnType.getName());
        
        for(integer i = 0; i < listOfParamNames.size(); i++) {
            System.debug('parameter name: ' + listOfParamNames.get(i));
            System.debug('  parameter type: ' + listOfParamTypes.get(i).getName());
        }
        
        // This shows the actual parameter values passed into the stubbed method at runtime.
        System.debug('number of parameters passed into the mocked call: ' + 
            listOfArgs.size());
        System.debug('parameter(s) sent into the mocked call: ' + listOfArgs);
        
        switch on (stubbedMethodName) {
            when 'sendNonFutureSms' {
                System.debug('sendNonFutureSms Called');
                return null;
            }
            when 'sendSms' {
                System.debug('sendSms Called');
                return null;
            }
            when 'createMessage' {
                System.debug('Create Message Called');
                return null;
            }
            when 'getLastOutboundMessage' {
                System.debug('Get Last Outbound Message Called');
                TwilioMessage__c msg = new TwilioMessage__c();
                msg.Direction__c = 'Outbound';
                msg.Topic__c = 'Ad_hoc';
                msg.MessageBody__c = 'Outbound Body';
                msg.Phone__c = '+18005551234';
                msg.Status__c = 'Success';
                return msg;
            }
            when 'getTopicFromSender' {
                return 'Ad_hoc';
            }
            when else {
                return null;
            }
        }
    }


}