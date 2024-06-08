import { LightningElement, track, wire, api } from 'lwc';
    import getProjects from '@salesforce/apex/timesheetTableController.getProjects';
    import getProjectAllotedHours from '@salesforce/apex/timesheetTableController.getProjectAllotedHours';
    import getProjectWiseHours from '@salesforce/apex/timesheetTableController.getProjectWiseHours';
    import deleteProjectAllotedHourRecord from '@salesforce/apex/timesheetTableController.deleteProjectAllotedHourRecord';
    import saveProjectAllotedRecords from '@salesforce/apex/timesheetTableController.saveProjectAllotedRecords';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    import { getRecord } from 'lightning/uiRecordApi';
    import { refreshApex } from '@salesforce/apex';
    import { RefreshEvent } from 'lightning/refresh';



    const FIELDS = ['Project_Alloted_Hour__c.TotalHR__c'];

    export default class ReportTable extends LightningElement {

        @track isSaveButtonDisabled = true;
        @api recordId;
        @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
        Project_Alloted_Hour__c;
        @track projectWiseHoursMap = {};
        @track events = [];
        @track projectOptions = [];
        @track currentDateDefault;
        @track Pmdd = [];
        @track finalPmdd = {};
        selectedProjectIds = [];
        selectedDate;
        @track showDateError = false;
        isPMNumbCheck = true;
        isAllotedNumCheck = true;
        projectAvail = false;
        projectExists = false;


        connectedCallback() {

            //const lastActiveTab = localStorage.getItem('activeTab');
            this.currentDateDefault = new Date().toISOString().split('T')[0];
            this.selectedDate = this.currentDateDefault;
            this.fetchProjectOptions();
            this.fetchSelectedDateData();
            this.addDefaultRow();
            this.fetchDataOnProject();
            this.isSaveButtonDisabled = true;
            //this.isSaveButtonDisabled = true;
            
        }

        addEvents() {
            const newEvent = {
                Project__c: '',
                TotalHR__c: 0,
                Sum_Of_Actual_Hours__c: 0,
            };
            this.events = [...this.events, newEvent];
            //
            this.isSaveButtonDisabled = false;
        }
        handleTextChange() {
            this.isSaveButtonDisabled = false;
        }
        addDefaultRow() {
            const defaultEvent = {
                Project__c: '',
                TotalHR__c: 0,
                Sum_Of_Actual_Hours__c: 0,
            };

            this.events = [defaultEvent];
        }
        fetchProjectOptions() {
            getProjects()
                .then((data) => {
                    const availableOptions = data.filter(project => !this.selectedProjectIds.includes(project.Id));
                    this.projectOptions = availableOptions.map((project) => ({
                        label: project.Name,
                        value: project.Id
                    }));
                })
                .catch((error) => {
                    console.error('Handle error in getProjects', error);
                });

                
                              
        }

        handleAllotedHoursChange(event) {
            const index = event.target.dataset.index;
            const inputValue = event.target.value.trim();
            console.log("enter onblur"+inputValue);

            const regex = /^(999(\.0{1,2})?|[1-9]\d{0,2}(\.\d{1,2})?|0(\.\d{1,2})?)$/;

            if (inputValue == null || inputValue == '') {
                console.log("enter if valid");
                this.events[index].hourError = 'Please Enter Alloted Hours';    
            }
            else {
                console.log("enter else valid");
                if (!regex.test(inputValue)) {
                    console.log("enter regex");
                    this.events[index].hourError = 'Please Enter Alloted Hours';    
                }

                else{
                    console.log("enter regex else part");
                    this.events[index].hourError = '';
                }
                
            } 
            const allotedHours = inputValue;
            const pmBillableHours = this.events[index].PM_Billable_Hours__c ? Number(this.events[index].PM_Billable_Hours__c) : 0;
            this.events[index].Alloted_Hours__c = allotedHours;
            const totalHR = ((allotedHours != null ? Number(allotedHours) : 0) + pmBillableHours).toFixed(2);

            this.events[index].TotalHR__c = (isNaN(totalHR) ? 0 : totalHR) ;
            if (this.events[index].Id) {
                this.isSaveButtonDisabled = false;
            }
            
        }

        

        
        handleNoOfDevAndQAChange(event) {
            const index = event.target.dataset.index;
             const inputValue = event.target.value;
            

            const regex = /^(999(\.0{1,2})?|[1-9]\d{0,2}(\.\d{1,2})?|0(\.\d{1,2})?)$/; 
            if (inputValue == null || inputValue == '') {
                console.log("enter if valid");
                this.events[index].NoOfDevError = 'Please Enter No of Developers';    
            }
            else {
                console.log("enter else valid");
                if (!regex.test(inputValue)) {
                    console.log("enter regex");
                    this.events[index].NoOfDevError = 'Please Enter No of Developers';    
                }
                else{
                    console.log("enter regex else part");
                    this.events[index].NoOfDevError = '';
                }
                
            } 

            this.events[index].No_of_Dev_QA_s__c = inputValue;
            if (this.events[index].Id) {
                this.isSaveButtonDisabled = false;  
            }
            
        }

        handlePMBillableChange(event) {
            const inputValue = event.target.value;
            const index = event.target.dataset.index;
            console.log('OUTPUT : inputValue',inputValue);
            const regex = /^(999(\.0{1,2})?|[1-9]\d{0,2}(\.\d{1,2})?|0(\.\d{1,2})?)$/; 
            if (inputValue == null || inputValue == '') {
                console.log("enter if valid");
                this.events[index].PMError = 'Please Enter PM Billable Hours';    
            }
            else {
                console.log("enter else valid");
                if (!regex.test(inputValue)) {
                    console.log("enter regex");
                    this.events[index].PMError = 'Please Enter PM Billable Hours';    
                }
                else{
                    console.log("enter regex else part");
                    this.events[index].PMError = '';
                }
                
            } 
            
            const projectAllotedHours = this.events[index].Alloted_Hours__c ? Number(this.events[index].Alloted_Hours__c):0;
            console.log('OUTPUT : projectAllotedHours',projectAllotedHours);
            const pmBillableHours = inputValue;
            console.log('OUTPUT : pmBillableHours',pmBillableHours);
            this.events[index].PM_Billable_Hours__c = pmBillableHours;
            console.log("this.events"+JSON.stringify(this.events));
                const totalHR = (projectAllotedHours + (pmBillableHours != null ? Number(pmBillableHours) :0)).toFixed(2);
                console.log('OUTPUT : totalHR',totalHR);
                this.events[index].TotalHR__c = (isNaN(totalHR) ? 0 : totalHR);
            
            
            //this.handleTotalChange(event);
            if (this.events[index].Id) {
                this.isSaveButtonDisabled = false;  
            }
            console.log("inputValue",inputValue);
        }
        

        handleTotalChange(event) {
            console.log('event in total change: ',event);
            const index = event.target.dataset.index;
            this.events[index].TotalHR__c = parseFloat(event.target.value);
            console.log('total change type check : ',typeof event.target.value);

            if (this.events[index].Id) {
                this.isSaveButtonDisabled = false;
            }
        }

        handleProjectChange(event) {
            
            const selectedProjectId = event.detail.value;
            const index = event.target.dataset.index;
            console.log('selectedProjectId', selectedProjectId);
            console.log('index', index);
            console.log('event.Project__c', event.Project__c);
            this.projectExists = this.events.some(event => event.Project__c === selectedProjectId);
            console.log('projectExists', this.projectExists);
            console.log('projectWiseHoursMap', this.projectWiseHoursMap);
            const selectedProject = this.projectOptions.find(project => project.value === selectedProjectId);
            console.log('selectedProject', selectedProject);
            let projectsTotalHours = this.projectWiseHoursMap[selectedProject.label];
            console.log('projectsTotalHours:', projectsTotalHours);

            console.log('selectedProjectId:>> ', selectedProjectId);

            
            if (this.projectExists) {
                console.log('selectedProjectId inside :>> ', selectedProjectId);
                this.projectAvail = true;  
                event.projectError = 'Project Name already exists';
                this.events[index].projectError = 'Project Name already exists';
                console.log('event.projectError :>> ', event.projectError);
                //console.log("enter nnull"+this.events[index].Project__c);
                //console.log('this.events if', this.events);
            }
            else {
                event.projectError = '';
                console.log("enter nnull else");
                this.projectAvail = false;
                this.events[index].Project__c = selectedProjectId;
                this.events[index].Sum_Of_Actual_Hours__c = projectsTotalHours;
                this.events[index].projectError = '';
                console.log('this.events', JSON.stringify(this.events));
                this.selectedProjectIds.push(selectedProjectId);
            }
            if (this.events[index].Id) {
                this.isSaveButtonDisabled = false;
            }
            console.log('OUTPUT : ______+ ',event.detail.value);
        }

        handleSumActualHoursChange(event) {
            const index = event.target.dataset.index;
            this.events[index].Sum_Of_Actual_Hours__c = event.detail.value;
        }
        
        handleDateChange(event) {
            this.selectedDate = event.target.value;
            this.fetchSelectedDateData();
            this.fetchDataOnProject();
            if(event.target.value == null){
                this.showDateError = true;
            }
            else{
                this.showDateError = false;
            }
            this.isSaveButtonDisabled = true;
        }
        get showDateError() {
            return this.showDateError && !this.selectedDate;
        }

        handleSaveClick() {
            console.log("enter save");
            this.isSaveButtonDisabled = true;
            let allValid = true;
        this.events.forEach((event, index) => {
            console.log("event @@@2= ",event);
            if (!event.Alloted_Hours__c) {
                
                console.log("enter else if");
                event.hourError = 'Please Enter Alloted Hours';
                allValid = false;
            } else {
                console.log("enter else");
                const regex = /^(999(\.0{1,2})?|[1-9]\d{0,2}(\.\d{1,2})?|0(\.\d{1,2})?)$/;
                if (!regex.test(event.Alloted_Hours__c)) {
                    console.log("enter regex");
                    event.hourError = 'Please Enter Alloted Hours'; 
                    allValid = false;   
                }
                else{
                    console.log("enter regex else part");
                    event.hourError = '';
                }
            }
            console.log("event.No_of_Dev_QA_s__c"+event.No_of_Dev_QA_s__c);
           
            if (!event.No_of_Dev_QA_s__c ) {
                event.NoOfDevError = 'Please Enter No of QA & Dev';
                allValid = false;
            } else {
                console.log("qqqqqqqqqqqqqqqqqqqqqqqqqqqqqq");
                const regex = /^(999(\.0{1,2})?|[1-9]\d{0,2}(\.\d{1,2})?|0(\.\d{1,2})?)$/;
                if (!regex.test(event.No_of_Dev_QA_s__c)) {
                    console.log("enter regex");
                    event.NoOfDevError = 'Please Enter No of QA & Dev'; 
                    allValid = false;   
                }
                else{
                    console.log("enter regex else part");
                    event.NoOfDevError = '';
                }
            }

            if (!event.PM_Billable_Hours__c || !event.PM_Billable_Hours__c.trim()) {
                console.log('OUTPUT : event.PM_Billable_Hours__c => ',event.PM_Billable_Hours__c);
                event.PMError = 'Please Enter PM Billable Hours ';
                allValid = false;
            } else {
                console.log("pmmmmmm"+event.PM_Billable_Hours__c);
                const regex = /^(999(\.0{1,2})?|[1-9]\d{0,2}(\.\d{1,2})?|0(\.\d{1,2})?)$/;
                if (!regex.test(event.PM_Billable_Hours__c)) {
                    console.log("enter regex");
                    event.PMError = 'Please Enter PM Billable Hours'; 
                    allValid = false;   
                }
                else{
                    console.log("enter regex else part");
                    event.PMError = '';
                }
            }
            console.log('@@@@@@@@@@@@@@@@@@@@@event.Project__c',event.Project__c);
            console.log('this.projectAvail-->> ',this.projectAvail);
            if(!event.Project__c   || this.projectAvail){
                console.log('event.Project__c -- 2',event.Project__c);
                if(this.projectExists && selectedProjectId){
                    event.projectError = 'Project Name already exists Here ';
                }
                else{
                    event.projectError = 'Enter Project Name';
                }
                allValid = false;
            }
            else {
                console.log('eventproject',event.Project__c);
                
                event.projectError = '';
            }

        });
        console.log('allValid::>>>',allValid);
        if (allValid) {
            if (!this.selectedDate) {
                this.showDateError = true;
                return;
            }
            const currentDate = new Date().toISOString().split('T')[0];
            if (this.selectedDate > currentDate) {
                this.showToast('Error', 'Selected date cannot be in the future', 'error');
                return;
            }
            this.Pmdd = [];
            this.Pmdd = this.events;
            this.finalPmdd = { ...this.finalPmdd, Pmdd: this.Pmdd };
            console.log('this.events:', this.events);

            console.log('this.Pmdd:', this.finalPmdd);
                    saveProjectAllotedRecords({ timesheetList: JSON.parse(JSON.stringify(this.finalPmdd)), selectedDate: this.selectedDate, isInsert: false })
                    .then(result => {
                        console.log('Result for new records:', result);
                        if (result === 'success') {
    
                            this.showToast('Success', 'PMDD Records Save Successfully.', 'success');
                            setTimeout(() => {
                                refreshApex(this.fetchSelectedDateData());
                            }, 5000);
                            this.isSaveButtonDisabled = true;
                        } else {
                            this.showToast('Error', 'Failed to Save records', 'error');
                        }
                    })
           
        }

        }

        fetchSelectedDateData() {
            console.log('this.selectedDate>>', this.selectedDate);
            console.log('in save get totalhours ', this.events);
            getProjectAllotedHours({ selectedDate: this.selectedDate })
                .then((data) => {
                    console.log('in apex calling ', data);
                    if (data && data.length > 0) {
                        this.events = data.map((record) => ({
                            Id: record.Id,
                            Alloted_Hours__c: record.Alloted_Hours__c.toString(),
                            Project__c: record.Project__c,
                            PM_Billable_Hours__c: record.PM_Billable_Hours__c.toString(),
                            TotalHR__c: record.TotalHR__c,
                            No_of_Dev_QA_s__c: record.No_of_Dev_QA_s__c.toString(),
                            Sum_Of_Actual_Hours__c: record.Sum_Of_Actual_Hours__c
                        }));
                    } else {
                        this.addDefaultRow();
                    }
                })
                .catch((error) => {
                    console.error('Error fetching records:', error);
                });
        }

        fetchDataOnProject() {
            console.log('this.selectedDate>>', this.selectedDate);
            getProjectWiseHours({ selectedDate: this.selectedDate })
                .then((result) => {
                    console.log('getProjectWiseHours - Result>>', JSON.parse(result));
                    this.projectWiseHoursMap = JSON.parse(result);
                })
                .catch((error) => {
                    console.error('Error fetching records:', error);
                });

                console.log('this.projectWiseHoursMap -- >>', this.projectWiseHoursMap);
        }

        showToast(title, message, variant) {
            const event = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            });
            this.dispatchEvent(event);
        }

        deleteEvent(event) {
            const id = event.target.dataset.id;
            const index = event.target.dataset.index;

            if (id == undefined) {
                this.events.splice(index, 1);
            } else {
                if (confirm('Are you sure you want to delete this ?')) {
                    this.deleteRecord(id);
                }
            }
        }

        deleteRecord(recordId) {
            deleteProjectAllotedHourRecord({ projectAHId: recordId })
                .then(result => {
                    if (result === 'success') {
                        this.showToast('Success', 'PMDD Record deleted successfully', 'success');
                        this.fetchSelectedDateData();
                    } else {
                        this.showToast('Error', 'Failed to delete record', 'error');
                    }
                })
                .catch(error => {
                    console.error('Error deleting record:', error);
                });
        }

        get computedTotalAllottedHours() {
            let totalAllottedHours = 0;

            this.events.forEach((event) => {
                // totalAllottedHours += parseFloat(event.Alloted_Hours__c) || 0;
                totalAllottedHours += parseFloat(event.TotalHR__c) || 0;

            });

            return totalAllottedHours.toFixed(2);
        }
        refreshComponent(event){
               this.dispatchEvent(new RefreshEvent());

    }
    }