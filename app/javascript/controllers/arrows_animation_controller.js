import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['arrow'];

  connect() {
    this.arrowsAnimationCounter = 0;
    this.animateArrows();
  }

  animateArrows() {
    const rec = this.element.getBoundingClientRect();
    const position = rec.top / window.innerHeight * 100;
    const isSectionAtReadingLevel = position <= 20 && position >= 0;
    const isSectionNotVisible = position < -60 || position > 90;

    if (isSectionAtReadingLevel && this.arrowsAnimationCounter < 1) {
      this.animateArrow();
    } else if (isSectionNotVisible) {
      this.arrowsAnimationCounter = 0;
    }
  }

  animateArrow(index = 0) {
    this.arrowsAnimationCounter = 1;
    const arrow = this.arrowTargets[index];
    arrow.style.transform = `translateX(${arrow.dataset.space})`;
    setTimeout(() => {
      arrow.style.transform = "translateX(0)"
      index < (this.arrowTargets.length - 1) && this.animateArrow(index + 1);
    }, 320)
  }
}
