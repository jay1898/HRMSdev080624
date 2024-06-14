import { LightningElement, track, wire } from 'lwc';
import getResumeTemplate from '@salesforce/apex/ResumeBuilderController.getResumeTemplate';

export default class ResumeBuilderLeftPanel extends LightningElement {
	@track templates = [];
	@track contentVersion;
	spinner = true;
	
	selectedContentId = '0681s000002WknfAAC';
	connectedCallback() {
		// this.images = [
		// 		{ id: '0681s000002WgdyAAC', base64Data: 'data:image/jpeg;base64,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' },
		// 		{ id: '0681s000002Wge3AAC', base64Data: 'data:image/jpeg;base64,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' },
		// 		{ id: '0681s000002WhKEAA0', base64Data: 'data:image/jpeg;base64,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' }		
		// 		Add more image data as needed
		// ];
		this.getResumeTemplateDetails();
	}


	getResumeTemplateDetails() {
		getResumeTemplate()
			.then(result => {
				//console.log('@result ', result);
				this.templates = JSON.parse(result);
				this.spinner = false;
				console.log('Template data@@@', result);
				// if (this.templates.length > 0) {
				// 	this.sendDataToParent(this.templates[0].templateDocumentId);
				// }
			})
			.catch(error => {
				console.error('Error data:', error);
			});
	}

	handleImageClick(event) {
		console.log('@@')
		this.selectedContentId = event.currentTarget.dataset.id;
		console.log("selectedContentId######", this.selectedContentId);
		this.sendDataToParent(this.selectedContentId);
	}

	sendDataToParent(contentVersionId) {
		const event = new CustomEvent('sendtemplateid', { detail: contentVersionId });
		this.dispatchEvent(event);
	}

}