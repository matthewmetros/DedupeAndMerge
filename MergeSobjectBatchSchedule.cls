global class MergeSobjectBatchSchedule implements Schedulable{

    public Integer batchSize = 2;


    global void execute(SchedulableContext sc) 
    {
        Map<String, Set<String>> mRules1 = MergeRules.MergeRules('Contact');
        String query1 = 'SELECT Id, DuplicateIds__c  FROM Contact Where DuplicateIds__c != Null';
        BatchMergeSobjects batch1		= 	new BatchMergeSobjects(query1, 'Contact', mRules1);

        Database.executeBatch(Batch1, batchSize);
    }
}
