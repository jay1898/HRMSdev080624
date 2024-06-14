import { LightningElement, track, wire, api } from 'lwc';
import saveAnnouncement from '@salesforce/apex/AnnouncementController.saveAnnouncement';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPaginatedAnnouncements from '@salesforce/apex/AnnouncementController.getPaginatedAnnouncements';

import fetchNotificationData from '@salesforce/apex/AnnouncementController.fetchNotificationData';
import updateNotificationData from '@salesforce/apex/AnnouncementController.updateNotificationData';
import deleteNotification from '@salesforce/apex/AnnouncementController.deleteNotification';



export default class Announcement extends LightningElement {
    @track notifications;
    @track announcementList = [];
    @track editedAnnounceList = [];
    @track error;
    @track announcement = '';
    @api recordId;
    wiredAnnouncementResult;
    selectedTabLabel;
    isAnnouncementTab = true;
    isPostTab = false;
    isHolidaysTab = false;


    @track isEditModalOpen = false;
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
    announcementResult;
    isLoading = false;
    minDate = this.getMinDate();
    hideAnnouncement = false;

    nullContentError = false;

    @track isError = false;
    @track errorMessage = '';

    @track pageNumber = 1;
    @track pageSize = 5;


    



    handleModalCancel() {
        this.isEditModalOpen = false;
        this.isDeleteModalOpen = false;
    }



    

    // @wire(getAllAnnouncements)
    // wiredAnnouncements(result) {

    //     function formatDate(dateString) {
    //         const date = new Date(dateString);
    //         const day = date.getDate();
    //         const month = date.getMonth() + 1;
    //         const year = date.getFullYear();

    //         // Pad single digits with leading zero
    //         const formattedDay = String(day).padStart(2, '0');
    //         const formattedMonth = String(month).padStart(2, '0');

    //         return `${formattedDay} ${formattedMonth} ${year}`;
    //     }


    //     this.wiredAnnouncementResult = result; // Storing the response
    //     if (result.data) {

    //         this.notifications = result.data.map(notification => ({
    //             ...notification,
    //             isEditable: notification.Announced_by__c === this.recordId,
    //              CreatedDateFormatted: formatDate(notification.CreatedDate)
    //         }));

    //         console.log('emp id@@!!@@!!', this.recordId);
    //         console.log('OUTPUT : ', this.notifications);
    //         this.tempdp = this.notifications;
    //         let profileUrl;
    //         // Fetch and display image for each notification
    //         this.notifications.forEach(notification => {
    //             if (notification.Announced_by__c) {
    //                 this.fetchAndDisplayImage(notification.Announced_by__c);
    //                 // console.log('notification.Announced_by__c::>>',notification.Announced_by__c);
    //                 // fetchImage({ fileName: 'Employee Profile Photo', EmployeeId: notification.Announced_by__c })
    //                 //     .then(result => {
    //                 //         this.profileImage = 'data:image/jpeg;base64,'+result;
    //                 //     })
    //                 //     .catch(error => {
    //                 //         console.error('Error fetching image:', error);
    //                 // });
    //                 // console.log('this.profileImage::>>', this.profileImage);
    //             }
    //             else {
    //                 this.profileImage = '';
    //             }
    //             this.announcementList.push({ ...notification, "profile": this.profileImage });
    //         });


    //         console.log('announcementList::>>', JSON.parse(JSON.stringify(this.announcementList)));

