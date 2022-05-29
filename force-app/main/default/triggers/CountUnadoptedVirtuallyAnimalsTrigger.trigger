trigger CountUnadoptedVirtuallyAnimalsTrigger on Adoption__c (after insert, after update, after undelete, after delete) {
    Set<Id> animalIds = new Set<Id>();
    if (Trigger.isInsert || Trigger.isUndelete || Trigger.isUpdate) {
        for (Adoption__c adoption: Trigger.new) {
            animalIds.add(adoption.Animal__c);
        }
    }
    if (Trigger.isDelete) {
       for (Adoption__c adoption: Trigger.old) {
            animalIds.add(adoption.Animal__c);
       }
    }

    List<Animal__c> animals = [SELECT Account__c FROM Animal__c WHERE Id IN :animalIds];
    List<Id> accountIdsRelatedToAnimal = new List<Id>();
    for (Animal__c animal: animals) {
        accountIdsRelatedToAnimal.add(animal.Account__c);
    }

    Map<Id, Account> accountsRelatedToAnimalMap = new Map<Id, Account>();
    for (Account account: [SELECT Id, Animal_Count__c, Unadopted_Virtually_Count__c
    						FROM Account WHERE Id IN :accountIdsRelatedToAnimal]) {
        account.Unadopted_Virtually_Count__c = account.Animal_Count__C;
        accountsRelatedToAnimalMap.put(account.Id, account);
    }

    RecordType virtualAdoptionRecordType = [SELECT Id FROM RecordType WHERE RecordType.Name = 'Virtual' LIMIT 1];
    List<Adoption__c> virtualAdoptionsRelatedToAccounts = [SELECT Id, Animal__c, Animal__r.Account__c FROM Adoption__c
                                                    WHERE Animal__r.Account__c IN :accountsRelatedToAnimalMap.keySet()
                                                    AND RecordTypeId = :virtualAdoptionRecordType.Id];

    Set<Id> checkedAnimalIds = new Set<Id>();
    Set<Adoption__c> virtualAdoptionsWithUniqueAnimals = new Set<Adoption__c>();
    for (Adoption__c adoption: virtualAdoptionsRelatedToAccounts) {
        if (!checkedAnimalIds.contains(adoption.Animal__c)) {
            virtualAdoptionsWithUniqueAnimals.add(adoption);
            checkedAnimalIds.add(adoption.Animal__c);
        }
    }

    for (Adoption__c adoption: virtualAdoptionsWithUniqueAnimals) {
        Id accountId = adoption.Animal__r.Account__c;
        Account account = accountsRelatedToAnimalMap.get(accountId);
        account.Unadopted_Virtually_Count__c -= 1;
    }

    if (accountsRelatedToAnimalMap.size() > 0) {
        update accountsRelatedToAnimalMap.values();
    }
}