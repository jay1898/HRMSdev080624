import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi'

import CANDIDATE_OBJECT from '@salesforce/schema/Candidate__c'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import submitApplication from '@salesforce/apex/ApplicationFormController.submitApplication';
import deleteRedundantFiles from '@salesforce/apex/ApplicationFormController.deleteRedundantFiles';
// import emailOtpVerification from '@salesforce/apex/ApplicationFormController.emailOtpVerification';
// import logOTPSent from '@salesforce/apex/ApplicationFormController.logOTPSent';
// import getLastOTPGenerationTime from '@salesforce/apex/ApplicationFormController.getLastOTPGenerationTime';
import getFileSizes from '@salesforce/apex/ApplicationFormController.getFileSizes';
// import createRecord from '@salesforce/apex/ApplicationFormController.createRecord';
// import deleteFiles from '@salesforce/apex/ApplicationFormController.deleteLargeFiles';
import { CurrentPageReference } from 'lightning/navigation';

export default class ApplicationForm extends LightningElement {

	@api name;
	@api recordId;

	@track qualificationOptions = [];
	@track experienceOptions = [];
	@track aboutUsOptions = [];
	fileData = [];
	uploadedFiles = [];
	emailContainer = [];

	candidateInserted = false;
	isFileUploaded = false;
	showOTPInputModal = false;
	isValidEmail = false;
	keepUserBlocked = false;
	showConfirmation = false;
	@track isLoading = false;
	@track isVerifyEmailLoading = false;
	hasUnsavedChanges = false;
	unloadSet = false;

	newRecord = '';
	Full_Name__c = '';
	Last_Name__c = '';
	Email__c = '';
	// Country__c = '';
	// State__c = '';
	// Address__c = '';
	Phone__c = '';
	selectedQualification = '';
	selectedAboutUs = '';
	selectedExperience = '';
	Highest_Qualification_Held__c = '';
	Years_of_Experience__c = '';
	Salesforce_Certifications__c = '';
	References__c = '';
	candidate_role;
	resumeFile;
	coverLetterFile;
	contentVersionId = '';
	contentVersionIdPrevious = '';
	limitExceeds;
	fileName = '';
	parameters;
	phoneRegex = '';
	checkedCheckbox;
	errorMessageClass = 'slds-hide';
	errorClass = '';
	postInitial = false;
	emailError = '';
	fullNameError = '';
	referenceError = '';
	phoneError = '';
	qualificationError = '';
	experienceError = '';
	aboutusError = '';
	fileuploadError = '';
	isFilelimitExceed = '';
	// showEmailVerifyButton = false;

	selectedCountry = 'IN';
	verifyEmailButtonTitle = 'Verify Email';

	usersOtp = '';
	otpToken = 0;
	inputFocus = 0;
	otpAttempt = 0;
	reGenerateOtpLimit = 0;

	/******************** PICK-LISTS *******************/

	@wire(getObjectInfo, { objectApiName: CANDIDATE_OBJECT })
	objectInfo

	@wire(getPicklistValuesByRecordType, {
		objectApiName: CANDIDATE_OBJECT,
		recordTypeId: '$objectInfo.data.defaultRecordTypeId'
	})
	pickListFields({ data, error }) {

		if (data) {
			data = JSON.parse(JSON.stringify(data)).picklistFieldValues;
			//console.log('pickListFields: ', data)
			this.experienceOptions = [...this.generatePicklist((JSON.parse(JSON.stringify(data))).Years_of_Experience__c)];
			this.qualificationOptions = [...this.generatePicklist((JSON.parse(JSON.stringify(data))).Highest_Qualification_Held__c)];
			this.aboutUsOptions = [...this.generatePicklist((JSON.parse(JSON.stringify(data))).How_Did_You_Hear_About_Us__c)];

			// console.log('Experience Options', this.experienceOptions);
			// console.log('Qualification Options', this.qualificationOptions);
			// console.log('About us Options', this.aboutUsOptions);
		}
		if (error) {
			console.error('pickListFields:', error)
		}
	}



	/******************** HANDLERS *******************/

	handleInputChange(event) {

		const fieldName = event.target.name;
		const fieldValue = event.target.value;

		//Remove spaces from the input value
		// fieldValue = fieldValue.replace(/\s/g, '');
	
		this.postInitial = true;
		const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
		// const phoneRegex = /^(?:\+?\d{1,3}[-\s.]?)?\(?\d{1,4}?\)?[-\s.]?\d{1,4}[-\s.]?\d{1,4}[-\s.]?\d{1,4}$/;
		// const phoneRegex = /^\d{10}$/;
		// const phoneRegex = /^(\d\s?){10}$/;
		const phoneRegex = /^(\d\s?){10}$/;
		if (fieldName === 'Full_Name__c') {
        if (!fieldValue.trim() || fieldValue === '') {
            this.fullNameError = 'Please enter full name.';
        } else {
            this.fullNameError = '';
        }
    } else if (fieldName === 'Email__c') {
        if (!emailRegex.test(fieldValue) || /\s/.test(fieldValue)) {
            this.emailError = 'Please enter a valid email address.';
        } else {
            this.emailError = '';
        }
    } else if (fieldName === 'Phone__c') {
        if (!fieldValue || !phoneRegex.test(fieldValue.replace(/\s/g, ''))) {
            this.phoneError = 'Please enter a 10-digit phone number.';
        } else {
            this.phoneError = '';
        }
    } else if (fieldName === 'Highest_Qualification_Held__c') {
        if (!fieldValue) {
            this.qualificationError = 'Please enter your highest qualification.';
        } else {
            this.qualificationError = '';
        }
    } else if (fieldName === 'References__c') {
        if (!fieldValue.trim() || fieldValue === '') {
            this.referenceError = 'Please enter your reference.';
        } else {
            this.referenceError = '';
        }
    } else if (fieldName === 'Years_of_Experience__c') {
        if (!fieldValue) {
            this.experienceError = 'Please specify your years of experience.';
        } else {
            this.experienceError = '';
        }
    } else if (fieldName === 'How_Did_You_Hear_About_Us__c') {
        this.selectedAboutUs = fieldValue;
		if (!fieldValue) {
            this.aboutusError = 'Please share how you came to know about us.';
        } else {
            this.aboutusError = '';
        }
        if (this.selectedAboutUs === 'Referral') {
            this.showReferenceField = true;
            this.referenceError = '';
        } else {
            this.showReferenceField = false;
            this.References__c = '';
            this.referenceError = '';
        }
    }

		// // Validate the input and show error messages if necessary
		// this.validateInput(fieldName, fieldValue);

		// // Check if there are spaces in any of the fields, and update the isSubmitDisabled flag
		// this.isSubmitDisabled = this.hasSpacesInFields();

		this.hasUnsavedChanges = true;
		if (event.target.name == 'Full_Name__c') {
			this.Full_Name__c = event.target.value;
		} else if (fieldName == 'Last_Name__c') {
			this.Last_Name__c = fieldValue;
		} else if (fieldName === 'Email__c') {
			this.Email__c = fieldValue;
		} else if (fieldName === 'Phone__c') {
			this.Phone__c = fieldValue;
		} else if (fieldName === 'Highest_Qualification_Held__c') {
			this.selectedQualification = event.target.value;
		} else if (fieldName === 'Years_of_Experience__c') {
			this.selectedExperience = event.target.value;
		} else if (fieldName === 'Salesforce_Certifications__c') {
			this.Salesforce_Certifications__c = fieldValue;
		} else if (fieldName === 'How_Did_You_Hear_About_Us__c') {
			this.selectedAboutUs = event.target.value;
		} else if (fieldName === 'References__c') {
			this.References__c = fieldValue;
		}

		// if(this.Full_Name__c.trim()){
		// 	this.showEmailVerifyButton = (this.Full_Name__c && this.Email__c);
		// 	console.log('onChange: HandleInput: This.ShowEmailVerifyButton: ' + this.showEmailVerifyButton);
		// }else{
		// 	//this.showToast('Please Enter Full Name',' ','Error');
		// 	this.showEmailVerifyButton = false;
		// 	console.log('onChange: HandleInput: This.ShowEmailVerifyButton: ' + this.showEmailVerifyButton);
		// }
	}

