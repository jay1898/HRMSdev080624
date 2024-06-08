import { LightningElement, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import getAllOppsByStage from '@salesforce/apex/DonutChart.getAllOppsByStage';

export default class DonutChart extends LightningElement {
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

    @wire(getAllOppsByStage)
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