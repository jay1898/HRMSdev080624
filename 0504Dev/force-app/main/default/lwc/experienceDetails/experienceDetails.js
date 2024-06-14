import { LightningElement,track } from 'lwc';
import saveExperience from '@salesforce/apex/ProfileBuilderController.saveExperience';
import getEmployeeNames from '@salesforce/apex/ProfileBuilderController.getEmployeeNames';
export default class ExperienceDetails extends LightningElement {

    // myVal = '<strong>Hello!</strong>';
    employeeId;
    @track employerValue = '';
    @track jobTitleValue = '';
    @track startDateValue = null;
    @track endDateValue = null;
    @track myVal = '';
    @track showExperienceForm = false;

    connectedCallback(){
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
        this.getEmployeeDetails();
    }


    handleEmployerChange(event) {
        this.employerValue = event.target.value;
        console.log('this.employerValue--->',this.employerValue);
    }

    handleJobTitleChange(event) {
        this.jobTitleValue = event.target.value;
        console.log('this.jobTitleValue--->',this.jobTitleValue);
    }

    handleStartDateChange(event) {
        this.startDateValue = event.target.value;
        console.log('this.startDateValue--->',this.startDateValue);
    }

    handleEndDateChange(event) {
        this.endDateValue = event.target.value;
        console.log('this.endDateValue--->',this.endDateValue);
    }

    handleChange(event) {
        this.myVal = event.target.value;
        console.log('this.myVal--->',this.myVal);
    }

    getEmployeeDetails() {
        getEmployeeNames()
            .then(result => {
                console.log('@result ', JSON.parse(JSON.stringify(result[0].Id)));
                this.employeeId = JSON.parse(JSON.stringify(result[0].Id));
                //this.employeeOptions = result.map(employee => ({ label: employee.Id, value: employee.Id }));
                //console.log('this.employeeOptions--->',this.employeeOptions);
                
            })
            .catch(error => {
                console.error('Error fetching Timesheet data:', error);
            });
    }

    onAddOneMoreExperience(event) {
        this.showExperienceForm = !this.showExperienceForm;
        console.log('this.showExperienceForm--->',this.showExperienceForm);

    }

    /*onNavigateToSummaryPage(){
        this.dispatchEvent(
            new CustomEvent('summarypage', {
                detail: {
                    'summaryPage': true
                }
            })
        )
    }*/

    onNavigateToSummaryPage() {
    saveExperience({
        employer: this.employerValue,
        jobTitle: this.jobTitleValue,
        startDate: this.startDateValue,
        endDate: this.endDateValue,
        description: this.myVal,
        employeeId: this.employeeId
    })
    .then(result => {
        console.log('Experience saved successfully');
        // Dispatch the custom event to navigate to the summary page
        this.dispatchEvent(
            new CustomEvent('summarypage', {
                detail: { 'summaryPage': true }
            })
        );
    })
    .catch(error => {
        console.error('Error saving experience: ', error);
        // Handle error
    });
    }

    onBack(){
        this.dispatchEvent(
            new CustomEvent('backtocertificatepage', {
                detail: {
                    'certificatePage': true,
                }
            })
        )
    }
}