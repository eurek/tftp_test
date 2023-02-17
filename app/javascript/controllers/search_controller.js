import { Controller } from "@hotwired/stimulus";
import { throttle } from "underscore";

export default class extends Controller {
  static targets = ['query', 'status', 'resultsContainer', 'paginationContainer']
  static values = { uri: String }

  connect() {
    this.throttledFetchResults = throttle(this.fetchResults, 1000);
  }

  submit() {
    this.throttledFetchResults();
  }

  fetchResults() {
    const currentURI = '//' + window.location.host + window.location.pathname;
    const urlParams = new URLSearchParams(window.location.search);
    urlParams.set('search', this.queryTarget.value);

    const fetchUri = currentURI + '?' + urlParams;

    fetch(fetchUri)
    .then(response => response.text())
    .then(text => {
      const parser = new DOMParser();
      const doc = parser.parseFromString(text, 'text/html');
      this.resultsContainerTarget.innerHTML = doc.querySelector("[data-search-target='resultsContainer']").innerHTML;
      this.paginationContainerTarget.innerHTML = doc.querySelector("[data-search-target='paginationContainer']").innerHTML;
    })

    .catch(function(err) {
      console.log('Failed to fetch page: ', err);
    });
  }
}
