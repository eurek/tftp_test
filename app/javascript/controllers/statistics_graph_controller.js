import { Controller } from "@hotwired/stimulus";
import { Chart, LineController, LineElement, PointElement, LinearScale, TimeScale, Tooltip } from 'chart.js'

Chart.register(LineController, LineElement, PointElement, LinearScale, TimeScale, Tooltip);

export default class extends Controller {
  static targets = [ "canvas" ]
  static values = {
    color: String
  }

  connect() {
    const chartColor = this.defineGraphColorCode(this.colorValue);
    const firstDataset = JSON.parse(document.getElementsByClassName('DataTab--active')[0].dataset.graphValues);
    const ctx = this.canvasTarget.getContext('2d');
    const dataset = this.generateDataset(firstDataset);
    this.chart = this.createChart(ctx, dataset, chartColor);
  }

  defineGraphColorCode(colorName) {
    if (colorName === 'lagoon') {
      return '#89E5D3'
    } else if (colorName === 'purple') {
      return '#B29FFF'
    }
  }

  updateChart(event) {
    const dataValues = JSON.parse(event.currentTarget.dataset.graphValues)
    const newDataset = this.generateDataset(dataValues);
    this.chart.data.datasets.forEach((dataset) => {
      dataset.data = newDataset;
    });
    this.chart.update();
  }

  generateDataset(values) {
    const dataset = values.map((dataPoint) => {
      dataPoint.x = new Date(dataPoint.x);
      return dataPoint;
    });
    return dataset
  }

  createChart(ctx, dataset, chartColor) {
    const chart = new Chart(ctx, {
      // The type of chart we want to create
      type: 'line',
      data: {
        datasets: [{
          borderColor: '#FFFFFF',
          data: dataset,
          lineTension: 0
        }]
      },
      // Configuration options go here
      options: {
        responsive: true,
        legend: {
          display: false
        },
        maintainAspectRatio: false,
        plugins: {
          tooltip: {
            displayColors: false,
            cornerRadius: 0,
            titleFontFamily: 'Gilroy',
            bodyFontFamily: 'Open Sans'
          }
        },
        scales: {
          x: {
            type: 'time',
            time: {
              unit: 'month',
              displayFormats: { month: 'MMM yy' },
              tooltipFormat: 'MMM yy'
            },
            display: true,
            border: {
              color: chartColor
            },
            ticks: {
              color: chartColor
            }
          },
          y: {
            display: true,
            border: {
              color: chartColor
            },
            ticks: {
              color: chartColor
            }
          }
        }
      }
    });
    return chart;
  }
}
