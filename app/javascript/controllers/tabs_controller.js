import { Controller } from "@hotwired/stimulus"

// Tabs controller for User Form
// Handles tab switching with smooth transitions
export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = {
    activeTab: { type: Number, default: 0 }
  }

  connect() {
    this.showTab(this.activeTabValue)
  }

  switch(event) {
    event.preventDefault()
    const tabIndex = parseInt(event.currentTarget.dataset.tabIndex)
    this.activeTabValue = tabIndex
    this.showTab(tabIndex)
  }

  showTab(index) {
    // Update tab buttons
    this.tabTargets.forEach((tab, i) => {
      if (i === index) {
        tab.classList.remove("text-gray-500", "border-transparent", "hover:text-gray-700", "hover:border-gray-300")
        tab.classList.add("text-brand-blue", "border-brand-blue")
      } else {
        tab.classList.remove("text-brand-blue", "border-brand-blue")
        tab.classList.add("text-gray-500", "border-transparent", "hover:text-gray-700", "hover:border-gray-300")
      }
    })

    // Update panels
    this.panelTargets.forEach((panel, i) => {
      if (i === index) {
        panel.classList.remove("hidden")
        panel.classList.add("animate-fade-in")
      } else {
        panel.classList.add("hidden")
        panel.classList.remove("animate-fade-in")
      }
    })
  }
}
