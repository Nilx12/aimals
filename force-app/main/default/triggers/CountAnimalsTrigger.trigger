trigger CountAnimalsTrigger on Animal__c (before delete, after insert) {
    Set<Id> animalIds = new Set<Id>();
    Integer addOrSubtractRecordFlag = 1;
    if (Trigger.isInsert) {
        animalIds.addAll(Trigger.newMap.keySet());
    }
    if (Trigger.isDelete) {
        addOrSubtractRecordFlag = -1;
        animalIds.addAll(Trigger.oldMap.keySet());
    }

    List<Animal__c> animals = [SELECT Id, Account__c FROM Animal__c WHERE Id IN :animalIds];
    System.debug(animals.size());

    List<Id> accountIdsRelatedToAnimals = new List<Id>();
    for (Animal__c animal: animals) {
        Id accountId = animal.Account__c;
        accountIdsRelatedToAnimals.add(accountId);
    }

    Map<Id,Account> accountsToUpdateMap = new Map<Id,Account>();
    for (Account account: [SELECT Id, Animal_Count__c, Unadopted_Virtually_Count__c
                            FROM Account WHERE Id IN :accountIdsRelatedToAnimals]) {
        accountsToUpdateMap.put(account.Id, account);
    }
    System.debug(accountsToUpdateMap.size());

    for (Animal__c animal: animals) {
        Id accountId = animal.Account__c;
        Account account = accountsToUpdateMap.get(accountId);
        if (account.Animal_Count__c == null) {
            account.Animal_Count__c = 0;
        }
        if (account.Unadopted_Virtually_Count__c == null) {
            account.Unadopted_Virtually_Count__c = 0;
            //account.Unadopted_Virtually_Count__c = [SELECT COUNT() FROM Animal__c WHERE Account__r.Id = :accountId];
        }
        account.Unadopted_Virtually_Count__c += (1 * addOrSubtractRecordFlag);
        account.Animal_Count__c += (1 * addOrSubtractRecordFlag);
    }

    if (accountsToUpdateMap.size() > 0) {
        update accountsToUpdateMap.values();
    }
}