// Highlight Controller - scrolls to and highlights an element based on URL param
// Usage: data-controller="highlight" on container element
// URL param: ?highlight=element_id

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.checkHighlight()
  }

  checkHighlight() {
    const urlParams = new URLSearchParams(window.location.search)
    const highlightId = urlParams.get('highlight')

    if (highlightId) {
      // Small delay to ensure DOM is ready
      setTimeout(() => this.highlightElement(highlightId), 100)
    }
  }

  highlightElement(elementId) {
    const element = document.getElementById(elementId)
    if (!element) {
      console.warn(`[Highlight] Element #${elementId} not found`)
      return
    }

    // Scroll to element
    element.scrollIntoView({ behavior: 'smooth', block: 'center' })

    // Add highlight animation
    element.classList.add('ring-4', 'ring-brand-primary', 'ring-opacity-75', 'bg-yellow-50')

    // Flash effect
    element.animate([
      { backgroundColor: 'rgb(254 249 195)' }, // yellow-100
      { backgroundColor: 'rgb(255 255 255)' }, // white
      { backgroundColor: 'rgb(254 249 195)' },
      { backgroundColor: 'rgb(255 255 255)' }
    ], {
      duration: 1500,
      iterations: 2
    })

    // Remove highlight after animation
    setTimeout(() => {
      element.classList.remove('ring-4', 'ring-brand-primary', 'ring-opacity-75', 'bg-yellow-50')
    }, 3500)

    // Clean URL (remove highlight param)
    const url = new URL(window.location.href)
    url.searchParams.delete('highlight')
    window.history.replaceState({}, '', url.toString())

    console.log(`[Highlight] Highlighted #${elementId}`)
  }
}
