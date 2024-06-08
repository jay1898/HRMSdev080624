import { LightningElement } from 'lwc';

import { loadScript } from 'lightning/platformResourceLoader';
import zipdata from '@salesforce/resourceUrl/profileBuilderDependencyJs';

export default class PreviewProfileBuilder extends LightningElement {
    PizZipUtils = zipdata + '/js/pizzip-utils.js';
    PizZip = zipdata + '/js/pizzip.js';
    Docxtemplater = zipdata + '/js/docxtemplater-latest.js';

    connectedCallback() {
        this.datashow();
    }

    datashow() {
        // await Promise.all([
        //     loadScript(this, this.PizZipUtils),
        //     loadScript(this, this.PizZip),
        //     loadScript(this, this.Docxtemplater)
        // ]);

        let reciveData;

        const receivedfromLWC = {
            name: "jhon",
            last_name: "Doe",
            phone: "0652455478",
            description: "New Website",
           // ProfileImage: "{!URLFOR($Resource.sampleImage)}",
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
        };
        const output = this.template.querySelector("#output");
        if (output) {
            output.innerHTML = JSON.stringify(receivedfromLWC); // Converting to string to display JSON
            reciveData = receivedfromLWC;
            this.generateHTML(reciveData);
        } else {
            console.error('Output element not found in the template.');
        }

    }

    async generateHTML(data) {
        const buffer = await fetch('/resource/templates').then(response => response.arrayBuffer());
        const content = new Uint8Array(buffer);
        const zip = new PizZip(content);

        const fileContent = zip.file("word/document.xml").asText();
        const parser = new DOMParser();
        const xmlDoc = parser.parseFromString(fileContent, "text/xml");
        const picElements = xmlDoc.getElementsByTagName('wp:inline');
        const descriptionEmbedPairs = {};

        for (let i = 0; i < picElements.length; i++) {
            const picElement = picElements[i];
            const description = picElement.getElementsByTagName('wp:docPr')[0].getAttribute('descr');
            const rEmbedValue = picElement.getElementsByTagName('a:blip')[0].getAttribute('r:embed');
            descriptionEmbedPairs[description] = rEmbedValue;
        }

        const fileContentRels = zip.file("word/_rels/document.xml.rels").asText();
        const xmlDocRels = parser.parseFromString(fileContentRels, "text/xml");

        for (const description in descriptionEmbedPairs) {
            if (data != undefined && data[description]) {
                const binaryData = await this.getBinaryContentReturn(data[description]);
                const rId6Element = xmlDocRels.querySelector('Relationship[Id="' + descriptionEmbedPairs[description] + '"]');
                const targetAttributeValue = rId6Element.getAttribute('Target');
                zip.file("word/" + targetAttributeValue, binaryData, { binary: true });
            }
        }

        const doc = new Docxtemplater(zip, {
            paragraphLoop: true,
            linebreaks: true,
        });

        doc.render(data);

        const buf = doc.getZip().generate({
            type: "blob",
        });

        this.renderDocx(buf);
    }

    async getBinaryContentReturn(description) {
        return new Promise((resolve, reject) => {
            PizZipUtils.getBinaryContent(description, (err, binaryData) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(binaryData);
                }
            });
        });
    }

    renderDocx(file) {
        if (!file) return;

        const container = this.template.querySelector("#document-container");
        const docxOptions = {
            debug: true,
            experimental: true
        };

        docx.renderAsync(file, container, null, docxOptions).then((x) => {
            this.renderThumbnails(container, this.template.querySelector("#thumbnails-container"));
            console.log(x);
        });
    }
}