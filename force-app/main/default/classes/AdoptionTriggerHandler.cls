public with sharing class AdoptionTriggerHandler {

    public void beforeDelete(Map<Id, Adoption__c> oldRecordsMap){
        this.updateCount(oldRecordsMap.keySet(),-1);
    }

    public void afterUndelete(List<Adoption__c> newRecords, Map<Id, Adoption__c> newRecordsMap) {
        updateCount(newRecordsMap.keySet(), 1);

        Set<Id> animalIds = getAnimalIdsFromAdoptions(newRecords);
        countUnadoptedVirtuallyAnimals(animalIds);
    }

    public void afterInsert(List<Adoption__c> newRecords, Map<Id, Adoption__c> newRecordsMap) {
        updateCount(newRecordsMap.keySet(),1);

        animalFoodPoints(newRecordsMap.keySet());

        Set<Id> animalIds = getAnimalIdsFromAdoptions(newRecords);
        countUnadoptedVirtuallyAnimals(animalIds);
    }

    public void afterUpdate(List<Adoption__c> newRecords, Map<Id, Adoption__c> newRecordsMap,
            List<Adoption__c> oldRecords, Map<Id, Adoption__c> oldRecordsMap) {

        sendEmailAfterStatusChange(oldRecordsMap.keySet(), oldRecords);

        Set<Id> adoptionIds = getAdoptionIdsWithDifferentRecordTypes(oldRecords, newRecords);
        animalFoodPoints(adoptionIds);

        Set<Id> animalIds = getAnimalIdsWithDifferentRecordTypes(oldRecords, newRecords);
        countUnadoptedVirtuallyAnimals(animalIds);
    }

    public void afterDelete(List<Adoption__c> oldRecords, Map<Id, Adoption__c> oldMap) {
        Set<Id> animalIds = getAnimalIdsFromAdoptions(oldRecords);
        countUnadoptedVirtuallyAnimals(animalIds);
    }

    private void animalFoodPoints(Set<Id> adoptionIds) {
        List<Adoption__c> newAdoptions = [SELECT Id, RecordTypeId, Contact__c FROM Adoption__c WHERE Id IN :adoptionIds];

        List<Id> contactIdsAssociatedWithNewAdoption = new List<Id>();
        for (Adoption__c adoption: newAdoptions) {
            Id contactId = adoption.Contact__c;
            contactIdsAssociatedWithNewAdoption.add(contactId);
        }

        Map<Id,Contact> contactsWithNewAdoptionMap = new Map<Id, Contact>();
        for (Contact contact: [SELECT Id, Adoption_Points__c, Free_Animal_Food__c
        FROM Contact WHERE Id IN :contactIdsAssociatedWithNewAdoption]) {
            contactsWithNewAdoptionMap.put(contact.Id, contact);
        }

        Id realAdoptionRecordTypeId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'Real' LIMIT 1].Id;
        for (Adoption__c adoption: newAdoptions) {
            Id contactId = adoption.Contact__c;
            Contact contact = contactsWithNewAdoptionMap.get(contactId);
            contact.Adoption_Points__c += 10;
            if (adoption.RecordTypeId.equals(realAdoptionRecordTypeId)) {
                contact.Adoption_Points__c += 10;
            }

            if (contact.Free_Animal_Food__c.equals('Unavailable') && contact.Adoption_Points__c >= 30) {
                contact.Free_Animal_Food__c = 'Available';
            }
        }

        if (contactsWithNewAdoptionMap.size() > 0) {
            update contactsWithNewAdoptionMap.values();
        }
    }


    private void countUnadoptedVirtuallyAnimals(Set<Id> animalIds) {
        List<Animal__c> animals = [SELECT Account__c FROM Animal__c WHERE Id IN :animalIds];
        List<Id> accountIdsRelatedToAnimal = new List<Id>();
        for (Animal__c animal: animals) {
            accountIdsRelatedToAnimal.add(animal.Account__c);
        }

        Map<Id, Account> accountsRelatedToAnimalMap = new Map<Id, Account>();
        for (Account account: [SELECT Id, Animal_Count__c, Unadopted_Virtually_Count__c
        FROM Account WHERE Id IN :accountIdsRelatedToAnimal]) {
            account.Unadopted_Virtually_Count__c = account.Animal_Count__c;
            accountsRelatedToAnimalMap.put(account.Id, account);
        }

        //Id virtualAdoptionRecordType = Schema.getGlobalDescribe().get(Adoption).getDescribe().getRecordTypeInfosByDeveloperName().get('Virtual').recordTypeId;
        Id virtualAdoptionRecordTypeId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'Virtual' LIMIT 1].Id;
        List<Adoption__c> virtualAdoptionsRelatedToAccounts = [SELECT Id, Animal__c, Animal__r.Account__c FROM Adoption__c
        WHERE Animal__r.Account__c IN :accountsRelatedToAnimalMap.keySet()
        AND RecordTypeId = :virtualAdoptionRecordTypeId];

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

    private void updateCount(Set<Id> resultIds,Integer value){
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
            Decimal ah = ac.Adoptions_Count__c;
            if (ah == null){
                ac.Adoptions_Count__c = 0;
            }
            ac.Adoptions_Count__c += value;
        }
        update accounts.values();
    }

    private void sendEmailAfterStatusChange(Set<Id> resultIds,List<Adoption__c> adopt){
        Map<Id,Adoption__c> adoptions = new Map<Id,Adoption__c>();
        for(Adoption__c a : adopt) {
            adoptions.put(a.Id, a);
        }
        for(Adoption__c a : [SELECT Id, Status__c, Contact__r.Email, Animal__r.Age__c,Animal__r.Breed__c,Animal__r.Sex__c, Contact__r.Id, Animal__r.Name FROM Adoption__c WHERE Id IN :resultIds]) {
            if(a.Status__c != adoptions.get(a.Id).Status__c){
                String text = 'Adoption status changed to '+ a.Status__c+'\n'+
                        'Animal: '+a.Animal__r.Breed__c+'\n';
                if(a.Animal__r.Age__c != null){
                    text = text +'\t Age: '+a.Animal__r.Age__c+'\n';
                }
                text = text +'\t Name: '+a.Animal__r.Name+'\n'+'\t Sex: '+a.Animal__r.Sex__c;

                EmailManager.sendEmail(a.Contact__r.Email, 'Adoption status changed', text);
            }
        }
    }

    private Set<Id> getAnimalIdsFromAdoptions(List<Adoption__c> records) {
        Set<Id> animalIds = new Set<Id>();
        for (Adoption__c adoption: records) {
            animalIds.add(adoption.Animal__c);
        }

        return animalIds;
    }

    private Set<Id> getAdoptionIdsWithDifferentRecordTypes(List<Adoption__c> oldRecords, List<Adoption__c> newRecords) {
        Set<Id> adoptionIds = new Set<Id>();
        Map<Id, Id> adoptionIdRecordTypeIdMap = new Map<Id, Id>();
        for (Adoption__c oldAdoption: oldRecords) {
            adoptionIdRecordTypeIdMap.put(oldAdoption.Id, oldAdoption.RecordTypeId);
        }
        for (Adoption__c newAdoption: newRecords) {
            Id oldRecordTypeId = adoptionIdRecordTypeIdMap.get(newAdoption.Id);
            if (oldRecordTypeId != newAdoption.RecordTypeId) {
                adoptionIds.add(newAdoption.Id);
            }
        }

        return adoptionIds;
    }

    private Set<Id> getAnimalIdsWithDifferentRecordTypes(List<Adoption__c> oldRecords, List<Adoption__c> newRecords) {
        Set<Id> animalIds = new Set<Id>();
        Map<Id, Id> adoptionIdRecordTypeIdMap = new Map<Id,Id>();
        for (Adoption__c oldAdoption: oldRecords) {
            adoptionIdRecordTypeIdMap.put(oldAdoption.Id, oldAdoption.RecordTypeId);
        }
        for (Adoption__c newAdoption: newRecords) {
            Id oldRecordTypeId = adoptionIdRecordTypeIdMap.get(newAdoption.Id);
            if (oldRecordTypeId != newAdoption.RecordTypeId) {
                animalIds.add(newAdoption.Animal__c);
            }
        }

        return animalIds;
    }

}