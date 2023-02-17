import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["warningMessage"]
  toggleLever() {
    this.warningMessageTarget.classList.add("CounterSection-warning--displayed");

    setTimeout(() => {
      this.warningMessageTarget.classList.remove("CounterSection-warning--displayed");
    }, 3000)
  }
}
