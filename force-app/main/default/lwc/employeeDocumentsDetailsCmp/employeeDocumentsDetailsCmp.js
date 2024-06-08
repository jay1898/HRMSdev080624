import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchEmployeeData from '@salesforce/apex/EmployeeController.fetchEmployeeDetails';
import updateEmployeeData from '@salesforce/apex/EmployeeController.updateEmployeeDetails';
import uploadDocumentFile from '@salesforce/apex/EmpUploadDocumentCls.uploadEmpDocument';
import fetchImage from '@salesforce/apex/EmpUploadDocumentCls.fetchImage';
import fetchAllImage from '@salesforce/apex/EmpUploadDocumentCls.fetchAllImages';
import getFileSizes from '@salesforce/apex/EmpUploadDocumentCls.getFileSizes';
import deleteFileById from '@salesforce/apex/EmpUploadDocumentCls.deleteFileById';


export default class EmployeeProfilePage extends LightningElement {
    @track EditAadhaarNumber = false;
    @track AddDegreesCertificate = false;
    @track EditPANCardNumber = false;
    @api employeeId;
    @track objectEmployee = 'Employee__c';
    @track employeeData;
    @track editedEmployeeData;
    @track isEditable = false;
    @track showError = false;
    @track errorMessage = '';
    @track isCheck = false;
    @track AadharfileName;
    @track DegreesfileName = '';
    @track PanfileName = '';
    @track imageUrlAadhar = '';
    @track imageUrlDegrees = '';
    @track imageUrlPAN = '';
    @track contentDocumentId = '';
    acceptedFormats = ['.png', '.jpg'];
    @track isIdentityTab = true;
    @track isDegreesTab = false;
    @track degreesName = '';
    isLodingDegree = false;
    @api imageUrlDegrees;
    selectedTabLabel;
    @track isLoading = false;
    @track isPanCard = false;
    @track isAdhaarCard = false;



    tabs = [
        { label: 'Identity', isActive: true },
        { label: 'Degrees', isActive: false },
    ];

    handleTabClick(event) {
        this.selectedTabLabel = event.target.dataset.tab;
        this.tabs.forEach(tab => {
            tab.isActive = tab.label === this.selectedTabLabel;
        });

        if (this.selectedTabLabel === 'Identity') {
            this.isIdentityTab = true;
            this.isDegreesTab = false;
        } else if (this.selectedTabLabel === 'Degrees') {
            this.isIdentityTab = false;
            this.isDegreesTab = true;
            this.isLodingDegree = true;
            this.fetchDegreesImage();

        }
        // Call adjustIndicator to move the indicator to the selected tab
        this.adjustIndicator(event.currentTarget);
    }

