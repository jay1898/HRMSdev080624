import { LightningElement, track, api, wire } from 'lwc';
import updateData from '@salesforce/apex/EmployeeController.updateData';
import insertClockinRecords from '@salesforce/apex/EmployeeController.insertClockinRecords';
import updateClockoutRecords from '@salesforce/apex/EmployeeController.updateClockoutRecords';
import getWFHData from '@salesforce/apex/EmployeeController.getWFHData';
import getLeaveData from '@salesforce/apex/EmployeeController.getLeaveData';
import getLeaveRequests from '@salesforce/apex/EmployeeController.getLeaveRequests';
import saveWFHData from '@salesforce/apex/EmployeeController.saveWFHData';
import saveLeaveData from '@salesforce/apex/EmployeeController.saveLeaveData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getClockInOutData from '@salesforce/apex/EmployeeController.getClockInOutData';
import updateClockOutTime from '@salesforce/apex/EmployeeController.updateClockOutTime';
import getAttendanceTotalClockInHours from '@salesforce/apex/EmployeeController.getAttendanceTotalClockInHours';
import getClockInTime from '@salesforce/apex/EmployeeController.getClockInTime';
import getAttendanceOnTimeArrival from '@salesforce/apex/EmployeeController.getAttendanceOnTimeArrival';
import getontimeArrival from '@salesforce/apex/EmployeeController.getontimeArrival';
//import getNumberOfNonBusinessDays from '@salesforce/apex/EmployeeController.getNumberOfNonBusinessDays';
import { refreshApex } from '@salesforce/apex';

export default class ClockInClockOut extends LightningElement {
    @api empDetails;
    @track currentBtnPosition = 'Clock-in';
    @track hour;
    @track minute;
    @track second;
    @track time;
    @track date;
    @track isClockinorout;
    @track currentClockInOutStatus;
    @track empRecordId;
    @track wfhRequest = {};
    @track leaveRequest = {};
    @track wfhType;
    @track wfhTypeOption = [];
    @track leaveTypeOption = [];
    startDate;
    startDateString;
    endDateString;
    formattedFromDate;
    endDate;
    formattedToDate;
    @track isModalOpenWFH = false;
    @track isModalOpenLEAVE = false;
    @track isDisableClockoutFor1min = false;
    @track isClockOutForget = false;
    @track clockInOutData = [];
    @track lastForgetClockinDate;
    objectApiName = 'Clock_In_Out__c';
    recordId = '';
    month_names_short = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    day_names_short = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    @track typeOptionsArr = [];
    clockInTime;
    @track clockOutDateTime = '';
    @track isClockOutDateTimeFilled = false;
    @track setIntervalId;
    @track timeDifference = "0 h: 0 m";
    @track leaveDurationOption = [];
    @track fromDateleaveDurationOption = [];
    @track toDateleaveDurationOption = [];
    @track toDateleaveDuration = false;
    @track isOnedayLeave = false;
    @track ismultipledayLeave = false;
    @track showLeaveDuration = false;
    selectedLeaveType;
    isLeaveTypeSelected = false;
    leavesAvailable = false;
    leavesEmpty = false;
    leavesZero = false;
    isRequired_ToDura = false;
    isRequired_FromDura = false;
    numberOfAvailableLeaves = 0 ;
    numberOfLeavesRemaining;
    numberOfLeavesZero;
    numberOfLeavesGreater;
    @track NoOfPaidAndUnpaidLeave = { "paidLeave": 0, "unpaidLeave": 0 };
    totalDays = 0;
    tempTotalDays = 0;
    parsedValue;
    lastSelectedTemp;
    lastSelectedTemp1;
    @track reason;
    @track fullDayValue = true;
    @track customValue = false;
    reasonExceedsLimit = false;
    isDisableSave = false;
    formattedDate;
    @track attendanceData = [];
    arrivalStatus;
    @track arrivalPercentage = {
        onTime : 0,
        late: 0
    }


