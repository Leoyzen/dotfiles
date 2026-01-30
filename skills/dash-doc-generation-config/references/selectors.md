# Documentation Framework Selectors

Common CSS selectors for popular documentation frameworks to assist in building Dash docsets.

## MkDocs Material
- **Page Title**: `title` (needs cleaning of " - Project Name" suffix).
- **Breadcrumbs**: `.md-path__item` or `.md-breadcrumbs__item`.
- **Active Navigation**: `.md-nav__item--active > .md-nav__link`.
- **API Objects (mkdocstrings)**: `.doc-object`.
  - Class: `.doc-class`.
  - Function/Method: `.doc-function`.
  - Attribute/Field: `.doc-attribute`.
  - Header with ID: `h1, h2, h3, h4` within `.doc-object`.
- **Noise Elements (to hide)**: `.md-header, .md-tabs, .md-sidebar, .md-footer, .md-source, .md-content__button, .headerlink`.

## Sphinx (Standard Theme)
- **API Objects**: `.py.class`, `.py.function`, `.py.method`.
- **Signature Name**: `.sig-name.descname`.
- **Breadcrumbs**: `.wy-breadcrumbs`.
- **Noise Elements**: `.wy-nav-side, .wy-nav-content-wrap > nav, footer`.

## Docusaurus
- **API Objects**: Often tagged with custom classes or just standard markdown.
- **Breadcrumbs**: `.breadcrumbs__item`.
- **Noise Elements**: `.navbar, .footer, .theme-doc-sidebar-container`.
