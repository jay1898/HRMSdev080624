import { LightningElement, track, api, wire } from 'lwc';
import gettimesheetData from '@salesforce/apex/timesheetTableController.gettimesheetData';
import saveTimesheetRecords from '@salesforce/apex/timesheetTableController.saveTimesheetRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTimesheetRecordsBasedonDate from '@salesforce/apex/timesheetTableController.getTimesheetRecordsBasedonDate';
import deleteTimeSheetRecord from '@salesforce/apex/timesheetTableController.deleteTimeSheetRecord';
import getIsLockedFieldValue from '@salesforce/apex/timesheetTableController.getIsLockedFieldValue';
import getAttendanceData from '@salesforce/apex/timesheetTableController.getAttendanceData';
import getEmployeeData from '@salesforce/apex/timesheetTableController.getEmployeeData';



export default class SubForm extends LightningElement {
    @api employeeDetails;

    _customDateHandler;

    @api
    get customDateHandler() {
        return
    }
    set customDateHandler(value) {
        this.customDateHandlerChanged(value);
    }


    @track events = [{
        TaskType: '',
        ActualHour: '',
        EstimatedHour: '',
        ProjectName: '',
        TicketNo: '',
        TaskDescription: '',
        EmployeeId: '',
        TimeSheetDate: '',
        TimeSheetRecordId: ''
    }];
    @track eventDeleteEnable = false;
    @track ActEstHourOption = [];
    @track projNameOption = [];
    // @track projManagerOption = [];
    // @track SubprojOption = [];
    @track taskTypeOption = [];
    // @track mapSubproject = {};
    @track TaskType;
    picklistValues;
    @track finalDrs = {};//m
    @track DRS = [];//m
    @track isDateSelected = false;
    @track isSpinnerLoad = false;

    @track DeleteModalPopup = false;
    @track DeleteObj = {};
    currentDateDefault;

    @track isSaveButtonVisible = false;
    isAddButtonVisible = false;

    @track totalActualHours = 0;
    @track AttendanceRecordList;
    @track EmployeeCreatedDate;



    @track isTableVisible = true;

    timesheetRecords = [];
    todayDate
    addEvents(event) {
        let drsNoDetails = {
            TaskType: '',
            ActualHour: '',
            EstimatedHour: '',
            ProjectName: '',
            // ProjectManager: '',
            // SubProjectName: '',
            TicketNo: '',
            TaskDescription: '',
            EmployeeId: '',
            TimeSheetDate: '',
            TimeSheetRecordId: ''
        }
        if (this.projNameOption.length === 1) {
            drsNoDetails.ProjectName = this.projNameOption[0].value;
        }
        this.events.push(drsNoDetails);
        this.eventDeleteEnable = this.events.length > 0;
        console.log(JSON.parse(JSON.stringify(this.events)));
        // this.isSaveButtonVisible = this.events.length > 0;
    }