	// validateInput(fieldName, fieldValue) {
	// 	// Existing validation code
	
	// 	// ...
	
	// 	// Example: Check if the fieldValue contains spaces
	// 	if (fieldValue.includes(' ')) {
	// 		this[fieldName + 'Error'] = 'Spaces are not allowed.';
	// 	} else {
	// 		this[fieldName + 'Error'] = ''; // Clear the error message if no spaces
	// 	}
	// }

	// hasSpacesInFields() {
	// 	// Check if any of the fields have spaces
	// 	const fieldsWithSpaces = ['Full_Name__c', 'Email__c', 'Phone__c', 'Highest_Qualification_Held__c', 'References__c', 'Years_of_Experience__c'];
	
	// 	for (const fieldName of fieldsWithSpaces) {
	// 		const fieldValue = this[fieldName];
	// 		if (fieldValue && fieldValue.includes(' ')) {
	// 			return true; // Return true if spaces are found
	// 		}
	// 	}
	
	// 	return false; // Return false if no spaces are found
	// }

	// handleAddressChange(event) {
	// 	this.Street__c = event.detail.street;
	// 	this.City__c = event.detail.city;
	// 	this.State__c = event.detail.province;
	// 	this.Postal_Code__c = event.detail.postalCode;
	// 	this.selectedCountry = event.detail.country;

	// 	// console.log('street: ', event.detail.street);
	// 	// console.log('city: ', event.detail.city);
	// 	// console.log('province: ', event.detail.province);
	// 	// console.log('postalCode: ', event.detail.postalCode);
	// 	// console.log('country: ', event.detail.country);
	// }

	// handleInput(event) {
	// 	const input = event.target;
	// 	const value = input.value;

	// 	if (isNaN(value)) {
	// 		input.value = '';
	// 		return;
	// 	}

	// 	if (value !== '') {
	// 		this.usersOtp += value;
	// 		//console.log('USER OTP:' + this.usersOtp);
	// 		const nextInput = input.nextElementSibling;
	// 		if (nextInput) {
	// 			this.inputFocus++;
	// 			nextInput.focus();
	// 			//console.log('this.inputFocus++: ' + this.inputFocus);
	// 		}
	// 	}
	// }

	// handleKeydown(event) {
	// 	const input = event.target;
	// 	const key = event.key.toLowerCase();

	// 	if (key === 'backspace' || key === 'delete') {
	// 		input.value = '';
	// 		const prevInput = input.previousElementSibling;
	// 		if (prevInput) {
	// 			prevInput.focus();
	// 			this.inputFocus--;
	// 			//console.log('this.inputFocus--: ' + this.inputFocus);

	// 			//remove last added number from usersOtp
	// 			if (this.usersOtp.length != 0) {
	// 				this.usersOtp = this.usersOtp.substring(0, this.usersOtp.length - 1);
	// 				//console.log('USER OTP:' + this.usersOtp);
	// 			} else {
	// 				this.usersOtp = '';
	// 			}

	// 		}
	// 	}
	// }

	handleEmailonBlur(event) {
		const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
		if (event.target.name === 'Email__c') {
			if (!emailRegex.test(event.target.value) || /\s/.test(event.target.value)) {
				this.emailError = 'Please enter a valid email address.';
			} else {
				this.emailError = '';
			}
		}
		// console.log('handleEmailonBlur: The email is: ', this.Email__c);

		//check this email is contained in the blocked email list from the localStorage
		// let tempBlockedList = JSON.parse(localStorage.getItem('blockedEmails'));

		// if (tempBlockedList == null || tempBlockedList == '')
		// 	return;

		// tempBlockedList.forEach((item, index) => {
		// 	if (item.emailAddress === this.Email__c) {
		// 		console.log(this.Email__c + ' is blocked as of now');
		// 		this.keepUserBlocked = true;
		// 	} else {
		// 		this.keepUserBlocked = false;
		// 		this.reGenerateOtpLimit = 0;
		// 		console.log('Reseting regenerate Limit for this email', this.Email__c);
		// 	}
		// });
	}

