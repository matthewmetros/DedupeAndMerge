public class LeadFactory extends GenericSobjectFactory
{
            public override Schema.SObjectType getSObjectType()
            {
                return Lead.SobjectType;
            }
            
            public List<Lead> make( Map<String, Object> valuesByField, Integer count, Boolean insertSobject)
            {
                List<Lead> listOfLeads = new List<Lead>();

                    for(Integer i = 0; i < count ; i++)
                    {
                        Lead newLead = (Lead) this.makeRecord(valuesByField);

                        listOfLeads.add(newLead);
                    }

				if(insertSobject)
				{
					Database.DMLOptions dml = new Database.DMLOptions();
					dml.DuplicateRuleHeader.allowSave = true;

                    Database.SaveResult[] srList = Database.insert(listOfLeads, dml);
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
                
                return listOfLeads;
            }	
}