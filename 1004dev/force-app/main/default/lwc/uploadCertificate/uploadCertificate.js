import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import Employee_OBJECT from "@salesforce/schema/Employee__c";
import ID_FIELD from "@salesforce/schema/Employee__c.Id";
import CERTIFICATE_FIELD from "@salesforce/schema/Employee__c.Certificate__c";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const fields = [CERTIFICATE_FIELD];
export default class UploadCertificate extends LightningElement {
    @track options;
    @api recordId;
    @api recordObject;
    employeeyRecordTypeId
    picklistValue

    connectedCallback(){
        this.recordObject = JSON.parse(JSON.stringify(this.recordObject));
    }
    @wire(getObjectInfo, { objectApiName: Employee_OBJECT })
    results({ error, data }) {
    if (data) {
      this.employeeyRecordTypeId = data.defaultRecordTypeId;
      this.error = undefined;
      console.log("employeetRecordTypeId##",this.employeeyRecordTypeId);
    } else if (error) {
      this.error = error;
      this.accountRecordTypeId = undefined;
    }
  }

    @wire(getPicklistValues, { recordTypeId: "$employeeyRecordTypeId",fieldApiName: CERTIFICATE_FIELD }) 
    picklistResults({ error, data }) {
        console.log('certificatePicklistResults ',data);
        if (data) {
            this.options = data.values.map(opt => {return {"label": opt.label, "value": opt.value}});
            this.template.querySelector('[role="cm-picklist"]').setOptions(this.options);
            this.template.querySelector('[role="cm-picklist"]').setSelectedList(getFieldValue(this.employee.data, CERTIFICATE_FIELD));
        }
    }
  
    @wire(getRecord, { recordId: "$recordId", fields})
    employee    

    onNavigateToExperiencePage(){
        
        if(this.template.querySelector('[role="cm-picklist"]').isValid()){
           this.picklistValue = this.template.querySelector('[role="cm-picklist"]').getSelectedList();
           console.log("picklistValue####",this.picklistValue);
           this.recordObject['Certificate__c'] = this.picklistValue;
           console.log('Record Object: ', this.recordObject);

           this.dispatchEvent(
            new CustomEvent('experiencepage', {
                detail: {
                    'experiencePage': true,
                    'recordObject': this.recordObject,
                    
                }
            })
        )
        }else{
            this.showErrorToast();
        }

        
    }

    handleCertificateListChange(evnet){

    }

    onBack(){
        this.dispatchEvent(
            new CustomEvent('backtoskillpage', {
                detail: {
                    'skillPage': true,
                }
            })
        )
    }

    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Error',
            message: 'Some unexpected error',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}