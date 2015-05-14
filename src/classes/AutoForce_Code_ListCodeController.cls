/**
    AutoForce_Code_ListCodeController show all the list of class/trigger/page/component.
    
    author : kiwi

**/
public class AutoForce_Code_ListCodeController
{
    public String type { get;set;}
    public List<AutoForce_QueryProcessor.ApexCode> result { get;set;}
    public Long use { get;set;}
    public String domain { get;set;}
    
    public PageReference load()
    {
        type = ApexPages.currentPage().getParameters().get('type');
        String prefix = ApexPages.currentPage().getParameters().get('prefix');
        
        domain = URL.getSalesforceBaseUrl().toExternalForm();
        
        AutoForce_QueryProcessor reader = new AutoForce_QueryProcessor(UserInfo.getSessionId(), domain + AutoForce_Constant.TOOLING_SERVICE_URL);
        
        Long start = system.currentTimeMillis();
        
        result = reader.getList(type, prefix);
   
        Long en = System.currentTimeMillis();
        
        use = en - start;

        return null;
    }
}