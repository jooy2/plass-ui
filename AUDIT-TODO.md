# Audit TODO

The open findings of an audit of what `plass-ui` can do to the loading speed, the responsiveness and the search ranking of a website that uses it (Core Web Vitals and SEO), taken at `62e1b599` on 2026-10-04. Every docs demo was rendered with `renderToString` in Node and hydrated with `hydrateRoot` in a browser, its controls were pressed at a 4x CPU slowdown, and the source was read for layout, listener and markup problems. When no item is left, delete this file in a commit of its own.

A closed item is deleted from this file, not ticked, and its number is not used again.

**5 items are open, and the last number used is 136.** Batch 1 (2026-10-04) closed items 1 to 23 and 32 to 44; batch 2 (2026-10-04) closed items 24 to 31 and 45 to 50; batch 3 (2026-10-04) closed items 51 to 130, the small differences batches 1 and 2 noted in passing and the ones batch 3 noted on its way, all made items on the Prompter's word. Batch 3 was paused on the Prompter's word with items 131 to 135 open: each is decided, and none has been started.

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

Line numbers are from `aa6957e47` and drift as the code changes; when one no longer matches, search for the symbol.

### Low

- **131.** **A `paused` endless effect jumps to where its run landed when reduced motion is turned off**, its first frame as a rule, so an endless fade held by `paused` turns almost transparent; both builds do it, since a finished CSS animation's clock holds at the landing point. Decided: both builds keep the frame that was on screen until `paused` is let go.
- **132.** **A finite effect that landed under reduced motion plays again in React when the setting is turned off before its run would have ended** (a fade that stood at 1 goes back to 0.25 and runs on); Flutter leaves it where it landed. Decided: React leaves it where it landed too.
- **133.** **A `delay` changed while a run is under way sends a React effect back to waiting** (a fade drops to opacity 0); Flutter ignores it. Decided: React ignores it too, and a new `delay` applies from the next run.
- **134.** **A Flutter effect `paused` during its `delay` lands at once when reduced motion arrives** (`animate.dart` ~1066, `_landed = _startedRuns >= 0 && _waiting == null`, and `_holdDelay` has already cleared `_waiting`), so an exit fade drops to 0 while paused and skips the rest of its wait once let go; React stays at 1 and lands when the wait would have ended.
- **135.** **A finished Flutter run whose `repeat` becomes `null` stays put and asks for no frame** (`_go()` calls `forward()` on a controller already at its upper bound); React starts turning again.

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
- **A fixed bottom bar inside a transform (item 115).** It writes `--plass-bottom-navigation-height` on the document's root like any other, so a page outside the scaled box that declares the reservation keeps room at its end too. A `fixed` bar inside a mockup is a demo's case, and the docs' demos are `static`; such a bar can be `static`.
- **A paused typewriter's box when its `text` changes (item 117).** React keeps the old line's box until the pause is let go, which its layout cannot avoid, and Flutter takes the new text's box at once. Making Flutter match would move its layout on release, so the two stay as they are.
- **`PlAnimateLighting` after reduced motion (item 136).** React's light waits its `delay` and starts from its first frame when the setting is turned off (read from the CSS, which takes the animation off under reduced motion, not measured); Flutter's goes on from where its time puts it since item 129. It changes where the light starts, not the content or the layout, so the two stay as they are.

## Noted differences

None. Every difference noted in batches 1 to 3 is an item above, or was closed and recorded.
