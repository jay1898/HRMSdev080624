import { LightningElement, track, api, wire } from 'lwc';
import gettimesheetData from '@salesforce/apex/timesheetTableController.gettimesheetData';
import saveTimesheetRecords from '@salesforce/apex/timesheetTableController.saveTimesheetRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTimesheetRecordsBasedonDate from '@salesforce/apex/timesheetTableController.getTimesheetRecordsBasedonDate';
import deleteTimeSheetRecord from '@salesforce/apex/timesheetTableController.deleteTimeSheetRecord';
import getIsLockedFieldValue from '@salesforce/apex/timesheetTableController.getIsLockedFieldValue';
import getAttendanceData from '@salesforce/apex/timesheetTableController.getAttendanceData';
import getEmployeeData from '@salesforce/apex/timesheetTableController.getEmployeeData';
import { RefreshEvent } from 'lightning/refresh';

export default class SubForm extends LightningElement {
    @api employeeDetails;

    _customDateHandler;

    mobileView = false;
    @track windowWidth;

    @api
    get customDateHandler() {
        return
    }
    set customDateHandler(value) {
        this.customDateHandlerChanged(value);
    }
    taskTypeError = '';
    ticketNoError = '';
    @track events = [{
        TaskType: '',
        ActualHour: '',
        EstimatedHour: '',
        ProjectName: '',
        TicketNo: '',
        TaskDescription: '',
        ComponentChange : '',
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
    isPreviousDataIsNULL = false;
    isEmployeeNotJoinedYet = false;
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
            ComponentChange : '',
            EmployeeId: '',
            TimeSheetDate: '',
            TimeSheetRecordId: '',
            // IsLocked:true
        }
        if (this.projNameOption.length === 1) {
            drsNoDetails.ProjectName = this.projNameOption[0].value;
        }
        // if(this.todayDate==this.finalDrs.Date){
        //     drsNoDetails.IsLocked=false;
        // }
        this.events.push(drsNoDetails);
        this.eventDeleteEnable = this.events.length > 0;
        console.log('this.eventDeleteEnable --->  ',this.eventDeleteEnable);
        // this.isSaveButtonVisible = this.events.length > 0;
        this.isPreviousDataIsNULL = false;

         if (this.events.length > 1) {
        setTimeout(function() {
            let tasktypes = this.template.querySelectorAll(".tasktype");
            if (tasktypes != null) {
                tasktypes[tasktypes.length - 1].focus();
            }
        }.bind(this), 100);
    }
    // setTimeout(function(){
        //     let tasktypes =  this.template.querySelectorAll(".tasktype"); 
        // if(tasktypes!=null){
        //     tasktypes[tasktypes.length-1].focus();
        // }

        // }.bind(this),100)
        
    }

    deleteEvent(event) {
        console.log('@@event', event.target.dataset.index)
        var indx = parseInt(event.target.dataset.index);
        var eventData = JSON.parse(JSON.stringify(this.events));
        console.log('@@@eventData:', eventData);
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
    }

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

