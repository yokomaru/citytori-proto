import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal", "errors"];

  open() {
    this.clearErrors();
    this.modalTarget.style.display = "flex";
  }

  close() {
    this.resetAndClose();
  }

  closeAfterSubmit(event) {
    if (!event.detail.success) return;

    this.resetAndClose();
  }

  resetAndClose() {
    this.element.reset();
    this.clearErrors();
    this.modalTarget.style.display = "none";
  }

  clearErrors() {
    if (!this.hasErrorsTarget) return;

    this.errorsTarget.innerHTML = "";
  }
}