	/*handleUserOTPInput(event) {
		this.usersOtp = event.target.value;
		console.log('user entered Otp', this.usersOtp);
	}*/
	// cntRegenerate = 1;
	// validateWithUserOtp() {
	// 	if (this.usersOtp.length == 4) {
	// 		if (this.otpToken == Number.parseInt(this.usersOtp)) {
	// 			this.isValidEmail = true;
	// 			this.showOTPInputModal = false;
	// 			this.usersOtp = '';
	// 			this.inputFocus = 0;
	// 			this.showToast('Success', 'Email Verified', 'Success');
	// 			this.candidate_role = this.name;
	// 			createRecord({ fullName: this.Full_Name__c, email: this.Email__c, role: this.candidate_role }).then((result) => {
	// 				if (result) {
	// 					this.newRecord = result;
	// 					console.log('newly created record id', this.newRecord);
	// 				} else {
	// 					console.log('emailOtpVerification: ', result);
	// 				}
	// 			}).catch((error) => {
	// 				console.error(error);
	// 				this.showToast('Error', error.body.message, 'error');
	// 			})
	// 			//TODO: add this css to the div
	// 			this.template.querySelector('.myEmailField').classList.add("emailVerifiedClass");
	// 		} else {
	// 			this.isValidEmail = false;
	// 			// this.showOTPInputModal = false;
	// 			// this.usersOtp = '';
	// 			// this.inputFocus = 0;
	// 			// this.verifyEmailButtonTitle = 'Re-Generate OTP';
	// 			this.otpAttempt++;

	// 			// Remove focus from last Cursor to First Cursor
	// 			const inputs = this.template.querySelectorAll('.input-1');
	// 			inputs.forEach(input => {
	// 				input.value = '';
	// 			});
	// 			inputs[0].focus(); // set focus to the first input
	// 			this.usersOtp = ''; // reset the OTP string
	// 			this.inputFocus = 0; // reset the focus index

				

	// 			if (this.otpAttempt < 3) {
	// 				const remainingAttempts = 3 - this.otpAttempt;
	// 				this.inputFocus = 0;
	// 				// Show an error message for incorrect OTP
	// 				this.showToast('Please Enter Correct OTP', 'Attempt Remaining ' + remainingAttempts, 'Error');
					
	// 			}else if(this.cntRegenerate==2){
	// 				// Close the OTP modal after 3 attempts
	// 				this.verifyEmailButtonTitle = 'Verify Email';
	// 				this.showOTPInputModal = false;
	// 				this.otpAttempt = 0; // Reset the attempts counter
					
	// 				this.showToast('OTP Incorrect', 'Maximum OTP Generation Reached or Try after 2 minutes', 'Error');
	// 				this.cntRegenerate=1;
	// 			} else {
	// 				// Close the OTP modal after 3 attempts
	// 				this.verifyEmailButtonTitle = 'Re-Generate OTP';
	// 				this.showOTPInputModal = false;
	// 				this.otpAttempt = 0; // Reset the attempts counter
	// 				this.cntRegenerate++;
	// 				this.showToast('OTP Incorrect', 'Please Re-Generate OTP', 'Error');
	// 			}

	// 			// this.showToast('OTP Incorrect', ' Please Enter Correct Otp', 'Error');
	// 			// this.handleInput();
	// 			// this.template.querySelector('.myEmailField').classList.remove("emailVerifiedClass");
	// 		}


	// 	}
	// }
	// backup
	// handleVerifyOTPButtonClick(event) {
	// 	if (!(this.Full_Name__c && this.Email__c)) {
	// 		this.showToast('Details Missing', 'Please enter Full Name & Email', 'error');
	// 		return;
	// 	}
	// 	if (this.keepUserBlocked) {
	// 		console.log('User is blocked. Cannot generate OTP.');
	// 		this.showToast('User is Blocked', 'Can not generate more', 'Error');
	// 		return;
	// 	}

	// 	if (this.reGenerateOtpLimit < 2) {
	// 		emailOtpVerification({ email: this.Email__c, name: this.Full_Name__c }).then((result) => {
	// 			if (result) {
	// 				console.log('data in verify otp', result);
	// 				this.otpToken = result;
	// 				this.showOTPInputModal = true;
	// 				this.reGenerateOtpLimit++; // Only Generate 2 time with that email 
	// 			} else {
	// 				console.log('emailOtpVerification: ', result);
	// 			}
	// 		}).catch((error) => {
	// 			console.error(error);
	// 			this.showToast('Error', error.body.message, 'error');
	// 		})
	// 	} else {
	// 		this.showToast('Enter New Email', 'Maximum OTP Generation Reached', 'error');
	// 		this.verifyEmailButtonTitle = 'Verify Email';

	// 		let mObj = {};
	// 		mObj['emailAddress'] = this.Email__c;
	// 		mObj['timeAdded'] = new Date();
	// 		console.log('Adding This Object to blocked email list in tempArray: ', mObj);

	// 		//get the blocked list from the local storage & add this email to the same
	// 		let tempArray = [];
	// 		tempArray.push(mObj);

	// 		//prevent overriding 
	// 		let currentDataInStorage = JSON.parse(localStorage.getItem('blockedEmails'));
	// 		if (currentDataInStorage != null || currentDataInStorage.length != 0) {
	// 			currentDataInStorage.push(mObj);
	// 			localStorage.setItem('blockedEmails', JSON.stringify(currentDataInStorage));
	// 		} else {
	// 			localStorage.setItem('blockedEmails', JSON.stringify(tempArray));
	// 		}
	// 		console.log('After Adding into Storage Now::: ', JSON.parse(localStorage.getItem('blockedEmails')))
	// 	}
	// }

	// handleVerifyOTPButtonClick(event) {
	// 	this.isVerifyEmailLoading = true;
	// 	if (!(this.Full_Name__c && this.Email__c)) {
	// 		this.showToast('Details Missing', 'Please enter Full Name & Email', 'error');
	// 		return;
	// 	}

	// 	getLastOTPGenerationTime({ email: this.Email__c }).then(response => {
	// 		console.log('@@@@response', response);

	// 		// Server will determine if OTP can be regenerated or not
	// 		if (response.canRegenerateOTP) {
	// 			emailOtpVerification({ email: this.Email__c, name: this.Full_Name__c }).then((result) => {
	// 				if (result) {
	// 					console.log('data in verify otp', result);
	// 					this.otpToken = result;
	// 					this.isVerifyEmailLoading = false;
	// 					this.showOTPInputModal = true;

