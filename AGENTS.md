# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Joget DX8/DX9 marketplace plugin (OSGi bundle). It's a Datalist `Column Formatter` that turns a datalist column into a link which opens its target (a URL or Userview Menu ID) in a slider panel sliding in from the right of the screen, instead of navigating away. It supports an optional multi-tab mode where multiple opened links dock as tabs in the same slider.

## Build

Requires Maven and a local/reachable Joget `wflow-core` 8.0-SNAPSHOT artifact (dependency in [pom.xml](pom.xml)), since this builds against Joget DX8 APIs.

```bash
mvn clean package
```

Produces an OSGi bundle jar in `target/` named `open-slider-list-formatter-<version>.jar`, embedding all compile/runtime-scoped dependencies (see `maven-bundle-plugin` config in [pom.xml](pom.xml)). This jar is uploaded directly into Joget as a plugin (Settings > Manage Plugins > Upload Plugin) — there is no separate deploy step in this repo.

Run tests (there are currently none under `src/test`, but surefire is wired to also run in the `integration-test` phase):

```bash
mvn test
```

There is no linter configured for this project.

## Architecture

This is a single-purpose plugin with three cooperating pieces:

- [`Activator.java`](src/main/java/org/joget/marketplace/Activator.java) — OSGi `BundleActivator` that registers `OpenSliderListFormatter` as an exported service. This is the plugin entry point Joget's plugin manager loads.
- [`OpenSliderListFormatter.java`](src/main/java/org/joget/marketplace/OpenSliderListFormatter.java) — extends Joget's `DataListColumnFormatDefault`. Its `format()` method runs once per row when Joget renders the datalist column:
  - On the *first* row of a datalist render (guarded by an `HttpServletRequest` attribute keyed by the class name, so it only runs once per request), it injects the slider FreeMarker template (`slider.ftl`) into the page, passing all styling properties as a `model` map with hardcoded fallback defaults for anything not configured.
  - For *every* row, it builds the target URL from the `href` property plus dynamic `hrefParam`/`hrefColumn` pairs (semicolon-delimited, matched positionally) whose values are pulled from the current row via `DataListService.evaluateColumnValueFromRow`, then emits an `<a>` tag with an `onClick="openSlider(url, tabTitle)"` handler.
  - `getLinkLabel()` supports `{columnName}` placeholder substitution in the configured `label` property, falling back to the raw column value, then to `"Hyperlink"`.
  - `getTabName()` resolves the multi-tab tab title: prefers the configured `tabNameColumn`, falling back to `getLinkLabel()`.
- [`slider.ftl`](src/main/resources/template/slider.ftl) — FreeMarker template containing the slider's HTML/CSS/JS, rendered once per page. It defines two independent behavior sets gated by the `multiTabEnabled` model flag:
  - **Single mode**: a plain sliding panel; `window.openSlider(url)` swaps a single iframe into `.slider-content`.
  - **Multi-tab mode** (`#if multiTabEnabled`): a dock with a tab bar, minimize/restore/close controls, and one iframe per tab (`window.openSlider(url, tabName)` adds/focuses a tab by URL identity). All colors, sizes, and spacing in this mode are FreeMarker-interpolated from the `model` map built in `format()`.
  - Both modes install `window.openSlider`/`window.closeSlider` as globals, so only one mode's script block should be reasoned about at a time depending on `multiTabEnabled`.

Configuration UI (property form fields, defaults, and `control_field`/`control_value` show/hide wiring for multi-tab-only options) is declared in [`OpenSliderListFormatter.json`](src/main/resources/properties/OpenSliderListFormatter.json); i18n labels/descriptions referenced via `@@key@@` live in [`OpenSliderListFormatter.properties`](src/main/resources/messages/OpenSliderListFormatter.properties). When adding a new configurable style property, all three of these plus the corresponding `model.put(...)` block in `format()` need to stay in sync.

`APP_OpenSliderListFormatterSampleApp-*.jwa` at the repo root is an exported sample Joget app for manually testing the plugin end-to-end after building.
