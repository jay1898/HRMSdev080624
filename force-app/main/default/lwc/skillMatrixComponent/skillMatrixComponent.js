import { LightningElement, api, track} from 'lwc';
import getSkillMatrix from '@salesforce/apex/SkillMatrixController.getSkillMatrix';
import updateEmployeeSkillSet from '@salesforce/apex/SkillMatrixController.updateEmployeeSkillSet';
import TotalAmount from '@salesforce/schema/Order.TotalAmount';

export default class SkillMatrixComponent extends LightningElement {
    @api employeeId;
    @track allSkillMatrixDetails = [];
    @track skillMatrixNeedsToBeUpdated = [];
    isLoading = true;
    expertisePercentage = 0;

    connectedCallback(){
        this.getEmployeeSkills();
    }

    async getEmployeeSkills() {
        this.isLoading = true;
        await getSkillMatrix({employeeId: this.employeeId})
        .then(res=>{
            // console.log(JSON.stringify(res));
            this.allSkillMatrixDetails = (res === null || (Array.isArray(res) && res.length === 0)) ? [] : [...JSON.parse(res)];
            // console.log(JSON.stringify(this.allSkillMatrixDetails));
            this.allSkillMatrixDetails.forEach(i=>{
                const {name, check} = this.constructCheckBoxProperties(i);
                this.changesInCheckBoxes(i.Id, name, check, 'initital');
            })
            this.countExpertiseInPercentage();
        })
        .catch(err=>{
            console.error('Error while fetching the results of skillsets of employees', err);
            this.isLoading = false;
        })
        this.isLoading = false;
    }

    handleCheckboxChange(event) {
        // console.log(event.target.name);
        // console.log(event.target.dataset.id);
        // console.log(event.target.checked);
        this.changesInCheckBoxes(event.target.dataset.id, event.target.name, event.target.checked, 'update');
    }

