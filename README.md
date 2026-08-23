# voitiuk.com

Персональний двомовний сайт української художниці-графіка Анни Войтюк. Сайт зібраний на Jekyll і розгортається через GitHub Pages.

Цей файл — інструкція для підтримки сайту: де лежить контент, як додавати роботи, публікації, виставки й джерела та що перевіряти перед публікацією.

## Де що знаходиться

| Що потрібно змінити | Файл або каталог |
| --- | --- |
| Тексти інтерфейсу, головної, біографії, контактів і футера | `_data/content.yml` |
| Вибрані роботи | `_data/works.yml` |
| Повний каталог виставки «Червона книга» | `_data/red_book_2026.yml` |
| Нагороди | `_data/awards.yml` |
| Персональні та групові виставки | `_data/exhibitions.yml` |
| Картки авторських матеріалів сайту | `_data/articles.yml` |
| Освіта, бібліографічні публікації, проєкти, преса й дослідження | `_data/professional.yml` |
| Реєстр зовнішніх джерел і локальних каталогів | `_data/sources.yml` |
| Українські сторінки | `uk/` |
| Англійські сторінки | `en/` |
| Шаблони сторінок | `_layouts/` |
| Повторно використовувані фрагменти | `_includes/` |
| Повнорозмірні роботи та прев’ю | `assets/img/works/` |
| Зображення для публікацій | `assets/img/publications/` |
| «Червона книга»: повні зображення | `assets/img/exhibitions/red-book-2026/full/` |
| «Червона книга»: прев’ю | `assets/img/exhibitions/red-book-2026/thumbs/` |
| Локальний архів каталогів | `assets/documents/catalogues/` |
| PDF-резюме та інші документи | `assets/documents/` |
| Стилі та JavaScript | `assets/css/`, `assets/js/` |
| Налаштування сайту, Formspree і Clarity | `_config.yml` |
| GitHub Pages workflow | `.github/workflows/jekyll.yml` |

`_site/`, `.jekyll-cache/`, `tmp/`, `vendor/` і `.bundle/` є згенерованими або локальними службовими каталогами. Їх не потрібно редагувати й комітити.

## Як влаштований контент

Сайт розділяє дані та сторінки:

- YAML-файли в `_data/` містять структуровані факти й переклади;
- файли в `en/` і `uk/` створюють URL та, для статей, містять сам текст;
- `_layouts/` перетворюють ці дані на HTML;
- `_includes/` відповідають за типові елементи: картки робіт, посилання на джерела, позначення технік, Etsy-блоки й lightbox.

Порядок записів у YAML здебільшого є порядком відображення на сайті. Нагороди, виставки й публікації варто тримати від нових до старих. У `_data/works.yml` порядок є кураторським порядком вибраних робіт.

### Правила для YAML

- Використовуйте пробіли, не табуляцію.
- Дотримуйтеся наявних відступів у два пробіли.
- Рядки з двокрапкою, лапками або іншими спеціальними символами краще брати в лапки.
- Дати записуйте як рядки у форматі `"YYYY-MM-DD"`.
- Ідентифікатори й `slug` пишіть латиницею в `kebab-case`.
- Для розміру роботи використовуйте знак множення `×`, а не літеру `x`.
- Кожен публічний факт має походити з підтвердженого джерела. Внутрішні припущення й неперевірені нотатки на сайт не виносимо.

## Мови й маршрути

- Англійська версія живе під `/en/`.
- Українська версія живе під `/uk/`.
- Корінь `/` — сторінка вибору мови з шаблоном `_layouts/gateway.html`.
- Вибір зберігається в `localStorage` під ключем `voitiuk-language`.
- Для української або російської бажаної мови браузера пропонується українська; для інших мов — англійська.
- `/?choose=1` примусово відкриває селектор, навіть якщо вибір уже збережено.

Для кожної звичайної сторінки мають існувати обидві мовні адреси. У front matter потрібно вказувати взаємні альтернативи:

```yaml
alternate_en: /en/example/
alternate_uk: /uk/example/
```

Файли `en-html.md`, `uk-html.md`, `de.md` та інші redirect-файли в корені підтримують старі або вже проіндексовані адреси. Не видаляйте їх без перевірки зовнішніх посилань і пошукової індексації.

## Як додати вибрану роботу

### 1. Підготувати зображення

Для кожної роботи потрібні:

- повнорозмірне зображення `assets/img/works/<slug>.jpg`;
- прев’ю до 960 px `assets/img/works/<slug>-960.jpg`.

Перед додаванням:

