import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["allCheckbox"]

  connect() {
    this.updateAllCheckboxes()
  }

  toggleCategory(event) {
    const row = event.target.closest('tr')
    const checkboxes = row.querySelectorAll('.permission-checkbox')
    const isChecked = event.target.checked

    checkboxes.forEach(checkbox => {
      checkbox.checked = isChecked
    })
  }
  
  // Optional: Update 'All' checkbox state based on individual checkboxes
  updateAllCheckboxes() {
    // Implementation for syncing state if needed in future
  }
}
