# Audit TODO

The open findings of an audit of what `plass-ui` can do to the loading speed, the responsiveness and the search ranking of a website that uses it (Core Web Vitals and SEO), taken at `62e1b599` on 2026-10-04. Every docs demo was rendered with `renderToString` in Node and hydrated with `hydrateRoot` in a browser, its controls were pressed at a 4x CPU slowdown, and the source was read for layout, listener and markup problems. When no item is left, delete this file in a commit of its own.

A closed item is deleted from this file, not ticked, and its number is not used again.

**12 items are open, and the last number used is 106.** Batch 1 (2026-10-04) closed items 1 to 23 and 32 to 44; batch 2 (2026-10-04) closed items 24 to 31 and 45 to 50; batch 3 (2026-10-04) closed items 51 to 94, the small differences batches 1 and 2 noted in passing and the ones batch 3 noted on its way, all made items on the Prompter's word. Items 95 to 106 are what batch 3 noted last, and their work is under way.

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

Line numbers are from `3a00ba0e8` and drift as the code changes; when one no longer matches, search for the symbol.

### Low

- **95.** **A `visible` effect that is not `once` starts again every time its share on screen crosses one of the observer's steps** (`internal/animate.ts` ~695, `check` calls `start()` on every report while it is shown), so a half-visible counter or fade replays from its first frame as the page scrolls. Flutter's `_checkVisible` (`animate.dart` ~375) starts only one that has not started.
- **96.** **A `visible` `PlAnimateTyping` that is not `once` waits for its return with the line typed in Flutter** (`pl_animate_typing.dart` ~265) and with an empty line in React (`PlAnimateTyping.tsx` ~195). Decided: Flutter waits with an empty line, as React does and as item 88 decided for the counter and the scramble.
- **97.** **`PlWindowPane` resizes, steps with a key and holds a minimised height from the size it is drawn at** (`PlWindowPane.tsx` ~715, ~752, ~790), and does not convert a pointer's movement, so inside a scaled ancestor each of them is off by the scale (items 80, 91 and 92 fixed the same in `PlPanes`, `PlSidebar` and `PlCarousel`).
- **98.** **`PlScrollZone` measures an item's start on the screen and passes it to `scrollByPixels`** (~410–415, ~446–458), and writes a drag's `dx` to `scrollLeft` unconverted (~540–577), so inside a scaled ancestor it scrolls by the drawn distance.
- **99.** **The calendar's `revealInColumn` adds a rect difference to `scrollTop`** (`internal/calendar.tsx` ~1214–1222), so inside a scaled ancestor a time column scrolls the chosen value short of view.
- **100.** **`styles.css` ~54 says everything but three values per family is derived with `color-mix()`**, the claim item 94 corrected in the docs.
- **101.** **A disabled Flutter `PlBreadcrumb` step with `onPressed` drops its link semantics** (`pl_breadcrumb.dart` ~410, `link: null`), so it is announced as unavailable text, where React now announces such a step as an unavailable link (item 90).
- **102.** **`PlBreadcrumb`'s `structuredData` keeps a disabled step's address** (`stepHref` does not read `disabled`). Decided: keep it, since Google's `BreadcrumbList` needs an `item` on every step but the last; say so on the breadcrumb page.
- **103.** **A disabled `PlBreadcrumbItem` or `PlListItem` with only an `onClick` is plain text**, where a disabled `PlChip` stays a `<button disabled>`. Decided: draw it as a `<button disabled>`, announced as an unavailable button, and match it in Flutter.
- **104.** **A React slide inside a mask with `once={false}` stops partway** (`internal/animate.ts` ~695): `restingRect` measures a running effect's drawn box, so the first report while it slides in reads below the threshold and lets it go, and the slide holds at about a tenth of its way until the page scrolls. Flutter measures the box before the move.
- **105.** **Flutter's `_checkVisible` has no `shown > 0`** (`animate.dart` ~374), so a `threshold` of `0` starts an effect that is off screen; React needs at least one pixel.
- **106.** **A new run of a `paused` `PlAnimateTyping`** (a `hover` one the pointer enters again) **keeps the old line in React** (`PlAnimateTyping.tsx` ~212) **and shows an empty one in Flutter** (`pl_animate_typing.dart` ~309). Decided: `paused` holds what is on screen in both builds, and the new run types from its first character once it is let go.

## Decided and recorded

- **Time zones (item 32).** Only the clock is pinned to UTC for a server render and its hydration. A date a caller passes stays in each runtime's own zone, because the library treats a `Date` as a wall-clock day and pinning it would move dates east of UTC by a day; the locales guide tells a server-rendered page to build its dates from year, month and day. A date built from an instant (an ISO timestamp) can still differ between server and browser; a `timeZone` prop would be the way to close that, and is not planned.
- **Popup openings (item 17).** Profiled at 4x: most of a first opening is Base UI and React work, first-run compilation, the blur's raster and Base UI's positioner restyling the popup twice; Plass's own share was at most 15 ms. Only the pickers' needless second render was fixed.
- **A footer's content height (item 45).** The first paint reserves a fixed or sticky footer's padding and edges, not the height of what is inside it; a `min-height` on the footer does not reach the layout's first-paint rules, so the page-layout page recommends a `sticky` footer with `footerSpan="content"` for a page that must not move. No new prop.
- **`content-visibility` for glass lists (item 31).** Measured on 300 glass cards: on the list item it clips the cards' shadows, and on the card it changes nothing the eye sees but leaves the blur's draw time as it was, so the docs do not recommend it.
- **Charts and LCP (item 25).** Chromium does not count inline SVG shapes as LCP candidates, so `initialWidth` gives a complete first paint and indexable tick text rather than a better LCP score, except for a `PlGaugeChart`'s reading, which is HTML text.
- **Locale for matching typed text (item 53).** `PlCombobox` matches and folds case in the runtime's locale (`en-US` while a server render hydrates), as `PlDataTable`'s collation and `PlAvatar`'s initials do, not in `PlassProvider`'s `locale`.
- **A `dir` changed on a wrapper (item 58).** A subtree whose direction changes at run time takes `PlassProvider direction`, as `rtl.md` says; the components do not watch a wrapper's `dir`.
- **A failed lazy import in Chromium (item 68).** Chromium keeps a failed dynamic import in its module map until the page reloads, and the specifier belongs to the consumer's bundler, so the library cannot add a query that would make the second try reach the network. Recorded as the browser's behaviour.
- **Below the `color-mix()` floor (items 75 and 93).** Every supported browser has `color-mix()`, so what the compiled sheet's fallbacks and the components' own `color-mix()` values draw without it is not worked on.
- **Width reservation (items 76 and 79).** `WidthSizer` reserves a space more in Firefox beside wide East Asian characters, and in Chromium and Firefox beside U+200B. Erring wide keeps a chosen label from growing its box; erring narrow would move the layout.
- **Glow light and `useCommitChange` (item 81).** Its observer's callback runs on each pointer move of the glow, as an empty microtask; the measurement does not run under real input, so nothing changes.
- **A disabled navigation menu trigger under the pointer (item 83).** It is out of the Tab order but takes the focus on a press, as a `<button tabindex="-1">` does; it opens nothing and shows no ring, so it is kept.

## Noted differences

None. Every difference noted in batches 1 to 3 is an item above, or was closed and recorded.
