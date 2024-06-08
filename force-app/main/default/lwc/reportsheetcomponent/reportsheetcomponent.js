import { LightningElement, api, track, wire } from 'lwc';
import getUserProjectWiseChart from '@salesforce/apex/ReportSheetController.getUserProjectWiseChart';
import getallTaskDetails from '@salesforce/apex/ReportSheetController.getallTaskDetails';
import getUniqueTicketHours from '@salesforce/apex/ReportSheetController.getUniqueTicketHours';
import getOnTicketTaskWiseHours from '@salesforce/apex/ReportSheetController.getOnTicketTaskWiseHours';
import getMonthWiseUniqueTicketHours from '@salesforce/apex/ReportSheetController.getMonthWiseUniqueTicketHours';
import getMonthWiseProjectHours from '@salesforce/apex/ReportSheetController.getMonthWiseProjectHours';
import getMonthWiseTaskTypeHours from '@salesforce/apex/ReportSheetController.getMonthWiseTaskTypeHours';
import getCurrentYearHoursReports from '@salesforce/apex/ReportSheetController.getCurrentYearHoursReports';
import findTicketsAssigningInMultipleProjects from "@salesforce/apex/ReportSheetController.findTicketsAssigningInMultipleProjects";
import MonthWiseFindTicketsAssigningInMultipleProjects from "@salesforce/apex/ReportSheetController.MonthWiseFindTicketsAssigningInMultipleProjects";
import getCurrentYearTotalHours from "@salesforce/apex/ReportSheetController.getCurrentYearTotalHours";

export default class Reportsheetcomponent extends LightningElement {
    @api recordId;
    startingYear = 2023;
    monthOptions = [
        {label: "January", value: 1},
        {label: "February", value: 2},
        {label: "March", value: 3},
        {label: "April", value: 4},
        {label: "May", value: 5},
        {label: "June", value: 6},
        {label: "July", value: 7},
        {label: "August", value: 8},
        {label: "September", value: 9},
        {label: "October", value: 10},
        {label: "November", value: 11},
        {label: "December", value: 12}
    ];
    monthNames = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    @track ticketHasMultipleProjects = {};
    @track monthWiseTicketHasMultipleProjects = {};
    @track yearOptions = [];
    @track projectWiseDetails = [];
    @track taskWiseDetails = [];
    @track uniqueTicketDetails = [];
    @track currentYearMonthTotalDetails = [];
    @track currentYearTotalHoursDetails = {};
    @track allDataDashboard = [];
    @track allDataTicketTaskDetails = [];
    @track allDataMonthWiseDetails = [];
    @track allDataYearMonthTotal = [];
    @track allYearTotalHours = [];
    @track monthWiseTicketDetails = [];
    @track monthWiseProjectDetails = [];
    @track monthWiseTaskDetails = [];
    @track ticketNumbers= [];
    @track selectedValues = {
        ticketNumber: '',
        month: new Date().getMonth() + 1,
        year: new Date().getFullYear()
    }
    @track currentYear;
    @track currentMonth;
    isLoading = true;
    isBLoading = true;
    isNLoading = true;
    isSLoading = true;

    isAllData = false;
    isMonthData = false;
    isTicketData = false;
    isYearData = false;


    connectedCallback(){
        // console.log(this.recordId, 'in reporsheet');
        this.currentYear = new Date().getFullYear();
        this.currentMonth = new Date().getMonth();
        this.addYearOptions();
        this.getAllDataCalls();
        this.getCurrentYearMonthTotalDetails();
        this.getMonthWiseDataCalls();
        this.isLoading = false;
    }

    addYearOptions() {
        const year = new Date().getFullYear();
        for (let i = this.startingYear; i <= year; i++) {
            this.yearOptions.push({
                label: `${i}`,
                value: i
            });
        }
    }

