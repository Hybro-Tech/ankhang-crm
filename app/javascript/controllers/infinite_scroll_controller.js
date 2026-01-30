import { Controller } from "@hotwired/stimulus"

// Infinite Scroll Controller for load more functionality
export default class extends Controller {
  static targets = ["entries", "pagination"]
  static values = { url: String }

  connect () {
    this.page = 1
  }

  async loadMore (event) {
    event.preventDefault()

    const button = event.currentTarget
    const nextPage = button.dataset.page || (this.page + 1)

    // Show loading state
    button.disabled = true
    button.innerHTML = '<i class="fa-solid fa-spinner fa-spin mr-1"></i> Đang tải...'

    try {
      const response = await fetch(`${this.urlValue}?page=${nextPage}`, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html"
        }
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
        this.page = parseInt(nextPage)
      }
    } catch (error) {
      console.error("Load more error:", error)
      button.innerHTML = '<i class="fa-solid fa-exclamation-triangle mr-1"></i> Lỗi, thử lại'
      button.disabled = false
    }
  }
}
