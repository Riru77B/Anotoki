import { Controller } from "@hotwired/stimulus"

// 入力欄の文字をクリップボードにコピーし、ボタンの文字を一時的に「コピーしました」に変える
// 使い方: data-controller="clipboard" / data-clipboard-target="source" / data-action="clipboard#copy"
export default class extends Controller {
  static targets = ["source", "button"]

  async copy() {
    const text = this.sourceTarget.value
    try {
      await navigator.clipboard.writeText(text)
    } catch {
      // クリップボードが使えない環境では、文字を選択状態にして手動でコピーしてもらう
      this.sourceTarget.select()
      return
    }
    const original = this.buttonTarget.textContent
    this.buttonTarget.textContent = "コピーしました"
    setTimeout(() => { this.buttonTarget.textContent = original }, 2000)
  }
}
