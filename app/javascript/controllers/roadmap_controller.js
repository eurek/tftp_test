import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['detailsPlaceholder', 'selectedTask'];

  connect() {
    this.detailsOpenClass = 'DetailsContainer-detailsPlaceholder--open';
    this.selectedTaskClass = 'Task--selected';
  }

  selectTask(event) {
    const path = event.currentTarget.getAttribute('data-href');
    this.unselectCurrentlySelectedTask();
    const task = event.currentTarget;
    fetch(`${path}?js=true`, { headers: { accept: "text/html" } })
      .then(response => response.text())
      .then((taskDetails) => {
        if (this.detailsPlaceholderTarget.classList.contains(this.detailsOpenClass)) {
          this.detailsPlaceholderTarget.classList.remove(this.detailsOpenClass);
          setTimeout(() => {
            this.displayTaskDetails(task, taskDetails)
          }, 350)
        } else {
          this.displayTaskDetails(task, taskDetails)
        }
      });
  }

  unselectCurrentlySelectedTask() {
    const selectedTask = document.querySelector(`.${this.selectedTaskClass}`);
    selectedTask && selectedTask.classList.remove(this.selectedTaskClass);
  }

  displayTaskDetails(task, taskDetails) {
    task.classList.add(this.selectedTaskClass);
    this.detailsPlaceholderTarget.innerHTML = taskDetails;
    this.detailsPlaceholderTarget.classList.add(this.detailsOpenClass);
  }

  closeTask() {
    this.unselectCurrentlySelectedTask();
    this.detailsPlaceholderTarget.classList.remove(this.detailsOpenClass);
  }
}
