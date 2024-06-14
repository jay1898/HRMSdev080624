import { LightningElement,wire } from 'lwc';
import fetchNotificationData from '@salesforce/apex/AnnouncementController.fetchNotificationData';
import { NavigationMixin } from 'lightning/navigation';
import IMAGE1 from "@salesforce/resourceUrl/AltImage";
export default class DashboardAnnouncement extends NavigationMixin(LightningElement)  {

    latestAnnouncement;
    temp;
    isAnnouncementLoading = false;
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
    }
    fetchAnnouncement() {
        this.noContentAvail = false;
        this.isAnnouncementLoading=true;
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
                    }
                    // Accessing the first record and assigning it to latestAnnouncement
                    this.latestAnnouncement = [result[0]];
                    console.log('this.latestAnnouncement[0]-->>:', this.latestAnnouncement);
                    
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