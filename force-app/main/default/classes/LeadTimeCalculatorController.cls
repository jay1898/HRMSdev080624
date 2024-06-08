/**
* @description       : LeadTimeCalculatorController class Used for LeadTimeCalculator lwc
* @author            : Balaji Ravindran | mailto:ravindramb@evergegroup.com
* History   
* Ver   Date         Author            Modification
* 1.0   26-07-2023   Balaji Ravindran  Initial Version()
**/
public class LeadTimeCalculatorController {
    
    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 26-07-2023
    *   Purpose         : This method will return the Category Questions filter by the param records.
    *   Input Param     : String selectedBrand   - passed the selected brand value from LWC.
    *                     String selectedProductCategory - passed the selected product category value from LWC.
    *   Output Param    : List of Category_Questions__c records from the query.
    */
    @AuraEnabled
    public static List<Category_Questions__c> getCategoryQuestions(String selectedBrand, String selectedProductCategory){
        
        return [Select Id, Question_Text__c FROM Category_Questions__c WHERE Brand_Shipping__r.Brand__c =: selectedBrand AND Product_Category__c =: selectedProductCategory];
    }
    
    /*
    *   Created By      : Lucas Soderstrom
    *   Added on        : 27-07-2023
    *   Purpose         : This method will return the Category Questions filter by the param records.
    *   Input Param     : String questionIds   - passing the selected the List<Category_Questions__c> as JSON string from LWC.
    *                     String branchId - passing the branchId from LWC.
    *                     Date orderDate - passing the selected order date from LWC.
    *   Output Param    : List of DeliveryLeadTimes wrapper values.
    */
    @AuraEnabled
    public static List<DeliveryLeadTimes> generateLeadTimes(String questionIds, String branchId, Date orderDate, String branchPrefinish, String productCategory, String brand){
        
        List<Category_Questions__c> questionList = (List<Category_Questions__c>) JSON.deserialize(questionIds, List<Category_Questions__c>.class);
        system.debug('questionList '+questionList);

        // generate list and map of lead times based on values selected by user
        list <Decimal> leadTimes = new list <Decimal>(); 
        Map <Decimal, Category_Questions__c> leadTimesMap = new Map <Decimal, Category_Questions__c>(); 
        for (Category_Questions__c question : [Select Manufacture_Days_Standard__c, Manufacture_Days_Rapid__c FROM Category_Questions__c WHERE Id =: questionList]) {
            leadTimes.add(question.Manufacture_Days_Standard__c);  
            leadTimesMap.put(question.Manufacture_Days_Standard__c, question);
        }
        
        // find matching brand shipping record based on brand selected by user
        list <Brand_Shipping__c> brandShipping = [Select Is_Vinyl__c, Is_Fiberglass__c, Is_Wood__c
                                                 FROM Brand_Shipping__c WHERE Brand__c = :brand];
        system.debug('brandShipping: ' + brandShipping);
        
        List<DeliveryLeadTimes> deliveryLeadTimesWrapperList = new List<DeliveryLeadTimes>();
        
        if (leadTimes.size() > 0){ 
		// find the record with the highest lead time. This record will be used to establish dates below
        Decimal maxLeadTime = leadTimes.get(leadTImes.size()-1);
        Category_Questions__c maxQuestion = leadTimesMap.get(maxLeadTime);
        system.debug('maxQuestin: ' + maxQuestion);

        if(String.isBlank(branchId)) {
            return deliveryLeadTimesWrapperList;
        }

        // query branch time records, which tell us how many days to add for each of the four shipping methods
            for (Branch_Delivery_Time__c branchTime : [Select LRD_Wait__c, Place_Order__c, Custom_Prefinish__c, Delivery_Method__r.Name__c, 
                                                   Load_to_Truck__c, Padding__c, Pick_up_from_pod__c, Deliver_to_pod_tech__c, Standard_Prefinish__c,
                                                   Transit_Wood__c, Transit_Vinyl__c, Transit_Fiberglass__c, Ship_Fiberglass__c, Ship_Wood__c, Ship_Vinyl__c
                                                   FROM Branch_Delivery_Time__c 
                                                   WHERE Branch__c = :branchId
                                                   AND Is_Disabled__c = false
                                                   Order By Delivery_Method__r.Name__c DESC]){
                                                       system.debug('branchTime: ' + branchTime);
                                                       DeliveryLeadTimes leadTime = new DeliveryLeadTimes();
                                                       leadTime.deliveryMethod = branchTime.Delivery_Method__r.Name__c;
                                                       leadTime.mfrStart = addDates(orderDate.addDays(1), (Integer.valueOf(branchTime.LRD_Wait__c) + Integer.valueOf(branchTime.Place_Order__c)));
                                                       system.debug('mfrStart: ' + leadTime.mfrStart);
														// mfr days to add depends on whether shipping method is rapid or standard
                                                       if(leadTime.deliveryMethod.contains('Rapid')){ 
                                                           leadTime.mfr = addDates(Date.parse(leadTime.mfrStart), Integer.valueOf(maxQuestion.Manufacture_Days_Rapid__c));
                                                       } else if(leadTime.deliveryMethod.contains('Standard')){
                                                           leadTime.mfr = addDates(Date.parse(leadTime.mfrStart), Integer.valueOf(maxQuestion.Manufacture_Days_Standard__c));   
                                                       }
                                                       
                                                       // receive date depends on whether material is wood, vinyl or fiberglass
                                                       system.debug('in receive');
                                                       Date updatedShippingDate = Date.parse(leadTime.mfr);
                                                       if (brandShipping[0].Is_Wood__c){
                                                           if(branchTime.Ship_Wood__c != null){ 
                                                           updatedShippingDate = findShippingDate(Date.parse(leadTime.mfr), branchTime.Ship_Wood__c);
                                                           }
                                                           leadTime.receive = addDates(updatedShippingDate, Integer.valueOf(branchTime.Transit_Wood__c));                                          
                                                       } else if (brandShipping[0].Is_Vinyl__c){
                                                           if(branchTime.Ship_Vinyl__c != null){
                                                           updatedShippingDate = findShippingDate(Date.parse(leadTime.mfr), branchTime.Ship_Vinyl__c);
                                                           }
                                                           leadTime.receive = addDates(updatedShippingDate, Integer.valueOf(branchTime.Transit_Vinyl__c));                                          
                                                       } else if (brandShipping[0].Is_Fiberglass__c){
                                                           if(branchTime.Ship_Fiberglass__c != null){
                                                           updatedShippingDate = findShippingDate(Date.parse(leadTime.mfr), branchTime.Ship_Fiberglass__c);
                                                           }
                                                           leadTime.receive = addDates(updatedShippingDate, Integer.valueOf(branchTime.Transit_Fiberglass__c));                                          
                                                       }
                                                       
                                                       // prefinish days to add depends on whether record is standard or custom
                                                       if (branchPrefinish == 'Custom'){ 
                                                           leadTime.branchPrefinish = addDates(Date.parse(leadTime.receive), Integer.valueOf(branchTime.Custom_Prefinish__c));
                                                       } else if (branchPrefinish == 'Standard'){
                                                           leadTime.branchPrefinish = addDates(Date.parse(leadTime.receive), Integer.valueOf(branchTime.Standard_Prefinish__c));   
                                                       } else{
                                                           leadTime.branchPrefinish = leadTime.receive;   
                                                       }
                                                       
                                                       leadTime.buffer = Integer.valueOf(branchTime.Padding__c);
                                                       leadTime.loadDeliver = addDates(Date.parse(leadTime.branchPrefinish), (Integer.valueOf(branchTime.Load_to_truck__c) + Integer.valueOf(branchTime.Deliver_to_pod_tech__c) + Integer.valueOf(branchTime.Pick_up_from_pod__c)));
                                                       leadTime.partReady = addDates(Date.parse(leadTime.loadDeliver), leadTime.buffer);
                                                       system.debug('plus one');
                                                       leadTime.plusOne = addDates(Date.parse(leadTime.partReady), 1);
                                                       deliveryLeadTimesWrapperList.add(leadTime);                                     
        }
        }
        
        // Rows need to be ordered by from cheapest to most expensive, which is only indicated by the shipping method
        // label. If we get all four shipping methods, 'Overnight' needs to be last. 
        List<DeliveryLeadTimes> deliveryLeadTimesWrapperListSorted = new List<DeliveryLeadTimes>();
        if(deliveryLeadTimesWrapperList.size() == 4){ 
        deliveryLeadTimesWrapperListSorted.add(deliveryLeadTimesWrapperList[0]);
        deliveryLeadTimesWrapperListSorted.add(deliveryLeadTimesWrapperList[1]);
        deliveryLeadTimesWrapperListSorted.add(deliveryLeadTimesWrapperList[3]);
        deliveryLeadTimesWrapperListSorted.add(deliveryLeadTimesWrapperList[2]);
        } else {
           deliveryLeadTimesWrapperListSorted = deliveryLeadTimesWrapperList;
        }
        return deliveryLeadTimesWrapperListSorted;
    }
    
    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 01-08-2023
    *   Purpose         : This method will insert the Part type case lines.
    *   Input Param     : String caseId   - passed the current case id value from LWC.
                          String leadTimesString   - passed the DeliveryLeadTimes value from LWC.
                          String branchId   - passed the current case record branch value from LWC.
    *                     String orderDate - passed the selected order date from LWC.
    *   Output Param    : inserted part type case line.
    */
    @AuraEnabled
    public static Case_Line__c createPartCaseLines(String caseId, String leadTimesString, String branchId, Date orderDate){
        
            DeliveryLeadTimes leadTimes = (DeliveryLeadTimes) JSON.deserialize(leadTimesString, DeliveryLeadTimes.class);
            system.debug('partready: ' + leadTimes.PartReady);
            Case_Line__c caseLine = new Case_Line__c();
            caseLine.Branch__c = branchId;
            caseLine.Order_Date__c = orderDate;
            caseLine.RecordTypeId = Schema.SObjectType.Case_Line__c.getRecordTypeInfosByName().get('Parts').getRecordTypeId();
            caseLine.Part_Ready__c = Date.parse(leadTimes.PartReady);
            caseLine.Case__c = caseId;
        try{
            insert caseLine;
            return [Select Id, Name from Case_Line__c where Id =: caseLine.Id];

        } catch (Exception e) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadTimeCalculatorController','createPartCaseLines',caseId, e,'LWC Controller'));
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 16-10-2023
    *   Purpose         : This method will return the Part_Source__c records filter by the Branch for Part Source picklist option in lwc.
    *   Input Param     : String branchId   - passed the current case record branch value from LWC.
    *   Output Param    : returning the List<SelectOption>.
    */
    @AuraEnabled(cacheable=true)
    public static List<selectOptionWrapper> getPartSourceOptions(String branchId){
        
        List<selectOptionWrapper> options = new List<selectOptionWrapper>();
        for(Part_Source__c part : [Select Name__c FROM Part_Source__c WHERE Branch__c =: branchId OR Branch__c = null Order BY Name__c ASC]) {
            selectOptionWrapper option = new selectOptionWrapper();
            option.label = part.Name__c;
            option.value = part.Name__c;
            options.add(option);
        }
 	 	return options;
    }

    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 03-10-2023
    *   Purpose         : This method will insert and return the Case Line record.
    *   Input Param     : String caseId   - passed current case record Id from LWC.
    *                     String selectedAvailableDate - passed the selected available date value from LWC.
    *                     String linePrice - passed the entered line price value from LWC.
    *                     String description - passed the description value from LWC.
    *                     String partSource - passed the selected part source value from LWC.
    *   Output Param    : Inserted Case Line record.
    */
    @AuraEnabled
    public static Case_Line__c createStockPartCaseLines(String caseId, Date selectedAvailableDate, Decimal linePrice, String description, String partSource, Double quantity, String partNumber){
        
            Case_Line__c caseLine = new Case_Line__c();
            caseLine.Available_Date__c = selectedAvailableDate;
            caseLine.Line_Price__c = linePrice;
            caseLine.RecordTypeId = Schema.SObjectType.Case_Line__c.getRecordTypeInfosByName().get('Parts').getRecordTypeId();
            caseLine.Description__c = description;
            caseLine.Part_Source__c = partSource;
            caseLine.Quantity__c = quantity;
            caseLine.Part_Number__c = partNumber;
            caseLine.Case__c = caseId;
        try{
            insert caseLine;
            return [Select Id, Name from Case_Line__c where Id =: caseLine.Id];

        } catch (Exception e) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadTimeCalculatorController','createStockPartCaseLines',caseId, e,'LWC Controller'));
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static String formatDate(Date d) {
        return d.year() + '-' + d.month() + '-' + d.day();
    }
    
    
    /*
    *   Created By      : Lucas Soderstrom
    *   Added on        : 08-08-2023
    *   Purpose         : This method will add dates together while excluding weekends
    *   Input Param     : String startingDate   - starting Date
    *                     String toAdd - Integer of days to add to startingDate
    *   Output Param    : String.
    */
    public static String addDates(Date startingDate, Integer toAdd) {
        set <Date> holidayDates = new set <Date>(); 
        for (Holiday hol : [Select RecurrenceStartDate FROM Holiday]){
            holidayDates.add(hol.RecurrenceStartDate);
        }
        system.debug('holidayDates: ' + holidayDates);
        
        Integer daysAdded = 0;
        
        // starts at startDate, but will be ++ in the loop 
        DateTime currentDate = DateTime.NewInstance(startingDate.year(), startingDate.month(), startingDate.day()).addHours(1); 
            
        while (daysAdded != toAdd) {
            system.debug('currentDate: ' + currentDate);
            system.debug('currentDatespelled: ' + currentDate.format('E'));
            system.debug('333: ' + currentDate + holidayDates.contains(Date.valueOf(currentDate)));
            system.debug(currentDate.format('E') != 'Sat');
            system.debug(currentDate.format('E') != 'Sun');
       		// if currentDate is not a weekend, we will increment to the loop variable
       		system.debug('date value ' + (Date.valueOf(currentDate)) + holidayDates.contains(Date.valueOf(currentDate)));
            if((currentDate.format('E') != 'Sat' && currentDate.format('E') != 'Sun' && !holidayDates.contains(Date.valueOf(currentDate)))){
                system.debug('daysaddedbefore: ' + daysAdded);
                daysAdded++;
                system.debug('daysaddedafter: ' + daysAdded);
            }
			currentDate = currentDate.addDays(1);
        }  
        
        system.debug('currentdate final1: ' + currentDate);
        if(currentDate.format('E') == 'Sat'){
           if(!holidayDates.contains(Date.valueOf(currentDate.addDays(2)))){
            currentDate = currentDate.addDays(2);
        } else if (!holidayDates.contains(Date.valueOf(currentDate.addDays(3)))){
            currentDate = currentDate.addDays(3);
        } else {
           currentDate = currentDate.addDays(4); 
        }
        }
        system.debug('currentdate final2: ' + currentDate);
        return Date.valueOf(currentDate).format();
    }
    
    /*
    *   Created By      : Lucas Soderstrom
    *   Added on        : 08-08-2023
    *   Purpose         : This method will find the closest Date to when this type of material ships
    *   Input Param     : Date startingDate   - starting Date
    *                     String shippingDays - String of letters that indicates when this type of material ships (M, T, W, R, and/or F)
    *   Output Param    : Date.
    */
    public static Date findShippingDate(Date startingDate, String shippingDays) {
        set <String> activeShippingDays = new set <String>();
        // convert individual character format to 'Mon', 'Tue', etc
        if(shippingDays.contains('M')){
            activeShippingDays.add('Mon');
        }
        if(shippingDays.contains('T')){
            activeShippingDays.add('Tue');
        }
        if(shippingDays.contains('W')){
            activeShippingDays.add('Wed');
        }
        if(shippingDays.contains('R')){
            activeShippingDays.add('Thu');
        }
        if(shippingDays.contains('F')){
            activeShippingDays.add('Fri');
        }
        
        system.debug('activeShippingDays: ' + activeShippingDays);
        Integer count = 0;
        DateTime currentDate = DateTime.NewInstance(startingDate.year(), startingDate.month(), startingDate.day());
        // find the closest date that matches one of the activeShippingDays. Should at most need to go through full week to find closest date
        if(activeShippingDays.size() > 0){ 
            while (count < 7){ 
                if(activeShippingDays.contains(currentDate.addDays(count).format('E'))){
                    currentDate = currentDate.addDays(count);
                    break;
                } else {
                    count++;
                }
            } 
        }
        system.debug('currentDate: ' + currentDate);
        return Date.valueOf(currentDate);
    }
    
    public class DeliveryLeadTimes {
        @AuraEnabled public String deliveryMethod;
        @AuraEnabled public String partReady;
        @AuraEnabled public String branchPrefinish;
        @AuraEnabled public String mfrStart;
        @AuraEnabled public String mfr;
        @AuraEnabled public String receive;
        @AuraEnabled public String plusOne;
        @AuraEnabled public String loadDeliver;
        @AuraEnabled public Integer buffer;
    }

    public class selectOptionWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
}