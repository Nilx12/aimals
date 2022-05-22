trigger CountUnadoptedVirtuallyAnimalsTrigger on Adoption__c (after insert, after update, after undelete, before delete) {
    Set<Id> adoptionIds = new Set<Id>();
    if (Trigger.isInsert || Trigger.isUndelete || Trigger.isUpdate) {
        adoptionIds.addAll(Trigger.newMap.keySet());
    }
    if (Trigger.isDelete) {
        adoptionIds.addAll(Trigger.oldMap.keySet());
    }

    RecordType virtualAdoptionRecordType = [SELECT Id FROM RecordType WHERE RecordType.Name = 'Virtual' LIMIT 1];
    List<Adoption__c> realAdoptions = [SELECT Id,
            Animal__r.Account__c,
            Animal__r.Account__r.Id
    FROM Adoption__c
    WHERE Id IN :adoptionIds AND RecordTypeId <> :virtualAdoptionRecordType.Id];

    List<Id> idsOfAccountsRelatedToRealAdoptions = new List<Id>();
    for (Adoption__c realAdoption: realAdoptions) {
        Id accountId = realAdoption.Animal__r.Account__c;
        idsOfAccountsRelatedToRealAdoptions.add(accountId);
    }

    Map<Id,Account> accountsRelatedToRealAdoptionsMap = new Map<Id, Account>();
    for (Account account: [SELECT Id, Unadopted_Virtually_Count__c FROM Account WHERE Account.Id IN :idsOfAccountsRelatedToRealAdoptions]) {
        accountsRelatedToRealAdoptionsMap.put(account.Id, account);
    }

    for (Id accountId: idsOfAccountsRelatedToRealAdoptions) {
        Account account = accountsRelatedToRealAdoptionsMap.get(accountId);
        if (Trigger.isDelete) {
            account.Unadopted_Virtually_Count__c -= 1;
        } else {
            account.Unadopted_Virtually_Count__c += 1;
        }
    }

    if (accountsRelatedToRealAdoptionsMap.size() > 0) {
        update accountsRelatedToRealAdoptionsMap.values();
    }
}