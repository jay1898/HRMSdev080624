import { LightningElement, api, wire, track } from 'lwc';
import getHelpText from '@salesforce/apex/ProfileBuilderController.getHelpTextSummary';
import updateEmployeeRecord from '@salesforce/apex/ProfileBuilderController.updateEmployeeRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProfessionalSummary from '@salesforce/apex/ProfileBuilderController.getProfessionalSummary';
import getEmployeeRecord from '@salesforce/apex/ProfileBuilderController.getEmployeeRecord';
import getEmployeeEducation from '@salesforce/apex/ProfileBuilderController.getEmployeeEducation';
import getListOfExperience from '@salesforce/apex/ProfileBuilderController.getListOfExperience';
import fetchEmployeeImage from '@salesforce/apex/ProfileBuilderController.fetchEmployeeImage';
import SAMPLE_IMAGE from '@salesforce/resourceUrl/sampleImage'

export default class ProfessionalSummary extends LightningElement {
    @track richTextValue = ''
    @track helpTexts;
    @track error;
    @api recordObject;
    @api profileData;
    @api profileId;
    searchKey = '';
    delayTimeout
    selectedValue
    spinner = true;
    buttonEnable = true
    buttonDisable = false
    empRecord = {};
    empEducation = {};
    empExperiences = [];
    empSkills = [];
    empCertificates = [];
    empProfileContentVersion;
    previewSpinner = false;
    

    connectedCallback() {
        this.recordObject = JSON.parse(JSON.stringify(this.recordObject));
        this.profileData = JSON.parse(JSON.stringify(this.profileData));
        this.getSummaryOfEmployee();
        this.getEmployeeProfileImage();
        this.getEmployeeRecordDetails();
        this.getEmployeeEducationDetails();
        this.getExperienceDetails();

    }
    

    //get pre-define summary helpText using apex
    @wire(getHelpText, { inputStr: '$searchKey' })
    wiredHelpTexts({ data, error }) {
        if (data) {
            this.helpTexts = data;
            //console.log("helptText####",this.helpTexts)
            this.error = undefined;
            this.spinner = false
        } else {
            this.helpTexts = undefined;
            this.error = error;
        }
    }

    //get stored summary of selected employee
    getSummaryOfEmployee() {
        getProfessionalSummary({ id: JSON.parse(JSON.stringify(this.recordObject['Id'])) })
            .then(result => {
                //console.log('Summary', result);
                this.richTextValue = result;
            });
    }
    getEmployeeProfileImage(){
        fetchEmployeeImage({employeeId:JSON.parse(JSON.stringify(this.recordObject['Id']))})
        .then(result => {
            //console.log("profileImage#######", result);
            if(result != null){
            this.empProfileContentVersion = result
            }else{
                this.empProfileContentVersion = 'no Image'
            }
        })
    }
    getEmployeeRecordDetails() {
        getEmployeeRecord({ empId: JSON.parse(JSON.stringify(this.recordObject['Id'])) })
            .then(result => {
                this.empRecord = result;
                this.empSkills = this.empRecord['Skills__c'].split(';');
                this.empCertificates = this.empRecord['Certificate__c'].split(';');
                this.empRecord['Date_of_Birth__c'] = this.formatDate(this.empRecord['Date_of_Birth__c']);
                //console.log('result#######', this.empRecord);
            });
    }
    /*
    getEmployeeEducationDetails(){
        getEmployeeEducation({empId : JSON.parse(JSON.stringify(this.recordObject['Id']))})
        .then(result => {
          this.empEducation = result;
           console.log('education result#######',  this.empEducation);
        });
    }*/

    getEmployeeEducationDetails() {
        getEmployeeEducation({ empId: JSON.parse(JSON.stringify(this.recordObject['Id'])) })
            .then(result => {
                // Format the date fields
                this.empEducation = result.map(edu => ({
                    ...edu,
                    Start_Date__c: this.formatDate(edu.Start_Date__c),
                    End_Date__c: this.formatDate(edu.End_Date__c)
                }));
                //console.log('education result#######', this.empEducation);
            });
    }

    getExperienceDetails() {
        getListOfExperience({ id: JSON.parse(JSON.stringify(this.recordObject['Id'])) })
            .then(result => {
                // console.log('resultOf Experience ', result);
                // Iterate over the result array and format start date and end date
                this.empExperiences = result.map(exp => ({
                    ...exp,
                    Start_Date__c: this.formatDate(exp.Start_Date__c),
                    End_Date__c: this.formatDate(exp.End_Date__c)
                }));
                //console.log('this.empExperiences--->', this.empExperiences);
                // console.log('this.empExperiences[0].Start_Date__c-->', this.empExperiences[0].Start_Date__c);
                // console.log('this.empExperiences[0].End_Date__c-->', this.empExperiences[0].End_Date__c);
            });
    }

    // Helper method to format date
    

    handleRichTextValue(event) {
        this.richTextValue = event.target.value;
        this.recordObject['Professional_Summary__c'] = this.richTextValue;
        this.buttonDisable = false;
        this.buttonEnable = true
        //console.log('this.myVal--->', this.richTextValue);
    }

