import { Controller } from "@hotwired/stimulus"

// TASK-021: Phone check controller for real-time duplicate detection
export default class extends Controller {
  static targets = ["phone", "feedback"]
  static values = { url: String }

  connect () {
    this.timeout = null
  }

  disconnect () {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  check () {
    const phone = this.phoneTarget.value

    // Clear previous timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // Don't check if too short
    if (phone.replace(/\D/g, '').length < 10) {
      this.clearFeedback()
      return
    }

    // Debounce
    this.timeout = setTimeout(() => {
      this.performCheck(phone)
    }, 500)
  }

  async performCheck (phone) {
    try {
      const response = await fetch(`${this.urlValue}?phone=${encodeURIComponent(phone)}`)
      const data = await response.json()

      if (data.exists) {
        this.showError(data.message, data.contact_id)
      } else if (data.message) {
        this.showSuccess(data.message)
      } else {
        this.clearFeedback()
      }
    } catch (error) {
      console.error("Phone check error:", error)
    }
  }

  showError (message, contactId) {
    if (!this.hasFeedbackTarget) return

    this.feedbackTarget.innerHTML = `
      <div class="mt-1 flex items-center gap-2 text-red-600 text-sm">
        <i class="fa-solid fa-circle-exclamation"></i>
        <span>${message}</span>
        ${contactId ? `<a href="/contacts/${contactId}" class="underline hover:no-underline">Xem</a>` : ''}
      </div>
    `
    this.phoneTarget.classList.add("border-red-500", "ring-red-500")
    this.phoneTarget.classList.remove("border-gray-300", "border-green-500")
  }

  showSuccess (message) {
    if (!this.hasFeedbackTarget) return

    this.feedbackTarget.innerHTML = `
      <div class="mt-1 flex items-center gap-2 text-green-600 text-sm">
        <i class="fa-solid fa-check-circle"></i>
        <span>${message}</span>
      </div>
    `
    this.phoneTarget.classList.add("border-green-500")
    this.phoneTarget.classList.remove("border-gray-300", "border-red-500")
  }

  clearFeedback () {
    if (!this.hasFeedbackTarget) return

    this.feedbackTarget.innerHTML = ""
    this.phoneTarget.classList.remove("border-red-500", "border-green-500")
    this.phoneTarget.classList.add("border-gray-300")
  }
}
