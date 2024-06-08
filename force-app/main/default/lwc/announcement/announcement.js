import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchNotificationData from '@salesforce/apex/AnnouncementController.fetchNotificationData';
import fetchNotificationCount from '@salesforce/apex/AnnouncementController.fetchNotificationCount';
import updateNotificationData from '@salesforce/apex/AnnouncementController.updateNotificationData';
import deleteNotification from '@salesforce/apex/AnnouncementController.deleteNotification';
import insertNotificationData from '@salesforce/apex/AnnouncementController.insertNotificationData';
import IMAGE1 from "@salesforce/resourceUrl/AltImage";
import My_Image from '@salesforce/resourceUrl/profileimage'

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
    @track clickNewButton = false;

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
    altImages = My_Image;
    totalAnnouncementCount;
    isSaveDisabled = false;
    isTextBoxDisabled = true;

    @track dynamicHeight = 'height: 147px'; // Initial height

    handleFocus() {
        this.dynamicHeight = 'height: 200px'; // Change height when focused
          const style = document.createElement('style');
            style.innerText = `
			        .DetailsofAnnouncementClass div[role="group"]  {
                        height:100%;
                    }
			        .DetailsofAnnouncementClass .slds-form-element__control  {
                        height:100%;
                    }
			        .DetailsofAnnouncementClass .slds-rich-text-editor  {
                        height:100%;
                    }
			        .DetailsofAnnouncementClass .slds-rich-text-editor__textarea {
                        height:100%;
                    }
                    
				  `;
                  
            this.template.querySelector('.overrideStyle').appendChild(style);
    }

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

        //this.expirationDate = null;
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
            .slds-modal__container{
				max-width: 50% !important;
			}
            .newBtncolor button{
                color: rgb(11, 214, 123) !important;
                border: 1px solid;
                width: 97%;
                font-weight: bold;
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
    descriptionInputClass(index) {
        return this.events[index].descriptionError ? 'error-border' : '';
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
                        HasProfile_Photo: (recordData.Profile_Photo !== undefined && recordData.Profile_Photo !== null) ? true : false,
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

    handleExpFocusOut(event){
        const field = event.target.dataset.field;
        console.log('field-FOCUSOUT-->', field);
        let value = event.target.value;
        console.log('value-FOCUSOUT-->', value);
        if (value == '' || value == null || value == undefined){
            this.expirationDate = null;
        }else{
            this.expirationDate = value;
        }
        
        console.log('this.expirationDate-FOCUSOUT>>', this.expirationDate);
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
            else if (this.expirationDate !== null && (this.expirationDate <= this.currentDate)) {
                this.handleValidationErrors('Invalid Date', 'Past date and current date is not allowed, please select future date.', 'error');
                    //this.expirationDate = null;
                    setTimeout(() => {
                        this.isSaveDisabled = false;            
                    }, 800);
                    
                    return;
            }
            else {
                this.isLoadingAfter = true;
                console.log('this.announcement - Save :', this.announcement);
                insertNotificationData({
                    content: this.announcement,
                    expirationDate: this.expirationDate,
                    annonceById: this.recordId,
                    notiType: 'Announcement'
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
        //this.expirationDate = '';
        this.nullContentError = false;
        this.invalidDateError = false;
        this.clickNewButton = false;
    }

    // Edit Data

    handleEditModal(event) {
        console.log(' announceid: ', event.currentTarget.dataset.announceid);
        const announcementId = event.currentTarget.dataset.announceid;
        this.editedAnnounceList = this.announcementList.find(announce => announce.Id === announcementId);
        console.log(' this.editedAnnounceList: ', this.editedAnnounceList);
        this.isEditModalOpen = true;
        this.nullContentError = false;
        this.charRestrictError = false;
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
            this.editedAnnounceList.content__c = newContent;
            console.log('this.editedAnnounceList- Change -->>>', this.editedAnnounceList);
            this.nullContentError = false;
            this.charRestrictError = false;
        }
    }

    handleSaveEdit() {

        try {

            console.log('this.editedAnnounceList.content__c -->>>', this.editedAnnounceList.content__c);
            console.log('this.nullContentError -->>>', this.nullContentError);
            //if(this.editedAnnounceList.content__c == undefined){
            //    this.nullContentError = false;
            //}
            if (this.nullContentError) {
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
    
    handleBlur(event) {
        this.dynamicHeight = 'height: 147px';
        console.log('OUTPUT : this.dynamicHeight');
        let name = event.target.name;
        let index = event.target.dataset.index;
        if (name == 'DetailsofAnnouncement') {
            // this.events[index][name] = event.target.value;
            const fieldName = event.target.name;
            const fieldValue = event.target.value;
            this.events[index][fieldName] = fieldValue;

            if (!fieldValue.trim()) {
                this.events[index].descriptionError = 'Please Enter Task Description.';
            } else {
                this.events[index].descriptionError = '';
            }
            this.events[index][name] = event.target.value;
        }
            
    }

    handleNewClick(event){
        this.clickNewButton = true;
    }

}