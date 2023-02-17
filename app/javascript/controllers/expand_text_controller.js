import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['text', 'seeMoreButton', 'seeLessButton']

  connect() {
    this.originalText = this.textTarget.innerText;
    this.wordCount = this.originalText.split(' ').length;

    if (window.innerWidth < 768) {
      this.truncate();
    }
  }

  resizeText() {
    if (window.innerWidth < 768) {
      this.truncate();
    } else {
      this.expand();
      this.seeMoreButtonTarget.classList.add("ClimateDeal-expandButtons--hidden");
      this.seeLessButtonTarget.classList.add("ClimateDeal-expandButtons--hidden");
    };
  }

  truncate() {
    if (this.wordCount > 25) {
      const truncated_text = this.originalText.split(' ').slice(0, 24).join(" ") + '...';
      this.textTarget.innerText = truncated_text;
      this.seeMoreButtonTarget.classList.remove("ClimateDeal-expandButtons--hidden");
      this.seeLessButtonTarget.classList.add("ClimateDeal-expandButtons--hidden");
    }
  }

  expand() {
    this.textTarget.innerText = this.originalText;
    if (window.innerWidth < 768) {
      this.seeLessButtonTarget.classList.remove("ClimateDeal-expandButtons--hidden");
      this.seeMoreButtonTarget.classList.add("ClimateDeal-expandButtons--hidden");
    }
  }
}
