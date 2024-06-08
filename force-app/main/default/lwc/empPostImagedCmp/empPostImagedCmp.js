import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import getContentVersionData from '@salesforce/apex/AnnouncementController.getContentVersionData';
const FIELDS = ['ContentVersion.Id', 'ContentVersion.Title', 'ContentVersion.VersionData'];

export default class EmpPostImagedCmp extends LightningElement {

    @api contentVersionId;
    @api imageType;
    contentData;
    base64StringResponse;
    contentVersion;
    error;
    isUploading = true;
    isProfilePic = false;
    isPostPic = false;


    @wire(getContentVersionData, { contentVersionId: '$contentVersionId' })
    wiredContentVersion({ error, data }) {
        //console.log('data-->>', data);
        if (data) {
            this.contentVersion = { data };
            //console.log('this.contentVersion-->>', this.contentVersion);
            this.error = undefined;
			this.base64StringResponse = this.contentVersion.data.VersionData;
            this.isUploading = false;
            if(this.imageType == "Post"){
                this.isPostPic = true;
                this.isProfilePic = false;
            }else{
                this.isProfilePic = true;
                this.isPostPic = false;
            }
						
        } else if (error) {
            this.isUploading = true;
            this.error = error;
            console.log('this.error',this.error);
        }
    }

}