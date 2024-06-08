import { LightningElement, track, api } from 'lwc';
import getLeaveRequestRecords from '@salesforce/apex/EmployeeController.getLeaveRequestRecords';
import updateLeaveRequestStatus from '@salesforce/apex/EmployeeController.updateLeaveRequestStatus';
import getLeaveRequests from '@salesforce/apex/EmployeeController.getLeaveRequests';
import getLeaveCountByType from '@salesforce/apex/EmployeeController.getLeaveCountByType';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';



export default class LeaveRequestDetailPage extends LightningElement {

    isConfirmationModalOpen = false;
    selectedRecordId;
    buttonClickIndex;
    isDataLoaded = false;
    @track leaveRequestRecords = [];
    @api recordId;
    @track isCancelDisabled;
    // @track numberOfDays;
    // @track days;
    @track numberOfLeaves1;
    numberOfAvailableLeaves=0;
    totalUsedLeaves=0;
    totalWFHDays=0;
    totalHalfDays=0;
    totalUnPaidLeaves = 0 ;
    totalPaidLeaves = 0 ;
    availiableBalanceLeave = 0 ;

    todayDate;
    
    connectedCallback(){ 

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
         this.retrieveleaveRequestRecords();
        }
        
        getLeaveRequests({ employeeId: this.recordId })
            .then(result => {
                console.log("rsult",result);
                console.log('result.Leave_Balance__c', result.Leave_Balance__c);
                // if (result.Leave_Balance__c != null){
                //     this.availiableBalanceLeave = result.Leave_Balance__c;
                // }else{
                //     this.availiableBalanceLeave =0;
                // }
                
                if(result.Number_of_Leaves__c != null || result.Number_of_Leaves__c != undefined){
                    this.numberOfAvailableLeaves = result.Number_of_Leaves__c;
                }
                else{
                    this.numberOfAvailableLeaves = 0;     
                }
                
                this.totalUsedLeaves = result.Total_Leave_Taken__c ;
                this.totalHalfDays = result.Total_Half_Days__c;
                this.totalWFHDays = result.Total_Work_From_Home_Days__c;
                console.log('Get number of available leaves', result);
                
            })
            .catch(error => {
                console.error('Error:', error);
            });

             getLeaveCountByType({ employeeId: this.recordId })
            .then(result => {
                if (result && Object.keys(result).length > 0) {
                    // Process the result as it is not null or empty
                    if (result.hasOwnProperty('Paid Leave')){
                        console.log('Leave count by type:', result['Paid Leave']);
                        this.totalPaidLeaves =  result['Paid Leave'];
                    }
                    else{
                        this.totalPaidLeaves =0;
                    }
                    if (result.hasOwnProperty('Unpaid Leave')){
                        console.log('Leave count by type- Unpaid:', result['Unpaid Leave']);
                        this.totalUnPaidLeaves = result['Unpaid Leave'];
                    }
                    else{
                        this.totalUnPaidLeaves =0;
                    }
                } else {
                    console.log('Leave count by type is null or empty.');
                    this.totalPaidLeaves =  0;
                    this.totalUnPaidLeaves = 0;
                    // Handle the case where the result is null or empty
                }
            })
            .catch(error => {
                console.error('Error:', error);
            });

    }

    retrieveleaveRequestRecords() {
        console.log('OUTPUT : this.recordId',this.recordId);
        getLeaveRequestRecords({ employeeId: this.recordId })
            .then(result => {
                console.log('OUTPUT : result LeaveRRRRRR',result);
                this.leaveRequestRecords = result.map(record => ({
                    ...record,
                    statusInputClass: this.getStatusInputClass(record.Status__c),
                    disable: record.Status__c === 'Cancelled' || record.Status__c === 'Rejected',
                    isPastDate: record.Start_Date__c < this.todayDate
                     // numberOfLeaves: record.Employee__r.Number_of_Leaves__c,
                    // numberOfDays: record.Number_of_Days__c
                    
                }));
                
                console.log('OUTPUT : this.leaveRequestRecords',JSON.stringify(this.leaveRequestRecords));
                this.isDataLoaded = true;
            })
            .catch(error => {
                console.error('Error fetching leave request records', error);
            });
         }
    getStatusInputClass(status) {
        if (status === 'Approved') {
            return 'status-approved';
        } else if (status === 'Rejected') {
            return 'status-rejected';
        }
        return 'default-status'; // A default class, if needed
    }

    handleCancel(recordId) {
        updateLeaveRequestStatus({ recordId, status: 'Cancelled' || 'Rejected'})
            .then(result => {
                // Find the index of the record to update
                //const index = this.leaveRequestRecords.findIndex(record => record.Id === recordId);
                const index = this.buttonClickIndex;
                console.log('index ::--->> ' ,index);
                if (index !== -1) {
                    const updatedRecords = [...this.leaveRequestRecords];
                    const updatedRecord = { ...updatedRecords[index] };
                    updatedRecord.Status__c = result;
                    updatedRecord.disable = true;
                    updatedRecords[index] = updatedRecord;
                    this.leaveRequestRecords = updatedRecords;
                    this.performHardRefresh();
                    
                   // reflact the Leave Balance on UI Immidately 
                    if (updatedRecord.Leave_Type__c === 'Paid Leave') {
                        this.numberOfAvailableLeaves += updatedRecord.Number_of_Days__c;
                        this.totalPaidLeaves -= updatedRecord.Number_of_Days__c;
                    } else if (updatedRecord.Leave_Type__c === 'Unpaid Leave') {
                        this.totalUnPaidLeaves -= updatedRecord.Number_of_Days__c;
                    }
                    this.performHardRefresh();
                   // this.refreshComponentData();
                    this.retrieveleaveRequestRecords();
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
            //console.log('this.leaveRequestRecords -- Cancel ::--->> ' ,JSON.stringify(this.leaveRequestRecords));
            
            
    }
    /*handleCancel(recordId) {
        updateLeaveRequestStatus({ recordId, status: 'Cancelled' || 'Rejected'})
            .then(result => {
                const index = this.buttonClickIndex;
                if (index !== -1) {
                    const updatedRecords = [...this.leaveRequestRecords];
                    const updatedRecord = { ...updatedRecords[index] };
                    updatedRecord.Status__c = result;
                    updatedRecord.disable = true;
                    updatedRecords[index] = updatedRecord;
                    this.leaveRequestRecords = updatedRecords;
    
                    if (updatedRecord.Leave_Type__c === 'Paid Leave') {
                        this.numberOfAvailableLeaves += updatedRecord.Number_of_Days__c;
                        this.totalPaidLeaves -= updatedRecord.Number_of_Days__c;
                    } else if (updatedRecord.Leave_Type__c === 'Unpaid Leave') {
                        this.totalUnPaidLeaves -= updatedRecord.Number_of_Days__c;
                    }
    
                    this.performHardRefresh();
                    this.retrieveleaveRequestRecords();
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
    */

    performHardRefresh() {
        this.isConfirmationModalOpen = false;
    }


    openConfirmationModal(event) {
        this.selectedRecordId = event.target.dataset.id;
        this.buttonClickIndex = event.target.dataset.index;
        this.isConfirmationModalOpen = true;
       

    }

    handleYesClick() {
       
        this.handleCancel(this.selectedRecordId);
        
        
        
    }

    handleNoClick() {
        this.isConfirmationModalOpen = false;
    }
    handleCancelClick() {
        this.isConfirmationModalOpen = false;
        
    }
}