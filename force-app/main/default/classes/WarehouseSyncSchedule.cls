public with sharing class WarehouseSyncSchedule implements Schedulable {
    public void execute(System.SchedulableContext sc){
        System.enqueueJob(new WarehouseCalloutService());
       }

}