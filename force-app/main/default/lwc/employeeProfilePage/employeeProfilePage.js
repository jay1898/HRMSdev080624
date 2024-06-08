import { LightningElement, track , api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

import fetchEmployeeData from '@salesforce/apex/EmployeeController.fetchEmployeeDetails';
import fetchEmpEduData from '@salesforce/apex/EmployeeController.fetchEmpEducationData';
import fetchEmpExpData from '@salesforce/apex/EmployeeController.fetchEmpExperienceData';
import getAllPicklistValues from '@salesforce/apex/EmployeeController.getAllPicklistValues';
import updateEmployeeData from '@salesforce/apex/EmployeeController.updateEmployeeDetails';
import updateEducationData from '@salesforce/apex/EmployeeController.updateEmpEducationData';
import updateExperianceData from '@salesforce/apex/EmployeeController.updateEmpExperianceData';
import deleteRecordData from '@salesforce/apex/EmployeeController.deleteRecordById';

export default class EmployeeProfilePage extends LightningElement {
    @track viewPrimary = true;
    @track editPrimary = false;

    @track viewContact = true;
    @track editContact = false;

    @track viewAddress = true;
    @track editAddress = false;

    @track viewEducation = true;
    @track editEducation = false;

    @track viewExperance = true;
    @track editExperance = false;

    @track viewSummary = true;
    @track editSummary = false;
    @track showDateError = false;


    @api employeeId;
    @track objectEmployee = 'Employee__c';

    @track employeeData;
    @track employeeEduData = [];
    @track employeeExpData = [];

    @track editedEmployeeData;
    @track editedEmployeeEduData = [];
    @track editedEmployeeExpData = [];

    @track picklistGender = [];
    @track picklistBloodGrp = [];
    @track picklistNationality = [];
    @track isEditable = false;

    @track showError = false;
    @track showPhoneError = false;
    @track showEduError = false;
    @track showExpError = false;
    @track errorEmpMessage = '';
    @track showExpErrorMsg = '';
    @track errorMessage = '';
    @track dateFieldNull = false;

    @track PreviousDate;
    @track currentDate;
    @track SelectedDOBDate;
    @track TodayDate;


    @track newRecStartDate;
    @track newRecEndDate;

    @track enableAddEduRow = false;
    @track enableAddExpRow = false;
    @track updatedEduRow = {};
    @track updatedExpRow = {};
    @track allExpFieldsValid = true;
    @track allEduFieldsValid = true;

    showEduSpinner = false;
    showExpSpinner = false;
    showEmpSpinner = false;

    @track educationColumns = [
        { label: 'Degree Name', fieldName: 'Degree_Name__c', editable: true },
        { label: 'University Name', fieldName: 'University_Name__c', editable: true },
        { label: 'Start Date', fieldName: 'Start_Date__c',editable: true, type: 'date-local' },
        { label: 'End Date', fieldName: 'End_Date__c',editable: true, type: 'date-local' },
        {label: 'Action',type: 'button',typeAttributes: {
                iconName: 'utility:delete',
                name: 'delete',
                variant: 'destructive'
            },
            cellAttributes: { alignment: 'left' }
        }
        
    ];

    @track experianceColumns = [
        { label: 'Designation', fieldName: 'Position__c', editable: true },
        { label: 'Company Name', fieldName: 'Company_Name__c', editable: true },
        { label: 'Company Location', fieldName: 'Company_Location__c', editable: true },
        { label: 'Join Date', fieldName: 'Join_Date__c',editable: true, type: 'date-local' },
        { label: 'Leave Date', fieldName: 'Leave_Date__c',editable: true, type: 'date-local' },
        {
            label: 'Action',
            type: 'button',
            typeAttributes: {
                iconName: 'utility:delete',
                
                name: 'delete',
                variant: 'destructive'
            },
            cellAttributes: { alignment: 'left' }
        }
        
    ];    

    connectedCallback() {
        this.getCurrentDateString();
        this.getAllPicklistValuesFunction();
        this.fetchEmployeeDetails();
        // console.log('employeeId-->>', this.employeeId);
    }

    getCurrentDateString() {
        const today = new Date();
        const yesterday = new Date();
        yesterday.setDate(today.getDate() - 1);

        const formatDate = (date) => {
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            return `${year}-${month}-${day}`;
        };

        this.currentDate = formatDate(today);
        this.previousDate = formatDate(yesterday);
    }

    // get currentDate() {
    //     const today = new Date();
    //     const year = today.getFullYear();
    //     let month = today.getMonth() + 1;
    //     let day = today.getDate();
    //     month = month < 10 ? '0' + month : month;
    //     day = day < 10 ? '0' + day : day;
    //     return `${year}-${month}-${day}`;
    // }

    //max={currentDate}

    getAllPicklistValuesFunction() {
        getAllPicklistValues()
            .then(result => {
                var resultData = JSON.parse(result);
                // // console.log('resultData-->>', JSON.parse(JSON.stringify(resultData)));
                // // console.log('resultData-->>', JSON.parse(JSON.stringify(resultData.Gender)));
                this.data = resultData.Data;
                for (var key in resultData.Gender) {
                    this.picklistGender.push({ "label": resultData.Gender[key], "value": key })
                }
                for (var key in resultData.BloodGroup) {
                    this.picklistBloodGrp.push({ "label": resultData.BloodGroup[key], "value": key })
                }
                for (var key in resultData.Nationality) {
                    this.picklistNationality.push({ "label": resultData.Nationality[key], "value": key })
                }
            });
            // console.log('this.picklistGender-->>', JSON.parse(JSON.stringify(this.picklistGender)));
            // console.log('this.picklistBloodGrp-->>', JSON.parse(JSON.stringify(this.picklistBloodGrp)));
            // console.log('this.picklistNationality-->>', JSON.parse(JSON.stringify(this.picklistNationality)));
            this.picklistGender = JSON.parse(JSON.stringify(this.picklistGender))
            this.picklistBloodGrp = JSON.parse(JSON.stringify(this.picklistBloodGrp))
            this.picklistNationality = JSON.parse(JSON.stringify(this.picklistNationality))
    }

    fetchEmployeeDetails() {
        if (!this.employeeId) {
            return;
        }
        fetchEmployeeData({ employeeId: this.employeeId })
            .then(result => {
                this.employeeData = result[0];
                console.log('this.employeeData@@@@@@@@@',this.employeeData);
                 console.log('this.employeeData-->>', JSON.parse(JSON.stringify(this.employeeData)));
            })
            .catch(error => {
                this.error = error;
                console.error('Error in fetching record data:', error);
            });
        // console.log('fetchEmpEduData-->>', this.employeeId);
        fetchEmpEduData({ employeeId: this.employeeId })
            .then(result => {
                this.employeeEduData = result;
                // console.log('this.employeeEduData-->>', JSON.parse(JSON.stringify(this.employeeEduData)));
            })
            .catch(error => {
                this.error = error;
                console.error('Error in fetching Education record data:', error);
            });

        fetchEmpExpData({ employeeId: this.employeeId })
            .then(result => {
                this.employeeExpData = result;
                // console.log('this.employeeExpData-->>', JSON.parse(JSON.stringify(this.employeeExpData)));
            })
            .catch(error => {
                this.error = error;
                console.error('Error in fetching Experiance record data:', error);
            });
    }


    get formattedDateOfBirth() {
        if (this.employeeData && this.employeeData.Date_of_Birth__c) {
            const dateParts = this.employeeData.Date_of_Birth__c.split('-');
            if (dateParts.length === 3) {
                const [year, month, day] = dateParts;
                return `${day}-${month}-${year}`;
            }
        }
        return '';
    }

    editPrimaryBtn(){
        this.editedEmployeeData = { ...this.employeeData };
        //this.viewPrimary = false;
        this.editPrimary = true;
    }
    editContactBtn(){
        this.editedEmployeeData = { ...this.employeeData };
        //this.viewContact = false;
        this.editContact = true;
    }
    editAddressBtn(){
        this.editedEmployeeData = { ...this.employeeData };
        //this.viewAddress = false;
        this.editAddress = true;
    }

    editExperianceBtn(){
        for (let record of this.employeeExpData) {
            // Create a new object for the converted record
            let convertedRecord = {
                Id: record.Id,
                Position__c: record.Position__c,
                Company_Name__c: record.Company_Name__c,
                Company_Location__c: record.Company_Location__c,
                Join_Date__c: record.Join_Date__c,
                Leave_Date__c: record.Leave_Date__c
            };
            this.editedEmployeeExpData.push(convertedRecord);
        }
        this.editExperance = true;
        this.enableAddExpRow = true;
        this.showExpError = false;
        this.showExpErrorMsg = '';
        this.allExpFieldsValid = true;
        this.updatedExpRow = {};
    }

    editSummaryBtn(){
        this.editedEmployeeData = { ...this.employeeData };
        //this.viewSummary = false;
        this.editSummary = true;
    }
    editEducationBtn(){
        for (let record of this.employeeEduData) {
            // Create a new object for the converted record
            let convertedRecord = {
                Id: record.Id,
                Degree_Name__c: record.Degree_Name__c,
                University_Name__c: record.University_Name__c,
                Start_Date__c: record.Start_Date__c,
                End_Date__c: record.End_Date__c
            };
            this.editedEmployeeEduData.push(convertedRecord);
        }
        this.editEducation = true;
        this.enableAddEduRow = true;
        this.showEduError = false;
        this.showEduErrorMsg = '';
        this.allEduFieldsValid = true;
        this.updatedEduRow = {};
    }

    hidePrimaryModal(){
        this.editPrimary = false;
        this.showDateError = false;
        // this.showError = false;
        // this.errorEmpMessage = '';
    }

    hideContactModal(){
        this.editContact = false;
    }

    hideAddressModal(){
        this.editAddress = false;
    }

    hideSummaryModal(){
        this.editSummary = false;
    }

    hideEduModal(){
        
        this.editEducation = false;
        this.editedEmployeeEduData = [];
    }

    hideExpModal(){
        this.editExperance = false;
        this.editedEmployeeExpData = [];
    }

    isValidPhoneNumber(phoneNumber) {
        const phoneRegex = /^[0-9]{10}$/;
        return phoneRegex.test(phoneNumber);
    }

    handleEmployeeChange(event) {
        this.errorEmpMessage = '';
        this.showError = false;
        let value = '';
        const field = event.target.dataset.field;
        console.log('field-->>', field);
        console.log('event.target.value-->>', event.target.value);

        if(field == "Date_of_Birth__c" && event.target.value == null){
            this.dateFieldNull = true;
            this.showDateError = true;
        }else if((field == "First_Name__c" || field == "Last_Name__c" || field == "Gender__c"  || field == "Date_of_Birth__c" || field == "Personal_Email__c" || field == "Emergency_Contact_No__c") && (event.target.value == null)){
            this.showError= true;
            this.errorEmpMessage = 'Required! fields are must not null or empty.';
            this.handleValidationErrors('Error', 'Required! fields are must not null or empty.' , 'error');
        }else{
          //  this.showDateError = false;
        }


        if(event.target.value != null || event.target.value != ''){
        value = event.target.value.replace(/<[^>]*>/g, '').trim();
        console.log('value', value);
         }
        
     
        if(field == "Date_of_Birth__c" && event.target.value != null){
            console.log('field-->>');
            this.TodayDate = new Date();
            this.SelectedDOBDate = new Date(value);
            console.log('this.SelectedDOBDate',this.SelectedDOBDate);
            this.dateFieldNull = false;

        }

        

        // console.log('this.TodayDate',this.TodayDate);
        // console.log('this.SelectedDOBDate',this.SelectedDOBDate);
        
        if (this.SelectedDOBDate != null && this.SelectedDOBDate != undefined){
            console.log('field-->10>');

            if (this.SelectedDOBDate > this.TodayDate || this.SelectedDOBDate.toDateString() == this.TodayDate.toDateString()) {
                    console.log('field-->11>');
                    this.dateFieldNull = false;
                    this.showDateError = true;
                    // this.showError = true;
                    // this.errorEmpMessage = 'Date of Birth cannot be a current date and future date.';
                    // this.handleValidationErrors('Error', this.errorEmpMessage, 'error');
                    // Exit the function to prevent further processing
            }else{
                this.showDateError = false;
                console.log('field-->12>');
            }

        }else if ((field == "First_Name__c" || field == "Last_Name__c" || field == "Gender__c"  || field == "Date_of_Birth__c" || field == "Personal_Email__c" || field == "Emergency_Contact_No__c" ) && (value == null || value == '' )){
            console.log('field-->>', field);
            console.log('event.target.value-->>', event.target.value);
            this.showError= true;
            this.errorEmpMessage = 'Required! fields are must not null or empty.';
            this.handleValidationErrors('Error', 'Required! fields are must not null or empty.' , 'error');
        }

        if (field == "Emergency_Contact_No__c" && !this.isValidPhoneNumber(value) ){
            this.showPhoneError= true;
        }else{
            this.showPhoneError= false;
        }

        if(field == "Physically_Handicap__c"  || field == "Marital_Status__c" ){
            this.editedEmployeeData[field] = event.target.checked;
        }else{
            this.editedEmployeeData[field] = event.target.value;
        }

        if(field == "Professional_Summary__c"){
            let profSummary = value.replace(/<[^>]*>/g, '');
            if(profSummary.length > 1000 ){
                this.showError= true;
                this.errorEmpMessage = 'Please limit your input to 1000 characters.';
                this.handleValidationErrors('Warning', this.errorEmpMessage , 'warning');
            }
            if(!profSummary ){
                this.showError= true;
                this.errorEmpMessage = 'Input is required for saving the record.';
                this.handleValidationErrors('Error', this.errorEmpMessage , 'error');
            }
        }

        if(field == "Address__c"){
            if(!value){
                this.showError= true;
                this.errorEmpMessage = 'Input is required for saving the record.';
                this.handleValidationErrors('Error', this.errorEmpMessage , 'error');
            }
        }
        
    }
    
    handleExperianceChange(event) {
        const field = event.target.dataset.expfield;
        this.editedEmployeeExpData[field] = event.target.value;
    }

    

    saveEmployeeDetails(){
        console.log('this.showError-->>', this.showError);
        console.log('this.errorEmpMessage-->>', this.errorEmpMessage);
        
        if (this.showDateError && this.editPrimary) {
            this.handleValidationErrors('Error', 'Date of Birth cannot be a current date and future date' , 'error');
            return;
        }

        if (this.dateFieldNull && this.editPrimary) {
            this.handleValidationErrors('Error', 'Date of Birth cannot be a current date and future date' , 'error');
            return;
        }

        if (!this.editedEmployeeData.First_Name__c && this.editPrimary) {
            this.handleValidationErrors('Error', 'First Name is required.', 'error');
            return;
        }

        
        if (!this.editedEmployeeData.Last_Name__c && this.editPrimary) {
            this.handleValidationErrors('Error', 'Last Name is required.', 'error');
            return;
        }
        

        // Check if First Name contains only spaces
    if (this.editedEmployeeData.First_Name__c && this.editedEmployeeData.First_Name__c.trim().length === 0 && this.editPrimary) {
        this.handleValidationErrors('Error', 'First Name cannot be empty', 'error');
        return;
    }

       // Check if First Name contains only spaces
       if (this.editedEmployeeData.Last_Name__c && this.editedEmployeeData.Last_Name__c.trim().length === 0 && this.editPrimary) {
        this.handleValidationErrors('Error', 'Last Name cannot be empty', 'error');
        return;
    }

    


        console.log('this.this.editedEmployeeData.Date_of_Birth__c-->>', this.editedEmployeeData.Date_of_Birth__c);

        if (!this.editedEmployeeData.Date_of_Birth__c && this.editPrimary) {
            this.handleValidationErrors('Error', 'Date of Birth is required.', 'error');
            return;
        }

        // Check if First Name contains only spaces
        if (this.editedEmployeeData.Emergency_Contact_No__c && this.editedEmployeeData.Emergency_Contact_No__c.trim().length != 10 && this.editContact) {
            this.handleValidationErrors('Error', 'Phone no. must have 10 digit', 'error');
             return;
        }

        if(this.showPhoneError && this.editContact){
            this.handleValidationErrors('Error', 'Phone no. must have 10 digit' , 'error');
            return;
        }


        if (!this.editedEmployeeData.Emergency_Contact_No__c && this.editContact) {
            this.handleValidationErrors('Error', 'Phone is required.', 'error');
            return;
        }

        if(this.showError && (this.errorEmpMessage!= null || this.errorEmpMessage!=undefined)){
            console.log('this.errorEmpMessage-->>', this.errorEmpMessage);
            this.handleValidationErrors('Error', this.errorEmpMessage , 'error');
            return;
        }
        if(!this.showError){
            // console.log('employeeData-->>', JSON.parse(JSON.stringify(this.editedEmployeeData)));
            updateEmployeeData({ employeeData: this.editedEmployeeData })
            .then(result => {
                // console.log('result-->>', JSON.parse(JSON.stringify(result)));
                this.editedEmployeeEduData = [];
                this.fetchEmployeeDetails();
                this.handleValidationErrors('Success', 'Employee Details are Updated.', 'success');
            })
            .catch(error => {
                // Handle error
                this.error = error;
                console.error('Error in updating record data:', error);
            });

            this.editPrimary = false;
            this.editContact = false;
            this.editAddress = false;
            this.editSummary = false;
            this.editEducation = false;
            this.editExperance = false;
            this.showError = false;
            this.showPhoneError = false;
            this.showDateError = false;
            this.dateFieldNull = false;

        }
       
    }

    validateData(objName, updatedRecordData) {
        let allRecordsValid = true;
        if (objName === 'Employee_Education__c') {
        
            updatedRecordData.forEach(row => {
                let isDataValid = true;
                console.log('this.row-->>', row);
                console.log('row.Id.length-->>', row.Id.length);
                if(row.hasOwnProperty('Id') && row.Id.length < 7 ){
                    if (!row.hasOwnProperty('Degree_Name__c') || (row.Degree_Name__c === null || row.Degree_Name__c.trim() === '')) {
                        isDataValid = false;
                    }
                    if (!row.hasOwnProperty('University_Name__c') || (row.University_Name__c === null || row.University_Name__c.trim() === '')) {
                        isDataValid = false;
                    }
                    if (!row.hasOwnProperty('Start_Date__c') || (row.Start_Date__c === null || row.Start_Date__c.trim() === '')) {
                        isDataValid = false;
                    }
                    if (!row.hasOwnProperty('End_Date__c') || (row.End_Date__c === null || row.End_Date__c.trim() === '')) {
                        isDataValid = false;
                    }
                }else{
                    if (row.hasOwnProperty('Degree_Name__c') && (row.Degree_Name__c === null || row.Degree_Name__c.trim() === '')) {
                        isDataValid = false;
                    }
                    if (row.hasOwnProperty('University_Name__c') && (row.University_Name__c === null || row.University_Name__c.trim() === '')) {
                        isDataValid = false;
                    }
                    if (row.hasOwnProperty('Start_Date__c') && (row.Start_Date__c === null || row.Start_Date__c.trim() === '')) {
                        isDataValid = false;
                    }
                    if (row.hasOwnProperty('End_Date__c') && (row.End_Date__c === null || row.End_Date__c.trim() === '')) {
                        isDataValid = false;
                    }
                }
                if (!isDataValid) {
                    allRecordsValid = false;
                }
            });
        }
        if (objName === 'Employee_Experience__c') {

            updatedRecordData.forEach(row => {
                let isDataValid = true;
                console.log('this.row-->>', row);
                console.log('row.Id.length-->>', row.Id.length);
                if(row.hasOwnProperty('Id') && row.Id.length < 7 ){
                    console.log('this.row.Id -->>', row.Id);
                    if (!row.hasOwnProperty('Position__c') || (row.Position__c === null || row.Position__c.trim() === '')) {
                        isDataValid = false;
                    }
                    if (!row.hasOwnProperty('Company_Name__c') || (row.Company_Name__c === null || row.Company_Name__c.trim() === '')) {
                        isDataValid = false;
                    }
                    if (!row.hasOwnProperty('Company_Location__c') || (row.Company_Location__c === null || row.Company_Location__c.trim() === '')) {
                        isDataValid = false;
                    }
                    if (!row.hasOwnProperty('Join_Date__c') || (row.Join_Date__c === null || row.Join_Date__c.trim() === '')) {
                        isDataValid = false;
                    }
                    if (!row.hasOwnProperty('Leave_Date__c') || (row.Leave_Date__c === null || row.Leave_Date__c.trim() === '')) {
                        isDataValid = false;
                    }
                }else{
                    console.log('this.row.Id ELSE -->>', row.Id);
                    console.log('(row.hasOwnProperty(Position__c) -->>',(row.hasOwnProperty('Position__c')));
                    if (row.hasOwnProperty('Position__c') && (row.Position__c === null || row.Position__c.trim() === '')) {
                        isDataValid = false;
                    }
                    console.log('(row.hasOwnProperty(Company_Name__c) -->>',(row.hasOwnProperty('Company_Name__c')));
                    if (row.hasOwnProperty('Company_Name__c') && (row.Company_Name__c === null || row.Company_Name__c.trim() === '')) {
                        isDataValid = false;
                    }
                    console.log('(row.hasOwnProperty(Company_Location__c) -->>',(row.hasOwnProperty('Company_Location__c')));
                    if (row.hasOwnProperty('Company_Location__c') && (row.Company_Location__c === null || row.Company_Location__c.trim() === '')) {
                        isDataValid = false;
                    }
                    console.log('(row.hasOwnProperty(Join_Date__c) -->>',(row.hasOwnProperty('Join_Date__c')));
                    if (row.hasOwnProperty('Join_Date__c') && (row.Join_Date__c === null || row.Join_Date__c.trim() === '')) {
                        isDataValid = false;
                    }
                    console.log('(row.hasOwnProperty(Leave_Date__c) -->>',(row.hasOwnProperty('Leave_Date__c')));
                    if (row.hasOwnProperty('Leave_Date__c') && (row.Leave_Date__c === null || row.Leave_Date__c.trim() === '')) {
                        isDataValid = false;
                    }
                   
                }
                console.log('isDataValid -->>',isDataValid);
                if (!isDataValid) {
                    allRecordsValid = false;
                }
            });
        }
        console.log('allRecordsValid -->>',allRecordsValid);
        if (!allRecordsValid) {
            this.handleValidationErrors('Error', 'Please ensure that all fields are completed.', 'error');
        }
        console.log('allRecordsValid 2  -->>',allRecordsValid);
        // Return the validation result
        return allRecordsValid;
    }



    handleExpCellChange(event) {
        this.showExpError = false;
        this.showExpErrorMsg = '';
        
        event.detail.draftValues.forEach(updatedRow => {
            const rowIndex = this.editedEmployeeExpData.findIndex(row => row.Id === updatedRow.Id);
            if (rowIndex !== -1) {
                Object.keys(updatedRow).forEach(fieldName => {
                    const cellValue = updatedRow[fieldName].replace(/<[^>]*>/g, '').trim();
                    if (!cellValue) {
                        this.showExpError= true;
                        this.showExpErrorMsg = 'Please ensure that all fields are completed.';
                        this.handleValidationErrors('Error', this.showExpErrorMsg , 'error');
                        return;
                    } else {
                        if (fieldName == 'Join_Date__c' || fieldName == 'Leave_Date__c') {
                            let startDate;
                            if(fieldName == 'Join_Date__c'){
                                startDate = cellValue;
                            } 
                            else if (this.editedEmployeeExpData[rowIndex] && this.editedEmployeeExpData[rowIndex].Join_Date__c){
                                startDate = this.editedEmployeeExpData[rowIndex].Join_Date__c;
                            }
                            let endDate;
                            if(fieldName == 'Leave_Date__c'){
                                endDate = cellValue;
                            } 
                            else if (this.editedEmployeeExpData[rowIndex] && this.editedEmployeeExpData[rowIndex].Leave_Date__c) {
                                endDate = this.editedEmployeeExpData[rowIndex].Leave_Date__c;
                            }

                            if (fieldName === 'Join_Date__c' && startDate > this.currentDate) {
                                this.showExpError= true;
                                this.showExpErrorMsg = 'Join date/Leave date cannot be a future date or Leave date cannot be before the Join date.';
                                this.handleValidationErrors('Error', this.showExpErrorMsg , 'error');
                                return;
                            }
                            if(fieldName === 'Join_Date__c' && (endDate != null && (endDate < startDate || endDate > this.currentDate))){
                                this.showExpError= true;
                                this.showExpErrorMsg = 'Join date/Leave date cannot be a future date or Leave date cannot be before the Join date.';
                                this.handleValidationErrors('Error', this.showExpErrorMsg , 'error');
                                return;
                            }
                            if (fieldName === 'Leave_Date__c' && (endDate > this.currentDate || endDate < startDate)) {
                                // console.log('Validation 2:-->>');
                                this.showExpError= true;
                                this.showExpErrorMsg = 'Join date/Leave date cannot be a future date or Leave date cannot be before the Join date.';
                                this.handleValidationErrors('Error', this.showExpErrorMsg , 'error');
                                return;
                            }
                        }
                    }
                });
            }else{
                Object.keys(updatedRow).forEach(fieldName => {
                    const cellValue = updatedRow[fieldName];
                    if (!cellValue) {
                        //this.showExpError= true;
                        this.showExpErrorMsg = 'Please ensure that all fields are completed.';
                        this.handleValidationErrors('Error', this.showExpErrorMsg , 'error');
                        return;
                    } else {
                        if (fieldName == 'Join_Date__c' || fieldName == 'Leave_Date__c') {
                            let startDate;
                            if(fieldName == 'Join_Date__c'){
                                startDate = cellValue;
                                this.newRecStartDate  = cellValue;
                            }
                            else{
                                if(this.updatedExpRow.hasOwnProperty('Join_Date__c')){
                                    if(this.updatedExpRow['Join_Date__c'] !== null && this.updatedExpRow['Join_Date__c'] !== ''){
                                        this.newRecStartDate  = this.updatedExpRow['Join_Date__c'];
                                    }
                                }else{
                                    this.newRecStartDate  = null;
                                }
                            }
                            let endDate;
                            if(fieldName == 'Leave_Date__c'){
                                endDate = cellValue;
                                this.newRecEndDate  = cellValue;
                            }else{
                                if(this.updatedExpRow.hasOwnProperty('Leave_Date__c')){
                                    if(this.updatedExpRow['Leave_Date__c'] !== null && this.updatedExpRow['Leave_Date__c'] !== ''){
                                        this.updatedExpRow  = this.updatedExpRow['Leave_Date__c'];
                                    }
                                }else{
                                        this.newRecEndDate = null;
                                        console.log('this.newRecEndDate3:-->>',this.updatedExpRow);
                                    }
                            }
                            if (fieldName === 'Join_Date__c' && (this.newRecStartDate  > this.currentDate) 
                            ) {
                                this.showExpError= true;
                                this.allExpFieldsValid = false;
                                this.showExpErrorMsg = 'Join date/Leave date cannot be a future date or Leave date cannot be before the Join date.';
                                this.handleValidationErrors('Error', this.showExpErrorMsg , 'error');
                                return;
                            }
                            else if(fieldName === 'Join_Date__c' && (this.newRecEndDate != null && (this.newRecEndDate < this.newRecStartDate  || this.newRecEndDate > this.currentDate))){
                                this.showExpError= true;
                                this.allExpFieldsValid = false;
                                this.showExpErrorMsg = 'Join date/Leave date cannot be a future date or Leave date cannot be before the Join date.';
                                this.handleValidationErrors('Error', this.showExpErrorMsg , 'error');
                                return;
                            }
                            else if(fieldName === 'Leave_Date__c' && (this.newRecEndDate > this.currentDate || (this.newRecStartDate && this.newRecEndDate <  this.newRecStartDate))) {
                                this.showExpError= true;
                                this.allExpFieldsValid = false;
                                this.showExpErrorMsg = 'Join date/Leave date cannot be a future date or Leave date cannot be before the Join date.';
                                this.handleValidationErrors('Error', this.showExpErrorMsg , 'error');
                                return;
                            }else{
                                this.allExpFieldsValid = true;
                                this.showExpError= false;
                                this.showExpErrorMsg = '';
                            }
                        }
                    }
                    this.updatedExpRow = {...this.updatedExpRow ,...updatedRow};
                    console.log('this.updatedExpRow handle>>', this.updatedExpRow);
                });
            }
        });
    }

    handleEduCellChange(event) {
        this.showEduError = false;
        this.showEduErrorMsg = '';
        
        event.detail.draftValues.forEach(updatedRow => {
            const rowIndex = this.editedEmployeeEduData.findIndex(row => row.Id === updatedRow.Id);
            if (rowIndex !== -1) {
                Object.keys(updatedRow).forEach(fieldName => {
                    const cellValue = updatedRow[fieldName].replace(/<[^>]*>/g, '').trim();
                    if (!cellValue) {
                        this.showEduError= true;
                        this.showEduErrorMsg = 'Please ensure that all fields are completed.';
                        this.handleValidationErrors('Error', this.showEduErrorMsg , 'error'); 
                        return;
                    } else {
                        if (fieldName == 'Start_Date__c' || fieldName == 'End_Date__c') {
                            
                            let startDate;
                            if(fieldName == 'Start_Date__c'){
                                startDate = cellValue;
                                //this.newRecStartDate  = cellValue;
                            }
                            else if (this.editedEmployeeEduData[rowIndex] && this.editedEmployeeEduData[rowIndex].Start_Date__c){
                                startDate = this.editedEmployeeEduData[rowIndex].Start_Date__c;
                                //this.newRecStartDate  = startDate;
                            }
                            let endDate;
                            if(fieldName == 'End_Date__c'){
                                endDate = cellValue;
                                //this.newRecEndDate  = cellValue;
                            } 
                            else if (this.editedEmployeeEduData[rowIndex] && this.editedEmployeeEduData[rowIndex].End_Date__c) {
                                endDate = this.editedEmployeeEduData[rowIndex].End_Date__c;
                                //this.newRecEndDate  = endDate;
                            }
                            if (fieldName === 'Start_Date__c' && startDate > this.currentDate) {
                                this.showEduError= true;
                                this.showEduErrorMsg = 'Start date/End date cannot be a future date or End date cannot be before the Start date.';
                                this.handleValidationErrors('Error', this.showEduErrorMsg , 'error');
                                return;
                            }
                            if(fieldName === 'Start_Date__c' && (endDate != null && (endDate < startDate || endDate > this.currentDate))){
                                this.showEduError= true;
                                this.showEduErrorMsg = 'Start date/End date cannot be a future date or End date cannot be before the Start date.';
                                this.handleValidationErrors('Error', this.showEduErrorMsg , 'error');
                                return;
                            }
                            if (fieldName === 'End_Date__c' && (endDate > this.currentDate || endDate < startDate)) {
                                this.showEduError= true;
                                this.showEduErrorMsg = 'Start date/End date cannot be a future date or End date cannot be before the Start date.';
                                this.handleValidationErrors('Error', this.showEduErrorMsg , 'error');
                                return;
                            }
                        }
                    }
                });
            }else{
                Object.keys(updatedRow).forEach(fieldName => {
                    const cellValue = updatedRow[fieldName].replace(/<[^>]*>/g, '').trim();
                    if (!cellValue) {
                        //this.showEduError= true;
                        this.showEduErrorMsg = 'Please ensure that all fields are completed.';
                        this.handleValidationErrors('Error', this.showEduErrorMsg , 'error');
                        return;
                    } else {
                        if (fieldName == 'Start_Date__c' || fieldName == 'End_Date__c') {
                            let startDate;
                            if(fieldName == 'Start_Date__c'){
                                startDate = cellValue;
                                this.newRecStartDate  = cellValue;
                            }
                            else{
                                if(this.updatedEduRow.hasOwnProperty('Start_Date__c')){
                                    if(this.updatedEduRow['Start_Date__c'] !== null && this.updatedEduRow['Start_Date__c'] !== ''){
                                        this.newRecStartDate  = this.updatedEduRow['Start_Date__c'];
                                    }
                                }else{
                                    this.newRecStartDate  = null;
                                }
                            }
                            let endDate;
                            if(fieldName == 'End_Date__c'){
                                endDate = cellValue;
                                this.newRecEndDate  = cellValue;
                            }else{
                                if(this.updatedEduRow.hasOwnProperty('End_Date__c')){
                                    if(this.updatedEduRow['End_Date__c'] !== null && this.updatedEduRow['End_Date__c'] !== ''){
                                        this.newRecEndDate  = this.updatedEduRow['End_Date__c'];
                                    }
                                }else{
                                        this.newRecEndDate = null;
                                    }
                            }
                            if (fieldName === 'Start_Date__c' && (this.newRecStartDate  > this.currentDate)) {
                                this.showEduError= true;
                                this.allEduFieldsValid = false;
                                this.showEduErrorMsg = 'Start date/End date cannot be a future date or End date cannot be before the Start date.';
                                this.handleValidationErrors('Error', this.showEduErrorMsg , 'error');
                                return;
                            }
                            else if(fieldName === 'Start_Date__c' && (this.newRecEndDate != null && (this.newRecEndDate < this.newRecStartDate  || this.newRecEndDate > this.currentDate))){
                                this.showEduError= true;
                                this.allEduFieldsValid = false;
                                this.showEduErrorMsg = 'Start date/End date cannot be a future date or End date cannot be before the Start date.';
                                this.handleValidationErrors('Error', this.showEduErrorMsg , 'error');
                                return;
                            }
                            else if (fieldName === 'End_Date__c' && (this.newRecEndDate > this.currentDate || (this.newRecStartDate && this.newRecEndDate < this.newRecStartDate ))) {
                                this.showEduError= true;
                                this.allEduFieldsValid = false;
                                this.showEduErrorMsg = 'Start date/End date cannot be a future date or End date cannot be before the Start date.';
                                this.handleValidationErrors('Error',this.showEduErrorMsg , 'error');
                                return;
                            }else{
                                this.allEduFieldsValid = true;
                                this.showEduError= false;
                                this.showEduErrorMsg = '';
                            }
                        }
                    }
                    this.updatedEduRow = {...this.updatedEduRow ,...updatedRow};
                });
            }
        });
        
    }

    saveEducationDetails(event){
        console.log('this.allEduFieldsValid-->>', this.allEduFieldsValid);
       if(this.showEduError || !this.allEduFieldsValid){
            this.handleValidationErrors('Error', 'Any of date cannot be a future date or End date cannot be before the Start date.', 'error');
            return;
        }
        // else if(!this.allEduFieldsValid){
        //     this.handleValidationErrors('Error', 'Start date/End date cannot be a future date or End date cannot be before the Start date.', 'error');
        //    // this.showEduSpinner = false;
        //     return;
        // }
        else{
             console.log('ELSE');
            this.showEduSpinner = true;
             let allDataValid = true;
            let updatedRecord = event.detail.draftValues;
            updatedRecord.forEach(record => {
                const existingRecord = this.editedEmployeeEduData.find(item => item.Id === record.Id);
                if (!existingRecord) {
                    //updatedRecords.push(record);
                    console.log('updatedRecord-->>', JSON.parse(JSON.stringify(updatedRecord)));
                    allDataValid = this.validateData('Employee_Education__c', updatedRecord);
                    if (allDataValid == false) {
                        console.log('!this.validateData(Employee_Education__c, updatedRecord)-->>', !this.validateData('Employee_Education__c', updatedRecord));
                        this.showEduSpinner = false;
                        return;
                    }
                }
            });
            if(allDataValid){
                const modifiedEduData = updatedRecord.map(record => {
                    return { ...record, Employee__c: this.employeeId };
                });
                // console.log('modifiedEduData-->>', JSON.parse(JSON.stringify(modifiedEduData)));
                updateEducationData({ jsonData: JSON.stringify(modifiedEduData) })
                    .then(result => {
                        this.fetchEmployeeDetails();
                        this.showEduSpinner = false;
                        this.handleValidationErrors('Success', 'Employee\'s Education Details are Updated.', 'success');
                        this.editedEmployeeEduData = [];
                        this.editEducation = false;
                        this.newRecEndDate ='';
                        this.newRecStartDate = '';
                        this.updatedEduRow = {};
                    })
                    .catch(error => {
                        // Handle error
                        this.error = error;
                        console.error('Error in updating record data:', error);
                    });
            }
            
        }
         console.log('END');
         this.showEduError = false;

    }

    saveExperianceDetails(event){

        console.log('this.allExpFieldsValid-->>', this.allExpFieldsValid);
        if(this.showExpError || !this.allExpFieldsValid){
            this.handleValidationErrors('Error', 'Join date/Leave date cannot be null or future date or Leave date cannot be before the Join date.', 'error');
            return;
        }
        else{
             console.log('ELSE');
             let allDataValid = true;
            this.showExpSpinner = true;
            let updatedRecord = event.detail.draftValues;
            updatedRecord.forEach(record => {
                const existingRecord = this.editedEmployeeExpData.find(item => item.Id === record.Id);
                if (!existingRecord) {
                    //updatedRecords.push(record);
                    allDataValid = this.validateData('Employee_Experience__c', updatedRecord);
                    console.log('allDataValid Save-->>', allDataValid);
                    if (allDataValid == false) {
                        this.showExpSpinner = false;
                        //this.handleValidationErrors('Error', 'Join date/Leave date cannot be null or future date or Leave date cannot be before the Join date.', 'error');
                        return;
                    }
                }
            });
            console.log('allDataValid Save 2-->>', allDataValid);
            if(allDataValid){
                const modifiedExpData = updatedRecord.map(record => {
                    return { ...record, Employee__c: this.employeeId };
                });
                // console.log('modifiedExpData-->>', JSON.parse(JSON.stringify(modifiedExpData)));
                updateExperianceData({ jsonData: JSON.stringify(modifiedExpData) })
                    .then(result => {
                        this.fetchEmployeeDetails();
                        this.showExpSpinner = false;
                        this.handleValidationErrors('Success', 'Employee\'s Experience Details are Updated.', 'success');
                        this.editedEmployeeExpData = [];
                        this.editExperance = false;
                        //this.showExpErrorMsg = ''; 
                        this.newRecEndDate ='';
                        this.newRecStartDate = '';
                        this.updatedExpRow = {};
                    })
                    .catch(error => {
                        // Handle error
                        this.error = error;
                        console.error('Error in updating record data:', error);
                    });
            }
            
        }
        this.showExpError= false;
        //this.showExpSpinner = false;
    }

    handleEduAddRow() {

         console.log('this.updatedEduRow>>', this.updatedEduRow);
        let requiredKeys = ["University_Name__c", "Id", "Degree_Name__c", "Start_Date__c", "End_Date__c"];
        console.log('Object.keys(this.updatedEduRow).length>>', Object.keys(this.updatedEduRow).length);
        if (Object.keys(this.updatedEduRow).length !== 0) {
            let hasBlankRow = requiredKeys.every(key => {
               
                            if(this.updatedEduRow.hasOwnProperty('Start_Date__c') && this.updatedEduRow.hasOwnProperty('End_Date__c')){
                                if (this.updatedEduRow['Start_Date__c']  > this.currentDate ) {
                                    console.log('val1>>', this.updatedEduRow['Start_Date__c']  > this.currentDate);
                                    this.handleValidationErrors('Error', 'Start date/End date cannot be a future date or End date cannot be before the Start date.' , 'error');
                                    return;
                                }
                                else if(this.updatedEduRow['Start_Date__c'] != null && (this.updatedEduRow['Start_Date__c'] > this.updatedEduRow['End_Date__c']  || this.updatedEduRow['End_Date__c'] > this.currentDate)){
                                    console.log('Val2>>', (this.updatedEduRow['Start_Date__c'] < this.updatedEduRow['End_Date__c'] ));
                                    this.handleValidationErrors('Error', 'Start date/End date cannot be a future date or End date cannot be before the Start date.' , 'error');
                                    return;
                                }
                                else if ((this.updatedEduRow['End_Date__c'] > this.currentDate) || (this.updatedEduRow['End_Date__c'] < this.updatedEduRow['Start_Date__c'] )) {
                                    console.log('Val3>>', (this.updatedEduRow['End_Date__c'] > this.currentDate || (this.updatedEduRow['Start_Date__c'] && this.updatedEduRow['End_Date__c'] < this.updatedEduRow['Start_Date__c'] )));
                                    this.handleValidationErrors('Error','Start date/End date cannot be a future date or End date cannot be before the Start date.' , 'error');
                                    return;
                                }else{
                                    this.showEduError= false;
                                    this.allEduFieldsValid = true;
                                    this.showEduErrorMsg = '';
                                }
                            }
                            
                            return this.updatedEduRow.hasOwnProperty(key) && this.updatedEduRow[key] !== null && this.updatedEduRow[key] !== '';
                        });
            console.log('hasBlankRow>>', hasBlankRow); // corrected typo here
            if (!hasBlankRow) {
                return;
            }
        }
        else{
            let hasBlankRow = this.editedEmployeeEduData.some(row => 
                Object.values(row).some(value => value === null || value === '')
            );   
            if(hasBlankRow){
                return;
            }
        }
        if(this.showEduError){
            return;
        }
        
        let newRow = { Degree_Name__c: '',University_Name__c: '',Start_Date__c: '', End_Date__c: '' };
        this.editedEmployeeEduData = [...this.editedEmployeeEduData, newRow];
        this.updatedEduRow={};
    
        
        //this.enableAddEduRow = false;
            
        
    }

    handleExpAddRow() {

        console.log('this.updatedExpRow>>', this.updatedExpRow);
        let requiredKeys = ["Position__c", "Id", "Company_Name__c", "Company_Location__c", "Join_Date__c", "Leave_Date__c"];
        console.log('Object.keys(this.updatedExpRow).length>>', Object.keys(this.updatedExpRow).length);
        if (Object.keys(this.updatedExpRow).length !== 0) {
            let hasBlankRow = requiredKeys.every(key => {
            
                            if(this.updatedExpRow.hasOwnProperty('Join_Date__c') && this.updatedExpRow.hasOwnProperty('Leave_Date__c')){
                                if (this.updatedExpRow['Join_Date__c']  > this.currentDate ) {
                                    console.log('val1>>', this.updatedExpRow['Join_Date__c']  > this.currentDate);
                                    this.handleValidationErrors('Error', 'Join date/Leave date cannot be a future date or Leave date cannot be before the Join date.' , 'error');
                                    return;
                                }
                                else if(this.updatedExpRow['Join_Date__c'] != null && (this.updatedExpRow['Join_Date__c'] > this.updatedExpRow['Leave_Date__c']  || this.updatedExpRow['Leave_Date__c'] > this.currentDate)){
                                    console.log('Val2>>', (this.updatedExpRow['Join_Date__c'] < this.updatedExpRow['Leave_Date__c'] ));
                                    this.handleValidationErrors('Error', 'Join date/Leave date cannot be a future date or Leave date cannot be before the Join date.' , 'error');
                                    return;
                                }
                                else if ((this.updatedExpRow['Leave_Date__c'] > this.currentDate) || (this.updatedExpRow['Leave_Date__c'] < this.updatedExpRow['Join_Date__c'] )) {
                                    console.log('Val3>>', (this.updatedExpRow['Leave_Date__c'] > this.currentDate || (this.updatedExpRow['Join_Date__c'] && this.updatedExpRow['Leave_Date__c'] < this.updatedExpRow['Join_Date__c'] )));
                                    this.handleValidationErrors('Error','Join date/Leave date cannot be a future date or Leave date cannot be before the Join date.' , 'error');
                                    return;
                                }else{
                                    this.showExpError= false;
                                    this.allExpFieldsValid = true;
                                    this.showExpErrorMsg = '';
                                }
                            }
                            
                            return this.updatedExpRow.hasOwnProperty(key) && this.updatedExpRow[key] !== null && this.updatedExpRow[key] !== '';
                        });
            console.log('hasBlankRow>>', hasBlankRow); // corrected typo here
            if (!hasBlankRow) {
                return;
            }
        }
        else{
            let hasBlankRow = this.editedEmployeeExpData.some(row => 
                Object.values(row).some(value => value === null || value === '')
            );   
            if(hasBlankRow){
                return;
            }
        }
        if(this.showEduError){
            return;
        }
        
        let newRow = { Position__c: '',Company_Name__c: '',Company_Location__c: '',Join_Date__c: '', Leave_Date__c: '' };
        this.editedEmployeeExpData = [...this.editedEmployeeExpData, newRow];
        this.updatedExpRow={};
    }

    handleCancel(event) {
        this.isEditable = false;

        this.editExperance = false;
        this.editedEmployeeExpData = [];
        this.updatedExpRow={};

        this.editEducation = false;
        this.editedEmployeeEduData = [];
        this.updatedEduRow={};
        
    }

    handleDelEduRec(event){
         const actionName = event.detail.action.name;
        const rowData = event.detail.row;
        if (actionName === 'delete') {
            this.deleteRecotd(rowData.Id, 'Employee_Education__c');
        }
    }

    handleDelExpRec(event){
        const actionName = event.detail.action.name;
        const rowData = event.detail.row;
        if (actionName === 'delete') {
            this.deleteRecotd(rowData.Id, 'Employee_Experience__c');
            
        }
    }

    deleteRecotd(recordId, objName){
        
        deleteRecordData({ recordId: recordId, objName: objName })
            .then(() => {
                this.handleValidationErrors('Success', 'Record deleted successfully', 'success');
                // this.dispatchEvent(new ShowToastEvent({
                //     title: 'Success',
                //     message: 'Record deleted successfully',
                //     variant: 'success'
                // }));
                this.editedEmployeeExpData = [];
                this.editedEmployeeEduData = [];
                this.fetchEmployeeDetails();
                this.editExperance = false;
                this.editEducation = false;
                
            })
            .catch(error => {
                console.error('Error deleting record', error);
                this.handleValidationErrors('Error', 'Error deleting record', 'error');
                // this.dispatchEvent(new ShowToastEvent({
                //     title: 'Error',
                //     message: 'Error deleting record',
                //     variant: 'error'
                // }));
            });
            return true;
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