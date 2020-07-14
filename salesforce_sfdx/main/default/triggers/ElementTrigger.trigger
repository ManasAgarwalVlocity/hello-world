trigger ElementTrigger on Element__c (before insert, after insert, before delete, after update, before update) 
{
    TriggerSetup__c myCS = TriggerSetup__c.getInstance('AllTriggers');
    Logger.dbg('Element__c:Custom Setting for AllTriggers');
    boolean isTriggerOn = false;
    if(myCS != null)
    {
        isTriggerOn = myCS.IsTriggerOn__c;
        Logger.dbg('Element__c:AllTriggers ' + isTriggerOn);
    }
    else 
    {
        Logger.dbg('Element__c:Can not get the Custom Setting');
    }
    if(isTriggerOn && ElementTriggerHandler.elementTriggerEnabled)
    {    
        OUITriggerFactory.createHandler(Element__c.SObjectType, isTriggerOn);
    }
    CoreProjectTrackingService.addTriggerItems('Element','OmniScriptId__c');
}