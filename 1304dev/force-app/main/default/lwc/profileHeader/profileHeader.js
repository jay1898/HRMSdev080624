import { LightningElement, api, wire, track } from 'lwc';
import IMAGES from "@salesforce/resourceUrl/iTechlogo";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import getEmployeeNames from '@salesforce/apex/ProfileBuilderController.getEmployeeNames';
import getSkillList from '@salesforce/apex/ProfileBuilderController.getSkillList';
import updateEmployeeRecord from '@salesforce/apex/ProfileBuilderController.updateEmployeeRecord';
import Employee_OBJECT from "@salesforce/schema/Employee__c";
import Skill_FIELD from "@salesforce/schema/Employee__c.Skills__c";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const fields = [Skill_FIELD];
export default class ProfileHeader extends LightningElement {
    @track options;
    @api recordId;
    @track recordObject = {};
    @track employeeOptions = [];
    @track value;
    iTechlogo = IMAGES;
    progressValue = 20;
    skillPage = true;
    certificatePage = false;
    experiencePage = false;
    professionalSummaryPage = false;
    footerButtonOnSkillPage = true;
    skillListFromObject;
    employeeyRecordTypeId
    picklistValue
    employees
    navigateToExperiencePage = false;
    navigateToSummaryPage = false;

    @track iscolor;

