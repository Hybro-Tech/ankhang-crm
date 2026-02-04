import { Controller } from "@hotwired/stimulus"

// Collapse controller for expandable sections (e.g., password change section)
export default class extends Controller {
  static targets = ["content", "icon"]

  toggle(event) {
    event.preventDefault()
    
    const content = this.contentTarget
    const icon = this.iconTarget

    if (content.classList.contains("hidden")) {
      content.classList.remove("hidden")
      icon.classList.add("rotate-180")
    } else {
      content.classList.add("hidden")
      icon.classList.remove("rotate-180")
    }
  }
}
