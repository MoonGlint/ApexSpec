public with sharing class MaintenanceRequestHelper {   
        public static void updateWorkOrders() {    
               
            List<Case> existingMainReq =Trigger.New;   
            Integer count = 0;
           
                  Map<Id, Integer> toGetDueDateMap = new Map<Id, Integer>();
                       Map<Id,Case> newCasesToIdsMap = new Map<Id,Case>();      
                          List<Case> createNewMainReq = new List<Case>();     
                              List<Case> caseIdsList = new List<Case>();   
                                    Map<Equipment_Maintenance_Item__c,Id> EquipMainItemsToProdIds = 
                                    new Map<Equipment_Maintenance_Item__c,Id>();       
                                               if(!existingMainReq.isEmpty()){       
                                                     for(Case cc : existingMainReq){      
                                  if((cc.Type == 'Repair' || cc.Type == 'Routine Maintenance') && cc.Status == 'Closed'){   
                                      caseIdsList.add(cc);                 
                                  }       
                                                     }          
                                               }         
            List<Equipment_Maintenance_Item__c> equipMainList = 
                [Select id,Equipment__c,Maintenance_Request__c 
                 from Equipment_Maintenance_Item__c 
                 where Maintenance_Request__c IN : caseIdsList];  
            if(!equipMainList.isEmpty()){          
                for(Equipment_Maintenance_Item__c equipMainn : equipMainList){  
                    EquipMainItemsToProdIds.put(equipMainn,equipMainn.Equipment__c); 
                    system.debug(EquipMainItemsToProdIds.size()); 
                    if(EquipMainItemsToProdIds.size() > 1){ 
                        count = EquipMainItemsToProdIds.size(); 
                    }           
                }         
            }      
            List<Equipment_Maintenance_Item__c> EMIList = 
                [Select Equipment__r.Maintenance_Cycle__c,Equipment__c
                 from Equipment_Maintenance_Item__c 
                 where Equipment__r.Id IN :EquipMainItemsToProdIds.values()
                 AND Maintenance_Request__c IN:caseIdsList order
                 By Equipment__r.Maintenance_Cycle__c ASC limit 1]; 
            for(Equipment_Maintenance_Item__c equip : EMIList){
                toGetDueDateMap.put(equip.Id,Integer.valueOf(equip.Equipment__r.Maintenance_Cycle__c));
                for(Case c : caseIdsList){ 
                    Case mainRe = new Case(); 
                    mainRe.Vehicle__c = c.Vehicle__c; 
                    mainRe.status = 'New';   
                    mainRe.Type = 'Routine Maintenance';  
                    mainRe.Subject = 'New Main Request For Vehicle for Apex Specialist';
                    mainRe.Date_Reported__c = date.today(); 
                    if(count > 1){ 
                        mainRe.Date_Due__c = Date.today().addDays(toGetDueDateMap.get(equip.Id));
                    }                     else{  
                        mainRe.Date_Due__c = Date.today();
                    }                     
                    createNewMainReq.add(mainRe); 
                    newCasesToIdsMap.put(c.Id,mainRe); 
                }                  
                insert createNewMainReq; 
                if(caseIdsList.size()>0 && newCasesToIdsMap.size()>0){
                    cloneEquipItems(caseIdsList,newCasesToIdsMap); 
                }            
            }    
        }     
        public static void cloneEquipItems(List<case> closedCaseRecords, Map<Id,case> newCreatedCasesMapp){  
            List<Equipment_Maintenance_Item__c> newEquipItems = new List<Equipment_Maintenance_Item__c>();
            try{            
                if(!closedCaseRecords.isEmpty() && newCreatedCasesMapp.size()>0){ 
                    List<Equipment_Maintenance_Item__c> oldEquipItems =
                        [SELECT Equipment__c, Maintenance_Request__c, Quantity__c,Maintenance_Request__r.Id  
                         FROM Equipment_Maintenance_Item__c
                         WHERE  Maintenance_Request__c IN :closedCaseRecords];  
                    for(Equipment_Maintenance_Item__c equipItem : oldEquipItems) { 
                        Equipment_Maintenance_Item__c newItem = equipItem.clone(false, true, false, false);
                        newItem.Maintenance_Request__c = newCreatedCasesMapp.get(equipItem.Maintenance_Request__c).id;
                        newEquipItems.add(newItem); 
                    }
                    insert newEquipItems;
                }         
            }         
            catch(Exception e) { 
                System.debug('Exception is'+ e);
            }    
        } 
    }

    
            
            
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        /*Deploing... It works! One more time
        

public with sharing class MaintenanceRequestHelper {    

public static void updateWorkOrders() {
List<Case> caseList =Trigger.New;

Map<String,Integer> IDToCycleMap = getMinMaintenanceCycleByCaseID(caseList);        

List<case> newCasesList = new List<Case>();        

for(Case oldCase : caseList){

if(oldCase.status=='closed' && (oldCase.type=='Repair' || oldCase.type=='Routine Maintenance')){

Case newCase = new Case();

newCase.Status = 'New';

newCase.Origin = 'web';

newCase.Type = 'Routine Maintenance';

newCase.Subject = 'Routine Maintenance of Vehicle';

newCase.Vehicle__c = oldCase.Vehicle__c;

newCase.Date_Reported__c = Date.today();

newcase.Cloned_Case_Id__c = oldCase.Id;

newCase.Date_Due__c = IDToCycleMap.get(oldCase.Id) == null ? Date.today() : Date.today()+IDToCycleMap.get(oldCase.Id);           

newCasesList.add(newCase);

}

}       

insert newCasesList;             

updateEquipments(newCasesList);

}



//update Equipments : Reparent them with new Case

public static void updateEquipments(List<Case> newCasesList){

List<Equipment_Maintenance_Item__c> equipmentsList = [select ID, Maintenance_Request__c from Equipment_Maintenance_Item__c];

List<Equipment_Maintenance_Item__c> updatedEquipmentsList  = new List<Equipment_Maintenance_Item__c>();

for(Case c : newCasesList){

for(Equipment_Maintenance_Item__c e : equipmentsList ){

if(e.Maintenance_Request__c == c.Cloned_Case_Id__c){

e.Maintenance_Request__c = c.Id;

updatedEquipmentsList.add(e);

}

}

}

update updatedEquipmentsList;

}



//Get min Maintenance Cycle by  Case IDs    

public static Map<String,Integer> getMinMaintenanceCycleByCaseID(List<Case> caseList){

Map<String,Integer> IDToCycleMap = new Map<String,Integer>();

List<String> CaseIDList = new List<String>();   

for(Case eachCase  : caseList){

caseIDList.add(eachCase.ID);

}

List<AggregateResult> result =[SELECT Maintenance_Request__r.ID CaseID, MIN(Equipment__r.Maintenance_Cycle__c) 
Cycle FROM Equipment_Maintenance_Item__c WHERE 

Maintenance_Request__r.ID IN :caseIDList AND Equipment__r.Maintenance_Cycle__c != null group by Maintenance_Request__r.ID];



for(AggregateResult a : result){

IDToCycleMap.put((String)a.get('CaseID'),Integer.valueOf(a.get('Cycle')));

}

return IDToCycleMap;

}    

}

































/*
public with sharing class MaintenanceRequestHelper {

public static void updateWorkOrders() {

List <Case> caseList=  [SELECT Id,Type,Status,Vehicle__r.ID, 
(SELECT Equipment__c FROM Equipment_Maintenance_Items__r)
From Case WHERE (Id IN:Trigger.New AND 
Status ='Closed'And 
(Type = 'Repair' OR Type = 'Routine Maintenance'))
ORDER by Case.id	];

System.debug(caseList);


List<AggregateResult> emiListCycle = [SELECT Min(Equipment__r.Maintenance_Cycle__c)m,Maintenance_Request__r.id

From Equipment_Maintenance_Item__c 
WHERE ((Maintenance_Request__r.Type = 'Repair' OR
Maintenance_Request__r.Type = 'Routine Maintenance') AND
Maintenance_Request__r.Status ='Closed' AND
Maintenance_Request__r.ID IN:caseList)
group by Maintenance_Request__r.id
ORDER by Maintenance_Request__r.id  ];

System.debug(emiListCycle);

List<Equipment_Maintenance_Item__c> equipmentQuantityList = [SELECT Maintenance_Request__r.id,
Equipment__c.Id,Quantity__c
FROM Equipment_Maintenance_Item__c
WHERE ( Maintenance_Request__r.ID IN:caseList)

ORDER by Maintenance_Request__r.id  ];

System.debug(equipmentQuantityList);






List<Case> newCases = new List<Case>();
List<Equipment_Maintenance_Item__c> newEmis =new List<Equipment_Maintenance_Item__c>();

for(Integer i = 0;i<caseList.size();i++){ 


String requestType = caseList.get(i).Type;
String requestStatus = caseList.get(i).Status;
String requestVehicle = caseList.get(i).Vehicle__c;
//LIst<Product2> equipmentList = caseList.get(i).Equipment_Maintenance_Items__r.Equipment__c;
Integer min = Integer.valueOf((emiListCycle.get(i)).get('m'));


System.debug(requestType);  
System.debug(requestStatus); 
System.debug(requestVehicle); 
System.debug((emiListCycle.get(i)).get('m'));

Case newCase = new Case(Type = 'Routine Maintenance',
Vehicle__c = requestVehicle, 
Subject = 'Auto created Subject From'+caseList.get(i).id,
Date_Reported__c = Date.today(),
Date_Due__c = Date.today().addDays(min)); 
newCases.add(newCase);
}
insert newCases;


for(Integer i=0;i<newCases.size();i++){
Equipment_Maintenance_Item__c newEmi = 
new Equipment_Maintenance_Item__c(                                                
Maintenance_Request__c=newCases.get(i).id,

Equipment__c =equipmentQuantityList.get(i).Equipment__c;

// Quantity__c =	
System.debug(equipmentQuantityList.get(i).Equipment__c);
System.debug(equipmentQuantityList.get(i));
newEmis.add(newEmi);				   

}
insert newEmis;

}
}

*/ 
        
        //Equipment_Maintenance_Items
        
        
        
        
        /*    System.debug('End + newCases  '+ newCases.size());

for(Integer k = 0; k<newCases.size();k++){
System.debug('Id '+ newCases.get(k).id);
System.debug('Maintenance_request__c '+ newEmis.get(k).id);    

newEmis.get(k).Maintenance_request__c = newCases.get(k).id;
}
System.debug('End +newEmis  '+newEmis.size());   */
        
        
        
        
        
        
        /*       




///NEW!!! 

List<Case> cases = [SELECT Id,Type,Status,Vehicle__r.ID,(SELECT Equipment__c,Quantity__c FROM Equipment_Maintenance_Items__r)
From Case WHERE Id IN: Trigger.New];

Case triggerCase = cases.get(0);
String mRtype = triggerCase.Type;
String mRstatus = triggerCase.Status;
Id mRvehicleID = triggerCase.Vehicle__r.ID;

List<Equipment_Maintenance_Item__c> maintenanceItems =
triggerCase.Equipment_Maintenance_Items__r;
(mRtype == 'Repair' || mRtype =='Routine Maintenance')&& mRstatus == 'Closed' ){

Case newCase = new Case(Type = 'Routine Maintenance',
Vehicle__c = mRvehicleID, 
Subject = 'Auto created Subject',
Date_Reported__c = Date.today(),
Date_Due__c = Date.today().addDays(MaintenanceRequestHelper.minCycle(maintenanceItems)));       

insert newCase;         

List<Equipment_Maintenance_Item__c> newEmiList =new List <Equipment_Maintenance_Item__c>();   


for(Equipment_Maintenance_Item__c emi :maintenanceItems){
Equipment_Maintenance_Item__c newEmi =
new Equipment_Maintenance_Item__c( Maintenance_request__c = newCase.id,
Equipment__c =emi.Equipment__c ,
Quantity__c = emi.Quantity__c); 

newEmiList.add(newEmi); 
} 

insert newEmiList;

}
} 
private static Integer minCycle (List<Equipment_Maintenance_Item__c> listOfEmi){

Decimal min = [SELECT Maintenance_Cycle__c From Product2 Where ID =:listOfEmi.get(0).Equipment__c].get(0).Maintenance_Cycle__c ;
for (Integer i = 1;i<listofEmi.size();i++){
if(min > [SELECT Maintenance_Cycle__c From Product2 Where ID =:listOfEmi.get(i).Equipment__c].get(0).Maintenance_Cycle__c ) {
min = [SELECT Maintenance_Cycle__c From Product2 Where ID =:listOfEmi.get(i).Equipment__c].get(0).Maintenance_Cycle__c ;
}
}

return min.intValue();
}

}
List <Equipment_Maintenance_Item__c> emiList=  [SELECT //Maintenance_Request__r.Id,
Maintenance_Request__r.Type,
Maintenance_Request__r.Status,
Maintenance_Request__r.Vehicle__c,
Equipment__r.Id,
Quantity__c

From Equipment_Maintenance_Item__c 
WHERE 
((Maintenance_Request__r.Type = 'Repair' OR
Maintenance_Request__r.Type = 'Routine Maintenance') AND
Maintenance_Request__r.Status ='Closed' AND
Maintenance_Request__C IN:Trigger.New) ];

//            if( (requestType == 'Repair' || requestType =='Routine Maintenance')&& requestStatus == 'Closed' ){





*/