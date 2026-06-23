import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal"];

  open() {
    this.modalTarget.style.display = "flex";
  }

  close() {
    this.resetAndClose();
  }

  closeAfterSubmit(event) {
    if (!event.detail.success) return;

    this.resetAndClose();
  }

  closeWhenBackgroundClicked(event) {
    if (event.target === this.modalTarget) {
      this.resetAndClose();
    }
  }

  resetAndClose() {
    this.element.reset();
    this.modalTarget.style.display = "none";
    this.dispatch("closed");
  }
}
