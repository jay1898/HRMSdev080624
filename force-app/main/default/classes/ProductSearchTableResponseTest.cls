/**
* @description       : ProductSearchTableResponseTest Test class for ProductSearchTableResponse
* @author            : Balaji Ravindran | mailto:ravindramb@evergegroup.com
* History   
* Ver   Date         Author            Modification
* 1.0   28-06-2023   Balaji Ravindran  Initial Version()
**/
@IsTest
public class ProductSearchTableResponseTest {
    
    static testMethod void testParse() {
        String json = '['+
        '   {'+
        '      \"serialNo\": {'+
        '         \"value\": \"14\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"owner\": {'+
        '         \"value\": \"Name (14)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"partyId\": {'+
        '         \"value\": \"Party ID (14)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"quantity\": {'+
        '         \"value\": \"QTY 1\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"purchase\": {'+
        '         \"value\": \"Purchase (51)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"pqm\": {'+
        '         \"value\": \"PQM (0)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"salesOrder\": {'+
        '         \"value\": \"Sales (14)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"salesOrderLine\": {'+
        '         \"value\": \"Sales Line(14)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"lineItemNotes\": {'+
        '         \"value\": \"Line Notes (14)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"bac\": {'+
        '         \"value\": \"BAC (14)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"orderAt\": {'+
        '         \"value\": \"2023-06-30T05:41:44.092Z\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"shipAt\": {'+
        '         \"value\": \"2023-06-29T05:41:44.092Z\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"installAt\": {'+
        '         \"value\": \"2023-07-04T05:41:44.092Z\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"item\": {'+
        '         \"value\": \"Item (14)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"address\": {'+
        '         \"value\": \"Address (14)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"brand\": {'+
        '         \"value\": \"Brand (14)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"product\": {'+
        '         \"value\": \"Product (14)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"location\": {'+
        '         \"value\": \"Location (14)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"description\": {'+
        '         \"value\": \"Description (14)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"framWidth\": {'+
        '         \"value\": \"Width (13)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"frameHeight\": {'+
        '         \"value\": \"Height (2)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"configType\": {'+
        '         \"value\": \"Type (17)\",'+
        '         \"visible\": true'+
        '      },'+
        '      \"expand\": false,'+
        '      \"tab1\": \"65:1\",'+
        '      \"tab2\": \"86:2\",'+
        '      \"tab3\": \"52:3\"'+
        '   }'+
        ']';
        List<ProductSearchTableResponse> obj = ProductSearchTableResponse.parse(json);
        System.assert(obj != null);
    }
}