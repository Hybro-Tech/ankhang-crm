import { Controller } from "@hotwired/stimulus"

// Interaction Form Controller
// Handles form interactions including showing/hiding appointment datetime picker
export default class extends Controller {
  static targets = ["methodRadio", "appointmentFields", "scheduledAt", "content"]

  connect() {
    // Check initial state on page load
    this.updateAppointmentVisibility()
  }

  // Called when interaction method changes
  methodChanged(event) {
    this.updateAppointmentVisibility()
  }

  // Show/hide appointment fields based on selected method
  updateAppointmentVisibility() {
    const selectedMethod = this.element.querySelector('input[name="interaction[interaction_method]"]:checked')
    
    if (!this.hasAppointmentFieldsTarget) return

    if (selectedMethod && selectedMethod.value === "appointment") {
      this.appointmentFieldsTarget.classList.remove("hidden")
      // Set required for scheduled_at when appointment is selected
      if (this.hasScheduledAtTarget) {
        this.scheduledAtTarget.required = true
      }
    } else {
      this.appointmentFieldsTarget.classList.add("hidden")
      // Remove required when not appointment
      if (this.hasScheduledAtTarget) {
        this.scheduledAtTarget.required = false
        this.scheduledAtTarget.value = "" // Clear the value
      }
    }
  }
}
