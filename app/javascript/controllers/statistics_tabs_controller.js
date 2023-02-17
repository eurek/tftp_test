import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "activeTab", "tab" ];

  connect() {
    this.currentIndex = 0;
  }

  repositionOnResize() {
    const tabHeight = this.activeTabTarget.getBoundingClientRect().height;
    this.activeTabTarget.style.top = `${parseInt(this.currentIndex) * parseInt(tabHeight)}px`;
  }

  switch(event) {
    this.tabTargets.forEach(tab => {
      tab.classList.remove("DataTab--active");
    })
    event.currentTarget.classList.add("DataTab--active");

    const tabHeight = this.activeTabTarget.getBoundingClientRect().height;
    this.currentIndex = event.currentTarget.dataset.index;
    this.activeTabTarget.style.top = `${parseInt(this.currentIndex) * parseInt(tabHeight)}px`;
  }
}
