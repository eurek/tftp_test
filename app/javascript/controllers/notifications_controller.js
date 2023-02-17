import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  fetchNotifications(event) {
    event.preventDefault();
    const fetchUri = event.currentTarget.href;

    fetch(fetchUri)
      .then(response => response.text())
      .then(text => {
        const parser = new DOMParser();
        const doc = parser.parseFromString(text, 'text/html');
        document.querySelector("[data-action='notifications#fetchNotifications']").remove();
        this.element.innerHTML += doc.querySelector("[data-controller='notifications']").innerHTML;
      })

      .catch(function(err) {
        console.log('Failed to fetch page: ', err);
      });
  }
}
