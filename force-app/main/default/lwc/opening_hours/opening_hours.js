import { LightningElement, api, wire, track } from 'lwc';
import getOpeningHoursForAccount from '@salesforce/apex/FM_OpeningHours_ServiceEndpoint.getOpeningHoursForAccount';

export default class OpeningHours extends LightningElement {
    @track oHours = [];
    @api recordId;
    @track changeStyle = false;
    @track num = 0;


    @wire(getOpeningHoursForAccount, {accountId: '$recordId'})
    wiredHours({ error, data }) {
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
        }
    get className(){
          //if changeStle is true, getter will return class1 else class2
          const d = new Date();
          let day = d.getDay();
          this.num++;
                    if(this.num==day){
                        this.changeStyle = true;
                    }
                    else{
                        this.changeStyle = false;
                    }
          return this.changeStyle ? 'class1': 'class2';
        }

}