import { LightningElement, api, wire, track } from 'lwc';
import getHelpText from '@salesforce/apex/ProfileBuilderController.getHelpTextSummary';
import updateEmployeeRecord from '@salesforce/apex/ProfileBuilderController.updateEmployeeRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProfessionalSummary from '@salesforce/apex/ProfileBuilderController.getProfessionalSummary';

export default class ProfessionalSummary extends LightningElement {
    @track richTextValue = ''
    @track helpTexts;
    @track error;
    @api recordObject;
    searchKey = '';
    delayTimeout
    selectedValue
    spinner = true;
    buttonEnable = true
    buttonDisable = false

    connectedCallback() {
        this.recordObject = JSON.parse(JSON.stringify(this.recordObject));
        this.getSummaryOfEmployee();
    }

    //get pre-define summary helpText using apex
    @wire(getHelpText, { inputStr: '$searchKey' })
    wiredHelpTexts({ data, error }) {
        if (data) {
            this.helpTexts = data;
            //console.log("helptText####",this.helpTexts)
            this.error = undefined;
            this.spinner = false
        } else {
            this.helpTexts = undefined;
            this.error = error;
        }
    }

    //get stored summary of selected employee
    getSummaryOfEmployee() {
        getProfessionalSummary({ id: JSON.parse(JSON.stringify(this.recordObject['Id'])) })
            .then(result => {
                //console.log('Summary', result);
                this.richTextValue = result;
            });
    }

    handleRichTextValue(event) {
        this.richTextValue = event.target.value;
        this.buttonDisable = false;
        this.buttonEnable = true
        //console.log('this.myVal--->', this.richTextValue);
    }

    //update rich-text value onClick of pre-define helpText arrow icon
    onValueGoToRichTextArea(event) {
        var index = parseInt(event.currentTarget.dataset.id);
        // console.log("index$$",index);
        this.selectedValue = this.helpTexts[index]['Instructions__c'];
        // console.log("selectedValue$$",this.selectedValue);
        this.richTextValue += '<ul>' + '<li>' + this.selectedValue + '</li>' + '</ul>';
        this.buttonDisable = false;
        this.buttonEnable = true
    }
    //Set the search key for helpText for Aex method
    handleKeyChange(event) {
        const searchKey = event.target.value.trim();
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey == '' ? this.searchKey = ' ' : searchKey;
        }, '200');
    }

    //onclick of Save&Next button fire event for ProfileHeader(Parent Component)
    onSaveAndNext() {
        this.recordObject['Professional_Summary__c'] = this.richTextValue;
        //console.log('Record Object: ', this.recordObject);
        if (this.richTextValue == '' || this.richTextValue == null) {
            this.showErrorToast();
        } else {
            updateEmployeeRecord({ wrapperText: JSON.stringify(this.recordObject) })
            this.buttonDisable = true
            this.buttonEnable = false
            this.showSuccessToast();
        }
    }

    //onclick of Back button fire event for ProfileHeader(Parent Component)
    onBack() {
        this.dispatchEvent(
            new CustomEvent('backtoexperiencepage', {
                detail: {
                    'experiencePage': true,
                }
            })
        )
    }
    //Error Toasts
    showErrorToast() {
        const evt = new ShowToastEvent({
            message: 'Please Enter Details',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    showSuccessToast() {
        const evt = new ShowToastEvent({
            message: 'Profile Update Successfully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}