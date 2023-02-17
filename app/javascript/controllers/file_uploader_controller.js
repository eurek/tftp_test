import { Controller } from "@hotwired/stimulus";
import {getTranslation} from "./shared/getTranslation";

export default class extends Controller {
  static targets = ['label', 'filename', 'editButton' ];

  async connect() {
    this.uploadedFileI18n = await getTranslation("common.uploaded_file");
  }

  displayFileName(event) {
    if (this.hasFilenameTarget) {
      this.filenameTarget.remove();
    }
    const file = event.currentTarget.files[0];
    const fileName = this.shortFilename(file.name);
    this.labelTarget.innerHTML = `${this.uploadedFileI18n} : ${fileName}`;
    this.labelTarget.classList.add('Form-input--valid');
    this.labelTarget.classList.remove('FileInput-label--hidden');
    this.editButtonTarget.classList.remove('FileInput-editButton--hidden');
  }

  shortFilename(filename) {
    if (filename.length > 28) {
      return `${filename.slice(0, 12)}...${filename.slice(-12)}`
    }
    return filename;
  }
}
