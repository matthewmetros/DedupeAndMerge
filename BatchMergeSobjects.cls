global class BatchMergeSobjects implements Database.Batchable<SObject>, Database.Stateful
{
    public String globalsObject;
    public String query;
    public Map<String, List<String>> apiNames = new Map<String, List<String>>{
        'Updateable' => new List<String>(),
        'Non-Updateable' => new List<string>()
    };


    public Map<String, Set<String>> sObjectMergeRules;


    global BatchMergeSobjects(String soqlQuery, String sObjectType, Map<String, Set<String>> MergeRules)
    {
        sObjectMergeRules = MergeRules;
        globalsObject = sObjectType;
        query = soqlQuery;
        apiNames.get('Updateable').addAll(DynamicSOQL.getFields(globalsObject, true));
        apiNames.get('Non-Updateable').addAll(DynamicSOQL.getFields(globalsObject, false));



    }

    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<SObject> scope) 
    {
        MergeService mServe = new MergeService();
        MatchService matchServe = new MatchService();
        DynamicSObjectUpdater sObjectUpdater  = new DynamicSObjectUpdater();

        for(Sobject sObj: scope)
        {
            Boolean Success = false;
            // Add all the Ids into a string List
            String stringOfIds = (String)sObj.get('DuplicateIds__c');
            Set<String> duplicateIdsSet = new Set<String>(stringOfIds.split(','));
            duplicateIdsSet.add((String)sObj.get('Id'));

            List<String> allApiNames = new List<String>();

            allApiNames.addAll(apiNames.get('Updateable'));
            allApiNames.addAll(apiNames.get('Non-Updateable'));
 
            // Get the Sobjects and all updateable fields
            List<SObject> sObjectsToMerge = (List<SObject>)DynamicSOQL.SOQL(globalsObject, allApiNames, duplicateIdsSet);

            // Now find the master and records to be deleted
            // matchResults ={ 'Master' => new List<Sobject>(), 'MergedRecords' => new List<Sobject>()};
            Map<String, List<Sobject>> matchResults = matchServe.matchManySobject(sObjectsToMerge, apiNames.get('Updateable'), sObjectMergeRules);

            Sobject masterRecord = matchResults.get('Master').get(0);
            Sobject[] recordsToDelete = matchResults.get('MergedRecords');

            Map<String, Object> sobjMap1 = new Map<String, Object>( masterRecord.getPopulatedFieldsAsMap() );
            // Map<String, Object> sobjMap2 = (Map<String, Object>) JSON.deserializeUntyped( JSON.serialize( masterRecord ) );


            // Remove all the fields that cannot be updated for the merge
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(globalsObject).getDescribe().fields.getMap();
            for(String keys: sobjMap1.keySet())
            {
                System.debug(sobjMap1.get(keys));
            
                if(fieldMap.get(keys).getDescribe().isUpdateable() == false && keys != 'Id')
                {
                    sobjMap1.remove(keys);
                }

            }



            masterRecord = (sObject) JSON.deserialize( JSON.serialize( sobjMap1 ), Type.forName('Schema.'+globalsObject));

            Map<String, List<String>> mergeResults = mServe.mergeMany(masterRecord, recordsToDelete);

            String[] mResults = mergeResults.get('MergedRecords');

            Map<String, Object> sObjectFieldsToUpdate = new Map<String, Object>();


            String mergeStringList = string.join(mResults, ',');



            sObjectFieldsToUpdate.put('MergedIds__c', mergeStringList);


            sObjectUpdater.getUpdateSObject( masterRecord.Id, sObjectFieldsToUpdate);


        }
        sObjectUpdater.updateSObjects();




        
    }

    global void finish(Database.BatchableContext BC) 
    {

    }


}
