import { LightningElement, track } from 'lwc';

export default class UploadCertificate extends LightningElement {
    selectedValue = '';

    @track certificateOptions = [
        { label: 'Omnistudio', value: 'Omnistudio'}, 
            { label: 'Admin', value: 'Admin'}, 
            { label: 'Pd-I', value: 'Pd-I'}, 
            { label: 'Pd-II', value: 'Pd-II'}
    ];
   

    get getCertificateList() {
        return JSON.parse(JSON.stringify(this.certificateOptions));
    }
    onNavigateToExperiencePage(){
        this.dispatchEvent(
            new CustomEvent('experiencepage', {
                detail: {
                    'experiencePage': true
                }
            })
        )
    }

    handleCertificateListChange(evnet){

    }

    onBack(){
        this.dispatchEvent(
            new CustomEvent('backtoskillpage', {
                detail: {
                    'skillPage': true,
                }
            })
        )
    }
}