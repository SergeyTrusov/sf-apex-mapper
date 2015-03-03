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

    public static final String ACCOUNT_NAME = 'Test Account';

    @testSetup
    static void prepareData() {
        Account testAccount = new Account(
            Name = ACCOUNT_NAME,
            AnnualRevenue = 55.0,
            NumberOfEmployees = 20
        );
        insert testAccount;
    }
    
    @isTest(seeAllData = false)
    static void testMapping() {
        //prepareData();

        Account[] accounts = [
            Select Id, Name, AnnualRevenue, NumberOfEmployees
            From Account
            Where Name = :ACCOUNT_NAME
        ];

        GS_Mapper mapper = new GS_Mapper();
        GS_AccountWrapper mappingResult = (GS_AccountWrapper) mapper.mapTo(
            accounts[0], 
            GS_AccountWrapper.class,
            mappingAccountConfig
        );

        System.assert(String.isNotBlank(mappingResult.AccountId));
        //System.assertEquals('Test Account', mappingResult.AccountName);
        //System.assertEquals(55.0, mappingResult.Revenue);
        //System.assertEquals(20, mappingResult.NoOfEmployees);

    }
    
}