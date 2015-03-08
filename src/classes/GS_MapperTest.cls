@isTest(seeAllData = false)
private class GS_MapperTest {

    private static Map<String, String> mappingAccountConfig = new Map<String, String> {
        'Id' => 'AccountId',
        'Name' => 'AccountName',
        'Type' => 'AccountType',
        'Owner' => 'AccountOwner',
        'NumberOfEmployees' => 'NoOfEmployees',
        'AnnualRevenue' => 'Revenue'
    };

    private static Map<String, String> reverseMappingAccountConfig = new Map<String, String> {
        'AccountId' => 'Id',
        'AccountName' => 'Name' ,
        'AccountType' => 'Type',
        'AccountOwner' => 'Owner',
        'NoOfEmployees' => 'NumberOfEmployees',
        'Revenue' => 'AnnualRevenue'
    };

    // Account Const
    private static final String ACCOUNT_ID = Account.getSObjectType().getDescribe().getKeyPrefix() + '000000000001';
    private static final String CONTACT_ID = Contact.getSObjectType().getDescribe().getKeyPrefix() + '000000000001';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final Decimal ACCOUNT_ANNUAL_REVENUE = 55.0;
    private static final Integer ACCOUNT_NUMBER_OF_EMPLOYEES = 20;

    // CustomObject Const
    public static final String TEST_NAME = 'Test';
    public static final Integer TEST_COUNT = 1;
    public static final Decimal TEST_DECIMAL = 1.111;
    public static final Date TEST_DATE = Date.today();
    public static final DateTime TEST_DATETIME = Datetime.now();
    public static final Boolean TEST_BOOLEAN = true;
    public static final String TEST_STRING = 'A lot of text.';

    @testSetup
    static void setupData() {
        SObject[] sObjectToInsert = new SObject[] {};

        Account testAccount = new Account(
            Name = ACCOUNT_NAME,
            AnnualRevenue = ACCOUNT_ANNUAL_REVENUE,
            NumberOfEmployees = ACCOUNT_NUMBER_OF_EMPLOYEES
        );
        sObjectToInsert.add(testAccount);
        
        Contact contact = new Contact (
            LastName = TEST_NAME
        );
        sObjectToInsert.add(contact);

        insert sObjectToInsert;

        GS_TestCO__c testCo = new GS_TestCO__c(
            Name = TEST_NAME,
            AccountId__c = testAccount.Id,
            ContactId__c = contact.Id,
            Count__c = TEST_COUNT,
            thisCurrency__c = TEST_DECIMAL,
            thisDateTime__c = TEST_DATETIME,
            thisDate__c = TEST_DATE,
            IsActive__c = TEST_BOOLEAN,
            TextArea__c = TEST_STRING
        );
        insert testCo;
    }
    
    @isTest(seeAllData = false)
    static void testMapSObjectToDomainUseConfig() {

        Account[] accounts = [
            Select Id, Name, AnnualRevenue, NumberOfEmployees
            From Account
            Where Name = :ACCOUNT_NAME
        ];

        GS_Mapper mapper = new GS_Mapper();
        GS_AccountWrapperCF mappingResult = (GS_AccountWrapperCF) mapper.mapTo(
            accounts[0], 
            GS_AccountWrapperCF.class,
            mappingAccountConfig
        );

        System.assert(String.isNotBlank(mappingResult.AccountId));
        System.assertEquals(ACCOUNT_NAME, mappingResult.AccountName);
        System.assertEquals(ACCOUNT_ANNUAL_REVENUE, mappingResult.Revenue);
        System.assertEquals(ACCOUNT_NUMBER_OF_EMPLOYEES, mappingResult.NoOfEmployees);
    }

    @isTest(seeAllData = false)
    static void testMapSObjectToDomainExceptions() {

        GS_Mapper mapper = new GS_Mapper();
        GS_AccountWrapperCF mappingResult = null;

        try {
            mappingResult = (GS_AccountWrapperCF) mapper.mapTo(null, null);
        } catch(GS_MapperException mapperException) {
            System.assertEquals(GS_ErrorMessage.valueIsNull('sObj'), mapperException.getMessage());
        }

        Account[] accounts = [
            SELECT Id, Name, AnnualRevenue, NumberOfEmployees
            FROM Account
            WHERE Name = :ACCOUNT_NAME
            LIMIT 1
        ];

        try {
            mappingResult = (GS_AccountWrapperCF) mapper.mapTo(accounts[0], null);
        } catch(GS_MapperException mapperException) {
            System.assertEquals(GS_ErrorMessage.valueIsNull('domainType'), mapperException.getMessage());
        }

        System.assertEquals(mappingResult, null);
    }
    
