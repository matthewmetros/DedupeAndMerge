public class MergeService {


    public Boolean mergeOne(Sobject masterRecord, Sobject mergedRecord)
    {
        Database.MergeResult result = Database.merge(masterRecord, mergedRecord, false);
        if (result.isSuccess())
        {
            System.debug('Master record ID: ' + result.getId());
            List<Id> mergedIds = result.getMergedRecordIds();
            System.debug('IDs of merged records: ' + mergedIds); 
            return true;
        }
        else
        {
            for(Database.Error err : result.getErrors())
            {
                // Write each error to the debug output
                System.debug('Merge Failure: ');
                System.debug(err.getMessage());
            }
            return false;
        }
    }


    public Map<String, list<String>> mergeMany(Sobject masterRecord, Sobject[] mergedRecords)
    {
        Map<String, List<String>> mergeResults = new Map<String, List<String>>
        {
            'Master' => new List<String>(),
            'MergedRecords' => new List<String>()
        };

        Sobject master = masterRecord;
        List<String> sucessfulMerges = new List<String>();
        Boolean sucess = false;


        for(Sobject mergedRecord: mergedRecords )
        {
            ID masterRecordId = masterRecord.Id;
            ID mergedRecordId = mergedRecord.Id;
            // Make sure that the record IDs are not the same
            if(masterRecordId != mergedRecordId)
            {
                sucess = mergeOne(master, mergedRecord);
                if(sucess == true)
                {
                    sucessfulMerges.add(mergedRecordId);
                }
            }
        }
        
        mergeResults.get('Master').add(master.Id);
        mergeResults.get('MergedRecords').addAll(sucessfulMerges);

        return mergeResults;
    }

    public Boolean convertOne(Sobject masterRecord, Sobject mergedRecord)
    {
        Database.LeadConvert lc = new Database.LeadConvert();

        lc.setLeadId(mergedRecord.Id);
        lc.setConvertedStatus('Qualified');

        String accId = ((Id)masterRecord.get('AccountId')); 

        if(accId != null)
        {
            lc.setAccountId( ((Id)masterRecord.get('AccountId')));    
            lc.setContactId(masterRecord.Id);
        }
        lc.setDoNotCreateOpportunity(true);



        System.debug(masterRecord.Id);
        // [SELECT id from ]
        System.debug(mergedRecord.Id);
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        if(lcr.isSuccess())
        {
            System.debug('Master record ID: ' + lcr.getContactId() );
            Id convertedId = lcr.getLeadId();
            System.debug('ID of converted record: ' + convertedId); 
            return true;
        }
        else 
        {
            for(Database.Error err: lcr.getErrors())
            {
                // Write each error to the debug output
                System.debug('Merge Failure: ');
                System.debug(err.getMessage());
                System.debug('Fields That Failed: ');
                System.debug(err.getFields());

            }   
            
            return false;
        }
    }

    public Map<String, list<String>> convertMany(Sobject masterRecord, Sobject[] mergedRecords)
    {
        Map<String, List<String>> mergeResults = new Map<String, List<String>>
        {
            'Master' => new List<String>(),
            'MergedRecords' => new List<String>()
        };

        Sobject master = masterRecord;
        List<String> sucessfulMerges = new List<String>();
        Boolean sucess = false;


        for(Sobject mergedRecord: mergedRecords )
        {
            ID masterRecordId = masterRecord.Id;
            ID mergedRecordId = mergedRecord.Id;
            // Make sure that the record IDs are not the same
            if(masterRecordId != mergedRecordId)
            {
                sucess = convertOne(master, mergedRecord);
                if(sucess == true)
                {
                    sucessfulMerges.add(mergedRecordId);
                }
            }
        }
        
        mergeResults.get('Master').add(master.Id);
        mergeResults.get('MergedRecords').addAll(sucessfulMerges);
        
        return mergeResults;
    }

}
