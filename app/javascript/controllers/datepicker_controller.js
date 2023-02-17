import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr";
import "flatpickr/dist/flatpickr.min.css";
import "flatpickr/dist/themes/dark.css";
import FlatpickrLanguages from "flatpickr/dist/l10n";
import {getTranslation} from "./shared/getTranslation";

export default class extends Controller {

  async connect() {
    const locale = location.pathname.split("/")[1];
    const format = await getTranslation("date.formats.default")
    const flatpickr_format = format.replace('%-d', 'j').replace('%-m', 'n').replaceAll('%', '')
    flatpickr(this.element, {
      locale: FlatpickrLanguages[locale],
      dateFormat: flatpickr_format
    });
  }
}
