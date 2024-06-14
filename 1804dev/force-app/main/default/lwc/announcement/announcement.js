import { LightningElement, track, wire, api } from 'lwc';
import saveAnnouncement from '@salesforce/apex/AnnouncementController.saveAnnouncement';
import { refreshApex } from '@salesforce/apex';
import getAllAnnouncements from '@salesforce/apex/AnnouncementController.getAllAnnouncements';
import updateAnnouncement from '@salesforce/apex/AnnouncementController.updateAnnouncement';
import deleteAnnouncement from '@salesforce/apex/AnnouncementController.deleteAnnouncement';
import fetchImage from '@salesforce/apex/AnnouncementController.fetchImage';

export default class Announcement extends LightningElement {
    @track notifications;
    @track error;
    @track announcement = '';
    @api recordId;
    wiredAnnouncementResult;
    selectedTabLabel;
    isAnnouncementTab= true;
    isPostTab = false;
    isHolidaysTab = false;


    @track isModalOpen = false;
    @track isDeleteModalOpen = false;

    @track editedContent = '';
    @track currentEditingId = '';
    @track currentDeletingId = '';

    openModal(event) {
        let buttonElement = event.target;
        // If the icon or span inside the button was clicked, access the parent button element
        if (!event.target.dataset.id) {
            buttonElement = event.target.closest('button');
        }

        this.currentEditingId = buttonElement.dataset.id;
        console.log('this.currentEditingId  OUTPUT : ',this.currentEditingId);
        this.editedContent = this.notifications.find(notif => notif.Id === this.currentEditingId).Content__c;
        console.log(' this.editedContent this.editedContent OUTPUT : ',this.editedContent);
        this.isModalOpen = true;

        this.fetchAndDisplayImage();
    }


    deleteModal(event) {
        let buttonDeleteElement = event.target;

        // If the icon or span inside the button was clicked, access the parent button element
        if (!event.target.dataset.id) {
            buttonDeleteElement = event.target.closest('button');
        }

        this.currentDeletingId = buttonDeleteElement.dataset.id;

        console.log('this.currentDeletingId  OUTPUT : ',this.currentDeletingId);
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
            console.log('in handle edit save modal : ',this.editedContent);
            // const editedAnnouncement = { Id: this.currentEditingId, Content__c: this.editedContent };
            await updateAnnouncement({ currentEditingId: this.currentEditingId , editedContent : this.editedContent })
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
        this.wiredAnnouncementResult = result; // Storing the response
        if (result.data) {
           this.notifications = result.data.map(notification => ({
                ...notification,
                isEditable: notification.Announced_by__c === this.recordId
            }));
            
            console.log('emp id@@!!@@!!', this.recordId);
            console.log('OUTPUT : ',this.notifications);
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.notifications = undefined;
        }
    }

    async handleSave() {
        try {
            await saveAnnouncement({ announcementContent: this.announcement, empId: this.recordId });
            this.clearAnnouncement();
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
    }

    
    async fetchAndDisplayImage() {
        console.log('fetchAndDisplayImageIn : ');
        const base64Data = await fetchImage({
            fileName: 'Employee Profile Photo',
            EmployeeId: this.recordId
        });
        if (base64Data == '') {
            this.profileImage = My_Image;
            this.isUploading = false; 
            console.log('this.profileImage : ', this.profileImage = My_Image);
        } else {
            this.profileImage = 'data:image/jpeg;base64,' + base64Data;
            this.isUploading = false; 

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
        this.fetchAndDisplayImage();
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