import { LightningElement,wire,track,api } from 'lwc';
import wordlib from '@salesforce/resourceUrl/WordTemplate';
import { loadScript } from 'lightning/platformResourceLoader';
import { getRecord,createRecord } from 'lightning/uiRecordApi';
const FIELDS = ['ContentVersion.Id', 'ContentVersion.Title', 'ContentVersion.VersionData'];
export default class ResumeBuilder extends LightningElement {
		@track contentVersionId;
		@api profileContentVersionId='0681e000001bTjxAAE';
		@api profileData ={};
        currentProfileData = {};
		
		@wire(getRecord, { recordId: '$profileContentVersionId', fields: FIELDS })
        wiredContentVersionProfile({ error, data }) {
            if (data) {
                this.contentVersion = { data };
                this.error = undefined;
                            this.profileImageResponse = this.contentVersion.data.fields.VersionData.value;
                            this.currentProfileData.ProfileImage=this.profileImageResponse;
            } else if (error) {
                this.contentVersion = { error: error.body.message };
                this.error = error;
            }
        }

		connectedCallback() {
            this.currentProfileData=JSON.parse(JSON.stringify(this.profileData));
            console.log('currentProfileData#####',this.currentProfileData);
		}
		
		 handleResumeTemplateChange(event) {
        const eventData = event.detail;
				this.contentVersionId=eventData;
        console.log('Data received from child:', eventData);
        // Do something with the data received from the child component
    }
		
}