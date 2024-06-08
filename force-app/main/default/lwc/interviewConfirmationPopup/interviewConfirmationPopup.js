import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import iTech_logo from '@salesforce/resourceUrl/iTech_logo';
import Link_Expire from '@salesforce/resourceUrl/Link_Expire';
import Interview_Yes from '@salesforce/resourceUrl/Interview_Yes';
import Interview_No from '@salesforce/resourceUrl/Interview_No';
import facebookFooter from '@salesforce/resourceUrl/facebookFooter';
import twitterFooter from '@salesforce/resourceUrl/twitterFooter';
import skypeFooter from '@salesforce/resourceUrl/skypeFooter';
import linkedInFooter from '@salesforce/resourceUrl/linkedInFooter';
import InstagramFooter from '@salesforce/resourceUrl/InstagramFooter';
import getCandidateData from '@salesforce/apex/ApplicationFormController.getInterviewConfirmedCandidateDetails';
import updateRecord from '@salesforce/apex/ApplicationFormController.setInterviewConfirmed';
export default class InterviewConfirmationPopup extends LightningElement {
  currentYear;
  parameters;
  candidateRecordId;
  fullname;
  role;
  interviewDate;
  @track selectedValue;
  @track imageURL;
  @track ExpirelinkURL;
  @track InterviewYesURL;
  @track InterviewNoURL;
  facebookFooterIcon;
  twitterFooterIcon;
  skypeFooterIcon;
  linkedInFooterIcon;
  InstagramFooterIcon;
  formattedDate = {};
  errorMessage = '';

  showExpiredLink = false;
  showFinalSubmit = false;
  showNoSubmit = false;
  showDescriptionOfConfirmation = true;
  isDataLoding = true;

  connectedCallback() {
    // display: block;
    // margin-right: 20px; 
    this.currentYear = new Date().getFullYear();
    setTimeout(() => {
      const style = document.createElement('style');
      style.innerText = `
            lightning-radio-group .slds-form-element__legend.slds-form-element__label {
              font-size: 20px;
            }
            lightning-radio-group .slds-form-element__control {
                text-align:left;
            }
            lightning-radio-group .slds-form-element__control .slds-radio{
              display: inline;
            }
            .slds-spinner .slds-spinner__dot-b:after,.slds-spinner .slds-spinner__dot-b:before,.slds-spinner .slds-spinner__dot-a:after,.slds-spinner .slds-spinner__dot-a:before,.slds-spinner_large.slds-spinner:after,.slds-spinner_large.slds-spinner:before{
              background-color: #37a000 !important;
            }
            `;
      this.template.querySelector('.overrideStyle').appendChild(style);
      this.imgURL = iTech_logo;
      this.ExpirelinkURL = Link_Expire;
      this.InterviewYesURL = Interview_Yes;
      this.InterviewNoURL = Interview_No;
      this.facebookFooterIcon = facebookFooter;
      this.twitterFooterIcon = twitterFooter;
      this.skypeFooterIcon = skypeFooter ;
      this.linkedInFooterIcon = linkedInFooter ; 
      this.InstagramFooterIcon = InstagramFooter ;
    }, 100);
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.parameters = currentPageReference.state;
      console.log('@@parameters::', this.parameters);
      //   this.showConfirmation = this.parameters.Confirmation === "false" ? false : true;
      //   this.showVariable = this.parameters.Variable === "true" ? true : false ; 
      this.candidateRecordId = this.parameters.id;
      getCandidateData({ CandidateId: this.candidateRecordId }).then((result) => {
        if (result) {
          console.log('Data are:::____:::', result);
          this.fullname = result[0].Full_Name__c;
          this.role = result[0].Candidate_Role__c;
          this.interviewDate = new Date(result[0].Interview_Date__c);
          console.log('data', result);

          console.log('interviewDate', this.interviewDate);

          let hour = this.interviewDate.getHours();
          let ampm = hour >= 12 ? 'PM' : 'AM';
          hour = hour % 12;
          hour = hour || 12;  // the hour '0' should be '12'  

          this.formattedDate['year'] = this.interviewDate.getFullYear();
          this.formattedDate['month'] = this.interviewDate.getMonth();
          this.formattedDate['date'] = this.interviewDate.getDate();
          this.formattedDate['hour'] = hour;
          this.formattedDate['minutes'] = String(this.interviewDate.getMinutes()).padStart(2, '0');
          this.formattedDate['ampm'] = ampm;

          console.log('Date Full Year', this.formattedDate);
          this.isDataLoding = false;

        } else {
          console.log('Error : ', result);
        }
      }).catch((error) => {
        if (error.body.message === 'Your link has already expired.') {
          this.showExpiredLink = true;
          this.showFinalSubmit = false;
          this.isDataLoding = false;
          this.showDescriptionOfConfirmation = false;
          // this.showToast('Error', 'Your link has already expired.', 'error');
        } else {
          console.error(error);
          // this.showToast('Error', error.body.message, 'error'); // giving error when uncommented
        }
        // console.error(error);
        // this.showToast('Error', error.body.message, 'error');
      })
    }
  }
  get options() {
    return [
      { label: 'Yes', value: 'true' },
      { label: 'No', value: 'false' },
    ];
  }
  handleRadioChange(event) {
    this.selectedValue = event.detail.value === 'true';
    console.log('SelecteD Value in checkbox', this.selectedValue);
  }

  handleSubmitClick() {
    if (!this.selectedValue && this.selectedValue !== false) {
      this.errorMessage = 'Please choose Yes or No for interview confirmation.';
      return; // Exit the function
    }
    updateRecord({ candidateId: this.candidateRecordId, isConfirmed: this.selectedValue })
      .then(result => {
        if (this.selectedValue) {
          this.showFinalSubmit = true;
          this.showConfirmation = false;
          this.showDescriptionOfConfirmation = false;
          this.showNoSubmit = false;
          this.showToast('Success', 'Confirmed Interview', 'Success');
          console.log('result on submitting', result);
        } else {
          this.showNoSubmit = true;
          this.showFinalSubmit = false;
          this.showDescriptionOfConfirmation = false;
          this.showToast('Info', 'Thanks for letting us know', 'info');
        }

      })
      .catch(error => {
        if (error.body.message === 'Your link has already expired.') {
          this.showExpiredLink = true;
          this.showFinalSubmit = false;
          this.showDescriptionOfConfirmation = false;
        } else {
          this.showToast('Error', error.body.message, 'error');
        }

        // console.error("Error updating record", error);
        // Handle error, maybe display a toast message
      });

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


}