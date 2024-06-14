import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchNotificationData from '@salesforce/apex/AnnouncementController.fetchNotificationData';
import fetchNotificationCount from '@salesforce/apex/AnnouncementController.fetchNotificationCount';
import updateNotificationData from '@salesforce/apex/AnnouncementController.updateNotificationData';
import deleteNotification from '@salesforce/apex/AnnouncementController.deleteNotification';
import insertNotificationData from '@salesforce/apex/AnnouncementController.insertNotificationData';
import IMAGE1 from "@salesforce/resourceUrl/AltImage";

export default class Announcement extends LightningElement {

    @api recordId;

    @track notifications;
    @track announcementList = [];
    @track editedAnnounceList;
    @track error;

    isAnnouncementTab = true;
    isPostTab = false;
    isHolidaysTab = false;

    @track isEditModalOpen = false;
    @track isDeleteModalOpen = false;

    @track editedContent = '';
    @track currentEditingId = '';
    @track currentDeletingId = null;

    @track profileImage;
    @track isUploading = false;

    @track isError = false;
    @track errorMessage = '';

    @track pageSize = 5;

    wiredAnnouncementResult;
    selectedTabLabel;
    currentDate;

    tempdp;
    expirationDate;
    dateValue;
    inputDate;
    todayDate;
    announcementResult;
    isLoading = true;
    isLoadingAfter = false;
    //minDate = this.getMinDate();
    hideAnnouncement = false;
    validContentValue;
    nullContentError = false;
    invalidDateError = false;
    charRestrictError = false;
    noContentAvail = false;
    contentAvailable = true;
    announcement = null;
    altImages = IMAGE1;
    totalAnnouncementCount;
    isSaveDisabled = false;

    //@track pageNumber = 1;

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

        this.selectedTabLabel = 'Announcement';
        this.getCurrentDateString();
        this.fetchAnnouncementDetails();
        setTimeout(() => {

            const style = document.createElement('style');
            style.innerText = `
			.createContent .slds-rich-text-area__content{
                background: #F1F1F1 !important;
            }
			.slds-spinner .slds-spinner__dot-b:after,.slds-spinner .slds-spinner__dot-b:before,.slds-spinner .slds-spinner__dot-a:after,.slds-spinner .slds-spinner__dot-a:before,.slds-spinner_large.slds-spinner:after,.slds-spinner_large.slds-spinner:before,.slds-spinner_medium.slds-spinner:after,.slds-spinner_medium.slds-spinner:before{
              background-color: #37a000 !important;
            }
				  `;
            this.template.querySelector('.overrideStyle').appendChild(style);
        }, 100);

