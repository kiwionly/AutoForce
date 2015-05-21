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
    public String last { get;set;}
    
    public PageReference load()
    {
        id = ApexPages.currentPage().getParameters().get('id');
        name = ApexPages.currentPage().getParameters().get('name');
        type = ApexPages.currentPage().getParameters().get('type');
        last = '' + getTime(type, id);
        
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
    
    private static boolean isModified(String lastModified, String type, String id)
    {
        DateTime myLastModifiedDate = DateTime.valueOfGMT(lastModified);
        
        if(type.equals('ApexClass'))
        {
            List<ApexClass> code = [select id, LastModifiedDate from ApexClass where id = :id limit 1];
            
            if(!code.isEmpty())
            {
                DateTime LastModifiedDate = DateTime.valueOf(code.get(0).LastModifiedDate);
                
                if(myLastModifiedDate < LastModifiedDate ){
                    return true;
                }
            }
        }
        
        if(type.equals('ApexTrigger'))
        {
            List<ApexTrigger> code = [select id, LastModifiedDate from ApexTrigger where id = :id limit 1];
            
            if(!code.isEmpty())
            {
                DateTime LastModifiedDate = DateTime.valueOf(code.get(0).LastModifiedDate);
                
                if(myLastModifiedDate < LastModifiedDate ){
                    return true;
                }
            }
        }
        
        if(type.equals('ApexPage'))
        {
            List<ApexPage> code = [select id, LastModifiedDate from ApexPage where id = :id limit 1];
            
            if(!code.isEmpty())
            {
                DateTime LastModifiedDate = DateTime.valueOf(code.get(0).LastModifiedDate);
                
                if(myLastModifiedDate < LastModifiedDate ){
                    return true;
                }
            }
        }
        
        if(type.equals('ApexComponent'))
        {
            List<ApexComponent> code = [select id, LastModifiedDate from ApexComponent where id = :id limit 1];
            
            if(!code.isEmpty())
            {
                DateTime LastModifiedDate = DateTime.valueOf(code.get(0).LastModifiedDate);
                
                if(myLastModifiedDate < LastModifiedDate ){
                    return true;
                }
            }
        }
        
        return false;
    }
    
    private static DateTime getTime(String type, String id)
    {
        if(type.equals('ApexClass'))
        {
            List<ApexClass> code = [select id, LastModifiedDate from ApexClass where id = :id limit 1];
            
            return code.isEmpty() ? null : code.get(0).LastModifiedDate;
        }
        
        if(type.equals('ApexTrigger'))
        {
            List<ApexTrigger> code = [select id, LastModifiedDate from ApexTrigger where id = :id limit 1];
            
            return code.isEmpty() ? null : code.get(0).LastModifiedDate;
        }
        
        if(type.equals('ApexPage'))
        {
            List<ApexPage> code = [select id, LastModifiedDate from ApexPage where id = :id limit 1];
            
            return code.isEmpty() ? null : code.get(0).LastModifiedDate;
        }
        
        if(type.equals('ApexComponent'))
        {
            List<ApexComponent> code = [select id, LastModifiedDate from ApexComponent where id = :id limit 1];
            
            return code.isEmpty() ? null : code.get(0).LastModifiedDate;
        }
        
        return null;
    }
    
    
    @RemoteAction
    public static Map<String, String> compile(String type, String code, String id, String server, String lastModified, boolean checkModified)
    {
        system.debug(lastModified);
        
        Map<String, String> result = new Map<String, String>();
        
        if(checkModified)
        {
            if(isModified(lastModified, type, id))
            {
                result.put('line', '-1');
    			result.put('time', '-1');
    			result.put('message', 'some one had update the source, please save your work and refresh to modify again');
    			
                return result;
            }
        }
        
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