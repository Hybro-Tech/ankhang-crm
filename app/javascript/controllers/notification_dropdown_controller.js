import { Controller } from "@hotwired/stimulus"

// TASK-035: Controller to refresh notification dropdown when bell is clicked
export default class extends Controller {
  refresh() {
    // Find the turbo frame and reload it
    const frame = document.getElementById("notification_dropdown_content")
    if (frame) {
      // Force reload by setting src again
      const currentSrc = frame.getAttribute("src")
      if (currentSrc) {
        frame.src = currentSrc
      }
    }
  }
}
