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

    // Use Rails Request.js to fetch Turbo Stream
    get(url, { responseKind: "turbo-stream" })
  }
}
