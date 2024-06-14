import { LightningElement, track, wire, api } from 'lwc';
import saveAnnouncement from '@salesforce/apex/AnnouncementController.saveAnnouncement';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getAllAnnouncements from '@salesforce/apex/AnnouncementController.getAllAnnouncements';
import updateAnnouncement from '@salesforce/apex/AnnouncementController.updateAnnouncement';
import deleteAnnouncement from '@salesforce/apex/AnnouncementController.deleteAnnouncement';
import fetchImage from '@salesforce/apex/AnnouncementController.fetchImage';
//import fetchExpirationDate from '@salesforce/apex/AnnouncementController.fetchNotificationData';


export default class Announcement extends LightningElement {
    @track notifications;
    @track announcementList = [];
    @track error;
    @track announcement = '';
    @api recordId;
    wiredAnnouncementResult;
    selectedTabLabel;
    isAnnouncementTab = true;
    isPostTab = false;
    isHolidaysTab = false;


    @track isModalOpen = false;
    @track isDeleteModalOpen = false;

    @track editedContent = '';
    @track currentEditingId = '';
    @track currentDeletingId = '';

    @track profileImage;
    @track isUploading = false;
    tempdp;
    expirationDate;
    dateValue;
    inputDate;
    todayDate;
    minDate = this.getMinDate(); 
    @track hideAnnouncement = false;

    openModal(event) {
        let buttonElement = event.target;
        // If the icon or span inside the button was clicked, access the parent button element
        if (!event.target.dataset.id) {
            buttonElement = event.target.closest('button');
        }

        this.currentEditingId = buttonElement.dataset.id;
        console.log('this.currentEditingId  OUTPUT : ', this.currentEditingId);
        this.editedContent = this.notifications.find(notif => notif.Id === this.currentEditingId).Content__c;
        console.log(' this.editedContent this.editedContent OUTPUT : ', this.editedContent);
        this.isModalOpen = true;

        // this.fetchAndDisplayImage();
    }


    deleteModal(event) {
        let buttonDeleteElement = event.target;

        // If the icon or span inside the button was clicked, access the parent button element
        if (!event.target.dataset.id) {
            buttonDeleteElement = event.target.closest('button');
        }

        this.currentDeletingId = buttonDeleteElement.dataset.id;

        console.log('this.currentDeletingId  OUTPUT : ', this.currentDeletingId);
        this.isDeleteModalOpen = true;
    }

    handleContentChange(event) {
        this.editedContent = event.target.value;
    }

    handleModalCancel() {
        this.isModalOpen = false;
        this.isDeleteModalOpen = false;
    }

    async handleSaveEdit() {
        try {
            console.log('in handle edit save modal : ', this.editedContent);
            // const editedAnnouncement = { Id: this.currentEditingId, Content__c: this.editedContent };
            await updateAnnouncement({ currentEditingId: this.currentEditingId, editedContent: this.editedContent })
                .then(result => {
                    console.log('Result', result);
                })
                .catch(error => {
                    console.error('Error:', error);
                });
            // await updateAnnouncement(editedAnnouncement);
            await refreshApex(this.wiredAnnouncementResult);
            this.isModalOpen = false;
        } catch (error) {
            this.error = error;
            console.error('Error updating announcement: ', error);
        }
    }

    async handleDelete() {
        try {
            // console.log('in handle edit save modal : ',this.editedContent);
            // const editedAnnouncement = { Id: this.currentEditingId, Content__c: this.editedContent };
            await deleteAnnouncement({ currentDeletingId: this.currentDeletingId })
                .then(result => {
                    console.log('Result', result);
                })
                .catch(error => {
                    console.error('Error:', error);
                });
            // await updateAnnouncement(editedAnnouncement);
            await refreshApex(this.wiredAnnouncementResult);
            this.isDeleteModalOpen = false;
        } catch (error) {
            this.error = error;
            console.error('Error updating announcement: ', error);
        }
    }

