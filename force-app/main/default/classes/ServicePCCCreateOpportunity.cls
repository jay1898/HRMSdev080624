@RestResource(urlMapping='/PCCCreateOpportunity/*')
global without sharing class ServicePCCCreateOpportunity {
    public class OpportunityRequest{
        
        public String userLogin;
        public String name;
        public String businessSegment;
        public String customerPartyId;
        public String branchNumber;
        
        // Added for National Account Opportunity
        public String clientType;
        public String marketSegment;
        public String OrderType;
        public String clientName;
        
    }
    
    global class OpportunityResponse {
        public String spokerecid;
        public String status; 
        public String httpStatusCode;
        public String errorMessage ;
        
        public String Address1 ;
        public String City ;
        public String State ;
        public String PostalCode ;
        public String Country ;
        public OpportunityResponse()
        {
            status = 'SUCCESS';
            httpStatusCode = '200' ;
        }
    }
    
    
    @HttpPost
    global static OpportunityResponse postData()
    {
        RestRequest reqst = Restcontext.request;
        OpportunityResponse res = new OpportunityResponse();
        RestResponse restRes = RestContext.response;
        restRes.headers.put('Content-Type','application/json');
        restRes.headers.put('Access-Control-Allow-Origin','*');
        String reqBody ;
        
        
        // Check Integration Switch settings, if disabled then go back  
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_Opportunity_Integration__c ) ) return res ;
        // prepare Response
        
        
        
        try{
            OpportunityRequest request;
            reqBody = reqst.requestBody.toString() ;
            // Try to deserialize REQUEST
            try{
                
                request = (OpportunityRequest)JSON.deserialize(reqBody,OpportunityRequest.class);
                
                /*if(String.isEmpty(request.name) || String.isEmpty(request.businessSegment)){
res.status = 'name and businessSegment must not be empty';
res.errorMessage = 'INVALID_DATA:';
res.httpStatusCode = '400';
new ApexDebugLog().createLog(new ApexDebugLog.Error('PostOpportunity','postData',reqBody,'INVALID_DATA','Integration'));
return res;
}*/
                List<Contact> listContact=new List<Contact>();
                List<Account> listAccount=new List<Account>();
                // If National Account Opportunity
                if(request.clientType!=null && !String.isBlank(request.clientType) && request.clientType != '1'){
                    
                    // find account based on the mdmrecId
                    listAccount=[SELECT Id,OwnerId,parent.BillingStreet,parent.BillingCity,parent.BillingState,parent.BillingPostalCode,parent.BillingCountry 
                                 FROM Account where Oracle_Account_Number__c= :request.clientName and Oracle_Account_Number__c!=null and RecordType.DeveloperName='Pro_Lowes' ];
                    
                    
                }else{
                    
                    // Find Account based on the username
                    listContact=[SELECT Id,Account.OwnerId, PCC_UserName__c,AccountId,Account.parent.BillingStreet,Account.parent.BillingCity,Account.parent.BillingState,
                                 Account.parent.BillingPostalCode,Account.parent.BillingCountry FROM Contact Where PCC_UserName__c!=null 
                                 and PCC_UserName__c = :request.userLogin ];
                    listAccount=new List<Account>();
                    if(listContact.size()==0 || listContact[0].AccountId==null){
                        if(!String.isEmpty(request.customerPartyId) ){
                            
                            //Added logic to retrieve owner ID for branch account and stamp it on the Opportunity in line 92
                            //Updated: 11/10/2020
                            listAccount = [SELECT Id,OwnerId,parent.BillingStreet,parent.BillingCity,parent.BillingState,parent.BillingPostalCode,parent.BillingCountry 
                                           FROM Account where parent.mdmrecId__c= :request.customerPartyId and parent.mdmrecId__c!=null and branch__r.T_C_Branch_Number__c=:request.branchNumber];
                            
                            
                            // Added logic to retrieve account based on branch group on 12/11/2020
                            if(listAccount.size()==0){
                                // Get branch Detail
                                List<Branch__c> listBranch=[SELECT ID,T_C_Branch_Number__c,Branch_Family__c FROM Branch__c Where T_C_Branch_Number__c =:request.branchNumber];
                                if(listBranch.size()>0){
                                    // Get Branch Account associated with branch family
                                    listAccount = [SELECT Id,OwnerId,parent.BillingStreet,parent.BillingCity,parent.BillingState,parent.BillingPostalCode,parent.BillingCountry 
                                                   FROM Account where parent.mdmrecId__c= :request.customerPartyId and parent.mdmrecId__c!=null and branch__r.branch_family__c=:listBranch[0].Branch_Family__c];
                                    
                                }
                                
                            }
                            
                        }
                    }
                }
                
                // IF Order Type is Present then will create Order instead of Opportunity
                if(request.OrderType!=null && !String.isBlank(request.OrderType)  && request.OrderType=='NADISPLAY'){
                    if(listAccount.size()==0){
                        listAccount=[SELECT Id,OwnerId,parent.BillingStreet,parent.BillingCity,parent.BillingState,parent.BillingPostalCode,parent.BillingCountry 
                                     FROM Account where id=:Label.Order_PLACEHOLDER_ACCOUNT];
                    }
                    //Get Standard PricebookId
                    ID standardPricrbookId;
                    if(Test.isRunningTest()){
                        standardPricrbookId = Test.getStandardPricebookId();//[SELECT Id, IsStandard, IsArchived, IsActive, Name FROM Pricebook2][0].Id;
                    }
                    else{
                        standardPricrbookId = [SELECT Id, IsStandard, IsArchived, IsActive, Name FROM Pricebook2 WHERE IsStandard=TRUE LIMIT 1 ][0].Id;
                    }
                    
                    Order ord=new Order();
                    ord.Name=(request.Name!=null && request.Name.length()>80)?request.Name.subString(0,80):request.Name;
                    if(listAccount.size()>0){
                        ord.AccountId=listAccount[0].Id;
                        ord.Ownerid=listAccount[0].OwnerId;
                    }
                    ord.Pricebook2Id=standardPricrbookId;
                    ord.status='Draft';
                    ord.EffectiveDate=Date.today();
                    
                    Database.SaveResult saveResult = Database.insert(ord, false);
                    Map<String,Object> resultMap = checkDuplicates(saveResult);
                    
                    if(resultMap.containsKey('ErrorMessage')){
                        res.status = String.valueOf(resultMap.get('ErrorMessage'));
                        res.errorMessage = 'ERROR_ON_ORDER_CREATION:';
                        res.httpStatusCode = '400';
                        new ApexDebugLog().createLog(new ApexDebugLog.Error('PostOpportunity','postData',reqBody,String.valueOf(resultMap.get('ErrorMessage')),'Integration'));
                        return res;
                    }
                    List<SObject> duplicateRecords=(List<Sobject>)resultMap.get('duplicateRecords');
                    if(duplicateRecords.size() > 0 ) 
                    {
                        res.status = 'Duplicate Record found : '+ duplicateRecords[0].Id;
                        res.errorMessage = 'DUPLICATE_ORDER:';
                        res.httpStatusCode = '400';
                        new ApexDebugLog().createLog(new ApexDebugLog.Error('PostOpportunity','postData',reqBody,'Duplicate Record found : '+ duplicateRecords[0].Id,'Integration'));
                        return res;
                    }
                    
                    res.spokerecid=ord.Id;
                    
                    if(listAccount.size()>0){
                        res.Address1 =listAccount[0].Parent.BillingStreet;
                        res.City =listAccount[0].Parent.BillingCity;
                        res.State =listAccount[0].Parent.BillingState;
                        res.PostalCode =listAccount[0].Parent.BillingPostalCode;
                        res.Country =listAccount[0].Parent.BillingCountry;
                    }  
                    
                }else{
                    
                    //Create New Opportunity
                    Opportunity Opp=new Opportunity();
                    opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
                    opp.Name=(request.Name!=null && request.Name.length()>120)?request.Name.subString(0,120):request.Name;
                    //Added logic to retrieve owner ID for branch account and stamp it on the Opportunity 
                    //Updated: 11/10/2020                
                    if(listContact.size()!=0 && listContact[0].AccountId!=null){
                        opp.AccountId=listContact[0].AccountId;
                        opp.Ownerid=listContact[0].Account.OwnerId;
                    }else if(listAccount.size()>0){
                        opp.AccountId=listAccount[0].Id;
                        opp.Ownerid=listAccount[0].OwnerId;
                    }
                    opp.CloseDate=Date.today().addDays(49);
                    if(String.isBlank(request.marketSegment))
                        opp.market_segment__C = 'SP: Single Family Replacement';
                    else
                        opp.market_segment__C = request.marketSegment;
                    opp.Is_Created_Using_PCC__c=true;
                    opp.Type='Trade';
                    opp.StageName='Proposal';
                    /*if(String.isNotBlank(request.businessSegment)){
opp.type=request.businessSegment.equalsIgnoreCase('Retail')?'Replacement':request.businessSegment;
}*/
                    
                    if(request.clientType!=null && !String.isBlank(request.clientType) && request.clientType != '1'){
                        opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Pro_Lowes').getRecordTypeId();
                        If(request.clientType=='4'){
                           opp.Type = 'Lowe\'s';
                           opp.Market_Segment__c= 'S1C: Single Family New 3000-3999 sq. ft.';
                           opp.CloseDate=Date.today().addDays(180);
                        }Else If (request.clientType=='2'){
                           opp.Type = 'Prodealer';
                           opp.Market_Segment__c= 'NR: Non-Residential New';
                           opp.CloseDate=Date.valueOf('2100-01-01'); 
                        }
                        //opp.Market_Segment__c=(request.marketSegment==null || String.isBlank(request.marketSegment))?'S1C: Single Family New 3000-3999 sq. ft.':request.marketSegment;   
                        
                    }
                    
                    
                    Database.SaveResult saveResult = Database.insert(opp, false);
                    Map<String,Object> resultMap = checkDuplicates(saveResult);
                    
                    if(resultMap.containsKey('ErrorMessage')){
                        res.status = String.valueOf(resultMap.get('ErrorMessage'));
                        res.errorMessage = 'ERROR_ON_OPPORTUNITY_CREATION:';
                        res.httpStatusCode = '400';
                        new ApexDebugLog().createLog(new ApexDebugLog.Error('PostOpportunity','postData',reqBody,String.valueOf(resultMap.get('ErrorMessage')),'Integration'));
                        return res;
                    }
                    List<SObject> duplicateRecords=(List<Sobject>)resultMap.get('duplicateRecords');
                    if(duplicateRecords.size() > 0 ) 
                    {
                        res.status = 'Duplicate Record found : '+ duplicateRecords[0].Id;
                        res.errorMessage = 'DUPLICATE_OPPORTUNITY:';
                        res.httpStatusCode = '400';
                        new ApexDebugLog().createLog(new ApexDebugLog.Error('PostOpportunity','postData',reqBody,'Duplicate Record found : '+ duplicateRecords[0].Id,'Integration'));
                        return res;
                    }
                    
                    res.spokerecid=opp.Id;
                    
                    if(listContact.size()>0){
                        // Create Opp and contact role
                        OpportunityContactRole OppConRole=new OpportunityContactRole();
                        OppConRole.ContactId=listContact[0].Id;
                        OppConRole.OpportunityId=opp.Id;
                        OppConRole.Role='Pella Certified Contractor';
                        insert OppConRole;
                    }
                    if(listContact.size()!=0 && listContact[0].AccountId!=null){
                        res.Address1 =listContact[0].Account.Parent.BillingStreet;
                        res.City =listContact[0].Account.Parent.BillingCity;
                        res.State =listContact[0].Account.Parent.BillingState;
                        res.PostalCode =listContact[0].Account.Parent.BillingPostalCode;
                        res.Country =listContact[0].Account.Parent.BillingCountry;
                    }else if(listAccount.size()>0){
                        res.Address1 =listAccount[0].Parent.BillingStreet;
                        res.City =listAccount[0].Parent.BillingCity;
                        res.State =listAccount[0].Parent.BillingState;
                        res.PostalCode =listAccount[0].Parent.BillingPostalCode;
                        res.Country =listAccount[0].Parent.BillingCountry;
                    }     
                }
                
            }catch (Exception e){
                system.debug('@@'+e);
                res.status = e.getMessage();
                res.errorMessage = 'INVALID_INPUT_FORMAT:';
                res.httpStatusCode = '400';
                new ApexDebugLog().createLog(new ApexDebugLog.Error('PostOpportunity','postData',reqBody,e,'Integration'));
                return res;
            }
            
            // Information Log Added
            new ApexDebugLog().createLog(new ApexDebugLog.Information('PostOpportunity','postData',JSON.serialize(res),reqBody,'Integration'));
            
        }
        catch(Exception ex){
            System.debug('UAC: exception ' + ex.getMessage() );
            new ApexDebugLog().createLog(new ApexDebugLog.Error('PostOpportunity','postData',reqst.requestBody.toString(),ex,'Integration'));
        }
        
        
        return res;
    }
    
    public static Map<String,Object> checkDuplicates(Database.SaveResult saveResult)
    {
        Map<String,Object> resultMap=new Map<String,Object>();
        List<SObject> duplicateRecords = new List<SObject>();
        if(!saveResult.isSuccess())
        {
            for(Database.Error error : saveResult.getErrors()) 
            {
                
                // If there are duplicates, an error occurs Process only duplicates and not other errors (e.g., validation errors)
                if(error instanceof Database.DuplicateError) 
                {
                    // Handle the duplicate error by first casting it as a DuplicateError class This lets you use methods of that class (e.g., getDuplicateResult())
                    Database.DuplicateError duplicateError = (Database.DuplicateError)error;
                    Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                    
                    // Return only match results of matching rules that find duplicate records
                    Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                    
                    // Just grab first match result (which contains the duplicate record found and other match info)
                    Datacloud.MatchResult matchResult = matchResults[0];
                    Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                    
                    // Add matched record to the duplicate records variable
                    for(Datacloud.MatchRecord matchRecord : matchRecords) 
                    {
                        //System.debug('MatchRecord: ' + matchRecord.getRecord());
                        duplicateRecords.add(matchRecord.getRecord());
                    }
                }
                else
                {
                    resultMap.put('ErrorMessage',error.getMessage() );
                    System.debug('UAC: error message ' + error.getMessage() );
                }
            }
        }
        resultMap.put('duplicateRecords',duplicateRecords);
        return resultMap ;
    }
}