/**
    AutoForce_Test_Controller show a list of apex class/trigger with code caverage.
    
    author : kiwi

**/
public class AutoForce_Test_ListController 
{
    public String type { get;set;}
    public List<AutoForce_Test_CodeCoverageReader.TestResult> result { get;set;}
    public Long use { get;set;}
        
    public PageReference load()
    {
        type = ApexPages.currentPage().getParameters().get('type');
        String prefix = ApexPages.currentPage().getParameters().get('prefix');
        
        String domain = URL.getSalesforceBaseUrl().toExternalForm();
        
        Long start = system.currentTimeMillis();
        
        AutoForce_Test_CodeCoverageReader reader = new AutoForce_Test_CodeCoverageReader(UserInfo.getSessionId(), domain);
        
        if(type == null){
            type = 'ApexClass';
        }
        
        if(prefix == null) {
            prefix = '';
        }
        
        result = reader.getCodeCoverage(type, prefix);
        
        Long en = System.currentTimeMillis();
        
        use = en - start;

        return null;
    }
     
}