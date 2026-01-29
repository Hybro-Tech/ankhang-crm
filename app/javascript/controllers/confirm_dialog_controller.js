import { Controller } from "@hotwired/stimulus"

// Custom confirm dialog controller - replaces native browser confirm()
// Connects to data-controller="confirm-dialog"
export default class extends Controller {
  static targets = ["dialog", "title", "message", "confirmButton", "cancelButton", "backdrop", "panel", "iconWrapper", "warningIcon", "successIcon", "infoIcon"]
  static values = {
    title: { type: String, default: "Xác nhận" },
    confirmText: { type: String, default: "Xác nhận" },
    cancelText: { type: String, default: "Hủy" }
  }

  // Store the resolver for the promise
  #resolver = null
  #triggerElement = null // Element that triggered the dialog

  connect () {
    // Make this controller globally accessible for Turbo confirm override
    window.confirmDialog = this
  }

  disconnect () {
    window.confirmDialog = null
  }

  // Main method to show confirm dialog - returns a Promise
  confirm (message, options = {}) {
    this.#triggerElement = document.activeElement // Save currently focused element

    return new Promise((resolve) => {
      this.#resolver = resolve

      // Set content
      const title = options.title || this.titleValue
      const confirmText = options.confirmText || this.confirmTextValue
      const style = options.style || "info" // danger, success, info

      this.titleTarget.textContent = title
      this.messageTarget.textContent = message
      this.confirmButtonTarget.textContent = confirmText

      // Reset states
      this.#hideAllIcons()

      // Apply styles based on type
      const baseBtnClass = "inline-flex w-full justify-center rounded-md px-3 py-2 text-sm font-semibold text-white shadow-sm sm:ml-3 sm:w-auto transition-colors duration-200"

      switch (style) {
        case "danger":
          this.confirmButtonTarget.className = `${baseBtnClass} bg-red-600 hover:bg-red-500`
          this.iconWrapperTarget.className = "mx-auto flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10 transition-colors duration-200"
          if (this.hasWarningIconTarget) this.warningIconTarget.classList.remove("hidden")
          break

        case "success":
          this.confirmButtonTarget.className = `${baseBtnClass} bg-green-600 hover:bg-green-500`
          this.iconWrapperTarget.className = "mx-auto flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full bg-green-100 sm:mx-0 sm:h-10 sm:w-10 transition-colors duration-200"
          if (this.hasSuccessIconTarget) this.successIconTarget.classList.remove("hidden")
          break

        default: // info
          this.confirmButtonTarget.className = `${baseBtnClass} bg-blue-600 hover:bg-blue-500`
          this.iconWrapperTarget.className = "mx-auto flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full bg-blue-100 sm:mx-0 sm:h-10 sm:w-10 transition-colors duration-200"
          if (this.hasInfoIconTarget) this.infoIconTarget.classList.remove("hidden")
          break
      }

      // Show dialog with animation
      this.dialogTarget.classList.remove("hidden")

      // Accessibility attributes
      this.dialogTarget.setAttribute("aria-hidden", "false")
      document.body.classList.add("overflow-hidden") // Prevent body scroll

      // Animate in
      requestAnimationFrame(() => {
        this.backdropTarget.classList.remove("opacity-0")
        this.backdropTarget.classList.add("opacity-100")

        this.panelTarget.classList.remove("opacity-0", "translate-y-4", "sm:translate-y-0", "sm:scale-95")
        this.panelTarget.classList.add("opacity-100", "translate-y-0", "sm:scale-100")
      })

      // Focus management: Focus cancel button by default for safety
      setTimeout(() => {
        if (this.hasCancelButtonTarget) {
          this.cancelButtonTarget.focus()
        }
      }, 50)
    })
  }

  // User clicked confirm
  confirmAction () {
    this.#close(true)
  }

  // User clicked cancel or pressed Escape
  cancel () {
    this.#close(false)
  }

  // Close on backdrop click (optional, can be disabled if modal)
  closeOnBackdrop (event) {
    if (event.target === event.currentTarget) {
      this.cancel()
    }
  }

  // Close on Escape key
  closeOnEscape (event) {
    if (event.key === "Escape") {
      event.preventDefault()
      this.cancel()
    }
    // Trap focus with Tab key
    if (event.key === "Tab") {
      this.#trapFocus(event)
    }
  }

  #close (result) {
    // Animate out
    this.backdropTarget.classList.remove("opacity-100")
    this.backdropTarget.classList.add("opacity-0")

    this.panelTarget.classList.remove("opacity-100", "translate-y-0", "sm:scale-100")
    this.panelTarget.classList.add("opacity-0", "translate-y-4", "sm:translate-y-0", "sm:scale-95")

    // Hide after animation
    setTimeout(() => {
      this.dialogTarget.classList.add("hidden")
      this.dialogTarget.setAttribute("aria-hidden", "true")
      document.body.classList.remove("overflow-hidden") // Restore body scroll

      // Return focus to trigger element
      if (this.#triggerElement && document.body.contains(this.#triggerElement)) {
        this.#triggerElement.focus()
      }
    }, 200)

    // Resolve the promise
    if (this.#resolver) {
      this.#resolver(result)
      this.#resolver = null
    }
  }

  // Keep focus inside dialog
  #trapFocus (event) {
    const focusableElements = this.dialogTarget.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])')
    const firstElement = focusableElements[0]
    const lastElement = focusableElements[focusableElements.length - 1]

    if (event.shiftKey) {
      if (document.activeElement === firstElement) {
        lastElement.focus()
        event.preventDefault()
      }
    } else {
      if (document.activeElement === lastElement) {
        firstElement.focus()
        event.preventDefault()
      }
    }
  }

  #hideAllIcons () {
    if (this.hasWarningIconTarget) this.warningIconTarget.classList.add("hidden")
    if (this.hasSuccessIconTarget) this.successIconTarget.classList.add("hidden")
    if (this.hasInfoIconTarget) this.infoIconTarget.classList.add("hidden")
  }
}
