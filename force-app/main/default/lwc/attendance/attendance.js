import { LightningElement, api, track} from 'lwc';
import nextArrow from '@salesforce/resourceUrl/AttendanceCalendarRightArrow';
import backArrow from '@salesforce/resourceUrl/AttendanceCalendarLeftArrow';
import getAttendanceData from '@salesforce/apex/AttendanceController.getAttendanceData';
import getHolidaysByMonth from '@salesforce/apex/AttendanceController.getHolidaysByMonth';
import getFirstClockInDate from '@salesforce/apex/AttendanceController.getFirstClockInDate';
import getCurrentDayClockIn from '@salesforce/apex/AttendanceController.getCurrentDayClockIn';

const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

const monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
];

export default class Attendance extends LightningElement {
    @api recordId;
    @track attendanceDetails = {
        totalWorkingDays: 0,
        totalPresentDays: 0,
        totalLeaves: 0,
        totalHalfDays: 0,
        onTimeArrivalPercentage: 0,
        onTimeArrivalCounter: 0,
    };
    currMonth; //having month names inside it (not index)  apex needs exact month but js needs month -1
    currYear;
    monthPassInApex;
    @track employeeAttendance = {};
    @track holidays = {};
    @track firstClockIn = {};
    @track currentDayClockIn = {};
    @track firstWeek = [];
    @track secondWeek = [];
    @track thirdWeek = [];
    @track fourthWeek = [];
    @track fifthWeek = [];
    @track sixthWeek = [];
    @track nonBusinessDays;
    isLoading = true;
    class = 'inactive';
    @track lastOnClick = {
        month: true,
        year: true
    };
    
    smallScreen = false;
    @track windowWidth;
    resizeHandler;

    // get weekDays() {
    //     return weekDays;
    // }
    
    connectedCallback(){
        this.leftArrow = backArrow;
        this.rightArrow= nextArrow;
        this.currYear = new Date().getFullYear();
        this.currMonth = monthNames[new Date().getMonth()];
        this.monthPassInApex = monthNames.findIndex(i=>i===this.currMonth) + 1;
        setTimeout(() => {

            const style = document.createElement('style');
            style.innerText = `
			.slds-spinner .slds-spinner__dot-b:after,.slds-spinner .slds-spinner__dot-b:before,.slds-spinner .slds-spinner__dot-a:after,.slds-spinner .slds-spinner__dot-a:before,.slds-spinner_large.slds-spinner:after,.slds-spinner_large.slds-spinner:before,.slds-spinner_medium.slds-spinner:after,.slds-spinner_medium.slds-spinner:before{
              background-color: #37a000 !important;
            }
			`;
            this.template.querySelector('.overrideStyle').appendChild(style);
        }, 10);
        this.getData();
        this.handleSmallScreen();
        // Add event listener to update window size when it changes
        this.resizeHandler = () => this.handleSmallScreen();
        window.addEventListener('resize', this.resizeHandler);
    }

    disconnectedCallback() {
        // Remove event listener to prevent memory leaks
        window.removeEventListener('resize', this.resizeHandler);
    }
    
    handleSmallScreen(){
        this.windowWidth = window.innerWidth;
        if(this.windowWidth < 480){
            this.smallScreen = true;
        }
        else{
            this.smallScreen = false;
        }
    }
   
    renderCalendar(month, year) {
        this.clearOutWeeks();

        const weekMap = new Map();
        weekMap.set(1, this.firstWeek);
        weekMap.set(2, this.secondWeek);
        weekMap.set(3, this.thirdWeek);
        weekMap.set(4, this.fourthWeek);
        weekMap.set(5, this.fifthWeek);
        weekMap.set(6, this.sixthWeek);

        month = monthNames.findIndex(i=>i===month);
        const totalDaysInMonth = new Date(year, month + 1, 0).getDate();
        this.attendanceDetails.totalWorkingDays = totalDaysInMonth;

        const initialDays = 0 - new Date(Date.UTC(year, month, 1)).getDay();
        const lastDays = 6 - new Date(Date.UTC(year, month, totalDaysInMonth)).getDay();

        const firstDate = new Date(new Date(Date.UTC(year, month, 1)).getTime());
        firstDate.setDate(firstDate.getDate() + initialDays); // initial days should be either 0 or negative number

        const lastDate = new Date(new Date(Date.UTC(year, month, totalDaysInMonth)).getTime());
        lastDate.setDate(lastDate.getDate() + lastDays); // lastdays should be either 0 or positive number

        let currentDate = firstDate;
        let counter = 1;

        while (currentDate <= lastDate) {
            const obj = this.syncAttendanceData(currentDate, month, year);

            if (weekDays[currentDate.getDay()] === 'Sat') {
                weekMap.get(counter).push(obj);
                counter++;
            }
            else {
                weekMap.get(counter).push(obj);
            }
            currentDate.setDate(currentDate.getDate() + 1);
        } 
        this.attendanceDetails.onTimeArrivalPercentage = (Object.keys(this.employeeAttendance).length === 0) ? 0 : Math.round((this.attendanceDetails.onTimeArrivalCounter * 100) / Object.keys(this.employeeAttendance).length);
        // console.log(weekMap);
        // console.log(this.attendanceDetails.onTimeArrivalPercentage);
        // console.log(this.attendanceDetails.onTimeArrivalCounter);
        // console.log(Object.keys(this.employeeAttendance).length);  
    }
    
