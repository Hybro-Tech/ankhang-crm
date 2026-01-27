import { Controller } from "@hotwired/stimulus"

// TASK-020: Filter form with debounce for search
export default class extends Controller {
  static targets = ["form"]

  connect () {
    this.timeout = null
  }

  disconnect () {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  // Submit form when dropdown changes
  submit () {
    this.element.requestSubmit()
  }

  // Debounce for text input
  debounce () {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    this.timeout = setTimeout(() => {
      this.submit()
    }, 300)
  }
}
