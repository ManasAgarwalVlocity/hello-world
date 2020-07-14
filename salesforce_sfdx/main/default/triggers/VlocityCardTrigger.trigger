trigger VlocityCardTrigger on VlocityCard__c (after delete, after insert, after update, 
before delete, before insert, before update) {
    TriggerSetup__c myCS = TriggerSetup__c.getInstance('AllTriggers');
    boolean isTriggerOn = myCS != null ? myCS.IsTriggerOn__c : false;
    System.debug('is trigger on '+isTriggerOn);
    TriggerFactory.createHandler(VlocityCard__c.sObjectType, isTriggerOn);
    CoreProjectTrackingService.addTriggerItems('Vlocity Card','');
}