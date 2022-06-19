/**
 * Created by Kamil on 11.06.2022.
 */
import { LightningElement, api, wire, track } from 'lwc';
import searchAnimals from '@salesforce/apex/AnimalController.searchAnimals';
import getAccounts from '@salesforce/apex/AnimalController.getAccounts';
import getByImage from '@salesforce/apex/AnimalController.getByImage';
import setContent from '@salesforce/apex/AnimalController.setContent';

export default class AnimalFinder extends LightningElement {
    @api myRecordId;
    documentId = '';
    searchShelter = ' ';
    searchBreed = '';
    searchAge = null;
    searchGender = '';
    imagesearch = '';

    @wire(getAccounts) accounts;
    accounts;

    @wire(searchAnimals,{searchBreed: '$searchBreed',searchAge: '$searchAge',searchGender: '$searchGender',searchShelter:'$searchShelter',imageSearch:'$imagesearch'}) animals;
    animals;


    handleSearchBreedChange(event) {
            window.clearTimeout(this.delayTimeout);
            const searchBreed = event.target.value;
            this.delayTimeout = setTimeout(() => {
            	this.searchBreed = searchBreed;
            }, 300);
        }
    handleSearchAgeChange(event) {
           window.clearTimeout(this.delayTimeout);
           const searchAge = parseInt(event.target.value);
           this.delayTimeout = setTimeout(() => {
                this.searchAge = searchAge;
                if(this.searchAge==NaN){
                    this.searchAge=null;
                }
           }, 300);
        }
    handleSearchGenderChange(event) {
          window.clearTimeout(this.delayTimeout);
          const searchGender = event.detail.value;
          this.delayTimeout = setTimeout(() => {
                this.searchGender = searchGender;
          }, 300);
       }
    handleSearchShelterChange(event) {
        window.clearTimeout(this.delayTimeout);
        console.log(event.detail.value);
        const searchShelter = event.detail.value;
        this.delayTimeout = setTimeout(() => {
            this.searchShelter = searchShelter;
        }, 300);
    }


    get hasResults() {
    		return (this.animals.data.length > 0);
    	}
    get genders() {
            return [
                { label: 'All', value: '%' },
                { label: 'Male', value: 'Male' },
                { label: 'Female', value: 'Female' },
            ];
        }
    get shelters(){
        var dict = [];
        dict.push({
            label:   "All",
            value: ""
        });
        for(var i=0;i<this.accounts.data.length;i++){
            dict.push({
                label:   this.accounts.data[i].Name,
                value: this.accounts.data[i].Id
            });
        }
        return dict;
    }
    get acceptedFormats() {
            return ['.jpeg','.jpg', '.png'];
        }

    handleUploadFinished(event) {
            // Get the list of uploaded files
            const uploadedFiles = event.detail.files;

            console.log(uploadedFiles[0].documentId);

            const searchImage = uploadedFiles[0].documentId;


            setContent({documentId:searchImage}).then(()=>{
                this.imagesearch = searchImage;
        }).catch(error=>{
            console.log(error);
        })



        }

}