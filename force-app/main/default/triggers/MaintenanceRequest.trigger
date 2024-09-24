trigger MaintenanceRequest on Case (after update) {
    
    List<Case> casesToInsert = new List<Case>();
    
    for(Case newCase : Trigger.new){
        Case oldCase = Trigger.oldMap.get(newCase.Id);
        if((newCase.Type == Constants.CASE_TYPE_REPAIR || newCase.Type == Constants.CASE_TYPE_ROUTINE_MAINTENANCE) && (oldCase.Status != Constants.CASE_STATUS_CLOSED && newCase.Status == Constants.CASE_STATUS_CLOSED)){
            
            Date due = Date.Today();
            
            List<Equipment_Maintenance_Item__c> items = 
            [SELECT 
            Id, Equipment__r.Maintenance_Cycle__c
            FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c =: newCase.CaseNumber ORDER BY Equipment__r.Maintenance_Cycle__c ASC];
            
            

            if(items.size() > 0){
                due = Date.Today().addDays(items.get(0).Equipment__r.Maintenance_Cycle__c.intValue());
            }
            


            Case cs = new Case(
                Type = Constants.CASE_TYPE_ROUTINE_MAINTENANCE, 
                Subject = Constants.CASE_TYPE_ROUTINE_MAINTENANCE, 
                Date_Reported__c = Date.Today(),
                Date_Due__c = due
            );

            casesToInsert.add(cs);     
        }     
    }
    insert casesToInsert;
}