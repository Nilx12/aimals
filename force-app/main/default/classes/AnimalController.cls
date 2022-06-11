public class AnimalController {
    @AuraEnabled(Cacheable=true)
    public static List<Animal__C>  getAllAnimals(){
        List<Animal__C> animals = [SELECT Id, Name, Breed__c, Age__c,Photo__c,Sex__c,weight__C FROM Animal__C WHERE Status__C = 'Available'];
        for (Animal__C r : animals){
            if(r.Photo__c != null){
                String firstSubString = r.Photo__c.substringBetween('<img', 'img>');
                String secondSubString = firstSubString.substringBetween('src="', '"');
                String s = secondSubString.replace('amp;', '');
                r.Photo__c = s;
            }
        }
        return  animals;
    }
}