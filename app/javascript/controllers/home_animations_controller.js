import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    'mapSection',
    'mapText',
    'marker',
    'stepsSection',
    'step',
  ];

  connect() {
    this.mapTimeoutIds = [];
    this.stepTimeoutIds = [];
    this.animateOnScroll();
  }

  animateOnScroll() {
    this.animateMap();
    this.animateSteps();
  }

  animateMap() {
    if (this.isSectionAtReadingLevel(this.mapSectionTarget)) {
      this.mapTextTargets.forEach(text => text.style.opacity = "1");
      this.displayMarker();
    } else {
      this.mapTimeoutIds.forEach(timeoutId => window.clearTimeout(timeoutId));
      this.mapTimeoutIds = [];
      if (window.innerWidth > 768) {
        this.mapTextTargets.forEach(text => text.style.opacity = "0");
      }
      this.markerTargets.forEach(text => text.style.opacity = "0");
    }
  }

  displayMarker(index = 0) {
    this.markerTargets[index].style.opacity = "0.4";
    this.mapTimeoutIds.push(setTimeout(() => {
      index < (this.markerTargets.length - 1) && this.displayMarker(index + 1)
    }, 200));
  }

  animateSteps() {
    if (this.isSectionAtReadingLevel(this.stepsSectionTarget)) {
      this.stepTargets.forEach(step => {
        this.displayStep();
      });
    } else {
      this.stepTimeoutIds.forEach(timeoutId => window.clearTimeout(timeoutId));
      this.stepTimeoutIds = [];
      this.stepTargets.forEach(step => {
        step.classList.remove('StepsSection-step--revealed');
        step.classList.add('StepsSection-step--hidden');
      });
    }
  }

  isSectionAtReadingLevel(section) {
    const rec = section.getBoundingClientRect();
    const position = rec.top / window.innerHeight * 100;
    return (position <= 30);
  }

  displayStep(index = 0) {
    this.stepTargets[index].classList.remove('StepsSection-step--hidden');
    this.stepTargets[index].classList.add('StepsSection-step--revealed');
    this.stepTimeoutIds.push(setTimeout(() => {
      index < (this.stepTargets.length - 1) && this.displayStep(index + 1)
    }, 700));
  }
}
