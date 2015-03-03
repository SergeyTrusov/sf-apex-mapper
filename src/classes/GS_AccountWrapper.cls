public class GS_AccountWrapper {

    public String AccountId {get; set;}
    public String AccountName {get; set;}
    public String AccountType {get; set;}
    public String AccountOwner {get; set;}
    public Integer NoOfEmployees {get; set;}
    public Decimal Revenue {get; set;}

    public GS_AccountWrapper() {}
    public GS_AccountWrapper(String id, String name, String type, String owner, Integer numberofemployees, Decimal annualrevenue) {
        this.AccountId = id;
        this.AccountName = name;
        this.AccountType = type;
        this.AccountOwner = owner;
        this.NoOfEmployees = numberofemployees;
        this.Revenue = annualrevenue;
    }
    
}