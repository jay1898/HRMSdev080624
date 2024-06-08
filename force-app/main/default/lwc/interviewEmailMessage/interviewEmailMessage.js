import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class InterviewEmailMessage extends LightningElement {
    @api defaultemailBody;
    @api updatedDefaultEmailBody;

    connectedCallback() {
        console.log('connectedCallback > recieved defaultemailBody', this.defaultemailBody);
    }

    handleRichTextChange(event) {
        console.log('onChange > RichText: ', event.target.value);
        // Update the defaultemailBody when the content changes
        this.defaultemailBody = event.target.value;
        // this.convertToHtml();
        this.dispatchEvent(new FlowAttributeChangeEvent('updatedDefaultEmailBody', this.defaultemailBody));
        console.log('defaultemailBody', this.defaultemailBody);
    }

}