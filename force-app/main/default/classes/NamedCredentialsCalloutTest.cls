public class NamedCredentialsCalloutTest {
    public static void testConnection() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Missing_Animals_Cred?dayDelta=7');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
}