	// 					logOTPSent({ email: this.Email__c }).then(() => {
	// 						// Successfully logged OTP sent time.
	// 					}).catch(error => {
	// 						console.error("Error logging OTP sent timestamp:", error);
	// 					});
	// 				} else {
	// 					console.log('emailOtpVerification: ', result);
	// 				}
	// 			}).catch((error) => {
	// 				console.error(error);
	// 				this.showToast('Error', error.body.message, 'error');
	// 			});
	// 		} else {
	// 			this.isVerifyEmailLoading = false;
	// 			// The message can be adjusted based on the server response, if necessary
	// 			this.showToast('Enter New Email', 'Maximum OTP Generation Reached or Try after 2 minutes', 'error');
	// 			this.verifyEmailButtonTitle = 'Verify Email';
	// 		}
	// 	}).catch(error => {
	// 		this.isVerifyEmailLoading = false;
	// 		this.showToast('Error', 'Unable to verify OTP at this time. Please try again later.', 'error');
	// 	});
	// }


	// Working code of Blocled email for 1 day
	// handleVerifyOTPButtonClick(event) {
	// 	this.isVerifyEmailLoading = true;
	// 	if (!(this.Full_Name__c && this.Email__c)) {
	// 		this.showToast('Details Missing', 'Please enter Full Name & Email', 'error');
	// 		return;
	// 	}

	// 	getLastOTPGenerationTime({ email: this.Email__c }).then(response => {
	// 		let lastGeneratedTime = new Date(response.lastGeneratedTime);
	// 		let regenerationCount = response.regenerationCount;
	// 		console.log('@@@@response', response);
	// 		// console.log('lastgenerated time', lastGeneratedTime);
	// 		// console.log('regeneration count'+regenerationCount);
	// 		let currentTime = new Date();
	// 		let timeDifference = currentTime - lastGeneratedTime;
	// 		let twoMinutes = 2 * 60 * 1000;
	// 		// let oneDay = 1 * 60 * 60 * 1000;


	// 		if (timeDifference >= twoMinutes) {
	// 			regenerationCount = 0;
	// 			// You might want to update the server with this new state.
	// 		}


	// 		// regenerationCount = 0;

	// 		if (regenerationCount < 2) {
	// 			emailOtpVerification({ email: this.Email__c, name: this.Full_Name__c }).then((result) => {
	// 				if (result) {
	// 					console.log('data in verify otp', result);
	// 					this.otpToken = result;
	// 					this.isVerifyEmailLoading = false;
	// 					this.showOTPInputModal = true;
	// 					// this.reGenerateOtpLimit++; // Only Generate 2 times with that email 

	// 					logOTPSent({ email: this.Email__c }).then(() => {
	// 						// Successfully logged OTP sent time.
	// 					}).catch(error => {
	// 						console.error("Error logging OTP sent timestamp:", error);
	// 					});

	// 				} else {
	// 					console.log('emailOtpVerification: ', result);
	// 				}
	// 			}).catch((error) => {
	// 				console.error(error);
	// 				this.showToast('Error', error.body.message, 'error');
	// 			})
	// 		} else if (regenerationCount >= 2 && timeDifference < twoMinutes) {
	// 			this.isVerifyEmailLoading = false;
	// 			this.showToast('Enter New Email', 'Please try again after 1 day', 'error');
	// 			this.verifyEmailButtonTitle = 'Verify Email';
	// 			return;
	// 		}else{
	// 			this.isVerifyEmailLoading = false;
	// 			this.showToast('Enter New Email', 'in else part', 'error');
	// 			this.verifyEmailButtonTitle = 'Verify Email';
	// 			return;
	// 		}

	// 		// else {
	// 		// 	this.isVerifyEmailLoading = false;
	// 		// 	this.showToast('Enter New Email', 'Maximum OTP Generation Reached', 'error');
	// 		// 	this.verifyEmailButtonTitle = 'Verify Email';
	// 		// }
	// 	}).catch(error => {
	// 		// If no OTP generation time found, it means it's a new email address.
	// 		if (regenerationCount < 2) {
	// 			emailOtpVerification({ email: this.Email__c, name: this.Full_Name__c }).then((result) => {
	// 				if (result) {
	// 					console.log('data in verify otp', result);
	// 					this.otpToken = result;
	// 					this.showOTPInputModal = true;
	// 					// this.reGenerateOtpLimit++; // Only Generate 2 times with that email 

	// 					logOTPSent({ email: this.Email__c }).then(() => {
	// 						// Successfully logged OTP sent time.
	// 					}).catch(error => {
	// 						console.error("Error logging OTP sent timestamp:", error);
	// 					});

	// 				} else {
	// 					console.log('emailOtpVerification: ', result);
	// 				}
	// 			}).catch((error) => {
	// 				console.error(error);
	// 				this.showToast('Error', error.body.message, 'error');
	// 			})
	// 		} else {
	// 			this.isVerifyEmailLoading = false;
	// 			this.showToast('Enter New Email', 'Maximum OTP Generation Reached', 'error');
	// 			this.verifyEmailButtonTitle = 'Verify Email';
	// 		}
	// 	});
	// }

