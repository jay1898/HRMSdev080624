import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import ChartJS1 from '@salesforce/resourceUrl/ChartJS1';

export default class TLineChart extends LightningElement {
    @track myChart;
    isChartJsLoaded = false;

    renderedCallback() {
        if (this.myChart || this.isChartJsLoaded) {
            return;
        }

        // Load the Chart.js library
        loadScript(this, ChartJS1)
            .then(() => {
                console.log('Chart.js library loaded');
                this.isChartJsLoaded = true;
                // Call the drawCharts() function to initialize and draw the chart
                this.drawCharts();
            })
            .catch((error) => {
                console.log('Error:', error);
                this.showErrorMessage('Error loading Chart.js');
            });
    }

    // Function to create the line chart
    drawLineChart(div_id, results, yColumn, yLabel, xAxes, firstColour, secondColour, thirdColour, fourthColour) {
        if (this.isChartJsLoaded) {
            const ctx = this.template.querySelector('#' + div_id).getContext('2d');
            const width = window.innerWidth || document.body.clientWidth;
            const gradientStroke = ctx.createLinearGradient(0, 0, width, 0);
            gradientStroke.addColorStop(0, firstColour);
            gradientStroke.addColorStop(0.3, secondColour);
            gradientStroke.addColorStop(0.6, thirdColour);
            gradientStroke.addColorStop(1, fourthColour);

            const labels = results.map((item) => item[xAxes]);
            const data = results.map((item) => item[yColumn]);

            this.myChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [
                        {
                            label: yLabel,
                            borderColor: gradientStroke,
                            pointBorderColor: gradientStroke,
                            pointBackgroundColor: gradientStroke,
                            pointHoverBackgroundColor: gradientStroke,
                            pointHoverBorderColor: gradientStroke,
                            pointBorderWidth: 8,
                            pointHoverRadius: 8,
                            pointHoverBorderWidth: 1,
                            pointRadius: 3,
                            fill: false,
                            borderWidth: 4,
                            data: data,
                        },
                    ],
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    legend: {
                        display: false,
                    },
                    scales: {
                        yAxes: [
                            {
                                ticks: {
                                    fontFamily: 'Roboto Mono',
                                    fontColor: '#556F7B',
                                    fontStyle: 'bold',
                                    beginAtZero: true,
                                    maxTicksLimit: 5,
                                    padding: 20,
                                },
                                gridLines: {
                                    drawTicks: false,
                                    display: false,
                                    drawBorder: false,
                                },
                            },
                        ],
                        xAxes: [
                            {
                                gridLines: {
                                    zeroLineColor: 'transparent',
                                },
                                ticks: {
                                    padding: 20,
                                    fontColor: '#556F7B',
                                    fontStyle: 'bold',
                                    fontFamily: 'Roboto Mono',
                                },
                                gridLines: {
                                    drawTicks: false,
                                    display: false,
                                    drawBorder: false,
                                },
                            },
                        ],
                    },
                },
            });
        }
    }

    // Function to initialize and draw the chart
    drawCharts() {
        const results = [
                    {
                        date: 'Jan 17',
                        visits: 234,
                    },
                    {
                        date: 'Feb 17',
                        visits: 345,
                    },
                    {
                        date: "Mar 17",
                        visits: 321
                    },
                    {
                        date: "Apr 17",
                        visits: 412
                    },
                    {
                        date: "May 17",
                        visits: 435
                    },
                    {
                        date: "June 17",
                        visits: 543
                    },
                    {
                        date: "July 17",
                        visits: 567
                    },
                    {
                        date: "Aug 17",
                        visits: 480
                    }
                            ];

        this.drawLineChart(
            'lineChartBlueGreen',
            results,
            'visits',
            'Number of visits',
            'date',
            '#7C4DFF',
            '#448AFF',
            '#00BCD4',
            '#1DE9B6'
        );
    }

    // Display an error message using a Toast
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



