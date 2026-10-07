import { Controller } from "@hotwired/stimulus"
import "chart.js" // UMD 版なので、読み込むと window.Chart が使えるようになる（部品も登録済み）

// 7つの診断軸のスコアをレーダーチャートで描く
// 使い方: data-controller="radar-chart" data-radar-chart-labels-value="[...]" data-radar-chart-scores-value="[...]"
export default class extends Controller {
  static targets = ["canvas"]
  static values = { labels: Array, scores: Array }

  connect() {
    const orange = "rgb(249, 115, 22)"

    this.chart = new window.Chart(this.canvasTarget, {
      type: "radar",
      data: {
        labels: this.labelsValue,
        datasets: [{
          data: this.scoresValue,
          backgroundColor: "rgba(249, 115, 22, 0.2)",
          borderColor: orange,
          borderWidth: 2,
          pointBackgroundColor: orange,
          pointRadius: 4
        }]
      },
      options: {
        maintainAspectRatio: true,
        scales: {
          r: {
            min: 0,
            max: 100,
            ticks: { stepSize: 25, display: false },
            pointLabels: { font: { size: 14, weight: "bold" }, color: "#374151" }
          }
        },
        plugins: {
          legend: { display: false },
          tooltip: { callbacks: { label: (context) => ` ${context.raw} / 100` } }
        }
      }
    })
  }

  // Turbo でページを移動したときに、古いグラフを片づける
  disconnect() {
    this.chart?.destroy()
  }
}
