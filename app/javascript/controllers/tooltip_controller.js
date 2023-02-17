import { Controller } from "@hotwired/stimulus";
import tippy from 'tippy.js';
import 'tippy.js/dist/tippy.css';

export default class extends Controller {
  static targets = ['trigger', 'source', 'maxWidth']
  static values = {triggerType: String, maxWidth: Number}

  connect() {
    this.triggerTargets.forEach((trigger, index) => {
      tippy(trigger, {
        content: this.sourceTargets[index].innerHTML,
        theme: 'dark',
        allowHTML: true,
        arrow: false,
        placement: 'bottom-start',
        maxWidth: this.maxWidthValue || 475,
        delay: [this.triggerTypeValue ? null : 100, null],
        trigger: this.triggerTypeValue || 'mouseenter focus',
        interactive: this.triggerTypeValue ? true : false,
      });
    });
  }
}