    async getAllDataCalls() {
        this.isBLoading=true;
        await Promise.all([
            getallTaskDetails({ employeeId: this.recordId }),
            getUniqueTicketHours({employeeId: this.recordId}),
            getUserProjectWiseChart({ employeeId: this.recordId }),
            findTicketsAssigningInMultipleProjects({employeeId:this.recordId})
        ])
        .then(res=>{
            this.taskWiseDetails = (res[0] != null) ? res[0] : [];
            this.uniqueTicketDetails = (res[1] != null) ? res[1] : [];
            this.projectWiseDetails = (res[2] != null) ? res[2] : [];
            this.ticketHasMultipleProjects = (res[3] != null) ? res[3] : {};
            //add more data
        })
        .catch(err=>{
            console.error('Error while fetching data!', err);
            this.isBLoading = false;
        });

         this.mappingOfTicketsWhichAreAlignedWithMultipleProjects();
        //console.log('check it',this.uniqueTicketDetails);

        //this.allDataDashboard = [];
        const arr = [];
        arr.push(this.taskWiseDetails.length);
        arr.push(this.uniqueTicketDetails.length);
        arr.push(this.projectWiseDetails.length);

        const maxIndex = Math.max(...arr);

        for (let i = 0; i < maxIndex; i++) {
            const taskWiseDataElement = (this.taskWiseDetails[i] != undefined) ? this.taskWiseDetails[i] :  {count:"", label:""};
            const uniqueTicketWiseElement = (this.uniqueTicketDetails[i] != undefined) ? {...this.uniqueTicketDetails[i], index:i + 1 } : {Project_Name__c: "", hours: "", Ticket_No__c: ""};
            const projectWiseDataElement = (this.projectWiseDetails[i] != undefined) ? this.projectWiseDetails[i] : {taskType:"",totalHours: ""};
            
            const obj = {
                ...taskWiseDataElement,
                ...uniqueTicketWiseElement,
                ...projectWiseDataElement,               
                // index: i + 1
            }
            // console.log(obj);
            this.allDataDashboard.push(obj);
        }
        //console.log("-------A!!!!----------->",this.allDataDashboard);
        if (this.allDataDashboard.length == 0) {
            this.isAllData = false;
        }
        else {
           this.isAllData = true;
        }
        //console.log("---@uniqueTicketDetails->>>>>>>>>>",this.uniqueTicketDetails);
        if (this.uniqueTicketDetails.length > 0) {
            this.ticketNumbers = this.uniqueTicketDetails.map(i=>{
                return {
                    label: i.Ticket_No__c,
                    value: i.Ticket_No__c
                }
            });
            this.selectedValues.ticketNumber = this.ticketNumbers[0].value;
        }
        this.getTicketDetails();
        this.isBLoading = false;
    }


    handleOnChange(event) {
        console.log(event.target.name);
        console.log(event.target.value);

        if (event.target.name === 'enterTicket') {
            this.selectedValues.ticketNumber = event.target.value;
            this.getTicketDetails();
            this.isNLoading = false;
        }
        else if (event.target.name === 'enterMonth') {
            this.selectedValues.month = +event.target.value;
            this.getMonthWiseDataCalls();
        }
        else if (event.target.name === 'enterYear') {
            this.selectedValues.year = +event.target.value;
           this.getMonthWiseDataCalls();
        }
    }

