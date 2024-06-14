import { LightningElement,track } from 'lwc';
import saveExperience from '@salesforce/apex/ProfileBuilderController.saveExperience';
import getEmployeeNames from '@salesforce/apex/ProfileBuilderController.getEmployeeNames';
export default class ExperienceDetails extends LightningElement {

    employeeId;
    @track employerValue = '';
    @track jobTitleValue = '';
    @track startDateValue = null;
    @track endDateValue = null;
    @track myVal = '';
    @track showExperienceForm = false;

        
    @track isShowModal = false;
    @track storedExperiences = [];

    selectedValue
    values = [
        {
            "Id":"0",
            "Disc":"Lorem ipsum dolor sit amet consectetur adipisicing elit"
        },
        {
            "Id":"1",
            "Disc":"Lorem ipsum dolor sit amet consectetur adipisicing elit,Lorem ipsum dolor sit amet consectetur adipisicing elit"
        },
        {
            "Id":"2",
            "Disc":"Lorem ipsum dolor sit amet consectetur adipisicing elit"
        },
        {
            "Id":"3",
            "Disc":"Lorem ipsum dolor sit amet consectetur adipisicing elit,Lorem ipsum dolor sit amet consectetur adipisicing elit"
        },
     ]

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


    showModalBox() {
        this.isShowModal = true;
    }

    hideModalBox() {
        this.isShowModal = false;
    }

    editExperience(event) {
        const index = event.currentTarget.dataset.index;
        console.log('index--->',index);
        this.currentIndex = index; // Track the index of the experience being edited
        const experienceToEdit = this.storedExperiences[index];
        // Implement logic to populate modal with stored data for editing
        this.showModalBox();
        this.employerValue = experienceToEdit.employer;
        this.jobTitleValue = experienceToEdit.jobTitle;
        this.startDateValue = experienceToEdit.startDate;
        this.endDateValue = experienceToEdit.endDate;
        this.myVal = experienceToEdit.description;
    }
    

    saveExp() {
        if (this.currentIndex !== undefined) { // If currentIndex is defined, update the existing record
            const editedExperience = {
                id: this.storedExperiences[this.currentIndex].id, // Preserve the original id
                employer: this.employerValue,
                jobTitle: this.jobTitleValue,
                startDate: this.startDateValue,
                endDate: this.endDateValue,
                description: this.myVal
            };
            this.storedExperiences[this.currentIndex] = editedExperience; // Update the existing record
            console.log('update record------>',this.storedExperiences);
        } else { // If currentIndex is undefined, add a new record
            const newExperience = {
                id: Date.now(), // Unique identifier for each experience
                employer: this.employerValue,
                jobTitle: this.jobTitleValue,
                startDate: this.startDateValue,
                endDate: this.endDateValue,
                description: this.myVal
            };
            this.storedExperiences = [...this.storedExperiences, newExperience]; // Add a new record
            console.log('new record------>',this.storedExperiences);
        }
    
        // Call the Apex method to save the experience
        saveExperience({
            employer: this.employerValue,
            jobTitle: this.jobTitleValue,
            startDate: this.startDateValue,
            endDate: this.endDateValue,
            description: this.myVal,
            employeeId: this.employeeId, // You need to specify the employeeId here
            experienceId: this.currentIndex !== undefined ? this.storedExperiences[this.currentIndex].id : null // Pass the experienceId if updating, otherwise pass null for new records
        })
        .then(result => {
            console.log('Experience saved successfully',JSON.stringify(result));
            console.log('this.storedExperiences',this.storedExperiences);
            // Reset fields and hide modal box after successful save
            this.resetFields();
            this.hideModalBox();
        })
        .catch(error => {
            console.error('Error saving experience: ', error);
            // Handle error
        });
    }


    deleteExperience(event) {
        const index = event.currentTarget.dataset.index;
        this.storedExperiences.splice(index, 1);
        this.storedExperiences = [...this.storedExperiences]; // To trigger reactivity
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
    
    onValueGoToRichTextArea(event){
        
        var index = parseInt(event.currentTarget.dataset.id);
        console.log("index$$",index);
        this.selectedValue = this.values[index]['Disc'];
        console.log("selectedValue$$",this.selectedValue);
        this.myVal += '<ul>'+'<li>'+this.selectedValue+'</li>'+'</ul>';
        
   }
   getTheParagrhapValue(event){
      
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
        //this.showExperienceForm = !this.showExperienceForm;
        this.isShowModal = true;
        console.log('this.showExperienceForm--->',this.showExperienceForm);

    }

    onNavigateToSummaryPage(){
        this.dispatchEvent(
            new CustomEvent('summarypage', {
                detail: {
                    'summaryPage': true
                }
            })
        )
    }


    /*onNavigateToSummaryPage() {
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
    }*/

    onBack(){
        this.dispatchEvent(
            new CustomEvent('backtocertificatepage', {
                detail: {
                    'certificatePage': true,
                }
            })
        )
    }

    resetFields() {
        this.employerValue = '';
        this.jobTitleValue = '';
        this.startDateValue = '';
        this.endDateValue = '';
        this.myVal = '';
    }
}