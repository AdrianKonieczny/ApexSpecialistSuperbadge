@isTest
public with sharing class MaintenanceRequestHelperTest {
    
    @TestSetup
    public static void makeData(){
        
        Vehicle__c testVehicle = new Vehicle__c(
            Name = 'Porshe Camper',
            Model__c = 'Turbo S'
        );

        insert testVehicle;

        Product2 testEquipment = new Product2 (
            Name = 'UPS 20 VA',
            Maintenance_Cycle__c = 20,
            Description = 'Turbo',
            Replacement_Part__c = true
        );
        insert testEquipment;
        
        Case testCase = new Case(
            Type = Constants.CASE_TYPE_REPAIR,
            Status = 'New',
            Origin = 'Email',
            Vehicle__r = testVehicle
        );

        insert testCase;


        Equipment_Maintenance_Item__c testItem = new Equipment_Maintenance_Item__c(
            Maintenance_Request__c = testCase.Id,
            Equipment__c = testEquipment.Id
        );

        insert testItem;
    }


    @isTest
    private static void shouldCreateMaintenanceRequest(){

        Case testCase = [SELECT Id, Type, Status, Vehicle__c FROM Case WHERE Type =: Constants.CASE_TYPE_REPAIR AND Status !=: Constants.CASE_STATUS_CLOSED LIMIT 1];

        Test.startTest();
        testCase.Status = Constants.CASE_STATUS_CLOSED;
        update testCase;        
        Test.stopTest();

        List<Case> cases = [SELECT Id, Type, Status, Vehicle__c FROM Case];      
        List<Equipment_Maintenance_Item__c> items = [SELECT Id, Maintenance_Request__c, Equipment__c FROM Equipment_Maintenance_Item__c];

        Map<Id, List<Equipment_Maintenance_Item__c>> testCaseItems = new Map<Id, List<Equipment_Maintenance_Item__c>>();
        Map<Id, List<Equipment_Maintenance_Item__c>> newCaseItems = new Map<Id, List<Equipment_Maintenance_Item__c>>();
        
        Id newCaseId;

        for(Case cs : cases){
            if(cs.Id == testCase.Id){
                testCaseItems.put(cs.Id, new List<Equipment_Maintenance_Item__c>());
            }else{
                newCaseId = cs.Id;
                newCaseItems.put(cs.Id, new List<Equipment_Maintenance_Item__c>());
            }
        }

        for(Equipment_Maintenance_Item__c it : items){
            if(it.Maintenance_Request__c == testCase.Id){
                testCaseItems.get(testCase.Id).add(it);
            }
            if(it.Maintenance_Request__c != testCase.Id){
                newCaseItems.get(it.Maintenance_Request__c).add(it);
            }        
        }
        System.assertEquals(2, cases.size());
        System.assertEquals(testCaseItems.get(testCase.Id).size(), newCaseItems.get(newCaseId).size());  
    }

    @isTest
    private static void shouldNotCreateMaintenanceRequest(){
        
        Case testCase = [SELECT Id, Type, Status, Vehicle__c FROM Case WHERE Type =: Constants.CASE_TYPE_REPAIR AND Status !=: Constants.CASE_STATUS_CLOSED LIMIT 1];

        Test.startTest();
        testCase.Status = 'Working';
        update testCase;        
        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case];

        System.assertEquals(1, cases.size());
    }

    @isTest
    private static void shouldCreateMaintenanceRequestBulk(){
        
        List<Case> casesToInsert = new List<Case>();
        List<Equipment_Maintenance_Item__c> itemsToInsert = new List<Equipment_Maintenance_Item__c>();
        
        Vehicle__c tstVehicle = new Vehicle__c(
            Name = 'Porshe Camper',
            Model__c = 'Turbo S'
        );

        insert tstVehicle;

        Product2 tstEquipment = new Product2 (
            Name = 'UPS 20 VA',
            Maintenance_Cycle__c = 20,
            Description = 'Turbo',
            Replacement_Part__c = true
        );
        insert tstEquipment;
        
        
        for(Integer i = 0; i < 250; i++){
            Case tstCase = new Case(
                Type = Constants.CASE_TYPE_REPAIR,
                Status = 'New',
                Origin = 'Email',
                Vehicle__r = tstVehicle
            );
            casesToInsert.add(tstCase);
        }
        
        insert casesToInsert;


        for(Case cs : casesToInsert){
            Equipment_Maintenance_Item__c tstItem = new Equipment_Maintenance_Item__c(
            Maintenance_Request__c = cs.Id,
            Equipment__c = tstEquipment.Id
            );
            itemsToInsert.add(tstItem);
        }

        insert itemsToInsert;

        Test.startTest();
        for(Case cs : casesToInsert){
            cs.Status = Constants.CASE_STATUS_CLOSED;
        }
        update casesToInsert;
        Test.stopTest();

        List<Case> updatedCases = [SELECT Id FROM Case];

        System.assertEquals(501, updatedCases.size());
    }
}