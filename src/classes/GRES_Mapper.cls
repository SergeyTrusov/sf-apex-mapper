public class GRES_Mapper {
	public GRES_Mapper() {
		
	}

	public Object mapTo(SObject sObj, Type domainType, Map<String, String> config) {
		String domainTypeInstanceJson = JSON.serialize(domainType.newInstance());
		System.debug(LoggingLevel.ERROR, domainTypeInstanceJson);
		
		String token = 'Id';
		Integer startIndex = domainTypeInstanceJson.indexOf(token) + token.length();

		System.debug(LoggingLevel.ERROR, startIndex);

		startIndex = domainTypeInstanceJson.indexOf(':', startIndex) + 1;
		Integer endIndex = domainTypeInstanceJson.indexOf(',', startIndex);

		String f = domainTypeInstanceJson.substring(startIndex, endIndex);
		System.debug(LoggingLevel.ERROR, f);

		//for (String key : config.keySet()) {

		//}
		return null;
	}

	public class AccountWrapper {
		public String Id {get; set;}
		public String Name {get; set;}
		public String Type {get; set;}
		public String Owner {get; set;}
		public Integer NumberOfEmployees {get; set;}
		public Decimal AnnualRevenue {get; set;}

		public AccountWrapper() {}
		public AccountWrapper(String id, String name, String type, String owner, Integer numberofemployees, Decimal annualrevenue) {
			this.Id = id;
			this.Name = name;
			this.Type = type;
			this.Owner = owner;
			this.NumberOfEmployees = numberofemployees;
			this.AnnualRevenue = annualrevenue;
		}

	} 
}