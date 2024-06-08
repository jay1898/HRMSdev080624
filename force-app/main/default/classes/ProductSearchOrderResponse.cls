public class ProductSearchOrderResponse{
	@AuraEnabled
	public cls_data data;
	@AuraEnabled
    public cls_errors[] errors;
	
	public class cls_data {
		@AuraEnabled
		public cls_getPurchasedProductsBySerialNumber getPurchasedProductsBySerialNumber;
		@AuraEnabled
		public cls_results getPurchasedProductById;
		@AuraEnabled
		public cls_getPurchasedProductsBySerialNumber getPurchasedProductsByCustomerPONumber;
		@AuraEnabled
		public cls_getPurchasedProductsBySerialNumber getPurchasedProductsByAddress;
		@AuraEnabled
		public cls_getPurchasedProductsBySerialNumber getPurchasedProductsBySalesOrderNumber;
		@AuraEnabled
		public cls_getPurchasedProductsBySerialNumber getPurchasedProductsByCustomerNumber;
		@AuraEnabled
		public cls_modifyPurchasedProductsInstallDate[] modifyPurchasedProductsInstallDate;
	}

	public class cls_modifyPurchasedProductsInstallDate {
		@AuraEnabled
		public String id;	//9002d9c4-a61d-4547-9d22-3ac527a40785
		@AuraEnabled
		public String installDate;	//2023-07-15
	}

	public class cls_getPurchasedProductsBySerialNumber {
		@AuraEnabled
		public cls_results[] results;
		@AuraEnabled
		public cls_pageInfo pageInfo;
	}

	public class cls_results {
		@AuraEnabled
		public String id;	//d4bafe97-b81a-4af0-a4a6-fa87cfe78301
		@AuraEnabled
		public String serialNumber;	//TestSerialNumber
		@AuraEnabled
		public String shippedDate;	//TestSerialNumber
		@AuraEnabled
		public String installDate;	//1690243200000
		@AuraEnabled
		public String externalId;	//TestExternalId
		@AuraEnabled
		public String orderLineId;
		@AuraEnabled
		public cls_installAddress installAddress;
		@AuraEnabled
		public String customerPONumber;
		@AuraEnabled
		public cls_shipToAddress shipToAddress;
		@AuraEnabled
		public Integer orderLineNumber;	//1
		@AuraEnabled
		public String quoteLineNumber;
		@AuraEnabled
		public String itemDescription;
		@AuraEnabled
		public String poItemDescription;
		@AuraEnabled
		public String orderSource;	//TestOrderSource
		@AuraEnabled
		public String roomLocation;
		@AuraEnabled
		public String manufacturingEntity;	//TestEntity
		@AuraEnabled
		public String orderDate;
		@AuraEnabled
		public String orderNumber;	//1234
		@AuraEnabled
		public String projectName;
		@AuraEnabled
		public String orderLineQuantity;
		@AuraEnabled
		public String manufacturingSystem;
		@AuraEnabled
		public String manufacturingSystemSalesOrderNumber;
		@AuraEnabled
		public String manufacturingSystemSalesOrderLineNumber;
		@AuraEnabled
		public String brand;
		@AuraEnabled
		public String configType;
		@AuraEnabled
		public String frameHeight;
		@AuraEnabled
		public String frameWidth;
		@AuraEnabled
		public String interiorColor;
		@AuraEnabled
		public String exteriorColor;
		@AuraEnabled
		public String product;
		@AuraEnabled
		public cls_poAttributes[] poAttributes;
		@AuraEnabled
		public cls_mfgAttributes[] mfgAttributes;
		@AuraEnabled
		public cls_currentOwner currentOwner;
		@AuraEnabled
		public cls_previousOwners[] previousOwners;
		@AuraEnabled
		public cls_warranties[] warranties;
	}
	
	public class cls_installAddress {
		@AuraEnabled
		public String address1;
		@AuraEnabled
		public String address2;
		@AuraEnabled
		public String city;
		@AuraEnabled
		public String state;
		@AuraEnabled
		public String postalCode;
		@AuraEnabled
		public String country;
	}

	public class cls_warranties {
		@AuraEnabled
		public String id;	
		@AuraEnabled
		public String externalId;	
		@AuraEnabled
		public String customerName;	
		@AuraEnabled
		public String coverageDescription;	
		@AuraEnabled
		public String status;	
		@AuraEnabled
		public String startDate;	
		@AuraEnabled
		public String endDate;	
		@AuraEnabled
		public boolean isTransferable;
		@AuraEnabled 
		public cls_contractAddress contractAddress;
	}

	public class cls_contractAddress {
		@AuraEnabled
		public String address1;	
		@AuraEnabled
		public String address2;	
		@AuraEnabled
		public String city;	
		@AuraEnabled
		public String state;	
		@AuraEnabled
		public String postalCode;	
		@AuraEnabled
		public String country;	
	}
	
	public class cls_shipToAddress {
		@AuraEnabled
		public String address1;
		@AuraEnabled
		public String address2;
		@AuraEnabled
		public String city;
		@AuraEnabled
		public String state;
		@AuraEnabled
		public String postalCode;
		@AuraEnabled
		public String country;
	}

	public class cls_poAttributes {
		@AuraEnabled
		public String id;
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String value;
	}

	public class cls_mfgAttributes {
		@AuraEnabled
		public String id;
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String value;
	}

	public class cls_currentOwner {
		@AuraEnabled
		public cls_customer customer;	//TestOwnerName
		@AuraEnabled
		public String externalId;	//TestExternalId
		@AuraEnabled
		public String beginDate;	//1690848000000
	}

	public class cls_customer {
		@AuraEnabled
		public String id;	//a641b656-f689-48e3-8dba-c4559f1770d7
		@AuraEnabled
		public String email;	//Lawson6@yahoo.com
		@AuraEnabled
		public String firstName;	//Asa
		@AuraEnabled
		public String lastName;	//Walker
		@AuraEnabled
		public String phoneNumber;
	}

	public class cls_previousOwners {
		@AuraEnabled
		public String name;	//TestOwnerName
		@AuraEnabled
		public String externalId;	//TestExternalId
		@AuraEnabled
		public String beginDate;	//1690848000000
	}

	public class cls_pageInfo {
		@AuraEnabled
		public Integer currentPage;	//1
		@AuraEnabled
		public Integer totalPages;	//2
		@AuraEnabled
		public Integer totalRecords;	//45
		@AuraEnabled
		public Integer nextPage;	//2
		@AuraEnabled
		public Integer recLimit;	//40
		@AuraEnabled
		public Integer offset;	//0
	}

    public class cls_errors {
		@AuraEnabled
		public String message;	//Unauthorized
		@AuraEnabled
		public cls_extensions extensions;
	}

	public class cls_extensions {
		@AuraEnabled
		public String code;	//AUTH_ERROR
	}

	public static ProductSearchOrderResponse parse(String json){
		return (ProductSearchOrderResponse) System.JSON.deserialize(json, ProductSearchOrderResponse.class);
	}

}