import { LightningElement, track, api } from 'lwc';
import getTimesheetData from '@salesforce/apex/timeSheetFilterData.getTimesheetDataWithDateFilter';
// import getTimesheetData from '@salesforce/apex/timeSheetFilterData.getTimesheetData';
import getEmployeeNames from '@salesforce/apex/timeSheetFilterData.getEmployeeNames';
import projectNames from '@salesforce/apex/timeSheetFilterData.projectNames';
import updateEmployeeRecords from '@salesforce/apex/timeSheetFilterData.updateEmployeeRecords';
import LightningConfirm from "lightning/confirm";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Date', fieldName: 'Date__c' },
    { label: 'Day', fieldName: 'DayName' },
    { label: 'Ticket No', fieldName: 'Ticket_No__c' },
    { label: 'Employee Name', fieldName: 'EmployeeName' },
    { label: 'Task Description', fieldName: 'Task_Description__c' },
    { label: 'Actual Hours', fieldName: 'Total_Hours__c' },
    { label: 'Project Name', fieldName: 'Project_Name__c' },
    
    {
        label: 'Delete',
        type: 'button-icon',
        typeAttributes: {
            iconName: 'utility:delete',
            title: 'Delete',
            variant: 'bare',
            alternativeText: 'Delete',
        },
        cellAttributes: { class: 'slds-row-action' },
        initialWidth: 100,
        sortable: false,
    },
];
function transformData(data) {
    console.log('OUTPUT : data',data);
    return data.map(record => ({
        ...record,
        EmployeeName: record.Employee__r ? record.Employee__r.Name : '',
        Date__c: record.Date__c != null ? formatDate(record.Date__c) : '',
        DayName: record.Date__c != null ? getDayName(record.Date__c) : '',
    }));
}

function formatDate(dateString) {
    const months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    const date = new Date(dateString);
    const day = date.getDate().toString().padStart(2, '0');
    // const month = (date.getMonth() + 1).toString().padStart(2, '0'); 
     const month = months[date.getMonth()];
    const year = date.getFullYear();

    return `${day}-${month}-${year}`;
}
function getDayName(dateTimeString) {
    const options = { weekday: 'long' };
    const dayName = new Date(dateTimeString).toLocaleDateString(undefined, options);
    return dayName;
}
export default class RecordDataFilter extends LightningElement {
    @track selectedDate;
    @track selectedProjectName = [];
    @track employeeName;
    @track timesheetData;
    columns = columns;
    @track employeeOptions = [];
    @track projectOptions = [];
    @track selectedEmployeName = [];
    @track defaultEmployeeSettings = {}
    @track defaultProjectSettings = {};
    @track hasData;
    @track mergeTicket=false;

    @track selectedToDate;
    loaded = false;

    get copyClass() {
        return this.hasData ? 'with_copy' : 'without_copy';
    }
    connectedCallback() {
        this.loadEmployeeNames();
        this.loadProjectNames();

        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);

        const year = yesterday.getFullYear();
        let month = yesterday.getMonth() + 1;
        let day = yesterday.getDate();

        month = month < 10 ? `0${month}` : month;
        day = day < 10 ? `0${day}` : day;

