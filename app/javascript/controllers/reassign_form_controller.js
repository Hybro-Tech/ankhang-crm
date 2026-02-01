import { Controller } from "@hotwired/stimulus"

// TASK-052: Reassign Form Controller
// Handles toggle between reassign and unassign modes
export default class extends Controller {
  static targets = ["typeToggle", "reassignBtn", "unassignBtn", "toUserField", "requestType"]

  connect() {
    // Default to reassign mode
    this.selectReassign()
  }

  selectReassign() {
    // Update button styles
    this.reassignBtnTarget.classList.add("bg-white", "text-blue-700", "shadow-sm")
    this.reassignBtnTarget.classList.remove("text-gray-600", "hover:bg-gray-100")
    this.reassignBtnTarget.setAttribute("aria-pressed", "true")

    this.unassignBtnTarget.classList.remove("bg-white", "text-red-700", "shadow-sm")
    this.unassignBtnTarget.classList.add("text-gray-600", "hover:bg-gray-100")
    this.unassignBtnTarget.setAttribute("aria-pressed", "false")

    // Show user selection field
    this.toUserFieldTarget.classList.remove("hidden")

    // Update hidden input if exists
    if (this.hasRequestTypeTarget) {
      this.requestTypeTarget.value = "reassign"
    }
  }

  selectUnassign() {
    // Update button styles
    this.unassignBtnTarget.classList.add("bg-white", "text-red-700", "shadow-sm")
    this.unassignBtnTarget.classList.remove("text-gray-600", "hover:bg-gray-100")
    this.unassignBtnTarget.setAttribute("aria-pressed", "true")

    this.reassignBtnTarget.classList.remove("bg-white", "text-blue-700", "shadow-sm")
    this.reassignBtnTarget.classList.add("text-gray-600", "hover:bg-gray-100")
    this.reassignBtnTarget.setAttribute("aria-pressed", "false")

    // Hide user selection field (not needed for unassign)
    this.toUserFieldTarget.classList.add("hidden")

    // Clear the select value
    const select = this.toUserFieldTarget.querySelector("select")
    if (select) {
      select.value = ""
    }

    // Update hidden input if exists
    if (this.hasRequestTypeTarget) {
      this.requestTypeTarget.value = "unassign"
    }
  }
}
