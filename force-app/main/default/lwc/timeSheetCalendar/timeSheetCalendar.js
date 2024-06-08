import { LightningElement, track, api } from 'lwc';
import getTimesheet from '@salesforce/apex/timesheetTableController.getTimesheet';
import getAttendanceData from '@salesforce/apex/timesheetTableController.getAttendanceData';
import nextArrow from '@salesforce/resourceUrl/CalenderRightArrow';
import backArrow from '@salesforce/resourceUrl/CalenderLeftArrow';
const monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
];

const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

export default class TimeSheetCalendar extends LightningElement {

    @track currentMonth;
    @track currentYear;
    @track calendarDates = [];
    @track monthListClass = 'month-list';
    leftArrow;
    rightArrow;
    timesheetData = [];
    @api employeeDetails;

    daysTag;
    currentDate;
    prevNextIcon;
    currYear;
    currMonth;
    months;
    @track dateCells = [];
    @track selectedDate = null;
    isLoading = true;

    @api
    get customDateHandlerDrs() {
        return
    }
    set customDateHandlerDrs(value) {
        this.customDateHandlerChanged(value);
    }


    attendanceData = { above8: [], below8: [], equal0: [] };

    connectedCallback() {
        setTimeout(() => {

            const style = document.createElement('style');
            style.innerText = `
			.slds-spinner .slds-spinner__dot-b:after,.slds-spinner .slds-spinner__dot-b:before,.slds-spinner .slds-spinner__dot-a:after,.slds-spinner .slds-spinner__dot-a:before,.slds-spinner_large.slds-spinner:after,.slds-spinner_large.slds-spinner:before,.slds-spinner_medium.slds-spinner:after,.slds-spinner_medium.slds-spinner:before{
              background-color: #37a000 !important;
            }
				  `;
            this.template.querySelector('.overrideStyle').appendChild(style);
        }, 100);
        this.leftArrow = backArrow;
        this.rightArrow= nextArrow;
        const currDate = new Date();
        this.fetchTimesheetData(currDate.getMonth(), currDate.getFullYear());
        setTimeout(() => {
            this.initializeCalendar();
        }, 800);

        this.daysTag = this.template.querySelector('.days');
        this.currentDate = this.template.querySelector('.current-date');
        this.prevNextIcon = this.template.querySelectorAll('.icons span');

        this.currYear = new Date().getFullYear();
        this.currMonth = new Date().getMonth();
        this.months = [
            "January", "February", "March", "April", "May", "June", "July",
            "August", "September", "October", "November", "December"
        ];
        this.fetchAttendanceData();
        this.selectedDate = '';
    }

    fetchTimesheetData(selectedMonth, selectedYear) {

        getTimesheet({ employeeId: this.employeeDetails.EmpRecordId, month: selectedMonth, year: selectedYear })
            .then(result => {

                this.timesheetData = result;

                // Extract unique dates with records
                const datesWithRecords = new Set(this.timesheetData.map(item => item.Date__c));

                // Create an array of all dates in the calendar
                const allDates = this.calendarDates.map(item => item.date);

                // Separate dates with records and empty dates
                const datesWithRecordsData = [];
                const emptyDatesData = [];
                allDates.forEach(date => {
                    if (datesWithRecords.has(date)) {
                        datesWithRecordsData.push(date);
                    } else {
                        emptyDatesData.push(date);
                    }
                });


                this.renderCalendar();
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error fetching Timesheet data:', error);
            });
    }

    fetchAttendanceData() {
        console.log('this.employeeDetails @@@@@--->> ' , this.employeeDetails);
        getAttendanceData({ employeeId: this.employeeDetails.EmpRecordId,  })
            .then(result => {

                console.log('result@@',JSON.parse(JSON.stringify(result)));
                if (result && result.length > 0) {
                    // Initialize arrays to store categorized data
                    // this.attendanceData = {
                    //     above8: [],
                    //     below8: [],
                    //     equal0: [],
                    // };
                    // Categorize attendance data based on Total_Timesheet_Hours__c
                    result.forEach(item => {
                        if (item.Total_Timesheet_Hours__c > 7.75) {
                            this.attendanceData.above8.push(item);
                        } else if (item.Total_Timesheet_Hours__c < 8 && item.Total_Timesheet_Hours__c > 0) {
                            this.attendanceData.below8.push(item);
                        } else if (item.Total_Timesheet_Hours__c === 0) {
                            this.attendanceData.equal0.push(item);
                        }
                    });

                    // Call the renderCalendar method here to update the calendar based on the categorized data.
                    this.renderCalendar();
                    this.isLoading = false;
                } else {

                }
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error fetching Attendance data:', error);
                console.error(error.body.message); // Log the specific error message from the server
            });
    }

