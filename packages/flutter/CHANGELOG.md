# Changelog

> This package's unreleased changes and its latest release. Every earlier release is in [`CHANGELOG.archive.md`](https://github.com/jooy2/plass-ui/blob/main/packages/flutter/CHANGELOG.archive.md), and [plass.cdget.com/changelog](https://plass.cdget.com/changelog) shows the whole history on one page. The React package keeps its own at [`packages/react/CHANGELOG.md`](https://github.com/jooy2/plass-ui/blob/main/packages/react/CHANGELOG.md), because the two version independently.

## vNext (2026--)

## 1.10.1 (2026-11-26)

### Fixed

- **A Flutter preview on the documentation site stops growing when a field in it is pressed.** The preview took the handles a field puts up for its caret and its selection for a popup, and asked the page for a taller frame on every frame, until the field was squeezed out of sight. Only a press outside the preview brought it back.