    handleBlur(event) {

        let name = event.target.name;
        let index = event.target.dataset.index
        if (name == 'TaskType') {
            // this.events[index][name] = event.target.value;
            const fieldName = event.target.name;
            const fieldValue = event.target.value;
            this.events[index][fieldName] = fieldValue;
            if (!fieldValue.trim()) {
                this.events[index].taskTypeError = 'Please Enter Task Type.';
            } else {
                this.events[index].taskTypeError = '';
            }
            this.events[index][name] = event.target.value;
        }
        if (name == 'TicketNo') {
            // this.events[index]['TaskDescription'] = event.target.value + ' ' + (this.events[index]['TaskDescription']!=undefined || this.events[index]['TaskDescription']!='' ?this.events[index]['TaskDescription']:'');
            const fieldName = event.target.name;
            const fieldValue = event.target.value;
            this.events[index][fieldName] = fieldValue;

            if (!fieldValue.trim()) {
                this.events[index].ticketNoError = 'Please Enter Ticket No.';
            } else {
                this.events[index].ticketNoError = '';
            }
            this.events[index][name] = event.target.value;
        }
        if (name == 'ActualHour') {
            // this.events[index][name] = event.target.value;
            const fieldName = event.target.name;
            const fieldValue = event.target.value;
            this.events[index][fieldName] = fieldValue;

            if (!fieldValue.trim()) {
                this.events[index].actualHoursError = 'Please Enter Actual Hours.';
            } else {
                this.events[index].actualHoursError = '';
            }
            this.events[index][name] = event.target.value;
        }
        if (name == 'TaskDescription') {
            // this.events[index][name] = event.target.value;
            const fieldName = event.target.name;
            const fieldValue = event.target.value;
            this.events[index][fieldName] = fieldValue;

            if (!fieldValue.trim()) {
                this.events[index].descriptionError = 'Please Enter Task Description.';
            } else {
                this.events[index].descriptionError = '';
            }
            this.events[index][name] = event.target.value;
        }
        if (name == 'ComponentChange') {
            // this.events[index][name] = event.target.value;
            const fieldName = event.target.name;
            const fieldValue = event.target.value;
            this.events[index][fieldName] = fieldValue;

            // if (!fieldValue.trim()) {
            //     this.events[index].ComponentChangeError = 'Please Enter Component Change.';
            // } else {
            //     this.events[index].ComponentChangeError = '';
            // }
            this.events[index][name] = event.target.value;
        }
        if (name == 'ProjectName') {
            let value = event.target.value;
            this.events[index][name] = value;
            this.SubprojOption = [];
            console.log('parent project Name', value);

            const fieldName = event.target.name;
            const fieldValue = event.target.value;
            this.events[index][fieldName] = fieldValue;

            if (!fieldValue.trim()) {
                this.events[index].projectnameError = 'Please Enter Project Name.';
            } else {
                this.events[index].projectnameError = '';
            }
            this.events[index][name] = event.target.value;
        }


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
                this.isEmployeeNotJoinedYet = true;
                this.isPreviousDataIsNULL = false;
            } else {
                this.isTableVisible = true;
                this.isPreviousDataIsNULL = false;
                this.isEmployeeNotJoinedYet = false;
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
            console.log('if task type ');
            // this.events[index][name] = event.target.value;
            console.log('get index and name task type ');
            const fieldName = event.target.name;
            const fieldValue = event.target.value;
            this.events[index][fieldName] = fieldValue;
            if (!fieldValue.trim()) {
                console.log('in ticket no if');
                this.events[index].taskTypeError = 'Please enter Ticket No.';
                console.log('ticket no error', this.events[index].taskTypeError);
            } else {
                console.log('in ticket no else');
                console.log('ticket null');
                this.events[index].taskTypeError = '';
            }
            console.log('in ticket no outside');
           // this.isSaveButtonVisible = true;
            console.log('Save button enabled:2222222@@@@', this.isSaveButtonVisible); 
            this.events[index][name] = event.target.value;
            console.log('got the value');
            
        }
        if (name == 'ActualHour') {
            // this.events[index][name] = event.target.value;
            const fieldName = event.target.name;
            const fieldValue = event.target.value;
            this.events[index][fieldName] = fieldValue;
            if (!fieldValue.trim()) {
                this.events[index].actualHoursError = 'Please Enter Actual Hours.';
            } else {
                this.events[index].actualHoursError = '';
            }
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

            const fieldName = event.target.name;
            const fieldValue = event.target.value;
            this.events[index][fieldName] = fieldValue;
            if (!fieldValue.trim()) {
                this.events[index].projectnameError = 'Please Enter Project Name.';
            } else {
                this.events[index].projectnameError = '';
            }
            this.events[index][name] = event.target.value;
        }

        if (name == 'TicketNo') {
            // this.events[index]['TaskDescription'] = event.target.value + ' ' + (this.events[index]['TaskDescription']!=undefined || this.events[index]['TaskDescription']!='' ?this.events[index]['TaskDescription']:'');
            const fieldName = event.target.name;
            const fieldValue = event.target.value;
            this.events[index][fieldName] = fieldValue;
            if (!fieldValue.trim()) {
                this.events[index].ticketNoError = 'Please enter Ticket No.';
            } else {
                this.events[index].ticketNoError = '';
            }
            this.events[index][name] = event.target.value;
        }
        if (name == 'TaskDescription') {
            // this.events[index][name] = (this.events[index]['TicketNo']!=undefined || this.events[index]['TicketNo']!='' ?this.events[index]['TicketNo']:'') +' '+ event.target.value;
            // this.events[index][name] = event.target.value;
            //  this.autosize();
            const fieldName = event.target.name;
            const fieldValue = event.target.value;
            this.events[index][fieldName] = fieldValue;
            if (!fieldValue.trim()) {
                this.events[index].descriptionError = 'Please Enter Task Description.';
            } else {
                this.events[index].descriptionError = '';
            }
            this.events[index][name] = event.target.value;
        }
        if (name == 'ComponentChange') {
           
            const fieldName = event.target.name;
            const fieldValue = event.target.value;
            this.events[index][fieldName] = fieldValue;
            // if (!fieldValue.trim()) {
            //     this.events[index].ComponentChangeError = 'Please Enter Component Change.';
            // } else {
            //     this.events[index].ComponentChangeError = '';
            // }
            this.events[index][name] = event.target.value;
        }

