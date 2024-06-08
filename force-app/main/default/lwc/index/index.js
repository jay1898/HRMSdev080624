import { LightningElement, track, wire, api } from 'lwc';
// import career from '@salesforce/resourceUrl/career';
import iTech_logo from '@salesforce/resourceUrl/iTech_logo';
import candidate_Application_Submitted from '@salesforce/resourceUrl/Candidate_Application_Submitted';
import BackArrow from '@salesforce/resourceUrl/Back_Arrow';
import briefcase from '@salesforce/resourceUrl/briefcase';
import rupee from '@salesforce/resourceUrl/rupee';
import Location from '@salesforce/resourceUrl/Location';
import facebookFooter from '@salesforce/resourceUrl/facebookFooter';
import twitterFooter from '@salesforce/resourceUrl/twitterFooter';
import skypeFooter from '@salesforce/resourceUrl/skypeFooter';
import linkedInFooter from '@salesforce/resourceUrl/linkedInFooter';
import InstagramFooter from '@salesforce/resourceUrl/InstagramFooter';
// import Design from '@salesforce/resourceUrl/Design';
// import Footer from '@salesforce/resourceUrl/Carrer_footer';
import Career_header from '@salesforce/resourceUrl/Career_header';
import getRecruitData from '@salesforce/apex/PositionOpeningController.getRecruitData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Index extends LightningElement {
  @track imageURL;
  @track imgURL;
  @track CaseURL;
  @track RuURL;
  @track LocURL;
  @track designURL;
  candidateSubmitted;
  currentYear;
  BackURL;
  // @track footerURL;
  facebookFooterIcon;
  twitterFooterIcon;
  skypeFooterIcon;
  linkedInFooterIcon;
  InstagramFooterIcon;

  titlename
  jobData;
  selectedJobId = null;
  fullMessageView = false;
  showDescription;
  getName;
  showTitle;
  showJobTitle;
  showExperience;
  showfinalDescription;
  strippedshowDescription;
  showQualification;
  showSalary;
  showVariable;
  showJobLocation;
  showJobType;
  showResponsibilityDuty;
  showRequiredExperienceSkillsQualificaton;
  showSkills;
  strippedRAD;
  JobExp;
  candidateRecordId;
  countPosition;
  isLoading = true;
  @track showChild = false;
  @track showMain = true;
  isImageLoad = false;


  isThankyouvisible = false;


  showToast(mTitle, mMessage, mVariant) {
    const event = new ShowToastEvent({
      title: mTitle,
      message: mMessage,
      variant: mVariant,
      mode: 'pester'
    });
    this.dispatchEvent(event);
  }
  // _isThankyouvisible = false;

  // get isThankyouvisible() {
  //   return this._isThankyouvisible;
  // }

  // set isThankyouvisible(value) {
  //   this._isThankyouvisible = value;
  //   if (value === true) {
  //     // Refresh the page
  //     window.location.reload();
  //   }
  // }

  hanldeValueChange(event) {
    console.log('event.details', event.detail);
    this.fullMessageView = !event.detail;
    this.isThankyouvisible = event.detail;
    if(this.isThankyouvisible) {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

  }

  connectedCallback() {
    this.currentYear = new Date().getFullYear();
    console.log('Inside connected callback parent');
    // Set the imageURL using the static resource URL
    // this.imageURL = career;
    this.imgURL = iTech_logo;

    this.candidateSubmitted = candidate_Application_Submitted;

    this.CaseURL = briefcase;
    this.RuURL = rupee;
    this.LocURL = Location;

    // this.designURL = Design;
    // this.footerURL = Footer;

    this.facebookFooterIcon = facebookFooter;
    this.twitterFooterIcon = twitterFooter;
    this.skypeFooterIcon = skypeFooter;
    this.linkedInFooterIcon = linkedInFooter;
    this.InstagramFooterIcon = InstagramFooter;
    // this.isThankyouvisible = false;
  }
  handleImageLoaded() {
    this.isImageLoaded = true;
  }
  @wire(getRecruitData)
  wiredData({ data, error }) {
    if (data) {
      this.BackURL = BackArrow;
      this.isLoading = false;
      this.jobData = data.map((job) => ({
        ...job, showDetails: false,
        Skills__formatted: job.Skills__c.split(';'),
        Responsibilities_and_Duties: job.Responsibilities_and_Duties__c,
        JobExp: job.Job_Exp__c
      }));
      console.log('Data from apex', data);
      let dataLength = data.length;
      console.log('datalength', dataLength);
      this.countPosition = dataLength < 10 ? `0${dataLength}` : `${dataLength}`;
      console.log('countposition', this.countPosition);

    } else if (error) {
      console.error(error);
    }
    // if (data) {
    //   this.jobData = data.map((job) => ({
    //     ...job, showDetails: false,
    //     Skills__formatted: job.Skills__c.split(';'),
    //     Responsibilities_and_Duties: job.Responsibilities_and_Duties__c,
    //     JobExp:job.Job_Exp__c	
    //   }));
    //   console.log('Data from apex', data);
    //   console.log('this.jobData', JSON.parse(JSON.stringify(this.jobData)));
    // } else if (error) {
    //   console.log(error);
    // }

  }

  showDetails(event) {
    window.scrollTo({ top: 0, behavior: 'smooth' });
    this.fullMessageView = true;
    this.showMain = false;
    // console.log("this.fullMessageView downnn", this.fullMessageView);
    // console.log("this.showMain downnn", this.showMain);

    const jobId = event.currentTarget.dataset.id;
    const foundObject = this.jobData.find(item => item.Id === jobId);

    //console.log('row Name', foundObject.Job_Description__c);

    this.getName = foundObject.Name;
    //console.log('Name +++', this.getName);
    this.showTitle = foundObject.Title__c;
    this.showJobTitle = foundObject.Job_Title__c
    this.showExperience = foundObject.Job_Experience__c;
    this.showDescription = foundObject.Job_Description__c;
    this.showSalary = foundObject.Salary__c;
    this.showJobLocation = foundObject.Job_Location__c;
    this.showJobType = foundObject.Job_Type__c;
    console.log('this.showJobType', this.showJobType);
    this.showResponsibilityDuty = foundObject.Responsibilities_and_Duties__c;
    this.showRequiredExperienceSkillsQualificaton = foundObject.Req_Experience_Skills_qualification__c;
    this.JobExp = foundObject.Job_Exp__c;
    console.log('JobExp', this.JobExp);
    // this.showQualification = foundObject.Qualification__c;

    this.showQualification = this.formateMyValue(foundObject.Qualification__c);
    console.log('Skills with Comma : ', foundObject.Skills__c);
    // this.showQualification = this.formateMyValue(foundObject.Qualification__c);
    //for remove html tag
    // const originalString = ;
    // this.strippedshowDescription = foundObject.Job_Description__c;
    this.strippedshowDescription = foundObject.Job_Description__c;
    this.strippedRAD = foundObject.Responsibilities_and_Duties__c;

    console.log('strippedRAD', this.strippedRAD);

    // this.strippedshowDescription = this.showDescription.replace(/(<([^>]+)>)/gi, "");
    // console.log(strippedshowDescription); //outputs 'description'
    //this.showfinalDescription = strippedshowDescription;
    // Toggle the showDetails property for the clicked job item
    // this.jobData = this.jobData.map((job) => ({
    //   ...job,
    //   showDetails: job.Id === jobId ? !job.showDetails : job.showDetails,
    // }));
    //console.log("this.fullMessageView", this.fullMessageView);
    // this.template.querySelector('.at-Top').scrollIntoView();
  }

  formateMyValue(data) {
    let tempArr = data.split(";");
    let str = '';
    tempArr.forEach((ele, index) => {
      str += ele + (index == tempArr.length - 1 ? ' ' : ', ');
    })
    return str;
  }

  backButtonhandle() {
    this.showMain = true;
    this.isLoading = false;
    this.fullMessageView = false;
    this.isThankyouvisible = false;
  }

  disconnectedCallback() {
    console.log('Inside disconnected callback parent')
  }
  get skillsArray() {
    return this.job.Skills__formatted.split(' ');
  }
  // get footerBackground() {
  //   console.log('in footer');
  //   return `height:37rem;background-size:cover;background-position:center;background-image:url('/resource/Footer')`;
  //  }
}