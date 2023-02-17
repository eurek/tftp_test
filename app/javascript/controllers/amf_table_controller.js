import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "description"]

  toggle(event) {
    const icon = event.currentTarget.getElementsByTagName("i").item(0);
    if (icon.innerText === "expand_more") {
      icon.innerText = "expand_less"
    } else {
      icon.innerText = "expand_more"
    }
    this.descriptionTargets.forEach(description => {
      if (description.dataset.risk === event.currentTarget.dataset.risk) {
        description.classList.toggle("AmfRisksTable-description--open");
      }
    });
  }
}
