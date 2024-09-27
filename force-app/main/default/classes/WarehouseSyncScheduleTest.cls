@IsTest
public with sharing class WarehouseSyncScheduleTest {
    
    @istest
    static void shouldEnqueueJob(){

        test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        List<CronTrigger> before = [SELECT TimesTriggered, NextFireTime FROM CronTrigger];

        Test.startTest();
        
        WarehouseSyncSchedule.WarehouseSyncScheduleJob();
        Test.stopTest();

        List<CronTrigger> after = [SELECT TimesTriggered, NextFireTime FROM CronTrigger];

        System.assertEquals(before.size() + 1, after.size());  
    }
}