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
    @track profileData = {};
    @track previewProfile = true;
    @track value;
    iTechlogo = IMAGES;
    progressValue = 20;
    skillPage = true;
    certificatePage = false;
    experiencePage = false;
    professionalSummaryPage = false;
    profilePreviewPage = false
    footerButtonOnSkillPage = true;
    skillListFromObject;
    employeeyRecordTypeId
    picklistValue
    employees
    navigateToExperiencePage = false;
    navigateToSummaryPage = false;
    profileId='0681e000001bTjxAAE';
    spinner = true;
    searchResults;
    selectedSearchResult;
    selectedEmployeeId;


    connectedCallback() {
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
       this.progressStageBackgroundColorChange();
        this.getSkillsListFromEmployee();
         
        
    }
    //Start of lightning input for the employee selection
    get selectedValue() {
        return this.selectedSearchResult ? this.selectedSearchResult.label : null;
    }

    search(event) {
        const input = event.detail.value.toLowerCase();
        const result = this.employeeOptions.filter((picklistOption) =>
          picklistOption.label.toLowerCase().includes(input)
        );
        console.log('employeeoptionssss--->',this.employeeOptions);
        this.searchResults = result;
        console.log('this.searchResults--->',this.searchResults);
    }

    selectSearchResult(event) {
        const selectedValue = event.currentTarget.dataset.value;
        this.selectedEmployeeId = selectedValue;
        console.log('selectedValue---->',selectedValue);
        //console.log('employeeyRecordTypeId',employeeyRecordTypeId);
        this.selectedSearchResult = this.employeeOptions.find(
          (employeeOptions) => employeeOptions.value === selectedValue
        );
        console.log('this.employeeOptions selectSearchResult-->',this.selectedEmployeeId);
        this.recordObject['Id'] = this.selectedEmployeeId;
        this.clearSearchResults();
    }

    clearSearchResults() {
        this.searchResults = null;
    }
    
    showPicklistOptions() {
        if (!this.searchResults) {
          this.searchResults = this.employeeOptions;
          console.log('this.searchResults---showPicklistOptions-->',this.searchResults);
        }
    }
    //combox select employee
    // handleChange(event) {
    //     this.value = event.detail.value;
    //     //console.log("value###", this.value);
    //     this.recordObject['Id'] = this.value;
    // }

    //Get Employee List From Apex
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
        getSkillList({ id: this.selectedEmployeeId })
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
        this.profilePreviewPage = false;
        this.footerButtonOnSkillPage = true;
        this.progressValue = 20;
    }

    //On Click For Navigate to Certificate Section Using Circle-2 on Progress-bar 
    onCertificate() {
        if (JSON.parse(JSON.stringify(this.recordObject))['Skills__c'] != null && JSON.parse(JSON.stringify(this.recordObject))['Id'] != null) {
            this.skillPage = false;
            this.certificatePage = true;
            this.experiencePage = false;
            this.professionalSummaryPage = false;
            this.profilePreviewPage = false;
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
            this.profilePreviewPage = false;
            this.footerButtonOnSkillPage = false;
            this.progressValue = 60
        }
    }

    //On Click For Navigate to Summary Section Using Circle-4 on Progress-bar 
    onSymmary() {
        if (JSON.parse(JSON.stringify(this.recordObject))['Skills__c'] == null && JSON.parse(JSON.stringify(this.recordObject))['Id'] == null) {
            this.fillvalueOnSkillPage();
        }else if (this.navigateToSummaryPage == true) {
            this.skillPage = false;
            this.certificatePage = false;
            this.experiencePage = false;
            this.professionalSummaryPage = true;
            this.profilePreviewPage = false;
            this.footerButtonOnSkillPage = false;
            this.progressValue = 80
        }else if (JSON.parse(JSON.stringify(this.recordObject))['Skills__c'] != null && JSON.parse(JSON.stringify(this.recordObject))['Id'] != null) {
            this.storevalueOnExperiencePage();
        }else if (this.experiencePage == true) {
            this.storevalueOnExperiencePage();
        }

    }

    // Navigate to Cirtificate Section Using save & next button of skill section

    onNavigateToCertificatePage() {
        if (this.template.querySelector('[role="cm-picklist"]').isValid() && this.selectedEmployeeId != null) {
            this.picklistValue = this.template.querySelector('[role="cm-picklist"]').getSelectedList();
            //console.log("picklistValue####", this.picklistValue);
            this.recordObject['Skills__c'] = this.picklistValue;
            this.skillPage = false;
            this.certificatePage = true;
            this.footerButtonOnSkillPage = false;
            this.progressValue = 40;
            updateEmployeeRecord({ wrapperText: JSON.stringify(this.recordObject) })
        } else if (this.selectedEmployeeId == null) {
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
            this.selectedEmployeeId = this.recordObject['Id'];
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
            this.profilePreviewPage = false;
            this.progressValue = 80
        }

    }
// Navigate to Preview Section Using save & next button of Summary section
    //This is Child to parent onClick event listen
    handleFromSummaryPage(event){
        this.navigateToProfilePreviewPage = event.detail.profilePreviewPage;
        var navigateToProfilePreviewPage = event.detail.profilePreviewPage;
        if (navigateToProfilePreviewPage == true) {
            this.skillPage = false;
            this.certificatePage = false;
            this.experiencePage = false;
            this.professionalSummaryPage = false;
            this.profilePreviewPage = true;
            this.recordObject = JSON.parse(JSON.stringify(event.detail.recordObject))
            this.profileData = JSON.parse(JSON.stringify(event.detail.profileData))
            this.progressValue = 100
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
    handleBackToSummaryPage(event) {
        var backtoSummaryPage = event.detail.summaryPage;
        if (backtoSummaryPage == true) {
            this.skillPage = false;
            this.experiencePage = false;
            this.professionalSummaryPage = true;
            this.profilePreviewPage = false;
            this.progressValue = 80;
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

   progressStageBackgroundColorChange(){
        if (this.progressValue == 20) {
            this.template.querySelector('[data-msg="20"]').className = 'class1';
            this.template.querySelector('[data-msg="40"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="60"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="80"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="100"]').className = 'pogressNum';
        } else if (this.progressValue == 40) {
            this.template.querySelector('[data-msg="20"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="40"]').className = 'class1';
            this.template.querySelector('[data-msg="60"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="80"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="100"]').className = 'pogressNum';
        } else if (this.progressValue == 60) {
            this.template.querySelector('[data-msg="20"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="40"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="60"]').className = 'class1';
            this.template.querySelector('[data-msg="80"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="100"]').className = 'pogressNum';
        } else if (this.progressValue == 80) {
            this.template.querySelector('[data-msg="20"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="40"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="60"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="80"]').className = 'class1';
            this.template.querySelector('[data-msg="100"]').className = 'pogressNum';
        }else if(this.progressValue == 100){
            this.template.querySelector('[data-msg="20"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="40"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="60"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="80"]').className = 'pogressNum';
            this.template.querySelector('[data-msg="100"]').className = 'class1';
        }
   }
}