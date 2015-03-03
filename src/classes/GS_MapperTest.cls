@isTest
private class GS_MapperTest {

	private static Map<String, String> mappingAccountConfig = new Map<String, String> {
		'Id' => 'AccountId',
		'Name' => 'AccountName',
		'Type' => 'AccountType',
		'Owner' => 'AccountOwner',
		'NumberOfEmployees' => 'NoOfEmployees',
		'AnnualRevenue' => 'Revenue'
	};

	private static Account testAccount = new Account(
		Name = 'Test Account',
		AnnualRevenue = 55.0,
		NumberOfEmployees = 20
	);
	
	static void prepareData() {
		insert testAccount;
	}
	
	@isTest(seeAllData = false)
	static void testMapping() {
		prepareData();

		GS_Mapper mapper = new GS_Mapper();
		GS_AccountWrapper mappingResult = (GS_AccountWrapper) mapper.mapTo(
			testAccount, 
			GS_AccountWrapper.class,
			mappingAccountConfig
		);

		System.assert(String.isNotBlank(mappingResult.AccountId));
		System.assertEquals('Test Account', mappingResult.AccountName);
		System.assertEquals(55.0, mappingResult.Revenue);
		System.assertEquals(20, mappingResult.NoOfEmployees);

	}
	
}