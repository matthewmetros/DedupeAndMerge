global class BatchConvertMergeSobjects implements Database.Batchable<SObject>, Database.Stateful
{
    public String query;
    public Map<String, Set<String>> leadMergeRules = new Map<String, Set<String>>();
    public Map<String, Set<String>> contactMergeRules = new Map<String, Set<String>>();
    public Map<String, Set<String>> leadConMergeRules = new Map<String, Set<String>>();


    public Map<String, List<String>> leadConFields = new Map<String, List<String>>();
    public Map<String, List<String>> leadFields =  new Map<String, List<String>>();
    public Map<String, List<String>> conFields = new Map<String, List<String>>();


    public Map<String, Set<String>> SobjectIdsByType = new Map<String, Set<String>>();

    public Map<String, List<SObject>> matchResults = new Map<String, List<SObject>>();

    public void findCommonFields(Map<String, List<String>> leadFields , Map<String, List<String>> conFields )
    {
                // Find common fields between the two records
        for(String key: leadFields.keySet())
        {
            Set<String> leadFs = new  Set<String>(leadFields.get(key));
            Set<String> conFs = new  Set<String>(conFields.get(key));
            
            if(!leadConFields.containsKey(key)){leadConFields.put(key, new List<String>());}

            for (String fieldLabel : leadFs )
            {
                if(conFs.contains(fieldLabel)){leadConFields.get(key).add(fieldLabel);}
            }
        }

    }
    
    public sObject removeNonUpdateableFields(String masterSObjectType, SObject masterRecord)
    {
        Map<String, Object> sobjMap1 = new Map<String, Object>( masterRecord.getPopulatedFieldsAsMap() );
        // Map<String, Object> sobjMap2 = (Map<String, Object>) JSON.deserializeUntyped( JSON.serialize( masterRecord ) );
        // System.debug('removeNonUpdateableFields Function');
        System.debug(masterSObjectType);

        // Remove all the fields that cannot be updated for the merge
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(masterSObjectType).getDescribe().fields.getMap();
        for(String keys: sobjMap1.keySet())
        {
            if(fieldMap.containsKey(keys) && fieldMap.get(keys).getDescribe().isUpdateable() == false && keys != 'Id')
            {
                sobjMap1.remove(keys);
            }

        }

        // now we have everything matched at this point

        return (sObject) JSON.deserialize( JSON.serialize( sobjMap1 ), Type.forName('Schema.'+masterSObjectType));
    }

    global BatchConvertMergeSobjects(String soqlQuery, String sObjectType)
    {
        leadMergeRules = MergeRules.MergeRules('Lead');
        contactMergeRules = MergeRules.MergeRules('Contact');
        leadConMergeRules = MergeRules.MergeRules('LeadContact');

        query = soqlQuery;

        leadFields.put( 'Updateable', DynamicSOQL.getFields('Lead', true));
        leadFields.put('Non-Updateable',DynamicSOQL.getFields('Lead', false));
        List<String> allLeadFields = new List<String>();

        allLeadFields.addAll( leadFields.get('Updateable') );
        allLeadFields.addAll( leadFields.get('Non-Updateable'));


        leadFields.put('All-Fields', allLeadFields);

        conFields.put('Updateable', DynamicSOQL.getFields('Contact', true));
        conFields.put('Non-Updateable', DynamicSOQL.getFields('Contact', false));

        List<String> allContactFields = new List<String>();
        allContactFields.addAll(conFields.get('Updateable'));
        allContactFields.addAll(conFields.get('Non-Updateable'));

        conFields.put('All-Fields',allContactFields);
        // now we have common fields between the contact and lead
        findCommonFields(leadFields , conFields );
    }



    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        
        return Database.getQueryLocator(query);
    }

    global Map<String, Set<String>> splitIDBySchemaType(Set<String> dupIdSet)
    {
        Map<String, Set<String>> mapToReturn = new Map<String, Set<String>>();

        Set<String> conDupIdSet = new Set<String>();
        Set<String> leadDupIdSet = new Set<String>();

        // now we are going to through each dup in the set
        for(String dupId : dupIdSet)
        {
            // Find the Sobject Type
            String sot = String.valueOf( ((Id)dupId).getSobjectType() );

            if(sot == 'Contact'){ conDupIdSet.add(dupId);}
            else if(sot == 'Lead'){ leadDupIdSet.add(dupId); }

        }

        if(!conDupIdSet.isEmpty()){mapToReturn.put('Contact', conDupIdSet);}
        if(!leadDupIdSet.isEmpty()){mapToReturn.put('Lead', leadDupIdSet);}


        return mapToReturn;
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) 
    {
        MergeService mServe = new MergeService();
        for(Sobject sObj: scope)
        {
            Boolean Success = false;

            // get the dup ids
            String stringOfIds = (String)sObj.get('DuplicateIds__c');
            Set<String> duplicateIdsSet = new Set<String>(stringOfIds.split(','));
            duplicateIdsSet.add( ((String)(sObj.get('Id'))) );
            SobjectIdsByType = splitIDBySchemaType(duplicateIdsSet);

            List<SObject> leadSobjects = new List<Sobject>();
            List<SObject> contactSobjects = new List<Sobject>();

            // Get the Sobjects and all updateable fields

            if(SobjectIdsByType.containsKey('Lead') )
            {
                leadSobjects = (List<SObject>)DynamicSOQL.SOQL('Lead', leadFields.get('All-Fields'), SobjectIdsByType.get('Lead'));
            }
            if(SobjectIdsByType.containsKey('Contact'))
            {
                contactSobjects = (List<SObject>)DynamicSOQL.SOQL('Contact', conFields.get('All-Fields'), SobjectIdsByType.get('Contact'));
            }

            Map<String, List<Sobject>> tempMatchResults = new Map<String, List<Sobject>>();
            Map<String, List<Sobject>> tempMatchResults1 = new Map<String, List<Sobject>>();
            Map<String, List<Sobject>> tempMatchResults2 = new Map<String, List<Sobject>>();


            if(leadSobjects.size()>= 1)
            {
                MatchService matchLeadServe = new MatchService();
                tempMatchResults = matchLeadServe.matchManySobject(leadSobjects, leadFields.get('Updateable'), leadMergeRules);
                matchResults.put('LeadMaster',tempMatchResults.get('Master') );


                if(tempMatchResults.get('MergedRecords').size() >0)
                {
                    matchResults.put('LeadMergedRecords', tempMatchResults.get('MergedRecords'));
                }

            }
            if(contactSobjects.size()>= 1)
            {
                for(Sobject c : contactSobjects)
                {
                    System.debug(c.Id);
                }
                MatchService matchConServe = new MatchService();
                tempMatchResults1 = matchConServe.matchManySobject(contactSobjects, conFields.get('Updateable'), contactMergeRules); 
                matchResults.put('ContactMaster',tempMatchResults1.get('Master') );
                if(tempMatchResults1.get('MergedRecords').size() >0)
                {
                    matchResults.put('ContactMergedRecords', tempMatchResults1.get('MergedRecords'));
                    for(Sobject s : matchResults.get('ContactMergedRecords'))
                    {
                        System.debug(s.Id);
                    }
                } 
            }

            if(matchResults.containsKey('ContactMaster') && matchResults.containsKey('LeadMaster'))
            {
                list<SObject> sObjectsToMerge = new list<SObject>();
                sObjectsToMerge.addAll(matchResults.get('LeadMaster'));
                sObjectsToMerge.addAll(matchResults.get('ContactMaster'));

                MatchService matchServe = new MatchService();
                tempMatchResults2 = matchServe.matchLeadCon(sObjectsToMerge, leadConFields.get('Updateable'), leadConMergeRules);

                matchResults.put('ContactMaster',tempMatchResults2.get('Master') );
                if(tempMatchResults2.get('MergedRecords').size() >0)
                {
                    matchResults.put('LeadMasterMergedRecord', tempMatchResults2.get('MergedRecords'));
                } 
            }
            Sobject masterRecord = matchResults.containsKey('ContactMaster') == true ? matchResults.get('ContactMaster').get(0) : matchResults.get('LeadMaster').get(0);
            Sobject leadMasterRecord = matchResults.containsKey('LeadMaster') == true ? matchResults.get('LeadMaster').get(0) : null;

            String masterSObjectType = String.valueOf(masterRecord.getSObjectType());
            // List<SObject> recordsToDelete = new List<SObject>();

            // if(matchResults.containsKey('LeadMasterMergedRecord'))
            // {
            //     recordsToDelete.addAll(matchResults.get('LeadMasterMergedRecord'));
            // }
            // if(matchResults.containsKey('ContactMergedRecords'))
            // {
            //     recordsToDelete.addAll(matchResults.get('ContactMergedRecords'));
            // }
            // if(matchResults.containsKey('LeadMergedRecords'))
            // {
            //     recordsToDelete.addAll(matchResults.get('LeadMergedRecords'));  
            // }

            masterRecord = removeNonUpdateableFields(masterSObjectType, masterRecord);

            if(leadMasterRecord != null)
            {
                leadMasterRecord = removeNonUpdateableFields('Lead', leadMasterRecord);
            }

            if(masterSObjectType == 'Contact' && matchResults.containsKey(('ContactMergedRecords')))
            {
                System.debug('Contact Merge Records');
                System.debug(matchResults.get('ContactMergedRecords'));
                Map<String, List<String>> conMergeResults = mServe.mergeMany(masterRecord, matchResults.get('ContactMergedRecords'));
            }

            if(leadMasterRecord != null && matchResults.containsKey(('LeadMergedRecords')))
            {
                System.debug('Lead Merge Records');
                System.debug(matchResults.get('LeadMergedRecords'));
                Map<String, List<String>> leadMergeResults = mServe.mergeMany(leadMasterRecord, matchResults.get('LeadMergedRecords'));
            }
            // System.debug(masterSObjectType == 'Contact' && matchResults.containsKey('LeadMasterMergedRecord'));
            if(masterSObjectType == 'Contact' && matchResults.containsKey('LeadMasterMergedRecord'))
            {
                System.debug('Hello there');
                System.debug(matchResults.get('LeadMasterMergedRecord').get(0).Id);

                Map<String, List<String>> leadConMergeResults = mServe.convertMany(masterRecord, matchResults.get('LeadMasterMergedRecord'));
            }




        }
    }

    global void finish(Database.BatchableContext BC) 
    {

    }


}
