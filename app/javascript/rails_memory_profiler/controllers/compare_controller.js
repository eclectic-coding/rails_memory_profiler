import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "bar", "link"]
  static values  = { path: String }

  toggle(event) {
    const checked = this.checkboxTargets.filter(cb => cb.checked)
    if (checked.length > 2) {
      const oldest = checked.find(cb => cb !== event.target)
      if (oldest) oldest.checked = false
    }
    this._update()
  }

  _update() {
    const checked = this.checkboxTargets.filter(cb => cb.checked)
    const ready   = checked.length === 2

    this.barTarget.hidden = !ready

    if (ready) {
      const query = checked.map(cb => `ids[]=${encodeURIComponent(cb.value)}`).join("&")
      this.linkTarget.href = `${this.pathValue}?${query}`
    }
  }
}