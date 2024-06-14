import { LightningElement, wire } from 'lwc';
import getEmployeesBirthdays from '@salesforce/apex/AnnouncementController.getEmployeesBirthdays';
import getEmployeesWorkAnniversary from '@salesforce/apex/AnnouncementController.getEmployeesWorkAnniversary';
import IMAGE1 from "@salesforce/resourceUrl/AltImage";
import My_Image from '@salesforce/resourceUrl/profileimage'


export default class BirthdayAndWorkanniversary extends LightningElement {
    selectedTabLabel;
    isBirthdayTab = true;
    isWorkAnniversaryTab = false;
    todayBirthday = [];
    nextSevenDaysBirthdays = [];
    isNoBirthdayToday = true;
    isBirthdayToday = false;
    isBirthdayInSeven = false;
    isNoBirthdayInSeven = true;
    nextSevenDaysAnniversarys = [];
    todaydateAnniversarys = [];
    isNoAnniversaryToday = true;
    isAnniversaryToday = false;
    isNoWorkAnniversaryInSeven = true;
    spinner = true;
    spinnerAnni = true;
    altImages = My_Image;

    connectedCallback() {
        if (this.selectedTabLabel) {
            const activeTab = this.template.querySelector(`[data-tab="${this.selectedTabLabel}"]`);
            if (activeTab) {
                this.adjustIndicator(activeTab);
            }
        }
    }

    tabs = [
        { label: 'Birthday', isActive: true },
        { label: 'Work Anniversaries', isActive: false },
    ];

    @wire(getEmployeesBirthdays)
    wiredBirthdayData({ error, data }) {
        if (data) {
            //For Sorting the Lisr order wise birthday for next seven days
            const nextSevenDaysBirthdays = [...data.nextSevenDaysBirthdays];
            nextSevenDaysBirthdays
            nextSevenDaysBirthdays.sort((a, b)=>{
                const monthA = new Date(a.Date_of_Birth__c).getMonth();
                const dayA = new Date(a.Date_of_Birth__c).getDate();

                const monthB = new Date(b.Date_of_Birth__c).getMonth();
                const dayB = new Date(b.Date_of_Birth__c).getDate();

                // If years are equal, compare months
                if (monthA < monthB) return -1;
                if (monthA > monthB) return 1;

                // If months are equal, compare dates
                if (dayA < dayB) return -1;
                if (dayA > dayB) return 1;
                return 0;
            });
            console.log('LIST ORDER nextSevenDaysBirthdays--------->', nextSevenDaysBirthdays);
            this.todayBirthday = data.todayBirthdays.map(birth => ({
                ...birth,
                Formatted_Date_of_Birth__c: this.formatDate(birth.Date_of_Birth__c),
                HasProfile_Photo: (birth.Profile_Photo !== undefined && birth.Profile_Photo !== null) ? true : false,
                Profile_Photo: birth.Profile_Photo ? birth.Profile_Photo : this.altImages
            }));
            if (this.todayBirthday.length > 0) {
                this.isNoBirthdayToday = false;
                this.isBirthdayToday = true;
                this.spinner = false;
            }else {// This Was set For spinner false if no birthday comes on birthday Tab
                this.isNoBirthdayToday = true;
                this.isBirthdayToday = false;
                this.spinner = false; // Set spinner to false when there are no birthdays today
            }
            this.nextSevenDaysBirthdays = nextSevenDaysBirthdays.map(birth => ({//remove data.nextSevenDaysBirthdays 
                ...birth,
                Formatted_Date_of_Birth__c: this.formatDate(birth.Date_of_Birth__c),
                HasProfile_Photo: (birth.Profile_Photo !== undefined && birth.Profile_Photo !== null) ? true : false,
                Profile_Photo: birth.Profile_Photo ? birth.Profile_Photo : this.altImages
            }));
            if (this.nextSevenDaysBirthdays.length > 0) {
                this.isNoBirthdayInSeven = false;
                this.isBirthdayInSeven = true;
                this.spinner = false;
            }
            else {// This Was set For spinner false if no birthday comes on birthday Tab
                this.isNoBirthdayInSeven = true;
                this.isBirthdayInSeven = false;
                this.spinner = false; // Set spinner to false when there are no birthdays 
            }
            console.log('this.todayBirthday666666---------->', this.todayBirthday);
            console.log('this.nextSevenDaysBirthdays66666--->', this.nextSevenDaysBirthdays);
        } else if (error) {
            console.error('Error fetching birthday data:', error);
        }
    }

