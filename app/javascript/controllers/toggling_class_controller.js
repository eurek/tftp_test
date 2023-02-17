import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static classes = [ 'name' ];
  static values = {openElement: Boolean}

  toggleClassName(event) {
    // For accessibility if toggle controls expanded or collapsed of an element
    if (this.openElementValue) {
      event.currentTarget.setAttribute(
        "aria-expanded",
        event.currentTarget.getAttribute("aria-expanded") === "false" ? "true" : "false");
    }
    this.element.classList.toggle(this.nameClass);
  }
}