        this.selectedDate = `${year}-${month}-${day}`;
        this.selectedToDate=this.selectedDate;
        console.log("this.selectedDate" + this.selectedDate);
const style = document.createElement('style');
                    style.innerText = `
                    lightning-input lightning-datepicker input , lightning-dual-listbox .slds-dueling-list__options {
                        border-radius: 6.531px !important;
                        border: 0.8px solid #9D9D9D !important;
                    }
                    lightning-input lightning-datepicker .slds-form-element__label {
                        font-size: 14px;
                        padding-bottom: 10px;
                        color: #194051;
                    }
                    lightning-dual-listbox .slds-form-element__control {
                            padding: 10px;
                            background: white;
                            border-radius: 16px;
                    }
                    lightning-dual-listbox .slds-form-element__label.slds-form-element__legend {
                        padding: 4px 0px 10px 10px !important; 
                        font-weight: normal !important;
                        font-size: 14px !important;
                        color: #194051;
                    }
                `;
                     setTimeout(() => {
                        this.template.querySelector('.overrideStyle').appendChild(style);
                    }, 200);


    }

    loadEmployeeNames() {
        getEmployeeNames()
            .then(result => {
                this.employeeOptions = result.map(employee => ({ label: employee.Name, value: employee.Name }));
                this.employeeOptions.sort((a, b) => a.label.localeCompare(b.label));
                const selectedEmployees = result.filter(employee => employee.Default_Active__c === true);

                if (selectedEmployees.length > 0) {
                    this.selectedEmployeName = selectedEmployees.map(employee => employee.Name);
                    // this.selectedEmployeName.sort((a, b) => a.localeCompare(b));
                }
                console.log(JSON.stringify(this.selectedEmployeName));
            })
            .catch(error => {
                console.error('Error fetching employee names:', error);
            });
    }

    loadProjectNames() {
        projectNames()
            .then(result => {
                this.projectOptions = result.map(project => ({ label: project.Name, value: project.Name }));
                this.projectOptions.sort((a, b) => a.label.localeCompare(b.label));
                const selectedProjects = result.filter(employee => employee.Default_Active__c === true);

                if (selectedProjects.length > 0) {
                    this.selectedProjectName = selectedProjects.map(employee => employee.Name);
                    this.selectedProjectName.sort((a, b) => a.localeCompare(b));
                }

            })
            .catch(error => {
                console.error('Error fetching employee names:', error);
            });
    }

     async handleReset() {
         
            const result = await LightningConfirm.open({
                message: "Do you really want to reset the timesheet record?",
                theme: 'alt-inverse', 
                variant: "default", // headerless
                label: "Reset the timesheet Data"
            });
                      
            if (result) {
                this.selectedDate = null;
                this.selectedToDate = null;
                this.selectedProjectName = [];
                this.selectedEmployeName = [];
            } 
        
    }

    handleDateChange(event) {
        this.selectedDate = event.target.value;
    }
    handleToDateChange(event) {
        this.selectedToDate = event.target.value;
    }
    handleToMergeChange(event){
        this.mergeTicket= event.target.checked;
}

    handleProjectNameChange(event) {
        this.selectedProjectName = event.target.value;
        console.log('OUTPUT : ddddeeeedee',this.selectedProjectName);
    }


    handleDualListboxChange(event) {
        this.selectedEmployeName = event.detail.value;
    }

    handleSubmit() {
        this.loaded = true;
        getTimesheetData({ selectedDate: this.selectedDate,   selectedToDate: this.selectedToDate, projectNames: JSON.stringify(this.selectedProjectName), employeeName: JSON.stringify(this.selectedEmployeName) })
            .then(result => {
                this.timesheetData = transformData(result);
                console.log('OUTPUT : this.timesheetData',this.timesheetData);
                this.hasData = this.timesheetData && this.timesheetData.length > 0;
                if (this.timesheetData.length > 0) {
                    this.loaded = false;
                    this.showToast('Success', 'Timesheet record submitted successfully.', 'success');
                } else {
                    setTimeout(() => {
                        this.loaded = false;
                        this.showToast('Error', 'Record not found.', 'error');
                    }, 300);


                }
            })
            .catch(error => {
                console.error('Error retrieving timesheet data', error);
            });
    }

    handleCopyClick() {
        console.log('copy this.timesheetData', this.timesheetData);
        const visibleColumns = this.columns.filter(column => column.label !== 'Delete');
        const modifiedTimesheetData = this.timesheetData.map((row, index) => {
            console.log("row @@" + row + "index => " + index);
            return {
                ...row,
                Task_Description__c: row.Task_Description__c != null ? row.Task_Description__c.replace(/\n/g, '\r\n').replace(/"/g, '""') : ''
            };
        });
        const clipboardData = this.generateTableData(modifiedTimesheetData, visibleColumns);

        const textArea = document.createElement('textarea');
        textArea.value = clipboardData;
        document.body.appendChild(textArea);
        textArea.select();


        if (this.hasData) {
            document.execCommand('copy');
            document.body.removeChild(textArea);
            this.showToast('Data Copied', 'Timesheet data copied to clipboard.', 'success');
        } else {
            this.showToast('Don\'t have Data', 'Timesheet data Not Available.', 'error');


        }
    }

    generateTableData(data, columns) {
        console.log('dtaa@@@@', data);
        const columnLabels = columns.map(column => column.label);

        const headerRow = columnLabels.join('\t');

        /*const dataRows = data.map(row => {
            return columns.map(column => '" ' + row[column.fieldName] + '"').join('\t');
        });*/
				/*var preEmpName='';
        const dataRows = data.map(row => {
						var dataInfo=columns.map(column => '" ' + (column.fieldName=="EmployeeName"?(row[column.fieldName]==preEmpName?"":row[column.fieldName]):row[column.fieldName]) + '"').join('\t');
            preEmpName=row["EmployeeName"];
						return dataInfo;
        });*/
				var preEmpName='';
				var i=0;
				var totalhours=0;
        const dataRows = data.map(row => {
            if(this.mergeTicket){
                if(!row["Task_Description__c"].startsWith(row["Ticket_No__c"])){
                        row["Task_Description__c"]=row["Ticket_No__c"]+' : '+row["Task_Description__c"]
                }
        }
						var dataInfo=columns.map(column => '" ' + (column.fieldName=="EmployeeName"?(row[column.fieldName]==preEmpName?"":row[column.fieldName]):row[column.fieldName]) + '"').join('\t');
            preEmpName=row["EmployeeName"];
						if(row["Total_Hours__c"]!=null){
								totalhours+=row["Total_Hours__c"];
						}
						if((i+1)<data.length){
								if(preEmpName!=data[i+1]["EmployeeName"] && preEmpName!="" ){
										dataInfo+='\t"'+totalhours+'"';
										totalhours=0;
								}
								
						}
						if(i==(data.length-1)){
								dataInfo+='\t"'+totalhours+'"';
								totalhours=0;
						}
						i++;
						
						return dataInfo;
        });
        return `${headerRow}\n${dataRows.join('\n')}`;
    }

    handleUpdateRecords() {
        this.loaded = true;
        console.log('OUTPUT : ddd',this.selectedProjectName);
        updateEmployeeRecords({selectedProjectName:this.selectedProjectName, selectedEmployeName: this.selectedEmployeName })
            .then(result => {
                this.loaded = false;
                if(result == 'success'){
                    this.showToast('Success', 'Default timesheet record saved successfully.', 'success');
                }
                else {
                     this.showToast('Error', 'Changes not saved.', 'error');
                }
                
            })
            .catch(error => {
                console.error('Error updating records:', error);
            });
    }


    handleRowAction(event) {
        const recordId = event.detail.row.Id;

        this.deleteRecord(recordId);
    }

    deleteRecord(recordId) {
        const originalLength = this.timesheetData.length;

        this.timesheetData = this.timesheetData.filter(record => record.Id !== recordId);

        if (this.timesheetData.length < originalLength) {
            this.showToast('Success', 'Record deleted successfully.', 'success');
        } else {
            this.showToast('Error', 'Record not found for deletion.', 'error');
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}