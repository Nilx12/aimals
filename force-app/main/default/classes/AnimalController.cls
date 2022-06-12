public class AnimalController {
    @AuraEnabled(cacheable = true)
    public static List<Account> getAccounts()
    {
        return [SELECT Id, Name FROM Account];
    }
    @AuraEnabled(Cacheable=true)
    public static List<Animal__C>  getAllAnimals(){
        List<Animal__C> animals = [SELECT Id, Name, Breed__c, Age__c,Photo__c,Sex__c,weight__C FROM Animal__C WHERE Status__C = 'Available'];
        animals = reformatSrc(animals);
        return  animals;
    }
    @AuraEnabled(Cacheable=true)
    public static List<Animal__C>  searchAnimals(String searchBreed, Integer searchAge, String searchGender){
        if(searchBreed == '' && searchAge== null && searchGender==''){
            return getAllAnimals();
        }
        List<Animal__C> animals;
        searchBreed = '%'+searchBreed+'%';
        if(searchGender == ''){
            searchGender = '%';
        }
        if(searchAge == null){
            animals = [SELECT Id, Name, Breed__c, Age__c,Photo__c,Sex__c,weight__C
            FROM Animal__C
            WHERE Status__C = 'Available'
            AND Breed__c like :searchBreed
            And Sex__c like :searchGender
            WITH SECURITY_ENFORCED];
        }else{
            animals = [SELECT Id, Name, Breed__c, Age__c,Photo__c,Sex__c,weight__C
            FROM Animal__C
            WHERE Status__C = 'Available'
            AND Breed__c like :searchBreed
            And Sex__c like :searchGender
            AND Age__c = :searchAge
            WITH SECURITY_ENFORCED];
        }


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
}