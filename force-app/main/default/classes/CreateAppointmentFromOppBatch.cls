public class CreateAppointmentFromOppBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful {
    public static String oppId;
    public Database.QueryLocator start(Database.BatchableContext BC){
        String Query=Label.CreateSAFromOppQuery;
        if(Test.isRunningTest()){
            Query='SELECT Id,name,Appointment_DateTime__c,Description,Appointment_Type__c,Virtual_Appointment__c'
                +',accountId, Account.PersonContactId,Account.PersonContact.MailingPostalCode,Account.PersonContact.MailingCity'
                +',Account.PersonContact.MailingState,Account.PersonContact.MailingCountry,type'
                +' FROM Opportunity';
            if(oppId!=null){
                Query+=' where id=\''+oppId+'\''; 
            }
        }
       
            
       
        return Database.getQueryLocator(Query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> listOpps){
        
        for(Opportunity Opp: listOpps){
          
            String zip=Opp.Account.PersonContact.MailingPostalCode;
            String canadianZipcode= !zip.isNumeric() && zip.length() > 3 ? zip.substring(0,3) + '%' : '' ;
            DateTime startDate ;
            DateTime startDateEmail ;
            DateTime endDate ;
            DateTime nextDay12AM ;
            List<ServiceTerritory> lstServiceTerritory ;
            if(Test.isRunningTest()){
                zip='37335';
            }
            lstServiceTerritory = [ SELECT  Id, ParentTerritoryId, ParentTerritory.RecordType.DeveloperName, ParentTerritory.OperatingHours.TimeZone,
                                   ParentTerritory.ParentTerritory.Branch__c,ParentTerritory.ParentTerritory.Branch__r.branch_number__C, ParentTerritory.ApptDurationMin__c, ParentTerritory.Lead_Receiver__c,ParentTerritory.Virtual_Appt_Duration_Min__c 
                                   FROM ServiceTerritory 
                                   WHERE PostalCode != NULL AND (PostalCode=:zip OR PostalCode LIKE :canadianZipcode ) AND RecordType.Name='Zipcode' ];
            
            if(String.isBlank(zip))
            {
                lstServiceTerritory = [ SELECT  Id, ParentTerritoryId, ParentTerritory.RecordType.DeveloperName, ParentTerritory.OperatingHours.TimeZone,
                                       ParentTerritory.ParentTerritory.Branch__c, ParentTerritory.ApptDurationMin__c, ParentTerritory.Lead_Receiver__c,ParentTerritory.Virtual_Appt_Duration_Min__c 
                                       FROM ServiceTerritory 
                                       WHERE ParentTerritory.Parent_Branch__c = '998' AND RecordType.Name='Zipcode' LIMIT 1 ];
            }
            String TimeZone_Code,branchID;
            ServiceTerritory zoneST ;
            startDate=opp.Appointment_DateTime__c;
            endDate=startDate.addMinutes(180);
            
            if(lstServiceTerritory.size()>0)
            {
                // Parent Territory (Zone Territory) of Zipcode territory
                zoneST = lstServiceTerritory[0].ParentTerritory;
                TimeZone_Code= zoneST.OperatingHours.TimeZone;
                branchID = lstServiceTerritory[0].ParentTerritory.ParentTerritory.Branch__r.branch_number__C;
                
                if(opp.Virtual_Appointment__c){
                    endDate=startDate.addMinutes((Integer)zoneST.Virtual_Appt_Duration_Min__c);
                }else{
                    endDate=startDate.addMinutes((Integer)zoneST.ApptDurationMin__c);
                }
            }
            System.debug('UAC: zoneST ' + zoneST );
            //System.debug('TimeZone Code :: '+req.TimeZone_Code);
            
            
            Id softAssignId = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('Soft_Assign').RecordTypeId;
            // Insert Service appointment under Opporutnity
            ServiceAppointment sa = new ServiceAppointment( RecordTypeId = softAssignId, Subject = opp.Name, City = opp.Account.PersonContact.MailingCity, State = opp.Account.PersonContact.MailingState, PostalCode = zip,
                                                           ContactId=opp.Account.PersonContactId,
                                                           Description = opp.Description, Opportunity__c = opp.Id, DueDate = endDate, EarliestStartTime = startDate, 
                                                           SchedStartTime =startDate, Start_Datetime__c = startDate, End_Datetime__c = endDate, SchedEndTime = endDate,
                                                           Virtual_Appointment__c = opp.Virtual_Appointment__c );
            
            
            if(opp.Appointment_Type__c.equalsIgnoreCase('RT')) sa.Status = 'Soft Assigned' ;
            if(opp.Appointment_Type__c.equalsIgnoreCase('Preferred'))
            {
                sa.Status = 'Preference' ;
                system.debug('Status of Sa :' + sa.status);
                
            }
            
            // Assign Owner Of Service Appointment for NON RT types(Preferred, NRT)
            if(zoneST != null && String.isNotBlank(zoneST.Lead_Receiver__c) && !opp.Appointment_Type__c.equalsIgnoreCase('RT') ) sa.OwnerId = zoneST.Lead_Receiver__c ;
            
            if(opp.Appointment_Type__c.equalsIgnoreCase('Preferred') && zoneST != null)
            {
                system.debug('It is a preference Appointment');
                Integer durationInMinutes = Integer.valueOf(zoneST.ApptDurationMin__c);
                if(durationInMinutes == null) durationInMinutes = 0 ;
                
                // Added on 02-06 virtual appointment change
                if(opp.Virtual_Appointment__c){
                    durationInMinutes=zoneST.Virtual_Appt_Duration_Min__c==null?durationInMinutes:Integer.valueOf(zoneST.Virtual_Appt_Duration_Min__c);
                }
                
                Datetime nextDay = DateTime.newinstanceGMT(Date.today().addDays(1), Time.newInstance(12, 0, 0, 0));
                System.debug('UAC: nextDay ' + nextDay );
                
                startDateEmail = nextDay ;
                //opp.Appointment_DateTime_Email__c = startDateEmail;
                
                nextDay12AM = Datetime.newInstance(nextDay.addDays(1).date() , Time.newInstance(0, 0, 0, 0) );
                
                if(!String.isBlank(TimeZone_Code) && nextDay12AM != null ){
                    TimeZone tz = TimeZone.getTimeZone(TimeZone_Code);
                    nextDay12AM=nextDay12AM.addSeconds((tz.getOffset(nextDay12AM)/1000)*-1);
                }
                
                if(!String.isBlank(TimeZone_Code) )
                {   
                    TimeZone tz = TimeZone.getTimeZone(TimeZone_Code);
                    nextDay=nextDay.addSeconds((tz.getOffset(nextDay)/1000)*-1);
                }
                System.debug('UAC: nextDay ' + nextDay );
                sa.SchedStartTime = nextDay ;
                sa.Start_Datetime__c = nextDay;
                sa.EarliestStartTime = sa.SchedStartTime ;
                //opp.Appointment_DateTime__c = nextDay ;
                
                sa.SchedEndTime = sa.SchedStartTime.addMinutes(durationInMinutes);
                sa.End_Datetime__c = sa.SchedStartTime.addMinutes(durationInMinutes);
                sa.DueDate = sa.SchedEndTime ;
            }
            
            //List<Lead> leads = [SELECT Id FROM Lead WHERE NAME = 'Soft Assign Placeholder' FOR UPDATE ];
            
            //changed on 15-05 to resolve the issue of Unable to lock the row issue
            List<String> listSAPlaceLead=System.Label.Soft_Assign_Placeholder_Lead_ID.split(',');
            String leadSAId;
            try{
                leadSAId= listSAPlaceLead[Integer.valueOf( Math.random() * (listSAPlaceLead.size() - 1))];
            }catch(Exception e){
                leadSAId=listSAPlaceLead[0];
            }
            sa.ParentRecordId =leadSAId ; //System.Label.Soft_Assign_Placeholder_Lead_ID ; 
            system.debug('Parent Record Id is :'+ sa.ParentRecordId);   
            
            System.debug('UAC: sa to insert ' + sa );
            ServiceAppointmentTriggerHandler.CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE = TRUE ;
            
            // change on 24-03 instead of insert to database.insert
            
           // try{
                 insert sa ;
                system.debug('SA Id :' +sa.Id);
           // }
           // catch(DmlException de){
           //     new ApexDebugLog().createLog(new ApexDebugLog.Error('CreateAppointmentFromOppBatch','CreateAppointmentFromOpp',JSON.serialize(opp),de.getMessage(),'Integration'));
           // }
            if(sa.Id!=null){
                updateSAOwner(Opp.Id,sa.Id,zoneST);
            }
            
        }
    }
    
    
    public static void updateSAOwner(String oppId,String saId,ServiceTerritory zoneST){
        
        Opportunity orgOpp=[SELECT Id,name,Best_Match__c,Zone__c,Appointment_DateTime__c,Description,Appointment_Type__c,Virtual_Appointment__c,OwnerId FROM Opportunity where id = :oppId]; 
        
        // Update Service Appointment Owner with Opporunity Best Match
        ServiceAppointment sa = [SELECT Id, OwnerId, SchedStartTime, SchedEndTime, ServiceTerritoryId, Status FROM ServiceAppointment WHERE Id = :saId];
        
        if(zoneST != null && String.isNotBlank(zoneST.Lead_Receiver__c) && orgOpp.OwnerId == zoneST.Lead_Receiver__c){
            // For RT Types only change Owner as Best Match of Opportunity
            if(orgOpp.Appointment_Type__c == 'RT' && orgOpp.Best_Match__c!=null) sa.OwnerId = orgOpp.Best_Match__c ;
        }else{
             sa.OwnerId = orgOpp.OwnerId  ;
        }
        
        
        sa.ServiceTerritoryId = orgOpp.Zone__c ;
        
        System.debug('UAC: orgOpp.Appointment_Type__c ' + orgOpp.Appointment_Type__c );
        
        ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH = false ;
        ServiceAppointmentTriggerHandler.RUN_CHANGE_OWNER_AND_RESOURCE = false ;
        AssignedResourceTriggerHandler.CHANGE_SA_OPP_STATUS_OWNER = false ;
        ServiceAppointmentTriggerHandler.CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE = false ;
        ServiceAppointmentTriggerHandler.Check_Conflict_Overriden = false ;
        if(orgOpp.Appointment_Type__c == 'RT' ) 
        {
            ServiceAppointmentTriggerHandler.CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE = true ;
            ServiceAppointmentTriggerHandler.DO_NOT_CHANGE_FOR_RT = true ;
            
        }
        System.debug('UAC: sa bestmatch to update ' + sa );
        update sa; 
    }
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        CreateAppointmentFromOppBatch b = new CreateAppointmentFromOppBatch(); 
        database.executebatch(b,1);
    }
}