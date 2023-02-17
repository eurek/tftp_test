import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static classes = [ "tabActive", "descriptionActive" ]
  static targets = [ "tab", "description"]

  switch(event) {
    this.tabTargets.forEach((tab) => {
      tab.classList.remove(this.tabActiveClass);
      tab.setAttribute('aria-selected', 'false');
    });
    event.currentTarget.classList.add(this.tabActiveClass);
    event.currentTarget.setAttribute('aria-selected', 'true');

    this.descriptionTargets.forEach((description) => {
      if (description.dataset.id === event.currentTarget.dataset.id) {
        description.classList.add(this.descriptionActiveClass);
        description.setAttribute('aria-hidden', 'false');
      } else {
        description.classList.remove(this.descriptionActiveClass);
        description.setAttribute('aria-hidden', 'true');
      }
    });
  }
}
