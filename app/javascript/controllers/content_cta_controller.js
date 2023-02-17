import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static classes = [ "open", "fixed" ];
  static targets = [ "cta" ];

  toggleCtaHeight() {
    const rect = this.element.getBoundingClientRect();
    const topElementPosition = rect.top;
    const elementHeight = rect.height;


    if (rect.top <= 0) {
      this.ctaTarget.classList.remove(this.openClass);
    } else if (topElementPosition + elementHeight > window.innerHeight) {
      this.ctaTarget.classList.add(this.fixedClass);
    } else {
      this.ctaTarget.classList.remove(this.fixedClass);
      this.ctaTarget.classList.add(this.openClass);
    }
  }
}
