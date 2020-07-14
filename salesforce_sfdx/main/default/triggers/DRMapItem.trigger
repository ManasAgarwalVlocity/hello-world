trigger DRMapItem on DRMapItem__c (before insert, before update, after delete, after update, after insert) 
{
    TriggerSetup__c myCS = TriggerSetup__c.getInstance('AllTriggers');
    boolean isTriggerOn=false;
    if(myCS!=null){
      isTriggerOn = myCS.IsTriggerOn__c;
      system.debug('is trigger on '+isTriggerOn);
            
    }
    else {
        system.debug('can not get the custom setting');
    }
    if(isTriggerOn){
        TriggerFactory.createHandler(DRMapItem__c.sObjectType, isTriggerOn);
    }
    
    CoreProjectTrackingService.addTriggerItems('Dataraptor','Id');
}