    connectedCallback() {
        const currentDate = new Date().toISOString().split('T')[0];
        //For Displaying Today date below the timer
        const todayDateFormat = new Date();
        const options = { day: 'numeric', month: 'long', year: 'numeric' };
        const day = todayDateFormat.getDate();
        const dayOfWeek = todayDateFormat.toLocaleString('en-US', { weekday: 'long' });
        const month = todayDateFormat.toLocaleString('en-US', { month: 'long' });
        const year = todayDateFormat.getFullYear();
        this.formattedDate = `${dayOfWeek} ${day}, ${month} ${year}`;


    
        setTimeout(() => {
            const style = document.createElement('style');
            style.innerText = `
            lightning-datepicker .slds-form-element__control.slds-input-has-icon.slds-input-has-icon_right {
                color: #00A129;
                border-radius: 8px;
            }
            .leave-type lightning-base-combobox button.slds-combobox__input.slds-input_faux{	
                padding: 3px;
                font-size: 18px;
                padding-left: 13px;
                border: 1px solid #9D9D9D;
                border-radius: 20px;
                border-radius: 5px;
				border-radius: 8px !important;
                margin-left: 10px;
			}
            .remove_border lightning-datepicker .slds-input{
                border: none !important;
            }
            .remove_label {
                margin-top: 5px;
            }
            .remove_label label {
                display: none;
            }
            .slds-box {
                
            }
            `;
            this.template.querySelector('.overrideStyle').appendChild(style);

            let checkbox = this.template.querySelector("#s2-op_one");
            checkbox.setAttribute("checked", "checked");
        }, 100);



        const clockinTimestamp = localStorage.getItem('clockinTimestamp');
        if (clockinTimestamp) {
            const currentTime = new Date().getTime();
            const elapsedMilliseconds = currentTime - parseInt(clockinTimestamp);
            if (elapsedMilliseconds < 60000) {
                this.isDisableClockoutFor1min = true;
                setTimeout(() => {
                    this.isDisableClockoutFor1min = false;
                }, 60000 - elapsedMilliseconds);
            } else {
                localStorage.removeItem('clockinTimestamp');
            }
        }
        this.showTime();
        let empAllDetails = JSON.parse(JSON.stringify(this.empDetails));
        this.empRecordId = empAllDetails.EmpRecordId;
        console.log('this.empRecordIdthis.empRecordIdthis.empRecordId',this.empRecordId);
        if (empAllDetails.EmpClockInOutStatus === 'Clock-out')
            this.isClockinorout = true;
        else
            this.isClockinorout = false;
        getWFHData({})
            .then(result => {
                this.parsedValue = result;
                //console.log('Json Parse Data ' + this.parsedValue.wfhType);
                for (var i = 0; i < this.parsedValue.wfhType.length; i++) {
                    //console.log('Json Parse Data ', this.parsedValue.wfhType[i]);
                    this.wfhTypeOption.push({ 'label': this.parsedValue.wfhType[i], 'value': this.parsedValue.wfhType[i] });
                }
            })
            .catch(error => {
                console.error(error);
            });

        getLeaveData({})
            .then(result => {
                this.parsedValue = result;
                console.log('result is ehere : ', result);
                //console.log('Json Parse Data ' + this.parsedValue.leaveType);
                for (var i = 0; i < this.parsedValue.leaveType.length; i++) {
                    //console.log('Json Parse Data ', this.parsedValue.leaveType[i]);
                    this.leaveTypeOption.push({ 'label': this.parsedValue.leaveType[i], 'value': this.parsedValue.leaveType[i] });
                    // this.leaveDurationOption.push({ 'label': this.parsedValue.leaveDuration[i], 'value': this.parsedValue.leaveDuration[i] });
                }
                for (var i = 0; i < this.parsedValue.leaveDuration.length; i++) {
                    console.log('Json Parse Data ', this.parsedValue.leaveDuration[i]);
                    // this.leaveTypeOption.push({ 'label': this.parsedValue.leaveType[i], 'value': this.parsedValue.leaveType[i] });
                    this.leaveDurationOption.push({ 'label': this.parsedValue.leaveDuration[i], 'value': this.parsedValue.leaveDuration[i] });

                }
                for (var i = 0; i < this.parsedValue.fromDateleaveDuration.length; i++) {
                    console.log('Json From Date Leave Date ', this.parsedValue.fromDateleaveDuration[i]);
                    // this.leaveTypeOption.push({ 'label': this.parsedValue.leaveType[i], 'value': this.parsedValue.leaveType[i] });
                    this.fromDateleaveDurationOption.push({ 'label': this.parsedValue.fromDateleaveDuration[i], 'value': this.parsedValue.fromDateleaveDuration[i] });

                }
                for (var i = 0; i < this.parsedValue.toDateleaveDuration.length; i++) {
                    console.log('Json to date data ', this.parsedValue.toDateleaveDuration[i]);
                    // this.leaveTypeOption.push({ 'label': this.parsedValue.leaveType[i], 'value': this.parsedValue.leaveType[i] });
                    this.toDateleaveDurationOption.push({ 'label': this.parsedValue.toDateleaveDuration[i], 'value': this.parsedValue.toDateleaveDuration[i] });

                }
            })
            .catch(error => {
                console.error(error);
            });
        this.retrieveClockInOutData();
        this.loadAttendanceData();// For Fetching On arrival Data
        this.ontimeArrival();
        let getEmpItem = 'empDetails' + this.empRecordId;
        if (JSON.parse(localStorage.getItem(getEmpItem)) != null) {
            if (JSON.parse(localStorage.getItem(getEmpItem)).Clocked_In_Out_Status__c === 'Clock-out')
                this.isClockinorout = true;
            else
                this.isClockinorout = false;
        }
        //since login
        getClockInTime({ EmpRecordId: this.empRecordId })
            .then(result => {
                console.log('OUTPUT-------result : ', result);
                if (result != null) {
                    const dateTimeString = result; // Assuming 'result' is a valid date-time string
                    const dateTime = new Date(dateTimeString); // Convert the date-time string to a JavaScript Date object
                    const timeString = dateTime.toLocaleTimeString(); // Extract the time in a readable format
                    console.log('OUTPUT-------result : ', result);
                    this.getAttendanceTotalClockInHoursSinceLogin(timeString);
                    //this.getClockInTimeDifference(timeString);
                }
            })
            .catch(error => {
                console.error('error', error);
            });
        // Get number of available leaves

        this.getLeaveRequestData();
        

        const style = document.createElement('style');
        style.innerText = `
                    .leaveApply button{
                        border: 2px solid #00A129;
                        border-radius: 50px;
                        padding: 6px 35px;
                        color : #00A129;
                    }
                    .leaveApply button:hover{
                        background: unset;
                        color : #00A129;
                    }
                    .leaveApply button:focus{
                       box-shadow: none;
                    }
                    `;

        setTimeout(() => {
            this.template.querySelector('.overrideStyle').appendChild(style);
        }, 200);


        //this.getAttendanceTotalClockInHoursSinceLogin();

    }

    getLeaveRequestData() {
        getLeaveRequests({ employeeId: this.empRecordId })
            .then(result => {
                console.log("getLeaveRequests Result",result);
                if(result.Number_of_Leaves__c != null || result.Number_of_Leaves__c != undefined){
                    this.numberOfAvailableLeaves = result.Number_of_Leaves__c;
                }
                //console.log('Get number of available leaves', result.Number_of_Leaves__c);
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }
    retrieveClockInOutData() {
        getClockInOutData({ employeeId: this.empRecordId })
            .then(result => {
                this.clockInOutData = result;
                if (result.length > 0) {
                    this.isClockOutForget = true;
                }
                console.log('Clock In/Out Data:_________', this.clockInOutData);
                let lastClockinForgotResult = JSON.parse(JSON.stringify(this.clockInOutData));
                for (let x in lastClockinForgotResult) {
                    this.lastForgetClockinDate = lastClockinForgotResult[x].Clock_In_Time__c.split('T')[0];
                }
                console.log('@@@lastClockinForgotResult: ', this.lastForgetClockinDate);
            })
            .catch(error => {
                console.error('Error retrieving Clock In/Out Data:_________', error);
            });
    }


    handleReasonChange(event) {
        this.reason = event.target.value;
        this.checkWordCount();
    }
    
    checkWordCount() {
        let charCount = this.reason.trim().length;
        if (charCount > 5000) { 
            this.reason = this.reason.slice(0, 5000); 
            this.reasonExceedsLimit = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please limit your reason to 5000 characters or less.',
                    variant: 'error'
                })
            );
        } else {
            this.reasonExceedsLimit = false;
        }
    }
    


// WFHHandleSelection(event) {
//         let name = event.target.name;
//         // this.totalDays = 0;
//         console.log('name>> 1 ', name);
//         if (name === 'FromDate' || name === 'ToDate') {
//             //console.log('event.target.value>> ', event.target.value);
         
//             this.wfhRequest[name] = event.target.value;

