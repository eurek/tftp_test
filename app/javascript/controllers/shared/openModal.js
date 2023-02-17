import MicroModal from 'micromodal/dist/micromodal';
import {disableBodyScroll, enableBodyScroll, clearAllBodyScrollLocks} from 'body-scroll-lock';

export function openModal(modalId, options = {}) {
  const clearBodyLock = () => {
    MicroModal.close(modalId);
    clearAllBodyScrollLocks();
    document.removeEventListener('turbolinks:request-start', clearBodyLock);
  };
  const {onShow, onClose} = options;

  MicroModal.show(modalId, {
    disableBodyScroll: true,
    ...options,
    onShow: modal => {
      disableBodyScroll(document.querySelector(`#${modal.id} .Modal-container`));
      document.addEventListener('turbolinks:request-start', clearBodyLock);
      onShow && onShow();
    },
    onClose: modal => {
      enableBodyScroll(document.querySelector(`#${modal.id} .Modal-container`));
      onClose && onClose();
    },
  });
}
