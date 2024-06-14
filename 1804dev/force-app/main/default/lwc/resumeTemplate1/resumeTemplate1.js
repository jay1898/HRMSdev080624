import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class ResumeTemplate1 extends LightningElement {
    @track employeeData = {};

    connectedCallback() {
        this.employeeData = {
            "FirstName": "John",
            "LastName": "Doe",
            "Email": "john.doe@example.com",
            "Phone": "111-222-3333",
            "Position": "Front-End Developer",
            "Description": "I am a front-end developer with more than 3 years of experience writing HTML, CSS, and JS. I'm motivated, result-focused, and seeking a successful team-oriented company with the opportunity to grow.",
            "Experience": [
                {
                    "Id": "exp1",
                    "Company": "KlowdBox",
                    "Location": "San Francisco, CA",
                    "StartDate": "Jan 2011",
                    "EndDate": "Feb 2015",
                    "JobTitle": "Front-end Developer",
                    "Description": "Did this and that"
                },
                {
                    "Id": "exp2",
                    "Company": "Akount",
                    "Location": "San Monica, CA",
                    "StartDate": "Jan 2011",
                    "EndDate": "Feb 2015",
                    "JobTitle": "Front-end Developer",
                    "Description": "Did this and that"
                },
                {
                    "Id": "exp3",
                    "Company": "KlowdBox test",
                    "Location": "San Francisco, CA",
                    "StartDate": "Jan 2011",
                    "EndDate": "Feb 2016",
                    "JobTitle": "salesforce Developer",
                    "Description": "Did this and that"
                }
            ],
            "Education": [
                {
                    "Id": "edu1",
                    "Institute": "Sample Institute of Technology",
                    "Location": "San Francisco, CA",
                    "StartDate": "Jan 2011",
                    "EndDate": "Feb 2015",
                    "Degree": "Bachelor's in Computer Science",
                    "Description": "Did this and that"
                },
                {
                    "Id": "edu2",
                    "Institute": "Akount",
                    "Location": "San Monica, CA",
                    "StartDate": "Jan 2011",
                    "EndDate": "Feb 2015",
                    "Degree": "Master's in Web Development",
                    "Description": "Did this and that"
                }
            ],
            "Projects": [
                {
                    "Id": "proj1",
                    "Name": "DSP",
                    "Description": "I am a front-end developer with more than 3 years of experience writing HTML, CSS, and JS. I'm motivated, result-focused and seeking a successful team-oriented company with the opportunity to grow.",
                    "Link": ""
                },
                {
                    "Id": "proj2",
                    "Name": "DSP",
                    "Description": "I am a front-end developer with more than 3 years of experience writing HTML, CSS, and JS. I'm motivated, result-focused and seeking a successful team-oriented company with the opportunity to grow.",
                    "Link": "/login"
                }
            ],
            "Skills": [
                {
                    "Id": "skill1",
                    "Category": "Javascript",
                    "Experience": [
                        { "Id": "exp1", "Level": "Intermediate" },
                        { "Id": "exp2", "Level": "Advanced" }
                    ]
                },
                {
                    "Id": "skill2",
                    "Category": "CSS",
                    "Experience": [
                        { "Id": "exp1", "Level": "Intermediate" },
                        { "Id": "exp2", "Level": "Advanced" }
                    ]
                }
            ],
            "Interests": "Football, programming"
        }

    }

    handleClick() {
    const jsonData = JSON.stringify(this.employeeData);
    this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
            url: '/apex/resumeTemplate1?jsonData=' + encodeURIComponent(jsonData)
        }
    });
}
}