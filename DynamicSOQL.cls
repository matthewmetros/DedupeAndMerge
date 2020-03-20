public class DynamicSOQL {


    public static List<String> getFields(String ObjectName, Boolean updateable)
    {
        String SobjectApiName = objectName;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
 
        List<String>apiNames =  new list<String>();

        for(String apiName : fieldMap.keyset())
        {
            // && fieldMap.get(apiName).getDescribe().getCompoundFieldName() == Null

            if(fieldMap.get(apiName).getDescribe().isUpdateable() == updateable) 
            {
                apiNames.add(apiName);
            }
        }
        return apiNames;
    }



    public static List<Sobject> Soql (String ObjectName, List<String> apiNames, Set<String> IdsToQuery )
    {
        String query;
        String SobjectApiName = objectName;

        String allstring = string.join(apiNames,',');


        query = 'SELECT ' + allstring + ' FROM ' + SobjectApiName + ' WHERE ID = :IdsToQuery';
        Sobject[] sObjectList = Database.query(query);
        return sObjectList;
    }



}
