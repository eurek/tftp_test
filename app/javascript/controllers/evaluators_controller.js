import { Controller } from "@hotwired/stimulus";
import {fetchAndInject} from "./shared/fetchAndInject";

export default class extends Controller {
  static targets = ['resultsContainer', "seeLess", "seeMore", "loading", "completeList"];

  async showAllEvaluators(event) {
    event.preventDefault();

    if (this.allEvaluatorsHasBeenLoaded) {
      this.completeListTarget.classList.remove("hidden");
    } else {
      const uri = event.currentTarget.href;
      this.seeMoreTarget.classList.add("hidden");
      this.loadingTarget.classList.remove("hidden");
      await fetchAndInject(uri, this.resultsContainerTarget);
      this.loadingTarget.classList.add("hidden");
      this.allEvaluatorsHasBeenLoaded = true;
    }
    this.seeLessTarget.classList.remove("hidden");
    this.seeMoreTarget.classList.add("hidden");
  }

  showLessEvaluators(event) {
    event.preventDefault();
    this.completeListTarget.classList.add("hidden");
    this.seeLessTarget.classList.add("hidden");
    this.seeMoreTarget.classList.remove("hidden");
  }
}
