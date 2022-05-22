trigger AnimalFoodTrigger on Adoption__c (after insert, after update) {
    Set<Id> adoptionIds = Trigger.newMap.keySet();

    List<Adoption__c> newAdoptions = [SELECT Id,
                                    RecordTypeId,
                                    Contact__c
                                    FROM Adoption__c WHERE Id IN :adoptionIds];

    List<Id> contactIdsAssociatedWithNewAdoption = new List<Id>();
    for (Adoption__c adoption: newAdoptions) {
        Id contactId = adoption.Contact__c;
        contactIdsAssociatedWithNewAdoption.add(contactId);
    }
	System.debug(contactIdsAssociatedWithNewAdoption.size());
    Map<Id,Contact> contactsWithNewAdoptionMap = new Map<Id, Contact>();
    for (Contact contact: [SELECT Id, Adoption_Points__c, Free_Animal_Food__c 
                            FROM Contact WHERE Id IN :contactIdsAssociatedWithNewAdoption]) {
        contactsWithNewAdoptionMap.put(contact.Id, contact);
    }

    RecordType realAdoptionRecordType = [SELECT Id FROM RecordType WHERE RecordType.Name = 'Real' LIMIT 1];
    for (Adoption__c adoption: newAdoptions) {
        Id contactId = adoption.Contact__c;
        Contact contact = contactsWithNewAdoptionMap.get(contactId);
        contact.Adoption_Points__c += 10;
        if (adoption.RecordTypeId.equals(realAdoptionRecordType.Id)) {
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