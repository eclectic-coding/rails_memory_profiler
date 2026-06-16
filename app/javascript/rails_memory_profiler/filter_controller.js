import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "row", "clearButton"]

  connect() {
    this._updateClear()
  }

  filter() {
    const query = this.inputTarget.value.toLowerCase()
    this.rowTargets.forEach(row => {
      const name = (row.dataset.controllerName || "").toLowerCase()
      row.hidden = query.length > 0 && !name.includes(query)
    })
    this._updateClear()
  }

  clear() {
    this.inputTarget.value = ""
    this.rowTargets.forEach(row => { row.hidden = false })
    this._updateClear()
  }

  _updateClear() {
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.hidden = this.inputTarget.value.length === 0
    }
  }
}