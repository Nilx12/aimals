import {LightningElement, api, wire} from 'lwc';

import ACCOUNT_NAME from '@salesforce/schema/Account.Name'
import ACCOUNT_SHIPPING_CITY from '@salesforce/schema/Account.ShippingCity'
import ACCOUNT_SHIPPING_COUNTRY from '@salesforce/schema/Account.ShippingCountry'
import ACCOUNT_SHIPPING_POSTAL_CODE from '@salesforce/schema/Account.ShippingPostalCode'
import ACCOUNT_SHIPPING_STATE from '@salesforce/schema/Account.ShippingState'
import ACCOUNT_SHIPPING_STREET from '@salesforce/schema/Account.ShippingStreet'

import {getRecord} from "lightning/uiRecordApi";

export default class AccountMap extends LightningElement {
    @api recordId;
    account;
    error;
    mapMarkers;
    mapOptions;
    successfullyFetchedLocation = false;
    zoomLevel = 15;


    @wire(getRecord, { recordId: '$recordId',
        fields: [ACCOUNT_NAME,
            ACCOUNT_SHIPPING_CITY,
            ACCOUNT_SHIPPING_COUNTRY,
            ACCOUNT_SHIPPING_POSTAL_CODE,
            ACCOUNT_SHIPPING_STATE,
            ACCOUNT_SHIPPING_STREET] }
    )
    wiredAccount({data, error}) {
        if (data) {
            this.account = data;
            this.error = undefined;
            this.successfullyFetchedLocation = true
            this.setMapMarkers()
            this.setMapOptions()
        } else if (error) {
            this.error = error;
            this.account = undefined;
            this.successfullyFetchedLocation = false
        }
    }

    setMapOptions() {
        this.mapOptions = {
            draggable: false,
            disableDefaultUI: true,
        };
    }

    setMapMarkers() {
        this.mapMarkers = [
            {
                location: {
                    City: this.account.fields.ShippingCity.value,
                    Country: this.account.fields.ShippingCountry.value,
                    PostalCode: this.account.fields.ShippingPostalCode.value,
                    State: this.account.fields.ShippingState.value,
                    Street: this.account.fields.ShippingStreet.value,
                },
                title: this.account.fields.Name.value,
                icon: 'standard:account',
            },
        ];
    }
}