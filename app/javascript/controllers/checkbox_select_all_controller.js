import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="checkbox-select-all"
export default class extends Controller {
  static targets = ["parent", "child"]

  connect() {
    this.updateParentState()
  }

  toggleChildren(event) {
    const isChecked = event.target.checked
    this.childTargets.forEach(child => {
      child.checked = isChecked
    })
  }

  updateParentState() {
    if (this.childTargets.length === 0) return

    const allChecked = this.childTargets.every(child => child.checked)
    const someChecked = this.childTargets.some(child => child.checked)

    this.parentTarget.checked = allChecked
    this.parentTarget.indeterminate = someChecked && !allChecked
  }
}
