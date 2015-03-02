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
            domainObject = mapUseConfig(sObj, domainType, config);
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

    public static final String OPEN_CURLY = '{';
    public static final String CLOSE_CURLY = '}';
    public static final String DOUBLE_QUOTE = '"';
    public static final String COMMA = ',';

    private Object mapUseConfig(SObject sObj, Type domainType, Map<String, String> config) {

        Object domainObject = null;

        String sObjJsonString = JSON.serialize(sObj);

        Integer previousPosition = 0;
        Integer currentPosition = 1;
        Integer jsonStringLength = sObjJsonString.length();
        String token = sObjJsonString.substring(previousPosition, currentPosition);

        GS_StringBuilder stringBuilder = new GS_StringBuilder(token);

        while(currentPosition < jsonStringLength) {
            if(token.isWhitespace()) {
                previousPosition = currentPosition;
                currentPosition++;
                token = sObjJsonString.substring(previousPosition, currentPosition);
            } else {
                if (token == OPEN_CURLY && previousPosition == 0 && currentPosition == 1) {
                    previousPosition = currentPosition;
                    currentPosition++;
                    token = sObjJsonString.substring(previousPosition, currentPosition);
                } else if (token == OPEN_CURLY) {
                    previousPosition = currentPosition;
                    currentPosition = sObjJsonString.indexOf(CLOSE_CURLY, previousPosition);
                    token = sObjJsonString.substring(previousPosition, currentPosition);
                } else if (token == DOUBLE_QUOTE) {
                    previousPosition = currentPosition;
                    currentPosition = sObjJsonString.indexOf(DOUBLE_QUOTE, previousPosition + 1);
                    token = sObjJsonString.substring(previousPosition, currentPosition);
                    
                    stringBuilder.add(token);
                    System.debug(LoggingLevel.ERROR, token);

                    previousPosition = currentPosition;
                    currentPosition = sObjJsonString.indexOf(COMMA, previousPosition + 1);
                    if(currentPosition == -1) {
                        break;
                    }
                    token = sObjJsonString.substring(previousPosition, currentPosition);
                } else if (token == CLOSE_CURLY) {
                    currentPosition++;
                } else {
                    
                }
                stringBuilder.add(token);
            }
        }

        return null;
    }

}