import { LightningElement, track, wire,api } from 'lwc';
import getEmployeeDetails from '@salesforce/apex/EmployeeController.getEmployeeAllDetails';

export default class EmployeeJobDetailsCmp extends LightningElement {
    @api employeeDetails;
    @api employeeId;
 @track employeeNumber;
  @track dateOfjoin;
 @track JobTitle;
 @track inProbation;
 @track workerType;
 @track timeType;
 @track businessUnit;
 @track deparment;
 @track location;
 @track legalEntity;
 @track reportTo;
 @track shift;
 @track weeklyOfPolicy;
 @track leavePlan;
 @track holidayCalender;
 @track expansePolicy;
 @track LoanPolicy;

    @wire(getEmployeeDetails, { employeeId: '$employeeId' })
    wiredEmployeeDetails({ error, data }) {
                    console.log('employeeId:', this.employeeId);
        if (data) {
            this.employeeDetails = data;
            console.log('data', data);
            console.log('employeeDetails', this.employeeDetails);
        } else if (error) {
            console.error('Error fetching employee details:', error);
        }

        if (this.employeeDetails) {
            for (let i = 0; i < this.employeeDetails.length; i++) {
                console.log('Inside For Loop:', this.employeeDetails[i]);
                this.employeeNumber = this.employeeDetails[i].EmpCode__c != null && this.employeeDetails[i].EmpCode__c != undefined ? this.employeeDetails[i].EmpCode__c : "";
                this.dateOfjoin = this.formatDate(this.employeeDetails[i].Date_Of_Joining__c);
                this.JobTitle = this.employeeDetails[i].Job_Title__c != null && this.employeeDetails[i].Job_Title__c != undefined ? this.employeeDetails[i].Job_Title__c : "";
                this.inProbation = this.employeeDetails[i].In_Probation__c ? "Yes" : "No";
                this.workerType = this.employeeDetails[i].Worker_Type__c != null && this.employeeDetails[i].Worker_Type__c != undefined ? this.employeeDetails[i].Worker_Type__c : "";
                this.timeType = this.employeeDetails[i].Time_Type__c != null && this.employeeDetails[i].Time_Type__c != undefined ? this.employeeDetails[i].Time_Type__c : "";
                this.businessUnit = this.employeeDetails[i].Business_Unit__c != null && this.employeeDetails[i].Business_Unit__c != undefined ? this.employeeDetails[i].Business_Unit__c : "";
                this.deparment = this.employeeDetails[i].Department__c != null && this.employeeDetails[i].Department__c != undefined ? this.employeeDetails[i].Department__c : "";
               // this.location = this.employeeDetails[i].Location__c != null && this.employeeDetails[i].Location__c != undefined ? this.employeeDetails[i].Location__c : "";
               this.location = this.getAddressString(this.employeeDetails[i].Location__c);
               this.reportTo = this.employeeDetails[i].Reports_To__c != null && this.employeeDetails[i].Reports_To__c != undefined ? this.employeeDetails[i].Reports_To__c : "";
                this.legalEntity = this.employeeDetails[i].Legal_Entity__c != null && this.employeeDetails[i].Legal_Entity__c != undefined ? this.employeeDetails[i].Legal_Entity__c : "";
                this.shift = this.employeeDetails[i].Shift__c != null && this.employeeDetails[i].Shift__c != undefined ? this.employeeDetails[i].Shift__c : "";
                this.weeklyOfPolicy = this.employeeDetails[i].Weekly_Of_Policy__c != null && this.employeeDetails[i].Weekly_Of_Policy__c != undefined ? this.employeeDetails[i].Weekly_Of_Policy__c : "";
                this.leavePlan = this.employeeDetails[i].Leave_Plan__c != null && this.employeeDetails[i].Leave_Plan__c != undefined ? this.employeeDetails[i].Leave_Plan__c : "";
                this.holidayCalender = this.employeeDetails[i].Holiday_Celendar__c != null && this.employeeDetails[i].Holiday_Celendar__c != undefined ? this.employeeDetails[i].Holiday_Celendar__c : "";
                this.expansePolicy = this.employeeDetails[i].Expanse_Policy__c != null && this.employeeDetails[i].Expanse_Policy__c != undefined ? this.employeeDetails[i].Expanse_Policy__c : "";
                this.LoanPolicy = this.employeeDetails[i].Loan_Policy__c  != null && this.employeeDetails[i].Loan_Policy__c  != undefined ? this.employeeDetails[i].Loan_Policy__c  : "";
                console.log('this.Loanpolicy:', this.employeeDetails[i].Loan_Policy__c);

            }

            
        }
        console.log('this.employeeNumber:', this.employeeNumber);
    }
    getAddressString(addressObj) {
        if (!addressObj) {
            return "";
        }
        let addressString = "";
        if (addressObj.street) {
            addressString += addressObj.street + ", ";
        }
        if (addressObj.city) {
            addressString += addressObj.city + ", ";
        }
        if (addressObj.state) {
            addressString += addressObj.state + ", ";
        }
        if (addressObj.country) {
            addressString += addressObj.country + ", ";
        }
        if (addressObj.postalCode) {
            addressString += addressObj.postalCode;
        }
        return addressString;
    }

    formatDate(dateString) {
        if (!dateString) {
            return "";
        }
        const date = new Date(dateString);
        const options = { day: 'numeric', month: 'long', year: 'numeric' };
        return date.toLocaleDateString(undefined, options);
    }

    }