    @wire(getAllAnnouncements)
    wiredAnnouncements(result) {

        function formatDate(dateString) {
            const date = new Date(dateString);
            const day = date.getDate();
            const month = date.getMonth() + 1;
            const year = date.getFullYear();
            
            // Pad single digits with leading zero
            const formattedDay = String(day).padStart(2, '0');
            const formattedMonth = String(month).padStart(2, '0');

            return `${formattedDay} ${formattedMonth} ${year}`;
        }


        this.wiredAnnouncementResult = result; // Storing the response
        if (result.data) {

            this.notifications = result.data.map(notification => ({
                ...notification,
                isEditable: notification.Announced_by__c === this.recordId,
                 CreatedDateFormatted: formatDate(notification.CreatedDate)
            }));

            console.log('emp id@@!!@@!!', this.recordId);
            console.log('OUTPUT : ', this.notifications);
            this.tempdp = this.notifications;
            let profileUrl;
            // Fetch and display image for each notification
            this.notifications.forEach(notification => {
                if (notification.Announced_by__c) {
                    this.fetchAndDisplayImage(notification.Announced_by__c);
                    // console.log('notification.Announced_by__c::>>',notification.Announced_by__c);
                    // fetchImage({ fileName: 'Employee Profile Photo', EmployeeId: notification.Announced_by__c })
                    //     .then(result => {
                    //         this.profileImage = 'data:image/jpeg;base64,'+result;
                    //     })
                    //     .catch(error => {
                    //         console.error('Error fetching image:', error);
                    // });
                    console.log('this.profileImage::>>', this.profileImage);
                }
                else {
                    this.profileImage = '';
                }
                this.announcementList.push({ ...notification, "profile": this.profileImage });
            });


            console.log('announcementList::>>', JSON.parse(JSON.stringify(this.announcementList)));

            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.notifications = undefined;
        }
    }
     getMinDate() {
        const today = new Date();
        let month = today.getMonth() + 1;  // getMonth() is zero-indexed
        let day = today.getDate();
        const year = today.getFullYear();
        // Ensure the month and day are two digits, e.g., 04, 09
        month = month < 10 ? '0' + month : month;
        day = day < 10 ? '0' + day : day;
        return `${year}-${month}-${day}`;  // format to YYYY-MM-DD
    }
    // fetchExpirationDate(event) {
    //     console.log('fetchExpirationDate @@!!@', event.target.value);
    //     this.expirationDate = event.target.value;
        
    //     // this.dateValue = event.target.value;
    // }
    fetchExpirationDate(event) {
     this.inputDate = new Date(event.target.value);
     this.todayDate = new Date(this.minDate);

    if (this.inputDate < this.todayDate) {
        this.expirationDate = null;
        // Optionally display an error message to the user
        this.dispatchEvent(new ShowToastEvent({
            title: 'Invalid Date',
            message: 'Please select a future date.',
            variant: 'error'
        }));
    } else {
        this.expirationDate = event.target.value;
    }
}

