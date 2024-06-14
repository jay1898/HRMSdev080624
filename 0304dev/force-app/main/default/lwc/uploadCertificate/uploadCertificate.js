import { LightningElement } from 'lwc';

export default class UploadCertificate extends LightningElement {
    
    skillPage = false;
    certificatePage = true;
    experiencePage = false;
    

    onNavigateToExperiencePage(){
        this.dispatchEvent(
            new CustomEvent('nextpage', {
                detail: {
                    'experiencePage': true,
                }
            })
        )
    }

    onBack(){
        this.skillPage = true;
        this.certificatePage = false;
        this.progressValue = 20
    }
}