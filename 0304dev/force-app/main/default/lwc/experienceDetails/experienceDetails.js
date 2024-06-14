import { LightningElement,track } from 'lwc';
export default class ExperienceDetails extends LightningElement {

    // myVal = '<strong>Hello!</strong>';

    @track employerValue = '';
    @track jobTitleValue = '';
    @track startDateValue = null;
    @track endDateValue = null;

    handleEmployerChange(event) {
        this.employerValue = event.target.value;
    }

    handleJobTitleChange(event) {
        this.jobTitleValue = event.target.value;
    }

    handleStartDateChange(event) {
        this.startDateValue = event.target.value;
    }

    handleEndDateChange(event) {
        this.endDateValue = event.target.value;
    }

    handleChange(event) {
        // this.myVal = event.target.value;
    }

    onNavigateToSummaryPage(){
        this.dispatchEvent(
            new CustomEvent('summarypage', {
                detail: {
                    'summaryPage': true
                }
            })
        )
    }
    onBack(){
        this.dispatchEvent(
            new CustomEvent('backtocertificatepage', {
                detail: {
                    'certificatePage': true,
                }
            })
        )
    }
}