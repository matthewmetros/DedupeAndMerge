public with sharing class DynamicSObjectUpdater {

    Map<SObjectType, Map<Id, sObject>> sorToUpdate = new Map<SObjectType, Map<Id, sObject>>();


    public SObject getUpdateSObject(ID sObjectID, Map<String, Object> values)
    {
        SObjectType sot = sObjectID.getSobjectType();

        if(!sorToUpdate.containsKey(sot))
        {
            sorToUpdate.put(sot, new Map<Id, SObject>());
        }

        SObject targetSObject = sorToUpdate.get(sot).get(sObjectID);

        if(targetSObject == null)
        {
            targetSObject = sot.newSobject(sObjectID);

            sorToUpdate.get(sot).put(sObjectID, targetSObject);
        }
        
        for (String field : values.keySet()) 
        {
            targetSObject.put(field, values.get(field));
        }

        return targetSObject;
    }


    public void updateSObjects()
    {
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        List<SObject> sObjectsToUpdate = new List<SObject>();
        if(sorToUpdate.size() > 0)
        {
            for(SObjectType sorType: sorToUpdate.keySet())
            {
                sObjectsToUpdate.addAll( sorToUpdate.get(sorType).values() );
            }
        }
        if(sObjectsToUpdate.size()>0) srList = Database.update(sObjectsToUpdate, false);

        for (Database.SaveResult sr : srList) 
        {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully Updated SObject. Sobject ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('SObject fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

}