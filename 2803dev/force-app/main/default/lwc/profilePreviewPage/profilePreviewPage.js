import { LightningElement, api } from 'lwc';
export default class ProfilePreviewPage extends LightningElement {
    @api recordDetails
    PreviewhandleClick(){
        // connectedCallback() {
            console.log(this.recordDetails);
            // setTimeout(() => {
            this.template.querySelector("iframe").contentWindow.postMessage(JSON.stringify(this.recordDetails), '*');
            // }, 0)
        // }
    }
}