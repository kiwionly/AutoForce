/**
  Salesforce lib got type mapper error for Coverage generated class, So we need a class to parse a raw SOAP xml from tooling api.
  
  You may remove this and replace after salesforce fixed the lib issus. 
  However, the recent release api version 33 after test still show that this issue still unresolved.
  
 **/
public class AutoForce_QueryProcessor 
{       
    private String sessionId;
    private String url;
    
    public AutoForce_QueryProcessor(String sessionId, String url)
    {
        this.sessionId = sessionId;
        this.url = url;
    }
    
    public String getCode(String id, String type)
    {
        String soql = 'SELECT id, Body, name, ApiVersion, Status FROM ' + type + ' where id = \'' + id + '\'';
        List<ApexCode> result = queryClass(soql);
            
        ApexCode clazz = result.get(0);
        
        String body = clazz.body;
    
        return body;
    }
    
    public String getPage(String id, String type)
    {
        String soql = 'SELECT id, markup, name, ApiVersion FROM ' + type +' where id = \'' + id + '\'';
        List<ApexCode> result = queryClass(soql);
            
        ApexCode clazz = result.get(0);
        
        String markup = clazz.markup; 
    
        return markup;
    }
    
    public List<ApexCode> getList(String type, String filter)
    {
        String soql = 'SELECT id, name, ApiVersion FROM ' + type +' where name like \'' + filter + '%\' ';
        
        List<ApexCode> result = queryClass(soql);
        
        result.sort();
        
        return result;
    }
    
    public List<ApexCode> queryClass(String query)
    {       
        String request = getRequestXML(query);
    
        HttpResponse res = post(request);
    
        return toClass(res);
    }

    private String getRequestXML(String query)
    {
        String xml = 
        
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:tooling.soap.sforce.com">' +
            '   <soapenv:Header>' +
            '      <urn:SessionHeader>' + 
            '        <urn:sessionId>' + this.sessionId + '</urn:sessionId>' +
            '      </urn:SessionHeader>' +
            '   </soapenv:Header>' +
            '   <soapenv:Body>' +
            '      <urn:query>' +
            '         <urn:queryString>' + query + '</urn:queryString>' +
            '      </urn:query>' +
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
    
    
    public List<ApexCode> toClass(HttpResponse res)
    {
        List<ApexCode> recordList = new List<ApexCode>();
 
        Xmlstreamreader reader = res.getXmlStreamReader();
        
        ApexCode clazz = null;
        
        boolean enterRecord = false;
                
        while(reader.hasNext())
        {
            if(reader.getEventType() == XmlTag.START_ELEMENT)
            {
                String name = reader.getLocalName();
     
                if(name.equals('records'))
                {
                   clazz = new ApexCode();
                   
                   enterRecord = true;
                }
               
                if(name.equals('Id'))
                {
                    String val = getElementText(reader);
                    clazz.id = val;          
                }
                
                if(name.equals('Name'))
                {
                    String val = getElementText(reader);
                    clazz.name = val;
                }
                
                if(name.equals('Markup'))
                {
                    String val = getElementText(reader);
                    clazz.markup = val;
                }
                
                if(enterRecord) {
                
                    if(name.equals('Body'))
                    {
                        String val = getElementText(reader);
                        clazz.body = val;
                    }
                }
                
            }
            
            if(reader.getEventType() == XmlTag.END_ELEMENT)
            {
                String name = reader.getLocalName();
                
                if(name.equals('records'))
                {                                               
                    recordList.add(clazz);
                    
                    clazz = null;
                    
                    enterRecord = false;
                }              
            }
            
            reader.next();
        }
        
        return recordList;  
    }
    
    public class ApexCode implements Comparable
    {
        public String id;
        public String name;
        public String body;
        public String markup;
        
        public String getId()
        {
            return id;
        }
        
        public String getName()
        {
            return name;
        }
        
        public Integer compareTo(Object obj)
        {
            ApexCode c = (ApexCode)obj;
            
            if(c.name > name)
                return -1;
                
            if(c.name < name)
                return 1;
                
            return 0;
        }
    }
    

}