public class MatchService 
{
    Map<String, List<Sobject>> mapToReturn = new Map<String, List<Sobject>>
    {
        'Master' => new List<Sobject>(),
        'MergedRecords' => new List<Sobject>()
    };
    public Sobject masterRecord;
    public Sobject comparingSObject;
    public List<Sobject> sObjectestTobeDestroyed = new List<Sobject>();



    public Map<String, List<Sobject>> matchManySobject(List<Sobject> sObjectsToMerge, List<String> apiNames, Map<String, Set<String>> sObjectMergeRules) 
    {
        // make the first record the master
        masterRecord = sObjectsToMerge.remove(0);

        for(Sobject sObjectToMerge: sObjectsToMerge)
        {
            comparingSObject = sObjectToMerge;

            // if the master record is younger than the comparing record
            // with dates - today is a larger number than yesterday
            if( (Datetime)masterRecord.get('CreatedDate') > (Datetime)comparingSObject.get('CreatedDate'))
            {
                // Make the comparing record the master
                comparingSObject = masterRecord;
                masterRecord    = sObjectToMerge; 
            }

            // Now loop through each field
            for(String field : apiNames)
            {

                // get the master records value

                // System.debug('field being assessed: '+field);

                Object fieldVal = masterRecord.get(field);
                // System.debug(fieldVal);
                Object comparedFieldVal = comparingSObject.get(field);
                // System.debug(comparedFieldVal);
                if(sObjectMergeRules.get('newer').contains(field))
                {
                    if(comparedFieldVal != null)
                    {
                        masterRecord.put(field, comparedFieldVal);
                    }

                }
                else
                {
                

                    // If the fieldVal of the master is null - Check the comparing record
                    if(fieldVal == null)
                    {
                        if(comparedFieldVal != null)
                        {
                            masterRecord.put(field, comparedFieldVal);
                        }
                    }
                }
            }
            // Now add the comparing Sobject to the list of Sojbects To be Merged
            sObjectestTobeDestroyed.add(comparingSObject);

        }


        mapToReturn.put('MergedRecords',sObjectestTobeDestroyed);
        mapToReturn.put('Master', new List<Sobject>{masterRecord});

        return mapToReturn;
    }



    public Map<String, List<Sobject>> matchLeadCon(Sobject[] sObjectsToMerge, List<String> commonFields,  Map<String, Set<String>> sObjectMergeRules   )
    {
        // The master record is the contact
        masterRecord = sObjectsToMerge.remove(1);


        for(Sobject sObjectToMerge: sObjectsToMerge)
        {
            comparingSObject = sObjectToMerge;
            

            // if the master record is younger than the comparing record
            // with dates - today is a larger number than yesterday

            // Now loop through each field

            for(String field : commonFields)
            {
                // System.debug('field being assessed: '+field);
                Object fieldVal = masterRecord.get(field);
                // System.debug(fieldVal);
                Object comparedFieldVal = comparingSObject.get(field);
                // System.debug(comparedFieldVal);

                // if the lead is the older record
                if( (Datetime)masterRecord.get('CreatedDate') > (Datetime)comparingSObject.get('CreatedDate'))
                {
                    
                    if(sObjectMergeRules.get('newer').contains(field) && fieldVal == null)
                    {
                            // lead field val is not null
                            if(comparedFieldVal != null)
                            {
                                // take the lead field val onto the contact
                                masterRecord.put(field, comparedFieldVal);
                            }
                    }
                    else 
                    {
                            // Now we want all the lead fields that they have in common to go on to the contact
                            if(comparedFieldVal == null && fieldVal != null)
                            {
                                // do nothing
                            }
                            else 
                            {
                                masterRecord.put(field, comparedFieldVal);     
                            }
                            
                    }
                }
                else 
                {
                        // if the contact is the master record
                        if(sObjectMergeRules.get('newer').contains(field) && comparedFieldVal != null)
                        {
                            masterRecord.put(field, comparedFieldVal);
                        }
                        else
                        {
                            // If the fieldVal of the master is null - Check the comparing record
                            if(fieldVal == null)
                            {
                                if(comparedFieldVal != null)
                                {
                                    masterRecord.put(field, comparedFieldVal);
                                }
                            }
                        }
                }

            
            }
            // Now add the comparing Sobject to the list of Sojbects To be Merged
            sObjectestTobeDestroyed.add(comparingSObject);

        }


        mapToReturn.put('MergedRecords',sObjectestTobeDestroyed);
        mapToReturn.put('Master', new List<Sobject>{masterRecord});


        return mapToReturn;
    }
}
