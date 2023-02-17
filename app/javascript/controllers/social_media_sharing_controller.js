import { Controller } from "@hotwired/stimulus";
import JSShare from "js-share";

export default class extends Controller {

  share(event) {
    JSShare.go(event.currentTarget);
  }
}
