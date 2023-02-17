import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['task'];

  connect() {
    this.tasksAnimationCounter = 0;
    this.animateTasks();
  }

  animateTasks() {
    const rec = this.element.getBoundingClientRect();
    const position = rec.top / window.innerHeight * 100;
    const isSectionAtReadingLevel = position <= 40 && position >= 0;
    const isSectionNotVisible = position < -60 || position > 90;

    if (isSectionAtReadingLevel && this.tasksAnimationCounter < 1) {
      this.animateTask();
    } else if (isSectionNotVisible) {
      this.tasksAnimationCounter = 0;
      this.resetTask();
    }
  }

  animateTask(index = 0) {
    this.tasksAnimationCounter = 1;
    const task = this.taskTargets[index];
    task.classList.add('RoadmapSection-task--active');
    setTimeout(() => {
      index < (this.taskTargets.length - 1) && this.animateTask(index + 1);
    }, 350)
  }

  resetTask() {
    this.taskTargets.forEach(task => task.classList.remove('RoadmapSection-task--active'));
  }
}
