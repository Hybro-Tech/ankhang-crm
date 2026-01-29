import { Application } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

// Override Turbo's confirm method to use custom dialog
// This replaces native browser confirm() with our beautiful modal
Turbo.setConfirmMethod((message, element) => {
  // Wait for controller to be available
  return new Promise((resolve) => {
    const checkController = () => {
      if (window.confirmDialog) {
        // Detect style preference (danger, success, info)
        let style = element?.getAttribute("data-confirm-style")

        // Auto-detect destructive actions if no style specified
        if (!style) {
          const isDestructive = element?.closest("form")?.method === "post" &&
            (element?.closest("[data-turbo-method='delete']") ||
              element?.formMethod === "delete" ||
              message.toLowerCase().includes("xóa") ||
              message.toLowerCase().includes("delete"))

          if (isDestructive) style = "danger"
        }

        window.confirmDialog.confirm(message, {
          title: element?.getAttribute("data-confirm-title") || (style === "danger" ? "Xác nhận xóa" : "Xác nhận"),
          confirmText: element?.getAttribute("data-confirm-btn") || (style === "danger" ? "Xóa" : "Xác nhận"),
          style: style || "info"
        }).then(resolve)
      } else {
        // Fallback to native confirm if controller not ready
        setTimeout(checkController, 50)
      }
    }
    checkController()
  })
})

export { application }