    handleMonthChange(event) {
        this.isLoading = true;
        if (event.target.dataset.action === 'last') {
            if (this.currMonth === 'January') {
                this.currMonth = 'December';
                this.currYear--;
                this.monthPassInApex = monthNames.findIndex(i=>i===this.currMonth) + 1;
            }
            else{
                const monthIndex = monthNames.findIndex(i=>i===this.currMonth) - 1;
                this.currMonth = monthNames[monthIndex];
                this.monthPassInApex = monthIndex + 1;
            }
        }
        else if (event.target.dataset.action === 'next') {
            if (this.currMonth === 'December') {
                this.currMonth = 'January';
                this.currYear++;
                this.monthPassInApex = monthNames.findIndex(i=>i===this.currMonth) + 1;
            }
            else{
                const monthIndex = monthNames.findIndex(i=>i===this.currMonth) + 1;
                this.currMonth = monthNames[monthIndex];
                this.monthPassInApex = monthIndex + 1;
            }
            // this.renderCalendar(this.currMonth, this.currYear);
        }
        this.getData();
    }

    handleYearChange(event) {
        this.isLoading = true;
        if (event.target.dataset.action === 'last') {
            this.currYear--;
        }
        else if(event.target.dataset.action === 'next') {
            this.currYear++;
        }
        this.getData();
    }

    clearOutWeeks() {
        this.firstWeek = [];
        this.secondWeek = [];
        this.thirdWeek = [];
        this.fourthWeek = [];
        this.fifthWeek = [];
        this.sixthWeek = [];
        this.attendanceDetails.totalWorkingDays = 0;
        this.attendanceDetails.totalPresentDays = 0;
        this.attendanceDetails.totalLeaves = 0;
        this.attendanceDetails.totalHalfDays = 0;
        this.attendanceDetails.onTimeArrivalPercentage = 0;
        this.attendanceDetails.onTimeArrivalCounter = 0;
    }

    // checkForSundayOrSaturday(date) {
    //     if(weekDays[date.getDay()] === 'Sun'){
    //         return true;
    //     }
    //     else if(weekDays[date.getDay()] === 'Sat'){
    //             if(date.getDate() <= 7){
    //                 return true;
    //             }
    //             else if(date.getDate() >= 15 && date.getDate() <= 21){
    //                 return true;
    //             }
    //     }
    //     return false;
    // }

    async getData(){
        // console.log(this.monthPassInApex);
        // console.log(this.currMonth);
        // console.log(monthNames[new Date().getMonth()]);
        const promiseArr = [
            getAttendanceData({month: this.monthPassInApex, year: this.currYear, employeeId: this.recordId}),
            getHolidaysByMonth({month: this.monthPassInApex, year: this.currYear}),
            getFirstClockInDate({employeeId: this.recordId})
        ];
        if (this.currMonth === monthNames[new Date().getMonth()]) {
            promiseArr.push(getCurrentDayClockIn({employeeId: this.recordId}));
        }
        await Promise.all(promiseArr)
        .then(result=>{
            // console.log(JSON.parse(result[0]), 'r1');
            this.employeeAttendance = (result[0] != null) ? JSON.parse(result[0]) : {};
            // console.log(result[1], 'r2');    
            this.holidays = (result[1] != null) ? result[1] : {};
            this.firstClockIn = (result[2] != null) ? result[2] : {};
            // console.log(this.holidays);
            this.currentDayClockIn = (result [3] != null) ? result[3] : {};
            // console.log(this.currentDayClockIn);
        })
        .catch(err=>{
            console.error('Error while fetching data from Apex', err);
        });

        // console.log(JSON.stringify(this.firstClockIn));
        if (+this.firstClockIn.month === this.monthPassInApex && +this.firstClockIn.year === this.currYear) {
            this.lastOnClick.month = false;
        }
        else{
            this.lastOnClick.month = true;
        }

        if (+this.firstClockIn.year + 1 === this.currYear && +this.firstClockIn.month > this.monthPassInApex) {
                this.lastOnClick.year = false;
        }
        else if (+this.firstClockIn.year === this.currYear && +this.firstClockIn.month <= this.monthPassInApex) {
            this.lastOnClick.year = false;
        }
        else{
            this.lastOnClick.year = true;
        }

        this.renderCalendar(this.currMonth, this.currYear);
        this.isLoading = false;
    }

