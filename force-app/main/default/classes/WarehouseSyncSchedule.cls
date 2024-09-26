global with sharing class WarehouseSyncSchedule implements Schedulable {
    
    global static void execute(SchedulableContext sc) { 
        System.enqueueJob(new WarehouseCalloutService());
    }

    public static void WarehouseSyncScheduleJob(){

        String cronExp = '0 0 1 * * ?';
        System.schedule('WarehouseSyncScheduleJob', cronExp, new WarehouseSyncSchedule());
    }
}
