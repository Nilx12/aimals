trigger AdoptionTrigger on Adoption__c (after insert, after update, before delete, after delete, after undelete) {
    AdoptionTriggerHandler handler = new AdoptionTriggerHandler();
    switch on Trigger.operationType {
        when AFTER_INSERT {
            handler.afterInsert(Trigger.new, Trigger.newMap);
        }
        when AFTER_UPDATE {
            handler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
        when BEFORE_DELETE {
            handler.beforeDelete(Trigger.oldMap);
        }
        when AFTER_DELETE {
            handler.afterDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_UNDELETE {
            handler.afterUndelete(Trigger.new, Trigger.newMap);
        }
    }
}