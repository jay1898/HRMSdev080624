import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import Employee_OBJECT from "@salesforce/schema/Employee__c";
import ID_FIELD from "@salesforce/schema/Employee__c.Id";
import CERTIFICATE_FIELD from "@salesforce/schema/Employee__c.Certificate__c";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const fields = [CERTIFICATE_FIELD];
export default class UploadCertificate extends LightningElement {
    @track options = [];
    @api optionsFromParent = [];
    @api recordId;
    @api recordObject;
    employeeyRecordTypeId
    picklistValue

    connectedCallback() {
        this.recordObject = JSON.parse(JSON.stringify(this.recordObject));
        console.log('Record Object > UploadCertificate >> ', this.recordObject);
    }
    // renderedCallback(){
    //     console.log('Inside Render Callback > UploadCertificate:: ', this.template.querySelector('[role="cm-picklist"]').getSelectedList());

    //     if(this.options.length == 0){
    //         this.options = this.optionsFromParent;
    //         console.log('Options assigned with parent values');
    //     }

    //   try {
    //         var childPicklistCMP = this.template.querySelector('[role="cm-picklist"]');
    //         if (childPicklistCMP){
    //             this.template.querySelector('[role="cm-picklist"]').setOptions(this.options);
    //             this.template.querySelector('[role="cm-picklist"]').setSelectedList(JSON.parse(JSON.stringify(this.recordObject))['Certificate__c']);
    //         }
    //     } catch (error) {
    //         //console.log('Error: ', error);
    //     }
    // }

    @wire(getObjectInfo, { objectApiName: Employee_OBJECT })
    results({ error, data }) {
        if (data) {
            this.employeeyRecordTypeId = data.defaultRecordTypeId;
            this.error = undefined;
            console.log("employeetRecordTypeId##", this.employeeyRecordTypeId);
        } else if (error) {
            this.error = error;
            this.accountRecordTypeId = undefined;
        }
    }
    @wire(getPicklistValues, { recordTypeId: "$employeeyRecordTypeId", fieldApiName: CERTIFICATE_FIELD })
    picklistResults({ error, data }) {
        console.log('certificatePicklistResults ', data);
        if (data) {
            this.options = data.values.map(opt => { return { "label": opt.label, "value": opt.value } });
            console.log('Options@@@@@@@@@@', this.options);
            this.template.querySelector('[role="cm-picklist"]').setOptions(this.options);

            if (this.recordObject.hasOwnProperty('Certificate__c')) {
                this.template.querySelector('[role="cm-picklist"]').setSelectedList(JSON.parse(JSON.stringify(this.recordObject))['Certificate__c']);
            } else {
                console.log("no certififcate has been selected ::");
            }
        }
    }

    @wire(getRecord, { recordId: "$recordId", fields })
    employee

    onNavigateToExperiencePage() {
        if (this.template.querySelector('[role="cm-picklist"]').isValid()) {
            this.picklistValue = this.template.querySelector('[role="cm-picklist"]').getSelectedList();
            //console.log("picklistValue####",this.picklistValue);
            this.recordObject['Certificate__c'] = this.picklistValue;
            this.dispatchEvent(
            new CustomEvent('experiencepage', {
                detail: {
                    'experiencePage': true,
                    'recordObject': this.recordObject,
                    'certificateOptions': this.options

                }
            })
        )
            //console.log('Record Object: ', this.recordObject);
        } else {
            this.showErrorToast();
        }
        

    }

    onBack() {
        if (this.template.querySelector('[role="cm-picklist"]').isValid()) {
            this.picklistValue = this.template.querySelector('[role="cm-picklist"]').getSelectedList();
            //console.log("picklistValue####",this.picklistValue);
            this.recordObject['Certificate__c'] = this.picklistValue;
            //console.log('Record Object: ', this.recordObject);
        } else {
            console.log("No value Selected");
        }
        this.dispatchEvent(
            new CustomEvent('backtoskillpage', {
                detail: {
                    'skillPage': true,
                    'recordObject': this.recordObject,
                    'certificateOptions': this.options
                }
            })
        )
    }

    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Error',
            message: 'Please Enter Details',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}