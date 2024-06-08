/**
 * @Name         TwilioSmsFlowActions 
 * @Author       Pella/Terazo
 * @Description  This class is used with Flows to send an SMS.  
 *
 *
 *	Version		Developer		Date		Comments
 *-------------------------------------------------------------------------------------------
 *  	1.0			Pella/Terazo	04/04/2022	Created   
 */
public class TwilioSmsFlowActions {
    
    public class TwilioSmsFlowInput {
        @InvocableVariable public String toNum;
        @InvocableVariable public String message;
        @InvocableVariable public String topic;
        @InvocableVariable public Id recordId;
        @InvocableVariable public Id branchId;
    }
    
    @InvocableMethod(label='Twilio Send SMS' description='Twilio Send an SMS to user' category='Twilio')
    public static void sendSms(List<TwilioSmsFlowInput> twilioSmsFlowInputList) {
        for(TwilioSmsFlowInput twilioSmsFlowInput : twilioSmsFlowInputList){
            
            TwilioMessenger.SendSmsParams smsParams = new TwilioMessenger.SendSmsParams();
            smsParams.branchId = twilioSmsFlowInput.branchId;
            smsParams.message = twilioSmsFlowInput.message;
            smsParams.recordId = twilioSmsFlowInput.recordId;
            smsParams.toNum = twilioSmsFlowInput.toNum;
            smsParams.topic = twilioSmsFlowInput.topic;
            
            if (System.isFuture() || System.isBatch()) {
                //can't chain future methods together but CAN use callout/write if already in a future context
                //TODO: Verify that batch methods also can use the non-future method
                TwilioMessenger.sendNonFutureSms(smsParams); 
            } else {
                TwilioMessenger.sendSms(smsParams);
            }
        }
    }
}