/*import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ChartJS1 from '@salesforce/resourceUrl/ChartJS1';

export default class TLineChart extends LightningElement {
    @track myChart;

    renderedCallback() {
        if (this.myChart) {
            return;
        }

        // Load the Chart.js library
        loadScript(this, ChartJS1)
            .then(() => {
                console.log('Chart.js library loaded');

                const results = [
                    {
                        date: "Jan 17",
                        visits: 234
                    },
                    {
                        date: "Feb 17",
                        visits: 345
                    },
                    {
                        date: "Mar 17",
                        visits: 321
                    },
                    {
                        date: "Apr 17",
                        visits: 412
                    },
                    {
                        date: "May 17",
                        visits: 435
                    },
                    {
                        date: "June 17",
                        visits: 543
                    },
                    {
                        date: "July 17",
                        visits: 567
                    },
                    {
                        date: "Aug 17",
                        visits: 480
                    }
                ];

                // Function to create the line chart
                function drawLineChart(div_id, results, yColumn, yLabel, xAxes, firstColour, secondColour, thirdColour, fourthColour) {
                    const ctx = document.getElementById(div_id).getContext("2d");
                    const width = window.innerWidth || document.body.clientWidth;
                    const gradientStroke = ctx.createLinearGradient(0, 0, width, 0);
                    gradientStroke.addColorStop(0, firstColour);
                    gradientStroke.addColorStop(0.3, secondColour);
                    gradientStroke.addColorStop(0.6, thirdColour);
                    gradientStroke.addColorStop(1, fourthColour);

                    const labels = results.map((item) => item[xAxes]);
                    const data = results.map((item) => item[yColumn]);

                    const myChart = new Chart(ctx, {
                        type: "line",
                        data: {
                            labels: labels,
                            datasets: [
                                {
                                    label: yLabel,
                                    borderColor: gradientStroke,
                                    pointBorderColor: gradientStroke,
                                    pointBackgroundColor: gradientStroke,
                                    pointHoverBackgroundColor: gradientStroke,
                                    pointHoverBorderColor: gradientStroke,
                                    pointBorderWidth: 8,
                                    pointHoverRadius: 8,
                                    pointHoverBorderWidth: 1,
                                    pointRadius: 3,
                                    fill: false,
                                    borderWidth: 4,
                                    data: data
                                }
                            ]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            legend: {
                                display: false
                            },
                            scales: {
                                yAxes: [
                                    {
                                        ticks: {
                                            fontFamily: "Roboto Mono",
                                            fontColor: "#556F7B",
                                            fontStyle: "bold",
                                            beginAtZero: true,
                                            maxTicksLimit: 5,
                                            padding: 20
                                        },
                                        gridLines: {
                                            drawTicks: false,
                                            display: false,
                                            drawBorder: false
                                        }
                                    }
                                ],
                                xAxes: [
                                    {
                                        gridLines: {
                                            zeroLineColor: "transparent"
                                        },
                                        ticks: {
                                            padding: 20,
                                            fontColor: "#556F7B",
                                            fontStyle: "bold",
                                            fontFamily: "Roboto Mono"
                                        },
                                        gridLines: {
                                            drawTicks: false,
                                            display: false,
                                            drawBorder: false
                                        }
                                    }
                                ]
                            }
                        }
                    });
                }

                // Function to initialize and draw the chart
                function drawCharts() {
                    drawLineChart(
                        "lineChartBlueGreen",
                        results,
                        "visits",
                        "Number of visits",
                        "date",
                        "#7C4DFF",
                        "#448AFF",
                        "#00BCD4",
                        "#1DE9B6"
                    );
                }

                // Call the drawCharts() function to initialize and draw the chart
                drawCharts();
            })
            .catch((error) => {
                console.log('Error:', error);
                this.showErrorMessage('Error loading Chart.js');
            });
    }

    // Display an error message using a Toast
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
*/