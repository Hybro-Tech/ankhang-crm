import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="workspace-tabs"
export default class extends Controller {
  static targets = ["tab", "frame"]
  static outlets = ["slide-over"]

  connect () {
    // Set initial active tab
    if (this.hasTabTarget) {
      this.setActiveTab(this.tabTargets[0])
    }
  }

  switchTab (event) {
    const button = event.currentTarget
    const tabName = button.dataset.tab

    // Update active state
    this.setActiveTab(button)

    // Load tab content via Turbo
    const url = `/sales/workspace/tab_${tabName}`
    this.frameTarget.src = url
  }

  setActiveTab (activeButton) {
    this.tabTargets.forEach(tab => {
      tab.setAttribute("aria-selected", "false")
    })
    activeButton.setAttribute("aria-selected", "true")
  }

  showPreview (event) {
    // Prevent if clicking on action buttons
    if (event.target.closest('a') || event.target.closest('button') || event.target.closest('form')) {
      return
    }

    const row = event.currentTarget
    const previewUrl = row.dataset.previewUrl

    if (previewUrl) {
      const previewFrame = document.getElementById("contact_preview_frame")
      if (previewFrame) {
        previewFrame.src = previewUrl

        // Open the slide-over if outlet is present
        if (this.hasSlideOverOutlet) {
          this.slideOverOutlet.open()
        }
      }
    }
  }
}
