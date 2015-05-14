/**
    Controller for Code Editor
    
    author : kiwi

**/
public class AutoForce_Code_EditorController
{
    public String name { get; set; }
    public String code { get; set; }  
    public String type { get;set;}
    public String id { get;set;} 
    public String domain { get;set;} 
    public Long use { get;set;}
    
    public PageReference load()
    {
        id = ApexPages.currentPage().getParameters().get('id');
        name = ApexPages.currentPage().getParameters().get('name');
        type = ApexPages.currentPage().getParameters().get('type');
        
        domain = URL.getSalesforceBaseUrl().toExternalForm();
        
        Long start = system.currentTimeMillis();
        
        AutoForce_QueryProcessor reader = new AutoForce_QueryProcessor(UserInfo.getSessionId(), domain + AutoForce_Constant.TOOLING_SERVICE_URL);
        
        String source = null;
        
        if(type.equals('ApexClass') || type.equals('ApexTrigger'))
        {
             source = reader.getCode(id, type);
        }
        else
        {
             source = reader.getPage(id, type);
        }
        
        code = EncodingUtil.base64Encode(Blob.valueOf(source));
        
        Long en = System.currentTimeMillis();
        
        use = en - start;
        
        return null;
    }
    
    
    @RemoteAction
    public static Map<String, String> compile(String type, String code, String id, String server)
    {
        Map<String, String> result = new MAp<String, String>();
        
        AutoForce_Code_Compiler compiler = new AutoForce_Code_Compiler(UserInfo.getSessionId(), server);
			
		try {
			
			if(type.equals('ApexClass'))
				result = compiler.compile(code);
			else if(type.equals('ApexTrigger'))
				result = compiler.compileTrigger(code);
			else if(type.equals('ApexPage'))
				result = compiler.compilePage(id, code, 'ApexPage');
			else
				result = compiler.compilePage(id, code, 'ApexComponent');
			
		}
		catch (Exception e) 
		{
			result.put('line', '-1');
			result.put('time', '-1');
			result.put('message', e.getMessage());
			
			return result;
		}
    	    	
	    return result;
	
    }
    
}