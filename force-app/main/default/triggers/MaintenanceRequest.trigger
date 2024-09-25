trigger MaintenanceRequest on Case (after update) {
    
    List<Case> casesToInsert = new List<Case>();
    
    Set<Id> newCaseIds = new Set<Id>();
    Set<Equipment_Maintenance_Item__c> itemsToInsert = new Set<Equipment_Maintenance_Item__c>();

    Map<Id, Case> originalToNewCaseMap = new Map<Id, Case>();
    Map<Case, Set<Equipment_Maintenance_Item__c>> itemsToCaseMap = new Map<Case, Set<Equipment_Maintenance_Item__c>>();

    Date due = Date.Today(); 
    
    for(Case newCase : Trigger.new){
        Case oldCase = Trigger.oldMap.get(newCase.Id);
        if((newCase.Type == Constants.CASE_TYPE_REPAIR || newCase.Type == Constants.CASE_TYPE_ROUTINE_MAINTENANCE) && oldCase.Status != newCase.Status && newCase.Status == Constants.CASE_STATUS_CLOSED){      
            
            newCaseIds.add(newCase.Id);     
        }          
    }
    

    Map<Id, List<Equipment_Maintenance_Item__c>> caseIdToItemsMap = new Map<Id, List<Equipment_Maintenance_Item__c>>();

    
        List<Equipment_Maintenance_Item__c> items = [
            SELECT Id, Equipment__r.Id, Equipment__r.Maintenance_Cycle__c, Maintenance_Request__r.Id
            FROM Equipment_Maintenance_Item__c 
            WHERE Maintenance_Request__r.Id =: newCaseIds 
            ORDER BY Equipment__r.Maintenance_Cycle__c ASC];      
    

    for(Equipment_Maintenance_Item__c item : items){
        if(!caseIdToItemsMap.containsKey(item.Maintenance_Request__r.Id)){
            caseIdToItemsMap.put(item.Maintenance_Request__r.Id, new List<Equipment_Maintenance_Item__c>());
        }
        caseIdToItemsMap.get(item.Maintenance_Request__r.Id).add(item);
    }
    

    for(Case newCase : Trigger.new){
        if(caseIdToItemsMap.containsKey(newCase.Id)){
            List<Equipment_Maintenance_Item__c> items = caseIdToItemsMap.get(newCase.Id);

        if(items.size() > 0){
            due = Date.Today().addDays(items.get(0).Equipment__r.Maintenance_Cycle__c.intValue());
        }

        Case cs = new Case(
        Type = Constants.CASE_TYPE_ROUTINE_MAINTENANCE, 
        Subject = Constants.CASE_TYPE_ROUTINE_MAINTENANCE, 
        Date_Reported__c = Date.Today(),
        Date_Due__c = due,
        Vehicle__c = newCase.Vehicle__c
        ); 

        casesToInsert.add(cs); 
        originalToNewCaseMap.put(newCase.Id, cs);  
        
        for(Equipment_Maintenance_Item__c it : items){
            Equipment_Maintenance_Item__c newItem = new Equipment_Maintenance_Item__c();
            newItem.Equipment__c = it.Equipment__c;
            itemsToInsert.add(newItem);
            itemsToCaseMap.put(originalToNewCaseMap.get(newCase.Id), itemsToInsert);
        }
        
        }
    }    
    
    if(!casesToInsert.isEmpty()){
        insert casesToInsert;
    }         

    List<Equipment_Maintenance_Item__c> finalItemsToInsert = new List<Equipment_Maintenance_Item__c>();

    for (Case caseRecord : itemsToCaseMap.keySet()) {
        Set<Equipment_Maintenance_Item__c> maintenanceItems = itemsToCaseMap.get(caseRecord);       
        for (Equipment_Maintenance_Item__c item : maintenanceItems) {
            item.Maintenance_Request__c = caseRecord.Id;
            finalItemsToInsert.add(item);
        }
    }
    
    insert finalItemsToInsert;

}