    @isTest(seeAllData = false)
    static void testAutoMapSObjectToDomain() {

        Account[] accounts = [
            Select Id, Name, AnnualRevenue, NumberOfEmployees
            From Account
            Where Name = :ACCOUNT_NAME
        ];

        GS_Mapper mapper = new GS_Mapper();
        GS_AccountWrapperSF mappingResult = (GS_AccountWrapperSF) mapper.mapTo(
            accounts[0], 
            GS_AccountWrapperSF.class
        );

        System.assert(String.isNotBlank(mappingResult.Id));
        System.assertEquals(ACCOUNT_NAME, mappingResult.Name);
        System.assertEquals(ACCOUNT_ANNUAL_REVENUE, mappingResult.AnnualRevenue);
        System.assertEquals(ACCOUNT_NUMBER_OF_EMPLOYEES, mappingResult.NumberOfEmployees);
    }

    @isTest(seeAllData = false)
    static void testAutoMapCustomSObjectToDomain() {

        GS_TestCO__c[] testCustomObjs = [
            Select Id, Name, AccountId__c, ContactId__c, Count__c, thisCurrency__c, thisDateTime__c, thisDate__c, IsActive__c, TextArea__c
            From GS_TestCO__c
            Where Name = :TEST_NAME
        ];

        GS_Mapper mapper = new GS_Mapper();
        GS_TestCOWrapperSF mappingResult = (GS_TestCOWrapperSF) mapper.mapTo(
            testCustomObjs[0], 
            GS_TestCOWrapperSF.class
        );

        System.assert(String.isNotBlank(mappingResult.Id));
        System.assertEquals(testCustomObjs[0].AccountId__c, mappingResult.AccountId);
        System.assertEquals(testCustomObjs[0].ContactId__c, mappingResult.ContactId);
        System.assertEquals(TEST_NAME, mappingResult.Name);
        System.assertEquals(TEST_COUNT, mappingResult.Count);
        System.assertEquals(TEST_DECIMAL, mappingResult.thisCurrency);
        System.assertEquals(TEST_DATETIME, mappingResult.thisDateTime);
        System.assertEquals(TEST_DATE, mappingResult.thisDate);
        System.assertEquals(TEST_BOOLEAN, mappingResult.IsActive);
        System.assertEquals(TEST_STRING, mappingResult.TextArea);
    }

    @isTest(seeAllData = false) 
    static void testMapDomainToSObjectUseConfig() {
        Account[] accounts = [
            Select Id, Name, AnnualRevenue, NumberOfEmployees
            From Account
            Where Name = :ACCOUNT_NAME
        ];

        GS_Mapper mapper = new GS_Mapper();

        GS_AccountWrapperCF wrapper = new GS_AccountWrapperCF();
        wrapper.AccountId = accounts[0].Id;
        wrapper.AccountName = accounts[0].Name;
        wrapper.Revenue = accounts[0].AnnualRevenue;
        wrapper.NoOfEmployees = accounts[0].NumberOfEmployees;

        Account mappingResult = (Account) mapper.mapToSObj(
            wrapper,
            Account.getSObjectType(),
            reverseMappingAccountConfig
        );

        System.assert(String.isNotBlank(mappingResult.Id));
        System.assertEquals(ACCOUNT_NAME, mappingResult.Name);
        System.assertEquals(ACCOUNT_ANNUAL_REVENUE, mappingResult.AnnualRevenue);
        System.assertEquals(ACCOUNT_NUMBER_OF_EMPLOYEES, mappingResult.NumberOfEmployees);
    }

