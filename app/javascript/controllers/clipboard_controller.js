import { Controller } from "@hotwired/stimulus"

// Clipboard controller for copying text to clipboard
// Usage: data-controller="clipboard" data-clipboard-text-value="text to copy" data-action="click->clipboard#copy"
export default class extends Controller {
  static values = { text: String }

  copy (event) {
    event.preventDefault()

    if (!this.textValue) {
      console.warn("Clipboard: No text to copy")
      return
    }

    navigator.clipboard.writeText(this.textValue).then(() => {
      // Show success feedback
      this.showFeedback("Đã copy!")
    }).catch((err) => {
      console.error("Failed to copy:", err)
      // Fallback for older browsers
      this.fallbackCopy()
    })
  }

  showFeedback (message) {
    const originalTitle = this.element.getAttribute("title")
    const originalHTML = this.element.innerHTML

    // Change to checkmark
    this.element.innerHTML = '<i class="fa-solid fa-check"></i>'
    this.element.setAttribute("title", message)
    this.element.classList.add("text-green-500")

    // Reset after 1.5 seconds
    setTimeout(() => {
      this.element.innerHTML = originalHTML
      if (originalTitle) {
        this.element.setAttribute("title", originalTitle)
      }
      this.element.classList.remove("text-green-500")
    }, 1500)
  }

  fallbackCopy () {
    const textArea = document.createElement("textarea")
    textArea.value = this.textValue
    textArea.style.position = "fixed"
    textArea.style.left = "-9999px"
    document.body.appendChild(textArea)
    textArea.select()

    try {
      document.execCommand("copy")
      this.showFeedback("Đã copy!")
    } catch (err) {
      console.error("Fallback copy failed:", err)
    }

    document.body.removeChild(textArea)
  }
}
