import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchNotificationData from '@salesforce/apex/AnnouncementController.fetchNotificationData';
import fetchNotificationPostCount from '@salesforce/apex/AnnouncementController.fetchNotificationPostCount';
import updateNotificationData from '@salesforce/apex/AnnouncementController.updateNotificationData';
import deleteNotification from '@salesforce/apex/AnnouncementController.deleteNotification';
import insertNotificationData from '@salesforce/apex/AnnouncementController.insertNotificationData';
import createPostFiles from '@salesforce/apex/AnnouncementController.createPostFiles';
import deletePostImage from '@salesforce/apex/AnnouncementController.deletePostImage';
import checkFileSize from '@salesforce/apex/AnnouncementController.checkFileSize';
import IMAGE1 from "@salesforce/resourceUrl/AltImage";
import My_Image from '@salesforce/resourceUrl/profileimage'

export default class EmployeePostCreateCmp extends LightningElement {


    postDataList = [];
    showSpinner = false;

    editedPostList;
    editedPostPics = [];
    isEditModalOpen = false;
    isDeleteModalOpen = false;
    isFileUploadOpen = false;
    deletePostId;
    @api postRecordId;
    nullContentError = false;
    invalidDateError = false;
    editedPostId;

    newPost;
    expirationDate =  null;
    selectedFiles = [];
    selectedFileCounts = 0;
    @track displayfiles = [];
    acceptedFormats = ['.jpg', '.png', '.jpeg'];
    MAX_FILE_SIZE_BYTES = 2 * 1024 * 1024; // 2 MB in bytes
    MAX_TOTAL_SIZE_BYTES = 20 * 1024 * 1024; // 20 MB in bytes
    MAX_FILE_COUNT = 10;
    MAX_TOTAL_SIZE_MB = 21;
    MAX_FILE_SIZE_MB = 2.1;

    fileSizeError = null;
    fileCountError = null;
    currentDate;
    isLoading = true;
    isLoadingAfter = false;
    altImages = My_Image;
    fileUploadAction = 'Create';
    noContentAvail = false;
    contentAvailable = true;
    totalPostCount;
    @track pageSize = 5;
    fileRemovalMessage = false;
    isNewBtnEnabled = true;


