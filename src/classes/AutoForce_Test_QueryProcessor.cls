/**
  Salesforce lib got type mapper error for Coverage generated class, So we need a class to parse a raw SOAP xml from tooling api.
  
  You may remove this and replace after salesforce fixed the lib issus. 
  However, the recent release api version 33 still no resolved.
  
 **/
public class AutoForce_Test_QueryProcessor 
{       
    private String sessionId;
    private String url;
    
    public AutoForce_Test_QueryProcessor(String sessionId, String url)
    {
        this.sessionId = sessionId;
        this.url = url;
    }
    
    public List<AutoForce_Test_Record> query(String query)
    {       
        String request = getRequestXML(query);
    
        HttpResponse res = post(request);
    
        return toResult(res);
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
    
    
    public List<AutoForce_Test_Record> toResult(HttpResponse res)
    {
        List<AutoForce_Test_Record> recordList = new List<AutoForce_Test_Record>();

        Xmlstreamreader reader = res.getXmlStreamReader();
        
        AutoForce_Test_Record records = null;
        
        while(reader.hasNext())
        {
            if(reader.getEventType() == XmlTag.START_ELEMENT)
            {
                String name = reader.getLocalName();
               
                if(name.equals('records'))
                {
                   records = new AutoForce_Test_Record();                                       
                }
                
                if(name.equals('ApexClassOrTriggerId'))
                {
                    String val = getElementText(reader);
                                    
                    records.setApexClassOrTriggerId(val);                                        
                }
                
                if(name.equals('ApexTestClassId'))
                {
                    String val = getElementText(reader);
                                    
                    records.setApexTestClassId(val);                                         
                }
                
                if(name.equals('NumLinesCovered'))
                {
                    String val = getElementText(reader);
               
                    Integer covered = Integer.valueOf(val);
                    
                    records.setNumLinesCovered(covered);                               
                }
                
                if(name.equals('NumLinesUncovered'))
                {
                    String val = getElementText(reader);
               
                    integer covered = Integer.valueOf(val);
                    
                    records.setNumLinesUncovered(covered);                               
                }
                
                if(name.equals('coveredLines'))
                {
                    String val = getElementText(reader);
              
                    integer covered = Integer.valueOf(val);
                    
                    records.addCoveredLines(covered);                               
                }
                
                if(name.equals('uncoveredLines'))
                {
                    String val = getElementText(reader);
                
                    integer uncovered = Integer.valueOf(val);
                    
                    records.addUncoveredLines(uncovered);   
                    
                }
                
                if(name.equals('TestMethodName'))
                {
                    String val = getElementText(reader);

                    records.setTestMethodName(val);
                }
                                        
            }
            
            if(reader.getEventType() == XmlTag.END_ELEMENT)
            {
                String name = reader.getLocalName();
                
                if(name.equals('records'))
                {                                               
                    recordList.add(records);
            
                    records = null;                                      
                }              
            }
            
            reader.next();
            
        }
        
        return recordList;  
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