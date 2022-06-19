public class MissingAnimalsFlow {
    public static final INTEGER BREED = 0;
    public static final INTEGER PROBABILITY = 1;
    public static final INTEGER MISSING_ANIMAL_ID = 2;
    
    
    @InvocableMethod(label='Create cases for missing animals')
    public static void getMissingAnimalBase64EncodedBlobs() {
       
        List<Id> animalIds = MissingAnimalsRestCallout.getMissingAnimalsForDayDelta(0);
        
        String modelId = 'GW5SLPSIXYJLC7WSFUYY2C4P3Y';
        einsteinplay.Einstein_PredictionService einstein = new einsteinplay.Einstein_PredictionService(einsteinplay.Einstein_PredictionService.Types.IMAGE);
        List<Case> cases = new List<Case>();
        for (Id id: animalIds) {
            String animalEncodedBlob = MissingAnimalsRestCallout.getMissingAnimalBase64EncodedBlobById(id);
            einsteinplay.Einstein_PredictionResult result = einstein.predictImageBase64(modelId, animalEncodedBlob, 1, id);
            List<String> animalData = result.toString().replaceAll('.*label=(.*?)\\,.*probability=([10]\\.\\d+).*', '$1#$2').split('#');
            //System.debug(animalData.size());
            //System.debug(animalData.get(0));
            if(animalData.size() < 1){
                continue;
            } 
            for(Animal__C animal:[SELECt id,Account__c, Name,Breed__c FROM Animal__C WHERE Status__c='Available' AND Breed__c = :animalData.get(0)]){
                Case case1 = new Case();
                case1.Status = 'New';
                case1.Origin = 'Web';
                case1.Type = 'Missing animal';
                case1.AccountId = animal.account__c;
                case1.Subject = 'Missing animal, potentional match found';
                case1.Description = 'According to AI comparision, Animal from shelter of id: '+animal.Account__c+' from given shelter seems to be potentionaly matching missing animal\n'
                    +'Breed: '+animalData.get(0)+'\n'
                    +'Id of shelter '+animal.Account__c+'\n'
                    +'\t Id of animal in shelter: '+animal.Id+'\n'
                    +'\t Name oF animal: '+animal.name+'\n'
                    +'Missing animal id: '+id;
                cases.add(case1);
            }
            
        }
     insert cases;   
    } 
   
}