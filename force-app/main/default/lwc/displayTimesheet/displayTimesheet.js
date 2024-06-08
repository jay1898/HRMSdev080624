import { LightningElement, track, api, wire } from 'lwc';
import getTimesheetDetails from '@salesforce/apex/DisplayTimesheetController.getTimesheetDetails';

export default class DisplayTimesheet extends LightningElement {
		
		@track timeSheetRecords=[];
		connectedCallback() {
				getTimesheetDetails({})
				.then(result => {
						console.log('Result :: ',result);
						this.timeSheetRecords=result;
				})
				.catch(error => {
						console.error('Error fetching isHideAdd__c Field Value:', error);
				});
		}
		
}