//             this.totalDays = 0;
//             console.log('this.wfhRequest[name]>> ', this.wfhRequest[name]);
//             // console.log('wfhRequest.FromDate>> ', this.wfhRequest.FromDate);
//             // console.log('wfhRequest.ToDate>> ', this.wfhRequest.ToDate);
//             if(this.wfhRequest.FromDate==null || this.wfhRequest.ToDate==null){
//                 this.isOnedayLeave = false;
//                 return;
//             }
//             const fromDate = new Date(this.wfhRequest.FromDate);
//             const toDate = new Date(this.wfhRequest.ToDate);

//             this.startDateString = fromDate;
//             this.endDateString = toDate;
//             if (!isNaN(fromDate.getTime()) && !isNaN(toDate.getTime())) {
//                 console.log("if",this.totalDays);
//                 const totalDay = Math.ceil((toDate - fromDate) / (1000 * 3600 * 24)) + 1;
//                 getNumberOfNonBusinessDays({ startDate: this.startDateString, endDate: this.endDateString })
//                     .then(result => {
//                         // console.log('Result no of days remove ', result);
//                         this.totalDays = totalDay - result;
//                         this.tempTotalDays = this.totalDays;
//                         //console.log('Result using apexxxxxx  ---   aaaaaaaaaaaxxxxxxxxxx', this.totalDays);
//                         const timeDifference = toDate.getTime() - fromDate.getTime();
//                         const daysDifference = timeDifference / (1000 * 3600 * 24);
                       
//                         // If the difference is negative, display 0; if the difference is zero, display 1, else add 1 to the calculated days
//                         if (daysDifference < 0) {
//                             this.totalDays = 0;
//                             //console.log('daysDifference < 0 : ', this.totalDays);
//                         } else if (daysDifference === 0) {
//                             this.totalDays = 1;
//                             //console.log('else if (daysDifference === 0 : ', this.totalDays);
//                         } else {
//                             //this.totalDays = Math.abs(Math.round(daysDifference)) + 1;
//                             //console.log('else : ', this.totalDays);
//                         }
//                         if (this.totalDays >= 1) {
//                             this.isOnedayLeave = true;

//                             this.ismultipledayLeave = false;
//                             this.showLeaveDuration = false;
//                         } else {
                           
//                             this.isOnedayLeave = false;
//                             this.ismultipledayLeave = false;
//                         }
//                         //console.log("Total Days: ", this.totalDays);
//                         if (this.totalDays > 1) {
//                             this.ismultipledayLeave = true;
//                         } else {
//                             this.ismultipledayLeave = false;
//                         }
//                         //console.log("Total Days:@@@@@ ", this.totalDays);
//                         this.isLeaveTypeSelected = true;
//                         if (name == 'leaveType') {
//                             // this.isLeaveTypeVisible = true;
//                             event.target.value = null;

//                         }
//                     })
//                     .catch(error => {
//                         console.log("else",this.totalDays);
//                         this.totalDays = 0; // Handle error scenario
//                         console.error('Error:', error);
//                         console.log("apex call error", this.totalDays);
//                     });

//             } else {
//                 this.totalDays = 0; 
//                 this.isOnedayLeave = false;
//                 // Reset totalDays to 0 if both dates are not selected
//             }
//         }
//         if (name == 'FromDate') {
//             this.wfhRequest[name] = event.target.value;
//             this.startDate = new Date(this.wfhRequest.FromDate);
//             this.formatFromDate();
//             // console.log("From Date is ::: ", event.target.value)
//             // console.log("typeof From Date is ::: ", typeof (event.target.value))
//         }
//         if (name == 'ToDate') {
//             this.wfhRequest[name] = event.target.value;
//             this.endDate = new Date(this.wfhRequest.ToDate);//
//             this.formatToDate();
//             // console.log("ToDate  is ::: ", event.target.value)
//             // console.log("typeof ToDate is ::: ", typeof (event.target.value))
//         }
//         if (name == 'Reason') {
//             this.wfhRequest[name] = event.target.value;
//         }
//         if (name == 'wfhType' && event.target.checked) {
//             // this.wfhRequest[name] = event.target.value;
//             this.wfhRequest[name] = event.target.value;

//             //console.log('Selected Work From Home Type:', this.wfhRequest[name]);
        
//         }

// }

