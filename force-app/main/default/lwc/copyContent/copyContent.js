import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import copyRecord from '@salesforce/apex/PositionOpeningController.copyRecords';

export default class CopyContent extends LightningElement {
    @api recordId;

    handleCopy() {
        copyRecord({ recordId: this.recordId })
            .then(result => {
                // Copy the result to the clipboard
                this.copyToClipboard(result);
                this.showToast('Success', 'Record copied to clipboard', 'success');
            })
            .catch(error => {
                console.error('Error copying record:', error);
                this.showToast('Error', 'Error copying record', 'error');
            });
    }

    copyToClipboard(text) {
        const textarea = document.createElement('textarea');
        textarea.value = text;
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}