    connectedCallback() {
        const style = document.createElement('style');
        style.innerText = `
                        lightning-progress-bar .slds-progress-bar__value {
                            background-color: green;
                        }
                        lightning-combobox .slds-form-element__label {
                            color: #07334A;
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
        this.getSkillsListFromEmployee();
    }



    handleChange(event) {
        this.value = event.detail.value;
        //console.log("value###", this.value);
        this.recordObject['Id'] = this.value;
    }

    //Get Employee List From Apex
    getEmployeeDetails() {
        getEmployeeNames()
            .then(result => {
                //console.log('@result ', result);
                this.employeeOptions = result.map(employee => ({ label: employee.Name, value: employee.Id }));
            })
            .catch(error => {
                console.error('Error fetching Timesheet data:', error);
            });
    }

    //Get Object info of Employee Object for fetch skill pick list value
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

    //Fetch All Skill PickList Value Using Apex From Object
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

    //Get Specific Employee Related skill list for show data in field
    getSkillsListFromEmployee() {
        getSkillList({ id: this.value })
            .then(result => {
                this.skillListFromObject = result;
                //console.log('SkillsList', result);
                if (result == null) {
                    console.log("Skill list Null");
                } else {
                    this.template.querySelector('[role="cm-picklist"]').setSelectedList(result);
                }

            });
    }
    //On Click For Navigate to Skill Section Using Circle-1 on Progress-bar 
    onSkill() {
        this.skillPage = true;
        this.certificatePage = false;
        this.experiencePage = false;
        this.professionalSummaryPage = false;
        this.footerButtonOnSkillPage = true;
        this.progressValue = 20;

        var divblock = this.template.querySelector('[data-msg="20"]');
        if(divblock){
            this.template.querySelector('[data-msg="20"]').className='class1';
        } 
    }


    //On Click For Navigate to Certificate Section Using Circle-2 on Progress-bar 
    onCertificate() {
        if (JSON.parse(JSON.stringify(this.recordObject))['Skills__c'] != null && JSON.parse(JSON.stringify(this.recordObject))['Id'] != null) {
            this.skillPage = false;
            this.certificatePage = true;
            this.experiencePage = false;
            this.professionalSummaryPage = false;
            this.footerButtonOnSkillPage = false;
            this.progressValue = 40;
        } else if (this.skillListFromObject != null) {
            this.showErrorForSaveAndNextOnSkillPage();
        } else if (JSON.parse(JSON.stringify(this.recordObject))['Id'] == null) {
            this.showErrorOnSelectEmployeeToast();
        } else if (JSON.parse(JSON.stringify(this.recordObject))['Skills__c'] == null) {
            this.showErrorOnSelectSkillToast();
        } else if (JSON.parse(JSON.stringify(this.recordObject))['Skills__c'] != null) {
            this.showErrorOnSelectSkillToast();
        }
        var divblock = this.template.querySelector('[data-msg="40"]');
        if(divblock){
            this.template.querySelector('[data-msg="40"]').className='class1';
        } 
    }
    //On Click For Navigate to Experience Section Using Circle-3 on Progress-bar 
    onExperience() {
        if (JSON.parse(JSON.stringify(this.recordObject))['Skills__c'] == null && JSON.parse(JSON.stringify(this.recordObject))['Id'] == null) {
            this.fillvalueOnSkillPage();
        } else if (JSON.parse(JSON.stringify(this.recordObject))['Skills__c'] != null && JSON.parse(JSON.stringify(this.recordObject))['Id'] != null) {
            this.skillPage = false;
            this.certificatePage = false;
            this.experiencePage = true;
            this.professionalSummaryPage = false;
            this.footerButtonOnSkillPage = false;
            this.progressValue = 60
        }
        var divblock = this.template.querySelector('[data-msg="60"]');
        if(divblock){
            this.template.querySelector('[data-msg="60"]').className='class1';
        } 

    }

    //On Click For Navigate to Summary Section Using Circle-4 on Progress-bar 
    onSymmary() {
        if (JSON.parse(JSON.stringify(this.recordObject))['Skills__c'] == null && JSON.parse(JSON.stringify(this.recordObject))['Id'] == null) {
            this.fillvalueOnSkillPage();
        } else if (JSON.parse(JSON.stringify(this.recordObject))['Skills__c'] != null && JSON.parse(JSON.stringify(this.recordObject))['Id'] != null) {
            this.storevalueOnExperiencePage();
        }
        else if (this.navigateToSummaryPage == true) {
            this.skillPage = false;
            this.certificatePage = false;
            this.experiencePage = false;
            this.professionalSummaryPage = true;
            this.footerButtonOnSkillPage = false;
            this.progressValue = 80
        } else if (this.experiencePage == true) {
            this.storevalueOnExperiencePage();
        }
        var divblock = this.template.querySelector('[data-msg="80"]');
        if(divblock){
            this.template.querySelector('[data-msg="80"]').className='class1';
        } 

    }

    progressHandleClick(){
        var divblock = this.template.querySelector('[data-msg="100"]');
        if(divblock){
            this.template.querySelector('[data-msg="100"]').className='class1';
        } 
    }


    // Navigate to Cirtificate Section Using save & next button of skill section
    onNavigateToCertificatePage() {
        if (this.template.querySelector('[role="cm-picklist"]').isValid() && this.value != null) {
            this.picklistValue = this.template.querySelector('[role="cm-picklist"]').getSelectedList();
            //console.log("picklistValue####", this.picklistValue);
            this.recordObject['Skills__c'] = this.picklistValue;
            this.skillPage = false;
            this.certificatePage = true;
            this.footerButtonOnSkillPage = false;
            this.progressValue = 40;
            updateEmployeeRecord({ wrapperText: JSON.stringify(this.recordObject) })
        } else if (this.value == null) {
            this.showErrorOnSelectEmployeeToast();
            //console.log('In Valid...')
        } else {
            this.showErrorOnSelectSkillToast();
        }


    }


    // Navigate to Experience Section Using save & next button of Certificate section
    //This is Child to parent onClick event listen 
    handleFromCertificatePage(event) {
        var navigateToExperiencePage = event.detail.experiencePage;
        if (navigateToExperiencePage == true) {
            this.certificatePage = false;
            this.skillPage = false;
            this.experiencePage = true;
            this.progressValue = 60
            this.recordObject = JSON.parse(JSON.stringify(event.detail.recordObject))
            //console.log("$$recordObjetc@@@" ,JSON.parse(JSON.stringify(this.recordObject)));
        }


    }

    // Navigate to Skill Section Using Back button of Certificate section
    //This is Child to parent onClick event listen
    handleBackToSkillPage(event) {
        var backToSkillpage = event.detail.skillPage;
        if (backToSkillpage == true) {
            this.certificatePage = false;
            this.skillPage = true;
            this.experiencePage = false;
            this.footerButtonOnSkillPage = true;
            this.progressValue = 20;
            this.recordObject = JSON.parse(JSON.stringify(event.detail.recordObject))
            this.certificateOptions = JSON.parse(JSON.stringify(event.detail.certificateOptions))
            this.value = this.recordObject['Id'];
        }


    }

    // Navigate to Skill Section Using save & next button of Experience section
    //This is Child to parent onClick event listen 
    handleFromExperiencePage(event) {
        this.navigateToSummaryPage = event.detail.summaryPage;
        var navigateToSummaryPage = event.detail.summaryPage;
        if (navigateToSummaryPage == true) {
            this.certificatePage = false;
            this.skillPage = false;
            this.experiencePage = false;
            this.professionalSummaryPage = true
            this.progressValue = 80
        }

    }

    // Navigate to Certificate Section Using Back button of Experience section
    //This is Child to parent onClick event listen
    handleBackToCertificatePage(event) {
        var backToCertificatePage = event.detail.certificatePage;
        if (backToCertificatePage == true) {
            this.certificatePage = true;
            this.skillPage = false;
            this.experiencePage = false;
            this.progressValue = 40;
            this.recordObject = JSON.parse(JSON.stringify(event.detail.recordObject))
        }

    }

    // Navigate to Experience Section Using Back button of Summary section
    //This is Child to parent onClick event listen
    handleBackToExperiencePage(event) {
        var backtoExperiencePage = event.detail.experiencePage;
        if (backtoExperiencePage == true) {
            this.skillPage = false;
            this.experiencePage = true;
            this.professionalSummaryPage = false;
            this.progressValue = 60;
        }

    }

    //All Related Toast
    showErrorOnSelectEmployeeToast() {
        const evt = new ShowToastEvent({
            message: 'The "Add Employee & Skill" stage is required',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    showErrorOnSelectSkillToast() {
        const evt = new ShowToastEvent({
            message: 'The "Add Employee & Skill" stage is required',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    showErrorForSaveAndNextOnSkillPage() {
        const evt = new ShowToastEvent({
            message: 'Please Click On Save & Next',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    showErrorForSaveAndNextFromExperiencePage() {
        const evt = new ShowToastEvent({
            message: 'Please Click On Save & Next On Skill Stage',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    storeValueOnCertificatePage() {
        const evt = new ShowToastEvent({
            message: 'Please Save Value On Certificate Stage',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    storevalueOnExperiencePage() {
        const evt = new ShowToastEvent({
            message: 'Please Save Value On Experience Stage',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    fillvalueOnSkillPage() {
        const evt = new ShowToastEvent({
            message: 'The "Add Employee & Skill" stage is required',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}