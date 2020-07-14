/**
 * Class CoreProjectTrackingService
 *
 * Used to automatically track changes into “Default“ Core Workset record type project as the project items.
 */
public class CoreProjectTrackingService {
    /**
     * Public static method to Trigger Items addition
     *
     * Arguments:   String soString - Datapack type which triggered project items addition
     *              String parentId - Any parent datapack key, if any, referenced in triggered item or Id of triggered item
     */
    public static void addTriggerItems(String soString, String parentId){ 
        // Will work if its triggered after insert/update
        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter){
         	TriggerSetup__c projectItemTriggersCS = TriggerSetup__c.getInstance('AddProjectItemsTriggers');
            //Will check the custom setting, if tracking is ON/Off and also item is a part of import
            if(projectItemTriggersCS!=null && projectItemTriggersCS.IsTriggerOn__c && !DRDataPackService.isImporting){
                List<sObject> updatedRecords = new List<sObject>();
                updatedRecords.addAll((List<sObject>)(Trigger.new));
                
                String [] arrayOfUpdatedRecordsId = new List<String>();
                for (Integer i = 0; i<Trigger.New.size(); i++) {
                    arrayOfUpdatedRecordsId.add(Trigger.New[i].Id);
                    if(parentId != 'Id'){
                        arrayOfUpdatedRecordsId.add((String)Trigger.New[i].get(parentId));
                    }
                }
                list<ProjectItem__c> alreadyExistingProjectItems = [SELECT Id,ItemId__c FROM projectItem__c WHERE ItemId__c IN :arrayOfUpdatedRecordsId];        
                Map<String, String> IdToProjectItemIdMap = new Map<String, String> {};
                
                //Will create project Item id to Item Id mapping
                for (Integer i = 0; i<alreadyExistingProjectItems.size(); i++) {
                    IdToProjectItemIdMap.put(alreadyExistingProjectItems[i].ItemId__c, alreadyExistingProjectItems[i].Id);
                }
                
                list<projectItem__c> formattedList =  new List<projectItem__c>();
                
                String defaultWorkSetRecordId = [SELECT Id FROM RecordType WHERE Name = 'Work Set'][0].Id;
                String defaultProjectId = [SELECT Id FROM Project__c WHERE RecordTypeId = :defaultWorkSetRecordId AND IsDefault__c = true][0].Id;
                
                //Will create the list of projectItems in required format to do upsert later
                for (Integer i = 0; i<updatedRecords.size(); i++) {
                    projectItem__c objProjectItemToBeInserted = new projectItem__c(); 
                    if(IdToProjectItemIdMap.get(updatedRecords[i].Id) != null){
                        objProjectItemToBeInserted.Id = IdToProjectItemIdMap.get(updatedRecords[i].Id);
                    } else {
                        objProjectItemToBeInserted.Id = null;
                    }
                    objProjectItemToBeInserted.ItemId__c = updatedRecords[i].Id;
                    if(soString == 'Omniscript' && (Boolean)updatedRecords[i].get('IsProcedure__c')){
                        objProjectItemToBeInserted.ItemType__c = 'Integration Procedure';
                    } else {
                        objProjectItemToBeInserted.ItemType__c = soString;            
                    }
                    if(parentId != 'Id' && IdToProjectItemIdMap.get((String)updatedRecords[i].get(parentId)) != null){
                        objProjectItemToBeInserted.ParentItemId__c = IdToProjectItemIdMap.get((String)updatedRecords[i].get(parentId));
                    }
                    objProjectItemToBeInserted.Name = (String)updatedRecords[i].get('Name');
                    objProjectItemToBeInserted.ProjectId__c = defaultProjectId;
                    formattedList.add(objProjectItemToBeInserted);   
                }
                
                try {
                    //Perform upsert of records that have been updated 
                    upsert formattedList;
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }   
            } else {
                system.debug('Project Items Addition disabled');
            }   
        }
    }
}