1. Фізично застосуйте EXIF-поворот, щоб файл був правильно орієнтований без допомоги метаданих.
2. Видаліть EXIF/IPTC/XMP, особливо GPS, дані пристрою та службові коментарі.
3. Перевірте окремо повне зображення і прев’ю: вони можуть мати різну орієнтацію.
4. Запишіть фактичні розміри обох файлів у пікселях.
5. Не збільшуйте мале зображення штучно заради формального розміру.

### 2. Додати запис у `_data/works.yml`

```yaml
- id: example-work
  slug: example-work
  title:
    en: "Example Work"
    uk: "Приклад роботи"
  year: 2026
  technique:
    en: "Drypoint on plastic"
    uk: "Суха голка на пластику"
  technique_code: "C4"
  plate_size: "12.5 × 17.5 cm"
  edition: 20
  image: "/assets/img/works/example-work.jpg"
  thumbnail: "/assets/img/works/example-work-960.jpg"
  image_width: 1588
  image_height: 1588
  thumbnail_width: 960
  thumbnail_height: 960
  alt:
    en: "A concise description of the visible artwork"
    uk: "Стислий опис того, що зображено на роботі"
  description:
    en: "Optional extended description."
    uk: "Необов’язковий розширений опис."
  source_id: example-source
```

Обов’язково звірте `technique` і `technique_code`. Код не замінює зрозумілу назву техніки. Поля `year`, `edition`, `description` і `source_id` можна не додавати, якщо достовірних даних немає.

### 3. Створити дві сторінки роботи

`en/works/example-work.md`:

```yaml
---
layout: artwork
lang: en
page_key: artwork
work_id: example-work
title: "Example Work — Anna Voitiuk"
description: "Short English description for search and sharing."
image: /assets/img/works/example-work.jpg
permalink: /en/works/example-work/
alternate_en: /en/works/example-work/
alternate_uk: /uk/works/example-work/
---
```

Створіть аналогічний файл у `uk/works/example-work.md` з `lang: uk`, українськими `title` і `description` та українським `permalink`. `work_id` в обох файлах має точно збігатися з `id` у `_data/works.yml`. Текст сторінки нижче front matter не потрібен: його будує шаблон `artwork`.

## Як додати публікацію

На сайті є два різні типи публікацій. Їх важливо не плутати.

### Авторський матеріал на самому сайті

Це стаття, відеопублікація або інший матеріал, який має власну сторінку на `voitiuk.com`.

Спочатку додайте картку до `_data/articles.yml`:

```yaml
- date: "2026-08-23"
  date_label:
    en: "23 August 2026"
    uk: "23 серпня 2026"
  kind: "article"
  image: "/assets/img/publications/example.jpg"
  image_alt:
    en: "Description of the preview image"
    uk: "Опис зображення публікації"
  title:
    en: "English title"
    uk: "Українська назва"
  summary:
    en: "Short English summary."
    uk: "Короткий український опис."
  cta:
    en: "Read"
    uk: "Читати"
  url:
    en: "/en/articles/example/"
    uk: "/uk/articles/example/"
```

Потім створіть обидві мовні сторінки, наприклад `en/articles/example.md` і `uk/articles/example.md`:

```yaml
---
layout: article
lang: uk
page_key: article
parent_url: /uk/publications/
og_type: article
title: "Назва — Анна Войтюк"
article_title: "Назва"
description: "Опис для пошуку й поширення."
eyebrow: "Стаття"
date: "2026-08-23"
date_label: "23 серпня 2026"
reading_time: "8 хв читання"
image: /assets/img/publications/example.jpg
image_alt: "Опис зображення"
image_caption: "Необов’язковий підпис"
permalink: /uk/articles/example/
alternate_en: /en/articles/example/
alternate_uk: /uk/articles/example/
sources_title: "Джерела"
open_source: "Відкрити джерело"
back_label: "До публікацій"
source_ids:
  - first-source
  - second-source
---

Текст статті у Markdown починається тут.
```

Додаткові поля, які вже підтримує шаблон:

- `ai_disclosure` — чесне повідомлення про застосування ШІ;
- `video_id`, `video_title`, `video_duration_iso` — YouTube-відео;
- `video_load_label`, `video_external_label` — підписи кнопок відео.

Для YouTube зберігається локальне прев’ю, а iframe з `youtube-nocookie.com` завантажується лише після натискання. Це швидше й приватніше за автоматичне вбудовування.

Якщо в тексті є ручні посилання виду `[1]`, `[2]`, їхній порядок має збігатися з порядком `source_ids`. Якір кожного джерела має вигляд `#source-<source_id>`, наприклад:

