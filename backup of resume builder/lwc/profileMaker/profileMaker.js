import { LightningElement, wire, track } from 'lwc';
import getRecordIds from '@salesforce/apex/ProfileBuilderController.getRecordIds';
import getEmployeeNames from '@salesforce/apex/ProfileBuilderController.getEmployeeNames';
import getVFOrigin from '@salesforce/apex/ProfileBuilderController.getVFOrigin';

export default class ProfileMaker extends LightningElement {
    @track imageUrls;
    @track selectedItemId;
    @track showCheck = false;
    @track fullProfileJson = {};
    @track isfirstpage = true;
    // @track isTemplateSelected = false;
    @track isTemplateSelected = true;
    @track isButtonVisible = false;
    @track employeeOptions = [];
    @track value;
    @track loadVfpage = false;
    @track progressValue = 25;
    @track fullDataJson = {
        name: "Mahi",
        last_name: "sahu",
        phone: "0652455478",
        description: "New Website",
        ProfileImage: "{!URLFOR($Resource.sampleImage)}",
        professionalSummary: [
            { desc: "Overall, 12 years of IT experience in Software Design, Development of various client/server and web-based Enterprise Applications using different tools and technologies." },
            { desc: "10 years of experience with Salesforce in Creating Roles, Profiles, Email Services, Page Layouts, Workflow Alerts and Actions, Flow and Approval Workflow." },
            { desc: "Good knowledge of OOPs (Abstraction, Encapsulation, Inheritance and Polymorphism) and design concepts" },
            { desc: "Hands on experience in salesforce.com CRM integration, developing and deploying custom integration solutions." },
            { desc: "Experience in working on Sales Cloud, Service Cloud as well as Community Cloud." },
            { desc: "Experience in working with HTML, CSS, Bootstrap, JavaScript, jQuery, and Ajax." },
            { desc: "Experience in AGILE/Scrum Methodology." },
            { desc: "Extensive experience in developing Apex Classes, Triggers, Visual force pages, writing Workflows, Force.com API, test classes, Flow, Lightning aura component and LWC" },
            { desc: "Extensive experience in lead, case management, web-to-lead, Web-to case, Email-to-case." },
            { desc: "Proficient in Data Migration from Traditional Applications to Salesforce using Import Wizard and Data Loader Utility and currently use Salesforce Inspector extension." },
            { desc: "Used Salesforce Explorer to select data and to test in SOQL and search in SOSL." },
            { desc: "Experience with IDE tools Eclipse, Visual Studio, Ant, Git hub, JIRA." },
            { desc: "Integrated Salesforce with external applications using Force.com APIs (SOAP and REST) and developed Salesforce apex SOAP and REST web service classes. Experience working on XML and JSON formats also by creating Parsers, also worked on salesforce rest resources for calling webhooks and  client credential flow for calling SF Standard APIs." }
        ]
    }
    // Wire getVFOrigin Apex method to a Property
    @wire(getVFOrigin)
    vfOrigin;

    connectedCallback() {
        this.getMdtRecords();
        this.getEmployeeDetails();

    }

    getMdtRecords() {
        getRecordIds()
            .then(result => {
                console.log('result ', result);
                this.imageUrls = result;
            })
            .catch(error => {
                console.error('Error fetching Timesheet data:', error);
            });
    }

    getEmployeeDetails() {
        getEmployeeNames()
            .then(result => {
                console.log('@result ', result);
                this.employeeOptions = result.map(employee => ({ label: employee.Name, value: employee.Name }));
            })
            .catch(error => {
                console.error('Error fetching Timesheet data:', error);
            });
    }

    templateSelected(event) {
        const clickedItemId = event.currentTarget.dataset.itemId;
        console.log('clickedItemId ', clickedItemId);
        this.selectedItemId = clickedItemId;

        this.imageUrls = this.imageUrls.map(item => ({
            ...item,
            showCheck: item.Template_Name__c === clickedItemId
        }));
        this.fullProfileJson = {
            "selectedTemplate": clickedItemId
        }
        this.isButtonVisible = true;
    }

    handleClickNext(event) {
        const page = event.target.dataset.id;
        if (page == '1') {
            this.isfirstpage = false;
            this.isTemplateSelected = true;

        }
        if (page == '2') {
            this.loadVfpage = true;
            this.isTemplateSelected = false;

            // let message = JSON.stringify(this.fullDataJson);
            // let message = 'test';
            // this.template.querySelector("iframe").contentWindow.postMessage(message, '*');
            // Use setTimeout to ensure the iframe is rendered
            // setTimeout(() => {
            //     const vfIframe = this.template.querySelector('iframe');
            //     if (vfIframe) {
            //         vfIframe.contentWindow.postMessage(message, '*');
            //     }
            // }, 0);
            // this.template.querySelector("#profileBuilderPage").contentWindow.postMessage(message, '*');
        }
    }

    handleClickBack() {
        this.isTemplateSelected = false;
    }

    handleChange(event) {
        this.value = event.detail.value;

    }

    progressHandleClick(event){
        console.log('progress button click ',event.target.dataset.msg);
        this.progressValue = event.target.dataset.msg;
    }
}