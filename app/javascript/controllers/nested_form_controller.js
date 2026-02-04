import { Controller } from "@hotwired/stimulus"

// TASK-070: Dynamic nested form for UserServiceTypeLimits
// Handles add/remove of service type limits in user form
export default class extends Controller {
  static targets = ["template", "container", "addButton", "serviceTypeSelect"]
  static values = {
    index: Number
  }

  connect() {
    this.indexValue = this.containerTarget.querySelectorAll(".nested-fields:not(.hidden)").length
  }

  add(event) {
    event.preventDefault()
    
    const selectEl = this.serviceTypeSelectTarget
    const selectedOption = selectEl.options[selectEl.selectedIndex]
    
    if (!selectEl.value) {
      return
    }

    const serviceTypeId = selectEl.value
    const serviceTypeName = selectedOption.text

    // Check if already added
    const existingField = this.containerTarget.querySelector(`[data-service-type-id="${serviceTypeId}"]`)
    if (existingField && !existingField.classList.contains("hidden")) {
      alert("Loại nhu cầu này đã được thêm!")
      return
    }

    // Clone template and update
    const template = this.templateTarget.innerHTML
    const newIndex = this.indexValue++
    const newField = template
      .replace(/NEW_RECORD/g, newIndex)
      .replace(/SERVICE_TYPE_ID/g, serviceTypeId)
      .replace(/SERVICE_TYPE_NAME/g, serviceTypeName)

    this.containerTarget.insertAdjacentHTML("beforeend", newField)
    
    // Disable selected option
    selectedOption.disabled = true
    selectEl.value = ""

    // Update empty state
    this.updateEmptyState()
  }

  remove(event) {
    event.preventDefault()
    
    const field = event.target.closest(".nested-fields")
    const destroyField = field.querySelector("input[name*='_destroy']")
    const serviceTypeId = field.dataset.serviceTypeId

    if (destroyField) {
      // Existing record - mark for destruction
      destroyField.value = "1"
      field.classList.add("hidden")
    } else {
      // New record - just remove from DOM
      field.remove()
    }

    // Re-enable option in select
    if (serviceTypeId) {
      const option = this.serviceTypeSelectTarget.querySelector(`option[value="${serviceTypeId}"]`)
      if (option) {
        option.disabled = false
      }
    }

    this.updateEmptyState()
  }

  updateEmptyState() {
    const visibleFields = this.containerTarget.querySelectorAll(".nested-fields:not(.hidden)")
    const emptyState = this.element.querySelector(".empty-state")
    
    if (emptyState) {
      if (visibleFields.length === 0) {
        emptyState.classList.remove("hidden")
      } else {
        emptyState.classList.add("hidden")
      }
    }
  }
}
