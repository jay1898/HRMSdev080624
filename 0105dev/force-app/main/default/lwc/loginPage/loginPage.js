import { LightningElement, track, api, wire } from 'lwc';
import iTechlogo from '@salesforce/resourceUrl/iTech_logo';
import loginHDimage from '@salesforce/resourceUrl/loginHDimage';
import loginPageImage from '@salesforce/resourceUrl/loginPageImage';
import fullLoginPageImage from '@salesforce/resourceUrl/fullLoginPageImage';
import LoginPageWave from '@salesforce/resourceUrl/LoginPageWave';
import My_Image from '@salesforce/resourceUrl/profileimage'
import hrms from '@salesforce/resourceUrl/hrms';
import laoptopimage from '@salesforce/resourceUrl/laoptopimage';
import getEmployeeByUsernameAndPassword from '@salesforce/apex/EmployeeController.getEmployeeByUsernameAndPassword';
import updateEmployeeRecord from '@salesforce/apex/EmployeeController.updateEmployeeRecord';
import getNotificationInformation from '@salesforce/apex/EmployeeController.getNotificationInformation';
import getUserRecordsDetails from '@salesforce/apex/EmployeeController.getUserRecordsDetails';
import updateData from '@salesforce/apex/EmployeeController.updateData';
import getUserEmailAndSendEmail from '@salesforce/apex/EmployeeController.getUserEmailAndSendEmail';
import updatePassword from '@salesforce/apex/EmployeeController.updatePassword';
import HRMSLink from '@salesforce/label/c.HRMS_Link';
import fetchImage from '@salesforce/apex/EmpUploadDocumentCls.fetchImage';

// import resetPassword from '@salesforce/apex/EmployeeController.resetPassword';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { CurrentPageReference } from 'lightning/navigation';

export default class LoginPage extends LightningElement {
    @track showChildComponent = true;

    //@track loginurl = 'https://itechcloudsolution--itechdev.sandbox.my.site.com/hrms/s/';
    // Production link 
    //@track loginurl = 'https://hrms.itechcloudsolution.com/s/';
    @track loginurl = HRMSLink;
    backgroundImageUrl = `${window.location.origin}/${'resource/fullLoginPageImage'}`;
    @track usernameRequiredError = false;
    @track bannerNotificationList=[];
    @track sidepanelNotificationList=[];
    @track username = '';
    @track password = '';
    recordId;
    @track iTechlogo = iTechlogo;
    @track loginHDimage = loginHDimage;
    @track loginPageImage = loginPageImage; // cartoon
    @track LoginPageWave = LoginPageWave; // Login Page Wave
    @track fullLoginPageImage = fullLoginPageImage;
    @track hrms = hrms;
    @track laoptopimage = laoptopimage;
    @track profileImage = '';
    @track isUploading = false;


    @track tempusername = '';
    isLoading = true;
    loginVisible = true;
    isThankyou = false;
    error;
    empdetailVisible = false;
    resetForm = false;
    @track EmployeeName;
    // @track EmployeeEmail;
    @track EmployeeDetails = {};
    bodyMessage = "";
    i = 0;
    passforget;
    forgetPass;
    username;
    parameters;
    emailRetrieved = false;
    @track newPassword = '';
    @track confirmPassword = '';

    @track newPasswordError = '';
    @track popupError = '';
    @track showPasswordResetForm = false;

    @track selectedDateFromCalendar;
    @track selectedDateFromDrs;
    // @track isDataLoad = false;
    actionClick = true;
    requestDetailsClick = false;
    requesReportClick = false;
    dashboardClick = false;
    ticketHistoryClick = false;
    myProfileClick = false;
    attendanceClick = false;
    annoucementClick = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            
            this.parameters = currentPageReference.state;

            this.forgetPass = this.parameters.forgetPass;
            this.resetForm = this.forgetPass;
            this.loginVisible = !this.resetForm;