```html
<sup><a href="#source-first-source">[1]</a></sup>
```

### Бібліографічна згадка в CV

Якщо це каталог, журнальна стаття, згадка в пресі, дослідницький матеріал або проєкт без окремої авторської сторінки на сайті, додайте його до відповідного списку в `_data/professional.yml`:

- `publications` — бібліографічні публікації;
- `projects` — проєкти;
- `press` — матеріали преси;
- `research` — дослідження;
- `education` — освіта.

Ці записи автоматично з’являються на сторінці публікацій і/або у вебрезюме. Для підтверджень використовуйте `source_ids`.

## Як додати виставку

Звичайні персональні та групові виставки зберігаються в `_data/exhibitions.yml` у списках `solo` та `group`.

Приклад персональної виставки:

```yaml
- year: 2026
  title:
    en: "Exhibition title"
    uk: "Назва виставки"
  venue:
    en: "Gallery name"
    uk: "Назва галереї"
  city:
    en: "Lviv, Ukraine"
    uk: "Львів, Україна"
  start_date: "2026-08-18"
  end_date: "2026-09-13"
  dates:
    en: "18 August — 13 September 2026"
    uk: "18 серпня — 13 вересня 2026"
  summary:
    en: "Short description."
    uk: "Короткий опис."
  page:
    en: "/en/exhibitions/example/"
    uk: "/uk/exhibitions/example/"
  current: true
  source_ids: [example-source]
```

`current: true` виводить виставку в блоці поточних подій на головній. Таких виставок може бути кілька. Поле `page` не є обов’язковим, якщо окремої сторінки немає.

### Окрема галерея «Червона книга»

Це спеціальний розділ, а не запис у `_data/works.yml`:

- дані: `_data/red_book_2026.yml`;
- український маршрут: `uk/exhibitions/red-book-2026.md`;
- англійський маршрут: `en/exhibitions/red-book-2026.md`;
- повні зображення: `assets/img/exhibitions/red-book-2026/full/<slug>.jpg`;
- прев’ю: `assets/img/exhibitions/red-book-2026/thumbs/<slug>.jpg`.

Ім’я файлу зображення утворюється зі `slug` роботи. Записи згруповані за серіями; порядок серій і робіт у YAML є порядком на сторінці.

Шаблон `_layouts/exhibition-gallery.html` зараз навмисно прив’язаний до `_data/red_book_2026.yml`, дат цієї виставки й джерела `green-sofa-2026`. Для наступної великої виставки його потрібно узагальнити або зробити окремий шаблон; самого копіювання YAML недостатньо.

## Як додати нагороду

Додайте запис до `_data/awards.yml`, зберігаючи хронологію від нових до старих:

```yaml
- year: 2026
  award: "Назва нагороди так, як її подає організатор"
  event: "Назва конкурсу"
  city: "Місто"
  country:
    en: "Country"
    uk: "Країна"
  artwork: "Optional artwork title"
  technique: "C3, C5"
  size: "95 × 120 mm"
  source_ids: [official-result, official-catalogue]
  featured: true
```

`featured: true` показує запис серед вибраних нагород на головній. Повний список використовується у вебрезюме.

Якщо конкурс проводився в одному місті кілька разів, створюйте окремі записи з правильним роком, нагородою і джерелом. Не об’єднуйте їх лише через однакову географічну назву.

## Джерела, вебархів і локальні каталоги

Усі повторно використовувані джерела реєструються один раз у `_data/sources.yml`, а інші файли посилаються на них через `source_id` або `source_ids`.

```yaml
example-catalogue:
  label: "Official exhibition catalogue"
  organization: "Organiser name"
  url: "/assets/documents/catalogues/example.pdf"
  original_url: "https://example.org/catalogue.pdf"
  archive_url: "https://web.archive.org/web/.../https://example.org/catalogue.pdf"
  type: "official-catalogue"
  file_size: 12345678
  pages: 120
  verified_pages: [42]
  printed_pages: [40]
  sha256: "optional-checksum"
  last_checked: "2026-08-23"
```

Підтримувані типи впливають на підпис посилання:

- `official-catalogue` — «Каталог»;
- `jury-protocol` або `official-results` — «Результати»;
- інші — «Джерело».

Практичні правила:

- Для важливих PDF краще зберігати локальну копію в `assets/documents/catalogues/`, бо сторонні сайти зникають.
- Для локальної копії залишайте `original_url`, щоб було видно походження документа.
- `archive_url` додавайте лише після перевірки, що конкретний знімок справді відкривається. Наявність адреси у Wayback Machine ще не гарантує доступності сторінки або PDF.
- `verified_pages` — сторінки PDF-файлу, де факт перевірено; `printed_pages` — надруковані в самому каталозі номери, якщо вони відрізняються.
- Для великого архівного PDF бажано записати `file_size` і `sha256`.
- `public: false` приховує джерело з публічного інтерфейсу; `availability: "missing"` можна використати для відомого, але недоступного ресурсу.