    changesInCheckBoxes(Id, name, check, option) {
        const index = this.allSkillMatrixDetails.findIndex(i=>i.Id === Id);
        // console.log(Id, name, check, option);
        // console.log('normal', index);

        if (!check) {
            this.allSkillMatrixDetails[index].TrainingRequired = false;
            this.allSkillMatrixDetails[index].CurrentlyBeingTrained = false;
            this.allSkillMatrixDetails[index].Beginner = false;
            this.allSkillMatrixDetails[index].Intermediate = false;
            this.allSkillMatrixDetails[index].Advanced = false;
            this.allSkillMatrixDetails[index].Outcome = 0;

            // this.allSkillMatrixDetails[index].TrainingRequired_ED = false;
            // this.allSkillMatrixDetails[index].CurrentlyBeingTrained_ED = false;
            // this.allSkillMatrixDetails[index].Beginner_ED = false;
            // this.allSkillMatrixDetails[index].Intermediate_ED = false;
            // this.allSkillMatrixDetails[index].Advanced_ED = false;
        }
        else{
            if (name === 'tr') {
                this.allSkillMatrixDetails[index].TrainingRequired = true;
                this.allSkillMatrixDetails[index].CurrentlyBeingTrained = false;
                this.allSkillMatrixDetails[index].Beginner = false;
                this.allSkillMatrixDetails[index].Intermediate = false;
                this.allSkillMatrixDetails[index].Advanced = false;
                this.allSkillMatrixDetails[index].Outcome = 1;
    
                // this.allSkillMatrixDetails[index].TrainingRequired_ED = false;
                // this.allSkillMatrixDetails[index].CurrentlyBeingTrained_ED = true;
                // this.allSkillMatrixDetails[index].Beginner_ED = true;
                // this.allSkillMatrixDetails[index].Intermediate_ED = true;
                // this.allSkillMatrixDetails[index].Advanced_ED = true;
            }
            else if (name === 'cbt') {
                this.allSkillMatrixDetails[index].TrainingRequired = false;
                this.allSkillMatrixDetails[index].CurrentlyBeingTrained = true;
                this.allSkillMatrixDetails[index].Beginner = false;
                this.allSkillMatrixDetails[index].Intermediate = false;
                this.allSkillMatrixDetails[index].Advanced = false;
                this.allSkillMatrixDetails[index].Outcome = 2;
    
                // this.allSkillMatrixDetails[index].TrainingRequired_ED = true;
                // this.allSkillMatrixDetails[index].CurrentlyBeingTrained_ED = false;
                // this.allSkillMatrixDetails[index].Beginner_ED = true;
                // this.allSkillMatrixDetails[index].Intermediate_ED = true;
                // this.allSkillMatrixDetails[index].Advanced_ED = true;
            }
            else if (name === 'beg') {
                this.allSkillMatrixDetails[index].TrainingRequired = false;
                this.allSkillMatrixDetails[index].CurrentlyBeingTrained = false;
                this.allSkillMatrixDetails[index].Beginner = true;
                this.allSkillMatrixDetails[index].Intermediate = false;
                this.allSkillMatrixDetails[index].Advanced = false;
                this.allSkillMatrixDetails[index].Outcome = 3;
    
                // this.allSkillMatrixDetails[index].TrainingRequired_ED = true;
                // this.allSkillMatrixDetails[index].CurrentlyBeingTrained_ED = true;
                // this.allSkillMatrixDetails[index].Beginner_ED = false;
                // this.allSkillMatrixDetails[index].Intermediate_ED = true;
                // this.allSkillMatrixDetails[index].Advanced_ED = true;
            }
            else if (name === 'int') {
                this.allSkillMatrixDetails[index].TrainingRequired = false;
                this.allSkillMatrixDetails[index].CurrentlyBeingTrained = false;
                this.allSkillMatrixDetails[index].Beginner = false;
                this.allSkillMatrixDetails[index].Intermediate = true;
                this.allSkillMatrixDetails[index].Advanced = false;
                this.allSkillMatrixDetails[index].Outcome = 4;
    
                // this.allSkillMatrixDetails[index].TrainingRequired_ED = true;
                // this.allSkillMatrixDetails[index].CurrentlyBeingTrained_ED = true;
                // this.allSkillMatrixDetails[index].Beginner_ED = true;
                // this.allSkillMatrixDetails[index].Intermediate_ED = false;
                // this.allSkillMatrixDetails[index].Advanced_ED = true;
            }
            else if (name === 'adv') {
                this.allSkillMatrixDetails[index].TrainingRequired = false;
                this.allSkillMatrixDetails[index].CurrentlyBeingTrained = false;
                this.allSkillMatrixDetails[index].Beginner = false;
                this.allSkillMatrixDetails[index].Intermediate = false;
                this.allSkillMatrixDetails[index].Advanced = true;
                this.allSkillMatrixDetails[index].Outcome = 5;
    
                // this.allSkillMatrixDetails[index].TrainingRequired_ED = true;
                // this.allSkillMatrixDetails[index].CurrentlyBeingTrained_ED = true;
                // this.allSkillMatrixDetails[index].Beginner_ED = true;
                // this.allSkillMatrixDetails[index].Intermediate_ED = true;
                // this.allSkillMatrixDetails[index].Advanced_ED = false;
            }
        }

        if (option === 'update') {
            const updateIndex = this.skillMatrixNeedsToBeUpdated.findIndex(i=>i.Id === Id);
            if (updateIndex != -1) {
                this.skillMatrixNeedsToBeUpdated[updateIndex] = this.allSkillMatrixDetails[index];
            }
            else{
                this.skillMatrixNeedsToBeUpdated.push(this.allSkillMatrixDetails[index]);
            }
        }
        // console.log(JSON.stringify(this.skillMatrixNeedsToBeUpdated));
    }

    handleSave() {
        this.isLoading = true;
        updateEmployeeSkillSet({updatedSkills: JSON.stringify(this.skillMatrixNeedsToBeUpdated)})
        .then(res=>{
            console.log(res);
            if (res != null) {
                this.getEmployeeSkills();
            }
        })
        .catch(err=>{
            console.error('Error while updating skillsets on employee', err);
            this.isLoading = false;
        })
        this.isLoading = false;
    }

    countExpertiseInPercentage() {
        // console.log(JSON.stringify(this.allSkillMatrixDetails));
        const totalPoints = this.allSkillMatrixDetails.length * 5;
        const gainedPoints =  this.allSkillMatrixDetails.reduce((res, i)=>{
            return res = res + (+i.Outcome)
        }, 0);
        this.expertisePercentage = (totalPoints === 0) ? 0 : Math.round((gainedPoints / totalPoints) * 100);
        // console.log(totalPoints);
        // console.log(gainedPoints);
    }

    constructCheckBoxProperties(rec) {
        // console.log('rec',JSON.stringify(rec));
        if (rec.TrainingRequired) {
            return {
                name: 'tr',
                check: true
            }
        }
        else if (rec.CurrentlyBeingTrained) {
            return {
                name: 'cbt',
                check: true
            }
        }
        else if (rec.Beginner) {
            return {
                name: 'beg',
                check: true
            }
        }
        else if (rec.Intermediate) {
            return {
                name: 'int',
                check: true
            }
        }
        else if (rec.Advanced) {
            return {
                name: 'adv',
                check: true
            }
        }
        else {
            return {
                name: null,
                check: false
            }
        }
    }
}