    adjustIndicator(tabElement) {
        const indicator = this.template.querySelector('.tab-indicator');
        indicator.style.width = tabElement.offsetWidth + 'px';
        indicator.style.transform = `translateX(${tabElement.offsetLeft}px)`;
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


    connectedCallback() {
        this.selectedTabLabel = 'Identity';
        this.fetchEmployeeDetails();
        console.log('employeeId-->>', this.employeeId);
    }


    handleDownload(event) {
        const imageId = event.target.dataset.id; // Get the id from the button's data-id attribute
        const imageData = this.imageUrlDegrees.find(data => data.id === imageId);

        if (imageData) {
            // Convert base64 to blob
            const byteString = atob(imageData.base64Data.split(',')[1]);
            const mimeString = imageData.base64Data.split(',')[0].split(':')[1].split(';')[0];
            const byteNumbers = new Array(byteString.length);
            for (let i = 0; i < byteString.length; i++) {
                byteNumbers[i] = byteString.charCodeAt(i);
            }
            const byteArray = new Uint8Array(byteNumbers);
            const blob = new Blob([byteArray], { type: mimeString });

            // Create a temporary anchor to trigger download
            let anchor = document.createElement('a');
            anchor.href = URL.createObjectURL(blob);
            anchor.download = imageData.title + '.png'; // Assuming the images are in PNG format
            document.body.appendChild(anchor); // Append to the body
            anchor.click(); // Trigger the download
            document.body.removeChild(anchor); // Remove the anchor from the body
        } else {
            console.error('Image data not found for id:', imageId);
        }
    }


    fetchEmployeeDetails() {
        if (!this.employeeId) {
            return;
        }
        fetchEmployeeData({ employeeId: this.employeeId })
            .then(result => {
                this.employeeData = result[0];
                console.log('this.employeeData-->>', JSON.parse(JSON.stringify(this.employeeData)));
            })
            .catch(error => {
                this.error = error;
                console.error('Error in fetching record data:', error);
            });
    }


    EditAadhaarBtn() {
        this.editedEmployeeData = { ...this.employeeData };
        this.isLoading = true;
        this.fetchAndDisplayImage();
        this.EditAadhaarNumber = true;

    }


    AddCertificate() {
        this.AddDegreesCertificate = true;
    }

    EditPanCardBtn() {
        this.editedEmployeeData = { ...this.employeeData };
        //this.viewPrimary = false;
        this.fetchAndPANDisplayImage();
        this.EditPANCardNumber = true;
    }

    hideAadhaarModal() {
        this.EditAadhaarNumber = false;
    }

    hidePANModal() {
        this.EditPANCardNumber = false;
    }


    hideDegreesModal() {
        this.AddDegreesCertificate = false;
    }

    saveDegreesRecord() {
        if (!this.degreesName) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Degrees Name is required.',
                    variant: 'error',
                })
            );
            return;
        }

        // Proceed with saving the record if Degrees Name is filled
        this.isCheck = false;
        this.fetchAndDisplayImage();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Employee Details are saved.',
                variant: 'success',
            })
        );
        this.AddDegreesCertificate = false;

    }
    
    patternAdhar(event){
        let inputValue = event.target.value.replace(/\D/g, '').substring(0, 11);
        let formattedValue = inputValue.substring(0, 4);
        for (let i = 4; i < inputValue.length; i += 4) {
            formattedValue += '-' + inputValue.substr(i, 4);
        }
        event.target.value = formattedValue;
    }

    handleEmployeeChange(event) {
        const field = event.target.dataset.field;
    this.editedEmployeeData[field] = event.target.value;
    }

    handleUploadFinished(event) {

        console.log('Files uploaded:', event.detail.files);
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles', uploadedFiles);
        uploadedFiles.forEach(file => {
            this.contentDocumentId = file.contentVersionId;
            this.AadharfileName = 'Aadhaar Card Details';
            this.isCheck = true;
            console.log('File name', this.AadharfileName);
            this.GetFileSize(this.contentDocumentId, this.AadharfileName)

        });
    }

    GetFileSize(contentDoctId, uploadfileName) {
        console.log('contentDocumentId:', contentDoctId);
        console.log('uploadfileName:', uploadfileName);

        getFileSizes({ contentVersionIds: contentDoctId })
            .then(result => {
                console.log('result@@@!!@!!', result);
                result.forEach(file => {
                    console.log('File Name:', file.Title);
                    console.log('File Size:', file.ContentSize);
                    console.log('uploadfileName:', uploadfileName);

                    if (file.ContentSize < 1 * 1024 * 1024) {

                        if (uploadfileName === 'Aadhaar Card Details') {
                            console.log('Aadhaa:');
                            this.submitFileToApex();
                        } else if (uploadfileName === 'PAN Card Details') {
                            console.log('PAN:');
                            this.submitPANFileToApex();
                        } else {
                            console.log('deegres:');
                            this.submitDegreesFileToApex();
                        }
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'File size should be less than 1 MB.',
                                variant: 'error',
                            })
                        );
                        this.deleteFile(contentDoctId)
                        //return;
                    }
                });
            })

    }

    deleteFile(contentDoctId) {
        console.log('File deleted contentVersionId:', contentDoctId);

        deleteFileById({ contentVersionId: contentDoctId })
            .then(result => {
                console.log('File deleted successfully:', result);
            })
            .catch(error => {
                console.error('Error deleting file:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error deleting file: ' + error.body.message,
                        variant: 'error',
                    })
                );
            });
    }



    handleUploadPANFinished(event) {
        console.log('Files uploaded:', event.detail.files);
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles', uploadedFiles);
        uploadedFiles.forEach(file => {
            this.contentDocumentId = file.contentVersionId;
            this.PanfileName = 'PAN Card Details';
            this.isCheck = true;
            console.log('contentDocumentId: ' + this.contentDocumentId);
            console.log('File name', this.PanfileName);
            this.GetFileSize(this.contentDocumentId, this.PanfileName)
            //this.submitPANFileToApex();

        });
    }

    submitFileToApex() {
        console.log('@@this.contentDocumentId', this.contentDocumentId);
        console.log('@@this.employeeId', this.employeeId);
        console.log('@@@this.AadharfileName', this.AadharfileName);

        uploadDocumentFile({ contentDocumentId: this.contentDocumentId, EmployeeId: this.employeeId, FileName: this.AadharfileName, DocumentName: this.AadharfileName })
            .then(result => {
                console.log('Upload Result:', result);
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

    submitPANFileToApex() {
        console.log('this.contentDocumentId', this.contentDocumentId);
        console.log('this.employeeId', this.employeeId);

        uploadDocumentFile({ contentDocumentId: this.contentDocumentId, EmployeeId: this.employeeId, FileName: this.PanfileName, DocumentName: this.PanfileName })
            .then(result => {
                console.log('Upload Result:', result);
            })
            .catch(error => {
                console.error('Error in file upload:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'File upload failed: ' + error.body.message,
                        variant: 'error',
                    })
                );
            });
        this.fetchAndPANDisplayImage();

    }

    // Degrees Certificate 

    handleDegreesNameChange(event) {
        this.degreesName = event.target.value.trim();;
    }

    uploadCertificate(event) {
        console.log('Files uploaded:', event.detail.files);
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles', uploadedFiles);
        uploadedFiles.forEach(file => {
            this.contentDocumentId = file.contentVersionId;
            this.DegreesfileName = 'Degrees Certificate'
            this.isCheck = true;
            console.log('contentDocumentId: ' + this.contentDocumentId);
            console.log('File name', this.DegreesfileName);
            this.GetFileSize(this.contentDocumentId, this.DegreesfileName)

            //   this.submitDegreesFileToApex();
        });
    }

    submitDegreesFileToApex() {
        console.log('this.contentDocumentId', this.contentDocumentId);
        console.log('this.employeeId', this.employeeId);

        uploadDocumentFile({ contentDocumentId: this.contentDocumentId, EmployeeId: this.employeeId, FileName: this.degreesName, DocumentName: this.DegreesfileName })
            .then(result => {
                console.log('Upload Result:', result);
                this.fetchDegreesImage();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'File upload failed: ' + error.body.message,
                        variant: 'error',
                    })
                );
            });

    }
    /// End 

    async fetchAndDisplayImage() {
        const base64Data = await fetchImage({ fileName: 'Aadhaar Card Details', EmployeeId: this.employeeId });
        if (base64Data == '') {
            this.isAdhaarCard = false;
            this.isLoading = false;
        } else {
            this.isAdhaarCard = true;
            this.imageUrlAadhar = 'data:image/jpeg;base64,' + base64Data;
            this.isLoading = false;
        }
    }

    fetchDegreesImage() {
        fetchAllImage({ DocumentName: 'Degrees Certificate', EmployeeId: this.employeeId })
            .then(result => {
                console.log('Fetch Image Result:', result);
                if (result && result.length > 0) {
                    this.imageUrlDegrees = result.map(item => {
                        item.base64Data = 'data:image/jpeg;base64,' + item.base64Data; // Prepend data URL
                        this.isLodingDegree = false;
                        return item;
                    });
                } else {
                    this.imageUrlDegrees = null; // Reset if no images found
                    this.isLodingDegree = false;

                }
            })
            .catch(error => {
                console.error('Error fetching image:', error);
                this.imageUrlDegrees = null; // Reset on error
                this.isLodingDegree = false;

            });
    }

    async fetchAndPANDisplayImage() {
        const base64Data1 = await fetchImage({ fileName: 'PAN Card Details', EmployeeId: this.employeeId });
        if (base64Data1 == '') {
            this.isPanCard = false;
        } else {
            this.isPanCard = true;
            this.imageUrlPAN = 'data:image/jpeg;base64,' + base64Data1;

        }
    }


    saveEmployeeDetails() {

        // Check which card type is being edited
        const isEditingAadhaar = this.EditAadhaarNumber;
        const isEditingPANCard = this.EditPANCardNumber;

        console.log('this.editedEmployeeData.Aadhaar_Number__c.length', this.editedEmployeeData.Aadhaar_Number__c.length);
        console.log('this.editedEmployeeData.PAN_Card_Number__c.length', this.editedEmployeeData.PAN_Card_Number__c.length);
        console.log('isEditingPANCard', isEditingPANCard);
        console.log('isEditingAadhaar', isEditingAadhaar);
        console.log('editedEmployeeData.Aadhaar_Number__c', this.editedEmployeeData.Aadhaar_Number__c);
        console.log('this.editedEmployeeData.PAN_Card_Number__c', this.editedEmployeeData.PAN_Card_Number__c);
        // Validate Aadhaar Number length
        if (isEditingAadhaar && !this.editedEmployeeData.Aadhaar_Number__c && this.editedEmployeeData.Aadhaar_Number__c.length == 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Aadhaar Number is required.',
                    variant: 'error',
                })
            );
            return;

        } else if(isEditingAadhaar && this.editedEmployeeData.Aadhaar_Number__c){
            const aadhaarRegex = /^\d{4}-\d{4}-\d{4}$/;
            if (!aadhaarRegex.test(this.editedEmployeeData.Aadhaar_Number__c)) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please enter valid Aadhar Number.',
                        variant: 'error',
                    })
                );
                return;
            }
    
        }

        this.editedEmployeeData.Aadhaar_Number__c = this.editedEmployeeData.Aadhaar_Number__c.toString();

        if (isEditingAadhaar && this.editedEmployeeData.Aadhaar_Number__c && this.editedEmployeeData.Aadhaar_Number__c.length != 14) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Aadhaar Number must be 12 digits long.',
                    variant: 'error',
                })
            );
            return;
        }
        if (isEditingPANCard && this.editedEmployeeData.PAN_Card_Number__c.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'PAN Card Number is required.',
                    variant: 'error',
                })
            );
            return;
        }
        // Validate PAN Card Number length and first four characters
        if (isEditingPANCard && this.editedEmployeeData.PAN_Card_Number__c) {
            let panCardNumber = this.editedEmployeeData.PAN_Card_Number__c;
            console.log('length of pan ', panCardNumber.length);
            if (!/^[A-Z]{5}[0-9]{4}[A-Z]$/.test(panCardNumber)) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please enter valid PAN Card Number.',
                        variant: 'error',
                    })
                );
                return;
            }
        }




        console.log('employeeData-->>', JSON.parse(JSON.stringify(this.editedEmployeeData)));
        updateEmployeeData({ employeeData: this.editedEmployeeData })
            .then(result => {
                console.log('result-->>', JSON.parse(JSON.stringify(result)));
                this.editedEmployeeEduData = [];
                this.fetchEmployeeDetails();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Employee Details are Updated.',
                        variant: 'success',
                    })
                );
            })
            .catch(error => {
                // Handle error
                this.error = error;
                console.error('Error in updating record data:', error);
            });
        this.EditAadhaarNumber = false;
        this.EditPANCardNumber = false;
        this.editAddress = false;

    }

    get tabComponent() {
        return this.isActive ? 'activeTab' : '';
    }

}