import { LightningElement, wire } from 'lwc';
import getHolidaysByYear from '@salesforce/apex/HolidayController.getHolidayByYear';

export default class Holidays extends LightningElement {
    holidays;
    colourClasses = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l'];
    counter = 0;
    isLoading = true;

    @wire(getHolidaysByYear)
    getHolidays({data, error}){
        if (data) {
            this.holidays = JSON.parse(data);

            this.holidays.sort((a, b)=>new Date(a.holidayDate).getMonth() - new Date(b.holidayDate).getMonth());

            this.holidays.forEach((i, j)=>{
                if (j != 0 && new Date(this.holidays[j].holidayDate).getMonth() != new Date(this.holidays[j - 1].holidayDate).getMonth()) {
                    this.counter++;
                }
                i.class = this.colourClasses[this.counter];
                i.divClass = 'day';
                i.dateNumber = (i.dateNumber < 10) ? `0${i.dateNumber}` : `${i.dateNumber}`;
                if (
                    (new Date(i.holidayDate).getMonth() < new Date().getMonth()) ||
                    (new Date(i.holidayDate).getMonth() === new Date().getMonth() && new Date(i.holidayDate).getDate() < new Date().getDate())
                ) {
                 i.divClass = 'day pastHoliday';   
                }
            });

            this.counter = 0;
            // console.log(this.holidays);
            this.isLoading = false;
        }
        else{
            console.error('error while fetching data from apex', error)
        }
    }

    // async getData(){ 
    //     await Promise.all([
    //         getHolidaysByYear()
    //     ])
    //     .then(result=>{
    //         this.holidaysObj = (result[0] != null) ? result[0] : {};   
    //         console.log('holiday ',this.holidaysObj); 
    //     })
    //     .catch(err=>{
    //         console.error('Error while fetching data from Apex', err);
    //     });
    // }
}