/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-03-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class PQMQuoteWrapper {
    global class Response{
        public String status; 
        public String httpStatusCode;
        public String errorMessage ;
        public Response(){
            status = 'SUCCESS';
            httpStatusCode = '200' ;
        }
    }    
    
    global class Request{
        public String earliestLRD;
        public String quotenumber;
        public String quoteid;
        public String quotename;
        public String salesrepusername;
        public String status;
        public String QuoteType;
        public String contractdate;
        public String bookdate;
        public String quotedate;
        public String signedContractdate;
        public String ponumber;
        public String quantity;
        public String customerextendedprice;
        public String forecast;
        public String opportunity;
        public String contactname;
        public String partyid;
        public String totalBACprice;
        public String totalinvoiceprice;
        public String projectname;
        public String businessSegment;
        public String marketSegment;
        public String PQMListPrice;
        public String PQMQuoteDiscount;
        public String PQMQuoteDiscountPercent;
        public String PQMQuoteDate;
        public String PQMLinkDate;
        public String orgContactId;
        public String OrderType;
        public String TotalOrderQuantity;
        public List<brandcount> brandcount;
        public List<lineitem> lineitems;
        public JobDetails customer;
        public JobDetails projectOwner;
        public String recoveryQuote;
        public String PQMBACDiscount;
        public String preparedBy;
    }
    global class brandcount{
        public String brand;
        public String count;
        public String customerextendedprice ;
        public String totalinvoiceprice;
        public String TotalOrderQuantity;
        public List<productCount> productCount;
    }
    global class productCount{
        public String producttype;
        public String count;
        public String customerextendedprice ;
        public String totalBACprice;
        public String totalinvoiceprice;
        public String orderQuantity;
    }
    global class lineitem{
        public String BR;	
		public String PT;	
		public String QL;	
		public String PL;	
		public String UT;	
		public String RL;	
		public String OQ;	
		public String QQ;	
		public String DE;	
		public String PC;	
		public String PS;	
		public String FW;	
		public String FH;	
		public String CP;	
		public String EC;	
		public String AT;	
		public String FN;
		public String HS;	
		public String GP;	
		public String OW;	
		public String OH;	
		public String SO;	
		public String SS;
		public String OS;	
		public String OV;	
        public String CC;
        public String DP;	
        public String SF;
    }
    global class JobDetails{
        public String jobaddress;	
		public String jobcity;	
		public String jobinfo;	
		public String jobname;	
		public String jobphone;	
		public String jobmobilephone;	
		public String jobemail;	
		public String jobstate;	
		public String jobzip;	
		public String jobshiptojobsite;	
		public String jobAddress2;	
		public String jobCounty;	
		public String jobCountry;	
		public String jobLot;	
    }
    
    
    
}