import { LightningElement, track } from 'lwc';
import bootstrap from "@salesforce/resourceUrl/Bootstrap";
import {loadStyle,loadScript} from 'lightning/platformResourceLoader';
import IMAGES from "@salesforce/resourceUrl/iTechlogo";


export default class ProfileHeader extends LightningElement {

    iTechlogo = IMAGES;
    progressValue = 20;
    skillPage = true;
    certificatePage = false;
    footerButtonOnSkilPage = true;

    connectedCallback(){
        const style = document.createElement('style');
                    style.innerText = `
                        lightning-progress-bar .slds-progress-bar__value {
                            background-color: green;
                        }
                    `;
                     setTimeout(() => {
                        this.template.querySelector('.overrideStyle').appendChild(style);
                    }, 200);
    }

    // renderedCallback(){
    //     Promise.all([
    //         loadScript(this, bootstrap + '/bootstrap/js/bootstrap.js'),
    //         loadStyle(this, bootstrap + '/bootstrap/css/boorstrap.min.css')
    //     ])
    //     .then(() => {
    //         console.log("Bootstrap Working Fine");
    //     })  
    // }

    progressHandleClick(event){
        console.log('progress button click ',event.target.dataset.msg);
        this.progressValue = event.target.dataset.msg;
    }
    onNavigateToCertificatePage(){
        console.log("unde navigation");
        this.skillPage = false;
        this.certificatePage = true;
        this.footerButtonOnSkilPage = false;
        this.progressValue = 40
    }
    onBack(){
        this.skillPage = true;
        this.certificatePage = false;
        this.progressValue = 20
    }

    get getProgressValue(){
        return this.progressValue;
    }
}