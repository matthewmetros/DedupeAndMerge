public class AccountFactory extends GenericSobjectFactory
{
            public override Schema.SObjectType getSObjectType()
            {
                return Account.SobjectType;
            }

            public List<Account> make(Map<String, Object> valuesByField, Integer count, Boolean insertSobject)
            {
                List<Account> listOfAccounts = new List<Account>();
                
                for(Integer i = 0; i < count ; i++)
                {
                    Account newAccount = (Account) this.makeRecord(valuesByField);

                    listOfAccounts.add(newAccount);
                }

				if(insertSobject)
				{
					Database.DMLOptions dml = new Database.DMLOptions();
					dml.DuplicateRuleHeader.allowSave = true;

                    Database.SaveResult[] srList = Database.insert(listOfAccounts, dml);
                    for (Database.SaveResult sr : srList) 
                    {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                        }
                        else 
                        {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) 
                            {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Account fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
				}
                
                return listOfAccounts;
            }	
}