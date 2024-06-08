import { LightningElement, api,track } from 'lwc';
import getEmployeeRecord from '@salesforce/apex/ProfileBuilderController.getEmployeeRecord';
import getEmployeeEducation from '@salesforce/apex/ProfileBuilderController.getEmployeeEducation';
import getListOfExperience from '@salesforce/apex/ProfileBuilderController.getListOfExperience';
export default class ProfilePreviewPage extends LightningElement {

    @api recordObject;
    profileData = {};
    preview = false
    backButton = false;
    buttonEnable = true
    buttonDisable = false
   
    connectedCallback(){
        this.recordObject = JSON.parse(JSON.stringify(this.recordObject));
        
       
    }
    renderedCallback(){
        this.getEmployeeRecordDetails();
        this.getEmployeeEducationDetails();
        this.getExperienceDetails();
    }
 getEmployeeRecordDetails() {
        getEmployeeRecord({ empId: JSON.parse(JSON.stringify(this.recordObject['Id'])) })
            .then(result => {
                this.empRecord = result;
                console.log('result#######', this.empRecord);
            });
    }

     getEmployeeEducationDetails() {
        getEmployeeEducation({ empId: JSON.parse(JSON.stringify(this.recordObject['Id'])) })
            .then(result => {
                // Format the date fields
                this.empEducation = result.map(edu => ({
                    ...edu,
                    Start_Date__c: this.formatDate(edu.Start_Date__c),
                    End_Date__c: this.formatDate(edu.End_Date__c)
                }));
                console.log('education result#######', this.empEducation);
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
                console.log('this.empExperiences--->', this.empExperiences);
                // console.log('this.empExperiences[0].Start_Date__c-->', this.empExperiences[0].Start_Date__c);
                // console.log('this.empExperiences[0].End_Date__c-->', this.empExperiences[0].End_Date__c);
            });
    }

    formatDate(dateString) {
        const date = new Date(dateString);
        const day = date.getDate().toString().padStart(2, '0');
        const month = (date.getMonth() + 1).toString().padStart(2, '0');
        const year = date.getFullYear();
        return `${day}-${month}-${year}`;
    }

    setProfileData() {
        this.profileData = {
            name: this.empRecord['Name'],
            userName: this.empRecord['Username__c'],
            email: this.empRecord['Personal_Email__c'],
            certificate: this.empRecord['Certificate__c'],
            phone: this.empRecord['Phone__c'],
            skills: this.empRecord['Skills__c'],
            professionalSummary: this.empRecord['Professional_Summary__c'],
            experience: [],
            education: [],
            ProfileImage: 'data:image/jpg;base64, iVBORw0KGgoAAAANSUhEUgAAACAAAABACAIAAAD07OL5AAABjklEQVR4nOzX3yt7cRzH8XO+rb6uUFxw1iJxI8vFXKiVX0V+ZBeIi6WwpqQkIVJKGdOoXQxpNaW0lJqLUXaxsptlLGVTU35cTBONLewMZbny+vwBcvHp83lfPd4X61nvi51zFIvGQeFndJoQ3C27YIP5GW6KrsKm5nv4/44HLlIG4H/CHw8P8MDvR/GZUmKJuk1w0mGHbXVWeMRyB6sCMXi+fwau/MqG6T8RDzAQEPesGSwxbTvsbW2AM8U6WArOkl+nbGB5/QXsUOth+k/EAwwExIinEMvA5j5xG2nb3WtwXu0UPJw8gie2jHBSKIPpPxEPMBAQ/e8PWLSNt7D9qQLW93bBVadpuMV1BufunsD+806Y/hPxAAMBhS84hqU0ZIHl6QW4+uoDTm8vw+ZR8iwRatTgkCYB038iHmAgICZ841hyDOR/PHycBUsrJfCj1AEbJg/gpZQT7olswPSfiAcYCIg3zj4sb6+XsBQn3wGqwwI4ni/Dc+svsNdK3ovC1xGY/hPxAAOB7wAAAP//u2xofqwWhNYAAAAASUVORK5CYII='
        };

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
                endDate: item.End_Date__c,
                degreeName: item.Degree_Name__c
            }));
        }
        console.log('this.profileData-------->', this.profileData);
    }

    onPreview(){
        this.setProfileData();
        this.preview = true
        this.backButton = true
        this.buttonEnable = false
        this.buttonDisable = true
    }

    onDownload(){
        this.downloadToast();
    }

    onBack(){
        this.dispatchEvent(
            new CustomEvent('backtosummarypage', {
                detail: {
                    'summaryPage': true,
                }
            })
        )
    }

    downloadToast() {
        const evt = new ShowToastEvent({
            message: 'Download Coming Soon',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}