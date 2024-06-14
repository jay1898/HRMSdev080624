import { LightningElement, wire } from 'lwc';
import getEmployeesBirthdays from '@salesforce/apex/AnnouncementController.getEmployeesBirthdays';
import getEmployeesWorkAnniversary from '@salesforce/apex/AnnouncementController.getEmployeesWorkAnniversary';
import getNotificationData from '@salesforce/apex/AnnouncementController.fetchNotificationData';

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
    profileImages = {};

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
            this.todayBirthday = data.todayBirthdays.map(birth => ({
                ...birth,
                Formatted_Date_of_Birth__c: this.formatDate(birth.Date_of_Birth__c)
            }));
            if (this.todayBirthday.length > 0) {
                this.isNoBirthdayToday = false;
                this.isBirthdayToday = true;
            }
            this.nextSevenDaysBirthdays = data.nextSevenDaysBirthdays.map(birth => ({
                ...birth,
                Formatted_Date_of_Birth__c: this.formatDate(birth.Date_of_Birth__c)
            }));
            if (this.nextSevenDaysBirthdays.length > 0) {
                this.isNoBirthdayInSeven = false;
                this.isBirthdayInSeven = true;
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
            console.log('dataanniversary---->',data);
            this.todaydateAnniversarys = data.todaydateAnniversary.map(anniversary => ({
                ...anniversary,
                Formatted_Date_Of_Joining__c: this.formatDate(anniversary.Date_Of_Joining__c)
            }));
            if (this.todaydateAnniversarys.length > 0) {
                this.isNoAnniversaryToday = false;
                this.isAnniversaryToday = true;
            }
            this.nextSevenDaysAnniversarys = data.nextSevenDaysAnniversary.map(anniversary => ({
                ...anniversary,
                Formatted_Date_Of_Joining__c: this.formatDate(anniversary.Date_Of_Joining__c)
            }));
            if (this.nextSevenDaysAnniversarys.length > 0) {
                this.isNoWorkAnniversaryInSeven = false;
                this.isWorkAnniversaryInSeven = true;
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
