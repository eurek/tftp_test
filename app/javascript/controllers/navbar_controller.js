import { Controller } from "@hotwired/stimulus";
import {disableBodyScroll, enableBodyScroll, clearAllBodyScrollLocks} from 'body-scroll-lock';

export default class extends Controller {
  static targets = [
    'hamburger',
    'innovationsMenu',
    'innovationsArrow',
    'aboutMenu',
    'aboutArrow',
    'actingMenu',
    'actingArrow'
  ];

  connect() {
    this.hamburgerActiveClass = 'Navbar-hamburger--active';
    this.menuOpenClass = 'Navbar--menuOpen';
    clearAllBodyScrollLocks();
  }

  closeMenuOnLargeBreakpoint() {
    if (window.innerWidth > 990 && this.isMenuOpen()) {
      clearAllBodyScrollLocks();
      this.element.classList.remove(this.menuOpenClass);
      this.hamburgerTarget.classList.remove(this.hamburgerActiveClass);
    }
    if (window.innerWidth < 990 && (!this.aboutMenuTarget.classList.contains('hidden') || !this.actingMenuTarget.classList.contains('hidden'))) {
      this.hamburgerTarget.classList.add(this.hamburgerActiveClass);
      this.element.classList.add(this.menuOpenClass);
      this.toggleScrollOnBody(false);
    }
  }

  isMenuOpen() {
    return this.hamburgerTarget.classList.contains(this.hamburgerActiveClass);
  }

  toggleMenu() {
    const isClosingMenu = this.isMenuOpen();
    this.hamburgerTarget.classList.toggle(this.hamburgerActiveClass);
    this.element.classList.toggle(this.menuOpenClass);
    this.toggleScrollOnBody(isClosingMenu);
    this.hideAllMenus();
  }

  toggleScrollOnBody(isClosingMenu) {
    if (isClosingMenu) {
      enableBodyScroll(this.element);
    } else {
      disableBodyScroll(this.element);
    }
  }

  toggleInnovationsMenu() {
    this.innovationsMenuTarget.classList.toggle('hidden');
    this.innovationsArrowTarget.classList.toggle('hidden');
    this.hideActingMenu();
    this.hideAboutMenu();
  }

  toggleAboutMenu() {
    this.aboutMenuTarget.classList.toggle('hidden');
    this.aboutArrowTarget.classList.toggle('hidden');
    this.hideActingMenu();
    this.hideInnovationsMenu();
  }

  toggleActingMenu() {
    this.actingMenuTarget.classList.toggle('hidden');
    this.actingArrowTarget.classList.toggle('hidden');
    this.hideAboutMenu();
    this.hideInnovationsMenu();
  }

  hideMenusWhenKeyupEscape(event) {
    if (event.key === "Escape") {
      this.hideAllMenus();
    }
  }

  hideMenusWhenClickOutside(event) {
    if (this.element === event.target || this.element.contains(event.target)) return;

    this.hideAllMenus();
  }

  hideAllMenus() {
    this.hideActingMenu();
    this.hideAboutMenu();
    this.hideInnovationsMenu();
  }

  hideInnovationsMenu() {
    this.innovationsMenuTarget.classList.add('hidden');
    this.innovationsArrowTarget.classList.add('hidden');
  }

  hideActingMenu() {
    this.actingMenuTarget.classList.add('hidden');
    this.actingArrowTarget.classList.add('hidden');
  }

  hideAboutMenu() {
    this.aboutMenuTarget.classList.add('hidden');
    this.aboutArrowTarget.classList.add('hidden');
  }
}
