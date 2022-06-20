import {LightningElement, track} from 'lwc';
import getMissingAnimalsForDayDelta from '@salesforce/apex/MissingAnimalsRestCallout.getMissingAnimalsForDayDelta';
import getMissingAnimalBase64EncodedBlobById from '@salesforce/apex/MissingAnimalsRestCallout.getMissingAnimalBase64EncodedBlobById';

export default class MissingAnimalsComponent extends LightningElement {
    dayDelta = 0;
    @track missingAnimalsImages = [];
    error = false;
    spinner = false;
    errorMessage = "";

    handleSearchClick(event) {
        if (!this.dayDelta || this.dayDelta < 0) {
            this.error = true;
            this.errorMessage = "Please input number greater or equal zero";
            this.dayDelta = 0;
            return;
        }
        this.spinner = true;
        this.error = false;

        getMissingAnimalsForDayDelta({
            delta: this.dayDelta
        })
        .then(missingAnimalsIds => {
            this.missingAnimalsImages = []
            missingAnimalsIds.forEach((animalId) => this.getAnimalImage(animalId));
            if (this.error === true) {
                return;
            }
            this.spinner = false;
            this.error = false;
        })
        .catch(error => {
            console.log(error);
            this.error = true;
            this.errorMessage = "Couldn't retrieve images, sorry for the inconvenience";
            this.spinner = false;
        });
    }

    handleDayDeltaChange(event) {
        this.dayDelta = event.target.value;
    }

    getAnimalImage(id) {
        getMissingAnimalBase64EncodedBlobById({
            animalId: id
        })
        .then(missingAnimalBase64EncodedBlob => {
            this.missingAnimalsImages.push({key: id, value:'data:/image/jpeg;base64,' + missingAnimalBase64EncodedBlob});

        })
        .catch(error => {
            this.missingAnimalsImages = []
            this.error = true;
            this.errorMessage = "Couldn't retrieve images, sorry for the inconvenience";
        });
    }
}