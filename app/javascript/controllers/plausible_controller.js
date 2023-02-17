import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { eventName: String };

  sendGoal() {
    plausible(this.eventNameValue);
  }
}
