public with sharing class WarehouseCalloutService implements Queueable,Database.AllowsCallouts{
    Boolean replacement = true;   //replacement part (always true)
    Integer cost;				  //Cost__c                Currency
    Integer currentInventory;     //Current_Inventory__c   Number
    Integer lifespan;			  //Lifespan_Months__c     Number
    Integer maintenancePeriod;    //Maintenance_Cycle__c   Number
    String sku;					  //Warehouse_SKU__c       Text	
    
    public WarehouseCalloutService() {
    }
    public void execute(QueueableContext context) {
       
       WarehouseCalloutService.restWareHouseCall();
       
    }
    
    private static void restWareHouseCall(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-superbadge-apex.herokuapp.com/equipment/');
        request.setMethod('GET');
        request.setHeader('Content-Type','application/json');
        HttpResponse response = http.send(request);
        if (response.getStatusCode()==200){
         System.debug(response.getBody());
     //       deserialize(jsonString, apexType)
     //       Deserializes the specified JSON string into an Apex object of the specified type.
            
            List<JsonResponse> jsonList = (List<JsonResponse>)JSON.deserialize(response.getBody().replace('"_id":','"id":'),List<JsonResponse>.class);
               
                for(JSonResponse jSonResponse:jsonList){
                System.debug(jSonResponse.toString());
            }
        }
     
    }
    public class JSonResponse{
       
        public String id{get;set;}                //"_id":"55d66226726b611100aaf741",
        public boolean replacement{get;set;}  //"replacement":false,
        public Integer quantity{get;set;}     //"quantity":5,
        public String name{get;set;}          //"name":"Generator 1000 kW",
        public Double maintPeriod{get;set;}   //"maintenanceperiod":365,
        public Integer lifespan{get;set;}     //"lifespan":120,
        public Double cost{get;set;}          //"cost":5000,
        public String sku{get;set;}           //"sku":"100003"
    
        
    }
}