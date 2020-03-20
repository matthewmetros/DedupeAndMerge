global class MergeLeadContactBatchSchedule implements Schedulable {

    public Integer batchSize = 2;


    global void execute(SchedulableContext sc) 
    {
        String query1 = 'SELECT Id, DuplicateIds__c  FROM Lead Where DuplicateIds__c != Null';
        BatchConvertMergeSobjects batch1		= 	new BatchConvertMergeSobjects(query1, 'Lead');

        // String query2 = 'SELECT Id, DuplicateIds__c  FROM Contact Where DuplicateIds__c != Null';
        // BatchConvertMergeSobjects batch2		= 	new BatchConvertMergeSobjects(query2, 'Contact');


        Database.executeBatch(Batch1, batchSize);
        // Database.executeBatch(Batch2, batchSize);

    }

}
