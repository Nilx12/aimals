/**
 * Created by Kamil on 11.06.2022.
 */

import { LightningElement, api, wire, track } from 'lwc';
import getAllAnimals from '@salesforce/apex/AnimalController.getAllAnimals';

export default class AnimalFinder extends LightningElement {
    //@track animalsList = [];
    animals;
    errors;



    connectedCallback() {
    		this.loadAnimals();
    	}
    	loadAnimals() {
    		getAllAnimals()
    			.then(result => {
    				this.animals = result;
    			})
    			.catch(error => {
    				this.error = error;
    			});
    	}

   /* @wire(searchAnimals, {null})
    wiredAnimals({ error, data }) {
            if (data) {
               for(let key in data) {
                   if (data.hasOwnProperty(key)) {
                        this.oHours.push({value:data[key], key:key});

                   }
               }
            } else if (error) {
                console.log(error)
            }
            //console.log(this.oHours[0]);
        }*/
}