    async getMonthWiseDataCalls() {
        this.isSLoading = true;
        console.log(JSON.stringify(this.selectedValues));
        if(this.selectedValues.month != null && this.selectedValues.year != null){
            await Promise.all([
                getMonthWiseUniqueTicketHours({ employeeId: this.recordId, month: this.selectedValues.month, year: this.selectedValues.year }),
                getMonthWiseProjectHours({employeeId: this.recordId, month: this.selectedValues.month, year: this.selectedValues.year }),
                getMonthWiseTaskTypeHours({employeeId: this.recordId, month: this.selectedValues.month, year: this.selectedValues.year }),
                MonthWiseFindTicketsAssigningInMultipleProjects({employeeId: this.recordId, month: this.selectedValues.month, year: this.selectedValues.year })
            ])
            .then(res=>{
                this.monthWiseTicketDetails = (res[0] != null) ? res[0] : [];
                this.monthWiseProjectDetails = (res[1] != null) ? res[1] : [];
                this.monthWiseTaskDetails = (res[2] != null) ? res[2] : [];
                this.monthWiseTicketHasMultipleProjects = (res[3] != null) ? res[3] : {};

            // console.log("---------monthWiseTicketDetails-@@------------------>",this.monthWiseTicketDetails);
            // console.log("---------monthWiseProjectDetails-@@------------------>",this.monthWiseProjectDetails);
            // console.log("---------monthWiseTaskDetails-@@------------------>",this.monthWiseTaskDetails);
                //add more data
            })
            .catch(err=>{
                console.error('Error while fetching data!', err);
                this.isSLoading = false;
            });

            this.monthWiseMappingOfTicketsWhichAreAlignedWithMultipleProjects();
            //console.log('check it',this.getMonthWiseUniqueTicketHours);
            this.allDataMonthWiseDetails = [];
            const arr = [];
            arr.push(this.monthWiseTicketDetails.length);
            arr.push(this.monthWiseProjectDetails.length);
            arr.push(this.monthWiseTaskDetails.length);

            const maxIndex = Math.max(...arr);

            for (let i = 0; i < maxIndex; i++) {
                const monthWiseTicketDataElement = (this.monthWiseTicketDetails[i] != undefined) ? {...this.monthWiseTicketDetails[i], index: i + 1} : {Ticket_No__c:"", monthwisetotalHours: "", TicketWiseProjectName:"", };
                const monthWiseProjectDataElement = (this.monthWiseProjectDetails[i] != undefined) ? this.monthWiseProjectDetails[i] : {ProjectWiseProjectName:"", monthWiseProjectHours:"" };
                const monthWiseTaskDataElement = (this.monthWiseTaskDetails[i] != undefined) ? this.monthWiseTaskDetails[i] : {Task_Type__c:"", monthWiseTaskHours:"" };

                const obj = {
                    ...{...monthWiseTicketDataElement, TicketWiseProjectName: monthWiseTicketDataElement.Project_Name__c },
                    ...{...monthWiseProjectDataElement, ProjectWiseProjectName: monthWiseProjectDataElement.Project_Name__c},
                    ...monthWiseTaskDataElement               
                    //index: i + 1
                }
                this.allDataMonthWiseDetails.push(obj);
            }

            if (this.allDataMonthWiseDetails.length == 0) {
                this.isMonthData = false;
            }
            else {
                this.isMonthData = true;
            }
            // console.log("-----@@allDataMonthWiseDetails-------->",this.allDataMonthWiseDetails);
                //this.monthWiseAllBindData();
            this.isSLoading = false;
        }
    }

    getTicketDetails() {
        this.isNLoading = true;
        getOnTicketTaskWiseHours({employeeId: this.recordId, ticketNumber: this.selectedValues.ticketNumber})
        .then(res=>{
            this.allDataTicketTaskDetails = (res != null) ? res : [];
        })
        .catch(err=>{
            console.error('Error while fetching getOnTicketTaskWiseHours', err);
            this.isNLoading = false;
        })
        // if (this.allDataTicketTaskDetails.length == 0) {
        //     this.isTicketData = false;
        // }
        // else{
        //     this.isTicketData = true;
        // }
        this.isNLoading = false;
    }