        // fill date and employeeId in every row
        this.events[index]['EmployeeId'] = this.employeeDetails.EmpRecordId;
        this.events[index]['TimeSheetDate'] = this.finalDrs.Date;

        this.isSaveButtonVisible = this.events.length > 0 || this.events.length < this.formattedDate;
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

            // lightning-base-combobox .slds-combobox__input.slds-input_faux{
            //     color: #194051;
            //     border-radius: 10px;
            //     padding: 6px;
            //     font-size: 15px;
            //     width:183px;
            //     // background: #EAECF1;

            // }


            lightning-base-select .slds-select__input.slds-input_faux{           
                color: #194051;
                border-radius: 10px;
                padding: 6px;
                font-size: 15px;
                padding-left: 10px;
                / line-height: 1rem; /
                height: 40px;
                padding-left: 14px;
                margin-right: 14px;
                margin-top: 20px;
                width:183px;
            }
                
            .slds-select_container:before {
                border-bottom: 5px solid currentColor;
                top: calc((var(--lwc-lineHeightButtonSmall,1.75rem) / 2) - 6px);
                margin-top: 7px;
            }
            .slds-select_container:after {
                bottom: calc((var(--lwc-lineHeightButtonSmall,1.75rem) / 2) - 0px);
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
            .TaskDescriptionClass  textarea:focus {
                height: 10em;
                width:500px
            }
            .ComponentChangeClass  textarea:focus {
                height: 10em;
                width:500px
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
            lightning-select .slds-select {
                border-radius:10px;
                height: 44px;
            }
            .datePickerBlock .slds-input:active , .datePickerBlock .slds-input:focus {
                box-shadow: unset;
               
            }
            .datePickerBlock .slds-input {
                 cursor:pointer;
            }
            // lightning-input {
            //     width:35%;
            // }
            `;
            this.template.querySelector('.overrideStyle').appendChild(style);

            
        }, 100);
        var isCtrl = false;
        window.addEventListener('keydown', function(e){
            
            if (e.keyCode == 17) {
                e.preventDefault();
                isCtrl = true;
            }


        if (e.keyCode == 83 && isCtrl){
            e.preventDefault();
            if(this.isSaveButtonVisible==true){

                this.handleSaveClick();
            }
            isCtrl = false;
        }
        }.bind(this));
        
        
        
        
        
        
        var pressedKeys = {};
				
				window.addEventListener('keydown', function(event) {
						pressedKeys[event.key] = true;
						if ( pressedKeys['Control'] && (pressedKeys['s'] || pressedKeys['S'])) {
								
								event.preventDefault(); // Prevent the default browser save action
								 event.stopPropagation();
								// Add your save logic here
								 if(this.isSaveButtonVisible==true &&  this.isSpinnerLoad ==false){
										
										 this.handleSaveClick();
											 
										 pressedKeys = {};
								 }
						}
				}.bind(this));
				window.addEventListener('keyup', function(event) {
						pressedKeys[event.key] = false;
				}.bind(this));

        
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

        this.handleMobileView();

    }

    handleMobileView(){
        // console.log('mobile view -------------------------------------------------------------------------------------->');
        this.windowWidth = window.innerWidth;
        if(this.windowWidth < 480){
            // console.log('width size true----------------------------------------------------------------------------->', this.windowWidth);
            this.mobileView = true;

            setTimeout(() => {
                const style = document.createElement('style');
                style.innerText = ` 

                    .ComponentChangeClass textarea:focus {
                        height: 200px; 
                        width: 100%;
                    }
                    .TaskDescriptionClass  textarea:focus {
                        height: 200px; 
                        width: 100%;
                    }

                    lightning-datepicker .slds-form-element__label{
                        display:none !important;
        
                    }
                    lightning-input .slds-form-element__label{
                        display:none !important;
        
                    }
                    lightning-select .slds-form-element{
                        padding-right: 0px;
                    }
                    
                    .datePickerBlock .slds-input {
                        cursor: pointer;
                        border: none;
                        background: none;
                        font-weight: bold;
                        font-size: 16px;
                        color: rgb(0, 161, 41);
                        padding: 0px;
                    }

                    .datePickerBlock .slds-input {
                        cursor:pointer;
                   }

                    
                `;
            this.template.querySelector('.overrideStyle').appendChild(style);
                
        }, 100);
            
        }
        else{
            // console.log('width size false----------------------------------------------------------------------------->', this.windowWidth);
            this.mobileView = false;
        }
    }

    taskTypeInputClass(index) {
        return this.events[index].taskTypeError ? 'input error-border' : 'input';
    }
    ticketNoInputClass(index) {
        return this.events[index].ticketNoError ? 'error-border' : '';
    }
    descriptionInputClass(index) {
        return this.events[index].descriptionError ? 'error-border' : '';
    }
    componentChangeInputClass(index) {
        return this.events[index].ComponentChangeError ? 'error-border' : '';
    }
    actualHoursInputClass(index) {
        return this.events[index].actualHoursError ? 'error-border' : '';
    }
    projectNameInputClass(index) {
        return this.events[index].projectnameError ? 'error-border' : '';
    }
    handleSaveClick(event) {
        // to make fields required
        // let isValid = true;
        // let inputFields = this.template.querySelectorAll('.validate');
        // inputFields.forEach(inputField => {
        //     if (!inputField.checkValidity()) {
        //         inputField.reportValidity();
        //         isValid = false;
        //     }

        // });
        // Validate the "Ticket No" field specifically
        // if (isValid) {
        //     this.events.forEach(event => {
        //         if (!event.TicketNo.trim()) {
        //             isValid = false;
        //             this.showToast('Error', 'Ticket No is required', 'error');
        //         }
        //     });
        // }

        // if (!isValid) return;
        let allValid = true;
        this.events.forEach((event, index) => {
            if (!event.TaskType || !event.TaskType.trim()) {
                event.taskTypeError = 'Please Enter Task Type.';
                allValid = false;
            } else {
                event.taskTypeError = '';
            }
            if (!event.TicketNo || !event.TicketNo.trim()) {
                event.ticketNoError = 'Please Enter Ticket No.';
                allValid = false;
            } else {
                event.ticketNoError = '';
            }
            if (!event.TaskDescription || !event.TaskDescription.trim()) {
                event.descriptionError = 'Please Enter Task Description.';
                allValid = false;
            } else {
                event.descriptionError = '';
            }
            // if (!event.ComponentChange || !event.ComponentChange.trim()) {
            //     event.ComponentChangeError = 'Please Enter Component Change.';
            //     allValid = false;
            // } else {
            //     event.ComponentChangeError = '';
            // }
            if (!event.ActualHour || !event.ActualHour.trim()) {
                event.actualHoursError = 'Please Enter Actual Hours.';
                allValid = false;
            } else {
                event.actualHoursError = '';
            }
            if (!event.ProjectName || !event.ProjectName.trim()) {
                event.projectnameError = 'Please Enter Project Name.';
                allValid = false;
            } else {
                event.projectnameError = '';
            }
         });

            if (allValid) {


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
                        this.dispatchEvent(new RefreshEvent());


                })

                .catch(error => {
                    this.showToast('Error', 'An error occurred while saving records', 'error');
                    console.error(error);
                    this.isSpinnerLoad = false;
                });
        }
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

                    //show add event only if selected date is today
                    if (this.todayDate == this.finalDrs.Date) {
                        this.addEvents();
                        this.isPreviousDataIsNULL = false;
                    } else {
                        //error message for empty DRS Sheet
                        this.isPreviousDataIsNULL = true;


                        // check if yesterday time is before 2 PM, remove the error message
                        const today = new Date();
                        const yesterday = new Date();
                        yesterday.setDate(yesterday.getDate() - 1);
                        const selectedDate = new Date(this.finalDrs.Date);
                        const today2PM = new Date();
                        today2PM.setHours(14, 0, 0, 0); // Set to today 2 PM
                        if (today.getHours() < today2PM.getHours() &&
                            selectedDate.getUTCDate() == yesterday.getUTCDate()) {
                            this.isPreviousDataIsNULL = false;
                            this.addEvents();
                        }

                        //blocked error message for future dates
                        if (this.todayDate < this.finalDrs.Date) {
                            this.isPreviousDataIsNULL = false;
                        }
                        //removed error message for if employee is not joined yet
                        if (this.isEmployeeNotJoinedYet) {
                            this.isPreviousDataIsNULL = false;
                        }
                    }
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
            this.isEmployeeNotJoinedYet = true;
            this.isPreviousDataIsNULL = false;
        } else {
            this.isTableVisible = true;
            this.isEmployeeNotJoinedYet = false;
            this.isPreviousDataIsNULL = false;
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
            /* comment due to prod issue and uncomment above for loop
            getAttendanceData({ employeeId: this.employeeDetails.EmpRecordId, givenDate: requestedDate })
            .then(result => {
                console.log('OUTPUTresult## : ', result);
                this.isAddButtonVisible = result[0].isAddDisable__c
            })
            .catch(error => {
                console.error('Error fetching isHideAdd__c Field Value:', error);
            });*/
           // console.log('OUTPUTEmployeeDetails : ', this.employeeDetails);
        }
    }



}