import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import Employee_OBJECT from "@salesforce/schema/Employee__c";
import getCertificateList from '@salesforce/apex/ProfileBuilderController.getCertificateList';
import updateEmployeeRecord from '@salesforce/apex/ProfileBuilderController.updateEmployeeRecord';
import CERTIFICATE_FIELD from "@salesforce/schema/Employee__c.Certificate__c";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const fields = [CERTIFICATE_FIELD];
export default class UploadCertificate extends LightningElement {
    @track options = [];
    @api optionsFromParent = [];
    @api recordId;
    @api recordObject;
    @track optionsFromEmployee;
    employeeyRecordTypeId
    picklistValue
    spinner = true;


    connectedCallback() {
        this.recordObject = JSON.parse(JSON.stringify(this.recordObject));
         this.getCertificateListFromEmployee();
        //console.log('Record Object > UploadCertificate >> ', this.recordObject);
    }

    renderedCallback() {
       
    }

    @wire(getObjectInfo, { objectApiName: Employee_OBJECT })
    results({ error, data }) {
        if (data) {
            this.employeeyRecordTypeId = data.defaultRecordTypeId;
            this.error = undefined;
            //console.log("employeetRecordTypeId##", this.employeeyRecordTypeId);
        } else if (error) {
            this.error = error;
            this.accountRecordTypeId = undefined;
        }
    }
  getCertificateListFromEmployee() {
        getCertificateList({ id: JSON.parse(JSON.stringify(this.recordObject['Id'])) })
            .then(result => {
                //console.log('CertificateList', result);
                if(result != null){
                   this.optionsFromEmployee = result;
                   this.spinner = false
                }else if(result == null){
                    this.optionsFromEmployee = '';
                     this.spinner = false
                }
                    this.template.querySelector('[role="cm-picklist"]').setSelectedList( this.optionsFromEmployee);
                
                
                
            });
    }

    @wire(getPicklistValues, { recordTypeId: "$employeeyRecordTypeId", fieldApiName: CERTIFICATE_FIELD })
    picklistResults({ error, data }) {
        //console.log('certificatePicklistResults ', data);
        if (data) {
            this.options = data.values.map(opt => { return { "label": opt.label, "value": opt.value } });
            //console.log('Options@@@@@@@@@@', this.options);
            this.template.querySelector('[role="cm-picklist"]').setOptions(this.options);
            if (this.recordObject.hasOwnProperty('Certificate__c')) {
                this.template.querySelector('[role="cm-picklist"]').setSelectedList(JSON.parse(JSON.stringify(this.recordObject))['Certificate__c']);
            } else {
                //console.log("no certififcate has been selected ::");
            }
        }
    }

    @wire(getRecord, { recordId: "$recordId", fields })
    employee

    //Get Certificate List of Selected Employee
  

    onNavigateToExperiencePage() {
        if (this.template.querySelector('[role="cm-picklist"]').isValid()) {
            this.picklistValue = this.template.querySelector('[role="cm-picklist"]').getSelectedList();
            //console.log("picklistValue####",this.picklistValue);
            this.recordObject['Certificate__c'] = this.picklistValue;
        } else {
            this.recordObject['Certificate__c'] = null;
        }
        //console.log('Record Object: ', this.recordObject);
        //Update Record Of Employee onClick Of Save&Next Button
        updateEmployeeRecord({ wrapperText: JSON.stringify(this.recordObject) });

        //Event disoatch for profileHeader(parent component)
        this.dispatchEvent(
            new CustomEvent('experiencepage', {
                detail: {
                    'experiencePage': true,
                    'recordObject': this.recordObject,
                }
            })
        )
    }

    onBack() {
        if (this.template.querySelector('[role="cm-picklist"]').isValid()) {
            this.picklistValue = this.template.querySelector('[role="cm-picklist"]').getSelectedList();
            //console.log("picklistValue####", this.picklistValue);
            this.recordObject['Certificate__c'] = this.picklistValue;
            //console.log('Record Object: ', this.recordObject);
        } else {
            //console.log("No value Selected");
        }
        this.dispatchEvent(
            new CustomEvent('backtoskillpage', {
                detail: {
                    'skillPage': true,
                   
                    'certificateOptions': this.options
                }
            })
        )
    }

    //Validation Toast
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