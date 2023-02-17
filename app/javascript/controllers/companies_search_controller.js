import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    'query', 'isExact', 'resultsContainer', 'companyForm', 'searchForm', 'companyCard'
  ]
  static values = { uri: String, createUri: String, companyCardPartial: String }

  findResults(event) {
    event.preventDefault();

    if (this.queryTarget.value === '') {
      this.resultsContainerTarget.innerHTML = '';
    } else {
      const exactInt = this.isExactTarget.checked === true ? 1 : 0;
      const queryParams = `?&search[name]=${this.queryTarget.value}&search[exact]=${exactInt}`;
      const fetchUri = this.uriValue + queryParams + '&employer=true';

      this.fetchAndInjectElement(fetchUri, this.resultsContainerTarget, '#companies-search-results');
    }
  }

  assignEmployer(event) {
    event.preventDefault();
    this.fetchAndInjectElement(
      event.currentTarget.href,
      this.companyCardTarget,
      '#company-card',
      () => this.searchFormTarget.classList.add('hidden')
    );
  }

  removeEmployer(event) {
    event.preventDefault();
    this.fetchAndInjectElement(
      event.currentTarget.href,
      this.companyCardTarget,
      undefined,
      () => {
        this.searchFormTarget.classList.remove('hidden');
        this.emptyCompanyInputs();
      }
    );
  }

  fetchAndInjectElement(uri, containerElement, elementId, callback) {

    fetch(uri)
    .then(response => response.text())
    .then(text => {
      const parser = new DOMParser();
      const doc = parser.parseFromString(text, 'text/html');
      containerElement.innerHTML = elementId ? doc.querySelector(elementId).innerHTML : "";
    })
    .then(callback)
    .catch(function(err) {
      console.log('Failed to fetch page: ', err);
    });
  }

  newCompany(event) {
    event.preventDefault();

    this.companyFormTarget.classList.remove('hidden');
    this.searchFormTarget.classList.add('hidden');
  }

  createOrUpdateCompany(event) {
    this.companyName = this.companyFormTarget.querySelector('#individual_employer_attributes_name').value;
    this.companyAddress = this.companyFormTarget.querySelector('#individual_employer_attributes_address').value;
    this.companyId = this.companyFormTarget.querySelector('#individual_employer_attributes_id').value;

    if (this.companyName) {
      const parser = new DOMParser();
      const companyCardPartial = parser.parseFromString(this.companyCardPartialValue, 'text/html');
      companyCardPartial.querySelector('.Base-title').innerText = this.companyName;
      companyCardPartial.querySelector('.CompanyInfoCard-address').innerText = this.companyAddress;
      companyCardPartial.querySelector('.CompanyInfoCard').dataset.companyId = this.companyId;
      companyCardPartial.querySelector('#edit-company-button').classList.remove('hidden');
      this.companyFormTarget.classList.add('hidden');
      this.companyCardTarget.innerHTML = companyCardPartial.querySelector('#company-card').outerHTML;
      this.companyCardTarget.classList.remove('hidden');
    } else {
      this.companyFormTarget.querySelector('#individual_employer_attributes_name').focus();
      this.companyFormTarget.querySelector('#individual_employer_attributes_name').blur();
    }
  }

  cancelCreateCompany() {
    this.fillCompanyInputsFromCard();

    this.companyFormTarget.classList.add('hidden');

    if (this.companyCardTarget.querySelector('.Base-title')) {
      this.companyCardTarget.classList.remove('hidden');
    } else {
      this.searchFormTarget.classList.remove('hidden');
    }
  }

  emptyCompanyInputs() {
    this.companyFormTarget.querySelectorAll(".Form-input").forEach(input => input.value = "");
  }

  fillCompanyInputsFromCard() {
    if (this.companyCardTarget.querySelector('.Base-title')) {
      const companyName = this.companyCardTarget.querySelector('.Base-title').innerText;
      const companyAddress = this.companyCardTarget.querySelector('.CompanyInfoCard-address').innerText;
      const companyId = this.companyCardTarget.querySelector(".CompanyInfoCard").dataset.companyId;

      this.companyFormTarget.querySelector('#individual_employer_attributes_name').value = companyName;
      this.companyFormTarget.querySelector('#individual_employer_attributes_address').value = companyAddress;
      this.companyFormTarget.querySelector('#individual_employer_attributes_id').value = companyId;
    } else {
      this.emptyCompanyInputs();
    }
  }

  editCompany(event) {
    event.preventDefault();
    this.fillCompanyInputsFromCard();

    this.companyFormTarget.classList.remove('hidden');
    this.companyCardTarget.classList.add('hidden');
  }
}
