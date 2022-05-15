trigger CountAdoptionsTrigger on Adoption__c (before insert) {

    Set<Id> resultIds = (new Map<Id,SObject>(Trigger.New)).keySet();
    List<Id> accIds = new List<Id>();
    List<Adoption__c> adoptions = [SELECT Id,Animal__r.Account__c, Animal__r.Account__r.Adoptions_Count__c FROM Adoption__c WHERE Id IN :resultIds];
    
    for(Adoption__c a: adoptions){
        Id ac = a.Animal__r.Account__c;
        accIds.add(ac);
    }
    
    
   	Map<id,Account> accounts = new Map<id,Account>();
    for( Account a:[SELECT id, Adoptions_Count__c FROM Account WHERE id IN :accIds]){
    	 accounts.put(a.id, a);
    }
    
    for(Adoption__c a: adoptions){
        Id id = a.Animal__r.Account__c;
        Account ac = accounts.get(id);
        ac.Adoptions_Count__c+=1;
    }
    update accounts.values();
}