WFHHandleSelection(event) {
    let name = event.target.name;

    if (name === 'FromDate' || name === 'ToDate') {
        this.wfhRequest[name] = event.target.value;

        const fromDate = new Date(this.wfhRequest.FromDate);
        const toDate = new Date(this.wfhRequest.ToDate);

        // Check if both FromDate and ToDate are selected
        if (!isNaN(fromDate.getTime()) && !isNaN(toDate.getTime())) {
            const totalDay = Math.ceil((toDate - fromDate) / (1000 * 3600 * 24)) + 1;

            getNumberOfNonBusinessDays({ startDate: fromDate, endDate: toDate })
                .then(result => {
                    this.totalDays = totalDay - result;
                    if (this.totalDays >= 1) {
                        this.isOnedayLeave = true;
                        this.ismultipledayLeave = false;
                        this.showLeaveDuration = false;
                    } else {
                        this.isOnedayLeave = false;
                        this.ismultipledayLeave = false;
                    }
                    if (this.totalDays > 1) {
                        this.ismultipledayLeave = true;
                    } else {
                        this.ismultipledayLeave = false;
                    }
                    this.isLeaveTypeSelected = true;
                    if (name == 'leaveType') {
                        event.target.value = null;
                    }
                })
                .catch(error => {
                    // Handle error scenario gracefully
                    console.error('Error:', error);
                });
        }
    }

    if (name == 'FromDate') {
        this.wfhRequest[name] = event.target.value;
        this.startDate = new Date(this.wfhRequest.FromDate);
        this.formatFromDate();
    }

    if (name == 'ToDate') {
        this.wfhRequest[name] = event.target.value;
        this.endDate = new Date(this.wfhRequest.ToDate);
        this.formatToDate();
    }

    if (name == 'Reason') {
        this.wfhRequest[name] = event.target.value;
    }

    if (name == 'wfhType' && event.target.checked) {
        this.wfhRequest[name] = event.target.value;
    }
}
    formatFromDate() {
        if (this.startDate) {
            const options = { year: 'numeric', month: 'short', day: 'numeric' };
            this.formattedFromDate = new Date(this.startDate).toLocaleDateString('en-IN', options).replace(/(\d+)\s(\w+)/, '$1 $2,');
        }
    }
    formatToDate() {
        if (this.endDate) {
            const options = { year: 'numeric', month: 'short', day: 'numeric' };
            this.formattedToDate = new Date(this.endDate).toLocaleDateString('en-IN', options).replace(/(\d+)\s(\w+)/, '$1 $2,');
        }
    }

    handleRadioChange(event) {
        let name = event.target.name;
        console.log('@@name Type >> ', name);
        if (name == 'leaveDuration') {
            //this.leaveRequest[name] = event.target.value;
            console.log('event.target.value >> ', event.target.value);
            if (event.target.value === 'custom') {
                console.log('custom if >> ', event.target.value);
                this.customValue = event.target.checked;
                this.fullDayValue = false;

                this.showLeaveDuration = true;
                this.formatFromDate();
                this.formatToDate();
                this.isRequired_ToDura = true;
                this.isRequired_FromDura = true;
                this.leaveRequest[name] = '';
                this.lastSelectedTemp = undefined;
                this.lastSelectedTemp1 = undefined;


            } else if (event.target.value === 'Full Day') {
                console.log('Full Day if >> ', event.target.value);
                this.fullDayValue = event.target.checked;
                 this.customValue = false;
                 this.isRequired_FromDura = false;
                 this.isRequired_ToDura = false;
                this.showLeaveDuration = false;
                this.leaveRequest[name] = event.target.value;
                this.totalDays = this.tempTotalDays;
                  // Reset custom leave duration options when switching to Full Day
                    this.leaveRequest.fromDateLeaveDurationOption = '';
                    this.leaveRequest.toDateleaveDurationOption = '';
                    this.lastSelectedTemp = undefined; 
                    this.lastSelectedTemp1 = undefined;
                    this.isRequired_ToDura = false;
                    this.isRequired_FromDura = false;
                } else {
                    console.log('Else >> ', event.target.value);
                    // If the combobox is empty, set leaveDuration to "Full Day"
                    if (!this.leaveRequest.fromDateLeaveDurationOption && !this.leaveRequest.toDateleaveDurationOption) {
                        this.leaveRequest[name] = 'Full Day';
                    }
                    this.isRequired_ToDura = false;
                    this.isRequired_FromDura = false;
                }
            
        }
        //console.log('this.isRequired >> ', this.isRequired);
        console.log('@@LeaveRequest1', JSON.parse(JSON.stringify(this.leaveRequest)));
    }
    leaveHandleSelection(event) {
        let name = event.target.name;
        console.log('name>> ', name);
       // this.getLeaveRequestData();
        if (name === 'FromDate' || name === 'ToDate') {
            console.log('event.target.value>> ', event.target.value);
            this.fullDayValue = true;
            this.customValue = false;
            this.isRequired_FromDura = false;
            this.isRequired_ToDura = false;

            this.showLeaveDuration = false;
            this.leaveRequest[name] = event.target.value;
            this.totalDays = 0;
            console.log('this.leaveRequest[name]>> ', this.leaveRequest[name]);
            console.log('leaveRequest.FromDate>>111 ', this.leaveRequest.FromDate);
            console.log('leaveRequest.ToDate>>111 ', this.leaveRequest.ToDate);
            if(this.leaveRequest.FromDate==null || this.leaveRequest.ToDate==null){
                this.isOnedayLeave = false;
                this.showLeaveDuration = false;
                this.ismultipledayLeave = false;
                return;
            }
            console.log('leaveRequest.FromDate>>222 ', this.leaveRequest.FromDate);
            console.log('leaveRequest.ToDate>> ', this.leaveRequest.ToDate);
            const fromDate = new Date(this.leaveRequest.FromDate);
            const toDate = new Date(this.leaveRequest.ToDate);      
            this.startDate = fromDate;
            this.endDate = toDate;
            
            if (fromDate!=undefined && toDate!=undefined && !isNaN(fromDate.getTime()) && !isNaN(toDate.getTime())) {
                const totalDay = Math.ceil((toDate - fromDate) / (1000 * 3600 * 24)) + 1;
                getNumberOfNonBusinessDays({ startDate: this.startDate, endDate: this.endDate })
                    .then(result => {
                        console.log('Result no of days remove ', result);
                        this.totalDays = totalDay - result;
                        this.tempTotalDays = this.totalDays;
                        console.log('Result using apexxxxxx  ---   aaaaaaaaaaaxxxxxxxxxx', this.totalDays);
                        const timeDifference = toDate.getTime() - fromDate.getTime();
                        const daysDifference = timeDifference / (1000 * 3600 * 24);
                        console.log('before calling method', this.totalDays);
                        // If the difference is negative, display 0; if the difference is zero, display 1, else add 1 to the calculated days
                        if (daysDifference < 0) {
                            this.totalDays = 0;
                            console.log('daysDifference < 0 : ', this.totalDays);
                        } else if (daysDifference === 0) {
                            this.totalDays = 1;
                            console.log('else if (daysDifference === 0 : ', this.totalDays);
                        } else {
                            //this.totalDays = Math.abs(Math.round(daysDifference)) + 1;
                            console.log('else : ', this.totalDays);
                        }
                        if (this.totalDays == 1) {
                            this.isOnedayLeave = true;

                            this.ismultipledayLeave = false;
                            this.showLeaveDuration = false;
                        } else {
                            this.isOnedayLeave = false;
                            this.ismultipledayLeave = false;
                        }
                        console.log("Total Days: ", this.totalDays);
                        if (this.totalDays > 1) {
                           this.ismultipledayLeave = true;
                        } else {
                            this.ismultipledayLeave = false;
                        }
                        console.log("Total Days:@@@@@ ", this.totalDays);
                        this.isLeaveTypeSelected = true;
                        if (name == 'leaveType') {
                            // this.isLeaveTypeVisible = true;
                            event.target.value = null;

                        }
                    })
                    .catch(error => {
                        this.totalDays = 0; // Handle error scenario
                        console.error('Error:', error);
                        console.log("apex call error", this.totalDays);
                    });
 
            } 
            else {
                this.totalDays = 0; 
                this.isOnedayLeave = false;
                this.showLeaveDuration = false;// Reset totalDays to 0 if both dates are not selected
                this.ismultipledayLeave = false;
                
            } 
        }
       
        if (name == 'FromDate') {
            this.leaveRequest[name] = event.target.value;
            console.log("From Date is ::: ", event.target.value)
            console.log("typeof From Date is ::: ", typeof (event.target.value))
        }
        if (name == 'ToDate') {
            this.leaveRequest[name] = event.target.value;
            console.log("ToDate  is ::: ", event.target.value)
            console.log("typeof ToDate is ::: ", typeof (event.target.value))
        }
        if (name == 'Reason') {

            this.leaveRequest[name] = event.target.value;
        }
        if (name == 'leaveType') {
             this.isLeaveTypeVisible = true;
            this.selectedLeaveType = event.target.value;
            console.log('this.selectedLeaveType @@##$$%%^^^ ', this.selectedLeaveType);
            this.leaveRequest[name] = event.target.value;
            this.isLeaveTypeSelected = true;
        }
        if (name == 'leaveDuration') {
            this.leaveRequest[name] = event.target.value;
            let originalTotalDays = 1;
            let halfDayDeducted = false;
            // Track if a half-day leave has been deducted
            if (!halfDayDeducted) {
                if (event.target.value == 'First Half' || event.target.value == 'Second Half') {
                    originalTotalDays -= 0.5;
                    halfDayDeducted = true;  // Mark half-day leave as deducted
                    console.log('Half day leave deducted, totalDays: ', originalTotalDays);
                }
            } else {
                console.log('Half day leave already deducted, totalDays remains: ', originalTotalDays);
            }

            // Update the total days
            this.totalDays = originalTotalDays;
        }
        
        if (name == 'fromDateLeaveDurationOption') {
            
            this.leaveRequest[name] = event.target.value;
             
            if (event.target.value !== null){
                this.isRequired_FromDura = false;
                if(this.lastSelectedTemp == undefined && event.target.value == 'Full Day'){
                    this.lastSelectedTemp = event.target.value;
                }
                if (event.target.value === 'Second half') {
                    this.totalDays -= 0.5;
                    this.lastSelectedTemp = event.target.value;
                }
                if (this.lastSelectedTemp != event.target.value && event.target.value === 'Full Day') {
                    this.totalDays += 0.5;
                }
            }
            else{
                console.log('OUTPUT : elseeeeeeeeeeee');
                this.isRequired_FromDura = true;
            }
   
            console.log('fromDateLeaveDurationOption_______Name ', this.leaveRequest[name]);
        }
        if (name == 'toDateleaveDurationOption') {
            this.leaveRequest[name] = event.target.value;
            if (event.target.value !== null){
                this.isRequired_ToDura = false;
                if(this.lastSelectedTemp1 == undefined && event.target.value == 'Full Day'){
                    this.lastSelectedTemp1 = event.target.value;
                }
                if (event.target.value === 'First half') {
                    this.totalDays -= 0.5;
                    this.lastSelectedTemp1 = event.target.value;
                }
                if (this.lastSelectedTemp1 != event.target.value && event.target.value === 'Full Day') {
                    this.totalDays += 0.5;
                }
            }
            else{
                this.isRequired_ToDura = true;
            }
            console.log('toDateleaveDurationOption_______Name ');
        }
        console.log('@@LeaveRequest', JSON.parse(JSON.stringify(this.leaveRequest)));
        console.log("Total Days:@@@@@ after Leave 1 ", this.totalDays);
        //paid and unpaid leaves

        console.log('this.selectedLeaveType', this.selectedLeaveType);
        console.log("this.totalDays",this.totalDays);
        console.log("this.numberOfAvailableLeaves",this.numberOfAvailableLeaves);
        if (this.totalDays < this.numberOfAvailableLeaves) {
            let temp = this.numberOfAvailableLeaves - this.totalDays;
            this.numberOfLeavesRemaining = temp;
            this.leavesZero = false;
            this.numberOfLeavesGreater = false;
            this.leavesAvailable = true;
            this.leavesEmpty = false;
            console.log('total days is less');
            this.NoOfPaidAndUnpaidLeave.paidLeave = this.totalDays;
            this.NoOfPaidAndUnpaidLeave.unpaidLeave = 0;
        } else if (this.totalDays == this.numberOfAvailableLeaves) {
            //numberOfLeavesZero
            let temp1 = this.numberOfAvailableLeaves - this.totalDays;
            this.numberOfLeavesZero = temp1;
            this.numberOfLeavesGreater = false;
            this.leavesAvailable = false;
            this.leavesZero = true;
            this.leavesEmpty = false;
            console.log('total days is eqal');
            this.NoOfPaidAndUnpaidLeave.paidLeave = this.totalDays;
            this.NoOfPaidAndUnpaidLeave.unpaidLeave = 0;
        } else {
            let warningMsg = 'You have no more paid leaves, you have to select unpaid leaves for remaining';
            let temp2 = this.numberOfAvailableLeaves - this.totalDays;
            if (this.totalDays > this.numberOfAvailableLeaves) {
                this.numberOfLeavesGreater = warningMsg;
            }
            // this.numberOfLeavesGreater = temp2;
            this.leavesAvailable = false;
            this.leavesZero = false;
            this.leavesEmpty = true;
            //numberOfLeavesGreater
            console.log('total days is greater');
            this.NoOfPaidAndUnpaidLeave.paidLeave = this.numberOfAvailableLeaves;
            this.NoOfPaidAndUnpaidLeave.unpaidLeave = this.totalDays - this.numberOfAvailableLeaves;

        }
        console.log('noOfDaysDetails@@ ', this.NoOfPaidAndUnpaidLeave);
    }

    handleSaveClickWFH() {

        if (!this.wfhRequest.FromDate || !this.wfhRequest.ToDate) {
            this.isDisableSave = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter both Start Date and End Date.',
                    variant: 'error'
                })
            );
            return;
        }

        if (this.reasonExceedsLimit) {
            this.isDisableSave = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please limit your reason to 5000 characters or less.',
                    variant: 'error'
                })
            );
            return
        }

        if (!this.wfhRequest.Reason || this.wfhRequest.Reason.trim() === '') {
            this.isDisableSave = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Reason for leave can not be Empty. ',
                    variant: 'error'
                })
            );
            return; // Stop the function execution if reason is empty
        }
        this.wfhRequest = { ...this.wfhRequest };
        const fields = {
            Start_Date__c: this.wfhRequest.FromDate,
            End_Date__c: this.wfhRequest.ToDate,
            Reason__c: this.wfhRequest.Reason,
            Work_From_Home_Type__c: this.wfhRequest.wfhType == null ? this.wfhRequest.wfhType = 'Full Day WFH' : this.wfhRequest.wfhType,
            Number_of_Days__c: this.wfhRequest.numberOfDays,
            Employee__c: this.wfhRequest.wfhEmployee
        };
        console.log("Inside handle save 1")
        const currentDate = new Date();
        const currentYear = currentDate.getFullYear();
        const currentMonth = currentDate.getMonth() + 1;
        const formattedMonth = currentMonth < 10 ? `0${currentMonth}` : `${currentMonth}`;
        const currentDay = currentDate.getDate();
        const formattedDay = currentDay < 10 ? `0${currentDay}` : `${currentDay}`;
        const formattedCurrentDate = `${currentYear}-${formattedMonth}-${formattedDay}`;
        if (fields.Start_Date__c > fields.End_Date__c) {
            this.isDisableSave = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Start date should be earlier than end date.',
                    variant: 'error'
                })
            );
                return;
        }
        else if (fields.Start_Date__c < formattedCurrentDate) {
           
            const isConfirmed = confirm("Warning: Start date is in the past. Do you want to proceed?");
    
            if (!isConfirmed) {
                // User chose not to proceed, return without saving
                this.isDisableSave = false;
                return;
            }
            else if (fields.Start_Date__c > fields.End_Date__c) {
                 this.isDisableSave = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Start date should be earlier than end date.',
                    variant: 'error'
                })
            );
                return;
            }
        }  
        // else {
            this.isModalOpenWFH = false;
            saveWFHData({ wfhRequest: this.wfhRequest, EmpRecordId: this.empRecordId, numberOfDays: this.totalDays })
                .then(result => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Record Created',
                            message: 'Record created successfully',
                            variant: 'success'
                        })
                    );
                    console.log('OUTPUTresult : ', result);
                    if (this.empDetails.Manager__c) {
                        sendEmailNotification({ employeeId: this.empRecordId, managerId: this.empDetails.Manager__c })
                            .then(() => {
                                console.log('Email notification sent successfully');
                            })
                            .catch(error => {
                                console.error('Error sending email notification:', error);
                            });
                    }
                    
                    this.isModalOpenWFH = false;
                    this.wfhRequest = {};
                })
                
                .catch(error => {
                    if (error.body && error.body.message) {
                        // Display the error message to the user
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                // message: error.body.message,
                                message: 'Work From Home request already applied for same date.' ,
                                variant: 'error'
                            })
                        );
                    } else {
                        console.error('Error:', error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'An error occurred while saving records.',
                                variant: 'error'
                            })
                        );
                    }
                });
      
    }

    handleSaveClickLEAVE(event) {
        this.isDisableSave = true;
        this.isSpinnerLoad = true;
        
       // this.getLeaveRequestData();
       getLeaveRequests({ employeeId: this.empRecordId })
            .then(result => {
                console.log('empRecordId-------->',employeeId);
                console.log("getLeaveRequests Result",result);
                if(result.Number_of_Leaves__c != null || result.Number_of_Leaves__c != undefined){
                    this.numberOfAvailableLeaves = result.Number_of_Leaves__c;
                }
                console.log("this.leaveRequestFromDate:@@@@@ ", this.leaveRequest.FromDate);
                console.log("this.leaveRequestToDate:@@@@@ ", this.leaveRequest.ToDate);

                if (!this.leaveRequest.FromDate || !this.leaveRequest.ToDate) {
                     this.isDisableSave = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please enter both Start Date and End Date.',
                            variant: 'error'
                        })
                    );
                    return;
                }
                if (this.isRequired_FromDura || this.isRequired_ToDura) {
                     this.isDisableSave = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Select an Option for Leave Type . ',
                            variant: 'error'
                        })
                    );
                    return; // Stop the function execution if reason is empty
                }
                if (!this.leaveRequest.Reason || this.leaveRequest.Reason.trim() === '') {
                     this.isDisableSave = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Reason for leave can not be Empty. ',
                            variant: 'error'
                        })
                    );
                    return; // Stop the function execution if reason is empty
                
                }
                if (this.reasonExceedsLimit) {
                     this.isDisableSave = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please limit your reason to 5000 characters or less.',
                            variant: 'error'
                        })
                    );
                    return;
                }
                
                console.log("in save button calling:@@@@@ ", this.totalDays);
                this.leaveRequest = { ...this.leaveRequest };
                const fields = {
                    From_Date__c: this.leaveRequest.FromDate,
                    To_Date__c: this.leaveRequest.ToDate,
                    Reason_for_Leave__c: this.leaveRequest.Reason,
                    Leave_Type__c: this.leaveRequest.leaveType,
                    Leave_Duration__c: this.leaveRequest.leaveDuration == null ? this.leaveRequest.leaveDuration = 'Full Day' : this.leaveRequest.leaveDuration,
                    From_Date_Leave__c: this.leaveRequest.fromDateLeaveDurationOption,
                    To_Date_Leave__c: this.leaveRequest.toDateleaveDurationOption,
                };
                console.log('this.leaveRequest.leaveType  @@!%%%%--> ', this.leaveRequest.leaveType);
                console.log("Inside handle save 1")
                const currentDate = new Date();
                const currentYear = currentDate.getFullYear();
                const currentMonth = currentDate.getMonth() + 1;
                const formattedMonth = currentMonth < 10 ? `0${currentMonth}` : `${currentMonth}`;
                const currentDay = currentDate.getDate();
                const formattedDay = currentDay < 10 ? `0${currentDay}` : `${currentDay}`;
                const formattedCurrentDate = `${currentYear}-${formattedMonth}-${formattedDay}`;
                if (fields.From_Date__c > fields.To_Date__c) {
                     this.isDisableSave = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Start date should be earlier than end date.',
                            variant: 'error'
                        })
                    );
                    return;

                }
                else if (fields.From_Date__c < formattedCurrentDate) {
        
                    const isConfirmed = confirm("Warning: Start date is in the past. Do you want to proceed?");
            
                    if (!isConfirmed) {    
                        this.isDisableSave = false;            
                        return;

                    }
                    else if (fields.From_Date__c > fields.To_Date__c) {
                         this.isDisableSave = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Start date should be earlier than end date.',
                            variant: 'error'
                        })
                    );
                        return;
                    }
                    
                } 
               
                if (!this.leaveRequest.fromDateLeaveDurationOption && !this.leaveRequest.toDateleaveDurationOption && !this.leaveRequest.leaveDuration) {
                    // Set leaveDuration to 'Full Day'
                    this.leaveRequest.leaveDuration = 'Full Day';
                } 
                
                console.log("this.totalDays111",this.totalDays);
                console.log("this.numberOfAvailableLeaves111",this.numberOfAvailableLeaves);
                if (this.totalDays > this.numberOfAvailableLeaves) {
                    this.NoOfPaidAndUnpaidLeave.paidLeave = this.numberOfAvailableLeaves;
                    this.NoOfPaidAndUnpaidLeave.unpaidLeave = this.totalDays - this.numberOfAvailableLeaves;
                }
                    console.log("apex caslllllaall:@@@@@ ", this.totalDays);
                    console.log('this.this.NoOfPaidAndUnpaidddddddddddddddddLeave;;--<>' , JSON.parse(JSON.stringify(this.NoOfPaidAndUnpaidLeave)));
                    this.isModalOpenLEAVE = false;
                    this.isModalOpenLEAVE = false;
                    console.log('this.isModalOpenLEAVE 11111@@@@@',this.isModalOpenLEAVE);
                    saveLeaveData({ leaveRequest: this.leaveRequest, EmpRecordId: this.empRecordId, numberOfDays: this.totalDays, paidLeave: this.NoOfPaidAndUnpaidLeave.paidLeave, unpaidLeave: this.NoOfPaidAndUnpaidLeave.unpaidLeave })
                        .then(result => {
                            this.totalDays = 0;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Leave Request',
                                    message: 'Leave request has been sent.',
                                    variant: 'success',
                                })
                                
                            );
                            console.log('OUTPUTresult : ', result);
                            
                            console.log('this.isModalOpenLEAVE 22222 @@@@@',this.isModalOpenLEAVE);
                            // location.reload();
                            this.leaveRequest = {};
                            this.formattedFromDate = '-';
                            this.formattedToDate = '-';
                            this.showLeaveDuration = false;
                            this.isDisableSave = false;
                            // return refreshApex(this.parsedValue);
                        })
                        
                        .catch(error => {
                            console.log('error::>> ', JSON.stringify(error));
                            if (error.body && error.body.message) {
                                // Display the error message to the user
                                 this.isDisableSave = false;
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error',
                                        // message: error.body.message,
                                        message: 'Leave request already applied for same date.' ,
                                        variant: 'error'
                                    })
                                    
                                );
                                    
                            } else {
                                 this.isDisableSave = false;
                                console.error('Error:', error);
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error',
                                        message: 'An error occurred while saving records.',
                                        variant: 'error'
                                    })
                                );
                            }
                        });
                       
                //console.log('Get number of available leaves', result.Number_of_Leaves__c);
            })
            .catch(error => {
                console.error('Error:', error);
            });
            

    }
    
    handleClockinoutBtn(event) {
        const btnName = event.target.name;
        if (btnName === 'clockin') {
            this.hour = 0;
            this.minute = 0;
            this.second = 0;
            localStorage.setItem('clockInOutState', 'Clock-in');
            localStorage.setItem('clockinTimestamp', new Date().getTime());
            this.isClockinorout = false;
            this.currentClockInOutStatus = 'Clock-in';
            this.clockInTime = new Date();
            this.updateEmpRecords();
            this.insertClockinRecordsMethod();
            this.isDisableClockoutFor1min = true;
            setTimeout(() => {
                this.isDisableClockoutFor1min = false;
            }, 60000);
            // this.setIntervalId();
            const formattedTime = this.clockInTime.toLocaleTimeString();
            this.getAttendanceTotalClockInHoursSinceLogin(formattedTime);
            //this.getClockInTimeDifference(formattedTime);
        }
        else if (btnName === 'clockout') {
            localStorage.setItem('clockInOutState', 'Clock-out');
            clearInterval(this.setIntervalId);
            if (btnName === 'clockout') {
                this.isClockinorout = true;
                this.currentClockInOutStatus = 'Clock-out';
                this.updateEmpRecords();
                this.updateClockoutRecordsMethod();
            }
            
        }
        //this.getAttendanceTotalClockInHoursSinceLogin()

    }

    formatTime(time) {
        let hours = time.getHours();
        let minutes = time.getMinutes();
        let seconds = time.getSeconds();
        let suffix = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12;
        hours = hours ? hours : 12;
        minutes = minutes < 10 ? '0' + minutes : minutes;
        seconds = seconds < 10 ? '0' + seconds : seconds;
        return `${hours}:${minutes}:${seconds} ${suffix}`;
    }


    timeoutFunction() {
        const timeout = setTimeout(function () {
            this.showTime();
        }.bind(this), 1000
        )
    }
    showTime() {
        let date = new Date();
        let session = 'AM';
        this.hour = date.getHours();
        this.minute = date.getMinutes();
        this.second = date.getSeconds();
        this.date = this.month_names_short[date.getMonth()] + ' ' + date.getDate() + ', ' + date.getFullYear() + ' ' + this.day_names_short[date.getDay() - 1];
        if (this.hour == 0) {
            this.hour = 12;
        }
        if (this.hour >= 12) {
            this.hour = (this.hour > 12) ? this.hour - 12 : this.hour;
            session = 'PM';
        }
        this.hour = (this.hour < 10) ? '0' + this.hour : this.hour;
        this.minute = (this.minute < 10) ? '0' + this.minute : this.minute;
        this.second = (this.second < 10) ? '0' + this.second : this.second;
        this.time = this.hour + ':' + this.minute + ':' + this.second + ' ' + session;
        this.timeoutFunction();
    }
    updateEmpRecords() {
        updateData({ recordId: this.empRecordId, ClockInOutStatus: this.currentClockInOutStatus })
            .then(result => {
                localStorage.setItem('empDetails' + JSON.parse(result).Id, JSON.parse(JSON.stringify(result)));
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }
    insertClockinRecordsMethod() {
        console.log('@@@insertClockinRecords ::: this.empRecordId ', this.empRecordId)
        insertClockinRecords({ EmpRecordId: this.empRecordId })
            .then(result => {
                console.log('clockin result success:', result);
            })
            .catch(error => {
                console.log('clockin error:', error);
            });
    }
    updateClockoutRecordsMethod() {
        updateClockoutRecords({ EmpRecordId: this.empRecordId })
            .then(result => {
                console.log('clockout result success:', result);
            })
            .catch(error => {
                console.log('clockin error : ', error);
            });
    }
    workFromHomeSelect() {
        this.isModalOpenWFH = true;
        this.totalDays = 0;
        console.log('@@POp', this.isModalOpenWFH);
    }

    leaveOptionSelect() {
        this.getLeaveRequestData();
        this.isModalOpenLEAVE = true;
        console.log('this.isModalOpenLEAVE 333333@@@@@',this.isModalOpenLEAVE);
        this.isOnedayLeave = false;;
        this.ismultipledayLeave = false;
        console.log('@@POp', this.isModalOpenLEAVE);
        return refreshApex(this.parsedValue);
        
    }
    closeModal() {
        this.isDisableSave = false;
        this.isModalOpenWFH = false;
        this.isModalOpenLEAVE = false;
        console.log('this.isModalOpenLEAVE 44444@@@@@',this.isModalOpenLEAVE);
        this.totalDays = 0;
        this.leaveRequest = {};
        this.formattedFromDate = '-';
        this.formattedToDate = '-';
        this.showLeaveDuration = false;
        this.wfhRequest = {};
    }
    handleSubmit(event) {
        let fields = event.detail.fields;
        event.preventDefault(); // Prevent default form submission
        console.log("fields", JSON.parse(JSON.stringify(fields)));
        this.template.querySelector('lightning-record-edit-form').submit(fields); // Call the submit method
        this.isModalOpenWFH = false;
        this.isModalOpenLEAVE = false;
        console.log('this.isModalOpenLEAVE 555555@@@@@',this.isModalOpenLEAVE);
    }
    handleSuccess(event) {
        console.log('Updated Record Id is ', event.detail.id);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Successful Record Update',
                message: 'Record Updated Surccessfully!!!',
                variant: 'success'
            })
        );
        this.isModalOpenWFH = false;
        this.isModalOpenLEAVE = false;
        console.log('this.isModalOpenLEAVE 66666@@@@@',this.isModalOpenLEAVE);
        this.dispatchEvent(new CustomEvent('close'))
    }
    handleError(error) {
        console.log("error");
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Duplicate Record',
                message: 'The record you are about to create looks like a duplicate. Open an existing record instead.',
                variant: 'error'
            })
        );
    }
    handleDateTimeChange(event) {
        this.clockOutDateTime = event.target.value
        console.log('this.clockOutDateTime______', this.clockOutDateTime);
        if (event.target.name === 'clockOutDate') {
            this.clockOutDate = event.target.value
            console.log('this.clockOutDate', this.clockOutDate);
        }
        if (event.target.name === 'clockOutTime') {
            this.clockOutTime = event.target.value
            console.log('this.clockOutTime', this.clockOutTime);
        }
        if (this.clockOutDate && this.clockOutTime) {
            const date = new Date(this.clockOutDate);
            const timeParts = this.clockOutTime.split(':');
            date.setHours(parseInt(timeParts[0], 10));
            date.setMinutes(parseInt(timeParts[1], 10));
            date.setSeconds(0);
            const formattedDateTime = date.toISOString();
            console.log('Formatted DateTime Popup:', formattedDateTime);
            this.clockOutDateTime = formattedDateTime;
        }
        this.isClockOutDateTimeFilled = !!event.target.value;
    }
    handleClockOut() {
        if (this.isClockOutDateTimeFilled) {
            console.log('Formatted Clock Out DateTime:', this.clockOutDateTime);
            let formatedDateAndTime = this.lastForgetClockinDate + ' ' + this.clockOutTime;
            this.saveClockOutRecord(formatedDateAndTime);
        }
    }

    saveClockOutRecord(clockOutDateTime) {
        updateClockOutTime({ EmpRecordId: this.empRecordId, clockOutDateTime: clockOutDateTime })
            .then(result => {
                console.log('Clock-out record saved successfully:', result);
                this.isClockOutForget = false;
            })
            .catch(error => {
                console.error('Error saving clock-out record:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Clock Out Time cannot be less than Clock In Time.',
                        variant: 'error'
                    })
                );
            });
    }
    get isClockOutDateTimeNotFilled() {
        return !this.isClockOutDateTimeFilled;


    }


    getAttendanceTotalClockInHoursSinceLogin(givenTime) {
        console.log('Egfchdejfvg_________', this.empRecordId);
        getAttendanceTotalClockInHours({
            EmpRecordId: this.empRecordId
        }).then(result => {
            console.log('Clock-out record saved successfully Since @@##:', result);
            // const timeString = result;

            // Split the result by 'Hrs:' and 'Min' to extract hours and minutes
            const timeParts = result.split(/Hrs:|Min/);

            let hours = 0;
            let minutes = 0;
            if (timeParts.length === 3) {
                hours = parseInt(timeParts[0]);
                minutes = parseInt(timeParts[1]);
            }
            this.getClockInTimeDifference(givenTime, hours, minutes)

        }).catch(error => {
            console.error('Error saving clock-out record Since ##@@:', error);
        });

    }

    getClockInTimeDifference(givenTime, hoursToAdd, minutesToAdd) {
        const givenTimeParts = givenTime.split(':');
        let givenHours = parseInt(givenTimeParts[0], 10);
        let givenMinutes = parseInt(givenTimeParts[1], 10);
        let givenSeconds = parseInt(givenTimeParts[2], 10);

        const givenSuffix = givenTime.includes('AM') ? 'AM' : 'PM';

        if (givenSuffix === 'PM' && givenHours !== 12) {
            givenHours += 12;
        } else if (givenSuffix === 'AM' && givenHours === 12) {
            givenHours = 0;
        }


        const givenDate = new Date();
        givenDate.setHours(givenHours, givenMinutes, givenSeconds);

        this.setIntervalId = setInterval(() => {
            const currentDate = new Date();
            const timeDifference = currentDate - givenDate;

            let hours = Math.floor(timeDifference / 3600000) + hoursToAdd;
            let minutes = Math.floor((timeDifference % 3600000) / 60000) + minutesToAdd;
            //let seconds = Math.floor(((timeDifference % 3600000) % 60000) / 1000);

            if (minutes >= 60) {
                minutes = minutes - 60;
                hours = hours + 1;
            }
            this.timeDifference = `${hours} h: ${minutes} m`
        }, 1000);
    }

    //For Fetching On arrival Data
    loadAttendanceData() {
        console.log('this.empRecordId--->',this.empRecordId); 
        getAttendanceOnTimeArrival({ employeeId: this.empRecordId })
            .then(result => {
                this.attendanceData = result.map(record => ({
                    ...record,
                    arrivalStatus: record.On_Time_Arrival__c ? 'On time' : 'Late'
                }));
                console.log('result this.loadAttendanceData()-->',result);
            })
            .catch(error => {
                console.error('Error fetching attendance data:', error);
            });
    }

    //For Fetching the Data on arrival and late data 
    ontimeArrival() {
        getontimeArrival({ employeeId: this.empRecordId })
            .then(result => {
                const total = result.OnTimeArrivals + result.lateArrivals;
                this.arrivalPercentage.onTime = Math.round((result.OnTimeArrivals * 100) / total);
                this.arrivalPercentage.late = Math.round((result.lateArrivals * 100) / total);
                // console.log('result this.loadAttendanceData()-->',result);
                // console.log('counts', JSON.stringify(this.arrivalPercentage));
            })
            .catch(error => {
                console.error('Error fetching attendance data:', error);
            });
    }


}