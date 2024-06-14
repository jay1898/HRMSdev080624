import { LightningElement,track } from 'lwc';

export default class ProfessionalSummary extends LightningElement {
     @track richTextValue = ''
   selectedValue
    
     values = [
        {
            "Id":"0",
            "Disc":"Lorem ipsum dolor sit amet consectetur adipisicing elit"
        },
        {
            "Id":"1",
            "Disc":"Lorem ipsum dolor sit amet consectetur adipisicing elit,Lorem ipsum dolor sit amet consectetur adipisicing elit"
        },
        {
            "Id":"2",
            "Disc":"Lorem ipsum dolor sit amet consectetur adipisicing elit"
        },
        {
            "Id":"3",
            "Disc":"Lorem ipsum dolor sit amet consectetur adipisicing elit,Lorem ipsum dolor sit amet consectetur adipisicing elit"
        },
     ]

    handleRichTextValue(event) {
        this.richTextValue = event.target.value;
        console.log('this.myVal--->',this.richTextValue);
    }
    onValueGoToRichTextArea(event){
        
         var index = parseInt(event.currentTarget.dataset.id);
         console.log("index$$",index);
         this.selectedValue = this.values[index]['Disc'];
         console.log("selectedValue$$",this.selectedValue);
         this.richTextValue += '<ul>'+'<li>'+this.selectedValue+'</li>'+'</ul>';
         
    }
    getTheParagrhapValue(event){
       
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