import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import saveExperience from '@salesforce/apex/ProfileBuilderController.saveExperience';
import getHelpTextExperience from '@salesforce/apex/ProfileBuilderController.getHelpTextExperience';
import getListOfExperience from '@salesforce/apex/ProfileBuilderController.getListOfExperience';
import updateEmployeeRecord from '@salesforce/apex/ProfileBuilderController.updateEmployeeRecord';

export default class ExperienceDetails extends LightningElement {

    employeeId;
    recordempId = {};
    @track employerValue = '';
    @track jobTitleValue = '';
    @track startDateValue = null;
    @track endDateValue = null;
    @track myVal = '';
    @track showExperienceForm = false;
    today;
    //help text
    @track richTextValue = ''
    @track helpTexts;
    @track error;
    searchKey = '';
    @api recordObject;
    experienceId = '';
    delayTimeout
    selectedValue
    spinner = true;



    @track isShowModal = false;
    @track storedExperiences = [];



    connectedCallback() {
        this.today = new Date().toISOString().slice(0, 10)
        console.log('this.today-------->', this.today);

        const style = document.createElement('style');
        style.innerText = `
                        lightning-input .slds-form-element__label {
                            font-weight: bold;
                        }
                    `;
        setTimeout(() => {
            this.template.querySelector('.overrideStyle').appendChild(style);
        }, 200);
        //For Record Id;
        this.recordempId = JSON.parse(JSON.stringify(this.recordObject));
        console.log("recordObjectFromCertificate---@@", this.recordempId['Id']);

        this.getExperienceDetails();
    }

    //for fetching experience
    getExperienceDetails() {
        getListOfExperience({ id: this.recordempId['Id'] })
            .then(result => {
                console.log('resultOf Experience ', result);
                this.storedExperiences = result;
                this.spinner = false;
            });
    }



    @wire(getHelpTextExperience, { inputStr: '$searchKey' })
    wiredHelpTexts({ data, error }) {
        if (data) {
            this.helpTexts = data;
            console.log("helptText####", this.helpTexts)
            this.error = undefined;
        } else {
            this.helpTexts = undefined;
            this.error = error;
        }
    }

    showModalBox() {
        this.isShowModal = true;
    }

    hideModalBox() {
        this.isShowModal = false;
    }

    editExperience(event) {
        console.log('stored experience------>', this.storedExperiences);
        const id = event.currentTarget.dataset.id;
        console.log('id--->', id);
        const editexp = this.storedExperiences.find(i => i.Id === id);

        // const editExpRecord = this.storedExperiences.find(i=>i.Id === id);
        // console.log(editExpRecord);
        // this.currentIndex = index; // Track the index of the experience being edited
        // console.log('this.currentIndex---->',this.currentIndex);
        // const editexp = this.storedExperiences[index];
        // console.log('experienceToEdit---->',experienceToEdit);
        // // Implement logic to populate modal with stored data for editing
        this.showModalBox();
        this.employerValue = editexp.Name;
        this.jobTitleValue = editexp.Job_Title__c;
        this.startDateValue = editexp.Start_Date__c;
        this.endDateValue = editexp.End_Date__c;
        this.myVal = editexp.Description__c;
        this.experienceId = editexp.Id;
    }


    saveExp() {
        //start date and end date logic 
        if (this.endDateValue < this.startDateValue) {
            this.endAndStartDiffDateErrorToast()
        } else if (this.startDateValue > this.today && this.endDateValue > this.today) {
            this.bothDateErrorToast();
        }
        else if (this.startDateValue > this.today) {
            this.startDateErrorToast();
        } else if (this.endDateValue > this.today) {
            this.endDateErrorToast();
        } else {
            saveExperience({
                employer: this.employerValue,
                jobTitle: this.jobTitleValue,
                startDate: this.startDateValue,
                endDate: this.endDateValue,
                description: this.myVal,
                employeeId: this.recordempId['Id'], // You need to specify the employeeId here
                experienceId: this.experienceId // Pass the experienceId if updating, otherwise pass null for new records
            })
                .then(result => {
                    console.log('Experience saved successfully', JSON.stringify(result));
                    console.log('this.storedExperiences', this.storedExperiences);
                    const obj = this.storedExperiences.find(i => i.Id === this.experienceId);
                    console.log('obj', obj);
                    if (obj === null || obj === undefined) { //save case
                        this.storedExperiences.push(result);
                        console.log('result edit--------->', result);
                        const toastEvent = new ShowToastEvent({
                            message: 'Experience record inserted successfully',
                            variant: 'success'
                        });
                        this.dispatchEvent(toastEvent);
                    }
                    else { //edit case
                        console.log(this.storedExperiences);
                        const index = this.storedExperiences.findIndex(i => i.Id === this.experienceId);
                        console.log('index---------->', index);
                        this.storedExperiences[index] = result;
                        console.log('this.storedExperiences edited--->', this.storedExperiences);
                        const toastEvent = new ShowToastEvent({
                            message: 'Experience record edited successfully',
                            variant: 'success'
                        });
                        this.dispatchEvent(toastEvent);
                    }
                    // Reset fields and hide modal box after successful save
                    this.resetFields();
                    this.hideModalBox();
                })
                .catch(error => {
                    console.error('Error saving experience: ', error);
                    this.showErrorToast();
                    // Handle error
                });
        }
    }


