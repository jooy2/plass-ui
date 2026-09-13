---
title: Browser support
---

# Browser support

<p class="plass-lede">The oldest browsers each package works in, the platform features that decide those versions, and what someone on an older browser loses.</p>

::: fw react

## Minimum versions

| Browser               | Full support | Works, with gaps | Not supported  |
| --------------------- | ------------ | ---------------- | -------------- |
| Chrome, Edge          | 111          | None             | 110 and older  |
| Firefox               | 128          | 113 to 127       | 112 and older  |
| Safari, Safari on iOS | 16.4         | None             | 16.3 and older |

**Full support** means every component looks and behaves as its page describes. **Works, with gaps** means the components run and stay usable, without the features listed under [What older browsers lose](#what-older-browsers-lose).

Chrome 111 and Safari 16.4 were released in March 2023, and Firefox 128 in July 2024. Any other browser built on Chromium follows its Chromium version. Chrome and Firefox on iOS run on Safari's engine, so the Safari row applies to them.

Both stylesheets draw the same line. `plass-ui/styles.css` is compiled for these versions, and a project that imports `plass-ui/tailwind.css` compiles it with its own Tailwind CSS v4, which [targets the same three browsers](https://tailwindcss.com/docs/compatibility).

## What decides it

CSS decides the line, not JavaScript. A bundler can rewrite newer syntax and a polyfill can add a missing function, but nothing added to a build gives a browser a CSS feature it does not have.

| Requirement | Chrome | Firefox | Safari | Used for |
| --- | --- | --- | --- | --- |
| `color-mix()` | 111 | 113 | 16.2 | Every colour family's focus ring, soft fill, edge and tinted shadow |
| Base UI | 111 | 113 | 16.4 | The behaviour and accessibility of the interactive components |
| Tailwind CSS v4 | 111 | 128 | 16.4 | The compiled utilities and the theme values they read |

**`color-mix()` is the hard line.** In a browser without it, every property that reads one of those tokens falls back to its default. The focus ring disappears together with the hover fills, the coloured edges and the tinted shadows, and someone using a keyboard can no longer see where the focus is.

[Base UI](https://base-ui.com/react/overview/about) supports the browsers that were Baseline Widely Available when its current major version was released. Safari 16.2 and 16.3 have every CSS feature the hard line needs, but they are outside that range, so Safari has no versions that work with gaps.

Tailwind CSS v4 targets Firefox 128, and its compiled utilities carry fallbacks for older Firefox releases. What Firefox 113 to 127 still miss is listed in the next section.

The JavaScript is well below the line. The JavaScript in `dist/`, in Base UI and in React uses no syntax newer than Chrome 91, Firefox 79 and Safari 14.1.

## What older browsers lose

Firefox 113 to 127 run the components without these features:

| Feature | Firefox | Without it |
| --- | --- | --- |
| `:has()` | 121 | `PlTextField`, `PlSelect`, `PlCombobox`, `PlNumberField`, `PlRating` and the picker fields (`PlDatePicker`, `PlDateRangePicker`, `PlDateTimePicker`, `PlTimePicker`, `PlColorPicker`, `PlTreeSelect`) draw no focus ring. They still take focus; only the ring is missing. |
| `lh` unit | 120 | A checkbox tick, a radio dot, an alert's glyph and the other icons placed beside a label can sit slightly above the middle of the label's first line. |
| `Intl.Segmenter` | 125 | [`PlAnimateTyping`](./components/transitions/animate-typing) advances one code point at a time, so an emoji built from several code points appears in pieces. |
| `@property` | 128 | The light in [`PlAnimateLighting`](./components/transitions/animate-lighting) stays in place instead of travelling around the edge. |

The first row affects keyboard users most, because the fields that lose their ring are the ones they fill in. If an application has to work well with a keyboard, treat Firefox 121 as its minimum.

## Newer features used where they exist

Some features are missing from browsers inside the full-support range. Each one is used only where the browser has it, and a browser without it gets the result in the last column.

| Feature | Chrome | Firefox | Safari | Used for | Without it |
| --- | --- | --- | --- | --- | --- |
| `animation-timeline` | 115 | Not yet | 26 | `timeline="view"` on the transition effects, which follows the scroll position | The effect runs on its `duration`, as it does without `timeline` |
| `fetchpriority` | 101 | 132 | 17.2 | `priority` on [`PlImage`](./components/display/image), which asks for the picture a page is judged by ahead of the others | The picture is still fetched eagerly, at the browser's default priority |
| `hidden="until-found"` | 102 | 139 | 26.2 | `hiddenUntilFound` on [`PlAccordion`](./components/surfaces/accordion) and [`PlCollapsible`](./components/surfaces/collapsible), which lets find-in-page open a closed panel | Text inside a closed panel is not found |
| `Intl.Locale` week data | 99 | 153 | 15.4 | Calendars start the week on the day the locale starts it | The week starts on Sunday unless `weekStartsOn` is set on the component or on [`PlassProvider`](./guide/defaults) |

Firefox before 148 and Safari open the panel that holds the match, but do not scroll to the matched text correctly.

## How these versions were found

Every pull request runs the React test suite in the Chromium, Firefox and WebKit builds that Playwright ships, on Linux, Windows and macOS. Those builds follow the current releases, so older versions are not tested.

The versions on this page come from what the package ships, checked against [MDN's browser compatibility data](https://github.com/mdn/browser-compat-data): the compiled stylesheet, the JavaScript in `dist/`, and the Base UI release the package depends on. The Base UI and Tailwind CSS rows are what those projects state for themselves. The page was last checked against `plass-ui` 1.4.0 and `@base-ui/react` 1.8.0.

:::

::: fw flutter

## Flutter web

`plass_ui` adds no browser requirement of its own. The Flutter engine draws every component, and the package has no web-specific code, so a Flutter web app that uses it runs in the same browsers as one that does not. Those browsers are set by the Flutter SDK the app is built with, which is 3.41 or later.

At the time of writing, [Flutter's supported platforms page](https://docs.flutter.dev/reference/supported-platforms) lists these for Flutter 3.47:

| Browser      | Supported               | Not supported  |
| ------------ | ----------------------- | -------------- |
| Chrome, Edge | The latest two versions | 95 and older   |
| Firefox      | The latest two versions | 98 and older   |
| Safari       | 15.6 and newer          | 15.5 and older |

Flutter does not say whether the versions between the two columns work.

`flutter build web` compiles to JavaScript. A build with `--wasm` adds a WebAssembly version and keeps the JavaScript one, which Flutter uses in browsers that cannot run the WebAssembly version. [Flutter's WebAssembly page](https://docs.flutter.dev/platform-integration/web/wasm) lists which browsers currently run it.

## Other platforms

The same holds on Android, iOS, Linux, macOS and Windows: the package runs wherever Flutter 3.41 or later does, and the supported platforms page lists the versions.

:::
