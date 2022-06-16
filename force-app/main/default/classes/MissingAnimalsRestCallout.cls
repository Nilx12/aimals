public with sharing class MissingAnimalsRestCallout {

    private static final String callout = 'callout:Missing_Animals_Cred';

    @AuraEnabled(cacheable=true)
    public static List<Id> getMissingAnimalsForDayDelta(Integer delta) {
        if (delta < 0) {
            return null;
        }
        if (delta == null) {
            delta = 0;
        }

        HttpRequest request = new HttpRequest();
        request.setEndpoint(callout + '?dayDelta=' + delta);
        request.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(request);
        List<Id> missingAnimalsIdsList = response
                .getBody()
                .replaceAll('\\[?\\"\\]?','')
                .split('\\,');

        return missingAnimalsIdsList;
    }

    @AuraEnabled(cacheable=true)
    public static String getMissingAnimalBase64EncodedBlobById(Id animalId) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(callout + '/' + animalId);
        request.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(request);

        return EncodingUtil.base64Encode(response.getBodyAsBlob());
    }
}