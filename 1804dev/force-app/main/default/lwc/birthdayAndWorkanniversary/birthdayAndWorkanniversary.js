import { LightningElement, } from 'lwc';
export default class BirthdayAndWorkanniversary extends LightningElement {

    selectedTabLabel;
    isBirthdayTab= true;
    isWorkAnniversaryTab= false;

    connectedCallback() {
        if (this.selectedTabLabel) {
            const activeTab = this.template.querySelector(`[data-tab="${this.selectedTabLabel}"]`);
            if (activeTab) {
                this.adjustIndicator(activeTab);
            }
        }
    }

    tabs = [
        { label: 'Birthday', isActive: true },
        { label: 'Work Anniversaries', isActive: false },
    ];

    handleTabClick(event) {
        this.selectedTabLabel = event.target.dataset.tab;
        this.tabs.forEach(tab => {
            tab.isActive = tab.label === this.selectedTabLabel;
        });

        if (this.selectedTabLabel === 'Birthday') {
            this.isBirthdayTab = true;
            this.isWorkAnniversaryTab = false;
        } else if (this.selectedTabLabel === 'Work Anniversaries') {
            this.isBirthdayTab = false;
            this.isWorkAnniversaryTab = true;
        }
        // Call adjustIndicator to move the indicator to the selected tab
        this.adjustIndicator(event.currentTarget);
    }
    adjustIndicator(tabElement) {
        const indicator = this.template.querySelector('.tab-indicator');
        indicator.style.width = tabElement.offsetWidth + 'px';
        indicator.style.transform = `translateX(${tabElement.offsetLeft}px)`;
    }

    get isActive() {
        return this.tabs.find(tab => tab.isActive);
    }

}