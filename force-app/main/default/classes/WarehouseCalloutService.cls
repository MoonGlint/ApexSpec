@TestVisible
public with sharing class WarehouseCalloutService implements Queueable,Database.AllowsCallouts{
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    public void execute(QueueableContext context) { 
       WarehouseCalloutService.restWareHouseCall(); 
    }
   
    public static void restWareHouseCall(){
         List<JsonResponse> jsonList;
   		
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        request.setHeader('Content-Type','application/json');
        HttpResponse response = http.send(request);
     //   System.debug('Response:'+ response);
        if (response.getStatusCode()==200){
      //   System.debug('Getting body of response...  '+   response.getBody());
     
     //       deserialize(jsonString, apexType)
     //       Deserializes the specified JSON string into an Apex object of the specified type.
           
             jsonList = (List<JsonResponse>)JSON.deserialize(response.getBody().replace('"_id":','"id":'),List<JsonResponse>.class);
                   
                    WarehouseCalloutService.newProductsCreation(jsonList);
        
        }
    
    }
    
    private static void newProductsCreation(List<JsonResponse> jsonList){
      
        System.debug('Creation new Products ... ');
        List <Product2> newProductList = new List<Product2>{};
        Product2 newProduct;
 
        for (JSonResponse jsResponse:jsonList){  
            System.debug('Creation new Product for '+  jsResponse);
           
            newProduct = new Product2( 
                						ExternalId = jsResponse.id,	
                						Replacement_Part__c = true,//jsResponse.replacement,
                                        Cost__c = jsResponse.cost,
                                        Name = jsResponse.name,
                                        Lifespan_Months__c = jsResponse.lifespan,
                                        Maintenance_Cycle__c = jsResponse.maintenanceperiod,
                                        Current_Inventory__c = jsResponse.quantity,
               							Warehouse_SKU__c = jsResponse.sku
										);
     newProductList.add(newProduct);


        }
        if (newProductList.size()!=0){
            System.debug(newProductList);
        upsert(newProductList);
        }
        


    }

    public class JSonResponse{
       											//	Json
        public String id{get;set;}                //"_id":"55d66226726b611100aaf741",
        public boolean replacement{get;set;}  //"replacement":false,
        public Double quantity{get;set;}     //"quantity":5,
        public String name{get;set;}          //"name":"Generator 1000 kW",
        public Double maintenanceperiod{get;set;}   //"maintenanceperiod":365,maintenanceperiod
        public Integer lifespan{get;set;}     //"lifespan":120,
        public Double cost{get;set;}          //"cost":5000,
        public String sku{get;set;}           //"sku":"100003"
    
        
    }
}

 /*
        Boolean replacement = true;   //replacement part (always true)
        Integer cost;				  //Cost__c                Currency
        Double currentInventory;     //Current_Inventory__c   Number
        Integer lifespan;			  //Lifespan_Months__c     Number
        Integer maintenancePeriod;    //Maintenance_Cycle__c   Number
        String sku;					  //Warehouse_SKU__c       Text	
        */