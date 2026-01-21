import { Controller } from "@hotwired/stimulus"

// Sidebar controller - handles mobile sidebar toggle
export default class extends Controller {
  connect() {
    this.sidebar = document.getElementById("sidebar")
    this.overlay = document.getElementById("sidebar-overlay")
  }

  toggle() {
    this.sidebar.classList.toggle("-translate-x-full")
    this.overlay.classList.toggle("hidden")
  }

  close() {
    this.sidebar.classList.add("-translate-x-full")
    this.overlay.classList.add("hidden")
  }
}
