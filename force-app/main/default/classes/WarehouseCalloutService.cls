global with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {
    
    global void execute(QueueableContext qc) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-superbadge-apex.herokuapp.com/equipment');
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if(response.getStatusCode() == 200){
            List<EquipmentHandler> results =  (List<EquipmentHandler>)JSON.deserialize(response.getBody(), List<EquipmentHandler>.class);

            List<Product2> equipmentToUpsert = new List<Product2>();

            for(EquipmentHandler equpiment : results){
                Product2 newProduct = new Product2();
                newProduct.Replacement_Part__c = equpiment.replacement;
                newProduct.Current_Inventory__c = equpiment.quantity;
                newProduct.Name = equpiment.name;
                newProduct.Maintenance_Cycle__c = equpiment.maintenanceperiod;
                newProduct.Lifespan_Months__c = equpiment.lifespan;
                newProduct.Cost__c = equpiment.cost;
                newProduct.Warehouse_SKU__c = equpiment.sku;
                equipmentToUpsert.add(newProduct);
            }
            
            if(!equipmentToUpsert.isEmpty()){
                upsert equipmentToUpsert Warehouse_SKU__c;
            }
        }  
    }   
}