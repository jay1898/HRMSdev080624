import { LightningElement, api, wire, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import getUserTimeSheetDetails from '@salesforce/apex/UserTimeSheetDonutController.getUserTimeSheetDetails';

export default class TaskTypeWiseChart extends LightningElement {

    /*connectedCallback() {
    // Delay wire method call by 1000ms
    setTimeout(() => {
      this.wiredTimesheets();  
    }, 1000);
    }*/
    @api recordId;
    @track chart;
    chartjsInitialized = false;
    chartDataLoaded = false;
    chartData = null;

    config = {
        type: 'doughnut',
        data: {
            datasets: [
                {
                    data: [],
                    backgroundColor: [/*
                        'rgb(255,99,132)',
                        'rgb(255,159,64)',
                        'rgb(255,205,86)',
                        'rgb(75,192,192)',
                        'rgb(153,102,204)',
                        'rgb(179,158,181)',
                        'rgb(188,152,126)',
                        'rgb(123,104,238)',
                        'rgb(119,221,119)',
                        'rgb(255,99,132)',
                        'rgb(255,159,64)',*/
                    ],
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

    @wire(getUserTimeSheetDetails, { employeeId: '$recordId' })
    Timesheets({ error, data }) {
        console.log('apex calling'+data);
        if (data) {
            this.chartDataLoaded = true;
            this.chartData = data;

            if (this.chartjsInitialized) {
                this.updateChartWithData(data);
            }
        }   else if (error) {
            this.showErrorMessage('Error loading data: ' + error.message);
        }

        if (this.chartDataLoaded && !this.chartjsInitialized) {
            this.initializeChart();
        }
    }

    initializeChart() {
        this.chartjsInitialized = true;
        loadScript(this, chartjs)
            .then(() => {
                const ctx = this.template.querySelector('canvas.donut').getContext('2d');
                this.chart = new window.Chart(ctx, this.config);
                if (this.chartDataLoaded && this.chartData) {
                    this.updateChartWithData(this.chartData);
                }
            })
            .catch(error => {
                this.showErrorMessage('Error loading ChartJS: ' + error.message);
            });
    }

    updateChartWithData(data) {
        if (data && data.length > 0) {
            this.chart.data.labels = [];
            this.chart.data.datasets[0].data = [];
            this.chart.data.datasets[0].backgroundColor = [];
            data.forEach(item => {
                this.chart.data.labels.push(item.taskType);
                this.chart.data.datasets[0].data.push(item.totalHours);
                // Dynamically generate background color based on the value
                const randomColor = this.getRandomColor();
                this.chart.data.datasets[0].backgroundColor.push(randomColor);
            });
            this.chart.update();
        }
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





/*import { LightningElement, wire, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import getUserTimeSheetDetails from '@salesforce/apex/UserTimeSheetDonutController.getUserTimeSheetDetails';

export default class TaskTypeWiseChart extends LightningElement {
    @api recordId;
    chart;
    chartjsInitialized = false;

    config = {
        type: 'doughnut',
        data: {
            datasets: [
                {
                    data: [],
                    backgroundColor: [
                        'rgb(255,99,132)',
                        'rgb(255,159,64)',
                        'rgb(255,205,86)',
                        'rgb(75,192,192)',
                        'rgb(153,102,204)',
                        'rgb(179,158,181)',
                        'rgb(188,152,126)',
                        'rgb(123,104,238)',
                        'rgb(119,221,119)',
                        'rgb(255,99,132)',
                        'rgb(255,159,64)',
                    ],
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

    @wire(getUserTimeSheetDetails, { employeeId: '$recordId' }) // Replace with the actual employee Id
    Timesheets({ error, data }) {
        if (data) {
            console.log('Data----------->', data);
            console.log('RecordId------------->' + this.recordId);

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
                        console.log('error--------->'+error);
                    });
            } else {
                this.updateChartWithData(data);
            }
        } else if (error) {
            this.showErrorMessage('Error loading data: ' + error.message);
        }else {
            // Handle the case when data is undefined
            this.showErrorMessage('Data is not available.');
        }
    }

    updateChartWithData(data) {
        // Clear existing chart data
        this.chart.data.labels = [];
        this.chart.data.datasets[0].data = [];

        data.forEach(item => {
            this.chart.data.labels.push(item.taskType);
            this.chart.data.datasets[0].data.push(item.totalHours);
        });

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