    deleteExperience(event) {
        const recordId = event.currentTarget.dataset.id;// for deleting record from the backend
        const index = event.currentTarget.dataset.index;//for deleting from the box  
        this.storedExperiences.splice(index, 1);
        this.storedExperiences = [...this.storedExperiences];
        deleteRecord(recordId)
            .then(() => {
                // Show a success toast message after successful deletion
                const toastEvent = new ShowToastEvent({
                    message: 'Experience record deleted successfully',
                    variant: 'success'
                });
                this.dispatchEvent(toastEvent);
            })
            .catch(error => {
                console.error('Error deleting experience record:', error);
                // Show an error toast message if deletion fails
                const toastEvent = new ShowToastEvent({
                    message: 'Failed to delete experience record',
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
            });
    }



    handleEmployerChange(event) {
        this.employerValue = event.target.value;
        // console.log('this.employerValue--->',this.employerValue);
    }

    handleJobTitleChange(event) {
        this.jobTitleValue = event.target.value;
        // console.log('this.jobTitleValue--->',this.jobTitleValue);
    }

    handleStartDateChange(event) {
        this.startDateValue = event.target.value;
        // console.log('this.startDateValue--->',this.startDateValue);
    }

    handleEndDateChange(event) {
        this.endDateValue = event.target.value;
        // console.log('this.endDateValue--->',this.endDateValue);
    }

    handleChange(event) {
        this.myVal = event.target.value;
        // console.log('this.myVal--->',this.myVal);
    }

    handleKeyChange(event) {
        const searchKey = event.target.value.trim();
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey == '' ? this.searchKey = ' ' : searchKey;
        }, '200');
    }

    onValueGoToRichTextArea(event) {
        var index = parseInt(event.currentTarget.dataset.id);
        //console.log("index$$",index);
        this.selectedValue = this.helpTexts[index]['Instructions__c'];
        //console.log("selectedValue$$",this.selectedValue);
        this.myVal += '<ul>' + '<li>' + this.selectedValue + '</li>' + '</ul>';
    }

    onAddOneMoreExperience() {
        this.showExperienceForm = !this.showExperienceForm;
        this.isShowModal = true;
        // console.log('this.showExperienceForm--->',this.showExperienceForm);

    }

    onNavigateToSummaryPage() {
        if (this.storedExperiences.length == 0) {
              this.addAtLeastOneExperience();
        } else {
            this.dispatchEvent(
                new CustomEvent('summarypage', {
                    detail: {
                        'summaryPage': true
                    }
                })
            )
        }
    }

    onBack() {
        updateEmployeeRecord({ wrapperText: JSON.stringify(this.recordObject) })
        this.dispatchEvent(
            new CustomEvent('backtocertificatepage', {
                detail: {
                    'certificatePage': true,
                    'recordObject': this.recordObject
                }
            })
        )
    }

    showErrorToast() {
        const evt = new ShowToastEvent({
            message: 'Please Enter All Details',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    endAndStartDiffDateErrorToast() {
        const evt = new ShowToastEvent({
            message: 'Start Date Should Be Earlier Than End Date ',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    endDateErrorToast() {
        const evt = new ShowToastEvent({
            message: 'The end date should not be in the future.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    startDateErrorToast() {
        const evt = new ShowToastEvent({
            message: 'The start date should not be in the future.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    bothDateErrorToast() {
        const evt = new ShowToastEvent({
            message: 'The start and end date should not be in the future.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    addAtLeastOneExperience() {
        const evt = new ShowToastEvent({
            message: 'Please Add At Least One Experience',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    resetFields() {
        this.employerValue = '';
        this.jobTitleValue = '';
        this.startDateValue = '';
        this.endDateValue = '';
        this.myVal = '';
        this.experienceId = '';
    }
}