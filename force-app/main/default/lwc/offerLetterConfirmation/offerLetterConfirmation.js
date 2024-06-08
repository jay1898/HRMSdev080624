import { LightningElement, wire,track  } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import iTech_logo from '@salesforce/resourceUrl/iTech_logo';
import Link_Expire from '@salesforce/resourceUrl/Link_Expire';
import LatterConfirmation from '@salesforce/resourceUrl/LatterConfirmation';
import facebookFooter from '@salesforce/resourceUrl/facebookFooter';
import twitterFooter from '@salesforce/resourceUrl/twitterFooter';
import skypeFooter from '@salesforce/resourceUrl/skypeFooter';
import linkedInFooter from '@salesforce/resourceUrl/linkedInFooter';
import InstagramFooter from '@salesforce/resourceUrl/InstagramFooter';
import Confirmation_Yes from '@salesforce/resourceUrl/Confirmation_Yes';
import Confirmation_No from '@salesforce/resourceUrl/Confirmation_No';
import acceptOfferLetter from '@salesforce/apex/ApplicationFormController.acceptOfferLetter';
import getExpiredOfferLetterConfirmation from '@salesforce/apex/ApplicationFormController.getExpiredOfferLetterConfirmation';


export default class OfferLetterConfirmation extends LightningElement {
  parameters;
  currentYear;
  showVariable;
  showOfferLetterButtons = false;
  imgMainPage = false;
  showAcceptMsg = false;
  imgSecondPage = true;
  imgThirdPage = true;
  showDeclineMsg = false;
  showModal = false;
  showExpiredLink = false;
  pendingAction = null;
  isLoading = false;
  modalMessage = '';
  headerMessage = '';
  errorMessage = '';

  @track imgURL;
  @track latterURL;
  @track confirmationURL;
  @track confirmationNoURL;
  @track ExpirelinkURL;
  facebookFooterIcon;
  twitterFooterIcon;
  skypeFooterIcon;
  linkedInFooterIcon;
  InstagramFooterIcon;
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.parameters = currentPageReference.state;
      this.showVariable = this.parameters.Variable === "true" ? true : false;
      this.imgSecondPage = false;
      this.imgThirdPage = false;
      this.candidateRecordId = this.parameters.id;

      // Expiration link checking
      getExpiredOfferLetterConfirmation({ candidateId: this.candidateRecordId })
        .then(result => {
          if(result ){
            this.isLoading = false;
            this.showExpiredLink = true;
          }
          else{
          this.isLoading = false;
          this.imgMainPage = true;
          this.showOfferLetterButtons = true;
          }
        })
        .catch(error => {
          console.error('Error:', error);
      });
    }
  }

  handleOfferLetter(event) {
    // Store the user's decision and show the modal
    this.pendingAction = event.currentTarget.getAttribute('data-action');
    if (this.pendingAction === 'accept') {
      this.headerMessage = 'Offer Acceptance Confirmation';
      this.modalMessage = 'Are you sure you wish to accept this Confirmation?';
    } else if (this.pendingAction === 'reject') {
      this.headerMessage = 'Offer Rejection Confirmation';
      this.modalMessage = 'Are you sure you want to reject this offer confirmation?';
    }
    this.showModal = true;
  }

  handleModalAction(event) {
    const action = event.currentTarget.getAttribute('data-action');

    // Hide the modal
    this.showModal = false;

    if (action === 'confirm') {
      this.processDecision(this.pendingAction);
    } else {
      this.pendingAction = null;
    }
  }

  processDecision(decision) {
    acceptOfferLetter({ candidateId: this.candidateRecordId, action: decision })
      .then(result => {
        if (result === false) {
          this.showToast('Error', 'You have already submitted your response.', 'Error');
          return;  // Exit out early
        }

        if (decision === 'accept') {
            this.isLoading = false;
          this.showOfferLetterButtons = false;
          this.showAcceptMsg = true;
          this.imgMainPage =false;
          this.imgSecondPage = true;
        } else if (decision === 'reject') {
            this.isLoading = false;
          this.showOfferLetterButtons = false;
          this.showDeclineMsg = true;
          this.imgMainPage = false;
          this.imgSecondPage = false;
          this.imgThirdPage = true;
        }

      })
      .catch(error => {
        if (error && error.body) {
          this.errorMessage = error.body.message;
          console.error('error', error);
        } else {
          this.showToast('Error', error.body.message, 'error');
        }
      });
  }
  connectedCallback() {
    this.isLoading = true;
     this.currentYear = new Date().getFullYear();
    setTimeout(() => {
      const style = document.createElement('style');
      style.innerText = `
          .slds-spinner .slds-spinner__dot-b:after,.slds-spinner .slds-spinner__dot-b:before,.slds-spinner .slds-spinner__dot-a:after,.slds-spinner .slds-spinner__dot-a:before,.slds-spinner_large.slds-spinner:after,.slds-spinner_large.slds-spinner:before{
              background-color: #37a000 !important;
            }
				  `;
      this.imgURL = iTech_logo;
      this.ExpirelinkURL = Link_Expire;
      this.latterURL = LatterConfirmation;
      this.facebookFooterIcon = facebookFooter;
      this.twitterFooterIcon = twitterFooter;
      this.skypeFooterIcon = skypeFooter ;
      this.linkedInFooterIcon = linkedInFooter ; 
      this.InstagramFooterIcon = InstagramFooter ;
      this.confirmationURL = Confirmation_Yes;
      this.confirmationNoURL = Confirmation_No
      this.template.querySelector('.overrideStyle').appendChild(style);
    }, 100);
  }
  showToast(mTitle, mMessage, mVariant) {
    const event = new ShowToastEvent({
      title: mTitle,
      message: mMessage,
      variant: mVariant,
      mode: 'pester'
    });
    // this.imgURL = iTechlogo;
    this.dispatchEvent(event);
  }
}