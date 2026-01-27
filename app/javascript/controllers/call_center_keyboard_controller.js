import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  handleKeydown (event) {
    const key = event.key.toLowerCase()

    // Alt/Option + N: New (Reset Form)
    if (event.altKey && key === 'n') {
      event.preventDefault()
      const resetButton = this.element.querySelector('[data-action*="reset-form#reset"]')
      if (resetButton) resetButton.click()
    }

    // Alt/Option + S: Save
    if (event.altKey && key === 's') {
      event.preventDefault()
      this.element.requestSubmit()
    }
  }
}
