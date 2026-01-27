import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["phoneSection", "zaloSection", "phoneInput", "zaloInput", "modePhoneBtn", "modeZaloBtn", "identityInput"]

  connect () {
    this.setMode("phone") // Limit logic to set default
  }

  switchToPhone (event) {
    if (event) event.preventDefault()
    this.setMode("phone")
  }

  switchToZalo (event) {
    if (event) event.preventDefault()
    this.setMode("zalo")
  }

  setMode (mode) {
    if (mode === "phone") {
      // UI State
      this.phoneSectionTarget.classList.remove("hidden")
      this.zaloSectionTarget.classList.add("hidden")

      // Button State
      this.modePhoneBtnTarget.classList.add("bg-brand-blue", "text-white", "shadow-sm")
      this.modePhoneBtnTarget.classList.remove("text-gray-500", "hover:text-gray-900")

      this.modeZaloBtnTarget.classList.remove("bg-brand-blue", "text-white", "shadow-sm")
      this.modeZaloBtnTarget.classList.add("text-gray-500", "hover:text-gray-900")

      // Focus
      setTimeout(() => this.phoneInputTarget.focus(), 50)

      // Set Identity Context for Backend (Optional, handled by specific inputs)
      this.identityInputTarget.value = "phone"

    } else {
      // UI State
      this.phoneSectionTarget.classList.add("hidden")
      this.zaloSectionTarget.classList.remove("hidden")

      // Button State
      this.modeZaloBtnTarget.classList.add("bg-brand-blue", "text-white", "shadow-sm")
      this.modeZaloBtnTarget.classList.remove("text-gray-500", "hover:text-gray-900")

      this.modePhoneBtnTarget.classList.remove("bg-brand-blue", "text-white", "shadow-sm")
      this.modePhoneBtnTarget.classList.add("text-gray-500", "hover:text-gray-900")

      // Focus
      setTimeout(() => this.zaloInputTarget.focus(), 50)

      // Set Identity Context
      this.identityInputTarget.value = "zalo"
    }
  }
}
