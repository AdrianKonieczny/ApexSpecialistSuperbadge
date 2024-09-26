global with sharing class WarehouseCalloutServiceScheduled implements Schedulable {
    
    global static void execute(SchedulableContext sc) {

        System.enqueueJob(new WarehouseCalloutService());
    }
}