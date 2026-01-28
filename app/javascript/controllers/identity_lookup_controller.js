import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
  static values = { type: String }

  connect () {
    this.timeout = null
  }

  // Called on input event
  search () {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.performSearch()
    }, 500) // Debounce 500ms
  }

  // Called on blur event (immediate check)
  check () {
    clearTimeout(this.timeout)
    this.performSearch()
  }

  performSearch () {
    const value = this.element.value.trim()

    // If empty -> Do nothing (or restore list? Restoring list requires another endpoint, 
    // for now let's just not search if empty. The Context Panel stays as is.)
    // If empty -> Restore recent list
    if (value.length < 3) {
      if (value.length === 0) {
        get("/contacts/recent", { responseKind: "turbo-stream" })
      }
      return
    }

    const paramName = this.typeValue === "phone" ? "phone" : "zalo_id"
    const url = `/contacts/check_identity?${paramName}=${encodeURIComponent(value)}`

    // Use Rails Request.js to fetch Turbo Stream (Context Panel)
    get(url, { responseKind: "turbo-stream" })

    // Fetch JSON for Input Validation (Visual Feedback)
    fetch(url, { headers: { "Accept": "application/json" } })
      .then(response => response.json())
      .then(data => {
        this.updateInputValidation(data.exists)
      })
      .catch(error => console.error("Identity lookup error:", error))
  }

  updateInputValidation (exists) {
    // Remove all validation classes first
    const input = this.element
    const redClasses = ["border-red-500", "focus:border-red-500", "focus:ring-red-500", "text-red-600"]
    const greenClasses = ["border-green-500", "focus:border-green-500", "focus:ring-green-500", "text-green-600"]
    const defaultClasses = ["border-gray-300", "focus:border-brand-blue", "focus:ring-brand-blue", "text-gray-900"]

    input.classList.remove(...redClasses, ...greenClasses, ...defaultClasses)

    if (exists) {
      input.classList.add(...redClasses)
      // Show local warning if any
      const warning = input.parentElement.parentElement.querySelector('#phone_duplicate_warning')
      if (warning) warning.classList.remove('hidden')
    } else {
      input.classList.add(...greenClasses)
      const warning = input.parentElement.parentElement.querySelector('#phone_duplicate_warning')
      if (warning) warning.classList.add('hidden')
    }
  }
}