        fetchNotificationCount()
        .then(result => {
            console.log('result count:', result);
            this.totalAnnouncementCount = result;
        })
        .catch(error => {
            this.error = error;
            console.error('Error in fetching record data:', error);
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

    getCurrentDateString() {
        const today = new Date();

        const formatDate = (date) => {
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            return `${year}-${month}-${day}`;
        };

        this.currentDate = formatDate(today);
    }


    // Get Data

    fetchAnnouncementDetails() {
        this.noContentAvail = false;
        this.isLoadingAfter = true;

        fetchNotificationData({ recordType: 'Announcement', limits: this.pageSize })
            .then(result => {
                console.log('result:', result);
                if (result) {
                    this.announcementList = result.map(recordData => ({
                        ...recordData,
                        Profile_Photo: recordData.Profile_Photo ? recordData.Profile_Photo : this.altImages,
                        isEditable: recordData.Announced_by__c === this.recordId
                    }));
                    this.isLoadingAfter = false;
                    this.isLoading = false;
                    console.log('this.announcementList-->>', JSON.parse(JSON.stringify(this.announcementList)));
                    
                    if(this.pageSize >= this.totalAnnouncementCount){
                        this.contentAvailable = false;
                    }
                } else {
                    this.contentAvailable = false;
                    this.isLoadingAfter = false;
                    this.isLoading = false;
                    console.log('no content not coming');
                    this.noContentAvail = true;
                }

            })
            .catch(error => {
                this.error = error;
                console.error('Error in fetching record data:', error);
            });

    }

    loadMoreRecords() {
        this.pageSize += 5;
        this.fetchAnnouncementDetails(this.pageSize);
    }



    // Create Data 

    handleCreateEvent(event) {
        const field = event.target.dataset.field;
        let value = event.currentTarget.value.trim();
        console.log('value :', value);

        if (field == "Content__c") {
            let contentValue = value.replace(/<[^>]*>/g, '').trim();
            console.log('contentValue :', contentValue);
            if (contentValue == null || contentValue == '') {
                this.nullContentError = true;
            } else {
                this.announcement = value;
                this.nullContentError = false;
                console.log('this.announcement :', this.announcement);
            }
        }
        if (field == "Expiration_Date__c") {
            if (value <= this.currentDate) {
                this.invalidDateError = true;
            } else {
                this.expirationDate = value;
                this.invalidDateError = false;
            }
        }

    }

    handleSave() {
        this.isSaveDisabled = true;
        try {
            console.log('this.announcement :', this.announcement);
            if (this.nullContentError || (this.announcement == null || this.announcement == undefined || this.announcement == '')) {
                this.handleValidationErrors('Required', 'Blank Content not allowed!', 'error');
                return;
            }
            else if (this.announcement.replace(/<[^>]*>/g, '').trim().length > 360) {
                this.handleValidationErrors('Invalid Content', 'Please restrict your input to a maximum of 360 characters.', 'error');
                return;
            }
            else if (this.invalidDateError) {
                this.handleValidationErrors('Invalid Date', 'Past date and current date is not allowed, please select future date.', 'error');
                this.expirationDate = null;
                return;
            }
            else {
                this.isLoadingAfter = true;
                console.log('this.announcement - Save :', this.announcement);
                insertNotificationData({
                    content: this.announcement,
                    expirationDate: this.expirationDate,
                    annonceById: this.recordId,
                    notiType: 'Announcement',
                    filedata: null
                })
                    .then(result => {
                        console.log('Result', result);
                        this.isLoadingAfter = false;
                        this.isLoading = false;
                        this.clearDetails();
                        this.fetchAnnouncementDetails();
                        this.handleValidationErrors('Success', 'Announcement is created successfully.', 'success');
                    })
                    .catch(error => {
                        console.error('Error while saving notification:', error);
                        this.isSaveDisabled = false;
                    });
            }
        } catch (error) {
            this.error = error;
            console.error('Error saving announcement: ', error);
            this.isSaveDisabled = false;
        }
    }

    clearDetails() {
        this.announcement = null;
        this.expirationDate = null;
        this.announcement = '';
        this.expirationDate = '';
        this.nullContentError = false;
        this.invalidDateError = false;
    }

    // Edit Data

    handleEditModal(event) {
        console.log(' announceid: ', event.currentTarget.dataset.announceid);
        const announcementId = event.currentTarget.dataset.announceid;
        this.editedAnnounceList = this.announcementList.find(announce => announce.Id === announcementId);
        console.log(' this.editedAnnounceList: ', this.editedAnnounceList);
        this.isEditModalOpen = true;
    }

    handleContentChange(event) {
        this.nullContentError = false;
        this.charRestrictError = false;
        const newContent = event.target.value.trim();

        console.log('newContent-->>>', newContent);
        if (newContent.replace(/<[^>]*>/g, '').trim() == null || newContent.replace(/<[^>]*>/g, '').trim() == '') {
            this.nullContentError = true;
        }
        else if (newContent.replace(/<[^>]*>/g, '').trim().length > 360) {
            this.charRestrictError = true;
        }
        else {
            //this.editedAnnounceList.Content__c = event.target.value;
            this.editedAnnounceList.Content__c = newContent;
            console.log('this.editedAnnounceList- Change -->>>', this.editedAnnounceList);
            this.nullContentError = false;
            this.charRestrictError = false;
        }
    }

    handleSaveEdit() {

        try {
            console.log('this.editedAnnounceList.content__c -->>>', this.editedAnnounceList.content__c);
            console.log('this.nullContentError -->>>', this.nullContentError);
            if (this.editedAnnounceList.Content__c =='') {
                this.handleValidationErrors('Required', 'Blank Content not allowed!', 'error');
                return;
            } else if (this.charRestrictError) {
                this.handleValidationErrors('Invalid Content', 'Please restrict your input to a maximum of 360 characters.', 'error');
                return;
            }
            else {
                this.isLoadingAfter = true;
                console.log('this.nullContentError:', this.nullContentError);
                console.log('this.editedAnnounceList - Save :', this.editedAnnounceList);

                let newData = JSON.parse(JSON.stringify(this.editedAnnounceList));
                if (newData.hasOwnProperty('Profile_Photo')) {
                    delete newData.Profile_Photo;
                }
                let editedAnnounce = [];
                editedAnnounce.push(newData);
                console.log('this.editedAnnounceList - Save :', editedAnnounce);
                updateNotificationData({ notificationData: editedAnnounce })
                    .then(result => {
                        console.log('Result', result);
                        this.isEditModalOpen = false;
                        this.isLoadingAfter = false;
                        this.isLoading = false;
                        this.fetchAnnouncementDetails();


                        this.handleValidationErrors('Success', 'Announcement is edited successfully.', 'success');
                        this.handleCancel();
                    })
                    .catch(error => {
                        console.error('Error:', error);
                    });


            }

        } catch (error) {
            this.error = error;
            console.error('Error updating announcement: ', error);
        }
    }

    handleCancel() {
        this.isEditModalOpen = false;
        this.isDeleteModalOpen = false;
        this.editedAnnounceList = null;
        this.nullContentError = false;
        this.charRestrictError = false;
        this.isEditModalOpen = false;

        this.currentDeletingId = null;

    }

    // Delete Data

    deleteModal(event) {
        this.currentDeletingId = event.currentTarget.dataset.announceid;
        console.log('this.currentDeletingId  OUTPUT : ', this.currentDeletingId);
        this.isDeleteModalOpen = true;
    }

    handleDelete() {
        try {
            this.isLoadingAfter = true;
            console.log('this.currentDeletingId : ', this.currentDeletingId);
            deleteNotification({ currentDeletingId: this.currentDeletingId })
                .then(result => {
                    console.log('Result', result);
                    this.isDeleteModalOpen = false;
                    this.isLoading = false;

                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: 'Announcement deleted successfully.',
                        variant: 'success'
                    }));


                    this.isLoadingAfter = false;
                    this.fetchAnnouncementDetails();


                })
                .catch(error => {
                    console.error('Error:', error);
                });

        } catch (error) {
            this.error = error;
            console.error('Error updating announcement: ', error);
        }
    }

    // Toast msg

    handleValidationErrors(title, errorMessage, variant) {
        this.isSaveDisabled = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: errorMessage,
                variant: variant,
            })
        );
    }

    get shouldRenderContent() {
    return !this.isLoading && this.contentAvailable && this.announcementList && this.announcementList.length > 0;
}


}