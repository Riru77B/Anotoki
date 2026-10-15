# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# Chart.js は1ファイルで完結する UMD 版を使う（jspm 版は別ファイルを読み込むため importmap で動かない）
pin "chart.js", to: "chart.umd.min.js" # @4.5.1
