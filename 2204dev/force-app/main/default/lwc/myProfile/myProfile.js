import { LightningElement, track, api, wire } from 'lwc';
import My_Image from '@salesforce/resourceUrl/profileimage'
import verticalLineImage from '@salesforce/resourceUrl/verticalLineImage'
import getEmployeeDetails from '@salesforce/apex/EmployeeController.getEmployeeDetails';
import fetchImage from '@salesforce/apex/EmpUploadDocumentCls.fetchImage';
import uploadDocumentFile from '@salesforce/apex/EmpUploadDocumentCls.uploadEmpDocument';
import uploadFile from '@salesforce/apex/EmpUploadDocumentCls.uploadFile';



export default class MyProfile extends LightningElement {
    //profileImage = My_Image;
    acceptedFormats = ['.png', '.jpg'];
    vLineImage = verticalLineImage;
    empDetails;
    @api recordId;
    @api isActive;
    @track isAboutTab = true;
    @track isProfileTab = false;
    @track isJobTab = false;
    @track isDocumentTab = false;
    @track ProfileFileName;
    @track contentDocumentId = '';
    @track profileImage = '';
    @track contentVersionId = '';
    @track file;
    @track isUploading = false;


    @wire(getEmployeeDetails, { recordId: '$recordId' })
    employeeDetails({ data, error }) {
        if (data && data != null) {
            console.log(JSON.stringify(data));
            this.empDetails = data;
            this.isUploading = true; 
            this.fetchAndDisplayImage();
        }
        else {
            console.error(error);
        }
    }

    @track tabs = [
        { label: 'About', isActive: true },
        { label: 'Profile', isActive: false },
        { label: 'Job', isActive: false },
        { label: 'Document', isActive: false }
    ];

    handleTabClick(event) {
        const selectedTabLabel = event.detail;
        console.log('click- 1 ', selectedTabLabel);
        this.tabs = this.tabs.map(tab => {
            tab.isActive = tab.label === selectedTabLabel;
            return tab;
        });

        if (selectedTabLabel == 'About') {
            console.log('click- About', selectedTabLabel);
            this.isAboutTab = true;
            this.isProfileTab = false;
            this.isJobTab = false;
            this.isDocumentTab = false;
        } else if (selectedTabLabel == 'Profile') {
            console.log('click- Prof', selectedTabLabel);
            this.isAboutTab = false;
            this.isProfileTab = true;
            this.isJobTab = false;
            this.isDocumentTab = false;
        } else if (selectedTabLabel == 'Job') {
            console.log('click- Job', selectedTabLabel);
            this.isAboutTab = false;
            this.isProfileTab = false;
            this.isJobTab = true;
            this.isDocumentTab = false;
        } else if (selectedTabLabel == 'Document') {
            console.log('click- Doc', selectedTabLabel);
            this.isAboutTab = false;
            this.isProfileTab = false;
            this.isJobTab = false;
            this.isDocumentTab = true;
        }


        console.log('click', selectedTabLabel);
    }


    handlePhotoClick() {
        this.template.querySelector('.file-input').click();
    }


    handleFileChange(event) {
        this.file = event.target.files[0];
        console.log('Selected file:', this.file);
        this.uploadFileToServer();
    }


    async uploadFileToServer() {
        this.isUploading = true; 
        if (!this.file) {
            console.error('No file selected.');
            this.isUploading = false; 
            return;
        }

        const reader = new FileReader();
        reader.onloadend = async () => {
            const base64 = reader.result.split(',')[1];
            console.log('base64:', base64);
            console.log('this.file.name', this.file.name);

            try {
                this.contentVersionId = await uploadFile({ base64: base64, filename: this.file.name });
                console.log('ContentVersion ID:', this.contentVersionId);
                this.ProfileFileName = 'Employee Profile Photo';
                this.submitFileToApex();
            } catch (error) {
                console.error('Error uploading file:', error);
            }

        };
        reader.readAsDataURL(this.file);

    }

    submitFileToApex() {
        console.log('@@this.contentDocumentId', this.contentVersionId);
        console.log('@@this.employeeId', this.recordId);
        console.log('@@@this.ProfileFileName', this.ProfileFileName);
        uploadDocumentFile({
            contentDocumentId: this.contentVersionId, 
            EmployeeId: this.recordId,
            FileName: this.ProfileFileName,
            DocumentName: this.ProfileFileName
        })
            .then(result => {
                console.log('Upload Result:', result);
                this.dispatchEvent(new CustomEvent('uploadprofilephoto', {
                    detail: {
                        uploadProfile: true
                    }
                }));
                this.fetchAndDisplayImage();
            })
            .catch(error => {
                console.error('Error in file upload:', error);
                console.error('Error Response:', error.body);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'File upload failed: ' + error.body.message,
                        variant: 'error',
                    })
                );
            });
    }

    async fetchAndDisplayImage() {
        const base64Data = await fetchImage({
            fileName: 'Employee Profile Photo',
            EmployeeId: this.recordId
        });
        if (base64Data == '') {
            this.profileImage = My_Image;
            this.isUploading = false; 
        } else {
            this.profileImage = 'data:image/jpeg;base64,' + base64Data;
            this.isUploading = false; 

        }
    }


    get tabComponent() {
        return this.isActive ? 'activeTab' : '';
    }

}