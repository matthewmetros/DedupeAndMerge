public abstract class GenericSobjectFactory
{
    public SObject makeRecord(Map<String, Object> valuesByField) 
    {
        // Initialize the Lead object to return
        SObject record = this.getSObjectType().newSObject(null, true);

        // Populate the record with values passed to the method
        for (String eachField : valuesByField.keySet())
        {
            record.put(eachField, valuesByField.get(eachField));
        }

        // Return the Lead record
        return record;
    }
    public abstract Schema.SObjectType getSObjectType();

}