import { Controller } from "@hotwired/stimulus"

// Avatar preview controller
// Shows a preview of the selected image before saving
export default class extends Controller {
  static targets = ["input", "current", "preview"]

  preview () {
    const file = this.inputTarget.files[0]
    if (!file) return

    // Validate file type
    const validTypes = ["image/jpeg", "image/png", "image/gif", "image/webp"]
    if (!validTypes.includes(file.type)) {
      alert("Vui lòng chọn file ảnh (JPEG, PNG, GIF, WEBP)")
      this.inputTarget.value = ""
      return
    }

    // Validate file size (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      alert("File ảnh không được lớn hơn 5MB")
      this.inputTarget.value = ""
      return
    }

    // Show preview
    const reader = new FileReader()
    reader.onload = (e) => {
      // Hide current avatar, show preview
      this.currentTarget.classList.add("hidden")
      this.previewTarget.src = e.target.result
      this.previewTarget.classList.remove("hidden")
    }
    reader.readAsDataURL(file)
  }
}