	handleCheckbox(event) {
		this.checkedCheckbox = event.target.checked;
		// console.log('checked',this.checkedCheckbox);
		this.errorClass = ''; // Reset error class if checkbox is checked
		this.errorMessageClass = 'slds-hide';
	}
	handleSubmit() {
		// getting Candidate Role from index file data
		this.candidate_role = this.name;

		let validationErrors = [];
		
		const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
		if (!this.Full_Name__c) {
			validationErrors.push('Please enter full name.');
			this.fullNameError = validationErrors[validationErrors.length - 1];
		}

		if (!this.Email__c || !emailRegex.test(this.Email__c)) {
			validationErrors.push('Please enter a valid email address.');
			this.emailError = validationErrors[validationErrors.length - 1];
		}

		// Phone Validation
		// const phoneRegex = /^(?:\+?\d{1,3}[-\s.]?)?\(?\d{1,4}?\)?[-\s.]?\d{1,4}[-\s.]?\d{1,4}[-\s.]?\d{1,4}$/;
		// const phoneRegex = /^\d{10}$/;
		// const phoneRegex = /^(\d\s?){10}$/;
		// if (!this.Phone__c || !phoneRegex.test(this.Phone__c)) {
		// 	validationErrors.push('Please enter a 10-digit phone number.');
		// 	this.phoneError = validationErrors[validationErrors.length - 1];
		// 	// return;
		// }

		const phoneRegex = /^(\d\s?){10}$/;
		if (!this.Phone__c || !phoneRegex.test(this.Phone__c.replace(/\s/g, ''))) {
			validationErrors.push('Please enter a 10-digit phone number.');
			this.phoneError = validationErrors[validationErrors.length - 1];
		}

		if (!this.selectedQualification) {
			validationErrors.push('Please enter your highest qualification.');
			this.qualificationError = validationErrors[validationErrors.length - 1];
		}

		// if (!this.References__c) {
		// 	validationErrors.push('Please enter your Reference ');
		// 	this.referenceError = validationErrors[validationErrors.length - 1];
		// }

		if (!this.selectedExperience) {
			validationErrors.push('Please specify your years of experience.');
			this.experienceError = validationErrors[validationErrors.length - 1];
		}

		if (!this.selectedAboutUs) {
			validationErrors.push('Please share how you came to know about us.');
			this.aboutusError = validationErrors[validationErrors.length - 1];
		}

		if (this.isFileUploaded == false) {
			validationErrors.push('Please upload your resume/CV.');
			this.fileuploadError = validationErrors[validationErrors.length - 1];
		}

		if (!this.References__c.trim() && this.showReferenceField) {
			validationErrors.push('Please enter your reference.');
			this.referenceError = validationErrors[validationErrors.length - 1];
        }

		if (!this.checkedCheckbox) {
			validationErrors.push('Please check the checkbox.');
			this.errorClass = 'error-border';
			this.errorMessageClass = '';
		}

		if (validationErrors.length > 0) {
			// Display the first error message as a toast
			// this.showToast('Error', validationErrors[0], 'error');
			return;
		}


		// Phone Validation on submit button
		// const phoneRegex = /^(?:\+?\d{1,3}[-\s.]?)?\(?\d{1,4}?\)?[-\s.]?\d{1,4}[-\s.]?\d{1,4}[-\s.]?\d{1,4}$/;
		// if (!this.Phone__c || !phoneRegex.test(this.Phone__c)) {
		// 	this.phoneError = 'Please enter 10 Digit Phone Number.';
		// 	return;
		// }

		// if (!this.selectedQualification) {
		// 	this.qualificationError = 'Please enter Your Highest Qualification.';
		// 	return;
		// } else if (!this.selectedExperience) {
		// 	this.experienceError = 'Please specify your years of experience.';
		// 	return;
		// } else if (!this.selectedAboutUs) {
		// 	this.aboutusError = 'Please share how you came to know about us.';
		// 	return;
		// }
		// // else if (!this.selectedExperience) {
		// // 	this.phoneError = 'Please enter 10 Digit Phone Number';
		// // 	return;
		// // }else if (!this.selectedAboutUs) {
		// // 	this.phoneError = 'Please enter 10 Digit Phone Number';
		// // 	return;
		// // }

		// // Validation required fields and file !this.Country__c || !this.Address__c || !this.State__c
		// // if (!this.Phone__c || !this.selectedQualification || !this.selectedAboutUs || !this.selectedExperience) {
		// // 	this.showToast('Error', 'Required fields are empty', 'error');
		// // 	return;
		// // }

		// if (this.isFileUploaded == false) {
		// 	this.fileuploadError = 'Please Upload Resume/CV';
		// 	this.showToast('Error', 'Please Upload Resume/CV', 'error');
		// 	return;
		// } else {
		// 	this.fileuploadError = '';
		// }
		// // console.log('Above Checkbox');
		// // const checkbox = this.template.querySelector('#checkboxTnC');
		// console.log('Below Checkbox', this.checkedCheckbox);
		// if (!this.checkedCheckbox) {
		// 	this.errorClass = 'error-border'; // A class that gives a red border or any other visual indication
		// 	this.errorMessageClass = '';
		// 	// event.preventDefault(); // Stop the form from submitting
		// 	// this.showToast('Error','Please check checkbox','Error');
		// 	return;
		// }
		console.log('After Logic');
		this.isLoading = true;
		submitApplication({
			RecordId: this.newRecord,
			fullName: this.Full_Name__c,
			email: this.Email__c,
			phone: this.Phone__c,
			// country: this.selectedCountry,
			// state: this.State__c,
			// address: this.Address__c,
			// city: this.City__c,
			// street: this.State__c,
			// zipcode: this.Postal_Code__c,
			qualification: this.selectedQualification,
			role: this.candidate_role,
			contentVersionId: this.contentVersionId,
			experience: this.selectedExperience,
			certification: this.Salesforce_Certifications__c,
			hearAboutUs: this.selectedAboutUs,
			reference: this.References__c
		}).then(result => {
			if (result === 'Success') {

				// this.showToast('Success', 'Your application submitted', 'success');
				this.isFileUploaded = false;
				this.candidateInserted = true;
				this.hasUnsavedChanges = false; 
				this.resetForm();
				// window.location.href = 'https://www.itechcloudsolution.com/';
				const selectedEvent = new CustomEvent("submitclicked", {
					detail: true
				});
				// Dispatches the event.
				this.dispatchEvent(selectedEvent);
			} else {
				console.error('submitApplication:', error);
				this.showToast('Error', result, 'Error');
			}
		}).catch(error => {
			console.error('submitApplication:', error);
			this.showToast('Error', 'An error occurred: ' + error, 'Error');
		});
	}


	/******************** HELPER METHODS *******************/

	generatePicklist(data) {
		return data.values.map(item => ({
			label: item.label,
			value: item.value
		}))
	}

	resetForm() {
		this.Full_Name__c = '';
		this.Email__c = '';
		this.Phone__c = '';
		// this.State__c = '';
		// this.Address__c = '';
		// this.City__c = '';
		this.Postal_Code__c = '';
		this.selectedQualification = '';
		this.selectedExperience = '';
		this.selectedAboutUs = '';
		this.Salesforce_Certifications__c = '';
		this.References__c = '';
		this.Years_of_Experience__c = '';

		// this.Street__c = '';
		// this.City__c = '';
		this.State__c = '';
		this.selectedCountry = '';
		// this.Postal_Code__c = '';

		this.inputFocus = 0;
		this.isValidEmail = false;
		this.verifyEmailButtonTitle = 'Verify Email';
	}

	closeModal() {
		this.showOTPInputModal = false;
		this.isValidEmail = false;
		this.usersOtp = '';
		this.inputFocus = 0;
		this.verifyEmailButtonTitle = 'Re-Generate OTP';
	}

