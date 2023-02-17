import { Controller } from "@hotwired/stimulus";
import {getTranslation} from "./shared/getTranslation";

export default class extends Controller {
  static targets = ['textArea', 'counter'];

  async connect() {
    this.i18nCharacter = await getTranslation("common.characters");
    this.countCharacters();
  }

  countCharacters() {
    const characterLength = this.textAreaTarget.value ? this.textAreaTarget.value.length : 0;
    this.counterTarget.innerText = `${characterLength}/${this.textAreaTarget.maxLength} ${this.i18nCharacter}`;
  }
}
