@isTest
public with sharing class WarehouseSyncScheduleTest {
    private static String jobName ='Warehouse Sync Schedule';
    private static Final String CRON_EXP ='0 0 0 3 9 ? 2022';
    private static CronTrigger ct;
 @isTest
    public static void testCalloutService(){
        
        
    System.assertEquals(0,[Select count()From Product2],'');
        Test.startTest();
       Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock()); 
       String jobId = System.schedule(jobName, CRON_EXP, new WarehouseSyncSchedule());
        ct = [SELECT TimesTriggered,NextFireTime,CronExpression FROM CronTrigger WHERE Id =:jobId];
    ///check result before job done
    Test.stopTest();
        ///check result after job done
      System.assertEquals(CRON_EXP, ct.CronExpression);
      System.assertEquals(0, ct.TimesTriggered);
      System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
    }
}