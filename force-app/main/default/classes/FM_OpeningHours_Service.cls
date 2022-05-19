public with sharing class FM_OpeningHours_Service {

    public static String getOpenAndCloseHoursString(Time startTime, Time endTime) {
        Datetime startDate = Datetime.newInstance(System.now().date(), startTime);
        Datetime endDate = Datetime.newInstance(System.now().date(), endTime);

        return startDate.format('HH:ss') + ' - ' + endDate.format('HH:ss');
    }
}