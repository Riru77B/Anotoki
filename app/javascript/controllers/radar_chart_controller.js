import { Controller } from "@hotwired/stimulus"
import "chart.js" // UMD 版なので、読み込むと window.Chart が使えるようになる（部品も登録済み）

// 7つの診断軸のスコアをレーダーチャートで描く
// 使い方: data-controller="radar-chart" data-radar-chart-labels-value="[...]" data-radar-chart-scores-value="[...]"
//         周りから見たスコアも重ねるときは data-radar-chart-other-scores-value="[...]" を付ける
export default class extends Controller {
  static targets = ["canvas"]
  static values = { labels: Array, scores: Array, otherScores: { type: Array, default: [] } }

  connect() {
    const hasOthers = this.otherScoresValue.length > 0

    this.chart = new window.Chart(this.canvasTarget, {
      type: "radar",
      data: {
        labels: this.labelsValue,
        datasets: [
          this.dataset("自分", this.scoresValue, "249, 115, 22"),
          ...(hasOthers ? [this.dataset("周り", this.otherScoresValue, "14, 165, 233", [6, 4])] : [])
        ]
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
          legend: { display: hasOthers, position: "bottom" },
          tooltip: { callbacks: { label: (context) => ` ${context.dataset.label} ${context.raw} / 100` } }
        }
      }
    })
  }

  dataset(label, data, rgb, borderDash = []) {
    return {
      label,
      data,
      backgroundColor: `rgba(${rgb}, 0.15)`,
      borderColor: `rgb(${rgb})`,
      borderDash,
      borderWidth: 2,
      pointBackgroundColor: `rgb(${rgb})`,
      pointRadius: 4
    }
  }

  // Turbo でページを移動したときに、古いグラフを片づける
  disconnect() {
    this.chart?.destroy()
  }
}
