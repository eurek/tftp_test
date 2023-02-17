import { Controller } from "@hotwired/stimulus";
import {getTranslation} from "./shared/getTranslation";

export default class extends Controller {
  static targets = [ "additionalFields", "button" ]

  async connect() {
    this.validInputClass = 'Form-input--valid';
    this.invalidInputClass = 'Form-input--invalid';
    this.emptyFieldErrorI18n = await getTranslation("common.empty_field_error");
    this.errorsI18n = await getTranslation("errors");
    this.attributesI18n = await getTranslation("activerecord.attributes");
  }

  validate(event) {
    if (event.target.validity.valid) {
      this.makeInputValid(event.target);
    } else {
      this.makeInputInvalidAndDisplayError(event.target);
    }
  }

  makeInputInvalidAndDisplayError(input) {
    input.classList.remove(this.validInputClass);
    input.classList.add(this.invalidInputClass);

    if (this.isErrorSpanPresent(input)) {
      this.replaceErrorSpanText(input, this.errorMessage(input));
    } else {
      input.insertAdjacentHTML(
        'afterend',
        `<span class="Form-error">${this.errorMessage(input)}</span>`
      )
    }
  }

  makeInputValid(input) {
    input.classList.remove(this.invalidInputClass);
    input.classList.add(this.validInputClass);
    if (this.isErrorSpanPresent(input)) {
      this.replaceErrorSpanText(input, '');
    }
  }

  errorMessage(input) {
    const [model, attribute] = input.name.replaceAll(']', '').split('[');
    const format = this.errorMessageFormat(input);
    const attributeTranslation = this.attributesI18n[`${model}`][`${attribute}`];
    if (attributeTranslation === undefined) {
      return this.emptyFieldErrorI18n;
    } else {
      return format.replace(/%{attribute}/gi, attributeTranslation);
    }
  }

  errorMessageFormat(input) {
    if (this.errorsI18n ===  undefined) {
      return this.emptyFieldErrorI18n;
    } else if (input.validity.valueMissing ===  true) {
      return this.errorsI18n["messages"]["blank"];
    } else if (input.validity.patternMismatch ===  true) {
      return this.errorsI18n["messages"]["blank"];
    } else if (input.validity.typeMismatch ===  true) {
      return this.errorsI18n["messages"]["invalid"];
    } else {
      return '';
    }
  }

  isErrorSpanPresent(input) {
    return input.parentNode.getElementsByClassName('Form-error').length > 0
  }

  replaceErrorSpanText(input, text) {
    input.parentNode.getElementsByClassName('Form-error')[0].innerHTML = text;
  }

  hideFields() {
    this.additionalFieldsTarget.classList.toggle("Form-group--hidden");
  }

  revealButton() {
    this.buttonTarget.classList.toggle("Button--hidden");
  }
}
