import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchEmployeeData from '@salesforce/apex/EmployeeController.fetchEmployeeDetails';
import fetchEducationData from '@salesforce/apex/EmployeeController.fetchEmpEducationData';
import fetchExperienceData from '@salesforce/apex/EmployeeController.fetchEmpExperienceData';
import updateEmployeeData from '@salesforce/apex/EmployeeController.updateEmployeeDetails';

export default class EmployeeAboutPage extends LightningElement {
    @track viewMode = true;
    @track editMode = false;
    @api employeeId;
    @track objectAPIName = 'Employee__c';
    @track empData;
    @track empEduData;
    @track empExpData;

    @track isError = false;
    @track errorMessage = '';

    @track viewAbout = true;
    @track editAbout = false;

    @track viewAboutMe = true;
    @track editAboutMe = false;

    @track viewHobbies = true;
    @track editHobbies = false;
    // warningToastDisplayed = false;

    


    connectedCallback() {
        this.fetchEmployeeDetails();
        console.log('employeeId-->>', this.employeeId);
        setTimeout(() => {
            const style = document.createElement('style');
            style.innerText = `
			.slds-modal__container{
				max-width: 50% !important;
			}
				  `;
            this.template.querySelector('.overrideStyle').appendChild(style);
        }, 100);

    }

    fetchEmployeeDetails() {
        if (!this.employeeId) {
            return;
        }
        fetchEmployeeData({ employeeId: this.employeeId })
            .then(result => {
                this.empData = result[0];
                console.log('this.empData-->>', JSON.parse(JSON.stringify(this.empData)));
            })
            .catch(error => {
                this.error = error;
                console.error('Error in fetching record data:', error);
            });

        fetchEducationData({ employeeId: this.employeeId })
            .then(result => {
                this.empEduData = result;
                console.log('this.empEduData-->>', JSON.parse(JSON.stringify(this.empEduData)));
            })
            .catch(error => {
                this.error = error;
                console.error('Error in fetching record data:', error);
            });

        fetchExperienceData({ employeeId: this.employeeId })
            .then(result => {
                this.empExpData = result;
                console.log('this.empExpData-->>', JSON.parse(JSON.stringify(this.empExpData)));
            })
            .catch(error => {
                this.error = error;
                console.error('Error in fetching record data:', error);
            });
    }

    // switchToEditModeFirstBox(){
    //     this.viewModeFirstBox = false;
    //     this.editMode = true;
    // }

    // switchToEditModeSecondBox(){
    //     this.viewMode = false;
    //     this.editMode = true;
    // }
    editAboutbutton() {
        this.editedEmpData = { ...this.empData };
        this.editAbout = true;
        this.isError= false;
        this.errorMessage = '';
    }

    editAboutMebutton() {
        this.editedEmpData = { ...this.empData };
        this.editAboutMe = true;
        this.isError= false;
        this.errorMessage = '';
    }

    editHobbiesbutton() {
        this.editedEmpData = { ...this.empData };
        this.editHobbies = true;
        this.isError= false;
        this.errorMessage = '';
    }
    // cancelBtn(){
    //     this.viewMode = false;
    //     this.editMode = true;
    // }

    handleEmpChange(event) {
        this.isError= false;
        this.errorMessage = '';
        const field = event.target.dataset.field;
        this.editedEmpData[field] = event.target.value;
        let fieldValue = event.target.value;

        // if (!fieldValue.replace(/<[^>]*>/g, '').trim() || fieldValue.replace(/<[^>]*>/g, '') === '') {
           
        //     this.isError= true;
        //     this.errorMessage = 'Fields are must not null or empty.';
        //     this.handleValidationErrors('Error', this.errorMessage , 'error');
        // }
        console.log('field-->>', field);
        console.log('fieldValue-->>', fieldValue);
        if(field == "About_Me__c"){
            let aboutMe = fieldValue.replace(/<[^>]*>/g, '');
             console.log('aboutMe-->>', aboutMe);
            if(aboutMe.length > 1000 ){
                this.isError= true;
                this.errorMessage = 'Please limit your input to 1000 characters.';
                this.handleValidationErrors('Warning', this.errorMessage, 'warning');
            }
            if(!aboutMe || !aboutMe.replace(/<[^>]*>/g, '').trim() || aboutMe.replace(/<[^>]*>/g, '') === ''){
                this.isError= true;
                this.errorMessage = 'Input is required for saving the record.';
                this.handleValidationErrors('Error', this.errorMessage, 'error');
            }
        }
        if(field == "About_My_Job__c"){
            let aboutMyJob = fieldValue.replace(/<[^>]*>/g, '');
            console.log('aboutMyJob-->>', aboutMyJob);
            if(aboutMyJob.length > 1000 ){
                this.isError= true;
                this.errorMessage = 'Please limit your input to 1000 characters.';
                this.handleValidationErrors('Warning', this.errorMessage, 'warning');
            }
            if(!aboutMyJob || !aboutMyJob.replace(/<[^>]*>/g, '').trim() || aboutMyJob.replace(/<[^>]*>/g, '') === ''){
                this.isError= true;
                this.errorMessage = 'Input is required for saving the record.';
                this.handleValidationErrors('Error', this.errorMessage, 'error');
            }
        }
        if(field == "Hobbies__c"){
            let hobbies = fieldValue.replace(/<[^>]*>/g, '');
            console.log('hobbies-->>', hobbies);
            if(hobbies.length > 1000 ){
                this.isError= true;
                this.errorMessage = 'Please limit your input to 1000 characters.';
                this.handleValidationErrors('Warning', this.errorMessage, 'warning');
            }
            if(!hobbies || !hobbies.replace(/<[^>]*>/g, '').trim() || hobbies.replace(/<[^>]*>/g, '') === ''){
                this.isError= true;
                this.errorMessage = 'Input is required for saving the record.';
                this.handleValidationErrors('Error', this.errorMessage, 'error');
            }
        }
    }

