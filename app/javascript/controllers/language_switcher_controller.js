import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ 'popup' ];

  togglePopup(event) {
    this.popupTarget.classList.toggle('hidden');
    event.stopPropagation();
  }

  hide(event) {
    this.popupTarget.classList.add('hidden');
  }

  escapeHide(event) {
    if (event.key === 'Escape') {
      this.popupTarget.classList.add('hidden');
    }
  }
}
