import { LightningElement, wire, track ,api} from 'lwc';
import IMAGES from "@salesforce/resourceUrl/iTechlogo";
import getRecordIds from '@salesforce/apex/ProfileBuilderController.getRecordIds';
import getEmployeeNames from '@salesforce/apex/ProfileBuilderController.getEmployeeNames';
import getVFOrigin from '@salesforce/apex/ProfileBuilderController.getVFOrigin';
import getSkillsPicklistValues from '@salesforce/apex/ProfileBuilderController.getSkillsPicklistValues';


export default class ProfileMaker extends LightningElement {
    iTechlogo = IMAGES;

    showFCAutoLib = false;
    cardName;
    
    //@track imageUrls;
    //@track selectedItemId;
    //@track showCheck = false;
    @track fullProfileJson = {};
    @track isfirstpage = true;
    // @track isTemplateSelected = false;
    @track isTemplateSelected = true;
    //@track isButtonVisible = false;
    @track employeeOptions = [];
    @track value;
    @track loadVfpage = false;
    @track progressValue = 25;
    @track icFCAutoLib = 'utility:right';
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

    @track skillOptions = [];
    @wire(getSkillsPicklistValues)
    wiredSkillOptions({ error, data }) {
        if (data) {
            this.skillOptions = data;
        } else if (error) {
            console.error('Error fetching skill picklist values:', error);
        }
    }
    //For Overding Css lib 
    // connectedCallback(){
    //     const style = document.createElement('style');
    //                 style.innerText = `
    //                     lightning-combobox .slds-truncate {
    //                         font-size: small;
    //                     }
    //                 `;
    //                  setTimeout(() => {
    //                     this.template.querySelector('.overrideStyle').appendChild(style);
    //                 }, 200);
    // }

    FCAutoLib_handleClick(){
        if (this.showFCAutoLib == false) {
            this.showFCAutoLib = true;
            this.icFCAutoLib = 'utility:down';
            this.template.querySelector('[data-id="divblock5"]').className='drpDwnClrChng firstclassDwn';

        } else {
            this.showFCAutoLib = false;
            this.icFCAutoLib = 'utility:right';
            this.template.querySelector('[data-id="divblock5"]').className='drpRghtClrChng firstclass';
        }
    }

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


    handleChange(event) {
        this.value = event.detail.value;

    }

    /*progressHandleClick(event){
        console.log('progress button click ',event.target.dataset.msg);
        this.progressValue = event.target.dataset.msg;
    }*/

    //skill name print in expandable box
    handleSkillClick(event){
        console.log('skill name------->',JSON.stringify(event.target.dataset.name));
        this.cardName = event.target.dataset.name;
        console.log('cardName-------->',this.cardName);
    }

    // 
    @track selectedValue = 0;
    @track value2 = '';

    handleRangeChange(event) {
        this.selectedValue = parseInt(event.target.value, 10);
        this.updateValue2();
    }

    handleTextInput(event) {
        this.selectedValue = parseInt(event.target.value, 10);
        this.updateValue2();
    }

    updateValue2() {
        if (this.selectedValue === 0) {
            this.value2 = 'Novice';
        } else if (this.selectedValue === 1) {
            this.value2 = 'Beginner';
        } else if (this.selectedValue === 2) {
            this.value2 = 'Skillfull';
        } else if (this.selectedValue === 3) {
            this.value2 = 'Experienced';
        } else if (this.selectedValue === 4) {
            this.value2 = 'Expert';
        }
    }
}