import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    'lock',
    'badge'
  ];

  connect() {
    this.badgesAnimationCounter = 0;
    this.animateBadges();
  }

  animateBadges() {
    const rec = this.element.getBoundingClientRect();
    const position = rec.top / window.innerHeight * 100;
    const isSectionAtReadingLevel = position <= 20 && position >= 0;
    const isSectionNotVisible = position < -60 || position > 90;

    if (isSectionAtReadingLevel && this.badgesAnimationCounter < 1) {
      this.animateBadge();
    } else if (isSectionNotVisible) {
      this.badgesAnimationCounter = 0;
      this.resetBadge();
    }
  }

  animateBadge(index = 0) {
    this.badgesAnimationCounter = 1;
    const lock = this.lockTargets[index];
    const badge = this.badgeTargets[index];
    lock.classList.add('BadgesSection-lock--active');
    badge.classList.add('BadgesSection-badge--active');
    setTimeout(() => {
      index < (this.lockTargets.length - 1) && this.animateBadge(index + 1);
    }, 500)
  }

  resetBadge() {
    this.lockTargets.forEach(lock => lock.classList.remove('BadgesSection-lock--active'));
    this.badgeTargets.forEach(badge => badge.classList.remove('BadgesSection-badge--active'));
  }
}