Компонент `_includes/source-links.html` сам відкриває зовнішні джерела, вебархіви й PDF у новій вкладці. Не потрібно дублювати `target="_blank"` у кожному записі.

## Як оновити резюме

Вебверсія резюме збирається з `_data/awards.yml`, `_data/exhibitions.yml` і `_data/professional.yml`.

Окремий файл для завантаження зараз лежить тут:

```text
assets/documents/Anna_Voitiuk_CV_2026-08-20.pdf
```

Посилання на нього задано в `_layouts/cv.html`, а джерело — у `_data/sources.yml`. Якщо змінюється ім’я PDF, оновіть обидва місця. PDF відкривається в окремій вкладці.

## Як змінити звичайний текст

Більшість коротких написів і великих текстових блоків містяться в `_data/content.yml`. Структура поділена на `en` та `uk`. Додаючи новий ключ, одразу додайте обидва переклади, інакше на одній з мов сторінка матиме порожнє місце.

Довгі статті зберігаються безпосередньо у відповідних Markdown-файлах у `en/articles/`, `uk/articles/`, `en/publications/` або `uk/publications/`.

## SEO та доступність нової сторінки

У front matter нової сторінки мають бути щонайменше:

- зрозумілий `title`;
- унікальний `description`;
- правильний `lang`;
- стабільний `permalink`;
- `alternate_en` та `alternate_uk`;
- `image` і змістовний `image_alt`, якщо сторінка має головне зображення.

Для декоративного зображення допустимий порожній `alt=""`; для роботи, прев’ю статті або змістового фото alt має описувати побачене, а не повторювати назву файлу.

Нові публічні сторінки автоматично потрапляють до `sitemap.xml`, якщо їх не виключено явно. Після зміни маршрутів перевірте також canonical та мовні alternate-посилання у зібраному HTML.

## Локальний запуск

Потрібні Ruby, Bundler і залежності з `Gemfile`.

```powershell
bundle install
bundle exec jekyll serve
```

Сайт буде доступний за адресою `http://localhost:4000/`.

Продакшн-збірка в PowerShell:

```powershell
$env:JEKYLL_ENV = "production"
bundle exec jekyll build
Remove-Item Env:JEKYLL_ENV
```

У POSIX-shell:

```sh
JEKYLL_ENV=production bundle exec jekyll build
```

Не редагуйте результат у `_site/`: наступна збірка його перезапише.

## Що перевірити перед комітом

1. `bundle exec jekyll build` завершується без помилок.
2. `git diff --check` не знаходить зайвих пробілів і конфліктних маркерів.
3. Обидві мовні версії нової сторінки відкриваються.
4. Перемикач мови веде на відповідний матеріал, а не лише на головну.
5. Зображення не перевернуті, прев’ю відповідає повному файлу, метадані очищено.
6. У всіх змістових зображень є коректний alt.
7. Джерела справді підтверджують Анну Войтюк і саме той факт, біля якого стоять.
8. Зовнішні джерела, соцмережі, Etsy, локальні PDF і вебархів відкриваються в новій вкладці.
9. Ручні номери джерел у статтях ідуть по порядку та відповідають `source_ids`.
10. Перевірені маршрути: `/`, `/?choose=1`, `/en/`, `/uk/`, `/en/works/`, `/uk/works/`, обидві сторінки публікацій і актуальні виставки.

Після push у `master` GitHub Actions збирає сайт і публікує його на GitHub Pages. Адреса продакшну задається в `_config.yml` та `CNAME`.

## Типові помилки

- Додати дані роботи, але не створити два мовні файли маршруту.
- Створити статтю, але не додати її картку до `_data/articles.yml`.
- Додати бібліографічну згадку до `articles.yml`, хоча їй місце в `_data/professional.yml`.
- Вказати неіснуючий `source_id`: Jekyll не завжди повідомить про це як про фатальну помилку, але посилання зникне.
- Покласти роботи «Червоної книги» в `_data/works.yml` і очікувати, що вони автоматично з’являться в каталозі виставки.
- Покладатися на EXIF-поворот: браузер, генератор прев’ю і lightbox можуть трактувати його по-різному.
- Виправити лише українську або лише англійську версію.
- Редагувати `_site/` замість вихідних файлів.
