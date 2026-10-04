# Audit TODO

The open findings of an audit of what `plass-ui` can do to the loading speed, the responsiveness and the search ranking of a website that uses it (Core Web Vitals and SEO), taken at `62e1b599` on 2026-10-04. Every docs demo was rendered with `renderToString` in Node and hydrated with `hydrateRoot` in a browser, its controls were pressed at a 4x CPU slowdown, and the source was read for layout, listener and markup problems. When no item is left, delete this file in a commit of its own.

A closed item is deleted from this file, not ticked, and its number is not used again.

**27 items are open, and the last number used is 77.** Batch 1 (2026-10-04) closed items 1 to 23 and 32 to 44; batch 2 (2026-10-04) closed items 24 to 31 and 45 to 50. Items 51 to 77 are the small differences batches 1 and 2 noted in passing, made items on the Prompter's word.

## Working through a batch

When the Prompter asks to continue this audit, run a batch as written here, without asking how.

1. **Answers first.** Do what the Prompter approved under [Waiting for an answer](#waiting-for-an-answer) before the batch. Remove every answered question from that section.
1. **Pick items.** Take open items by severity, High before Medium before Low, and by number within one severity. Skip an item flagged `Decision needed` or `API addition`, and an item that turns out to need a decision once the work starts.
1. **Confirm before fixing.** Check the finding against the code first. An item that no longer reproduces gets no commit; delete it, and name it in the report.
1. **One item, one commit.** For each item:
   - Fix it following `CLAUDE.md` and the code around the change. Behaviour and appearance stay as they are unless the item says otherwise.
   - Add a test that fails without the fix, and prove it: commit first, then check the sources out of the parent commit with `git checkout HEAD~1 -- <paths>`, run the test, and check them back with `git checkout HEAD -- <paths>`. Never `git stash`. When a test cannot show the difference, say so in the report.
   - Add a user-facing entry under `## vNext` in `packages/react/CHANGELOG.md` (and the Flutter one when it changes), at the top of `Fixed`, `Changed` or `Added`. A change no user can notice gets no entry.
   - Update the documentation pages, `docs/en` and `docs/ko` together, and the props tables when documented behaviour changes.
   - Commit with the tags in `CONTRIBUTING.md`. No `Co-Authored-By` trailer.
1. **Stay inside the item.** A problem found in passing is not fixed; note it for the report.
1. **Verify the batch** with the commands below, all of them.
1. **Ask, then update this file and push.** Ask every question the batch raised through the prompt, record the answers, delete the batch's closed items, update the count at the top, commit this file on its own and push.
1. **Report in Korean and stop.**

Standing decisions:

- Questions go to the Prompter through the prompt (AskUserQuestion), all at once: several calls of four questions in one message. Each question says what the problem is and how it would be fixed, each option carries its pros and cons, and one option is marked recommended.
- An entry under [Waiting for an answer](#waiting-for-an-answer) has been answered and is approved.
- A problem found in passing becomes an item only when it hurts a consuming site's loading, responsiveness, layout stability or search visibility, or is wrong behaviour.

### Verifying a batch

```bash
cd packages/react && npm run lint && npm run typecheck && npx prettier --check src test CHANGELOG.md scripts && npm test && npm run build && npm run size
cd packages/flutter && dart format --line-length 100 lib test example/lib && flutter analyze && flutter test
cd docs && npm run typecheck && npm run lint && npx prettier --check . && npm run build
```

## Waiting for an answer

None.

## Items

Line numbers are from `511a9698e` and drift as the code changes; when one no longer matches, search for the symbol.

### Low

- **51.** **`PlSlider` ignores `PlassProvider`'s `locale`**, while `PlNumberField` and `PlMeter` read it (`PlSlider.tsx` ~233). Read it through `useLocale` as they do.
- **52.** **`docs/{en,ko}/guide/defaults.md` ~102 leaves `PlSparkline` out** of the components the provider's `locale` reaches.
- **53.** **`PlCombobox` lower-cases with the runtime locale** (`PlCombobox.tsx` ~455), which decides whether the custom row appears; use the resolved locale.
- **54.** **`getting-started.md`'s Next.js section** (en and ko) does not point to the locales guide's advice for server-rendered pages.
- **55.** **A browser whose time zone changes while a page is open** can show the calendar's month and weekday names a day off: `format.ts` caches formatters by locale and options only, and `WEEKDAY_ORIGIN` (`date.ts` ~487) is built once at load.
- **56.** **`internal/wheel.ts` ~136 calls `getComputedStyle(element).direction` on every wheel event** that moves a strip; read the direction the component already knows.
- **57.** **`PlDataTable` skips unchanged rows only while `columns` keeps its identity**, so an inline `columns` array redraws every row on each parent render. Compare columns by what they contain, or say on the page to keep `columns` stable.
- **58.** **A `dir` changed at run time on a wrapper, with no `PlassProvider direction`, leaves a `PlTabs` fade and indicator where they were** until something else changes. `rtl.md` already tells such a subtree to use the provider. `Decision needed` (observe the wrapper's `dir`, or keep the documented rule).
- **59.** **The direction reset for the marquee and the progress segment is exact two levels deep**; a right-to-left region inside a left-to-right one inside a right-to-left page runs the English way. Using `:dir()` alone, with the attribute rules only inside `@supports not selector(:dir(rtl))`, would be exact at any depth.
- **60.** **`PlPanes` (~330, ~362) and `PlMockup` (`usePlElementSize`) measure the border or content box where CSS resolves against another box**, so a padded split or mockup moves a few pixels at hydration.
- **61.** **An inline `style` change that moves segments without resizing the set is not re-measured on that commit** (`PlSegmentedButton`, `PlFloatingBottomNavigation`; their `MutationObserver` watches `class` and `dir`).
- **62.** **`drawerSide()` (`internal/page-layout.ts` ~204) reads the document's computed style on every render of a collapsed sidebar**, and a `PlHeader` that changes only its `position` is not measured again.
- **63.** **`localeWeekStart` (`internal/date.ts` ~568) builds an `Intl.DateTimeFormat` and an `Intl.Locale` on every picker render** when no locale is given; cache it per locale.
- **64.** **`animate-counter.md` ~77 says a new `value` counts from where the last one landed; the code counts from `from`** (`PlAnimateCounter.tsx` ~179). Check Flutter, then make the docs or the code true. `Decision needed` if both builds count from `from`.
- **65.** **Docs: a Flutter reader sees a 4px jump at hydration in a `<Demo>`** (`docs/.vitepress/theme/styles/docs.css` ~158 against `Demo.vue` `frameStyle`).
- **66.** **`PlAnimateCounter` with `maximumSignificantDigits` in `format` does not cap a frame's digits** (`resolvedOptions()` has no `maximumFractionDigits`, `PlAnimateCounter.tsx` ~100), so a count to 4,812 shows "12.3" on the way.
- **67.** **`PlAnimateTyping` let go during the hold before `erase` starts deleting after one delete step without finishing the hold**, and Flutter waits `_typeDelay` rather than `_deleteDelay` when it resumes partway through a deletion.
- **68.** **Chromium keeps a failed module import until the page reloads**, so item 40's second try only recovers in Firefox and WebKit. Check whether a retry can reach the network in Chromium without loading a second copy of the module; otherwise record it as the browser's behaviour.
- **69.** **`docs/package-lock.json` cannot be installed with the npm that ships with Node 20** (`npm ci` reports `react@18.3.1` missing); Node 26's npm installs it, and `docs/package.json` says `node >=20.19.0`.
- **70.** **A disabled Flutter `PlNavigationMenu` item is not a focus stop**, where the React one is reachable with Tab (Base UI's `focusableWhenDisabled`); read from the code, not run. `Decision needed` if they differ.
- **71.** **`PlTextLink.tsx` ~238 checks `rendersItsOwnHref`**, which Base UI 1.8.0's `mergeProps` already decides the same way.
- **72.** **`props-flutter.ts` ~1105: the Flutter-only `PlCard` `headingLevel` row is a plain row** without the shared tag the accordion and drawer rows now carry.
- **73.** **A disabled bottom navigation item is not a Tab stop, while a disabled navigation menu link is** (item 50 followed Base UI's trigger). `Decision needed` (make them agree, and which way).
- **74.** **Under reduced transparency, the scrims keep their dim and `blur(2px)`**, the tint-on-glass surfaces (a ghost `PlPill`, a pressed `glass` `PlToggle`, a `PlFilePicker` being dragged over) keep a translucent tint, and a consumer's own `--plass-blur` on a wrapper brings the blur back. `Decision needed`.
- **75.** **The compiled `dist/styles.css` falls back to the first colour of every `color-mix()` token** (for example `--plass-primary-soft` to the full accent), which only matters below the support floor; check whether any supported browser reaches the fallback.
- **76.** **`WidthSizer` normalises a line break inside a sample to a space**, where Firefox under `nowrap` drops a break between two wide East Asian characters, so Firefox can reserve one space more for such a label.
- **77.** **Moving to another step of a `PlStepper` drops the focus to the page's body** when it was inside the panel, since item 46 builds the panel anew. `Decision needed` (move the focus into the new panel, or keep it).

## Decided and recorded

- **Time zones (item 32).** Only the clock is pinned to UTC for a server render and its hydration. A date a caller passes stays in each runtime's own zone, because the library treats a `Date` as a wall-clock day and pinning it would move dates east of UTC by a day; the locales guide tells a server-rendered page to build its dates from year, month and day. A date built from an instant (an ISO timestamp) can still differ between server and browser; a `timeZone` prop would be the way to close that, and is not planned.
- **Popup openings (item 17).** Profiled at 4x: most of a first opening is Base UI and React work, first-run compilation, the blur's raster and Base UI's positioner restyling the popup twice; Plass's own share was at most 15 ms. Only the pickers' needless second render was fixed.

- **A footer's content height (item 45).** The first paint reserves a fixed or sticky footer's padding and edges, not the height of what is inside it; a `min-height` on the footer does not reach the layout's first-paint rules, so the page-layout page recommends a `sticky` footer with `footerSpan="content"` for a page that must not move. No new prop.
- **`content-visibility` for glass lists (item 31).** Measured on 300 glass cards: on the list item it clips the cards' shadows, and on the card it changes nothing the eye sees but leaves the blur's draw time as it was, so the docs do not recommend it.
- **Charts and LCP (item 25).** Chromium does not count inline SVG shapes as LCP candidates, so `initialWidth` gives a complete first paint and indexable tick text rather than a better LCP score, except for a `PlGaugeChart`'s reading, which is HTML text.

## Noted differences

None. Every difference noted in batches 1 and 2 is an item above.
