import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord  } from 'lightning/uiRecordApi';
import CONTACT_OBJECT from '@salesforce/schema/Account'
import NAME_FIELD from '@salesforce/schema/Account.Name'
import ACCOUNT_FIELD from '@salesforce/schema/Contact.AccountId'    
export default class AddressLookup extends LightningElement {
    // @api recordId;
    // selectedCountry = 'IN';
      objectName = CONTACT_OBJECT
    @api recordId;
    fields={
        nameField:NAME_FIELD
    }

    handleReset(){
        const inputFields = this.template.querySelectorAll('lightning-input-field')
        if(inputFields){
            Array.from(inputFields).forEach(field=>{
                field.reset()
            })
        }
    }

    // city;
    // country;
    // province;
    // postalCode;

    // handleChange(event) {
    //     // Handle changes in form fields if needed
    // }
    // handleAddress(event){
  

    // console.log('All details ' , event.target.details);
    // console.log('Street is ' , event.target.street);
    // console.log('City is ' , event.target.city);
    // console.log('Province is ' , event.target.province);
    // console.log('Country is ' , event.target.country);
    // console.log('postal Code is ' , event.target.postalCode);

   
    // }
    // handleSubmit(event) {
    //     event.preventDefault();

    //     // Extract address details
    //     const fields = event.detail.fields;
    //     fields.City = this.city;
    //     fields.Country = this.country;
    //     fields.Province = this.province;
    //     fields.PostalCode = this.postalCode;
    //     console.log('fiels city',this.city);
    //     console.log('fiels coiuntry',this.country);
    //     console.log('fiels proviancee',this.province);
    //     console.log('fiels postalcode',this.postalCode);

    //     // Save the record  
    //     this.template.querySelector('lightning-record-edit-form').submit(fields);
    // }.
    
    validateAddress() {
        if (!this.country && !this.city) {
            // Validation failed
            // You can display an error message or perform any other action here
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'Country and city is blank!', 
                variant : 'Error'         
            });
            this.dispatchEvent(event);
        } else {
            // Validation passed
            // Perform further actions or submit the form
            console.log('Validation passed. Submitting form...');
        }
    }


    countryStateMap = {
        IN: [
            { label: 'Andhra Pradesh', value: 'AP' },
            { label: 'Arunachal Pradesh', value: 'AR' },
            { label: 'Assam', value: 'AS' },
            { label: 'Bihar', value: 'BR' },
            { label: 'Chhattisgarh', value: 'CG' },
            { label: 'Goa', value: 'GA' },
            { label: 'Gujarat', value: 'GJ' },
            { label: 'Haryana', value: 'HR' },
            { label: 'Himachal Pradesh', value: 'HP' },
            { label: 'Jharkhand', value: 'JH' },
            { label: 'Karnataka', value: 'KA' },
            { label: 'Kerala', value: 'KL' },
            { label: 'Madhya Pradesh', value: 'MP' },
            { label: 'Maharashtra', value: 'MH' },
            { label: 'Manipur', value: 'MN' },
            { label: 'Meghalaya', value: 'ML' },
            { label: 'Mizoram', value: 'MZ' },
            { label: 'Nagaland', value: 'NL' },
            { label: 'Odisha', value: 'OR' },
            { label: 'Punjab', value: 'PB' },
            { label: 'Rajasthan', value: 'RJ' },
            { label: 'Sikkim', value: 'SK' },
            { label: 'Tamil Nadu', value: 'TN' },
            { label: 'Telangana', value: 'TG' },
            { label: 'Tripura', value: 'TR' },
            { label: 'Uttar Pradesh', value: 'UP' },
            { label: 'Uttarakhand', value: 'UK' },
            { label: 'West Bengal', value: 'WB' },
            { label: 'Jammu and Kashmir', value: 'JK' }
        ],

        US: [
            { label: 'Alabama', value: 'AL' },
            { label: 'Alaska', value: 'AK' },
            { label: 'Arizona', value: 'AZ' },
            { label: 'Arkansas', value: 'AR' },
            { label: 'California', value: 'CA' },
            { label: 'Colorado', value: 'CO' },
            { label: 'Connecticut', value: 'CT' },
            { label: 'Delaware', value: 'DE' },
            { label: 'Florida', value: 'FL' },
            { label: 'Georgia', value: 'GA' },
            { label: 'Hawaii', value: 'HI' },
            { label: 'Idaho', value: 'ID' },
            { label: 'Illinois', value: 'IL' },
            { label: 'Indiana', value: 'IN' },
            { label: 'Iowa', value: 'IA' },
            { label: 'Kansas', value: 'KS' },
            { label: 'Kentucky', value: 'KY' },
            { label: 'Louisiana', value: 'LA' },
            { label: 'Maine', value: 'ME' },
            { label: 'Maryland', value: 'MD' },
            { label: 'Massachusetts', value: 'MA' },
            { label: 'Michigan', value: 'MI' },
            { label: 'Minnesota', value: 'MN' },
            { label: 'Mississippi', value: 'MS' },
            { label: 'Missouri', value: 'MO' },
            { label: 'Montana', value: 'MT' },
            { label: 'Nebraska', value: 'NE' },
            { label: 'Nevada', value: 'NV' },
            { label: 'New Hampshire', value: 'NH' },
            { label: 'New Jersey', value: 'NJ' },
            { label: 'New Mexico', value: 'NM' },
            { label: 'New York', value: 'NY' },
            { label: 'North Carolina', value: 'NC' },
            { label: 'North Dakota', value: 'ND' },
            { label: 'Ohio', value: 'OH' },
            { label: 'Oklahoma', value: 'OK' },
            { label: 'Oregon', value: 'OR' },
            { label: 'Pennsylvania', value: 'PA' },
            { label: 'Rhode Island', value: 'RI' },
            { label: 'South Carolina', value: 'SC' },
            { label: 'South Dakota', value: 'SD' },
            { label: 'Tennessee', value: 'TN' },
            { label: 'Texas', value: 'TX' },
            { label: 'Utah', value: 'UT' },
            { label: 'Vermont', value: 'VT' },
            { label: 'Virginia', value: 'VA' },
            { label: 'Washington', value: 'WA' },
            { label: 'West Virginia', value: 'WV' },
            { label: 'Wisconsin', value: 'WI' },
            { label: 'Wyoming', value: 'WY' },
            { label: 'Puerto Rico', value: 'PR' }
        ]
    }

    countryOptions = [
        { label: 'India', value: 'IN' },
        { label: 'United States', value: 'US' }
    ];

    handleAddressChange(event) {
        console.log('handleAddressChange: event:: ', event)
        this.selectedCountry = event.detail.country;
    }

    get stateOptions() {
        return this.countryStateMap[this.selectedCountry];
    }

    get countryOptions() {
        return this.countryOptions;
    }
}