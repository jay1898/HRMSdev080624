import { LightningElement,wire,track,api } from 'lwc';
import wordlib from '@salesforce/resourceUrl/WordTemplate';
import { loadScript } from 'lightning/platformResourceLoader';
import { getRecord,createRecord } from 'lightning/uiRecordApi';
const FIELDS = ['ContentVersion.Id', 'ContentVersion.Title', 'ContentVersion.VersionData'];
export default class ResumeBuilderRightPanel extends LightningElement {
		@api contentVersionId;
		@api profileData;
		spinner = true;
		
		@track currentTemplateData;
		
		@wire(getRecord, { recordId: '$contentVersionId', fields: FIELDS })
    wiredContentVersion({ error, data }) {
        if (data) {
            this.contentVersion = { data };
            this.error = undefined;
						this.base64StringResponse = this.contentVersion.data.fields.VersionData.value;
						this.loadWord();
						if(this.loadWord()){
						this.spinner = false;
						}
        } else if (error) {
            this.contentVersion = { error: error.body.message };
            this.error = error;
        }
    }
		
		
		connectedCallback() {
				
				Promise.all([
						loadScript(this, wordlib+'/js/jszip.min.js'),
						loadScript(this, wordlib+'/js/jszip-old.min.js'),
						loadScript(this, wordlib+'/js/docx-preview.js'),
						loadScript(this, wordlib+'/js/FileSaver.min.js'),
						loadScript(this, wordlib+'/js/docxtemplater-latest.js'),
				]).then(() => {
						console.log('script Loaded')

				}).catch(error => {
						console.error('Error loading scripts:', error);
				});
				
				const style = document.createElement('style');
        style.innerText = `
            .docx{
								background-color:white !important;
								padding: 35pt !important;
						}
        `;
        setTimeout(() => {
            this.template.querySelector('.overrideStyle').appendChild(style);
            
        }, 100);

		}
		
		async loadWord(){
				const content = Uint8Array.from(atob(this.base64StringResponse), c => c.charCodeAt(0));
				const zip = new JSZipOld();
				await zip.load(content);
			
				var fileContent = await zip.file("word/document.xml").asText();

				//var fileContent = zip.file("word/document.xml").asText();
				var parser = new DOMParser();
				var xmlDoc = parser.parseFromString(fileContent, "text/xml");
				var picElements = xmlDoc.getElementsByTagName('wp:inline');
				var descriptionEmbedPairs = {};
				for (var i = 0; i < picElements.length; i++) {
						var picElement = picElements[i];
						var description = picElement.getElementsByTagName('wp:docPr')[0].getAttribute('descr');
						var rEmbedValue = picElement.getElementsByTagName('a:blip')[0].getAttribute('r:embed');
						descriptionEmbedPairs[description] = rEmbedValue;
				}

				picElements = xmlDoc.getElementsByTagName('wp:anchor');
				if(picElements!=null){
					for (var i = 0; i < picElements.length; i++) {
						var picElement = picElements[i];
						var description = picElement.getElementsByTagName('wp:docPr')[0].getAttribute('descr');
						var rEmbedValue = picElement.getElementsByTagName('a:blip')[0].getAttribute('r:embed');
						descriptionEmbedPairs[description] = rEmbedValue;
					}
				}
				
				
				fileContent = await zip.file("word/_rels/document.xml.rels").asText();
				xmlDoc = parser.parseFromString(fileContent, "text/xml");
				
				try{
						for (var description in descriptionEmbedPairs) {
								if(this.profileData[description]){
										const binaryData = Uint8Array.from(atob(this.profileData[description]), c => c.charCodeAt(0));//this.b64toBlob(this.data[description],"image/jpg");//await this.getBinaryContentReturn(this.data[description]);
										var rId6Element = xmlDoc.querySelector('Relationship[Id="'+descriptionEmbedPairs[description]+'"]');
										var targetAttributeValue = rId6Element.getAttribute('Target');
										console.log(targetAttributeValue);
										zip.file("word/"+targetAttributeValue, binaryData);
								}                
						}
				}catch(e){
						
				}
				
				
				const doc = new Docxtemplater(zip, {
						paragraphLoop: true,
						linebreaks: true,
				});

				doc.render(this.profileData);

				const buf = doc.getZip().generate({
						type: "blob",
				});

				var currentDocument = buf; 
				this.currentTemplateData=currentDocument;
				const docxOptions = Object.assign(docx.defaultOptions, {
            debug: true,
            experimental: true
        });
				const container = this.template.querySelector(".document-container");
				const customStyle = this.template.querySelector(".customStyle");
				docx.renderAsync(currentDocument, container, customStyle, docxOptions)
						.then((x) => {
						
						console.log(x);
				});
		}
		
		
		
		
		onClickDownload(){
				this.donwloadResume();
		}
		
		async donwloadResume(){
				saveAs(this.currentTemplateData,  this.profileData.name + ".docx");
		}
}