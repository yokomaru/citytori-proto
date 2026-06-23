import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "image"]

  preview(event) {
    const file = event.target.files[0]
    const validTypes = ["image/jpeg", "image/jpg", "image/png"]

    if (!file) {
      this.removeImage()
      return
    }

    if (!validTypes.includes(file.type)) {
      alert("JPEG、JPG、PNG形式のファイルを選択してください。")
      this.removeImage()
      return
    }

    const reader = new FileReader()

    reader.onload = (loadEvent) => {
      this.imageTarget.src = loadEvent.target.result
      this.previewTarget.classList.remove("hidden")
    }

    reader.readAsDataURL(file)

    this.dispatch("valid-file-selected")
  }

  removeImage() {
    this.inputTarget.value = ""
    this.imageTarget.src = ""
    this.previewTarget.classList.add("hidden")
  }
}