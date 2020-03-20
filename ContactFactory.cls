public class ContactFactory extends GenericSobjectFactory
{
            public override Schema.SObjectType getSObjectType()
            {
                return Contact.SobjectType;
            }
            
            public List<Contact> make(List<Account> accountsToAddCons, Map<String, Object> valuesByField, Integer count, Boolean insertSobject)
            {
                List<Contact> listOfContacts = new List<Contact>();

                for(Account acc: accountsToAddCons)
                {
                    for(Integer i = 0; i < count ; i++)
                    {
                        Contact newContact = (Contact) this.makeRecord(valuesByField);
                        newContact.AccountId = acc.Id;

                        listOfContacts.add(newContact);
                    }
                }

				if(insertSobject)
				{
					Database.DMLOptions dml = new Database.DMLOptions();
					dml.DuplicateRuleHeader.allowSave = true;

                    Database.SaveResult[] srList = Database.insert(listOfContacts, dml);
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
                
                return listOfContacts;
            }	
}