    async getCurrentYearMonthTotalDetails() {
        await Promise.all([
            getCurrentYearHoursReports({employeeId: this.recordId, year: this.selectedValues.year}),
            getCurrentYearTotalHours({employeeId: this.recordId, year: this.currentYear})
        ])
        .then(res=>{
            this.currentYearTotalHoursDetails = (res[1] != null) ? res[1] : {};
        
            if (Object.keys(res[0]).length > 0) {
            
                for (let i = 1; i <= this.currentMonth + 1; i++) {
                    this.currentYearMonthTotalDetails.push({
                            monthName: `${this.monthNames[i]}-${this.currentYear}`,
                            monthTotalHours: (res[0].hasOwnProperty(`${i}`)) ? res[0][`${i}`] : 0
                    });
                    
                }
                //console.log("@@-------currentYearMonthTotalDetails-------------->",this.currentYearMonthTotalDetails);
            }
            else{
                this.currentYearMonthTotalDetails = [];
            }
        })
        .catch(err=>{
            console.error('Error while fetching getOnTicketTaskWiseHours', err);
        })
        this.allDataYearMonthTotal = [];
        const arr = [];
        arr.push(this.currentYearMonthTotalDetails.length);
        
        const maxIndex = Math.max(...arr);
        for (let i = 0; i < maxIndex; i++) {
            const currentYearMonthTotalDataElement = (this.currentYearMonthTotalDetails[i] != undefined) ? this.currentYearMonthTotalDetails[i] : {monthName:"",monthTotalHours: ""};
            const obj = {
                ...currentYearMonthTotalDataElement
            }
            this.allDataYearMonthTotal.push(obj);
        }

        
        const arrr = [];
        arrr.push(this.currentYearTotalHoursDetails.length);
        //console.log("LenthArrry-------------->",this.currentYearTotalHoursDetails);
        const maxIndexnew = Math.max(...arrr);
        for (let i = 0; i < maxIndexnew; i++) {
            const currentYearTotalHoursDataElement = (this.currentYearTotalHoursDetails[i] != undefined) ? this.currentYearTotalHoursDetails[i] : {allTotalHours: ""};
            const objnew = {
                ...currentYearTotalHoursDataElement
            }
            this.allYearTotalHours.push(objnew);
        }
        
        //console.log("New Arrrry----------->",this.allYearTotalHours);
        if (this.allDataYearMonthTotal.length == 0) {
            this.isYearData = false;
        }
        else{
            this.isYearData = true;
        }
    }

    mappingOfTicketsWhichAreAlignedWithMultipleProjects() {
        if (Object.keys(this.ticketHasMultipleProjects).length > 0) {
            //console.log('unique check data',JSON.stringify(this.ticketHasMultipleProjects));
            const checkSet = new Set();
            this.uniqueTicketDetails = this.uniqueTicketDetails.filter(i=>{
                if (this.ticketHasMultipleProjects.hasOwnProperty(i.Ticket_No__c) && this.ticketHasMultipleProjects[i.Ticket_No__c][0] === 'Invalid') {
                    if (!checkSet.has(i.Ticket_No__c)) {
                        checkSet.add(i.Ticket_No__c);
                        return true;
                    }
                    return false;
                }
                else{
                    return true;
                }
            })
            .map(j=>{
                if (this.ticketHasMultipleProjects.hasOwnProperty(j.Ticket_No__c)) {
                    return {
                        Project_Name__c: this.ticketHasMultipleProjects[j.Ticket_No__c][0],
                        hours: this.ticketHasMultipleProjects[j.Ticket_No__c][1],
                        Ticket_No__c: j.Ticket_No__c
                    };
                }else{
                    return j;
                }
            });

            this.uniqueTicketDetails.sort((a, b)=>b.hours - a.hours);
            //console.log('abc', JSON.stringify(this.uniqueTicketDetails));
        }
        //console.log('unique check',JSON.stringify(this.uniqueTicketDetails));
    }

    monthWiseMappingOfTicketsWhichAreAlignedWithMultipleProjects() {
        if (Object.keys(this.monthWiseTicketHasMultipleProjects).length > 0) {
            const checkSet = new Set();
            this.monthWiseTicketDetails = this.monthWiseTicketDetails.filter(i=>{
                if (this.monthWiseTicketHasMultipleProjects.hasOwnProperty(i.Ticket_No__c) && this.monthWiseTicketHasMultipleProjects[i.Ticket_No__c][0] === 'Invalid') {
                    if (!checkSet.has(i.Ticket_No__c)) {
                        checkSet.add(i.Ticket_No__c);
                        return true;
                    }
                    return false;
                }
                else{
                    return true;
                }
            })
            .map(j=>{
                if (this.monthWiseTicketHasMultipleProjects.hasOwnProperty(j.Ticket_No__c)) {
                    return {
                        Project_Name__c: this.monthWiseTicketHasMultipleProjects[j.Ticket_No__c][0],
                        monthwisetotalHours: this.monthWiseTicketHasMultipleProjects[j.Ticket_No__c][1],
                        Ticket_No__c: j.Ticket_No__c
                    };
                }else{
                    return j;
                }
            });
            this.monthWiseTicketDetails.sort((a, b)=>b.monthwisetotalHours - a.monthwisetotalHours);
        }
    }

    
}