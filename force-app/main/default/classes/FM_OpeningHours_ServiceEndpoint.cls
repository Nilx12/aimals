public with sharing class FM_OpeningHours_ServiceEndpoint {

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getOpeningHoursForAccount(Id accountId) {
        Map<String, String> result = new Map<String, String>();
        Opening_Hours__c oh = [SELECT Account__c, Monday_Start_Time__c, Monday_End_Time__c, Tuesday_Start_Time__c, Tuesday_End_Time__c,
                Wednesday_Start_Time__c, Wednesday_End_Time__c, Thursday_Start_Time__c, Thursday_End_Time__c, Friday_Start_Time__c, Friday_End_Time__c FROM Opening_Hours__c WHERE Account__c = :accountId];

        if(oh != null) {
            result = new Map<String, String>();
            result.put('Monday', FM_OpeningHours_Service.getOpenAndCloseHoursString(oh.Monday_Start_Time__c, oh.Monday_End_Time__c));
            result.put('Tuesday', FM_OpeningHours_Service.getOpenAndCloseHoursString(oh.Tuesday_Start_Time__c, oh.Tuesday_End_Time__c));
            result.put('Wednesday', FM_OpeningHours_Service.getOpenAndCloseHoursString(oh.Wednesday_Start_Time__c, oh.Wednesday_End_Time__c));
            result.put('Thursday', FM_OpeningHours_Service.getOpenAndCloseHoursString(oh.Thursday_Start_Time__c, oh.Thursday_End_Time__c));
            result.put('Friday', FM_OpeningHours_Service.getOpenAndCloseHoursString(oh.Friday_Start_Time__c, oh.Friday_End_Time__c));
        }

        return result;
    }


}