import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['clear', 'panelsContainer', 'trigger', 'panel', 'allStatus'];

  connect() {
    this.panelTargets.forEach(panel => this.activateTrigger(panel));

    if (this.hasClearTrigger) {
      this.toggleClearItem();
    }
  }

  displayPanel(event) {
    event.stopPropagation();
    const filterId = event.currentTarget.getAttribute('data-filter-id');

    const filterDetails = document.getElementById(filterId);
    const isClosingPanel = filterDetails.classList.contains('Filters-details--open');

    this.closePanels();

    if (!isClosingPanel) {
      filterDetails.classList.add('Filters-details--open');
      event.currentTarget.classList.add('Filters-item--open')
    }
  }

  closePanels() {
    this.panelTargets.forEach(panel => {
      panel.classList.remove('Filters-details--open');

    });

    this.triggerTargets.forEach(trigger => {
      trigger.classList.remove('Filters-item--open')
    });

    this.toggleClearItem();
  }

  toggleClearItem() {
    if (document.querySelectorAll('input:checked').length > 0) {
      this.clearTarget.classList.remove("hidden");
    } else {
      this.clearTarget.classList.add("hidden");
    }
  }

  activateTagFilter(event) {
    const filterItem = event.currentTarget.parentNode;
  }

  activateTrigger(panel) {
    const trigger = document.querySelector(`[data-filter-id="${panel.id}"]`);

    if (this.isFilterActivated(panel)) {
      trigger.classList.add("Filters-item--active");
    } else {
      trigger.classList.remove("Filters-item--active");
    }
  }

  isFilterActivated(panel) {
    if (panel.classList.contains('InnovationsNav--mobile')) {
      return !this.allStatusTarget.parentNode.classList.contains('InnovationsNavItem--active');
    } else {
      return panel.querySelectorAll("input:checked").length > 0;
    }
  }


  selectInput(event) {
    const filterDetails = event.currentTarget.closest(".Filters-details");
    this.refreshContent(event.currentTarget.form);
    this.toggleClearItem();

    if (filterDetails) {
      this.activateTrigger(filterDetails);
    } else {
      this.activateTagFilter(event);
    }
  }

  hidePanelsWhenClickOutside(event) {
    if(this.panelsContainerTarget === event.target || this.panelsContainerTarget.contains(event.target)) return;

    this.closePanels();
  }

  refreshContent(form) {
    const currentURI = '//' + window.location.host + window.location.pathname;
    const formData = new FormData(form);

    const search = document.getElementById("search");
    if (search) {
      formData.append("search", search.value);
    }

    const currentParams = new URLSearchParams(window.location.search);
    if (currentParams.has('status')) {
      formData.append('status', currentParams.get('status'));
    }

    const queryString = (new URLSearchParams(formData)).toString();
    const fetchUri = currentURI + '?' + queryString;
    window.history.replaceState({}, "", `${currentURI}?${queryString}`);

    fetch(fetchUri)
      .then(response => response.text())
      .then(text => {
        const parser = new DOMParser();
        const doc = parser.parseFromString(text, "text/html");

        document.querySelectorAll(".UpdatableElement").forEach((element, index) => {
          element.innerHTML = doc.querySelectorAll(".UpdatableElement")[index].innerHTML;
        })
      })
      .catch(function(err) {
        console.log('Failed to fetch page: ', err);
      });
  }
}
