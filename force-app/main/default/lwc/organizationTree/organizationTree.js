import { LightningElement, api } from 'lwc';
import getEmployees from '@salesforce/apex/EmployeeOrganizationTree.getEmployees';

export default class OrganizationTree extends LightningElement {
    @api employees;

    connectedCallback() {
        if (!this.employees) {
            getEmployees().then(result => {
                this.employees = result;
                console.log('OUTPUT : ',result);
            }).catch(error => {
                console.error('Error fetching employees:', error);
            });
        }
        
    }
    isRootNode(emp) {
        return this.employees && this.employees[0] && emp.employee.Id === this.employees[0].employee.Id;
    }
    toggleChildren(event) {
        const parentNode = event.currentTarget.parentNode;
        const subordinates = parentNode.querySelector('.subordinates');
        if (subordinates) {
            subordinates.classList.toggle('hidden');
        }
    }
     renderedCallback() {
         setTimeout(() => {
                   this.hideEmptyLists();

        }, 1000);
    }

    hideEmptyLists() {
        const ulElements = this.template.querySelectorAll('ul');
        console.log('OUTPUT : ulElements',ulElements);
        ulElements.forEach(ul => {
            // Check if ulElement has any li child elements
            const hasLiChildren = ul.querySelector('li') !== null;
console.log('OUTPUT : hasLiChildren',hasLiChildren);
            if (!hasLiChildren) {
console.log('OUTPUT : hasLiChildren in',hasLiChildren);

                // Hide the ul element if it has no li children
                ul.style.display = 'none';
            }
        });
    }
}