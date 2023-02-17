import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['carousel', 'button', 'indicator', 'backArrow', 'forwardArrow'];
  static classes = ['activeButton', 'activeIndicator', 'carousel', 'activeArrow'];
  static values = {initialPosition: {type: Number, default: 0}, lastPosition: {type: Number, default: 2}};

  connect() {
    this.currentPosition = this.initialPositionValue;
    this.positionCarousel(this.currentPosition);
    this.deactivateArrows();
    this.activateArrows(this.currentPosition);
  }

  positionCarousel(newPosition) {
    this.carouselTarget.classList.remove(`${this.carouselClass}--${this.currentPosition}`)
    this.carouselTarget.classList.add(`${this.carouselClass}--${newPosition}`);
    this.currentPosition = newPosition;
  }

  nextPosition(panelIndex) {
    if (panelIndex === "previous" && this.currentPosition > 0) {
      return this.currentPosition - 1;
    } else if (panelIndex === "next" && this.currentPosition < this.lastPositionValue ) {
      return this.currentPosition + 1;
    } else if (0 <= panelIndex && panelIndex <= this.lastPositionValue) {
      return panelIndex;
    } else {
      return this.currentPosition;
    }
  }

  showPanel(event) {
    const nextPosition = this.nextPosition(event.currentTarget.dataset.panelIndex);

    this.positionCarousel(nextPosition);
    this.deactivateButtonsAndIndicators();
    this.deactivateArrows();
    this.activateButton(nextPosition);
    this.activateIndicator(nextPosition);
    this.activateArrows(nextPosition);
  }

  activateButton(nextPosition) {
    if (this.buttonTargets[nextPosition]) {
      this.buttonTargets[nextPosition].classList.add(this.activeButtonClass);
    }
  }

  activateIndicator(nextPosition) {
    if (this.indicatorTargets[nextPosition]) {
      this.indicatorTargets[nextPosition].classList.add(this.activeIndicatorClass);
    }
  }

  deactivateButtonsAndIndicators() {
    this.buttonTargets.forEach(element => element.classList.remove(this.activeButtonClass));
    this.indicatorTargets.forEach(element => element.classList.remove(this.activeIndicatorClass));
  }

  deactivateArrows() {
    this.backArrowTargets.forEach(element => element.classList.remove(this.activeArrowClass));
    this.forwardArrowTargets.forEach(element => element.classList.remove(this.activeArrowClass));
  }

  activateArrows(nextPosition) {
    if (this.lastPositionValue === 0) {
      return;
    } else if (nextPosition === 0) {
      this.forwardArrowTargets.forEach(arrow => arrow.classList.add(this.activeArrowClass));
    } else if (nextPosition === this.lastPositionValue) {
      this.backArrowTargets.forEach(arrow => arrow.classList.add(this.activeArrowClass));
    } else if (this.forwardArrowTargets.length > 1) {
      this.backArrowTargets[nextPosition - 1]?.classList?.add(this.activeArrowClass)
      this.forwardArrowTargets[nextPosition]?.classList?.add(this.activeArrowClass);
    } else {
      this.forwardArrowTarget.classList.add(this.activeArrowClass);
      this.backArrowTarget.classList.add(this.activeArrowClass);
    }
  }
}
