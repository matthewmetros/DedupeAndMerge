@isTest
public class BatchMergeTest 
{
    public static Integer numOfAccounts = 1;
    public static Integer numOfContacts = 3;
    public static Integer numOfLeads = 3;

    public static Sobject getDuplicateIds(Sobject sobj, list<Sobject> sobjs, Boolean updateRecords)
    {

        List<String> sObjectIds = new List<String>();



        for(Sobject sob: sobjs )
        {
            sObjectIds.add((String)sob.get('Id'));
        }

        string stringOfIds = String.join(sObjectIds,',');
        sobj.put( 'DuplicateIds__c' , stringOfIds);
        if(updateRecords)
        {
            Database.SaveResult sr = Database.update( sobj, false);

        }
        return sobj;
    }

    static testmethod void schedulerTest1() 
    {

        String CRON_EXP = '0 0 0 15 3 ? *';
    // Create Test
        AccountFactory af   = new AccountFactory();
    
        Map<String, Object> accountFields = new Map<String, Object>
        {
            'Name' => 'Test',
            'Website' => 'test.com',
            'Industry' => 'Accounting'
        };

    
        List<Account> Accounts = af.make(accountFields, numOfAccounts, true);



        ContactFactory cf = new ContactFactory();

        Map<String, Object> contactFields = new Map<String, Object>
        {
            'lastName' => 'Test',
            'Title' => 'test.com',
            'Email' => 'test@test.com'

        };
    
        List<Contact> cons = cf.make(Accounts, contactFields, numOfContacts, true);

        Contact firstCon = cons.remove(0);
        

        firstCon = (Contact)getDuplicateIds(firstCon, cons, true );

        LeadFactory lf = new LeadFactory();

        Map<String, Object> leadFields = new Map<String, Object>
        {
            'lastName' => 'Test',
            'Company' => 'Pandd',
            'Email' => 'test@Pandd.iop'

        };

        Lead[] leads = lf.make(leadFields, numOfLeads, true);

        List<SObject> listOfLeadCons = new List<SObject>();

        listOfLeadCons.add(firstCon);
        listOfLeadCons.addAll(cons);
        listOfLeadCons.addAll(leads);

        Lead firstLead = leads.remove(0);

        firstLead = (Lead)getDuplicateIds(firstLead, listOfLeadCons, true );


        
        
        Test.startTest();


            String jobId2 = System.schedule('Dedupe leadCons',  CRON_EXP, new MergeLeadContactBatchSchedule());
            CronTrigger ct2 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId2];
            System.assertEquals(CRON_EXP, ct2.CronExpression);
            System.assertEquals(0, ct2.TimesTriggered);
            

        Test.stopTest();

    }


}
