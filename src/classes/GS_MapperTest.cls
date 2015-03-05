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

    private static final String ACCOUNT_NAME = 'Test Account';
    private static final Decimal ACCOUNT_ANNUAL_REVENUE = 55.0;
    private static final Integer ACCOUNT_NUMBER_OF_EMPLOYEES = 20;

    @testSetup
    static void setupData() {
        Account testAccount = new Account(
            Name = ACCOUNT_NAME,
            AnnualRevenue = ACCOUNT_ANNUAL_REVENUE,
            NumberOfEmployees = ACCOUNT_NUMBER_OF_EMPLOYEES
        );
        insert testAccount;
    }
    
    @isTest(seeAllData = false)
    static void testMappingUseConfig() {

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
    static void testMappingExceptions() {

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
    static void testAutoMapping() {

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

    public class GS_AccountWrapperCF {

        public String AccountId {get; set;}
        public String AccountName {get; set;}
        public String AccountType {get; set;}
        public String AccountOwner {get; set;}
        public Integer NoOfEmployees {get; set;}
        public Decimal Revenue {get; set;}

        //public GS_AccountWrapperCF() {}
        //public GS_AccountWrapperCF(String id, String name, String type, String owner, Integer numberofemployees, Decimal annualrevenue) {
        //    this.AccountId = id;
        //    this.AccountName = name;
        //    this.AccountType = type;
        //    this.AccountOwner = owner;
        //    this.NoOfEmployees = numberofemployees;
        //    this.Revenue = annualrevenue;
        //}
    }

}