    deleteEvent(event) {
        console.log('@@event', event.target.dataset.index)
        var indx = parseInt(event.target.dataset.index);
        var eventData = JSON.parse(JSON.stringify(this.events));
        if (eventData[indx].TimeSheetRecordId != '') {
            this.DeleteModalPopup = true;
            this.DeleteObj.index = indx;
            this.DeleteObj.TimeSheetRecordId = eventData[indx].TimeSheetRecordId;
        }
        if (this.DeleteModalPopup == false) {
            eventData.splice(indx, 1);
            this.events = JSON.parse(JSON.stringify(eventData));
            console.log('OUTPUTEvents : ', this.events);
            this.eventDeleteEnable = eventData.length > 0;

            this.isSaveButtonVisible = eventData.length > 0;
        }

        let isValid = false;
        if(!isValid){
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = true;
            }

        });
        }
    }

    //     autosize() {
    //         let text = this.template.querySelectorAll('textarea');
    // console.log('### : text',text);
    //         text.forEach((element) => {
    //             element.rows = 1;
    //             this.resize(element);
    //         });

    //         text.forEach((element) => {
    //             element.addEventListener('input', () => {
    //                 this.resize(element);
    //             });
    //         });

    //     }

    // resize(text) {
    //     text.style.height = 'auto';
    //     text.style.height = text.scrollHeight + 'px';
    // }

    handleEventChange(event) {
        console.log('@@event', event.target.dataset.index)
        var indx = parseInt(event.target.dataset.index);
        var eventData = JSON.parse(JSON.stringify(this.events));
        eventData[indx][event.target.name] = event.target.value;
        this.events = eventData;
        console.log('all data', this.events);

        // this.totalActualHours = this.events.reduce((total, event) => {
        //     const actualHours = parseFloat(event.ActualHour) || 0; // Convert to float or default to 0
        //     return total + actualHours;
        // }, 0);

    }




    projectHandle(event) {
        console.log('this.events.length : ', this.events.length);
        console.log('this.events : ', JSON.parse(JSON.stringify(this.events)));
        let name = event.target.name;
        let index = event.target.dataset.index
        console.log('OUTPUT : ', index);
        if (name == 'Date__c') {
            this.finalDrs.Date = event.target.value;

            const comparisonDate = new Date(this.finalDrs.Date);
            const EmployeeCreatedDate = new Date(this.EmployeeCreatedDate);
            // console.log('Date(requestedDate) ', Date(requestedDate));
            // console.log('Date(this.EmployeeCreatedDate)', Date(this.EmployeeCreatedDate));
            // console.log('Date(requestedDate) < Date(this.EmployeeCreatedDate)', Date(requestedDate) < Date(this.EmployeeCreatedDate));
            if (comparisonDate < EmployeeCreatedDate) {
                this.isTableVisible = false;
            } else {
                this.isTableVisible = true;
            }

            this.getTimesheetRecords();
            console.log('this.finalDrs.Date______', this.finalDrs.Date);
            console.log('this.finalDrs.Date______', typeof this.finalDrs.Date);
            this.addButtonHideLogic(this.finalDrs.Date);

            if (this.finalDrs.Date === '' || this.finalDrs.Date === null) {
                this.isDateSelected = false; // Hide the "Add" button if the date is deselected
                console.log('this.isDateSelected____IF______', this.isDateSelected);
            } else {
                this.isDateSelected = true;
                console.log('this.isDateSelected_____ELSE_____', this.isDateSelected);
            }

            const dateSelect = new CustomEvent("getdatefromdrs", {
                detail: this.finalDrs.Date
            });
            this.dispatchEvent(dateSelect);

        }
        if (name == 'TaskType') {
            this.events[index][name] = event.target.value;
        }
        if (name == 'ActualHour') {
            this.events[index][name] = event.target.value;
        }
        if (name == 'EstimatedHour') {
            this.events[index][name] = event.target.value;
        }
        if (name == 'ProjectName') {
            let value = event.target.value;
            this.events[index][name] = value;
            this.SubprojOption = [];
            console.log('parent project Name', value);

        }

        if (name == 'TicketNo') {
            this.events[index][name] = event.target.value;
            // this.events[index]['TaskDescription'] = event.target.value + ' ' + (this.events[index]['TaskDescription']!=undefined || this.events[index]['TaskDescription']!='' ?this.events[index]['TaskDescription']:'');

        }
        if (name == 'TaskDescription') {
            // this.events[index][name] = (this.events[index]['TicketNo']!=undefined || this.events[index]['TicketNo']!='' ?this.events[index]['TicketNo']:'') +' '+ event.target.value;
            this.events[index][name] = event.target.value;
            //  this.autosize();
        }
        // fill date and employeeId in every row
        this.events[index]['EmployeeId'] = this.employeeDetails.EmpRecordId;
        this.events[index]['TimeSheetDate'] = this.finalDrs.Date;

        this.isSaveButtonVisible = this.events.length > 0;
        // this.isSaveButtonVisible = this.events[0].TaskType!='';
        console.log('isSaveButtonVisible____1_______', this.isSaveButtonVisible);

        const textarea = this.template.querySelector('lightning-textarea');
        textarea.style.height = 'auto';
        textarea.style.height = `${textarea.scrollHeight}px`;
        this.textareaStyle = textarea.getAttribute('style');

    }


    connectedCallback() {

        setTimeout(() => {
            const style = document.createElement('style');
            style.innerText = `
            lightning-datepicker .slds-form-element__control.slds-input-has-icon.slds-input-has-icon_right {
                color: #00A129;
                // border: 2px solid #00A129;
                border-radius: 5px;
                // padding: 9px;
                // font-size: 17px;
                // font-weight: bold;
            }
            .hide-date-icon lightning-button-icon .slds-button.slds-button_icon.slds-button_icon-bare{
                color: #00A12C;
                display:none !important
            }
            lightning-datepicker .slds-input{
                padding: 5px;
                font-size: 17px;
                font-weight: bold;
                background: #DEF5E4;
                border: none !important;
                width:100%;
            }
            lightning-datepicker .slds-dropdown-trigger.slds-dropdown-trigger_click.slds-size_1-of-1{
                display:flex;
            }
            lightning-datepicker .slds-form-element__label{
                display:none;
            }

            lightning-base-combobox .slds-combobox__input.slds-input_faux{
                color: #194051;
                border-radius: 10px;
                padding: 6px;
                font-size: 15px;
                width:153px;
                // background: #EAECF1;
            }
            
            .button-border button{
                    height: 45px;
                    width: 45px;
                    border-radius: 10px;
                    // background: #EAECF1;
            }
            .ticket-no lightning-primitive-input-simple .slds-input{
                color: #194051;
                border-radius: 10px;
                padding: 6px;
                font-size: 15px;
                padding-left:10px;
                // background: #EAECF1;
            }
            .large-svg lightning-primitive-icon .slds-button__icon{
                    width: 1.5rem;
                    height: 1.5rem;
                    color: #194051;
            }
            .description-color textarea{
                 color: #194051;
                border-radius: 10px;
                padding: 6px;
                font-size: 15px;
                padding-left:10px;
                // background: #EAECF1;
            }
             .slds-spinner .slds-spinner__dot-b:after,.slds-spinner .slds-spinner__dot-b:before,.slds-spinner .slds-spinner__dot-a:after,.slds-spinner .slds-spinner__dot-a:before,.slds-spinner_large.slds-spinner:after,.slds-spinner_large.slds-spinner:before{
              background-color: #37a000 !important;
            }
            // lightning-input {
            //     width:35%;
            // }
            `;
            this.template.querySelector('.overrideStyle').appendChild(style);
        }, 100);
        

        getAttendanceData({ employeeId: this.employeeDetails.EmpRecordId })
            .then(result => {
                console.log('OUTPUTresult## : ', result);
                this.AttendanceRecordList = result;
            })
            .catch(error => {
                console.error('Error fetching isHideAdd__c Field Value:', error);
            });
        console.log('OUTPUTEmployeeDetails : ', this.employeeDetails);


        getEmployeeData({ employeeId: this.employeeDetails.EmpRecordId })
            .then(result => {
                console.log('getEmployeeData OUTPUTresult## : ', result);
                const createDate = result.CreatedDate;
                const dateObject = new Date(createDate);
                const formattedDate = dateObject.toISOString().split('T')[0];
                console.log(formattedDate);
                this.EmployeeCreatedDate = formattedDate;
            })
            .catch(error => {
                console.error('Error fetching  Value:', error);
            });
        console.log('OUTPUTEmployeeDetails : ', this.employeeDetails);



        //current date logic by Ahil
        const currentDate = new Date();
        const formattedDate = currentDate.toISOString().split('T')[0];
        this.todayDate = formattedDate;
        this.finalDrs.Date = formattedDate;
        this.currentDateDefault = formattedDate;
        console.log('formattedDate', formattedDate);
        this.getTimesheetRecords();


        gettimesheetData({ employeeId: this.employeeDetails.EmpRecordId }).then(result => {
            this.parsedValue = result;
            console.log('Json Parse Data ' + this.parsedValue.TaskType);
            for (var i = 0; i < this.parsedValue.TaskType.length; i++) {
                console.log('Json Parse Data ', this.parsedValue.TaskType[i]);
                this.taskTypeOption.push({ 'label': this.parsedValue.TaskType[i], 'value': this.parsedValue.TaskType[i] });

            }
            for (var i = 0; i < this.parsedValue.ActEstHour.length; i++) {
                //console.log('Json Parse Data ',this.parsedValue.ActEstHour[i]);
                this.ActEstHourOption.push({ 'label': this.parsedValue.ActEstHour[i], 'value': this.parsedValue.ActEstHour[i] });

            }
            for (var i = 0; i < this.parsedValue.ProjectName.length; i++) {
                console.log('Json Parse Data ', this.parsedValue.ProjectName[i]);
                this.projNameOption.push({ 'label': this.parsedValue.ProjectName[i], 'value': this.parsedValue.ProjectName[i] });

            }
            this.isDateSelected = true;
            this.eventDeleteEnable = this.events.length > 0;

            if (this.projNameOption.length === 1) {
                this.events[0].ProjectName = this.projNameOption[0].value;
            }
            const selectedEvent = new CustomEvent("dataready", {
					isLoading: false
				});
				// Dispatches the event.
				this.dispatchEvent(selectedEvent);
        }).catch(err => console.log(err));

        this.fetchIsLockedFieldValue();

    }


    handleSaveClick() {
        // to make fields required
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }

        });
        // Validate the "Ticket No" field specifically
        if (isValid) {
            this.events.forEach(event => {
                if (!event.TicketNo.trim()) {
                    isValid = false;
                    this.showToast('Error', 'Ticket No is required', 'error');
                }
            });
        }

        if (!isValid) return;


        this.isSpinnerLoad = true;
        this.DRS = [];
        this.DRS = this.events;
        this.finalDrs = { ...this.finalDrs, DRS: this.DRS };
        console.log('finalDrsOUTPUT : ', JSON.parse(JSON.stringify(this.finalDrs)));
        saveTimesheetRecords({ timesheetList: JSON.parse(JSON.stringify(this.finalDrs)), EmpRecordId: this.employeeDetails.EmpRecordId, selectedDate: this.finalDrs.Date })
            .then(result => {
                console.log('OUTPUTresult : ', result);
                this.showToast('Success', 'Timesheet Records Saved Successfully.', 'success');
                this.events = [];
                this.isSaveButtonVisible = false;
                this.getTimesheetRecords();
                this.isSpinnerLoad = false;
                
            })
            .catch(error => {
                this.showToast('Error', 'An error occurred while saving records', 'error');
                console.error(error);
                this.isSpinnerLoad = false;
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
    getTimesheetRecords() {
        this.events = [];
        getTimesheetRecordsBasedonDate({ selectedDate: this.finalDrs.Date, employeeId: this.employeeDetails.EmpRecordId })
            .then(result => {
                console.log('OUTPUT SelectedDate : ', result);
                let res = JSON.parse(result); // Parse the entire result JSON

                if (res && res.DRS && res.DRS.length > 0) {
                    this.events = res.DRS; // Assign the array directly

                    // Calculate the total Actual Hours
                    this.totalActualHours = this.events.reduce((total, event) => {
                        const actualHours = parseFloat(event.ActualHour) || 0; // Convert to float or default to 0
                        return total + actualHours;
                    }, 0);

                } else {
                    this.addEvents();
                }

                console.log('Events : ', this.events);
                this.eventDeleteEnable = this.events.length > 0;
            })
            .catch(error => {
                console.error(error);
            });
    }



    handleActualHourChange(event) {
        const index = parseInt(event.target.dataset.index);
        const newValue = parseFloat(event.target.value) || 0;
        const eventData = JSON.parse(JSON.stringify(this.events));
        eventData[index].ActualHour = newValue;

        // Recalculate the total Actual Hours and update the display
        this.totalActualHours = eventData.reduce((total, event) => {
            const actualHours = parseFloat(event.ActualHour) || 0;
            return total + actualHours;
        }, 0);

        this.events = eventData;
    }


    get computedTotalActualHours() {
        return this.events.reduce((total, event) => {
            const actualHours = parseFloat(event.ActualHour) || 0;
            return total + actualHours;
        }, 0).toFixed(2); // Optionally, you can round the result to 2 decimal places
    }

    handleDeleteYesClick(event) {
        this.isSpinnerLoad = true;
        deleteTimeSheetRecord({ TimeSheetRecordId: this.DeleteObj.TimeSheetRecordId })
            .then(result => {
                console.log('DeleteResult', result);
                this.DeleteModalPopup = false;
                console.log('@@event', event.target.dataset.index)
                var indx = this.DeleteObj.index;
                var eventData = JSON.parse(JSON.stringify(this.events));
                eventData.splice(indx, 1);
                this.events = JSON.parse(JSON.stringify(eventData));
                console.log('OUTPUTEvents : ', this.events);
                this.eventDeleteEnable = eventData.length > 0;
                this.showToast('Success', 'Records Deleted Successfully', 'success');
                this.isSpinnerLoad = false;
            })
            .catch(error => {
                console.log('DeleteError', error);
                this.showToast('Error', 'An error occurred while deleting records', 'error');
                this.isSpinnerLoad = false;
            });
    }
    handleDeleteNoClick() {
        this.DeleteModalPopup = false;
    }

    fetchIsLockedFieldValue() {
        // Call the Apex method and log the result in the console.
        getIsLockedFieldValue({ employeeId: this.employeeDetails.EmpRecordId })
            .then(result => {
                if (result) {
                    this.isLocked = result;
                    console.log('IsLocked__c Field Value______________:', this.isLocked);
                }
            })
            .catch(error => {
                console.error('Error fetching IsLocked__c Field Value______________:', error);
            });
    }



    customDateHandlerChanged(requestedDate) {
        console.log('dfdfer@@ ', requestedDate);
        const comparisonDate = new Date(requestedDate);
        const EmployeeCreatedDate = new Date(this.EmployeeCreatedDate);
        // console.log('Date(requestedDate) ', Date(requestedDate));
        // console.log('Date(this.EmployeeCreatedDate)', Date(this.EmployeeCreatedDate));
        // console.log('Date(requestedDate) < Date(this.EmployeeCreatedDate)', Date(requestedDate) < Date(this.EmployeeCreatedDate));
        if (comparisonDate < EmployeeCreatedDate) {
            this.isTableVisible = false;
        } else {
            this.isTableVisible = true;
        }
        if (requestedDate) {

            this.addButtonHideLogic(requestedDate);
            this.finalDrs.Date = requestedDate;
            this.currentDateDefault = requestedDate;
            this.getTimesheetRecords();
            console.log('this.finalDrs.Date______', this.finalDrs.Date);

            if (this.finalDrs.Date === '' || this.finalDrs.Date === null) {
                this.isDateSelected = false;
                console.log('this.isDateSelected____IF______', this.isDateSelected);
            } else {
                this.isDateSelected = true;
                console.log('this.isDateSelected_____ELSE_____', this.isDateSelected);
            }
        }
    }

    addButtonHideLogic(requestedDate) {
        if (requestedDate > this.todayDate) {
            this.isAddButtonVisible = false;
        } else {
            for (let x in this.AttendanceRecordList) {
                if (this.AttendanceRecordList[x].Date__c == requestedDate) {
                    this.isAddButtonVisible = this.AttendanceRecordList[x].isAddDisable__c;
                    break;
                }
            }
        }
    }



}