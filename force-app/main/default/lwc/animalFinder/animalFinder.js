/**
 * Created by Kamil on 11.06.2022.
 */

import { LightningElement, api, wire, track } from 'lwc';
import searchAnimals from '@salesforce/apex/AnimalController.searchAnimals';
import getAccounts from '@salesforce/apex/AnimalController.getAccounts';


export default class AnimalFinder extends LightningElement {
    searchShelter = '';
    searchBreed = '';
    searchAge = null;
    searchGender = '';


    @wire(getAccounts) accounts;
    accounts;

    @wire(searchAnimals,{searchBreed: '$searchBreed',searchAge: '$searchAge',searchGender: '$searchGender'}) animals;
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
        console.log("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
        console.log(this.accounts);
        console.log(this.accounts.data);
        console.log(this.accounts.data[0].Id);

        var dict = [];
        for(var i=0;i<this.accounts.data.length;i++){
            dict.push({
                label:   this.accounts.data[i].Name,
                value: this.accounts.data[i].Id
            });
        }
        return dict;
    }
}