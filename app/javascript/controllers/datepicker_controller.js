import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

// Connects to data-controller="datepicker"
export default class extends Controller {
  static values = {
    enableTime: { type: Boolean, default: false },
    noCalendar: { type: Boolean, default: false },
    dateFormat: { type: String, default: "Y-m-d" }, // ISO format for backend/value
    timeFormat: { type: String, default: "H:i" },
    displayFormat: { type: String, default: "d/m/Y" }, // Display format for user
    defaultDate: { type: String, default: "" },
    minDate: { type: String, default: "" },
    maxDate: { type: String, default: "" }
  }

  connect() {
    // Determine formats
    let valueFormat = this.dateFormatValue;
    let altFormat = this.displayFormatValue;
    
    if (this.noCalendarValue) {
      valueFormat = this.timeFormatValue;
      altFormat = this.timeFormatValue;
    } else if (this.enableTimeValue) {
      valueFormat = `${this.dateFormatValue} ${this.timeFormatValue}`; // Y-m-d H:i
      altFormat = `${this.displayFormatValue} ${this.timeFormatValue}`; // d/m/Y H:i
    }

    const config = {
      // locale: Use default English for now (VN locale causes 404)
      enableTime: this.enableTimeValue,
      noCalendar: this.noCalendarValue,
      dateFormat: valueFormat,
      defaultDate: this.defaultDateValue || this.element.value,
      minDate: this.minDateValue,
      maxDate: this.maxDateValue,
      allowInput: true,
      altInput: true,
      altFormat: altFormat,
      time_24hr: true,
      onChange: (selectedDates, dateStr, instance) => {
        // Trigger native change event for other listeners (e.g. validatSaturday)
        this.element.dispatchEvent(new Event('change', { bubbles: true }));
      }
    }

    this.fp = flatpickr(this.element, config)
  }

  disconnect() {
    if (this.fp) {
      this.fp.destroy()
    }
  }
}