	showToast(mTitle, mMessage, mVariant) {
		const event = new ShowToastEvent({
			title: mTitle,
			message: mMessage,
			variant: mVariant,
			mode: 'pester'
		});
		this.dispatchEvent(event);
	}


	/******************** FILES METHODs *******************/

	//TODO: USELESS METHOD
	/*handleFileUpload(event) {
		const fieldName = event.target.name;
		const file = event.target.files[0];
	}*/

	//TODO: USELESS METHOD
	/*async handleSave() {
		if (!this.resumeFile || !this.coverLetterFile) {
			this.showToast('Error', 'Please select both resume and cover letter files.', 'error');
			return;
		}

		try {
			const resumeBase64 = await this.convertFileToBase64(this.resumeFile);
			const coverLetterBase64 = await this.convertFileToBase64(this.coverLetterFile);

			const candidateId = await uploadFiles({
				newCandidate: this.recordId, // Replace with actual candidate ID
				resumeName: this.resumeFile.name,
				coverLetterName: this.coverLetterFile.name,
				resumeBase64,
				coverLetterBase64
			});
		} catch (error) {
			console.error(error);
			this.showToast('Error', 'An error occurred while uploading files.', 'error');
		}
	}*/

	//TODO: USELESS METHOD
	/*convertFileToBase64(file) {
		return new Promise((resolve, reject) => {
			const reader = new FileReader();
			reader.onload = () => {
				resolve(reader.result.split(',')[1]);
			};
			reader.onerror = () => {
				reject('Error reading file');
			};
			reader.readAsDataURL(file);
		});
	}*/

	handleUploadFinished(event) {

		console.log('Files uploaded:', event.detail.files);
		var uploadedFiles = event.detail.files;
		console.log('uploadedFiles', uploadedFiles);
		// if (event.target.files.length > 0) {
		// 	// this.documnetadded = true;
		// 	for (var i = 0; i < event.target.files.length; i++) {
		// 		this.fileSize = this.fileSize + event.target.files[i].size;
		// 		console.log("filesieze++++++",this.fileSize);
		// 		//consze.log('@@this.ALLOWED_FILE_TYPES:', this.ALLOWED_FILE_TYPES);
		// 		// if (!this.ALLOWED_FILE_TYPES.includes(event.target.files[i].type)) {
		// 		// 	this.fileTypeDifferent = true;
		// 		// 	return;
		// 		// } else {
		// 		// 	this.fileTypeDifferent = false;
		// 		// }
		// 		if (this.fileSize >= MAX_FILE_SIZE) {
		// 			this.limitExceeds = true;
		// 			this.fileSize = this.fileSize - event.target.files[i].size;
		// 			console.log('File size exceeded the upload size limit.');
		// 			return;
		// 		} else {
		// 			this.limitExceeds = false;
		// 		}
		// 		// let file = event.target.files[i];
		// 		// let reader = new FileReader();
		// 		// reader.onload = e => {
		// 		// 	var fileContents = reader.result.split(',')[1]

		// 		// 	this.filesData.push({ 'fileName': file.name, 'fileContent': fileContents, 'fileSize': file.size });
		// 		// };
		// 		// reader.readAsDataURL(file);
		// 	}
		// 	//console.log('@@@this.filesData', this.filesData);
		// }



		// Calling apex for getting file size
		let contentVersionIds = uploadedFiles.map(file => file.contentVersionId);


		getFileSizes({ contentVersionIds: contentVersionIds })
			.then(result => {
				console.log('result@@@!!@!!', result);
				let filesToDelete = []; // This will store the contentVersionIds of files to delete
				result.forEach(file => {
					console.log('File Name:', file.Title);
					console.log('File Size:', file.ContentSize);

					if (file.ContentSize < 25 * 1024 * 1024) {
						// if Size is less than 25 MB
						this.fileuploadError = '';
						console.log('Size is less than 5 MB', file.ContentSize);
						this.contentVersionId = file.Id;
						this.fileName = file.Title;
						this.isFileUploaded = true;
						this.isFilelimitExceed = false;
						console.log('contentVersionId@@++', this.contentVersionId);
					} else if (file.ContentSize > 25 * 1024 * 1024) {
						// if Size is Greater than 25 MB
						this.filename = '';

						this.isFileUploaded = false;
						console.log('In case large file name ', this.filename);
						this.isFilelimitExceed = true;
						// this.showToast('Error', 'Please Choose below 25 MB file', 'Error');
						filesToDelete.push(file.contentVersionId); // Add to delete list
					}

					// console.log('contentVersionId: ' + this.contentVersionId);
					console.log('File name', this.fileName);
					console.log('isFileUploaded', this.isFileUploaded);
				});

				// if (filesToDelete.length > 0) {
				// 	// Delete the oversized files
				// 	deleteRedundantFiles({ cvId:  contentVersionIds[0] }).then((result) => {
				// 		if (result === 'success') {
				// 			console.log('Recent file delted');
				// 			this.showToast('Success', 'Your previously uploaded file removed', 'success');
				// 			this.contentVersionIdPrevious = this.contentVersionId;
				// 		}
				// 	}).catch((error) => {
				// 		console.log(error);
				// 	})

				// }
			})
			.catch(error => {
				console.error('Error fetching file sizes:', error);
			});




		// For Lightning file upload Standard
		// console.log('Files uploaded:', event.detail.files);
		// var uploadedFiles = event.detail.files;
		// console.log('uploadedFiles', uploadedFiles);
		// uploadedFiles.forEach(file => {
		// 	console.log('File size @@@@', file.size);
		// 	// if (file.size > 5 * 1024 * 1024) {  // 5 MB = 5 * 1024 * 1024 bytes
		// 	// 	alert('The file size should not exceed 5 MB.');
		// 	// 	return; // exit and don't process the file
		// 	// }
		// 	const reader = new FileReader();
		// 	reader.onloadend = () => {
		// 		const fileSize = file.size; // Get the file size in bytes
		// 		console.log('File Size: using reader' + fileSize + ' bytes');
		// 	};
		// 	this.contentVersionId = file.contentVersionId;
		// 	this.fileName = file.name;
		// 	this.isFileUploaded = true;
		// 	console.log('contentVersionId: ' + this.contentVersionId);
		// 	console.log('File name', this.fileName);
		// 	// console.log('upload file size',this.uploadedFiles.length);
		// });

		this.contentVersionId = contentVersionIds[0];
		console.log('this.contentVersionId', this.contentVersionId);

		//initially document id will be null
		if (this.contentVersionIdPrevious == null || this.contentVersionIdPrevious == '') {
			this.contentVersionIdPrevious = this.contentVersionId;
			console.log('First File (Only One)');
		} else if ((this.contentVersionIdPrevious != '' || this.contentVersionIdPrevious != '') && this.contentVersionIdPrevious != this.contentVersionId) {
			console.log('Second file occurence... Deleting previous file: ' + this.contentVersionIdPrevious);

			deleteRedundantFiles({ cvId: this.contentVersionIdPrevious }).then((result) => {
				if (result === 'success') {
					console.log('Recent file delted');
					// this.showToast('Success', 'Your previously uploaded file removed', 'Info');
					this.contentVersionIdPrevious = this.contentVersionId;
				}
			}).catch((error) => {
				console.log(error);
			})

		}
	}

