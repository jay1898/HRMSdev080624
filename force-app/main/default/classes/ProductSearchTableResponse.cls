/**
* @description       : ProductSearchTableResponse class Used to create work order(s)
* @author            : Balaji Ravindran | mailto:ravindramb@evergegroup.com
* History            : SCS-369 User Story   
* Ver   Date         Author            Modification
* 1.0   28-06-2023   Balaji Ravindran  Initial Version()
**/
public class ProductSearchTableResponse {
    
    public SerialNo serialNo;
    public SerialNo owner;
    public SerialNo partyId;
    public SerialNo quantity;
    public SerialNo purchase;
    public SerialNo pqm;
    public SerialNo salesOrder;
    public SerialNo salesOrderLine;
    public SerialNo lineItemNotes;
    public SerialNo bac;
    public SerialNo orderAt;
    public SerialNo shipAt;
    public SerialNo installAt;
    public SerialNo item;
    public SerialNo address;
    public SerialNo brand;
    public SerialNo product;
    public SerialNo location;
    public SerialNo description;
    public SerialNo framWidth;
    public SerialNo frameHeight;
    public SerialNo configType;
    public String selectedIssue;
    public String selectedComponent;
    public String taskType;
    public String serviceAction;
    public Boolean secondTechMultiplier;
    public cls_warranties warranties;

    public class SerialNo {
        public String value;
        public Boolean visible;
    }

    public class cls_warranties {
        public cls_value[] value;
        public boolean visible;
    }

    public class cls_value {
        public cls_contractAddress contractAddress;
        public String coverageDescription;
        public String customerName;
        public String endDate;
        public String externalId;
        public String id;
        public boolean isTransferable;
        public String startDate;
        public String status;
    }

    public class cls_contractAddress {
        public String address1; //18900 - PWD, LLC
        public String address2; //1940 OPDYKE CT.
        public String city; //AUBURN HILLS
        public String country;  //US
        public String postalCode;   //48326
        public String state;    //MI
    }

    
    public static List<ProductSearchTableResponse> parse(String json) {
        return (List<ProductSearchTableResponse>) System.JSON.deserialize(json, List<ProductSearchTableResponse>.class);
    }
}