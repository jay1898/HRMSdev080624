import { LightningElement, wire, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import WorkingFormatController from '@salesforce/apex/WorkingFormatController.getWorkingFormatChart';

export default class WorkingFormatLineGraph extends LightningElement {
    @api recordId;
    @track chart;
    chartjsInitialized = false;

    config = {
        type: 'line',
        data: {
            labels: [],
            datasets: [
                {
                    label: 'Daily Hours',
                    data: [],
                    borderColor: 'rgb(50, 205, 50)',
                    borderWidth: 1.5,
                    fill: true,
                    backgroundColor: 'rgba(0, 161, 41, 0.25)',
                },
            ],
        },
        options: {
            responsive: true,
            legend: {
                display: false,
            },
            animation: {
                animateScale: true,
                animateRotate: true,
            },
            scales: {
                xAxes: { // Assuming Chart.js 3.x syntax
                    type: 'category',
                    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
                    gridLines: {
                        display: false, // This will remove the x-axis gridLines lines
                    },
                },
                yAxes: {
                    beginAtZero: true,
                    stepSize: 2,
                    gridLines: {
                        display: false, // This will remove the y-axis gridLines lines
                    },
                    ticks: {
                        // Include your tick options here if necessary
                    },
                },
            },
        },
    };

    @wire(WorkingFormatController, { employeeId: '$recordId' })
    Timesheets({ error, data }) {
        if (data) {
            console.log('data&&&&&&&&&&&&&&&&&&&',data);
            if (!this.chartjsInitialized) {
                this.chartjsInitialized = true;
                loadScript(this, chartjs)
                    .then(() => {
                        const ctx = this.template.querySelector('canvas.line-chart').getContext('2d');
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
        this.chart.data.labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        console.log('this.chart.data.labels',this.chart.data.labels);
        for (const item of data) {
            const dayLabel = item.label;
            const index = this.chart.data.labels.indexOf(dayLabel);
            if (index !== -1) {
                this.chart.data.datasets[0].data[index] = item.count;
            }
        }
         this.chart.data.datasets[0].borderColor = 'transparent';
        this.chart.options = {
            scales: {
                x: {
                    ticks: {
                        font: {
                            size: 14 // Set your desired font size here
                        }
                    }
                },
                // Do the same for the y-axis if you want to change the font size there too
                y: {
                    ticks: {
                        font: {
                            size: 14 // And here
                        }
                    }
                }
            }
        };
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
    connectedCallback() {
        setTimeout(() => {
            const style = document.createElement('style');
            style.innerText = `
                canvas{
                    height:227px !important;
                }
            `;
            this.template.querySelector('.overrideStyle').appendChild(style);
        }, 100);
    }
}