    syncAttendanceData(currentDate, month, year) {
        const date = currentDate.toLocaleDateString('en-CA', {year: 'numeric', month: '2-digit', day:'2-digit'});
        //console.log('Date : ',date);
        const obj = {
            Date : (currentDate.getDate() < 10) ? `0${currentDate.getDate()}` : `${currentDate.getDate()}`,
            Day: weekDays[currentDate.getDay()],
            class: {
                main: 'DA', // Deactivated Date
                dateround: 'DA-dateround',
                status: 'DA-status'
            },
            clockIn: '',
            clockOut: '',
            timeDiff: '',
            isHoliday: false,
            isManualHoliday: false,
            HolidayReason: '',
            manualStatus: '', 
            ontimearrival: ''
        }
        
        if (this.employeeAttendance.hasOwnProperty(date)) {
            const clockIn = {
                hours : new Date(this.employeeAttendance[date].clockIn).getHours() ,
                mins: new Date(this.employeeAttendance[date].clockIn).getMinutes()
            };

            const clockOut = {
                hours : new Date(this.employeeAttendance[date].clockOut).getHours(),
                mins: new Date(this.employeeAttendance[date].clockOut).getMinutes()
            };

            obj.clockIn = `${(clockIn.hours < 10) ? `0${clockIn.hours}` : clockIn.hours}:${(clockIn.mins < 10) ? `0${clockIn.mins}` : clockIn.mins}-`;
            obj.clockOut = `${(clockOut.hours < 10) ? `0${clockOut.hours}` : clockOut.hours}:${(clockOut.mins < 10) ? `0${clockOut.mins}` : clockOut.mins}`;

            const attendanceStatus = this.checkAttendanceStatus(this.employeeAttendance[date].clockIn, this.employeeAttendance[date].totalTimeSpan, this.employeeAttendance[date].presentStatus, this.employeeAttendance[date].manualPresentStatus);

            obj.class.main = attendanceStatus;
            obj.class.dateround = `${attendanceStatus}-dateround`;
            obj.class.status = `${attendanceStatus}-status`;
            obj.timeDiff = this.employeeAttendance[date].totalTimeSpan.replace(/\s/g, '').replace('Hrs', 'h').replace('Mins', 'm').replace(':', ' ');
            obj.ontimearrival = this.employeeAttendance[date].onTimeArrivalStatus;
            if(obj.class.main === 'FHL' || obj.class.main === 'SHL'){
                this.attendanceDetails.totalHalfDays++;
            }
            if(obj.ontimearrival == true){
                this.attendanceDetails.onTimeArrivalCounter++;
            }
            this.attendanceDetails.totalPresentDays++;
            // this.onTimeArrivalCounts(this.employeeAttendance[date], obj);
        }
        else if(Object.keys(this.currentDayClockIn).length > 0 && currentDate.getDate() === new Date().getDate() && currentDate.getMonth() === new Date().getMonth() && currentDate.getFullYear() === new Date().getFullYear()) {
            obj.class.main = 'TODAY';
            obj.class.dateround = `TODAY-dateround`;
            obj.class.status = `TODAY-status`;
            obj.clockIn = this.currentDayClockIn.time;
            // obj.ontimearrival = this.currentDayClockIn.onTimeArrival;
            // if(obj.ontimearrival == 'true'){
            //     // console.log(this.attendanceDetails.onTimeArrivalCounter);
            //     this.attendanceDetails.onTimeArrivalCounter++;
            // }
            // this.attendanceDetails.totalPresentDays++;
            // console.log(this.attendanceDetails.totalPresentDays);
            // console.log(this.attendanceDetails.onTimeArrivalCounter);
        }
        else if(this.currMonth === monthNames[new Date().getMonth()] && currentDate.getDate() === new Date().getDate() && currentDate.getMonth() === new Date().getMonth() && currentDate.getFullYear() === new Date().getFullYear()) {
            obj.class.main = 'CMD';
            obj.class.dateround = `CMD-dateround`;
            obj.class.status = `CMD-status`;
        }
        else if (this.holidays.hasOwnProperty(date) && currentDate.getMonth() === month && currentDate.getFullYear() === year) {
            // console.log(this.holidays[date]);
            if (this.holidays[date] === 'WO') {
                obj.class.main = 'WO';
                obj.class.dateround = `WO-dateround`;
                obj.class.status = `WO-status`;
                (currentDate.getMonth() === month) ? this.attendanceDetails.totalWorkingDays-- : '';
            }
            else{
                obj.isHoliday = true;
                obj.isManualHoliday = (this.holidays[date] === 'Manual Holiday') ? true : false;
                obj.HolidayReason = (this.holidays[date] === 'Manual Holiday') ? ' (Holiday)' : ` (${this.holidays[date]})`;
                obj.class.main = `FO ${(this.holidays[date] !== 'Manual Holiday' && this.holidays[date] !== 'FO' && this.holidays[date] !== 'WO') ? `(${this.holidays[date]})` : ''}`;
                obj.class.dateround = `FO-dateround`;
                obj.class.status = `FO-status`;
                (currentDate.getMonth() === month) ? this.attendanceDetails.totalWorkingDays-- : '';
            }
        }
        // else if(this.checkForSundayOrSaturday(currentDate) && currentDate.getMonth() === month && currentDate.getFullYear() === year) {
        //     obj.class.main = 'WO';
        //     obj.class.dateround = `WO-dateround`;
        //     obj.class.status = `WO-status`;
        //     (currentDate.getMonth() === month) ? this.attendanceDetails.totalWorkingDays-- : '';
        // }
        else if(currentDate < new Date() && currentDate.getMonth() === month && currentDate.getFullYear() === year) {
            if (this.firstClockIn.date > date && +this.firstClockIn.month === this.monthPassInApex && +this.firstClockIn.year === this.currYear) {
                obj.class.main = 'CMD';
                obj.class.dateround = `CMD-dateround`;
                obj.class.status = `CMD-status`;
            }
            else{
                obj.class.main = 'FDL';
                obj.class.dateround = `FDL-dateround`;
                obj.class.status = `FDL-status`;
                this.attendanceDetails.totalLeaves++;
            }
        }
        else if(currentDate.getMonth() === month && currentDate.getFullYear() === year) {
            obj.class.main = 'CMD';
            obj.class.dateround = `CMD-dateround`;
            obj.class.status = `CMD-status`;
        }
        return obj;
    }

