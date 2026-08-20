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

  const form = document.querySelector('.contact-form');
  if (form) {
    const status = form.querySelector('[data-form-status]');
    form.addEventListener('submit', async (event) => {
      if (!form.checkValidity()) return;
      event.preventDefault();
      const button = form.querySelector('button[type="submit"]');
      button.disabled = true;
      status.textContent = document.documentElement.lang === 'uk' ? 'Надсилання…' : 'Sending…';
      try {
        const response = await fetch(form.action, {
          method: 'POST',
          body: new FormData(form),
          headers: { Accept: 'application/json' }
        });
        if (!response.ok) throw new Error('Request failed');
        form.reset();
        status.textContent = document.documentElement.lang === 'uk' ? 'Дякуємо. Повідомлення надіслано.' : 'Thank you. Your message has been sent.';
      } catch (error) {
        status.textContent = document.documentElement.lang === 'uk' ? 'Не вдалося надіслати. Спробуйте ще раз або напишіть електронною поштою.' : 'The message could not be sent. Please try again or use email.';
      } finally {
        button.disabled = false;
      }
    });
  }
})();

