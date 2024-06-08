@isTest
public class ProductSearchOrderServiceTest {
    
    @isTest
    static void testMethodBySerialNumberData() {
        Test.setMock(HttpCalloutMock.class, new ProductSearchOrderAPIBySerialNumberMock());
        Test.startTest();
        ProductSearchOrderResponse resp = ProductSearchOrderService.getOrderDetailsBySerialNumber(null, null, null);
        System.Assert.areEqual(null, resp.data);
        Test.stopTest();
    }
    
    @isTest
    static void testMethodBySerialNumber() {
        Test.setMock(HttpCalloutMock.class, null);
        Test.startTest();
        try{
        	ProductSearchOrderResponse resp = ProductSearchOrderService.getOrderDetailsBySerialNumber(null, null, null);   
            System.Assert.areEqual(null, resp);
        }catch(Exception e){}        
        Test.stopTest();
    }
    
    @isTest
    static void testMethodbyPONumber() {
        Test.setMock(HttpCalloutMock.class, new ProductSearchOrderAPIBySerialNumberMock());
        Test.startTest();
        ProductSearchOrderResponse resp = ProductSearchOrderService.getOrderDetailsByCustPONumber(null, null, null);
        System.Assert.areEqual(null, resp.data);
        Test.stopTest();
    }
    
    @isTest
    static void testMethodbyPONumberError() {
        Test.setMock(HttpCalloutMock.class, null);
        Test.startTest();
        ProductSearchOrderResponse resp = ProductSearchOrderService.getOrderDetailsByCustPONumber(null, null, null);
        System.Assert.areEqual(null, resp);
        Test.stopTest();
    }
    
    @isTest
    static void testMethodbyAddress() {
        Test.setMock(HttpCalloutMock.class, new ProductSearchOrderAPIBySerialNumberMock());
        Test.startTest();
        ProductSearchOrderResponse resp = ProductSearchOrderService.getOrderDetailsByAddress('[{"addressId":"qylig1rs8q4dmmgkfq","street":"182*","addressLine1":"1325*","city":"FALL RIVER","state":"MA","country":"US","zipcode":"02720","isChecked":true}]', null, null);
        System.Assert.areEqual(null, resp.data);
        Test.stopTest();
    }
    
    @isTest
    static void testMethodbyAddressError() {
        Test.setMock(HttpCalloutMock.class, null);
        Test.startTest();
        ProductSearchOrderResponse resp = ProductSearchOrderService.getOrderDetailsByAddress('[{"addressId":"qylig1rs8q4dmmgkfq","street":"182*","addressLine1":"1325*","city":"FALL RIVER","state":"MA","country":"US","zipcode":"02720","isChecked":true}]', null, null);
        System.Assert.areEqual(null, resp);
        Test.stopTest();
    }
    
    @isTest
    static void testMethodbySalesOrder() {
        Test.setMock(HttpCalloutMock.class, new ProductSearchOrderAPIBySerialNumberMock());
        Test.startTest();
        ProductSearchOrderResponse resp = ProductSearchOrderService.getOrderDetailsBySalesOrderNumber(null, null, null);
        System.Assert.areEqual(null, resp.data);
        Test.stopTest();
    }
    
    @isTest
    static void testMethodbySalesOrderError() {
        Test.setMock(HttpCalloutMock.class, null);
        Test.startTest();
        ProductSearchOrderResponse resp = ProductSearchOrderService.getOrderDetailsBySalesOrderNumber(null, null, null);
        System.Assert.areEqual(null, resp);
        Test.stopTest();
    }
    
    @isTest
    static void testMethodbySerailNoError() {
        Test.setMock(HttpCalloutMock.class, null);
        Test.startTest();
        ProductSearchOrderResponse resp = ProductSearchOrderService.getOrderDetailsBySerialNumber(null, null, null);
        System.Assert.areEqual(null, resp);
        Test.stopTest();
    }
    
    
    @isTest
    static void testMethodbySerailId() {
        Test.setMock(HttpCalloutMock.class, new ProductSearchOrderAPIBySerialNumberMock());
        Test.startTest();
        ProductSearchOrderResponse resp = ProductSearchOrderService.getOrderDetailsBySerialId(null);
        System.Assert.areEqual(null, resp.data);
        Test.stopTest();
    }
    
    @isTest
    static void testMethodbySerailIdError() {
        Test.setMock(HttpCalloutMock.class, null);
        Test.startTest();
        ProductSearchOrderResponse resp = ProductSearchOrderService.getOrderDetailsBySerialId(null);
        System.Assert.areEqual(null, resp);
        Test.stopTest();
    }


    @isTest
    static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new ProductSearchOrderAPIBySerialNumberMock());
        Test.startTest();
        ProductSearchOrderResponse resp = ProductSearchOrderService.updateInstallationDate(new List<String>{'test'}, '18/10/2023');
        System.Assert.areEqual(null, resp.errors);
        Test.stopTest();
    }
}