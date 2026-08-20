# voitiuk.com

Portfolio website for Ukrainian printmaker and graphic artist Anna Voitiuk.

## Structure

- English routes live under `/en/`; Ukrainian routes live under `/uk/`.
- Localised interface and biography copy are in `_data/content.yml`.
- Artwork metadata is in `_data/works.yml`.
- Awards, exhibitions, publications, sources, and pending verification records are in separate `_data/*.yml` files.
- Page rendering is handled by local layouts in `_layouts/`; the site no longer depends on the Agency remote theme.
- Full-size and 960 px artwork renditions are in `assets/img/works/`.
- The downloadable CV is in `assets/documents/`.

## Content rules

Only verified or explicitly artist-CV-supplied facts are published. Unconfirmed award records and missing artwork fields stay in `_data/pending_verification.yml` and are not rendered in production.

To add a work, add one object to `_data/works.yml`, provide local images, and create matching EN/UA artwork route files. Do not use stock or generated images as substitutes for Anna's work.

## Development

```sh
bundle install
bundle exec jekyll serve
```

The production build is:

```sh
JEKYLL_ENV=production bundle exec jekyll build
```