    async handleSave() {
        
        try {
            if(this.announcement == null || this.announcement == undefined || this.announcement ===''){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter Announcement.',
                    variant: 'error'
                }));
                return;
            }
            if (this.inputDate < this.todayDate) {
                this.expirationDate = '';
                // Optionally display an error message to the user
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Invalid Date',
                    message: 'Please select a future date.',
                    variant: 'error'
                }));
                this.expirationDate = '';
                return;
            }
            await saveAnnouncement({ announcementContent: this.announcement, empId: this.recordId, expirationDate: this.expirationDate});
            this.clearAnnouncement();
            this.expirationDate = '';
            this.dateValue = '';
            await refreshApex(this.wiredAnnouncementResult);
            // this.refreshAnnouncements(); // Refreshing the announcements after saving
        } catch (error) {
            this.error = error;
            console.error('Error saving announcement: ', error);
        }
    }


    handleChangeEvent(event) {
        this.announcement = event.target.value;
    }

    handleCancel() {
        this.clearAnnouncement();
    }

    clearAnnouncement() {
        this.announcement = '';
        this.expirationDate = '';
    }


    // async fetchAndDisplayImage(announcedById) {
    //     console.log('fetchAndDisplayImageIn : ', announcedById);
    //     const base64Data = await fetchImage({
    //         fileName: 'Employee Profile Photo',
    //         EmployeeId: announcedById
    //     });
    //     if (base64Data == '') {
    //         this.profileImage = My_Image;
    //         this.isUploading = false;
    //     } else {
    //         this.profileImage = 'data:image/jpeg;base64,' + base64Data;
    //         this.isUploading = false;
    //         let profileUrl = 'data:image/jpeg;base64,' + base64Data;
    //         //console.log('profileUrl : >>',  profileUrl);
    //         //return profileUrl;

    //     }
    // }
    async fetchAndDisplayImage(announcedById) {
        console.log('fetchAndDisplayImageIn : ', announcedById);
        const base64Data = await fetchImage({
            fileName: 'Employee Profile Photo',
            EmployeeId: announcedById
        });

        if (base64Data === '') {
            this.profileImage = My_Image;
            this.isUploading = false;
            return null; // Return null or any other value to indicate no image found
        } else {
            this.profileImage = 'data:image/jpeg;base64,' + base64Data;
            this.isUploading = false;
            let profileUrl = 'data:image/jpeg;base64,' + base64Data;
            return profileUrl;
        }
    }



    // Refresh data function
    refreshData() {
        console.log('inside refresh data method');
        if (this.wiredAnnouncementResult) {
            refreshApex(this.wiredAnnouncementResult);
        }
        // refreshApex(this.notifications);
        console.log('announcement @@!!@', this.notifications);
        // getAllAnnouncements()
        //     .then(result => {
        //         console.log('refresh data result',result);
        //         this.notifications = result;
        //         this.error = undefined;
        //     })
        //     .catch(error => {
        //         this.error = error;
        //         this.notifications = undefined;
        //     });
        console.log('last line refresh data method');

    }



    tabs = [
        { label: 'Announcement', isActive: true },
        { label: 'Post', isActive: false },
        { label: 'Holidays', isActive: false }
    ];

    handleTabClick(event) {
        this.selectedTabLabel = event.target.dataset.tab;
        this.tabs.forEach(tab => {
            tab.isActive = tab.label === this.selectedTabLabel;
        });

        if (this.selectedTabLabel === 'Announcement') {

            this.isAnnouncementTab = true;
            this.isPostTab = false;
            this.isHolidaysTab = false;
        } else if (this.selectedTabLabel === 'Post') {
            this.isAnnouncementTab = false;
            this.isPostTab = true;
            this.isHolidaysTab = false;

        } else if (this.selectedTabLabel === 'Holidays') {
            this.isAnnouncementTab = false;
            this.isPostTab = false;
            this.isHolidaysTab = true;

        }
        // Call adjustIndicator to move the indicator to the selected tab
        this.adjustIndicator(event.currentTarget);
    }

    adjustIndicator(tabElement) {
        const indicator = this.template.querySelector('.tab-indicator');
        indicator.style.width = tabElement.offsetWidth + 'px';
        indicator.style.transform = `translateX(${tabElement.offsetLeft}px)`;
    }
    connectedCallback() {
        // this.selectedTabLabel = 'Identity';
        // this.selectedTabLabel = 'Announcement';
        //this.fetchExpirationDate();

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
    // @wire(getAnnouncement)
    // announcements({ error, data }) {
    //     if (data) {
    //         this.announcements = data;
    //         console.log('all announcement',data);
    //     } else if (error) {
    //         this.error = error;
    //     }
    // }


    // refreshAnnouncements() {
    //     // Explicitly refresh the wired getAnnouncement cache
    //     getAnnouncement()
    //         .then(result => {
    //             this.announcements = result;
    //             console.log('Announcements refreshed: ', result);
    //         })
    //         .catch(error => {
    //             this.error = error;
    //             console.error('Error refreshing announcements: ', error);
    //         });
    // }
}