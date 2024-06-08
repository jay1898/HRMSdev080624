import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import acceptOfferLetter from '@salesforce/apex/ApplicationFormController.acceptOfferLetter';
export default class ConfirmingOfferLetter extends LightningElement {

    parameters;
    showVariable;
    showOfferLetterButtons = true;
    showAcceptMsg = false;
    showDeclineMsg = false;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.parameters = currentPageReference.state;
            console.log('@@parameters::', this.parameters);
            // this.showConfirmation = this.parameters.Confirmation === "false" ? false : true;
            this.showVariable = this.parameters.Variable === "true" ? true : false;
            this.candidateRecordId = this.parameters.id;
        }
    }
    handleOfferLetter(event){
        // this.showOfferLetterData = true;
        const action = event.currentTarget.getAttribute('data-action');
        acceptOfferLetter({ candidateId: this.candidateRecordId, action: action })
          .then(result => {
            if (result === false) {
              this.showToast('Error', 'You have already submitted your response.', 'Error');
              return;  // Exit out early
          }
    
            if (action == 'accept') {
              // this.showFinalSubmit = true;
              // this.showConfirmation = false;
              // this.showDescriptionOfConfirmation = false;
              // this.showNoSubmit = false;
              
              this.showOfferLetterButtons = false;
              this.showAcceptMsg = true;
              console.log('in accept');
              this.showToast('Success', 'Offer Accept', 'Success');
              console.log('result on submitting', result); //  true
            } else if(action == 'reject'){
              // this.showNoSubmit = true;
              // this.showFinalSubmit = false;
              // this.showDescriptionOfConfirmation = false;
              this.showOfferLetterButtons = false;
              this.showDeclineMsg = true;
              console.log('in reject');
              this.showToast('Info', 'Reject !!Thanks for letting us know', 'info');
            }
    
          })
          .catch(error => {
            if (error) {
                console.error('error',error);
              // this.showExpiredLink = true;
              // this.showDescriptionOfConfirmation = false;
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