    renderCalendar() {

        const date = new Date(this.currYear, this.currMonth, 1);

        let firstDayofMonth = date.getDay();

        let lastDateofMonth = new Date(this.currYear, this.currMonth + 1, 0).getDate();

        let lastDayofMonth = new Date(this.currYear, this.currMonth, lastDateofMonth).getDay();

        let lastDateofLastMonth = new Date(this.currYear, this.currMonth, 0).getDate();

        let liTag = [];
        let today = new Date();
        today.setHours(0, 0, 0, 0);


        for (let i = firstDayofMonth; i > 0; i--) {
            let currentDate = new Date(this.currYear, this.currMonth - 1, lastDateofLastMonth - i + 1);
            let dateString = currentDate.toISOString().split('T')[0];

            const hasRecords = this.timesheetData.some(item => item.Date__c === dateString);

            let classAttribute = 'calendar-day-hover inactive';
            if ((currentDate < today)) {
                if (hasRecords) {
                    classAttribute += ' has-records';
                } else {
                    classAttribute += ' ';
                }
            }

            liTag.push({ day: lastDateofLastMonth - i + 1, className: classAttribute });
        }

        for (let i = 1; i <= lastDateofMonth; i++) {
            let currentDate = new Date(this.currYear, this.currMonth, i);
            const dayString = i.toString().padStart(2, '0'); // Convert day to string with leading zero if necessary
            const monthString = (this.currMonth + 1).toString().padStart(2, '0'); // Convert month to string with leading zero if necessary
            const dateString = `${this.currYear}-${monthString}-${dayString}`;
            const hasRecords = this.timesheetData.some(item => item.Date__c === dateString);
            let isToday = i === new Date().getDate() && this.currMonth === new Date().getMonth() && this.currYear === new Date().getFullYear();

            let classAttribute = 'calendar-day-hover';

            if (isToday) {
                classAttribute += ' active';
            }

            if (currentDate < today) {
                if (hasRecords) {
                    classAttribute += ' has-records';
                    // Check if the attendance data for this date is above 8 hours or below 8 hours
                    console.log('this.attendanceData',this.attendanceData);
                    const attendanceData = this.attendanceData.above8.find(item => item.Date__c === dateString);
                    if (attendanceData) {
                        classAttribute += ' Completed-8-hours';
                    } else {
                        classAttribute += ' below-8-hours';
                    }
                } else {
                    classAttribute += ' empty-records';
                }
            } else {
                classAttribute += ' future-date'; // For future dates
            }
            if (dateString === this.selectedDate) {
                classAttribute += ' selected-date';
            }

            liTag.push({ day: i, month: this.currMonth + 1, year: this.currYear, className: classAttribute, currentSelectedDate: `${this.currYear}-${monthString}-${dayString}` });

        }

        for (let i = lastDayofMonth; i < 6; i++) {
            liTag.push({ day: i - lastDayofMonth + 1, className: 'inactive' });
        }



        this.dateCells = liTag;

        this.currentMonth = `${monthNames[this.currMonth]}`;



    };

    initializeCalendar() {
        const currentDate = new Date();
        this.currentMonth = monthNames[currentDate.getMonth()];
        this.currentYear = currentDate.getFullYear();
        // this.generateCalendar(currentDate.getMonth(), currentDate.getFullYear());
    }

    isLeapYear(year) {
        return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0);
    }

    getFebDays(year) {
        return this.isLeapYear(year) ? 29 : 28;
    }


    showMonthList() {
        this.monthListClass = 'month-list show';
    }


    prevnextmonth(event) {

        const clickedElementId = event.target.id;
        this.currMonth = clickedElementId.includes("prev") ? this.currMonth - 1 : this.currMonth + 1;
        if (this.currMonth < 0 || this.currMonth > 11) {
            this.currYear = clickedElementId.includes("prev") ? this.currYear - 1 : this.currYear + 1;
            this.currMonth = this.currMonth < 0 ? 11 : 0;
        }

        this.renderCalendar();
    }

    prevYear() {
        this.currYear--;
        this.renderCalendar();
        // this.generateCalendar(this.template.querySelector('.month-picker').dataset.month, this.currentYear);
    
    }

    nextYear() {
        this.currYear++;
        this.renderCalendar();
        //this.generateCalendar(this.template.querySelector('.month-picker').dataset.month, this.currentYear);
    }



    selectDate(event) {
        if (!event.currentTarget.classList.contains('inactive')) {

            const dateElements = this.template.querySelectorAll('.calendar-days li');
            dateElements.forEach((element) => {
                element.classList.remove('selected-date');
            });

            event.currentTarget.classList.add('selected-date');
            this.selectedDate = event.target.dataset.day;
            this.renderCalendar();

            const dateSelect = new CustomEvent("getdate", {
                detail: event.target.dataset.day
            });
            this.dispatchEvent(dateSelect);
        }
    }
    get monthNames() {
        return monthNames.map((name, index) => ({ name, index }));
    }
    get weekDays() {
        return weekDays;
    }
    selectMonth(event) {
        // const selectedMonth = event.target.dataset.month;
        this.currMonth = Number(event.target.dataset.month);
        this.currentMonth = monthNames[this.currMonth];
        // Close the pop-up
        this.monthListClass = 'month-list';

        this.renderCalendar();
        //this.generateCalendar(selectedMonthIndex, this.currentYear);

        
        this.fetchTimesheetData(selectedMonthIndex, this.currentYear);
    }

    customDateHandlerChanged(requestData) {
        // this.selectedDate = requestData;
        // this.renderCalendar();
        const date = new Date(requestData);
        this.selectedDate = requestData;
        this.currMonth = date.getMonth(); // Set the month from the received date
        this.currYear = date.getFullYear(); // Set the year from the received date
        this.renderCalendar();
    }
}