import { Controller } from "@hotwired/stimulus"
// TomSelect is loaded globally via script tag in application.html.erb

// TomSelect controller for enhanced select dropdowns
// Usage:
//   Single select: data-controller="tom-select"
//   Multi-select: data-controller="tom-select" data-tom-select-multiple-value="true"
//   With placeholder: data-tom-select-placeholder-value="Chọn..."
//   Allow create: data-tom-select-create-value="true"

export default class extends Controller {
  static values = {
    multiple: { type: Boolean, default: false },
    placeholder: { type: String, default: "Chọn..." },
    create: { type: Boolean, default: false },
    maxItems: { type: Number, default: null },
    plugins: { type: Array, default: [] }
  }

  connect () {
    this.initTomSelect()
  }

  initTomSelect () {
    const isMultiple = this.multipleValue || this.element.hasAttribute("multiple")

    // Default plugins for multi-select
    let plugins = this.pluginsValue
    if (isMultiple && plugins.length === 0) {
      plugins = ["remove_button", "clear_button"]
    }

    const config = {
      plugins: plugins,
      placeholder: this.placeholderValue,
      allowEmptyOption: true,
      create: this.createValue,
      maxItems: isMultiple ? this.maxItemsValue : 1,
      persist: false,
      // UI/UX improvements
      closeAfterSelect: !isMultiple,
      hideSelected: isMultiple,
      // Search settings
      selectOnTab: true,
      // Styling
      render: {
        option: (data, escape) => {
          return `<div class="py-2 px-3 cursor-pointer hover:bg-brand-blue/10">${escape(data.text)}</div>`
        },
        item: (data, escape) => {
          if (isMultiple) {
            return `<div class="inline-flex items-center gap-1 bg-brand-blue text-white text-sm px-2 py-1 rounded-md mr-1 mb-1">${escape(data.text)}</div>`
          }
          return `<div>${escape(data.text)}</div>`
        },
        no_results: () => {
          return '<div class="py-2 px-3 text-gray-500 italic">Không tìm thấy kết quả</div>'
        }
      },
      // Callbacks
      onInitialize: () => {
        // Add custom classes to wrapper
        if (this.tomSelect) {
          this.tomSelect.wrapper.classList.add("tom-select-wrapper")
        }
      }
    }

    // Initialize
    this.tomSelect = new TomSelect(this.element, config)

    // Apply custom styling
    this.applyCustomStyles()
  }

  applyCustomStyles () {
    if (!this.tomSelect) return

    const wrapper = this.tomSelect.wrapper
    const control = this.tomSelect.control
    const dropdown = this.tomSelect.dropdown

    // Wrapper styles
    wrapper.classList.add("w-full")

    // Control (input area) styles
    control.classList.add(
      "border", "border-gray-300", "rounded-lg", "px-3", "py-2",
      "focus-within:ring-2", "focus-within:ring-brand-blue", "focus-within:border-brand-blue",
      "bg-white", "min-h-[42px]", "flex", "items-center", "flex-wrap", "gap-1"
    )

    // Dropdown styles
    dropdown.classList.add(
      "border", "border-gray-200", "rounded-lg", "shadow-lg",
      "bg-white", "mt-1", "max-h-60", "overflow-y-auto", "z-50"
    )
  }

  disconnect () {
    if (this.tomSelect) {
      this.tomSelect.destroy()
    }
  }

  // Public method to refresh options
  refresh () {
    if (this.tomSelect) {
      this.tomSelect.sync()
    }
  }

  // Public method to clear selection
  clear () {
    if (this.tomSelect) {
      this.tomSelect.clear()
    }
  }
}