    //update rich-text value onClick of pre-define helpText arrow icon
    onValueGoToRichTextArea(event) {
        var index = parseInt(event.currentTarget.dataset.id);
        // console.log("index$$",index);
        this.selectedValue = this.helpTexts[index]['Instructions__c'];
        // console.log("selectedValue$$",this.selectedValue);
        this.richTextValue += '<ul>' + '<li>' + this.selectedValue + '</li>' + '</ul>';
        this.recordObject['Professional_Summary__c'] = this.richTextValue;
        this.buttonDisable = false;
        this.buttonEnable = true
    }
    
    stripHtmlTags(html) {
    const tempElement = document.createElement('div');
    tempElement.innerHTML = html;
    return tempElement.innerText;
    }
    //Set the search key for helpText for Aex method
    handleKeyChange(event) {
        const searchKey = event.target.value.trim();
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey == '' ? this.searchKey = ' ' : searchKey;
        }, '200');
    }

    //onclick of Save&Next button fire event for ProfileHeader(Parent Component)
    onSaveAndNext() {
        this.recordObject['Professional_Summary__c'] = this.richTextValue;
        this.previewSpinner = true
        //console.log('Record Object: ', this.recordObject);
        if (this.richTextValue == '' || this.richTextValue == null) {
            this.showErrorToast();
        } else {
           updateEmployeeRecord({ wrapperText: JSON.stringify(this.recordObject) })
            .then(result => {
                if (result) {
                    this.previewSpinner = false;
                    this.setProfileData()
                    this.dispatchEvent(
                        new CustomEvent('profilepreviewpage', {
                            detail: {
                                'profilePreviewPage': true,
                                'recordObject': this.recordObject,
                                'profileData':  this.profileData,
                                'profileId':this.empProfileContentVersion
                            }
                        })
                    );
                    this.showSuccessToast();
                } else {
                    // Handle update failure if needed
                    this.previewSpinner = false;
                    this.characterLimit();
                    //console.error('Employee record update failed');
                }
            })
            .catch(error => {
                // Handle any error during the update process
                //console.error('Error updating employee record:', error);
            });
        }
    }


    setProfileData() {
        this.profileData = {
            name: this.empRecord['Name'],
            userName: this.empRecord['Username__c'],
            dateOfBirth:this.empRecord['Date_of_Birth__c'],
            gender:this.empRecord['Gender__c'],
            email: this.empRecord['Personal_Email__c'],
            certificate: [],
            phone: this.empRecord['Phone__c'] ? this.empRecord['Phone__c'] : 'No phone number provided',
            skills: [],
            professionalSummary: this.stripHtmlTags(JSON.parse(JSON.stringify(this.recordObject['Professional_Summary__c']))),
            experience: [],
            education: [],
        };
        if (this.empSkills && this.empSkills.length > 0) {
        // Assign each skill from empSkills array to skillName within profileData.skills array
        this.profileData.skills = this.empSkills.map(skill => ({
            skillName: skill
            }));
        }
        if (this.empCertificates && this.empCertificates.length > 0) {
        // Assign each skill from empSkills array to skillName within profileData.skills array
        this.profileData.certificate = this.empCertificates.map(certificate => ({
            certificateName: certificate
            }));
        }
        if (this.empExperiences && this.empExperiences.length > 0) {
            // Mapping over empExperiences if it's not blank or null
            this.profileData.experience = this.empExperiences.map(item => ({
                expStartDate: item.Start_Date__c,
                expEndDate: item.End_Date__c,
                jobTitle: item.Job_Title__c,
                companyName: item.Name,
                workDesc: item.Description__c
            }));
        }

        if (this.empEducation && this.empEducation.length > 0) {
            // Mapping over empEducation if it's not blank or null
            this.profileData.education = this.empEducation.map(item => ({
                universityName: item.University_Name__c,
                startDate:item.Start_Date__c,
                endDate: item.End_Date__c,
                degreeName: item.Degree_Name__c

            }));
        }
        console.log('this.profileData-------->', this.profileData);
    }
    //onclick of Back button fire event for ProfileHeader(Parent Component)
    onBack() {
        this.dispatchEvent(
            new CustomEvent('backtoexperiencepage', {
                detail: {
                    'experiencePage': true,
                }
            })
        )  
    }
    formatDate(dateString) {
        const date = new Date(dateString);
        const day = date.getDate().toString().padStart(2, '0');
        const month = (date.getMonth() + 1).toString().padStart(2, '0');
        const year = date.getFullYear();
        return `${day}-${month}-${year}`;
    }
    //Error Toast
    showErrorToast() {
        const evt = new ShowToastEvent({
            message: 'Please Enter Details',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    characterLimit() {
        const evt = new ShowToastEvent({
            message: 'Please summarize your professional summary in 150 words only.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    //Success Toast
    showSuccessToast() {
        const evt = new ShowToastEvent({
            message: 'Your Preview Is Loading...',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}