    connectedCallback() {
        //this.showSpinner = true;
        this.expirationDate = null;
        this.getCurrentDateString();
        this.fetchPostDetails();
        setTimeout(() => {

            // .createContent .slds-rich-text-area__content{
            //     background: #F1F1F1 !important;
            //         border-radius: 0px 0px 15px 15px !important;
            //         border: 0 !important;
            // }
            // .createContent .slds-rich-text-editor__toolbar {
            //    border-radius: 15px 15px 0px 0px !important;
            //    border: 0 !important;
            // }
            const style = document.createElement('style');
            style.innerText = `
			.createContent .slds-rich-text-area__content{
                background: #F1F1F1 !important;
            }
			.slds-spinner .slds-spinner__dot-b:after,.slds-spinner .slds-spinner__dot-b:before,.slds-spinner .slds-spinner__dot-a:after,.slds-spinner .slds-spinner__dot-a:before,.slds-spinner_large.slds-spinner:after,.slds-spinner_large.slds-spinner:before{
              background-color: #37a000 !important;
            }
            .postPics img{
  border-radius: 10%;
  box-sizing: border-box; 
  padding: 5px;
    height: 100% !important;
}
            
				  `;
            this.template.querySelector('.overrideStyle').appendChild(style);
        }, 100);

        fetchNotificationPostCount()
        .then(result => {
            this.totalPostCount = result;
        })
        .catch(error => {
            this.error = error;
            console.error('Error in fetching record data:', error);
        });
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


    showToastMsg(title, errorMessage, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: errorMessage,
                variant: variant,
            })
        );
    }

    // Fetch Data 

    fetchPostDetails() {
        this.noContentAvail = false;
        this.isLoadingAfter = true;
        fetchNotificationData({ recordType: 'Post', limits: this.pageSize })
            .then(result => {
                if (result) {
                    this.postDataList = result.map(recordData => ({
                        ...recordData,
                        Profile_Photo: recordData.Profile_Photo ? recordData.Profile_Photo : this.altImages,
                        HasProfile_Photo: (recordData.Profile_Photo !== undefined && recordData.Profile_Photo !== null) ? true : false,
                        isEditable: recordData.Announced_by__c === this.postRecordId
                    }));
                    this.isLoadingAfter = false;
                    this.isLoading = false;
                    if(this.pageSize >= this.totalPostCount){
                        this.contentAvailable = false;
                    }
                } else {
                    
                    this.contentAvailable = false;
                    this.isLoadingAfter = false;
                    this.isLoading = false;
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
        this.fetchPostDetails(this.pageSize);
    }

    // Edit Data

    handleEditModal(event) {
        this.nullContentError = false;
        this.editedPostId = event.currentTarget.dataset.postid;
        this.editedPostList = this.postDataList.find(post => post.Id === this.editedPostId);
        this.editedPostPics = this.editedPostList.Post_Pics;
        this.isEditModalOpen = true;
        this.selectedFiles = [];
        this.displayfiles = [];
        
    }

    handleContentChange(event) {
        this.nullContentError = false;
        const newContent = event.target.value.trim();
        if (newContent.replace(/<[^>]*>/g, '').trim() == null || newContent.replace(/<[^>]*>/g, '').trim() == '') {
            this.nullContentError = true;
        } else {
            this.editedPostList.content__c = newContent;
            this.nullContentError = false;
        }
    }

    handleSaveEdit() {
        try {
            if (this.nullContentError) {
                this.showToastMsg('Required', 'Blank Content not allowed!', 'error');
                return;
            }
            else if (this.fileSizeError != null || this.fileCountError != null) {
                this.showToastMsg('Error', 'Each file size must be under 2 MB or only upload up to 10 files.', 'error');
                return;
            }
            else {
                this.isLoadingAfter = true;
                let newData = JSON.parse(JSON.stringify(this.editedPostList));
                let editedPostId = this.editedPostList.Id;
                if (newData.hasOwnProperty('Profile_Photo')) {
                    delete newData.Profile_Photo;
                }
                if (newData.hasOwnProperty('Post_Pics')) {
                    delete newData.Post_Pics;
                }

                let editedPost = [];
                editedPost.push(newData);
                updateNotificationData({
                    notificationData: editedPost,
                    notiType: 'Post'
                    //filedata: JSON.stringify(this.selectedFiles)
                })
                    .then(result => {
                        if(this.selectedFiles != null){
                            this.handleInsertFiles(this.selectedFiles,editedPostId);
                        }
                        this.showToastMsg('Success', 'Post is edited successfully.', 'success');
                        setTimeout(() => {
                            this.fetchPostDetails();
                           // this.isLoading = false;
                            //this.isLoadingAfter = false;
                        }, 20000);
                        //this.isLoading = false;
                        //this.isLoadingAfter = false;
                        //this.fetchPostDetails();
                        
                        this.handleCancel();
                    })
                    .catch(error => {
                        console.error('Error:', error);
                    });
            }
            setTimeout(() => {this.fetchPostDetails();}, 5000);

        } catch (error) {
            this.error = error;
            console.error('Error updating post: ', error);
        }
    }

    handleCancel() {
        this.fetchPostDetails();
        this.editedPostList = null;
        this.deletePostId = null;
        this.selectedFiles = [];
        this.displayfiles = [];
        this.nullContentError = false;
        this.isEditModalOpen = false;
        this.isDeleteModalOpen = false;
        this.isFileUploadOpen = false;
        this.selectedFileCounts = 0;
        
    }

    // Delete Data 

    handleDeleteModal(event) {
        this.deletePostId = event.currentTarget.dataset.postid;
        this.isDeleteModalOpen = true;
    }


    handleDelete() {
        this.isLoadingAfter = true;
        deleteNotification({ currentDeletingId: this.deletePostId })
            .then(result => {
                this.deletePostId = null;
                this.showToastMsg('Success', 'Post is Deleted succefully', 'success');
                this.fetchPostDetails();
                this.isLoadingAfter = false;
                this.isLoading = false;
                this.isDeleteModalOpen = false;
                
            })
            .catch(error => {
                console.error('Error:', error);
            });

    }

    // Create Data

    handleCreateEvent(event) {
        const field = event.target.dataset.field;
        let value = event.currentTarget.value.trim();

        if (field == "Content__c") {
            let contentValue = value.replace(/<[^>]*>/g, '').trim();
            if (contentValue == null || contentValue == '') {
                this.nullContentError = true;
            } else {
                this.newPost = value;
                this.nullContentError = false;
            }
        }
        if (field == "Expiration_Date__c") {
            
            //if (value <= this.currentDate) {
            //    this.invalidDateError = true;
            //}else {
            this.expirationDate = value;
            console.log('this.expirationDate>>', this.expirationDate);
            //    this.invalidDateError = false;
            //}
            
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
        this.isNewBtnEnabled = false;
        try {
            console.log('this.isNewBtnEnabled-SAVE-->>',this.isNewBtnEnabled);
            console.log('this.expirationDate-SAVE-->>',this.expirationDate);
            console.log('this.currentDate-SAVE-->>',this.currentDate);
            console.log('(this.expirationDate < this.currentDate-SAVE-->>',this.expirationDate < this.currentDate);
            console.log('this.expirationDate !== null-SAVE-->>',this.expirationDate !== null);
            console.log('this.expirationDate !== null && (this.expirationDate < this.currentDate)-SAVE-->>',this.expirationDate !== null && (this.expirationDate < this.currentDate));
            if (this.nullContentError || (this.newPost == null || this.newPost == undefined || this.newPost == '')) {
                this.showToastMsg('Required', 'Blank Content not allowed!', 'error');
                this.isNewBtnEnabled = true;
                return;
            }
            else if (this.fileSizeError != null || this.fileCountError != null) {
                this.showToastMsg('Error', 'Each file size must be under 2 MB or only upload up to 10 files.', 'error');
                this.isNewBtnEnabled = true;
                return;
            }
            else if (this.expirationDate !== null && (this.expirationDate <= this.currentDate)) {
                this.showToastMsg('Invalid Date', 'Past date and current date is not allowed, please select future date.', 'error');
                    //this.expirationDate = null;
                    setTimeout(() => {
                        this.isNewBtnEnabled = true;            
                    }, 800);
                    
                    return;
            }
            else {
                
                this.isLoadingAfter = true;
                insertNotificationData({
                    content: this.newPost,
                    expirationDate: this.expirationDate,
                    annonceById: this.postRecordId,
                    notiType: 'Post'
                })
                    .then(result => {
                        const insertedPostId = result;
                        if(insertedPostId){
                            this.handleInsertFiles(this.selectedFiles,insertedPostId);
                            setTimeout(() => {
                                this.fetchPostDetails();
                                this.isLoadingAfter = false;
                                this.isLoading = false;
                                this.expirationDate = null;
                            }, 5000);
                            this.clearDetails();
                            this.isNewBtnEnabled = true;
                            this.showToastMsg('Success', 'Post is created successfully.', 'success');
                        }
                        
                    })
                    .catch(error => {
                        console.error('Error while saving notification:', error);
                    });


            }

        } catch (error) {
            this.error = error;
            console.error('Error updating post: ', error);
        }
    }

    // handleInsertFiles(selectedFiles,insertedPostId){
    //     const errorFiles = [];
    //     selectedFiles.forEach(file => {
    //         console.log('JSON.stringify(file)', JSON.stringify(file));
    //         createPostFiles({ fileData: JSON.stringify(file), recordId: insertedPostId })
    //         .then(() => {
    //             console.log('File inserted successfully');
    //         })
    //         .catch(error => {
    //             console.log('JSON.stringify(file)-ERROR', file);
    //             errorFiles.push(file);
    //             console.error('Error inserting file:', error);
    //         });
    //     });
    //     console.log('errorFiles.length', errorFiles.length);
    //     if(errorFiles.length !== 0){
    //         console.log('errorFiles', errorFiles);
    //         this.handleInsertFiles(errorFiles,insertedPostId)
    //     }
    // }

    async handleInsertFiles(selectedFiles, insertedPostId) {
        const errorFiles = [];
        const promises = selectedFiles.map(file => {
            console.log('JSON.stringify(file)', JSON.stringify(file));
            return createPostFiles({ fileData: JSON.stringify(file), recordId: insertedPostId })
                .then(() => {
                    console.log('File inserted successfully');
                })
                .catch(error => {
                    console.log('JSON.stringify(file)-ERROR', file);
                    errorFiles.push(file);
                    console.error('Error inserting file:', error);
                });
        });

        await Promise.all(promises);

        console.log('errorFiles.length', errorFiles.length);
        if (errorFiles.length !== 0) {
            console.log('errorFiles', errorFiles);
            await this.handleInsertFiles(errorFiles, insertedPostId); // Call recursively with failed files
            
        }
        
    }

    clearDetails() {
        console.log('this.newPost', this.newPost);
        console.log('this.expirationDate', this.expirationDate);
        this.newPost = null;
        //this.expirationDate = null;
        this.fileSizeError = null;
        this.fileCountError = null;
        this.selectedFiles = [];
        this.displayfiles = [];
        this.newPost = '';
        this.expirationDate = null;
        //this.expirationDate = undefined;
        this.nullContentError = false;
        this.invalidDateError = false;
        this.selectedFileCounts = 0;
    }

    // File Data

    clickFileUpload(event) {
        const actionName = event.target.dataset.actionName;
        this.fileUploadAction = actionName;
        this.selectedFiles = [];
        //this.displayfiles = [];
        this.isFileUploadOpen = true;

    }


    calculateTotalSizeInMB() {
        // Calculate the total size of files already selected in MB
        let totalSize = 0;
        const fileInputs = this.template.querySelectorAll('input[type="file"]');
        fileInputs.forEach(fileInput => {
            totalSize += Array.from(fileInput.files).reduce((acc, file) => acc + file.size, 0);
        });
        return totalSize / (1024 * 1024); // Convert total size to MB
    }

    calculateTotalFileCount() {
        // Calculate the total number of files already selected
        let totalCount = 0;
        const fileInputs = this.template.querySelectorAll('input[type="file"]');
        fileInputs.forEach(fileInput => {
            totalCount += fileInput.files.length;
        });
        return totalCount;
    }

    handleFileChange(event) {
        this.fileSizeError = null;
        this.fileCountError = null;
         console.log('handleFileChange CALL-->>',);
        const files = event.target.files;
        let totalSize = 0;
        let selectFiles = [];
        const validExtensionsList = ['.png', '.jpeg', '.jpg'];
        // Calculate total size of selected files
        for (let i = 0; i < files.length; i++) {
            totalSize += files[i].size;
            selectFiles.push(files[i]);
            if (files[i].size > this.MAX_FILE_SIZE_MB * 1024 * 1024) {
                //this.fileSizeError = `File "${files[i].name}" exceeds the maximum size limit of ${this.MAX_FILE_SIZE_MB} MB.`;
                this.fileSizeError = `File "${files[i].name}" exceeds the maximum size limit of 2 MB.`;
                this.showToastMsg('Error', this.fileSizeError, 'error');
                event.target.value = '';
                return;
            }
            let validExtension = false;
            for (let j = 0; j < validExtensionsList.length; j++) {
                if (files[i].name.toLowerCase().endsWith(validExtensionsList[j])) {
                    validExtension = true;
                    break;
                }
            }
            if (!validExtension) {
                this.fileSizeError = `File "${files[i].name}" has an invalid extension. Only .png and .jpeg files are allowed.`;
                this.showToastMsg('Error', this.fileSizeError, 'error');
                event.target.value = '';
                return;
            }
        }

        // Calculate total size and number of already selected files
        const totalSizeInMB = totalSize / (1024 * 1024); 
        const currentTotalSizeInMB = this.calculateTotalSizeInMB() + totalSizeInMB;
        const currentTotalFileCount = this.calculateTotalFileCount() + selectFiles.length;
        let editActionFileCount = 0;
        if(this.editedPostPics == undefined){
            editActionFileCount = this.displayfiles.length + currentTotalFileCount;
        }else{
            editActionFileCount = this.editedPostPics.length + this.displayfiles.length + currentTotalFileCount;
        }
        
        if (this.fileUploadAction == 'Create' && ((this.displayfiles.length + currentTotalFileCount) > this.MAX_FILE_COUNT)) {
            // If more than 10 files are selected, display an error message
            this.fileCountError = `You can only upload up to ${this.MAX_FILE_COUNT} files.`;
            this.showToastMsg('Error', this.fileCountError, 'error');
            event.target.value = '';
            return;
        }
        else if(this.fileUploadAction == 'Edit' && editActionFileCount > this.MAX_FILE_COUNT) {
            // If more than 10 files are selected, display an error message
            this.fileCountError = `You can only upload up to ${this.MAX_FILE_COUNT} files.`;
            this.showToastMsg('Error', this.fileCountError, 'error');
            event.target.value = '';
            return;
        } 
        else if (currentTotalSizeInMB > this.MAX_TOTAL_SIZE_MB) {
            // If the total size exceeds the limit, display an error message
            //this.fileSizeError = `Total file size exceeds the limit of ${this.MAX_TOTAL_SIZE_MB} MB.`;
            this.fileSizeError = `Total file size exceeds the limit of 20 MB.`;
            this.showToastMsg('Error', this.fileSizeError, 'error');
            event.target.value = '';
            return; 
        } else {
            // If the total size and file count are within limits, handle the files
            for (let i = 0; i < selectFiles.length; i++) {
                this.fileCountError = null;
                this.fileSizeError = null;

                let file = selectFiles[i];
                let reader = new FileReader();
                // Define onload event handler for FileReader
                reader.onload = e => {
                    let fileContents = reader.result.split(',')[1];
                    const image = {
                        id: 'Post' + i,
                        name: file.name,
                        url: e.target.result,
                        fileContent: fileContents
                    };
                    this.displayfiles.push(image);
                };
                // Read the file content as Data URL (base64-encoded)
                reader.readAsDataURL(file);
            }
        }


    }


    handleRemoveImage(event) {
        const imageToRemove = event.currentTarget.dataset.imageName;
        this.displayfiles = this.displayfiles.filter((image) => image.name !== imageToRemove);
    }

    handleSaveFiles() {
        console.log('this.displayfiles-->>',this.displayfiles);
        const fileHandleEvent = {
            target: {
                files: []
            }
        };
        console.log('fileHandleEvent-->>',fileHandleEvent);
        this.handleFileChange(fileHandleEvent);
         console.log('this.fileCountError-->>',this.fileCountError);
        if (this.fileCountError != null) {
            this.showToastMsg('Error', this.fileCountError, 'error');
            return;
        } else {
            if(this.displayfiles.length === 0){
                this.showToastMsg('Warning', 'You did not select any file.', 'warning');
            }
            this.displayfiles.forEach(file => {
                this.selectedFiles.push({ 'fileContent': file.fileContent });
            });
            if (this.selectedFiles.length > 0) {
                this.selectedFileCounts = this.selectedFiles.length;
            }
            else {
                this.selectedFileCounts = 0;
            }
            this.isFileUploadOpen = false
        }


    }

    handleDeleteImage(event) {
        const imageToRemove = event.currentTarget.dataset.imageId;
        const postId = this.editedPostId;
        deletePostImage({ contentVersionId: imageToRemove, postId: postId })
            .then(result => {
                this.editedPostPics = this.editedPostPics.filter((image) => image !== imageToRemove);
            })
            .catch(error => {
                console.error('Error:', error);
            });
        /*const fileHandleEvent = {
            target: {
                files: this.displayfiles
            }
        };
        this.handleFileChange(fileHandleEvent);*/
    }

    handleFileCancel() {

        //this.editedPostList = null;
        //this.deletePostId = null;
        this.selectedFiles = [];
        this.displayfiles = [];
        this.isFileUploadOpen = false;
    }

    handleUploadFinished(event) {
        let cvIdList = [];

        const uploadedFiles = event.detail.files;
        const uploadedFilesCount = event.detail.files.length;
        if (uploadedFilesCount > this.MAX_FILE_COUNT) {
            // If more than 10 files are selected, display an error message
            this.fileCountError = `You can only upload up to ${this.MAX_FILE_COUNT} files.`;
            this.showToastMsg('Error', this.fileCountError, 'error');
            event.target.value = '';
            return;
        }
        else {
            uploadedFiles.forEach(cv => {
                cvIdList.push(cv.contentVersionId);
            });

            checkFileSize({ cvIdList: cvIdList })
                .then(result => {
                    if (result.length > 0) {
                        this.fileSizeError = `File "${result[0]}" exceeds the maximum size limit of 2 MB.`;
                        this.showToastMsg('Error', this.fileSizeError, 'error');
                        return;
                    }
                    else {
                        this.fileSizeError = null;
                        cvIdList.forEach(cv => {
                            this.displayfiles.push(cv);
                        });
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                });
        }

    }



}