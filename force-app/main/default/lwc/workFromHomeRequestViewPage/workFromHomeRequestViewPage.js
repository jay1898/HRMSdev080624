import { LightningElement, wire, api, track } from 'lwc';
import getWorkFromHomeRecords from '@salesforce/apex/EmployeeController.getWorkFromHomeRecords';
import getWFHRequests from '@salesforce/apex/EmployeeController.getWFHRequests';
import updateWorkFromHomeStatus from '@salesforce/apex/EmployeeController.updateWorkFromHomeStatus';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { refreshApex } from '@salesforce/apex';

export default class WorkFromHomeTable extends LightningElement {

    isConfirmationModalOpen = false;
    @track refreshComponent = false;
    selectedRecordId;
    buttonClickIndex;
    isDataLoaded = false;
    @track workFromHomeRecords = [];
    @api recordId;
    @track isCancelDisabled = false;
    totalWFHDays=0;
    
    todayDate;

    connectedCallback() {
        setTimeout(() => {
            const style = document.createElement('style');
            style.innerText = `
            @media (min-width: 48em){
                .slds-modal .slds-modal__container.conformation {
                    margin: 0 auto;
                    width: 50%;
                    max-width: 30rem !important;
                    min-width: 22rem;
                }
            }
            `;
            this.template.querySelector('.overrideStyle').appendChild(style);


        }, 100);
        

        this.todayDate = new Date().toLocaleDateString('en-CA'); // format yyyy-MM-dd
        console.log('this.todayDate',this.todayDate);
        if (this.recordId) {
            this.retrieveWorkFromHomeRecords();
        }
        getWFHRequests({ employeeId: this.recordId })
            .then(result => { 

                if(result.Number_of_Days__c != null || result.Number_of_Days__c != undefined){
                    this.totalWFHDays = result.Number_of_Days__c;
                }
                else{
                    this.totalWFHDays = 0;     
                }
                
                this.totalWFHDays = result.Number_of_Days__c;
                
            })
            .catch(error => {
                console.error('Error:', error);
            });

    }
    

    retrieveWorkFromHomeRecords() {
        console.log('OUTPUT : this.recordId',this.recordId);
        getWorkFromHomeRecords({ employeeId: this.recordId })
            .then(result => {
                console.log('OUTPUT : result wffffff',result);
                this.workFromHomeRecords= result.map(record => ({
                    ...record,
                    statusInputClass: this.getStatusInputClass(record.Status__c),
                    // disable: record.Status__c == 'Cancelled'? true : false,
                    // disable: record.Status__c == 'Rejected' ? true : false
                    disable: record.Status__c === 'Cancelled' || record.Status__c === 'Rejected',
                    isPastDate: record.Start_Date__c < this.todayDate
                }));
                console.log('OUTPUT : this.workFromHomeRecords',JSON.stringify(this.workFromHomeRecords));
                this.isDataLoaded = true;
            })
            .catch(error => {
                console.error('Error fetching work from home records', error);
            });
    }

    // isStartDatePast(startDate) {
    //     return new Date(startDate) < new Date(); // Compare start date with current date
    // }
   

    
    getStatusInputClass(status) {
        if (status === 'Approved') {
            return 'status-approved';
        } else if (status === 'Rejected') {
            return 'status-rejected';
        }
        return 'default-status'; // A default class, if needed
    }

    
    handleCancel(recordId) {
        updateWorkFromHomeStatus({ recordId, status: 'Cancelled' || 'Rejected'})
            .then(result => {
                // Find the index of the record to update
                //const index = this.workFromHomeRecords.findIndex(record => record.Id === recordId);
                const index = this.buttonClickIndex;
                if (index !== -1) {
                    const updatedRecords = [...this.workFromHomeRecords];  
                    const updatedRecord = { ...updatedRecords[index] }; 
                    console.log('OUTPUT : updatedRecord',updatedRecord); 
                    updatedRecord.Status__c = result; 
                    updatedRecord.disable = true;      
                    updatedRecords[index] = updatedRecord; 
                    console.log('OUTPUT :updatedRecords ',updatedRecords);
                    
                    this.workFromHomeRecords = updatedRecords;
                    this.performHardRefresh();
                }
                this.isConfirmationModalOpen = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Request has been cancelled successfully.',
                        variant: 'success',
                    })
                );
            })
            .catch(error => {
                console.error('Error updating record status', error);
            });
        }
    
    performHardRefresh() {
       // location.reload(true);
        //updateWorkFromHomeStatus.location.reload(true); 
        //this.isConfirmationModalOpen = false;
        this.isConfirmationModalOpen = true;
    }
    openConfirmationModal(event) {
        this.selectedRecordId = event.target.dataset.id;
        this.buttonClickIndex = event.target.dataset.index;
        this.isConfirmationModalOpen = true;

     
       
    }

    handleYesClick() {
        this.handleCancel(this.selectedRecordId);
        this.isConfirmationModalOpen = false;
        this.refreshComponent = !this.refreshComponent;
    }

    handleNoClick() {
        this.isConfirmationModalOpen = false;
        //const recordId = 'recordId';
    //this.handleCancel(recordId);
    }
    handleCancelClick() {
        this.isConfirmationModalOpen = false;
    }
}