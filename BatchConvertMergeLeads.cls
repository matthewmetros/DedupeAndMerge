global class BatchConvertMergeLeads implements Schedulable{

        public Integer batchSize = 2;
    
    
        global void execute(SchedulableContext sc) 
        {
            Map<String, Set<String>> mRules1 = MergeRules.MergeRules('Lead');
            String query1 = 'SELECT Id, DuplicateIds__c  FROM Lead Where DuplicateIds__c != Null and IsConverted = false';
            BatchMergeSobjects batch1		= 	new BatchMergeSobjects(query1, 'Lead', mRules1);
    
            Database.executeBatch(Batch1, batchSize);
        }
}
    
