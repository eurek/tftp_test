import { Controller } from "@hotwired/stimulus";
import Redactor from '../../../vendor/redactor/redactor.usm.min.js';
import Counter from '../../../vendor/counter/counter.min.js';

export default class extends Controller {
  static values = { type: String }

  connect() {
    const readonly = this.element.getAttribute("readonly") === "readonly";
    const callbacks = {
      started: function() {
        if (readonly) {
          this.enableReadOnly();
        }
      },
    }

    if (this.typeValue === "minimal") {
      return Redactor(
        this.element,
        {callbacks, buttons: ['bold', 'lists', 'link', 'sup', 'sub'], plugins: ['counter']}
      );
    }

    const model = this.element.getAttribute("data-model");
    const id = this.element.getAttribute("data-id");
    const attribute = this.element.getAttribute("data-attribute");
    const maxHeight = this.element.getAttribute("max_height") || false;
    Redactor(this.element, {
      imageUpload: `/image-upload?model=${model}&id=${id}&attribute=${attribute}`,
      formatting: ['p', 'blockquote', 'pre', 'h2', 'h3', 'h4', 'h5', 'h6'],
      maxHeight: maxHeight,
      plugins: ['counter'],
      buttonsAdd: ['sup', 'sub'],
      removeScript: false,
      callbacks: {
        ...callbacks,
        image: {
          deleted: function(image)
          {
            const attachmentId = image.nodes[0].lastChild.getAttribute("data-image");
            fetch(`/image-upload?attachment_id=${attachmentId}`, {
              method: 'DELETE',
            }).then(response => response.json())
              .then(console.log)
          }
        }
      }
    });
  }
}
