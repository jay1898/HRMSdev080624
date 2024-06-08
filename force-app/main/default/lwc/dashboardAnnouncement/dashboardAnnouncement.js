import { LightningElement,wire } from 'lwc';
import fetchNotificationData from '@salesforce/apex/AnnouncementController.fetchNotificationData';
import { NavigationMixin } from 'lightning/navigation';
import IMAGE1 from "@salesforce/resourceUrl/AltImage";
export default class DashboardAnnouncement extends NavigationMixin(LightningElement)  {

    latestAnnouncement;
    temp;
    isAnnouncementLoading = true;
    noContentAvail = false;
    altImages = IMAGE1;

    // @wire(fetchNotificationData, { recordType: 'Announcement' })
    // fetchNotificationData({ error, data }) {
    //   if (data) {
    //     this.latestAnnouncement = [data[0]];
    //     console.log('fetchNotificationData Data', this.latestAnnouncement);
    //   } else if (error) {
    //      console.error('Error:', error);
    //   }
    // }
    connectedCallback() {
        this.fetchAnnouncement();
        setTimeout(() => {

            const style = document.createElement('style');
            style.innerText = `
			.slds-spinner .slds-spinner__dot-b:after,.slds-spinner .slds-spinner__dot-b:before,.slds-spinner .slds-spinner__dot-a:after,.slds-spinner .slds-spinner__dot-a:before,.slds-spinner_large.slds-spinner:after,.slds-spinner_large.slds-spinner:before,.slds-spinner_medium.slds-spinner:after,.slds-spinner_medium.slds-spinner:before{
              background-color: #37a000 !important;
            }
				  `;
            this.template.querySelector('.overrideStyle').appendChild(style);
        }, 100);
    }
    fetchAnnouncement() {
        this.noContentAvail = false;
        //this.isAnnouncementLoading=false;
       console.log('fetchNotificationData:');
        fetchNotificationData({ recordType: 'Announcement', limits:1 })
            .then(result => {
                // console.log('result[0]-->>:', result[0]);
                // this.latestAnnouncement[0] =  result;
                // this.temp = this.latestAnnouncement[0];
                // console.log('this.temp this.temp0]-->>:', this.temp);

                // console.log('this.latestAnnouncement-->>', JSON.parse(JSON.stringify(this.latestAnnouncement)));
                if (result && result.length > 0) {
                    if(!result[0].hasOwnProperty('Profile_Photo')){
                        result[0].Profile_Photo = this.altImages;
                        this.isAnnouncementLoading=false;
                    }
                    // Accessing the first record and assigning it to latestAnnouncement
                    this.latestAnnouncement = [result[0]];
                    console.log('this.latestAnnouncement[0]-->>:', this.latestAnnouncement);
                    this.isAnnouncementLoading=false;
                    
                }else{
                    this.noContentAvail = true;
                }
                this.isAnnouncementLoading=false;
            })
            .catch(error => {
                this.error = error;
                console.error('Error in fetching record data:', error);
            });
       
    }
     handleView(event) {
        // Navigate to the new LWC component
        const announcementClick = new CustomEvent("announcementredirect", {
                detail: { actionbutton: 'announcement', value: true }
            });
            this.dispatchEvent(announcementClick);
    }
}