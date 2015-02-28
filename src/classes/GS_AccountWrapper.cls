public class GS_AccountWrapper {

    public String Id {get; set;}
    public String name {get; set;}
    public String Type {get; set;}
    public String Owner {get; set;}
    public Integer NumberOfEmployees {get; set;}
    public Decimal AnnualRevenue {get; set;}

    public GS_AccountWrapper() {}
    public GS_AccountWrapper(String id, String name, String type, String owner, Integer numberofemployees, Decimal annualrevenue) {
        this.Id = id;
        this.name = name;
        this.Type = type;
        this.Owner = owner;
        this.NumberOfEmployees = numberofemployees;
        this.AnnualRevenue = annualrevenue;
    }
    
}