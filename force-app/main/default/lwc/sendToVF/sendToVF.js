import { LightningElement, wire } from 'lwc';
import getVFOrigin from '@salesforce/apex/ProfileBuilderController.getVFOrigin';

export default class SendToVF extends LightningElement {
  //vfRoot = "https://itechcloudsolution--itechdev--c.sandbox.vf.force.com";
    @wire(getVFOrigin)
    vfOrigin;

  message = "";
  handleOnChange(event) {
    this.message = event.target.value;
  }
  // handleClick() {
  //   var vfWindow = this.template.querySelector("iframe").contentWindow;
  //   vfWindow.postMessage(this.message, this.vfOrigin.data);
  // }
  handleClick() {
    var vfWindow = this.template.querySelector("iframe").contentWindow;
    //vfWindow.postMessage(this.message, 'https://itechcloudsolution--itechdev--c.sandbox.vf.force.com');
    // vfWindow.postMessage(this.message, this.vfOrigin.data);
    vfWindow.postMessage(this.message, '*');
    // vfWindow.postMessage(this.message, this.vfRoot);
  }
}