    @wire(getEmployeesWorkAnniversary)
    wiredWorkAnniversaryData({ error, data }) {
        if (data) {
            //For Sorting the Lisr order wise birthday for next seven days
            const nextSevenDaysAnniversary = [...data.nextSevenDaysAnniversary];
            nextSevenDaysAnniversary
            nextSevenDaysAnniversary.sort((a, b)=>{
                const monthA = new Date(a.Date_Of_Joining__c).getMonth();
                const dayA = new Date(a.Date_Of_Joining__c).getDate();

                const monthB = new Date(b.Date_Of_Joining__c).getMonth();
                const dayB = new Date(b.Date_Of_Joining__c).getDate();

                // If years are equal, compare months
                if (monthA < monthB) return -1;
                if (monthA > monthB) return 1;

                // If months are equal, compare dates
                if (dayA < dayB) return -1;
                if (dayA > dayB) return 1;
                return 0;
            });
            console.log('LIST ORDER nextSevenDaysAnniversary--------->', nextSevenDaysAnniversary);
            this.todaydateAnniversarys = data.todaydateAnniversary.map(anniversary => ({
                ...anniversary,
                //Formatted_Date_Of_Joining__c: this.formatDate(anniversary.Date_Of_Joining__c),
                HasProfile_Photo: (anniversary.Profile_Photo !== undefined && anniversary.Profile_Photo !== null) ? true : false,
                Profile_Photo: anniversary.Profile_Photo ? anniversary.Profile_Photo : this.altImages
            }));
            if (this.todaydateAnniversarys.length > 0) {
                this.isNoAnniversaryToday = false;
                this.isAnniversaryToday = true;
                this.spinnerAnni = false;
            }else {// This Was set For spinner false if no Anniversary comes on Anniversary Tab
                this.isNoAnniversaryToday = true;
                this.isAnniversaryToday = false;
                this.spinnerAnni = false; // Set spinner to false when there are no Anniversary today
            }
            this.nextSevenDaysAnniversarys = nextSevenDaysAnniversary.map(anniversary => ({//remove data.nextSevenDaysAnniversary 
                ...anniversary,
                Years_of_Experience: anniversary.Years_of_Experience + 1,
                HasProfile_Photo: (anniversary.Profile_Photo !== undefined && anniversary.Profile_Photo !== null) ? true : false,
                Profile_Photo: anniversary.Profile_Photo ? anniversary.Profile_Photo : this.altImages
            }));
            if (this.nextSevenDaysAnniversarys.length > 0) {
                this.isNoWorkAnniversaryInSeven = false;
                this.isWorkAnniversaryInSeven = true;
                this.spinnerAnni = false;
            }else {// This Was set For spinner false if no Anniversary comes on Anniversary Tab
                this.isNoWorkAnniversaryInSeven = true;
                this.isWorkAnniversaryInSeven = false;
                this.spinnerAnni = false; // Set spinner to false when there are no Anniversary
            }
            console.log('todaydateAnniversary---------->', this.todaydateAnniversarys);
            console.log('this.nextSevenDaysAnniversary--->', this.nextSevenDaysAnniversarys);
        } else if (error) {
            console.error('Error fetching work anniversary data:', error);
        }
    }

    formatDate(dateString) {
        const date = new Date(dateString);
        const day = date.getDate();
        const month = date.toLocaleString('en-us', { month: 'long' });
        return `${day} ${month.toUpperCase()}`;
    }

    handleTabClick(event) {
        this.selectedTabLabel = event.target.dataset.tab;
        this.tabs.forEach(tab => {
            tab.isActive = tab.label === this.selectedTabLabel;
        });

        if (this.selectedTabLabel === 'Birthday') {
            this.isBirthdayTab = true;
            this.isWorkAnniversaryTab = false;
        } else if (this.selectedTabLabel === 'Work Anniversaries') {
            this.isBirthdayTab = false;
            this.isWorkAnniversaryTab = true;
        }
        this.adjustIndicator(event.currentTarget);
    }

    adjustIndicator(tabElement) {
        const indicator = this.template.querySelector('.tab-indicator');
        indicator.style.width = tabElement.offsetWidth + 'px';
        indicator.style.transform = `translateX(${tabElement.offsetLeft}px)`;
    }

    get isActive() {
        return this.tabs.find(tab => tab.isActive);
    }
}