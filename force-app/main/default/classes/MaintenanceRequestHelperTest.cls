@isTest

public with sharing class MaintenanceRequestHelperTest {

    @testSetup static void setup(){
        List<Case> caselist = new List<Case>();
        List<Case> secondList = new List<Case>();
        Account acc = new Account();
        acc.Name='AccName';
        insert acc;

        

        Contact con = new Contact();
        con.FirstName = 'FirstNameCon';
        con.LastName = 'LastNameCon';
        con.AccountId = acc.Id;
        insert con;

        

        Vehicle__c vehicle  = new Vehicle__c();
        vehicle.Name = 'Camper';
        insert vehicle;

        Product2 product = new Product2();

        product.Name = 'Product';
        product.Maintenance_Cycle__c = 15;
        product.isActive = true;
        product.Replacement_Part__c = true;
        insert product;

      

        Product2 product1 = new Product2();
        product1.Name = 'Product1';
        product1.Maintenance_Cycle__c = 5;
        product1.isActive = true;
        product1.Replacement_Part__c = true;
        insert product1;

        

        Case mainReq  =  new Case();
        mainReq.Vehicle__c = vehicle.Id;
        mainReq.Status = 'Other';
        mainReq.Type = 'Repair';
        mainReq.Subject = 'Maintenance Case';
        insert mainReq;

     /*   

        Case mainReq1  =  new Case();

        mainReq1.Vehicle__c = vehicle.Id;

        mainReq1.Status = 'Other';

        mainReq1.Type = 'New';

        mainReq1.Subject = 'Maintenance Case1';

          insert mainReq1;

        

        Case mainReq2  =  new Case();

        mainReq2.Vehicle__c = vehicle.Id;

        mainReq2.Status = 'Other';

        mainReq2.Type = 'New';

        mainReq2.Subject = 'Maintenance Case1';

        mainReq2.Date_Due__c = Date.today();

        insert mainReq2;

         */

        Equipment_Maintenance_Item__c emc1 = new Equipment_Maintenance_Item__c();
        emc1.Maintenance_Request__c = mainReq.Id;
        emc1.Equipment__c = product.Id;
        emc1.Quantity__c = 10;
        insert emc1;

        

        Equipment_Maintenance_Item__c emc1b = new Equipment_Maintenance_Item__c();
        emc1b.Maintenance_Request__c = mainReq.Id;
        emc1b.Equipment__c = product1.Id;
        emc1b.Quantity__c = 10;
        insert emc1b;

   /*     

        Equipment_Maintenance_Item__c emc2 = new Equipment_Maintenance_Item__c();

        emc2.Maintenance_Request__c = mainReq1.Id;

        emc2.Equipment__c = product.Id;

        emc2.Quantity__c = 78;    

            insert emc2;

        

                Equipment_Maintenance_Item__c emc3 = new Equipment_Maintenance_Item__c();

        emc3.Maintenance_Request__c = mainReq2.Id;

        emc3.Equipment__c = product.Id;

        emc3.Quantity__c = 78;    

            insert emc3;

       */ 

        caseList.add(mainReq);

   //     caseList.add(mainReq1);

   //     caseList.add(mainReq2);

    }

        @isTest static void testPositiveCase(){

        Test.startTest();

        System.debug('req2');

            List<Case> maintenanceRequest = [SELECT Id, Vehicle__c, Subject, Type, Status FROM Case WHERE Subject = 'Maintenance Case'];

            for (Case req:maintenanceRequest){
           System.debug('req');
                req.Status = 'Closed';
            }
            upsert maintenanceRequest;

        System.assertEquals(maintenanceRequest.size()>0,true,'Test');    
        Test.stopTest();
        }
}