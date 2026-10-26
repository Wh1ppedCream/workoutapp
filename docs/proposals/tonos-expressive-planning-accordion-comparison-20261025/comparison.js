'use strict';

(() => {
  const pairs = [...document.querySelectorAll('.pair')];
  const focus = document.getElementById('focus');
  const full = document.getElementById('full');
  let cardsOnly = true;

  function layout() {
    for (const pair of pairs) {
      const views = [...pair.querySelectorAll('.viewport')];
      if (views.some(view => !view.querySelector('img').naturalWidth)) continue;
      const heights = views.map(view => {
        const image = view.querySelector('img');
        return (image.naturalHeight - Number(view.dataset.start)) *
          image.clientWidth / image.naturalWidth;
      });
      const sharedHeight = Math.min(620, ...heights);
      for (const view of views) {
        const image = view.querySelector('img');
        view.style.height = cardsOnly ? `${sharedHeight}px` : 'auto';
        view.scrollTop = cardsOnly
          ? Number(view.dataset.start) * image.clientWidth / image.naturalWidth
          : 0;
      }
    }
  }

  function setMode(value) {
    cardsOnly = value;
    focus.setAttribute('aria-pressed', String(cardsOnly));
    full.setAttribute('aria-pressed', String(!cardsOnly));
    layout();
  }

  focus.addEventListener('click', () => setMode(true));
  full.addEventListener('click', () => setMode(false));
  document.querySelectorAll('.viewport img').forEach(image => {
    image.addEventListener('load', layout);
  });
  window.addEventListener('resize', layout);
  layout();
})();
