import { Controller } from "@hotwired/stimulus"

// TASK-052: Workspace Reject Modal Controller
// Handles the reject modal for Team Leaders to enter rejection reason
export default class extends Controller {
  static targets = ["modal", "backdrop", "reason", "form"]
  static values = {
    requestId: Number,
    rejectUrl: String
  }

  connect() {
    // Bind escape key to close modal
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  handleKeydown(event) {
    if (event.key === "Escape" && this.isOpen()) {
      this.close()
    }
  }

  isOpen() {
    return this.hasModalTarget && !this.modalTarget.classList.contains("hidden")
  }

  open(event) {
    // Get request info from the clicked button
    const button = event.currentTarget
    this.requestIdValue = button.dataset.requestId
    this.rejectUrlValue = button.dataset.rejectUrl

    // Update form action
    if (this.hasFormTarget) {
      this.formTarget.action = this.rejectUrlValue
    }

    // Show modal
    if (this.hasModalTarget) {
      this.modalTarget.classList.remove("hidden")
      document.body.classList.add("overflow-hidden")

      // Focus on reason textarea
      if (this.hasReasonTarget) {
        setTimeout(() => this.reasonTarget.focus(), 100)
      }
    }
  }

  close() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")

      // Clear the reason field
      if (this.hasReasonTarget) {
        this.reasonTarget.value = ""
      }
    }
  }

  submit(event) {
    if (this.hasReasonTarget && !this.reasonTarget.value.trim()) {
      event.preventDefault()
      this.reasonTarget.classList.add("border-red-500", "ring-2", "ring-red-200")
      this.reasonTarget.placeholder = "Vui lòng nhập lý do từ chối..."
      this.reasonTarget.focus()
      return
    }

    // Allow form submission
    this.close()
  }
}
