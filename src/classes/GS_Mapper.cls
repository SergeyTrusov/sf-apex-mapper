public class GS_Mapper {

    // Constants
    public static final String CUSTOM_FIELDS_EXTENSION = '__c';
    public static final String DATE_JSON_FORMAT = '"{0}"';
    public static final Map<String, Type> NAME_TYPE_MAP = new Map<String, Type>{
        'DATE' => Date.class,
        'DATETIME' => DateTime.class
    };

    // Construstor
    public GS_Mapper() { }

    // Public Methods
    public Object mapTo(SObject sObj, Type domainType) {
        return mapTo(sObj, domainType, null);
    }

    public Object mapTo(SObject sObj, Type domainType, Map<String, String> config) {
        if(sObj == null) {
            throw new GS_MapperException(GS_ErrorMessage.valueIsNull('sObj'));
        }
        if(domainType == null) {
            throw new GS_MapperException(GS_ErrorMessage.valueIsNull('domainType'));
        }

        Object domainObject = null;
        if(config == null) {
            domainObject = autoMap(sObj, domainType);
        } else {
            domainObject = mapUseConfigThrowJson(sObj, domainType, config);
        }
        return domainObject;
    }

    public SObject mapToSObj(Object domainObject, SObjectType sObjType) {
        return mapToSObj(domainObject, sObjType, null);
    }

    public SObject mapToSObj(Object domainObject, SObjectType sObjType, Map<String, String> reverseConfig) {
        if (domainObject == null) {
            throw new GS_MapperException(GS_ErrorMessage.valueIsNull('domainObject'));
        }
        if (sObjType == null) {
            throw new GS_MapperException(GS_ErrorMessage.valueIsNull('sObjType'));
        }

        SObject sObj = null;
        if (reverseConfig == null) {
            sObj = reverseAutoMap(domainObject, sObjType);
        } else {
            sObj = reverseMapUseConfig(domainObject, sObjType, reverseConfig);
        }
        return sObj;
    }

    // Private Methods
    private Object autoMap(SObject sObj, Type domainType) {
        
        Object domainObject = null;

        String sObjJsonString = JSON.serialize(sObj);

        Schema.SObjectType sObjectType = sObj.getSobjectType();
        Schema.DescribeSObjectResult sObejctDescription = sObjectType.getDescribe();
        if(sObejctDescription.isCustom()) {
            Map<String, Object> untypedSObjectMap = (Map<String, Object>) JSON.deserializeUntyped(sObjJsonString);
            String newKey;
            for(String key : untypedSObjectMap.keySet()) {
                if(key.endsWith(CUSTOM_FIELDS_EXTENSION)) {
                    newKey = key.removeEnd(CUSTOM_FIELDS_EXTENSION);
                    Object value = untypedSObjectMap.remove(key);
                    untypedSObjectMap.put(newKey, value);
                }
            }
            sObjJsonString = JSON.serialize(untypedSObjectMap);
        }
        domainObject = JSON.deserialize(sObjJsonString, domainType);
        
        return domainObject;
    }

    private Object mapUseConfigThrowJson(SObject sObj, Type domainType, Map<String, String> config) {
        String serializedSObj = JSON.serialize(sObj);

        Map<String, Object> untypedSObjMap = (Map<String, Object>) JSON.deserializeUntyped(serializedSObj);
        Map<String, Object> untypedDomainMap = new Map<String, Object>();

        String mappingDomainValue;
        Object value;
        Set<String> mappingKeys = config.keySet();

        for (String mappingKey : mappingKeys) {
            if (untypedSObjMap.containsKey(mappingKey)) {
                mappingDomainValue = config.get(mappingKey);
                value = untypedSObjMap.get(mappingKey);
                untypedDomainMap.put(mappingDomainValue, value);
            }
        }

        String serializedDomain = JSON.serialize(untypedDomainMap);
        Object result = JSON.deserialize(serializedDomain, domainType);
        return result;
    }

    private SObject reverseMapUseConfig(Object domainObj, sObjectType sObjType, Map<String, String> config) {
        String serializedDomain = JSON.serialize(domainObj);

        Map<String, Object> untypedDomainMap = (Map<String, Object>) JSON.deserializeUntyped(serializedDomain);

        String mappingSObjFieldValue;
        Object value;
        Set<String> mappingKeys = config.keySet();

        SObject sObj = sObjType.newSObject();
        Map<String, Schema.SObjectField> fieldSet = sObjType.getDescribe().fields.getMap();

        for (String mappingKey : mappingKeys) {
            if (untypedDomainMap.containsKey(mappingKey)) {
                mappingSObjFieldValue = config.get(mappingKey);
                value = untypedDomainMap.get(mappingKey);
                if (value != null && fieldSet.containsKey(mappingSObjFieldValue)) {
                    sObj.put(mappingSObjFieldValue, value);
                }
            }
        }

        return sObj;
    }

    private SObject reverseAutoMap(Object domainObj, sObjectType sObjType) {
        String serializedDomain = JSON.serialize(domainObj);

        Map<String, Object> untypedDomainMap = (Map<String, Object>) JSON.deserializeUntyped(serializedDomain);

        Object value;
        String customFieldName = '';

        SObject sObj = sObjType.newSObject();
        Schema.DescribeSObjectResult sObjectDescription = sObjType.getDescribe();
        Map<String, Schema.SObjectField> fieldSet = sObjectDescription.fields.getMap();

        for (String domainObjectKey : untypedDomainMap.keySet()) {
            value = untypedDomainMap.get(domainObjectKey);
            customFieldName = domainObjectKey;
            if(sObjectDescription.isCustom()) {
                customFieldName = domainObjectKey + CUSTOM_FIELDS_EXTENSION;
            }
            if (value != null && fieldSet.containsKey(customFieldName)) {
                Schema.DescribeFieldResult describeFieldResult = fieldSet.get(customFieldName).getDescribe();
                Schema.SoapType soapType = describeFieldResult.getSoapType();
                String typeName = soapType.name();
                if (NAME_TYPE_MAP.containsKey(typeName)) {
                    String formattedString = String.format(DATE_JSON_FORMAT, new String[]{(String)value});
                    sObj.put(customFieldName, JSON.deserialize(formattedString, NAME_TYPE_MAP.get(typeName)));
                } else {
                    sObj.put(customFieldName, value);
                }
            }
        }
        return sObj;
    }


    //
    // @deprecated
    //
    //public static final String OPEN_CURLY = '{';
    //public static final String CLOSE_CURLY = '}';
    //public static final String DOUBLE_QUOTE = '"';
    //public static final String COMMA = ',';

    //private Object mapUseConfig(SObject sObj, Type domainType, Map<String, String> config) {

    //    Object domainObject = null;

    //    String sObjJsonString = JSON.serialize(sObj);

    //    Integer previousPosition = 0;
    //    Integer currentPosition = 1;
    //    Integer jsonStringLength = sObjJsonString.length();
    //    String token = sObjJsonString.substring(previousPosition, currentPosition);

    //    GS_StringBuilder stringBuilder = new GS_StringBuilder(token);

    //    while(currentPosition < jsonStringLength) {
    //        if(token.isWhitespace()) {
    //            previousPosition = currentPosition;
    //            currentPosition++;
    //            token = sObjJsonString.substring(previousPosition, currentPosition);
    //        } else {
    //            if (token == OPEN_CURLY && previousPosition == 0 && currentPosition == 1) {
    //                previousPosition = currentPosition;
    //                currentPosition++;
    //                token = sObjJsonString.substring(previousPosition, currentPosition);
    //            } else if (token == OPEN_CURLY) {
    //                previousPosition = currentPosition;
    //                currentPosition = sObjJsonString.indexOf(CLOSE_CURLY, previousPosition);
    //                token = sObjJsonString.substring(previousPosition, currentPosition);
    //            } else if (token == DOUBLE_QUOTE) {
    //                previousPosition = currentPosition;
    //                currentPosition = sObjJsonString.indexOf(DOUBLE_QUOTE, previousPosition + 1);
    //                token = sObjJsonString.substring(previousPosition, currentPosition);
                    
    //                stringBuilder.add(token);

    //                previousPosition = currentPosition;
    //                currentPosition = sObjJsonString.indexOf(COMMA, previousPosition + 1);
    //                if(currentPosition == -1) {
    //                    break;
    //                }
    //                token = sObjJsonString.substring(previousPosition, currentPosition);
    //            } else if (token == CLOSE_CURLY) {
    //                currentPosition++;
    //            } else {
                    
    //            }
    //            stringBuilder.add(token);
    //        }
    //    }
    //    return null;
    //}
}