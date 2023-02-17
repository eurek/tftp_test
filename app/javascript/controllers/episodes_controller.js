import { Controller } from "@hotwired/stimulus";
import { throttle } from "underscore";
import {fetchAndInject} from "./shared/fetchAndInject";

export default class extends Controller {
  static targets = ['episodeContainer', 'episodeCard', 'episodesListContainer', 'backArrow', 'forwardArrow'];

  connect() {
    this.cardWidthWithMargin = this.episodeCardTargets[0].offsetWidth + parseInt(window.getComputedStyle(this.episodeCardTargets[0]).marginRight);
    this.scrollingWidth = this.episodesListContainerTarget.scrollWidth - this.episodesListContainerTarget.offsetWidth;
    this.scrollToSelectedEpisode();
  }

  switchEpisode(event) {
    event.preventDefault();
    const fetchUri = event.currentTarget.href;

    fetchAndInject(fetchUri, this.episodeContainerTarget, '#episode-show');

    this.episodeCardTargets.forEach(card => {
      card.classList.remove('EpisodeCard--showing');
    });
    event.currentTarget.classList.add('EpisodeCard--showing');
    window.history.replaceState({}, "", fetchUri);
  }

  toggleArrows() {
    this.throttledToggleArrowsResults = throttle(this.checkScrolledWidthAndToggleArrows, 1000);
    this.throttledToggleArrowsResults();
  }

  checkScrolledWidthAndToggleArrows() {
    if (this.episodesListContainerTarget.scrollLeft === 0) {
      this.backArrowTarget.classList.add('EpisodesList-arrow--hidden');
    } else if (this.backArrowTarget.classList.contains('EpisodesList-arrow--hidden') && this.episodesListContainerTarget.scrollLeft >= 20) {
      this.backArrowTarget.classList.remove('EpisodesList-arrow--hidden');
    } else if (this.episodesListContainerTarget.scrollLeft === this.scrollingWidth) {
      this.forwardArrowTarget.classList.add('EpisodesList-arrow--hidden');
    } else if (this.forwardArrowTarget.classList.contains('EpisodesList-arrow--hidden') && this.episodesListContainerTarget.scrollLeft <= this.scrollingWidth - 20) {
      this.forwardArrowTarget.classList.remove('EpisodesList-arrow--hidden');
    }
  }

  scrollForward() {
    this.episodesListContainerTarget.scrollBy({
      left: this.cardWidthWithMargin,
      behavior: 'smooth'
    });
  }

  scrollBack() {
    this.episodesListContainerTarget.scrollBy({
      left: -this.cardWidthWithMargin,
      behavior: 'smooth'
    });
  }

  scrollToSelectedEpisode() {
    this.episodeCardTargets.forEach(card => {
      if (card.classList.contains('EpisodeCard--showing') && card.id >= 2) {
        this.episodesListContainerTarget.scrollBy({
          left: (card.id - 1) * this.cardWidthWithMargin,
          behavior: 'smooth'
        });
      }
    })
  }
}
