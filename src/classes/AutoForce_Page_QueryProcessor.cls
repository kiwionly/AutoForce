/**
  Salesforce lib got type mapper error for Coverage generated class, So we need a class to parse a raw SOAP xml from tooling api.
  
  You may remove this and replace after salesforce fixed the lib issus. 
  However, the recent release api version 33 after test still show that this issue still unresolved.
  
 **/
public class AutoForce_Page_QueryProcessor 
{       
    private String sessionId;
    private String url;
    
    public AutoForce_Page_QueryProcessor(String sessionId, String url)
    {
        this.sessionId = sessionId;
        this.url = url;
    }
    
    public Map<String, String> compile(String id, String page, String type)
    {       
        String request = getRequestXML(id, page, type);
    
        HttpResponse res = post(request);
    
        return toResult(res);
    }
   
    private String getRequestXML(String id, String page, String type)
    {
        String xml = 
        
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com" xmlns:urn1="urn:sobject.enterprise.soap.sforce.com">' +
            '   <soapenv:Header>' +
            '      <urn:SessionHeader>' + 
            '        <urn:sessionId>' + this.sessionId + '</urn:sessionId>' +
            '      </urn:SessionHeader>' +
            '   </soapenv:Header>' +
            '   <soapenv:Body>' +
            '      <urn:update>' +
            '           <urn:sObjects>' + 
            '               <urn1:type>' + type + '</urn1:type>' +
            '               <urn1:Markup>' + page + '</urn1:Markup>' +
            '               <urn1:Id>' + id + '</urn1:Id>' +
            '           </urn:sObjects>' +
            '      </urn:update>' +
            '   </soapenv:Body>' +
            '</soapenv:Envelope>';
        
        return xml;
    }
    
    private HttpResponse post(String body)
    {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('SOAPAction', '1.0');
        req.setHeader('Content-Type', 'text/xml');
        req.setEndpoint(this.url);
        req.setMethod('POST');
        req.setBody(body);
        req.setTimeout(30000); 
        
        HttpResponse res = http.send(req);

        return res;
    }
    
    
    public Map<String, String> toResult(HttpResponse res)
    {
         Map<String, String> result = new Map<String, String>();
         result.put('success', 'false'); 

        Xmlstreamreader reader = res.getXmlStreamReader();
        
        AutoForce_Test_Record records = null;
        
        while(reader.hasNext())
        {
            if(reader.getEventType() == XmlTag.START_ELEMENT)
            {
                String name = reader.getLocalName();
               
                if(name.equals('success'))
                {
                    String val = getElementText(reader);
                    
                    result.put('success', val);                             
                }
                
                if(name.equals('message'))
                {
                    String val = getElementText(reader);

                    result.put('message', val);
                }                    
            }
            
            reader.next();
            
        }
     
        return result;  
    }
    
    private String getElementText(XMLStreamReader reader)
    {       
        String text = '';
        
        while(reader.hasNext())
        {
            if(reader.getEventType() == XmlTag.END_ELEMENT)
            {   
                break;
            }
            else if(reader.getEventType() == XmlTag.CHARACTERS)
            {               
                text += reader.getText();
            }
                        
            reader.next();
        }

        return text;
    }
    

}