import { LightningElement, api, track } from 'lwc';
import IMAGES from "@salesforce/resourceUrl/iTechlogo";
import getEployeeRole  from '@salesforce/apex/timesheetTableController.getEployeeRole';
export default class VerticalNavigationBar extends LightningElement {
    rolePM = false;
    @api recordId;
    iTechlogo = IMAGES;

    mobileView = false;
    @track windowWidth;

    connectedCallback() {

        // this.rolePM = false;
        getEployeeRole()
            .then((data) => {
                const PMData = data;
                console.log('PMData role of project manager -->', PMData);
                this.rolePM = data.some(employee => employee.Role__c === "Project Manager" && employee.Id === this.recordId);

                console.log('data role of project manager -->', this.recordId);
            })
            .catch((error) => {
                console.error('Handle error in getProjects', error);
            });


        const style = document.createElement('style');
        style.innerText = `
                    lightning-vertical-navigation-item-icon a:hover {
                        color:green !important;
                        background: rgba(222, 245, 228, 1);
                        box-shadow: none !important;
                    }
                    .slds-nav-vertical__item.slds-is-active .slds-nav-vertical__action {
                        width: auto;
                        background: rgba(222, 245, 228, 1);
                        box-shadow: none !important;
                        color:green !important;
                        width:100%;
                    }
                    .slds-nav-vertical__item:hover:before, .slds-nav-vertical__item.slds-is-active:before {
                        box-shadow: none;
                        background: transparent;
                    }
                    .slds-nav-vertical__item:hover:after, .slds-nav-vertical__item.slds-is-active:after {
                        box-shadow: none;
                        background: transparent;
                    }
                    .slds-nav-vertical__action {
                        display: inline-block !important;
                        
                    }
                    *:before {
                        box-sizing: content-box !important;
                    }
                    *:after {
                        box-sizing: content-box !important;
                    }
                    lightning-avatar .slds-avatar {
                        display: unset !important;
                    }
                    lightning-avatar img {
                        border-radius: 50%;
                    }
                    `;
        setTimeout(() => {
            this.template.querySelector('.overrideStyle').appendChild(style);
        }, "0");

        this.handleMobileView();

    }

    handleMobileView(){
        // console.log('mobile view -------------------------------------------------------------------------------------->');
        this.windowWidth = window.innerWidth;
        if(this.windowWidth < 480){
            // console.log('width size true----------------------------------------------------------------------------->', this.windowWidth);
            this.mobileView = true;

            const style = document.createElement('style');
        style.innerText = `
                    
                    .slds-nav-vertical__item.slds-is-active .slds-nav-vertical__action {
                        width: auto;
                        background: rgba(222, 245, 228, 1);
                        box-shadow: none !important;
                        color:green !important;
                        width:100%;
                        padding-top: 12px;
                        padding-bottom: 12px;
                    }

                    .slds-nav-vertical__action {
                        display: inline-block !important;
                        padding-top: 12px;
                        padding-bottom: 12px;
                    }
                    
                    `;
        setTimeout(() => {
            this.template.querySelector('.overrideStyle').appendChild(style);
        }, "0");

        //     setTimeout(() => {
        //         const style = document.createElement('style');
        //         style.innerText = ` 

        //             .ComponentChangeClass textarea:focus {
        //                 height: 200px; 
        //                 width: 100%;
        //             }
        //             .TaskDescriptionClass  textarea:focus {
        //                 height: 200px; 
        //                 width: 100%;
        //             }

        //             lightning-datepicker .slds-form-element__label{
        //                 display:none !important;
        
        //             }
        //             lightning-input .slds-form-element__label{
        //                 display:none !important;
        
        //             }
        //             lightning-select .slds-form-element{
        //                 padding-right: 0px;
        //             }
                    
        //             .datePickerBlock .slds-input {
        //                 cursor: pointer;
        //                 border: none;
        //                 background: none;
        //                 font-weight: bold;
        //                 font-size: 16px;
        //                 color: rgb(0, 161, 41);
        //                 padding: 0px;
        //             }

        //             .datePickerBlock .slds-input {
        //                 cursor:pointer;
        //            }

                    
        //         `;
        //     this.template.querySelector('.overrideStyle').appendChild(style);
                
        // }, 100);
            
        }
        else{
            // console.log('width size false----------------------------------------------------------------------------->', this.windowWidth);
            this.mobileView = false;
        }
    }

    handleLogOutClick() {
        const logout = new CustomEvent("logout", {
            // detail: event.target.dataset.day
        });
        this.dispatchEvent(logout);
    }

    handleClick(event) {
        if (event.target.name == 'requestDetails') {
            const requestDetailsClick = new CustomEvent("leftpanelactionbuttonclick", {
                detail: { actionbutton: 'requestDetails', value: true }
            });
            this.dispatchEvent(requestDetailsClick);
        }

        if (event.target.name == 'Dashboard') {
            const requestDetailsClick = new CustomEvent("leftpanelactionbuttonclick", {
                detail: { actionbutton: 'dashboard', value: true }
            });
            this.dispatchEvent(requestDetailsClick);
        }
        if (event.target.name == 'Ticket_History') {
            const ticketHistoryClick = new CustomEvent("leftpanelactionbuttonclick", {
                detail: { actionbutton: 'Ticket_History', value: true }
            });
            this.dispatchEvent(ticketHistoryClick);
        }
        if (event.target.name == 'pmddReportDetails') {
            const requesReportClick = new CustomEvent("leftpanelactionbuttonclick", {
                detail: { actionbutton: 'pmddReportDetails', value: true }
            });
            this.dispatchEvent(requesReportClick);
        }

        if (event.target.name == 'myProfile') {
            console.log('in verticle navigation bar');
            const myProfileClick = new CustomEvent("leftpanelactionbuttonclick", {
                detail: { actionbutton: 'myProfile', value: true }
            });
            this.dispatchEvent(myProfileClick);
            console.log('in verticle navigation bar @@@   after event');
        }

        if (event.target.name == 'myDashboard') {
            const requestDashboardClick = new CustomEvent("leftpanelactionbuttonclick", {
                detail: { actionbutton: 'myDashboard', value: true }
            });
            this.dispatchEvent(requestDashboardClick);
        }

        if (event.target.name == 'attendance'){
            // console.log('In Attendance');
            const attendanceClick = new CustomEvent("leftpanelactionbuttonclick", {
                detail: { actionbutton: 'attendance', value: true }
            });
            this.dispatchEvent(attendanceClick);
        }
        
        if (event.target.name == 'announcement'){
            console.log('In announcement');
            const announcementClick = new CustomEvent("leftpanelactionbuttonclick", {
                detail: { actionbutton: 'announcement', value: true }
            });
            this.dispatchEvent(announcementClick);
            console.log('in verticle navigation bar @@@   after annoucemetn tav');
        }

        if (event.target.name == 'reportsheet'){
            console.log('In reportsheet');
            const reportsheetClick = new CustomEvent("leftpanelactionbuttonclick", {
                detail: { actionbutton: 'reportsheet', value: true }
            });
            this.dispatchEvent(reportsheetClick);
            console.log('in verticle navigation bar @@@   after reportsheet tav');
        }

        if (event.target.name == 'skillMatrix'){
            console.log('In skillMatrix');
            const skillMatrixClick = new CustomEvent("leftpanelactionbuttonclick", {
                detail: { actionbutton: 'skillMatrix', value: true }
            });
            this.dispatchEvent(skillMatrixClick);
            console.log('in verticle navigation bar @@@   after skillMatrix tav');
        }
    }
}