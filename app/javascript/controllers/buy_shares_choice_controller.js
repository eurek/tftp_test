import { Controller } from "@hotwired/stimulus";
import Choices from 'choices.js';
import 'choices.js/public/assets/styles/choices.min.css';
import {getTranslation} from "./shared/getTranslation";

export default class extends Controller {
  static targets = [ "input", "form" ];
  static classes = [ "open" ];

  async connect() {
    const hint = await getTranslation("common.choices_hint");
    this.choices = this.inputTargets.map(select => new Choices(select, {
      searchEnabled: false,
      shouldSort: false,
      itemSelectText: hint,
      placeholder: true,
      allowHTML: false
    }));
  }

  resetTransactionTypeInput() {
    this.choices[1].setChoiceByValue("");
  }

  submitIfReady() {
    if (this.inputTargets.every(input => input.value !== "")) {
      this.formTarget.submit();
    }
  }
}
