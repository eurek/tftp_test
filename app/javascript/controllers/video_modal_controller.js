import { Controller } from "@hotwired/stimulus";
import {openModal} from './shared/openModal';

export default class extends Controller {
  static targets = ['contentVideoId']

  connect() {
    const tag = document.createElement('script');
    tag.id = 'iframe-demo';
    tag.src = 'https://www.youtube.com/iframe_api';
    const firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

    if (window.onYouTubeIframeAPIReady) {
      window.onYouTubeIframeAPIReady();
    } else {
      window.onYouTubeIframeAPIReady = () => {
        window.player = new YT.Player('youtube-player');
      }
    }
  }


  openModalAndPlay(event) {
    const contentVideoId = event.currentTarget.getAttribute('data-video-src');
    if (contentVideoId) {
      window.player.loadVideoById({videoId: contentVideoId});
    }
    const modalId = this.element.getAttribute('data-modal-id');
    openModal(modalId, {onClose: () => window.player.stopVideo()});
    window.player.loadVideoById({videoId: contentVideoId});
    window.player.playVideo();
  }
}