	/******************** GETTERS *******************/

	get acceptedFormats() {
		return ['.pdf', '.doc','.docx'];
	}
	get showEmailVerifyButton() {
		return this.Full_Name__c.trim() && this.Email__c.trim() && !this.fullNameError && !this.emailError;
		// Remove WhiteSpace Validation
		// if (this.Full_Name__c.trim()) {
		// 	return (this.Full_Name__c && this.Email__c);
		// } else {
		// 	if (this.postInitial) {
		// 		// this.showToast('Please Enter Full Name', ' ', 'Error');
		// 	}
		// 	return false;
		// }
		// return (this.Full_Name__c && this.Email__c);


		// GPT
		// if (this.Full_Name__c.trim() && this.Email__c.trim()) { // make sure both fields are not just whitespace
		// 	return true;
		// } else {
		// 	if (this.postInitial) {
		// 		if (!this.Full_Name__c.trim()) {
		// 			// this.showToast('Please Enter Full Name', ' ', 'Error'); // Uncomment if you want the toast message
		// 		}
		// 	}
		// 	return false;
		// }
	}
	get emailFieldDisable() {
		return this.isValidEmail;
	}
	get emailVerified() {
		return !this.isValidEmail;
	}
	get emailInputClass() {
		return this.emailError ? 'input error-border' : 'input';
	}
	get fullNameInputClass() {
		return this.fullNameError ? 'input error-border' : 'input';
	}
	get RefernceInputClass() {
		return this.referenceError ? 'input error-border' : 'input';
	}
	get phoneInputClass() {
		return this.phoneError ? 'input error-border' : 'input';
	}
	// get spanInputClass() {
	// 	return this.phoneError ? 'phoneinputspanclass' : '';
	// }
	get qualificationInputClass() {
		return this.qualificationError ? 'slds-has-error' : '';
	}
	get experienceInputClass() {
		return this.experienceError ? 'slds-has-error' : '';
	}
	get aboutusInputClass() {
		return this.aboutusError ? 'slds-has-error' : '';
	}
	// get addressVerified() {
	// 	return !this.isValidEmail;
	// }
	// get countryVerified() {
	// 	return !this.isValidEmail;
	// }
	// get stateVerified() {
	// 	return !this.isValidEmail;
	// }
	get stateOptions() {
		return this.countryStateMap[this.selectedCountry];
	}
	get countryOptions() {
		return this.countryOptions;
	}

	/******************** Session Management Methods *********/

	// calculateUserBlockTimeFromSession() {
	// 	let blockedEmailListFromStorage = JSON.parse(localStorage.getItem('blockedEmails'));
	// 	console.log('blockedEmailListFromStorage: ', blockedEmailListFromStorage);

	// 	if (blockedEmailListFromStorage == null || blockedEmailListFromStorage == '' || blockedEmailListFromStorage.length == 0) {
	// 		console.log('returning as blockedEmailListFromStorage is empty')
	// 		return;
	// 	}

	// 	let toAddInLocalStorage = blockedEmailListFromStorage;

	// 	blockedEmailListFromStorage.forEach((item, index) => {
	// 		let firstDate = new Date(item.timeAdded);
	// 		let secondDate = new Date();

	// 		// Calculate the difference in milliseconds between the two dates
	// 		const timeDifference = secondDate - firstDate;
	// 		console.log('timeDifference ' + timeDifference);

	// 		// Check if the difference is more than 1 minutes
	// 		if (timeDifference >= (1 * 60 * 1000)) {
	// 			console.log('The difference between the two dates is more than 1 minutes.\nPopping this objected from blocked list: ', item);
	// 			//remove this object as it passed the waiting period
	// 			toAddInLocalStorage.splice(index, 1);
	// 			console.log('toAddInLocalStorage after splice: ', toAddInLocalStorage);
	// 		}
	// 	});

	// 	localStorage.setItem('blockedEmails', JSON.stringify(toAddInLocalStorage));
	// 	console.log('Local Storage Now::: ', JSON.parse(localStorage.getItem('blockedEmails')));
	// }

	/******************** LIFE-CYCLE HOOKS *******************/

	connectedCallback() {
		console.log('Inside Connected Callback');
		window.addEventListener('beforeunload', this.handleBeforeUnload);
		// this.calculateUserBlockTimeFromSession();
		setTimeout(() => {
			const style = document.createElement('style');
			style.innerText = `
			lightning-base-combobox button.slds-combobox__input.slds-input_faux{
				border: none !important;
				border-bottom: 1px solid !important;
				border-radius: 0px !important;
				background: none !important;

				box-shadow: none !important;
			}
			.slds-combobox__input:focus {
				box-shadow: none !important; 
			}
			lightning-file-upload .slds-file-selector__button.slds-button.slds-button_neutral{
				color:green !important;
			}
			.slds-spinner .slds-spinner__dot-b:after,.slds-spinner .slds-spinner__dot-b:before,.slds-spinner .slds-spinner__dot-a:after,.slds-spinner .slds-spinner__dot-a:before,.slds-spinner_large.slds-spinner:after,.slds-spinner_large.slds-spinner:before{
              background-color: #37a000 !important;
            }
				  `;
			this.template.querySelector('.overrideStyle').appendChild(style);
		}, 100);
	}
	handleBeforeUnload(event) {
		if (this.hasUnsavedChanges) {
			event.returnValue = 'You have unsaved changes! Are you sure you want to leave?';
		}
	}
	renderedCallback() {
		this.setBeforeUnload();
	}
	setBeforeUnload() {
		// Check if the event listener is already added to avoid adding multiple listeners
		if (!this.unloadSet) {
			this.unloadSet = true;

			// Workaround for Locker Service
			window.addEventListener('beforeunload', (event) => {
				if (this.hasUnsavedChanges) {
					event.preventDefault();
					event.returnValue = 'You have unsaved changes! Are you sure you want to leave?';
				}
			});
		}
	}

