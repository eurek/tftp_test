import { Controller } from "@hotwired/stimulus";
import { Chart, LineController, LineElement, PointElement, LinearScale, TimeScale, Filler, Tooltip } from 'chart.js'
import 'chartjs-adapter-luxon';

Chart.register(LineController, LineElement, PointElement, LinearScale, TimeScale, Filler, Tooltip);

export default class extends Controller {
  static values = {
    funds: Object,
    markerLight: String,
    markerDark: String,
    lineColor: String,
    gradientRgbaCode: String
  }

  connect() {
    const dataset = this.fundsValue['historic'].map((dataPoint) => {
      dataPoint.x = new Date(dataPoint.x);
      return dataPoint;
    });

    const goal = this.fundsValue['goal'].map((dataPoint) => {
      dataPoint.x = new Date(dataPoint.x);
      return dataPoint;
    });

    // points styling for goal dataset
    const markerDark = new Image(35, 35);
    markerDark.src = this.markerDarkValue;
    const pointsConfigGoal = ['circle', markerDark]

    // points styling for shares purchase dataset
    const pointsConfig = dataset.map((dataPoint) => {
      'circle'
    });
    const markerLight = new Image(35, 35);
    markerLight.src = this.markerLightValue;
    pointsConfig[0] = markerLight;
    pointsConfig[pointsConfig.length - 1] = markerLight;


    const ctx = this.element.getContext('2d');

    // color gradient fill
    const gradient = ctx.createLinearGradient(0, 0, 0, 400);
    gradient.addColorStop(0, `rgba(${this.gradientRgbaCodeValue},1)`);
    gradient.addColorStop(1, `rgba(${this.gradientRgbaCodeValue},0)`);

    const chart = new Chart(ctx, {
        // The type of chart we want to create
        type: 'line',

        // The data for our datasets
        data: {
            datasets: [{
              borderColor: this.lineColorValue,
              backgroundColor: gradient,
              fill: 'origin',
              data: dataset,
              lineTension: 0,
              pointStyle: pointsConfig,
              hitRadius: 10
            },
            {
              data: goal,
              borderColor: '#7A8485',
              pointStyle: pointsConfigGoal,
              radius: 1,
              backgroundColor: 'rgba(0,0,0,0)'
            }
          ]
        },

        // Configuration options go here
        options: {
          plugins: {
            filler: {
              propagate: true,
            },
            tooltip: {
              enabled: true,
              displayColors: false,
              cornerRadius: 0,
              titleFontFamily: 'Gilroy',
              bodyFontFamily: 'Open Sans',
              callbacks: {
                label: function(context) {
                  return `${context.parsed.y.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ")} €`;
                }
              },
              filter: function (tooltipItem) {
                return tooltipItem.datasetIndex === 0;
              }
            },
          },
          maintainAspectRatio: false,
          legend: {
            display: false
          },

          scales: {
            x: {
              type: 'time',
              time: {
                unit: 'month',
                tooltipFormat: 'MMM yyyy'
              },
              display: false,
              offset: true
            },
            y: {
              display: false,
              offset: true
            }
          }
        }
    });
  }
}
