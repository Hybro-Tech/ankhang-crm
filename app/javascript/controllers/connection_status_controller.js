import { Controller } from "@hotwired/stimulus"

/**
 * TASK-055b: Connection Status Indicator
 * Monitors WebSocket connection and displays status
 * 
 * Usage:
 *   <div data-controller="connection-status">
 *     <span data-connection-status-target="indicator"></span>
 *     <span data-connection-status-target="text"></span>
 *   </div>
 */
export default class extends Controller {
  static targets = ["indicator", "text"]

  connect() {
    this.checkConnection()
    // Periodic health check
    this.healthCheckInterval = setInterval(() => this.checkConnection(), 5000)
    
    // Listen for online/offline browser events
    window.addEventListener("online", () => this.updateStatus("connected"))
    window.addEventListener("offline", () => this.updateStatus("disconnected"))
  }

  disconnect() {
    if (this.healthCheckInterval) {
      clearInterval(this.healthCheckInterval)
    }
  }

  checkConnection() {
    // Method 1: Check browser online status
    if (!navigator.onLine) {
      this.updateStatus("disconnected")
      return
    }

    // Method 2: Check for active WebSocket connections via Turbo Cable
    // Turbo maintains WebSocket connections internally
    const cableConnections = document.querySelectorAll("turbo-cable-stream-source")
    
    if (cableConnections.length > 0) {
      // Check if any Turbo stream source is connected
      // Turbo cable sources have internal channel subscriptions
      let anyConnected = false
      
      cableConnections.forEach(source => {
        // If the element exists and is in DOM, Turbo considers it connected
        if (source.isConnected && source.channel) {
          anyConnected = true
        }
      })

      if (anyConnected) {
        this.updateStatus("connected")
        return
      }
    }

    // Method 3: Fallback - ping a quick health endpoint
    this.pingHealthCheck()
  }

  async pingHealthCheck() {
    try {
      const controller = new AbortController()
      const timeoutId = setTimeout(() => controller.abort(), 3000)
      
      const response = await fetch("/up", {
        method: "HEAD",
        signal: controller.signal,
        cache: "no-store"
      })
      
      clearTimeout(timeoutId)
      
      if (response.ok) {
        this.updateStatus("connected")
      } else {
        this.updateStatus("disconnected")
      }
    } catch (error) {
      this.updateStatus("disconnected")
    }
  }

  updateStatus(status) {
    if (this.currentStatus === status) return
    this.currentStatus = status

    if (this.hasIndicatorTarget) {
      this.indicatorTarget.className = this.getIndicatorClass(status)
    }

    if (this.hasTextTarget) {
      this.textTarget.textContent = this.getStatusText(status)
      this.textTarget.className = this.getTextClass(status)
    }

    // Dispatch custom event for other components
    this.element.dispatchEvent(new CustomEvent("connection-status-change", {
      detail: { status },
      bubbles: true
    }))
  }

  getIndicatorClass(status) {
    const baseClass = "h-2.5 w-2.5 rounded-full transition-colors duration-300"
    
    switch (status) {
      case "connected":
        return `${baseClass} bg-green-500 shadow-[0_0_6px_rgba(34,197,94,0.6)]`
      case "connecting":
        return `${baseClass} bg-yellow-400 animate-pulse`
      case "disconnected":
        return `${baseClass} bg-red-500`
      default:
        return `${baseClass} bg-gray-400`
    }
  }

  getStatusText(status) {
    switch (status) {
      case "connected":
        return "Trực tuyến"
      case "connecting":
        return "Đang kết nối..."
      case "disconnected":
        return "Mất kết nối"
      default:
        return ""
    }
  }

  getTextClass(status) {
    const baseClass = "text-xs font-medium hidden sm:block"
    
    switch (status) {
      case "connected":
        return `${baseClass} text-green-600`
      case "connecting":
        return `${baseClass} text-yellow-600`
      case "disconnected":
        return `${baseClass} text-red-600`
      default:
        return `${baseClass} text-gray-500`
    }
  }

  // Manual reconnect action
  reconnect() {
    this.updateStatus("connecting")
    // Force page visit to re-establish connections
    window.location.reload()
  }
}
