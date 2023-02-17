import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

  connect() {
    this.autoCloseTimeoutId = setTimeout(() => this.close(), 7000);
  }

  close() {
    this.element.classList.add("Flash-close");
    setTimeout(() =>  {
      this.element.parentNode.removeChild(this.element);
      clearTimeout(this.autoCloseTimeoutId);
    }, 2000);
  }
}