    //         this.error = undefined;
    //     } else if (result.error) {
    //         this.error = result.error;
    //         this.notifications = undefined;
    //     }
    // }
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
                if(this.isError){
                    console.log('Err0');
                    this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter Announcement.',
                    variant: 'error'
                }));
                return;
                }
            if (this.editedAnnounceList.Content__c == null || this.editedAnnounceList.Content__c == undefined || this.editedAnnounceList.Content__c === '') {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter Announcement.',
                    variant: 'error'
                }));
                return;
            }
            //  if(this.editedAnnounceList('Content__c')){
                 
            //     // console.log('!this.editedAnnounceList.(Content__c) >>',this.editedAnnounceList.Content__c === 'undefined' || this.editedEmpData.Content__c === undefined);
            //     if( this.editedAnnounceList.Content__c === 'undefined' || this.editedAnnounceList.Content__c === undefined){
            //         console.log('Err1');
            //         this.handleValidationErrors('Error', 'Input is required for saving the record.' , 'error');
            //         return;
            //     }
            
            // }
            // else{
            //     console.log('Err1 Else');
            //         this.handleValidationErrors('Error', 'Input is required for saving the record.' , 'error');
            //         return;
            // }
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
            this.isLoading = true;
            await saveAnnouncement({ announcementContent: this.announcement, empId: this.recordId, expirationDate: this.expirationDate });
            this.clearAnnouncement();
            this.expirationDate = '';
            this.dateValue = '';
            this.fetchAnnouncementDetails();
            this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: 'Announcement created successfully.', 
                        variant : 'success'         
                    }));

            console.log('this.announcementResult this.announcementResult in save : ', this.announcementResult);
            // await refreshApex(this.announcementResult);
            // this.refreshAnnouncements(); // Refreshing the announcements after saving
        } catch (error) {
            this.error = error;
            console.error('Error saving announcement: ', error);
        }
    }


    handleChangeEvent(event) {
        this.announcement = event.target.value;
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
    // async fetchAndDisplayImage(announcedById) {
    //     console.log('fetchAndDisplayImageIn : ', announcedById);
    //     const base64Data = await fetchImage({
    //         fileName: 'Employee Profile Photo',
    //         EmployeeId: announcedById
    //     });

    //     if (base64Data === '') {
    //         this.profileImage = My_Image;
    //         this.isUploading = false;
    //         return null; // Return null or any other value to indicate no image found
    //     } else {
    //         this.profileImage = 'data:image/jpeg;base64,' + base64Data;
    //         this.isUploading = false;
    //         let profileUrl = 'data:image/jpeg;base64,' + base64Data;
    //         return profileUrl;
    //     }
    // }



    // Refresh data function
    // refreshData() {
    //     console.log('inside refresh data method');
    //     console.log('this.announcementResult inside refresh: ', this.announcementResult);
    //     if (this.announcementResult) {
    //         refreshApex(this.announcementResult);
    //     }
    //     // refreshApex(this.notifications);
    //     // console.log('announcement @@!!@', this.notifications);
    //     // getAllAnnouncements()
    //     //     .then(result => {
    //     //         console.log('refresh data result',result);
    //     //         this.notifications = result;
    //     //         this.error = undefined;
    //     //     })
    //     //     .catch(error => {
    //     //         this.error = error;
    //     //         this.notifications = undefined;
    //     //     });
    //     console.log('last line refresh data method');

    // }

    //===========================================================================================================
    //===========================================================================================================
    //===========================================================================================================

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
        this.fetchAnnouncementDetails();

    }
    get isActive() {
        return this.tabs.find(tab => tab.isActive);
    }

    fetchAnnouncementDetails() {
        this.isLoading = true;
        fetchNotificationData({ recordType: 'Announcement', pageNumber: this.pageNumber, pageSize: this.pageSize  })
            .then(result => {
                console.log('result:', result);
                this.announcementResult = result;
                let hasMoreRecords = result.length === this.pageSize;
                if (hasMoreRecords) {
                // If there are more records, display the "Load More" button
                this.hasMoreRecords = true;
                } else {
                // If no more records, hide the "Load More" button
                this.hasMoreRecords = false;
                }
                // console.log('result.data:', result.data);
                this.announcementList = result.map(recordData => ({
                    ...recordData,
                    isEditable: recordData.Announced_by__c === this.recordId
                }));
                 this.isLoading = false;

                console.log('this.announcementList-->>', JSON.parse(JSON.stringify(this.announcementList)));
            })
            .catch(error => {
                this.error = error;
                console.error('Error in fetching record data:', error);
            });
       
    }
    loadMoreRecords() {
    // Increment the page number before fetching more records
    this.pageNumber++;
    // Call the method to fetch records
    this.fetchAnnouncementDetails();
    }

    handleEditModal(event) {
        this.editedAnnounceList = [];
        const announcementId = event.currentTarget.dataset.announceid;
        this.editedAnnounceList.push(this.announcementList.find(announcement => announcement.Id === announcementId));
        this.isEditModalOpen = true;
    }

    handleContentChange(event) {
        this.nullContentError = false;
        const newContent = event.target.value.trim();
        
        console.log('newContent-->>>', newContent);
        if (newContent == null || newContent === '') {
            this.nullContentError = true;
        } else {
            if (this.editedAnnounceList.length > 0) {
                this.editedAnnounceList[0].Content__c = newContent;
            }
            console.log('this.editedAnnounceList- Change -->>>', this.editedAnnounceList);
        }
    }

    handleCreateEvent(event) {
        this.isError= false;
        this.errorMessage = '';
        const field = event.target.dataset.field;
        let value = event.target.value.trim();
        this.editedAnnounceList[field] = event.target.value;
        let fieldValue = event.target.value;

        if (field == "Content__c") {
            if (value == null || value === '') {
                this.nullContentError = true;
            } else {
                this.announcement = value;
            }
        }
        console.log('field-->>', field);
        console.log('fieldValue-->>', fieldValue);
        
        if(field == "Content__c"){
            let content = fieldValue.replace(/<[^>]*>/g, '');
             console.log('content-->>', content);
            if(!content.trim()){ 
                
                // console.log('ONLY WHIYE PACE');
            }
            if(content.length > 360 ){
                this.isError= true;
                this.errorMessage = 'Please limit your input to 360 characters.';
                this.handleValidationErrors('Warning', this.errorMessage, 'warning');
            }
          else  if(!content || !content.replace(/<[^>]*>/g, '').trim() || content.replace(/<[^>]*>/g, '') === ''){
                this.isError= true;
                this.errorMessage = 'Input is required for saving the record.';
                this.handleValidationErrors('Error', this.errorMessage, 'error');
            }
        }
        if (field == "Expiration_Date__c") {
            if (Date(value) < this.todayDate) {
                this.expirationDate = null;
                // Optionally display an error message to the user
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Invalid Date',
                    message: 'Please select a future date.',
                    variant: 'error'
                }));
                return;
            } else {
                this.expirationDate = value;
            }
        }
        

    }

    handleSaveEdit() {
        try {
            
            if(!this.editedAnnounceList.Content__c || !this.editedAnnounceList.Content__c.replace(/<[^>]*>/g, '').trim() || this.editedAnnounceList.Content__c.replace(/<[^>]*>/g, '') === ''){
                this.isError= true;
                    // this.errorMessage = 'Input is required for saving the record.';
                    // this.handleValidationErrors('Error', this.errorMessage, 'error');
            }
              if(this.isError){
                console.log('Err0');
                this.dispatchEvent(new ShowToastEvent({
                            title: 'Error',
                            message: 'Input is required for saving the record', 
                            variant : 'error'         
                        }));
                return;
            }
            console.log('this.this.editedAnnounceList:', this.editedAnnounceList);

            console.log('this.nullContentError:', this.nullContentError);
            if (this.nullContentError) {
                this.dispatchEvent(new ShowToastEvent({
                            title: 'Error!',
                            message: 'Content is Required', 
                            variant : 'error'         
                        }));
            }
            else {
                console.log('this.nullContentError:', this.nullContentError);
                console.log('this.editedAnnounceList - Save :', this.editedAnnounceList);
                updateNotificationData({ notificationData: this.editedAnnounceList })
                    .then(result => {
                        console.log('Result', result);
                        this.editedAnnounceList = [];
                        this.fetchAnnouncementDetails();
                        this.nullContentError = false;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success!',
                            message: 'Announcement edited successfully.', 
                            variant : 'success'         
                        }));
                        this.isEditModalOpen = false;
                        //Sucess Msg  -- this.handleValidationErrors('Success', 'Employee Details are Updated.', 'success');
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
        this.editedAnnounceList = [];
        this.currentDeletingId = null;
    }

    deleteModal(event) {
        this.currentDeletingId = event.currentTarget.dataset.announceid;
        console.log('this.currentDeletingId  OUTPUT : ', this.currentDeletingId);
        this.isDeleteModalOpen = true;
    }

    handleDelete() {
        try {
            this.isLoading = true;
            console.log('this.currentDeletingId : ', this.currentDeletingId);
            deleteNotification({ currentDeletingId: this.currentDeletingId })
                .then(result => {
                    console.log('Result', result);
                    this.isLoading = false;
                    
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: 'Announcement deleted successfully.', 
                        variant : 'success'         
                    }));
                    this.fetchAnnouncementDetails();
                    this.isDeleteModalOpen = false;

                })
                .catch(error => {
                    console.error('Error:', error);
                });
                
        } catch (error) {
            this.error = error;
            console.error('Error updating announcement: ', error);
        }
    }

    handleValidationErrors(title,errorMessage,variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: errorMessage,
                variant: variant,
            })
        );
    }

}