            // Use "forgetPass" instead of "passforget"
            this.username = this.parameters.UserName; // Use "UserName" instead of "username"
        }
    }

    toggleComponent() {
        //     this.showChildComponent = !this.showChildComponent;
        //    this.template.querySelector('[data-recid="hamburgermenu"]').style.display = 'none';
        //    this.template.querySelector('[data-recid="mainbody"]').style.display = 'unset'; 

        const hamburgerMenu = this.template.querySelector('[data-recid="hamburgermenu"]');
        const mainBody = this.template.querySelector('[data-recid="mainbody"]');

        if (this.showChildComponent) {
            hamburgerMenu.style.display = 'none';
            mainBody.style.display = 'unset'; // Show the main body content
        } else {
            hamburgerMenu.style.display = 'block'; // Show the child component
            mainBody.style.display = 'flex';
        }

        this.showChildComponent = !this.showChildComponent;
           
        }


    handleUsernameChange(event) {
        this.username = event.target.value.trim();
        this.usernameRequiredError = false;
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
    }

    updateStatus(event){
        console.log('data from child : ',event.detail.uploadProfile);
        if(event.detail.uploadProfile){
            this.fetchAndDisplayImage();
        }
    }

    connectedCallback() {
        this.recordId = localStorage.getItem('recordId') != undefined ? localStorage.getItem('recordId') : '';
        this.fetchAndDisplayImage();

        const style = document.createElement('style');
        style.innerText = `
                    .slds-col--padded.comm-content-header.comm-layout-column {
                        padding:0px !important;
                    }
                    .cCenterPanel  {
                        margin-top : 0px !important;
                    }
                    `;
        setTimeout(() => {
            this.template.querySelector('.overrideStyle').appendChild(style);
        }, 100);


         const thankyouStatus =  localStorage.getItem('isThankyou');
         if(this.forgetPass === 'true'){
            if (thankyouStatus == true) {
                // this.isThankyou = true;
            } else {
                localStorage.clear();
            }
         }
        
         // this.typewriterEffect();
        const isLoggedIn = localStorage.getItem('isLoggedIn');
        const employeeDetails = localStorage.getItem('EmployeeDetails');

        if (isLoggedIn === 'true') {
            // User is already logged in, navigate to the main page or show appropriate content.
            this.loginVisible = false;
            this.empdetailVisible = true;

            if (employeeDetails) {
                this.EmployeeDetails = JSON.parse(employeeDetails);
            }

        } else {
            //  this.loginVisible = true;
            this.empdetailVisible = false;
        }


        //if (localStorage.getItem('usernameLocalStorage') != undefined || localStorage.getItem('usernameLocalStorage') != '') {

        getUserRecordsDetails({ username: localStorage.getItem('usernameLocalStorage') })
            .then(result => {

                if (result) {
                    if (result.isLogin__c == false) {
                        // Handle the case where the query returned no rows
                        // localStorage.removeItem('isLoggedIn');
                        localStorage.clear();
                        this.loginVisible = true;
                        this.empdetailVisible = false;
                    }
                } else {
                    // Handle the case where the query returned no rows
                }

            })
            .catch(error => {
                console.error('error : ', error);
            });

        // }
        getNotificationInformation({ username: localStorage.getItem('usernameLocalStorage') })
        .then(result => {
                if (result) {
                        for(var i in result){
                                if(result[i].Type__c=='Banner'){
                                        this.bannerNotificationList.push(result[i]);
                                }else{
                                        this.sidepanelNotificationList.push(result[i]);
                                }
                                
                                
                        }
                } else {
                        // Handle the case where the query returned no rows
                }

        })
        .catch(error => {
                console.error('error : ', error);
        });
        // }


    }
    handleNewPasswordChange(event) {
        this.newPassword = event.target.value;
    }
    handleConfirmPasswordChange(event) {
        this.confirmPassword = event.target.value;
    }

    handleResetPassword() {
        // Reset the error message
        this.error = '';

        const newPassword = this.newPassword;
        const hasNumber = /\d/.test(newPassword);
        const hasUpperCase = /[A-Z]/.test(newPassword);
        const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(newPassword);


        if (newPassword.length < 8 || !hasNumber || !hasUpperCase || !hasSpecialChar) {
            this.error = 'Password must consist of at least 8 characters, including at least 1 number,1 capital letter and 1 Special character.';
        } else if (newPassword !== this.confirmPassword) {
            this.error = 'New Password and Confirm Password do not match.';
        } else {

            // Call the Apex method to update the password
            updatePassword({ username: this.username, newPassword: this.newPassword })
                .then(result => {
                    if (result === 'Password updated successfully') {
                        window.location.href = this.loginurl;
                        const toastEvent = new ShowToastEvent({
                            title: 'Success',
                            message: 'Password Reset Successfully.',
                            variant: 'success'
                        });
                        this.dispatchEvent(toastEvent);
                        this.resetForm = false;
                        this.loginVisible = false;
                        this.isThankyou = true;

                        localStorage.setItem('isThankyou', true);
                    } else {
                        const toastEvent = new ShowToastEvent({
                            title: 'Error',
                            message: 'Employee not found.',
                            variant: 'error'
                        });
                        this.dispatchEvent(toastEvent);
                        //  this.error = 'User not found.';
                        this.resetForm = true;
                        this.loginVisible = false;
                        this.empdetailVisible = false;
                    }

                })
                .catch(error => {
                    // Handle errors and display an error message
                    this.error = 'Error updating password: ' + error.message;
                });
        }

        if (!this.error) {
            this.resetForm = false;
            this.isThankyou = true;
            // this.loginVisible = true;
        }
    }

    showPasswordReset() {
        this.resetForm = false;
        this.loginVisible = true;
        this.showPasswordResetForm = true;
        this.tempusername = this.username
        this.username = '';
    }

    closePasswordReset() {
        this.usernameRequiredError = false;
        this.popupError = '';
        this.resetForm = false;
        this.showPasswordResetForm = false;
        this.loginVisible = true;
        // this.username = ''; // 13 oct
        this.username =  this.tempusername; // 13 oct
        
    }

    // Method to handle the password reset request
    handleResetClick() {
        this.error = '';
        if (!this.username) {
            this.usernameRequiredError = true;
            this.popupError = '';
        } else {

            getUserEmailAndSendEmail({ username: this.username })
                .then(result => {
                    if (result === 'Employee not found') {
                        this.error = 'Invalid username. Please enter a valid username.';
                    }
                    // Close the password reset form only if there is no error
                    if (!this.error) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Email sent successfully.',
                                variant: 'success'
                            })
                        );
                        this.closePasswordReset();
                    }
                })
                .catch(error => {
                    console.error('Error fetching email___________: ', error);
                    this.popupError = 'Invalid username.';
                });
        }
    }
    //end

    handleSignInClick() {
        this.error = '';

        if (!this.username && !this.password) {
            this.error = 'Please enter your username and password.';
        }
        else if (!this.username) {
            this.error = 'Please enter your username.';
        } else if (!this.password) {
            this.error = 'Please enter your password.';
        }
        else {
            getEmployeeByUsernameAndPassword({ username: this.username, password: this.password })

                .then(result => {
                    var parseData = JSON.parse(result);

                    if (parseData.status == 'success') {
                        localStorage.setItem('isLoggedIn', 'true');
                        localStorage.setItem('usernameLocalStorage', this.username);

                        // Employee found, do something with the data (e.g., navigate to another page)
                        
                        this.recordId = parseData.result.Id;
                        localStorage.setItem('recordId', this.recordId);
                        this.EmployeeName = parseData.result.Name;
                        // this.EmployeeEmail = parseData.result.Email__c;
                        this.EmployeeDetails = {
                            EmpName: this.EmployeeName,
                            EmpRecordId: parseData.result.Id,
                            EmpClockInOutStatus: parseData.result.Clocked_In_Out_Status__c,
                            EmpEmail: parseData.result.Email__c,
                            EmpRole: parseData.result.Role__c,
                            EmpContact: parseData.result.Emergency_Contact_No__c,
                            EmpAddress: parseData.result.Address__c,
                            EmpCode: parseData.result.EmpCode__c,
                            EmpDepartment: parseData.result.Department__c
                        }
                        // localStorage.setItem('EmployeeDetails', this.EmployeeDetails);
                        localStorage.setItem('EmployeeDetails', JSON.stringify(this.EmployeeDetails));
                        this.loginVisible = false;
                        this.empdetailVisible = true;
                        this.error = '';
                        // this.isDataLoad = true;
                    } else {
                        // Employee not found, show an error or take appropriate action
                        this.empdetailVisible = false;
                        this.error = 'Please enter correct username and password';

                    }
                })
                .catch(error => {
                    // Handle any errors that occurred during the call to the server
                    this.error = 'Something went wrong';
                    console.error('Error:', error);
                });
        }
    }

    updatechange(event) {
        this.EmployeeName = event.target.value;
        // this.EmployeeEmail = event.target.value;
    }
    updatedataset() {
        updateData({ recordId: this.recordId, Name: this.EmployeeName })
            .then(result => {
                console.error('result success:', result);
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }


    handleLogoutClick() {
        updateEmployeeRecord({ usernameId: this.username, isLogin: false })
            .then(result => {
            })
            .catch(error => {
                console.error('Error:', error);
            });
        localStorage.removeItem('isLoggedIn');
        localStorage.removeItem('usernameLocalStorage');
        localStorage.removeItem('EmployeeDetails');

        //  localStorage.clear();

        this.loginVisible = true;
        this.empdetailVisible = false;

        // localStorage.removeItem('isLoggedIn');

        this.username = '';
        this.password = '';
    }
    handleTimesheetLoaded(event){
        this.isLoading = false;
    }
    getDatefromCalender(event) {
        this.selectedDateFromCalendar = event.detail;
    }
    getDatefromDrs(event) {
        this.selectedDateFromDrs = event.detail;
    }

    
    async fetchAndDisplayImage() {
        const base64Data = await fetchImage({
            fileName: 'Employee Profile Photo',
            EmployeeId: this.recordId
        });
        if (base64Data == '') {
            this.profileImage = My_Image;
            this.isUploading = false; 
        } else {
            this.profileImage = 'data:image/jpeg;base64,' + base64Data;
            this.isUploading = false; 

        }
    }
    handleRedirect(event){
        console.log('handle redirect !!!!!!',event.detail.value);
        this.actionClick = !event.detail.value;
            this.annoucementClick = event.detail.value;
            this.requestDetailsClick = false;
            this.requesReportClick = false;
            this.dashboardClick = false;
            this.ticketHistoryClick = false;
            this.myProfileClick = false;
            this.attendanceClick = false;
    }

    handleLeftPanelButtonClick(event){
        if(event.detail.actionbutton == 'requestDetails'){
            this.actionClick = !event.detail.value;
            this.requestDetailsClick = event.detail.value;
            this.requesReportClick = false;
            this.dashboardClick = false;
            this.ticketHistoryClick = false;
            this.myProfileClick = false;
            this.attendanceClick = false;
            this.annoucementClick = false;
        }

        if(event.detail.actionbutton == 'Ticket_History'){
            this.actionClick = !event.detail.value;
            this.ticketHistoryClick = event.detail.value;
            this.requestDetailsClick = false;
            this.requesReportClick = false;
            this.dashboardClick = false;
            this.myProfileClick = false;
            this.attendanceClick = false;
            this.annoucementClick = false;
        }
        if(event.detail.actionbutton == 'dashboard'){
            this.actionClick = event.detail.value;
            this.requestDetailsClick = false;
            this.requesReportClick = false;
            this.dashboardClick = false;
            this.ticketHistoryClick = false;
            this.myProfileClick = false;
            this.attendanceClick = false;
            this.annoucementClick = false;
        }
          if(event.detail.actionbutton == 'pmddReportDetails'){
            this.actionClick = !event.detail.value;
            this.requesReportClick = event.detail.value;
            this.requestDetailsClick = false;
            this.dashboardClick = false;
            this.ticketHistoryClick = false;
            this.myProfileClick = false;
            this.attendanceClick = false;
            this.annoucementClick = false;
        }
        
        if(event.detail.actionbutton == 'myDashboard'){
            this.actionClick = !event.detail.value;
            this.requestDetailsClick = false;
            this.requesReportClick = false;
            this.dashboardClick = event.detail.value;
            this.ticketHistoryClick = false;
            this.myProfileClick = false;
            this.attendanceClick = false;
            this.annoucementClick = false;
        }

        if(event.detail.actionbutton == 'myProfile'){
            console.log('in login  page call');
            this.actionClick = !event.detail.value;
            this.myProfileClick = event.detail.value;
            this.requestDetailsClick = false;
            this.requesReportClick = false;
            this.dashboardClick = false;
            this.ticketHistoryClick = false;
            this.attendanceClick = false;
            this.annoucementClick = false;
        }
        
        if(event.detail.actionbutton == 'attendance'){
            // console.log('log in attendance');
            this.actionClick = !event.detail.value;
            this.attendanceClick = event.detail.value;
            this.requestDetailsClick = false;
            this.requesReportClick = false;
            this.dashboardClick = false;
            this.ticketHistoryClick = false;
            this.myProfileClick = false;
            this.annoucementClick = false;
        }

        if(event.detail.actionbutton == 'announcement'){
            //console.log('log in announcement');
            this.actionClick = !event.detail.value;
            this.annoucementClick = event.detail.value;
            this.requestDetailsClick = false;
            this.requesReportClick = false;
            this.dashboardClick = false;
            this.ticketHistoryClick = false;
            this.myProfileClick = false;
            this.attendanceClick = false;
        }
    }
}