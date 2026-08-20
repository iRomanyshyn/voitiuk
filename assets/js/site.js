(function () {
  const header = document.querySelector('[data-site-header]');
  const menuButton = document.querySelector('[data-menu-toggle]');
  const navigation = document.querySelector('[data-navigation]');

  const setScrolled = () => header && header.classList.toggle('is-scrolled', window.scrollY > 12);
  setScrolled();
  window.addEventListener('scroll', setScrolled, { passive: true });

  if (menuButton && navigation) {
    const closeMenu = () => {
      navigation.classList.remove('is-open');
      menuButton.setAttribute('aria-expanded', 'false');
    };
    menuButton.addEventListener('click', () => {
      const isOpen = menuButton.getAttribute('aria-expanded') === 'true';
      menuButton.setAttribute('aria-expanded', String(!isOpen));
      navigation.classList.toggle('is-open', !isOpen);
    });
    navigation.addEventListener('click', (event) => {
      if (event.target.closest('a')) closeMenu();
    });
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') closeMenu();
    });
  }

  const dialog = document.querySelector('[data-lightbox]');
  const items = Array.from(document.querySelectorAll('[data-lightbox-item]'));
  if (dialog && items.length) {
    const image = dialog.querySelector('[data-lightbox-image]');
    const title = dialog.querySelector('[data-lightbox-title]');
    const meta = dialog.querySelector('[data-lightbox-meta]');
    const close = dialog.querySelector('[data-lightbox-close]');
    const previous = dialog.querySelector('[data-lightbox-previous]');
    const next = dialog.querySelector('[data-lightbox-next]');
    let current = 0;
    let opener = null;

    const render = () => {
      const item = items[current].dataset;
      image.src = item.image;
      image.alt = item.alt;
      title.textContent = item.title;
      meta.textContent = item.meta;
    };
    const open = (index, button) => {
      current = index;
      opener = button;
      render();
      dialog.showModal();
      close.focus();
    };
    const closeDialog = () => {
      dialog.close();
      if (opener) opener.focus();
    };
    const move = (direction) => {
      current = (current + direction + items.length) % items.length;
      render();
    };

    items.forEach((item, index) => item.addEventListener('click', () => open(index, item)));
    close.addEventListener('click', closeDialog);
    previous.addEventListener('click', () => move(-1));
    next.addEventListener('click', () => move(1));
    dialog.addEventListener('click', (event) => {
      if (event.target === dialog) closeDialog();
    });
    dialog.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        event.preventDefault();
        closeDialog();
      } else if (event.key === 'ArrowLeft') {
        move(-1);
      } else if (event.key === 'ArrowRight') {
        move(1);
      }
    });
  }

  const clarityProjectId = document.body.dataset.clarityProjectId;
  const consentBanner = document.querySelector('[data-consent-banner]');
  const acceptAnalytics = document.querySelector('[data-clarity-accept]');
  const declineAnalytics = document.querySelector('[data-clarity-decline]');
  const analyticsSettings = Array.from(document.querySelectorAll('[data-clarity-settings]'));
  const consentStorageKey = 'voitiuk-clarity-consent-v1';

  if (clarityProjectId && consentBanner && acceptAnalytics && declineAnalytics) {
    const readConsent = () => {
      try {
        return window.localStorage.getItem(consentStorageKey);
      } catch (_error) {
        return null;
      }
    };
    const saveConsent = (value) => {
      try {
        window.localStorage.setItem(consentStorageKey, value);
      } catch (_error) {
        // The choice still applies to the current page when storage is unavailable.
      }
    };
    const signalConsent = (analyticsStorage) => {
      if (typeof window.clarity === 'function') {
        window.clarity('consentv2', {
          ad_Storage: 'denied',
          analytics_Storage: analyticsStorage
        });
      }
    };
    const loadClarity = () => {
      if (document.querySelector('script[data-clarity-script]')) {
        signalConsent('granted');
        return;
      }
      window.clarity = window.clarity || function () {
        (window.clarity.q = window.clarity.q || []).push(arguments);
      };
      signalConsent('granted');
      const script = document.createElement('script');
      script.async = true;
      script.src = `https://www.clarity.ms/tag/${clarityProjectId}`;
      script.dataset.clarityScript = '';
      document.head.appendChild(script);
    };
    const showConsent = (moveFocus = false) => {
      consentBanner.hidden = false;
      if (moveFocus) declineAnalytics.focus();
    };
    const hideConsent = () => {
      consentBanner.hidden = true;
    };

    acceptAnalytics.addEventListener('click', () => {
      saveConsent('granted');
      loadClarity();
      hideConsent();
    });
    declineAnalytics.addEventListener('click', () => {
      saveConsent('denied');
      signalConsent('denied');
      hideConsent();
    });
    analyticsSettings.forEach((button) => button.addEventListener('click', () => showConsent(true)));

    const storedConsent = readConsent();
    if (storedConsent === 'granted') {
      loadClarity();
    } else if (storedConsent !== 'denied') {
      showConsent();
    }
  }

})();