    @isTest(seeAllData = false) 
    static void testAutoMapDomainToSObject() {

        GS_Mapper mapper = new GS_Mapper();

        GS_AccountWrapperSF wrapper = new GS_AccountWrapperSF();
        wrapper.Id = ACCOUNT_ID;
        wrapper.Name = ACCOUNT_NAME;
        wrapper.AnnualRevenue = ACCOUNT_ANNUAL_REVENUE;
        wrapper.NumberOfEmployees = ACCOUNT_NUMBER_OF_EMPLOYEES;

        Account mappingResult = (Account) mapper.mapToSObj(
            wrapper,
            Account.getSObjectType()
        );

        System.assert(String.isNotBlank(mappingResult.Id));
        System.assertEquals(ACCOUNT_NAME, mappingResult.Name);
        System.assertEquals(ACCOUNT_ANNUAL_REVENUE, mappingResult.AnnualRevenue);
        System.assertEquals(ACCOUNT_NUMBER_OF_EMPLOYEES, mappingResult.NumberOfEmployees);
    }

    @isTest(seeAllData = false) 
    static void testAutoMapDomainToCustomSObject() {

        GS_Mapper mapper = new GS_Mapper();

        GS_TestCOWrapperSF wrapper = new GS_TestCOWrapperSF();
        wrapper.AccountId = ACCOUNT_ID;
        wrapper.ContactId = CONTACT_ID;
        // ToDo standard fields
        //wrapper.Name = TEST_NAME;
        wrapper.Count = TEST_COUNT;
        wrapper.thisCurrency = TEST_DECIMAL;
        wrapper.thisDateTime = TEST_DATETIME;
        wrapper.thisDate = TEST_DATE;
        wrapper.IsActive = TEST_BOOLEAN;
        wrapper.TextArea = TEST_STRING;

        System.debug(JSON.serialize(wrapper));
        System.debug(GS_TestCO__c.getSObjectType());

        GS_TestCO__c mappingResult = (GS_TestCO__c) mapper.mapToSObj(
            wrapper,
            GS_TestCO__c.getSObjectType()
        );

        System.debug(mappingResult);

        System.assertEquals(ACCOUNT_ID, mappingResult.AccountId__c);
        System.assertEquals(CONTACT_ID, mappingResult.ContactId__c);
        // ToDo
        //System.assertEquals(TEST_NAME, mappingResult.Name);
        System.assertEquals(TEST_COUNT, mappingResult.Count__c);
        System.assertEquals(TEST_DECIMAL, mappingResult.thisCurrency__c);
        System.assertEquals(TEST_DATETIME, mappingResult.thisDateTime__c);
        System.assertEquals(TEST_DATE, mappingResult.thisDate__c);
        System.assertEquals(TEST_BOOLEAN, mappingResult.IsActive__c);
        System.assertEquals(TEST_STRING, mappingResult.TextArea__c);
    }

    @isTest(seeAllData = false)
    static void testMapDomainToSObjectExceptions() {

        GS_Mapper mapper = new GS_Mapper();
        Account mappingResult = null;

        try {
            mappingResult = (Account) mapper.mapToSObj(null, null);
        } catch(GS_MapperException mapperException) {
            System.assertEquals(GS_ErrorMessage.valueIsNull('domainObject'), mapperException.getMessage());
        }

        GS_AccountWrapperSF accountWrapper = new GS_AccountWrapperSF();

        try {
            mappingResult = (Account) mapper.mapToSObj(accountWrapper, null);
        } catch(GS_MapperException mapperException) {
            System.assertEquals(GS_ErrorMessage.valueIsNull('sObjType'), mapperException.getMessage());
        }

        System.assertEquals(mappingResult, null);
    }

    abstract class GS_SObjectWrapperBase {
        public String Id {get; set;}
        public String Name {get; set;}
    }

    class GS_AccountWrapperSF extends GS_SObjectWrapperBase {
        public String Type {get; set;}
        public String Owner {get; set;}
        public Integer NumberOfEmployees {get; set;}
        public Decimal AnnualRevenue {get; set;}
    }

    class GS_AccountWrapperCF {
        public String AccountId {get; set;}
        public String AccountName {get; set;}
        public String AccountType {get; set;}
        public String AccountOwner {get; set;}
        public Integer NoOfEmployees {get; set;}
        public Decimal Revenue {get; set;}
    }

    class GS_TestCOWrapperSF extends GS_SObjectWrapperBase {
        public String AccountId {get; set;}
        public String ContactId {get; set;}
        public Integer Count {get; set;}
        public Decimal thisCurrency {get; set;}
        public DateTime thisDateTime {get; set;}
        public Date thisDate {get; set;}
        public Boolean IsActive {get; set;}
        public String TextArea {get; set;}
    }

}