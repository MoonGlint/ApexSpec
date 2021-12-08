@isTest
public class TestDataFactory {
    Static Final String TYPE_ROUTINE_MAINTENANCE = 'Routine Maintenance';
    Static Final String TYPE_REPAIR = 'Repair';
    Static Final String STATUS_NEW = 'New';
    Static Final String STSTUS_CLOSED = 'Closed';
    static Integer vehicleQantity;
    static Integer equipQantityForEach;
// создай одну запись потом масштабируй 
    
    public static Map<Id,Map<Id,Product2>> createDefaultData(){
 
        //				Map Keys:  Id ( MaintRequest__c) => Value: 
        //				Map Keys:  Id (Vehicle__c)       => Values Equipment(Product2)
    Map<Id,Map<Id,Product2>> resultDataMap = new Map<Id,Map<Id,Product2>>();
   Map<Id,Product2> innerMap =new Map<Id,Product2>();
        Map<Id,Product2> innerMap2 =new Map<Id,Product2>();
      
        Vehicle__c vehicle =new Vehicle__c(Name = 'Toy Hauler RV', Air_Conditioner__c = true, Bathrooms__c = 1, Bedrooms__c = 1, Model__c = 'Toy Hauler RV');
        Vehicle__c vehicle2 = new Vehicle__c(Name = 'Travel Trailer RV', Air_Conditioner__c = true, Bathrooms__c = 2, Bedrooms__c = 2, Model__c = 'Travel Trailer RV');
        Product2 equipment = new Product2(Warehouse_SKU__c = '55d66226726b611100aaf741',name = 'Generator 1000 kW', Replacement_Part__c = true,Cost__c = 100 ,Maintenance_Cycle__c = 100);
        Product2 equipment2 = new Product2(name = 'Fuse 20B',Replacement_Part__c = true,Cost__c = 1000, Maintenance_Cycle__c = 30  );
        insert vehicle;
        insert vehicle2;
        insert equipment;
        insert equipment2;
        Case maintRequest = new Case(Vehicle__c = vehicle.Id, Type = TYPE_REPAIR,Status = STATUS_NEW, Date_Reported__c = Date.today());
        Case maintRequest2 = new Case(Vehicle__c = vehicle2.Id, Type = TYPE_REPAIR,Status = STATUS_NEW, Date_Reported__c = Date.today());
        insert maintRequest;
        insert maintRequest2;
        Equipment_Maintenance_Item__c emi = new Equipment_Maintenance_Item__c(Equipment__c = equipment.Id, Maintenance_Request__c = maintRequest.Id);
        Equipment_Maintenance_Item__c emi2 = new Equipment_Maintenance_Item__c(Equipment__c = equipment2.Id, Maintenance_Request__c = maintRequest.Id);
        insert emi;
        insert emi2;
        
        innerMap.put(vehicle.id,equipment);
        innerMap2.put(vehicle2.id,equipment2);
        resultDataMap.put(maintRequest.Id,innerMap);
        resultDataMap.put(maintRequest2.Id,innerMap2);
        
        
        
        return resultDataMap;
     
    } 
   
    

}