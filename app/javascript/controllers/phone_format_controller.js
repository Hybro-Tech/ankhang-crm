import { Controller } from "@hotwired/stimulus"

// TASK-049: Phone input formatting to match placeholder (09xx xxx xxx)
export default class extends Controller {
  connect() {
    this.format()
  }

  format() {
    const input = this.element
    // Strip non-digits
    let value = input.value.replace(/\D/g, '')
    
    // Limit to 10 digits (Standard VN Mobile: 09x xxx xxxx or 08x...)
    // Placeholder format: 09xx xxx xxx (4-3-3 = 10 digits)
    if (value.length > 10) value = value.slice(0, 10)

    let formattedValue = ""
    
    if (value.length > 0) {
      formattedValue = value.substring(0, 4)
    }
    
    if (value.length > 4) {
      formattedValue += " " + value.substring(4, 7)
    }
    
    if (value.length > 7) {
      formattedValue += " " + value.substring(7, 10)
    }
    
    // Only update if changed to avoid cursor jumping if unnecessary
    // Note: Simple replacement always jumps cursor to end if typing in middle.
    // For this specific task ("khi nhập thì cũng sẽ có khoảng cách y như placeholder"),
    // append-only typing is the 90% use case.
    if (input.value !== formattedValue) {
      input.value = formattedValue
    }
  }
}
