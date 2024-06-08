import { LightningElement, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import getallTaskDetails from '@salesforce/apex/TaskTypeWiseChart.getallTaskDetails';

export default class TaskTypeWiseChart extends LightningElement {
    chart;
    chartjsInitialized = false;

    config = {
        type: 'doughnut',
        data: {
            datasets: [
                {
                    data: [],
                    backgroundColor: [], // Use an empty array for dynamic colors
                    label: 'Dataset 1',
                },
            ],
            labels: [],
        },
        options: {
            responsive: true,
            legend: {
                position: 'right',
            },
            animation: {
                animateScale: true,
                animateRotate: true,
            },
        },
    };

    @wire(getallTaskDetails)
    Timesheets({ error, data }) {
        if (data) {
            console.log('Data----------->' + data);
            if (!this.chartjsInitialized) {
                this.chartjsInitialized = true;
                loadScript(this, chartjs)
                    .then(() => {
                        const ctx = this.template.querySelector('canvas.donut').getContext('2d');
                        this.chart = new window.Chart(ctx, this.config);
                        this.updateChartWithData(data);
                    })
                    .catch((error) => {
                        this.showErrorMessage('Error loading ChartJS: ' + error.message);
                    });
            } else {
                this.updateChartWithData(data);
            }
        } else if (error) {
            this.showErrorMessage('Error loading data: ' + error.message);
        }
    }

    updateChartWithData(data) {
        // Clear existing chart data
        this.chart.data.labels = [];
        this.chart.data.datasets[0].data = [];
        this.chart.data.datasets[0].backgroundColor = []; // Clear existing background colors

        for (const key in data) {
            this.chart.data.labels.push(data[key].label);
            this.chart.data.datasets[0].data.push(data[key].count);

            // Dynamically generate background color based on the value
            const randomColor = this.getRandomColor();
            this.chart.data.datasets[0].backgroundColor.push(randomColor);
        }

        this.chart.update();
    }

    getRandomColor() {
        const letters = '0123456789ABCDEF';
        let color = '#';
        for (let i = 0; i < 6; i++) {
            color += letters[Math.floor(Math.random() * 16)];
        }
        return color;
    }

    showErrorMessage(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error',
            })
        );
    }
}


/*import { LightningElement, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import getallTaskDetails from '@salesforce/apex/TaskTypeWiseChart.getallTaskDetails';

export default class TaskTypeWiseChart extends LightningElement {
    chart;
    chartjsInitialized = false;

    config = {
        // Your chart configuration
                type : 'doughnut',
            data :{
            datasets :[
            {
                data: [],
                backgroundColor :[
                    'rgb(255,99,132)',
                    'rgb(255,159,64)',
                    'rgb(255,205,86)',
                    'rgb(75,192,192)',
                    'rgb(153,102,204)',
                    'rgb(179,158,181)',
                    'rgb(188,152,126)',
                    'rgb(123,104,238)',
                    'rgb(119,221,119)',//
                    'rgb(255,99,132)',
                    'rgb(255,159,64)',],
                label:'Dataset 1'
            }
             ],
        labels:[]
        },
        options: {
            responsive : true,
            legend : {
                position :'right'
            },
            animation:{
                animateScale: true,
                animateRotate : true
            }
        }
    };

    @wire(getallTaskDetails)
    Timesheets({ error, data }) {
        if (data) {
            console.log('Data----------->'+data);
            if (!this.chartjsInitialized) {
                this.chartjsInitialized = true;
                loadScript(this, chartjs)
                    .then(() => {
                        const ctx = this.template.querySelector('canvas.donut').getContext('2d');
                        this.chart = new window.Chart(ctx, this.config);
                        this.updateChartWithData(data);
                    })
                    .catch(error => {
                        this.showErrorMessage('Error loading ChartJS: ' + error.message);
                    });
            } else {
                this.updateChartWithData(data);
            }
        } else if (error) {
            this.showErrorMessage('Error loading data: ' + error.message);
        }
    }

    updateChartWithData(data) {
        // Clear existing chart data
        this.chart.data.labels = [];
        this.chart.data.datasets[0].data = [];

        for (const key in data) {
            this.chart.data.labels.push(data[key].label);
            this.chart.data.datasets[0].data.push(data[key].count);
        }

        this.chart.update();
    }

    showErrorMessage(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error',
            })
        );
    }
}*/