/**
    apex compiler.
    
    author : kiwi

**/
public class AutoForce_Code_Compiler
{
    private String sessionId;
    private AutoForce_Code_WS.Apex apex = new AutoForce_Code_WS.Apex();
    private AutoForce_Page_Compiler reader;
    
    public AutoForce_Code_Compiler(String sessionId, String server)
    {
        this.sessionId = sessionId;
        
        AutoForce_Code_WS.SessionHeader_element session = new AutoForce_Code_WS.SessionHeader_element();
        session.sessionId = sessionId;
        
        apex.SessionHeader = session;
        
        reader = new AutoForce_Page_Compiler(sessionId, server + AutoForce_Constant.TOOLING_SERVICE_URL_t);
    }
    
	public Map<String, String> compile(String clazz)
	{											
		List<String> classes = new List<String>();
		classes.add(clazz);
		
		long start = System.currentTimeMillis();
		
		AutoForce_Code_WS.CompileClassResult[] compileResult =  apex.compileClasses(classes);
		
		long en = System.currentTimeMillis();
		
		long use = en - start;
		
		AutoForce_Code_WS.CompileClassResult compileClassResult = compileResult[0];
		
		if(compileClassResult.success) {
			
			Map<String, String> result = new Map<String, String>();
			
			result.put('line', '' + compileClassResult.line);
			result.put('time', ''+ use);
			result.put('message', 'Successfully compile Class: ' + compileClassResult.id);
					
			return result;			
		} 
		else 
		{			
			Map<String, String> result = new Map<String, String>();
			
			result.put('line', '' + compileClassResult.line);
			result.put('time', ''+ use);
			result.put('message', 'Fail compile Class: ' + compileClassResult.problem);
					
			return result;
		}
	}
	
	
	public Map<String, String> compileTrigger(String clazz)
	{											
		List<String> classes = new List<String>();
		classes.add(clazz);
		
		long start = System.currentTimeMillis();
		
		AutoForce_Code_WS.CompileTriggerResult[] compileResult = apex.compileTriggers(classes);
	
		long en = System.currentTimeMillis();
		
		long use = en - start;
		
		AutoForce_Code_WS.CompileTriggerResult compileClassResult = compileResult[0];
		
		if(compileClassResult.success) {
			
			Map<String, String> result = new Map<String, String>();
			
			result.put('line', '' + compileClassResult.line);
			result.put('time', ''+ use);
			result.put('message', 'Successfully compile Class: ' + compileClassResult.id);
					
			return result;			
		} 
		else 
		{			
			Map<String, String> result = new Map<String, String>();
			
			result.put('line', '' + compileClassResult.line);
			result.put('time', ''+ use);
			result.put('message', 'Fail compile Class: ' + compileClassResult.problem);
					
			return result;
		}
	}
	
	public Map<String, String> compilePage(String id, String page, String type)
	{
		long start = System.currentTimeMillis();
		
        Map<String, String> reponse = reader.compile(id, page, type);
        
        long en = System.currentTimeMillis();
		
		long use = en - start;
        
        if(reponse.get('success').equals('true'))
        {
            Map<String, String> result = new Map<String, String>();
			
			result.put('line', '-1');
			result.put('time', ''+ use);
			result.put('message', 'Successfully compile Page: ' + id);
					
			return result;			
        }
        else
        {
            Map<String, String> result = new Map<String, String>();
			
			result.put('line', '-1');
			result.put('time', ''+ use);
			result.put('message', reponse.get('message'));
			
			return result;
        }
	
	}
	
	
	
}