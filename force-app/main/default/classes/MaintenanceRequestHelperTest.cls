@isTest
public with sharing class MaintenanceRequestHelperTest {
   public static Map<Id,Map<Id,Product2>> resultDataMap;
    
    @testSetup 
    static void init(){
        System.debug('TestInit');
         
       // resultDataMap = TestDataFactory.createDefaultData();
        System.debug(resultDataMap);
    }
   /*
    @isTest
    static void testAfterUpdateCase(){
        // Test data setup
        // Create default data
        CreateDefaultData.createDefaultData();
        //Check if data created
        System.assert(!CreateDefaultData.isDataCreated(),'Data was created');
        
        
    }
*/
    
    @isTest
    static void testRepairTypeBulk(){
        
        System.debug('Test2');
        resultDataMap = TestDataFactory.createDefaultData();
        System.debug(resultDataMap);
        
        List<Case> maintReqList = [SELECT Type,Status From Case Where Id =:resultDataMap.keySet()];
        for(Case c:maintReqList){
         // check Maintenance Request(Case) Status and Type, Status => Close for futher firing Trigger
            if ((c.Type == 'Repair') && (c.Status != 'Closed')){
             c.Status = 'Closed';
           }   
        }
               
        
        Test.startTest();
        //Update Database for firing Trigger
        List<Database.SaveResult> srList = Database.update(maintReqList,false);
        Test.stopTest();
        
        for(Database.SaveResult sr :srList){
            if(sr.isSuccess()){
      						// Operation was successful, so get the ID of the record that was processed
                 System.debug('Successfully updated account. Account ID: ' + sr.getId());
       						//getting Id of object and comparing Vehicle__c + Equipment(Product2)  with data from DataFactory
               Id caseId = sr.getId();
               
                System.assert(resultDataMap.containsKey(caseID),'There is no such Case Id in the initial Data');
                
             // System.assert(resultDataMap.get(caseId))
                
                
                
            }
            else {
        // Operation failed, so get all errors                
        for(Database.Error err : sr.getErrors()) {
            System.debug('The following error has occurred.');                    
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('Account fields that affected this error: ' + err.getFields());
        }
    }
  }
        
}
    
    
    
    
    
    
    
    
    @isTest
    static void testRoutineMaintenanceBulk(){
        List<Case> maintReqList = [SELECT Type,Status From Case Where Id =:resultDataMap.keySet()];
        // check Status and Type, Status => Close for Firing Trigger
        for(Case c: maintReqList){
          if ((c.Type == 'Routine Maintenance')&&(c.Status!='Closed')){
           c.Status = 'Closed';
            }
            
        }
        Test.startTest();
        List<Database.SaveResult> srList = Database.update(maintReqList, false);
        Test.stopTest();
        
        for(Database.SaveResult sr :srList){
            if(sr.isSuccess()){
                 // Operation was successful, so get the ID of the record that was processed
                 System.debug('Successfully updated account. Account ID: ' + sr.getId());
             sr.getId();   
                
            }
            else {
        // Operation failed, so get all errors                
        for(Database.Error err : sr.getErrors()) {
            System.debug('The following error has occurred.');                    
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('Account fields that affected this error: ' + err.getFields());
        }
    }
        }
        
    }
    
    

}