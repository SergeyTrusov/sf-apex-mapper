public class GS_Mapper {

    public static final String CUSTOM_FIELDS_EXTENSION = '__c';
    public GS_Mapper() { }

    public Object mapTo(SObject sObj, Type domainType) {
        return mapTo(sObj, domainType, null);
    }

    public Object mapTo(SObject sObj, Type domainType, Map<String, String> config) {
        
        if(sObj == null) {
            return new GS_MapperException(GS_ErrorMessage.valueIsNull('sObj'));
        }

        if(domainType == null) {
            return new GS_MapperException(GS_ErrorMessage.valueIsNull('domainType'));
        }

        Object domainObject = null;

        if(config == null) {
            domainObject = autoMap(sObj, domainType);
        } else {

        }


        //String domainTypeInstanceJson = JSON.serialize(domainType.newInstance());
        //System.debug(LoggingLevel.ERROR, domainTypeInstanceJson);
        
        //String token = 'Id';
        //Integer startIndex = domainTypeInstanceJson.indexOf(token) + token.length();

        //System.debug(LoggingLevel.ERROR, startIndex);

        //startIndex = domainTypeInstanceJson.indexOf(':', startIndex) + 1;
        //Integer endIndex = domainTypeInstanceJson.indexOf(',', startIndex);

        //String f = domainTypeInstanceJson.substring(startIndex, endIndex);
        //System.debug(LoggingLevel.ERROR, f);

        //for (String key : config.keySet()) {

        //}
        return domainObject;
    }

    private Object autoMap(SObject sObj, Type domainType) {
        
        Object domainObject = null;

        String sObjJsonString = JSON.serialize(sObj);

        Schema.SObjectType sObjectType = sObj.getSobjectType();
        Schema.DescribeSObjectResult sObejctDescription = sObjectType.getDescribe();
        if(sObejctDescription.isCustom()) {
            //TODO: Find Right Way
            sObjJsonString = sObjJsonString.remove(CUSTOM_FIELDS_EXTENSION);
        }
        domainObject = JSON.deserialize(sObjJsonString, domainType);
        
        return domainObject;
    }

}