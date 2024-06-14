import { LightningElement,wire,track } from 'lwc';
import getHelpText from'@salesforce/apex/ProfileBuilderController.getHelpTextSummary';

export default class ProfessionalSummary extends LightningElement {
     @track richTextValue = ''
     @track helpTexts;
     @track error;
     searchKey = '';
     delayTimeout
     selectedValue
   
     
     @wire (getHelpText,{inputStr: '$searchKey'}) 
     wiredHelpTexts({data,error}){
        console.log('Wire fired with search key:: ' + this.searchKey);
        if(data){
            this.helpTexts = data;
            console.log("helptText####",this.helpTexts)
            this.error = undefined;
        }else{
            this.helpTexts = undefined;
            this.error = error;
        }
     }



    handleRichTextValue(event) {
        this.richTextValue = event.target.value;
        console.log('this.myVal--->',this.richTextValue);
    }
    onValueGoToRichTextArea(event){
        
         var index = parseInt(event.currentTarget.dataset.id);
         console.log("index$$",index);
         this.selectedValue = this.helpTexts[index]['Instructions__c'];
         console.log("selectedValue$$",this.selectedValue);
         this.richTextValue += '<ul>'+'<li>'+this.selectedValue+'</li>'+'</ul>';
         
    }
    getTheParagrhapValue(event){
       
    }

    handleKeyChange(event){
        const searchKey = event.target.value;
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
        this.searchKey = searchKey == '' ? this.searchKey= ' ' : searchKey;
    }, '200');
    }

    onBack(){
        this.dispatchEvent(
            new CustomEvent('backtoexperiencepage', {
                detail: {
                    'experiencePage': true,
                }
            })
        )
    }

}