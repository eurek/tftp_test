import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['ring', 'number'];
  static values = {percent: Number};

  connect() {
    const radius = this.ringTarget.r.baseVal.value;
    this.circumference = radius * 2 * Math.PI;
    this.ringTarget.style.strokeDasharray = `${this.circumference} ${this.circumference}`;
    this.ringTarget.style.strokeDashoffset = this.circumference;
    this.roundedPercentage = Math.round(this.percentValue);
    this.resetRing();
    this.resetNumber();
    this.animateRing();
  }

  animateRing() {
    const rec = this.element.getBoundingClientRect();
    const position = rec.top / window.innerHeight * 100;
    const isMissionAtReadingLevel = position <= 60;
    const isMissionBelowFloatLine = position >= 100;

    if (isMissionAtReadingLevel && this.numberTarget.innerHTML === '0') {
      this.incrementNumber();
    }

    if (isMissionAtReadingLevel) {
      const offset = this.circumference - this.percentValue / 100 * this.circumference;
      this.ringTarget.style.strokeDashoffset = offset;
    } else if (isMissionBelowFloatLine) {
      this.resetRing();
      this.resetNumber();
    }
  }

  resetRing() {
    const offset = this.circumference - 0.1 / 100 * this.circumference;
    this.ringTarget.style.strokeDashoffset = offset;
  }

  resetNumber() {
    this.numberTarget.innerHTML = '0';
  }

  incrementNumber(count = 1) {
    setTimeout(() => {
      if (count <= this.roundedPercentage) {
        count++;
        this.numberTarget.innerHTML = `${count}`;
        this.incrementNumber(count);
      }
    }, 10);
  }
}
