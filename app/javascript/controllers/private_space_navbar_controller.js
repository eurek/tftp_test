import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "navbar", "hamburger" ]

  toggle() {
    if (this.hamburgerTarget.innerText == "menu") {
      this.navbarTarget.classList.remove("PrivateSpace-navbar--hidden");
      this.navbarTarget.classList.add("PrivateSpace-navbar--translated");
      this.hamburgerTarget.innerText = "menu_open";
    } else {
      this.navbarTarget.classList.remove("PrivateSpace-navbar--translated");
      this.navbarTarget.classList.add("PrivateSpace-navbar--hidden");
      this.hamburgerTarget.innerText = "menu";
    }
  }

  setNavbarOnLargeScreens() {
    if (window.innerWidth > 991) {
      this.navbarTarget.classList.remove("PrivateSpace-navbar--hidden");
      this.navbarTarget.classList.remove("PrivateSpace-navbar--translated");
      this.hamburgerTarget.innerText = "menu";
    }
  }
}