    hideAboutModal() {
        this.editAbout = false;
    }
    hideAboutMeModal() {
        this.editAboutMe = false;
    }
    hideHobbiesModal() {
        this.editHobbies = false;
    }

    saveEmpDetails() {
        console.log('empData-->>', JSON.parse(JSON.stringify(this.editedEmpData)));
         console.log('this.isError-->>', this.isError);
          console.log('this.errorMessage-->>', this.errorMessage);
          console.log('Err Start');
        if(this.isError){
            console.log('Err0');
            console.log('this.errorEmpMessage-->>', this.errorMessage);
            this.handleValidationErrors('Error', this.errorMessage , 'error');
            return;
        }
        if(this.editAbout){
            if(this.editedEmpData.hasOwnProperty('About_Me__c')){
                console.log('!this.editedEmpData.hasOwnProperty(About_Me__c) >>',this.editedEmpData.About_Me__c === 'undefined' || this.editedEmpData.About_Me__c === undefined);
                if( this.editedEmpData.About_Me__c === 'undefined' || this.editedEmpData.About_Me__c === undefined){
                    console.log('Err1');
                    this.handleValidationErrors('Error', 'Input is required for saving the record.' , 'error');
                    return;
                }
            
            }
            else{
                console.log('Err1 Else');
                    this.handleValidationErrors('Error', 'Input is required for saving the record.' , 'error');
                    return;
            }
        }
        console.log('this.editAboutMe-->>', this.editAboutMe);
        if(this.editAboutMe){
            if(this.editedEmpData.hasOwnProperty('About_My_Job__c')){
                console.log('this.editedEmpData.About_My_Job__c-->>', this.editedEmpData.About_My_Job__c);
                console.log('!this.editedEmpData.hasOwnProperty(About_My_Job__c) >>',this.editedEmpData.About_My_Job__c === 'undefined' || this.editedEmpData.About_My_Job__c === undefined);
                if(this.editedEmpData.About_My_Job__c === 'undefined' || this.editedEmpData.About_My_Job__c === undefined){
                    console.log('Err2');
                    this.handleValidationErrors('Error', 'Input is required for saving the record.' , 'error');
                    return;
                }
            }
            else{
                console.log('Err2 Else');
                this.handleValidationErrors('Error', 'Input is required for saving the record.' , 'error');
                return;
            }
        }
        
        
        if(this.editHobbies){
            if(this.editedEmpData.hasOwnProperty('Hobbies__c')){
                console.log('this.editedEmpData.Hobbies__c-->>', this.editedEmpData.Hobbies__c);
                console.log('!this.editedEmpData.hasOwnProperty(Hobbies__c) >>', this.editedEmpData.Hobbies__c === 'undefined' || this.editedEmpData.Hobbies__c === undefined);
                if(this.editedEmpData.Hobbies__c === 'undefined' || this.editedEmpData.Hobbies__c === undefined){
                    console.log('Err3');
                    this.handleValidationErrors('Error', 'Input is required for saving the record.' , 'error');
                    return;
                }
            }
            else{
                console.log('Err3 Else');
                this.handleValidationErrors('Error', 'Input is required for saving the record.' , 'error');
                return;
            }
        }
        
        
            console.log('No Err');
        updateEmployeeData({ employeeData: this.editedEmpData })
            .then(result => {
                console.log('rich text area Content-->>', JSON.parse(JSON.stringify(result)));
                this.fetchEmployeeDetails();
                this.isError= false;
                this.errorMessage = '';
                this.showToast('Success', 'Record saved successfully', 'success');
            })
            .catch(error => {
                // Handle error
                this.error = error;
                console.error('Error in updating record data:', error);
            });
        this.editAbout = false;
        this.editAboutMe = false;
        this.editHobbies = false;
        
        
        
    }
    showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event);
    }

    cancelEditMode() {
        // this.editedAboutMe = this.empData.About_Me__c; // Reset the edited value
        // this.editedAboutMyJob = this.empData.About_My_Job__c;
        // this.editedHobbies = this.empData.Hobbies__c;
        this.viewAbout = true; // Switch back to view mode
    }

    handleValidationErrors(title,errorMessage,variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: errorMessage,
                variant: variant,
            })
        );
    }


}