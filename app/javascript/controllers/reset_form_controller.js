import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  reset () {
    this.element.reset()
    // Focus on the first input (Phone)
    const firstInput = this.element.querySelector('input:not([type="hidden"])')
    if (firstInput) firstInput.focus()
  }
}
