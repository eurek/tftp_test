import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static classes = [ "toggled" ];
  static values = {more: String, less: String}

  toggle(event) {
    if (this.element.classList.contains(this.toggledClass)) {
      event.currentTarget.querySelector("span").innerHTML = this.moreValue;
    } else {
      event.currentTarget.querySelector("span").innerHTML = this.lessValue;
    }
    this.element.classList.toggle(this.toggledClass);
  }
}
