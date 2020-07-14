trigger BusinessProcessTrigger on OmniScript__c (before delete, before update, before insert) 
{
    TriggerSetup__c myCS = TriggerSetup__c.getInstance('AllTriggers');
    Logger.dbg('OmniScript__c:Custom Setting for AllTriggers');
    boolean isTriggerOn = false;
    if(myCS != null)
    {
        isTriggerOn = myCS.IsTriggerOn__c;
        Logger.dbg('OmniScript__c:AllTriggers ' + isTriggerOn);
    }
    else 
    {
        Logger.dbg('OmniScript__c:Can not get the Custom Setting');
    }
    if(isTriggerOn)
    {    
        OUITriggerFactory.createHandler(OmniScript__c.SObjectType, isTriggerOn);
    }
    CoreProjectTrackingService.addTriggerItems('Omniscript','Id');
}