import { LightningElement,api } from 'lwc';
import horizontalLineImage from '@salesforce/resourceUrl/horizontalLineImage'

export default class TabItem extends LightningElement {

    @api tabLabel;
    @api isActive;
    hLineImage = horizontalLineImage;

    handleClick() {
        const tabClick = new CustomEvent('tabclick', {
            detail: this.tabLabel
        });
        this.dispatchEvent(tabClick);
    }

    get tabClass() {
        return this.isActive ? 'activeTab' : '';
    }
}