	disconnectedCallback() {
		window.removeEventListener('beforeunload', this.handleBeforeUnload);
		if (!this.candidateInserted && this.contentVersionId != '') {
			console.log('Deleting Recently Uploaded File');
			deleteRedundantFiles({ cdId: this.contentVersionId }).then((result) => {
				if (result === 'success') {
					console.log('Recent file delted');
				}
			}).catch((error) => {
				console.error(error);
			})
		}
	}


	/******************** SERVICE LISTS *******************/

	// countryStateMap = {
	// 	IN: [
	// 		{ label: 'Andhra Pradesh', value: 'AP' },
	// 		{ label: 'Arunachal Pradesh', value: 'AR' },
	// 		{ label: 'Assam', value: 'AS' },
	// 		{ label: 'Bihar', value: 'BR' },
	// 		{ label: 'Chhattisgarh', value: 'CG' },
	// 		{ label: 'Goa', value: 'GA' },
	// 		{ label: 'Gujarat', value: 'GJ' },
	// 		{ label: 'Haryana', value: 'HR' },
	// 		{ label: 'Himachal Pradesh', value: 'HP' },
	// 		{ label: 'Jharkhand', value: 'JH' },
	// 		{ label: 'Karnataka', value: 'KA' },
	// 		{ label: 'Kerala', value: 'KL' },
	// 		{ label: 'Madhya Pradesh', value: 'MP' },
	// 		{ label: 'Maharashtra', value: 'MH' },
	// 		{ label: 'Manipur', value: 'MN' },
	// 		{ label: 'Meghalaya', value: 'ML' },
	// 		{ label: 'Mizoram', value: 'MZ' },
	// 		{ label: 'Nagaland', value: 'NL' },
	// 		{ label: 'Odisha', value: 'OR' },
	// 		{ label: 'Punjab', value: 'PB' },
	// 		{ label: 'Rajasthan', value: 'RJ' },
	// 		{ label: 'Sikkim', value: 'SK' },
	// 		{ label: 'Tamil Nadu', value: 'TN' },
	// 		{ label: 'Telangana', value: 'TG' },
	// 		{ label: 'Tripura', value: 'TR' },
	// 		{ label: 'Uttar Pradesh', value: 'UP' },
	// 		{ label: 'Uttarakhand', value: 'UK' },
	// 		{ label: 'West Bengal', value: 'WB' },
	// 		{ label: 'Jammu and Kashmir', value: 'JK' }
	// 	],

	// 	US: [
	// 		{ label: 'Alabama', value: 'AL' },
	// 		{ label: 'Alaska', value: 'AK' },
	// 		{ label: 'Arizona', value: 'AZ' },
	// 		{ label: 'Arkansas', value: 'AR' },
	// 		{ label: 'California', value: 'CA' },
	// 		{ label: 'Colorado', value: 'CO' },
	// 		{ label: 'Connecticut', value: 'CT' },
	// 		{ label: 'Delaware', value: 'DE' },
	// 		{ label: 'Florida', value: 'FL' },
	// 		{ label: 'Georgia', value: 'GA' },
	// 		{ label: 'Hawaii', value: 'HI' },
	// 		{ label: 'Idaho', value: 'ID' },
	// 		{ label: 'Illinois', value: 'IL' },
	// 		{ label: 'Indiana', value: 'IN' },
	// 		{ label: 'Iowa', value: 'IA' },
	// 		{ label: 'Kansas', value: 'KS' },
	// 		{ label: 'Kentucky', value: 'KY' },
	// 		{ label: 'Louisiana', value: 'LA' },
	// 		{ label: 'Maine', value: 'ME' },
	// 		{ label: 'Maryland', value: 'MD' },
	// 		{ label: 'Massachusetts', value: 'MA' },
	// 		{ label: 'Michigan', value: 'MI' },
	// 		{ label: 'Minnesota', value: 'MN' },
	// 		{ label: 'Mississippi', value: 'MS' },
	// 		{ label: 'Missouri', value: 'MO' },
	// 		{ label: 'Montana', value: 'MT' },
	// 		{ label: 'Nebraska', value: 'NE' },
	// 		{ label: 'Nevada', value: 'NV' },
	// 		{ label: 'New Hampshire', value: 'NH' },
	// 		{ label: 'New Jersey', value: 'NJ' },
	// 		{ label: 'New Mexico', value: 'NM' },
	// 		{ label: 'New York', value: 'NY' },
	// 		{ label: 'North Carolina', value: 'NC' },
	// 		{ label: 'North Dakota', value: 'ND' },
	// 		{ label: 'Ohio', value: 'OH' },
	// 		{ label: 'Oklahoma', value: 'OK' },
	// 		{ label: 'Oregon', value: 'OR' },
	// 		{ label: 'Pennsylvania', value: 'PA' },
	// 		{ label: 'Rhode Island', value: 'RI' },
	// 		{ label: 'South Carolina', value: 'SC' },
	// 		{ label: 'South Dakota', value: 'SD' },
	// 		{ label: 'Tennessee', value: 'TN' },
	// 		{ label: 'Texas', value: 'TX' },
	// 		{ label: 'Utah', value: 'UT' },
	// 		{ label: 'Vermont', value: 'VT' },
	// 		{ label: 'Virginia', value: 'VA' },
	// 		{ label: 'Washington', value: 'WA' },
	// 		{ label: 'West Virginia', value: 'WV' },
	// 		{ label: 'Wisconsin', value: 'WI' },
	// 		{ label: 'Wyoming', value: 'WY' },
	// 		{ label: 'Puerto Rico', value: 'PR' }
	// 	]
	// }

	// countryOptions = [
	// 	{ label: 'India', value: 'IN' },
	// 	{ label: 'United States', value: 'US' }
	// ];

}