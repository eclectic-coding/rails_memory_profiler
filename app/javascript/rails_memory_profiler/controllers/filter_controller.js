import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["controllerInput", "actionInput", "methodSelect", "row", "clearButton"]

  connect() {
    this._updateClear()
  }

  filter() {
    const controller = this.controllerInputTarget.value.toLowerCase()
    const action     = this.actionInputTarget.value.toLowerCase()
    const method     = this.methodSelectTarget.value

    this.rowTargets.forEach(row => {
      const matchController = !controller || (row.dataset.controllerName || "").toLowerCase().includes(controller)
      const matchAction     = !action     || (row.dataset.actionName     || "").toLowerCase().includes(action)
      const matchMethod     = !method     || (row.dataset.httpMethod     || "") === method
      row.hidden = !(matchController && matchAction && matchMethod)
    })
    this._updateClear()
  }

  clear() {
    this.controllerInputTarget.value = ""
    this.actionInputTarget.value     = ""
    this.methodSelectTarget.value    = ""
    this.rowTargets.forEach(row => { row.hidden = false })
    this._updateClear()
  }

  _updateClear() {
    if (!this.hasClearButtonTarget) return
    const active = this.controllerInputTarget.value.length > 0 ||
                   this.actionInputTarget.value.length     > 0 ||
                   this.methodSelectTarget.value.length    > 0
    this.clearButtonTarget.hidden = !active
  }
}