import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "backdrop", "panel"]

  connect () {
    this.close() // Ensure hidden on connect
    this.boundCloseOnEsc = this.closeOnEsc.bind(this)
    document.addEventListener("keydown", this.boundCloseOnEsc)
  }

  disconnect () {
    document.removeEventListener("keydown", this.boundCloseOnEsc)
  }

  open () {
    this.containerTarget.classList.remove("hidden")

    // Animate in
    requestAnimationFrame(() => {
      this.backdropTarget.classList.remove("opacity-0")
      this.backdropTarget.classList.add("opacity-100")

      this.panelTarget.classList.remove("translate-x-full")
      this.panelTarget.classList.add("translate-x-0")
    })
  }

  close () {
    // Animate out
    this.backdropTarget.classList.remove("opacity-100")
    this.backdropTarget.classList.add("opacity-0")

    this.panelTarget.classList.remove("translate-x-0")
    this.panelTarget.classList.add("translate-x-full")

    // Hide container after animation
    setTimeout(() => {
      this.containerTarget.classList.add("hidden")
    }, 500) // Match duration-500
  }

  closeOnEsc (event) {
    if (event.key === "Escape" && !this.containerTarget.classList.contains("hidden")) {
      this.close()
    }
  }
}
