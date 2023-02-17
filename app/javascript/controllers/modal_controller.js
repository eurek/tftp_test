import { Controller } from "@hotwired/stimulus";
import {openModal} from './shared/openModal';

export default class extends Controller {

  openModal() {
    const modalId = this.element.getAttribute('data-modal-id');
    openModal(modalId);
  }
}
