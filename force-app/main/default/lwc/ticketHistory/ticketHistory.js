import { LightningElement, track, api } from 'lwc';
import getTicketHistory from '@salesforce/apex/timeSheetFilterData.getTicketHistory';
import getEmployeeData from '@salesforce/apex/timeSheetFilterData.getEmployeeData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'NO', fieldName: 'index', initialWidth: 80 },
    { label: 'Date', fieldName: 'Date__c', initialWidth: 110 },
    { label: 'Task Type', fieldName: 'Task_Type__c' },
    { label: 'Ticket No', fieldName: 'Ticket_No__c' },
    { label: 'Task Description', fieldName: 'Task_Description__c', initialWidth: 400 },
    { label: 'Actual Hour', fieldName: 'Total_Hours__c' },
    { label: 'Employee Name', fieldName: 'EmployeeName' },
    { label: 'Component Change', fieldName: 'Component_Change__c' },


];

function transformData(data) {
    console.log('OUTPUT : data', data);
    return data.map((record, index) => ({
        ...record,
        index: index + 1,
        EmployeeName: record.Employee__r ? record.Employee__r.Name : '',
        Date__c: record.Date__c != null ? formatDate(record.Date__c) : '',
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

export default class TicketHistory extends LightningElement {

    @track selectedTicket = '';
    @track selectedEntireSheet = false;
    @api recordId;
    @track timesheetData;
    @track hasData = false;
    @track showEntirebtn = false;
    showTab = false;
    showTicketHistory = true;
    showTimesheetData = false;
    selectedTabLabel;

    columns = columns;
    @track totalhours = 0;
    @track selectedOption = 'contain';
    loaded = false;

    pageSizeOptions = [5, 10, 25, 50, 75, 100];
    records = []; //All records available in the data table
    totalRecords = 0; //Total no.of records
    pageSize; //No.of records to be displayed per page
    totalPages; //Total no.of pages
    pageNumber = 1; //Page number    
    @track recordsToDisplay = []; //Records to be displayed on the page

    columnHeader = ['Date', 'Task Type', 'Ticket No', 'Task Description', 'Actual Hour', 'Employee Name', 'Component Change'];


    searchOptions = [
        { label: 'Contain', value: 'contain' },
        { label: 'Exact Match', value: 'exact' }
    ];

    connectedCallback() {
        this.selectedTabLabel = 'TicketHistory';

        const style = document.createElement('style');
        style.innerText = `
                    
                    .selection_Sec  lightning-input label,.entire_time_sheet label span{
                        font-size: 18px !important;
                        color: black;
                    }

                    lightning-primitive-cell-factory[data-label="Task Description"] lightning-base-formatted-text {
                        white-space: break-spaces !important;
                        word-wrap: break-word !important;
                    }

                    lightning-datatable table th ,lightning-datatable table td {
                        vertical-align: top;
                    }
                    legend.slds-form-element__legend.slds-form-element__label {
                        font-size: 18px;
                        color: black;
                        font-weight: normal;
                    }
                    span.slds-form-element__label {
                        color: black;
                        font-size: 16px !important;
                    }
                    .slds-form-element__control .slds-radio {
                        display: inline;
                    }
                    label.slds-checkbox_toggle.slds-grid {
                        align-items: center;
                    }
                    .slds-list_inline.slds-p-bottom_xx-small {
                        align-items: center;
                        color: #333333 !important;
                        font-weight: bold;
                    }
                    label.slds-text-color_weak.slds-p-horizontal_x-small {
                        color: #333333 !important;
                        font-weight: bold;
                    }
                    button.slds-button {
                        color: #194051;
                    }
                    .slds-spinner_brand.slds-spinner:before, .slds-spinner_brand.slds-spinner:after, .slds-spinner_brand .slds-spinner__dot-a:before, .slds-spinner_brand .slds-spinner__dot-b:before, .slds-spinner_brand .slds-spinner__dot-a:after, .slds-spinner_brand .slds-spinner__dot-b:after, .slds-spinner--brand.slds-spinner:before, .slds-spinner--brand.slds-spinner:after, .slds-spinner--brand .slds-spinner__dot-a:before, .slds-spinner--brand .slds-spinner__dot-b:before, .slds-spinner--brand .slds-spinner__dot-a:after, .slds-spinner--brand .slds-spinner__dot-b:after {
                        background-color: #00a129;
                    }
                `;
        setTimeout(() => {
            this.template.querySelector('.overrideStyle').appendChild(style);
        }, 100);


        getEmployeeData({ EmpId: this.recordId })
            .then((result) => {
                console.log('result', result);
                if (result[0].Entire_Time_Sheet__c == true) {
                    console.log("if fffff");
                    this.showTab = true;
                    this.showEntirebtn = true;
                } else {
                    console.log("else ssss");
                    this.showTab = false;
                    this.showEntirebtn = false;

                }
            })
            .catch((error) => {
                console.error('Error retrieving timesheet data', error);
            });


    }
     renderedCallback() {
        // this.selectedTabLabel = 'Identity';
        if (this.selectedTabLabel) {
            const activeTab = this.template.querySelector(`[data-tab="${this.selectedTabLabel}"]`);
            if (activeTab) {
                this.adjustIndicator(activeTab);
            }
        }
    }

    get isActive() {
        return this.tabs.find(tab => tab.isActive);
    }

    tabs = [
        { label: 'TicketHistory', isActive: true },
        { label: 'TimeSheetData', isActive: false }
    ];

    handleTabClick(event) {
        this.selectedTabLabel = event.target.dataset.tab;
        this.tabs.forEach(tab => {
            tab.isActive = tab.label === this.selectedTabLabel;
        });

        if (this.selectedTabLabel === 'TicketHistory') {
            this.showTicketHistory = true;
            this.showTimesheetData = false;

        } else if (this.selectedTabLabel === 'TimeSheetData') {
            this.showTicketHistory = false;
            this.showTimesheetData = true;

        }
        // Call adjustIndicator to move the indicator to the selected tab
        this.adjustIndicator(event.currentTarget);
    }

    adjustIndicator(tabElement) {
        const indicator = this.template.querySelector('.tab-indicator');
        indicator.style.width = tabElement.offsetWidth + 'px';
        indicator.style.transform = `translateX(${tabElement.offsetLeft}px)`;
    }

    handleticketChange(event) {
        this.selectedTicket = event.target.value.trim();
        console.log('OUTPUT : ', this.selectedTicket);
    }
    handleToggleChange(event) {
        this.selectedEntireSheet = event.target.checked;
    }
    handleOptionChange(event) {
        this.selectedOption = event.detail.value;
        console.log("this.selectedOption", this.selectedOption);
        // You can add logic here to handle the selected option
    }


    // ---------------------------- Pagination start ------------------------------


    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }

    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }

    paginationHelper() {
        this.recordsToDisplay = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(JSON.parse(JSON.stringify(this.timesheetData[i])));
        }

    }


    // ---------------------------- Pagination End ------------------------------


    handleSubmit() {

        let ticketNumber = this.template.querySelector(".ticketNumber");
        let searchvalue = ticketNumber.value.trim();
        console.log('searchValue.length', searchvalue.length);
        if (!searchvalue || !searchvalue.length) {
            ticketNumber.setCustomValidity("Ticket Number is required");
            this.hasData = false;
        } else {
            this.loaded = true;
            ticketNumber.setCustomValidity("");
            getTicketHistory({ EmpId: this.recordId, selectedTicket: this.selectedTicket, selectedEntireSheet: this.selectedEntireSheet, selectedOption: this.selectedOption })
                .then((result) => {
                    this.loaded = false;
                    this.totalhours = 0;
                    this.timesheetData = transformData(result);
                    this.hasData = this.timesheetData && this.timesheetData.length > 0;
                    console.log('resulvv@', JSON.parse(JSON.stringify(this.timesheetData)));
                    for (let index = 0; index < result.length; index++) {
                        this.totalhours += result[index].Total_Hours__c;

                    }
                    console.log('result.length', result.length);
                    // -------------- Pagination start ----------------
                    if (result.length > 0) {
                        this.totalRecords = result.length; // update total records count                 
                        this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option

                        this.paginationHelper();
                        const selectElement = this.template.querySelector('select');
                        selectElement.value = this.pageSize;
                    }

                    // -------------- Pagination End ----------------

                    console.log('result.length down', result.length);
                    if (result.length == 0) {
                        this.showToast(' ', 'Oops! It looks like there\'s no data available in the timesheet at the moment.', 'warning');
                    }
                })
                .catch((error) => {
                    this.loaded = false;
                    console.error('Error retrieving timesheet data', error);
                });
        }
        ticketNumber.reportValidity();

        console.log('recordId', this.recordId);
        console.log('this.selectedTicket', this.selectedTicket);
        console.log('this.selectedEntireSheet', this.selectedEntireSheet);


    }

    handleCopyClick() {
        console.log('copy this.timesheetData', this.timesheetData);
        const visibleColumns = this.columns.filter(column => column.label !== 'NO');
        const modifiedTimesheetData = this.timesheetData.map((row, index) => {
            console.log("row @@" + row + "index => " + index);
            return {
                ...row,
                Task_Description__c: row.Task_Description__c != null ? row.Task_Description__c.replace(/\n/g, '\r\n').replace(/"/g, '""') : '',
                Component_Change__c: row.Component_Change__c != null ? row.Component_Change__c.replace(/\n/g, '\r\n').replace(/"/g, '""') : ''
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
        var preEmpName = '';
        var i = 0;
        var totalhours = 0;
        const dataRows = data.map(row => {
            if (this.mergeTicket) {
                if (!row["Task_Description__c"].startsWith(row["Ticket_No__c"])) {
                    row["Task_Description__c"] = row["Ticket_No__c"] + ' : ' + row["Task_Description__c"]
                }
            }
            var dataInfo = columns.map(column => '" ' + (column.fieldName == "EmployeeName" ? (row[column.fieldName] == preEmpName ? "" : row[column.fieldName]) : row[column.fieldName]) + '"').join('\t');
            // preEmpName=row["EmployeeName"];
            // 			if(row["Total_Hours__c"]!=null){
            // 					totalhours+=row["Total_Hours__c"];
            // 			}
            // 			if((i+1)<data.length){
            // 					if(preEmpName!=data[i+1]["EmployeeName"] && preEmpName!="" ){
            // 							dataInfo+='\t"'+totalhours+'"';
            // 							totalhours=0;
            // 					}

            // 			}
            // 			if(i==(data.length-1)){
            // 					dataInfo+='\t"'+totalhours+'"';
            // 					totalhours=0;
            // 			}
            // 			i++;

            return dataInfo;
        });
        return `${headerRow}\n${dataRows.join('\n')}`;
    }

    exportContactData() {
        // Prepare a html table
        const modifiedTimesheetData = this.timesheetData.map((row, index) => {
            console.log("row @@" + row + "index => " + index);
            return {
                ...row,
                Task_Description__c: row.Task_Description__c != null ? this.encodePlainText(row.Task_Description__c).replace(/\n/g, '<br>').replace(/\•/g, '&#8226;') : '',
                Component_Change__c: row.Component_Change__c != null ? this.encodePlainText(row.Component_Change__c).replace(/\n/g, '<br>').replace(/\•/g, '&#8226;') : ''
            };
        });

        console.log("modifiedTimesheetData", modifiedTimesheetData);
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';
        doc += '</style>';
        // Add all the Table Headers
        doc += '<tr>';
        this.columnHeader.forEach(element => {
            doc += '<th>' + element + '</th>'
        });
        doc += '</tr>';
        // Add the data rows
        modifiedTimesheetData.forEach(record => {
            doc += '<tr>';

            doc += '<td>' + record.Date__c + '</td>';
            doc += '<td>' + record.Task_Type__c + '</td>';
            doc += '<td style="mso-number-format:\'\@\';">' + record.Ticket_No__c + '</td>';
            doc += '<td style="mso-number-format:\'\@\';">' + record.Task_Description__c + '</td>';
            doc += '<td>' + record.Total_Hours__c + '</td>';
            doc += '<td>' + record.EmployeeName + '</td>';
            doc += '<td style="mso-number-format:\'\@\';">' + (record.Component_Change__c ? record.Component_Change__c : '') + '</td>';
            doc += '</tr>';
        });
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'Contact Data.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    encodePlainText(text) {
        return text ? text.replace(/[\u00A0-\u9999<>\&]/gim, function (i) {
            return '&#' + i.charCodeAt(0) + ';';
        }) : '';
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