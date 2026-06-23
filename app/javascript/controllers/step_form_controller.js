import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "form"]

  open() {
    this.modalTarget.style.display = "flex"
  }

  close() {
    this.modalTarget.style.display = "none"
    this.formTarget.reset()
  }

  closeAfterSubmit(event) {
    if (!event.detail.success) return

    this.close()
  }

  closeWhenBackgroundClicked(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }
}