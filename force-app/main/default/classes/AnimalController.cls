public class AnimalController {
    @AuraEnabled(Cacheable=true)
    public static List<Animal__C>  getAllAnimals(){
        List<Animal__C> animals = [SELECT Id, Name, Breed__c, Age__c,Photo__c,Sex__c,weight__C,Account__c  FROM Animal__C WHERE Status__C = 'Available'];
        animals = reformatSrc(animals);
        return  animals;
    }

    @AuraEnabled
    public static void setContent(String documentId){
        ContentVersion cv = [select id from contentversion where contentdocumentid =:documentId];
        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'Test';
        cd.ContentVersionId = cv.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        insert cd;
    }
    
    @AuraEnabled(Cacheable=true)
    public static String getByImage(String documentId){
        String modelId = 'GW5SLPSIXYJLC7WSFUYY2C4P3Y';
        String url = [SELECT ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId =:documentId Limit 1].ContentDownloadUrl;
        einsteinplay.Einstein_PredictionService einstein = new einsteinplay.Einstein_PredictionService(einsteinplay.Einstein_PredictionService.Types.IMAGE);
        einsteinplay.Einstein_PredictionResult result = einstein.predictImageUrl(modelId, url, 1, '12');
        
        return result.toString().replaceAll('.*label=(.*?)\\,.*probability=([10]\\.\\d+).*', '$1#$2').split('#').get(0);

    }

    @AuraEnabled(Cacheable=true)
    public static List<Animal__C>  searchAnimals(String searchBreed, Integer searchAge, String searchGender, String searchShelter, String imageSearch){
        if(searchBreed == '' && searchAge== null && searchGender=='' && (searchShelter == '' || searchShelter == ' ') && imageSearch == ''){
            return getAllAnimals();
        }
        List<Animal__C> animals;
        searchBreed = '%'+searchBreed+'%';
        if(searchGender == ''){
            searchGender = '%';
        }
        if(imageSearch != ''){
            searchBreed = getByImage(imageSearch);
        }
        
        String sql = 'SELECT Id, Name, Breed__c, Age__c,Photo__c,Sex__c,weight__C,Account__c FROM Animal__C '
                                	+'WHERE Status__C = \'Available\' '
            						+'AND Breed__c like :searchBreed '
            						+'AND Sex__c like :searchGender ';
        if(searchShelter != '' && searchShelter != ' '){
            sql = sql + 'AND Account__c = :searchShelter ';
        }
        if(searchAge != null){
            sql = sql + 'AND Age__c = :searchAge ';
        }
            
        animals = Database.query(sql);
        
        animals = reformatSrc(animals);
        return  animals;
    }

    
    private static List<Animal__C> reformatSrc(List<Animal__C> animals){
         for (Animal__C r : animals){
            if(r.Photo__c != null){
                String firstSubString = r.Photo__c.substringBetween('<img', 'img>');
                String secondSubString = firstSubString.substringBetween('src="', '"');
                String s = secondSubString.replace('amp;', '');
                r.Photo__c = s;
            }else{
                r.Photo__c = '';
            }
        }
        return  animals;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Account> getAccounts()
    {
            return [SELECT Id, Name FROM Account];
    }


}