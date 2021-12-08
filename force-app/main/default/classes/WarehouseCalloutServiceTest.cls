@IsTest
private class WarehouseCalloutServiceTest {
   @isTest
    static void newProductsCreationTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
       // WarehouseCalloutService.restWareHouseCall();
       System.enqueueJob(new WarehouseCalloutService());
   			
        Test.stopTest();
        
        System.assertEquals(22, [Select Count() From Product2],[Select Count() From Product2]);
       // System.assert( [Select Replacement_Part__c FROM Product2 Where Warehouse_SKU__c = '100004'LIMIT 1].get(0).Replacement_Part__c);
        
      
    }
}