    // onTimeArrivalCounts(obj, obj2) {
    //     if (
    //         (obj2.class.main === 'SHL' || obj2.class.main === 'P') &&
    //         (
    //             new Date(obj.clockIn).getHours() < 10 || 
    //             (
    //                 new Date(obj.clockIn).getHours() === 10 &&
    //                 new Date(obj.clockIn).getMinutes() === 0 && 
    //                 new Date(obj.clockIn).getSeconds() === 0
    //             )
    //         )
    //     ) {
    //         // console.log(obj.class.main);
    //         this.attendanceDetails.onTimeArrivalCounter++;
    //     }
    //     else if(
    //         obj2.class.main === 'FHL' &&
    //         (
    //             new Date(obj.clockIn).getHours() < 3 || 
    //             (
    //                 new Date(obj.clockIn).getHours() === 3 &&
    //                 new Date(obj.clockIn).getMinutes() === 0 && 
    //                 new Date(obj.clockIn).getSeconds() === 0
    //             )
    //         )
    //     ) {
    //         // console.log(obj);
    //         this.attendanceDetails.onTimeArrivalCounter++;
    //     }
    // }

    checkAttendanceStatus(clockInTime, timeSpan, presentStatus, manualPresentStatus) {
        timeSpan = +timeSpan.substring(0, timeSpan.indexOf('Hrs'));
        clockInTime = new Date(clockInTime);

        // console.log('cl',clockInTime.getHours());
        // console.log('t',timeSpan);
        
        if(manualPresentStatus != null) {
            return manualPresentStatus;
        }
        else if (
            (clockInTime.getHours() > 14 && clockInTime.getMinutes() > 0) ||
            (clockInTime.getHours() === 14)
        ) {
            return 'FHL';
        }
        else if (clockInTime.getHours() < 14 && timeSpan < 9) {
            return 'SHL';
        }
        else if (clockInTime.getHours() < 14 && timeSpan >= 9) {
            return 'P';
        }
        else{
            return presentStatus;
        }
    }
}