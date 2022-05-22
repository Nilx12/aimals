trigger AdoptionStatusTrigger on Adoption__c (after update) {
    
    //Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
    Map<id,Adoption__c> adoptions = new Map<id,Adoption__c>();
    Set<Id> resultIds = (new Map<Id,SObject>(Trigger.New)).keySet();
    for(Adoption__c a : Trigger.Old) {
    	adoptions.put(a.Id, a);
    }
    for(Adoption__c a : [SELECT Id, Status__c, Contact__r.Email, Animal__r.Age__c,Animal__r.Breed__c,Animal__r.Sex__c, Contact__r.Id, Animal__r.Name FROM Adoption__c WHERE Id IN :resultIds]) {
        if(a.Status__c != adoptions.get(a.Id).status__c){
            String text = 'Adoption status changed to '+ a.Status__c+'\n'+
                'Animal: '+a.Animal__r.Breed__c+'\n'+
                '\t Age: '+a.Animal__r.Age__c+'\n'+
                '\t Name: '+a.Animal__r.Name+'\n'+
                '\t Sex: '+a.Animal__r.Sex__c;
                
            EmailManager.sendEmail(a.Contact__r.Email, 'Adoption status changed', 
                       text);
        }
    }

}