import { LightningElement,track,api,wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import getEmployeeNames from '@salesforce/apex/ProfileBuilderController.getEmployeeNames';
import getSkillList from '@salesforce/apex/ProfileBuilderController.getSkillList';
import updateEmployeeRecord from '@salesforce/apex/ProfileBuilderController.updateEmployeeRecord';
import Employee_OBJECT from "@salesforce/schema/Employee__c";
import Skill_FIELD from "@salesforce/schema/Employee__c.Skills__c";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const fields = [Skill_FIELD];

export default class EmployeeSkillPage extends LightningElement {
    @track options;
    @api recordId;
    @api recordObject = {};
    @track employeeOptions = [];
    @track value;
    spinner = false;
    searchResults;
    selectedSearchResult;
    selectedEmployeeId;
   

    
    connectedCallback() {
        this.recordObject = JSON.parse(JSON.stringify(this.recordObject));
        const style = document.createElement('style');
        style.innerText = `
                        lightning-progress-bar .slds-progress-bar__value {
                            background-color: green;
                        }
                        lightning-combobox .slds-form-element__label {
                            color: #07334A;
                        }
                        .slds-dropdown_length-5, .slds-dropdown--length-5 {
                            width: 29.5%;    
                        }
                        .slds-dropdown {
                            position: absolute;
                            left: 35.3%;
                            border-radius: 9px;
                        }
                       
                    `;
        setTimeout(() => {
            this.template.querySelector('.overrideStyle').appendChild(style);
        }, 200);

        this.getEmployeeDetails();


    }

    renderedCallback() {
        try {
            var childPicklistCMP = this.template.querySelector('[role="cm-picklist"]');
            if (childPicklistCMP) {
                this.template.querySelector('[role="cm-picklist"]').setOptions(this.options);
                this.template.querySelector('[role="cm-picklist"]').setSelectedList(JSON.parse(JSON.stringify(this.recordObject))['Skills__c']);
            }
        } catch (error) {
            //console.log('Error: ', error);
        }

        //For Progress Stage Background Color
        
        this.getSkillsListFromEmployee();
    }

     get selectedValue() {
        return this.selectedSearchResult ? this.selectedSearchResult.label : null;
    }

     search(event) {
        const input = event.detail.value.toLowerCase();
        const result = this.employeeOptions.filter((picklistOption) =>
            picklistOption.label.toLowerCase().includes(input)
        );
        console.log('employeeoptionssss--->', this.employeeOptions);
        this.searchResults = result;
        console.log('this.searchResults--->', this.searchResults);
    }

     selectSearchResult(event) {
        const selectedValue = event.currentTarget.dataset.value;
        this.selectedEmployeeId = selectedValue;
        console.log('selectedValue---->', selectedValue);
        //console.log('employeeyRecordTypeId',employeeyRecordTypeId);
        this.selectedSearchResult = this.employeeOptions.find(
            (employeeOptions) => employeeOptions.value === selectedValue
        );
        console.log('this.employeeOptions selectSearchResult-->', this.selectedEmployeeId);
        this.recordObject['Id'] = this.selectedEmployeeId;
        this.clearSearchResults();
    }

     clearSearchResults() {
        this.searchResults = null;
        this.spinner = true
    }

     showPicklistOptions() {
        if (!this.searchResults) {
            this.searchResults = this.employeeOptions;
            console.log('this.searchResults---showPicklistOptions-->', this.searchResults);
        }
    }
     getEmployeeDetails() {
        getEmployeeNames()
            .then(result => {
                //console.log('@result ', result);

                this.employeeOptions = result.map(employee => ({ label: employee.Name, value: employee.Id }));
                //console.log('this.employeeOptions-->',this.employeeOptions);
                this.spinner = false
            })
            .catch(error => {
                console.error('Error fetching Timesheet data:', error);
            });
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

     @wire(getPicklistValues, { recordTypeId: "$employeeyRecordTypeId", fieldApiName: Skill_FIELD })
    picklistResults({ error, data }) {
        //console.log('picklistResults ', data);
        if (data) {
            this.options = data.values.map(opt => { return { "label": opt.label, "value": opt.value } });
            this.template.querySelector('[role="cm-picklist"]').setOptions(this.options);
            //this.template.querySelector('[role="cm-picklist"]').setSelectedList(getFieldValue(this.employees.data, Skill_FIELD));

        }
    }

    @wire(getRecord, { recordId: "$recordId", fields })
    employees

    getSkillsListFromEmployee() {
        getSkillList({ id:this.recordObject['Id'] })
            .then(result => {
                this.skillListFromObject = result;
                //console.log('SkillsList', result);
                if (result == null) {
                    console.log("Skill list Null");
                } else {
                    this.template.querySelector('[role="cm-picklist"]').setSelectedList(result);
                     this.spinner = false;
                }
                
            })
            .catch(error => {
                console.error('Error fetching Skills data:');
            });
    }

    onNavigateToCertificatePage(){

         this.dispatchEvent(
            new CustomEvent('certificatepage', {
                detail: {
                    'certificatePage': true,
                    'recordObject': this.recordObject,
                }
            })
        )

    }


}