# Audit TODO

The open findings of an audit of what `plass-ui` can do to the loading speed, the responsiveness and the search ranking of a website that uses it (Core Web Vitals and SEO), taken at `62e1b599` on 2026-10-04. Every docs demo was rendered with `renderToString` in Node and hydrated with `hydrateRoot` in a browser, its controls were pressed at a 4x CPU slowdown, and the source was read for layout, listener and markup problems. When no item is left, delete this file in a commit of its own.

A closed item is deleted from this file, not ticked, and its number is not used again.

**14 items are open, and the last number used is 41.** Batch 1 (2026-10-04) closed items 1 to 23, 32, 33, 34 and 38, and was paused before it was verified as a whole and pushed; see [Paused batch](#paused-batch).

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

## Paused batch

Batch 1 was paused on 2026-10-04 at the Prompter's request. Local `main` holds its picked commits on top of `10f3994ad` and has **not been pushed**. To finish it:

1. Pick the three commits for items 35, 36 and 37 from the branch `worktree-agent-a3b440281d678e550` (`8e4d6d63c`, `73bfbecc9`, `2486373e1`, made from `6a3f50799`). The worker was stopped before it reported, so check each one first (its test fails on the parent and passes with it, lint, typecheck) and write its changelog entry under `Fixed`.
1. Item 40 was half written in `.claude/worktrees/agent-a3b28dd03947561b8` and never committed: a new `src/internal/lazy.tsx` with its test, and changes to `PlConfirmProvider`, `PlSidebar`, `PlImage`, `PlGallery`, `vitest.config.ts` and `test/env.d.ts`. Finish it there or start again from `main`. Items 39 and 41 have not been started.
1. Verify the whole batch with every command under [Verifying a batch](#verifying-a-batch). React passed on `main` at `6a3f50799` (all three shards, after one rerun of the known `PlScatterChart` "renders again only when the nearest mark changes" flake); the commits picked after it each passed their own worker's full run. The size budget has moved past 2% ("Everything" about +1.5 kB, `One PlButton` +0.3 kB under esbuild, mostly from the new lazy chunks): run `npm run size -- --update` and commit the budget on its own.
1. Push (approved on 2026-10-04), check CI, remove the worker worktrees and branches once every commit is on `main`, and report.

## Waiting for an answer

Approved on 2026-10-04 and not yet done:

- **35.** Round every frame `PlAnimateCounter` draws to the answer's own number of fraction digits, as Flutter does, so the reserved width holds from the first frame.
- **36.** Make `PlAnimateTyping` hold its line once in the page's text at every moment (it holds the clipped copy and the typed text after typing).
- **37.** Keep the pass a paused `PlAnimateTyping` is on when it resumes (it resets `pass` to 1, so a finite `repeat` plays extra passes).
- **39.** Confirm, then fix: with a full-span `sticky` `PlHeader` the first paint has no `--p-layout-header`, so the sidebar is `100dvh` tall until hydration shortens it (`PlSidebar.tsx` ~437); reserve the header's height in CSS as item 4 did for a fixed header.
- **40.** A lazy dialog whose chunk fails to load (`PlConfirmProvider`'s `PlModal`, `PlSidebar`'s `PlDrawer`, `PlImagePreview`, `PlGalleryViewer`) throws to the nearest error boundary. Retry the import once, then step back quietly: `ask()` settles as cancelled, a drawer or a preview does not open, and a later attempt may try again; one shared helper, one sentence on each page.
- **41.** `PlCommandPalette` does not close on `Esc` (`docs/en/components/navigation/command-palette.md` ~135 says it does; `<Autocomplete.Root open>` in `PlCommandPalette.tsx` ~347 looks like the cause). Fix it, keep what `Esc` does in the field, and check the Flutter build.

## Items

Line numbers are from `62e1b599` and drift as the code changes; when one no longer matches, search for the symbol. Items 35 to 41 are under [Waiting for an answer](#waiting-for-an-answer).

### Low

- **24.** **`PlHotKeys` swaps `Ctrl` for `⌘` right after hydration on Apple platforms**, which moves the text after it (CLS 0.015 on the demo). The server cannot know the platform; reserve the width or accept it. `Decision needed`.
- **25.** **A chart draws nothing but its frame until hydration.** The plot, the ticks and a `PlGaugeChart`'s value are drawn once the width is measured, so a chart that is the largest element on screen delays LCP until JavaScript runs. An opt-in initial width would let the server draw it. `API addition`.
- **26.** **`PlAppLogo` defaults `alt` to `''`**, so a logo rendered as a home link with only `src` is a link with no name. `Decision needed` (a required `alt` is a type change).
- **27.** **Some link items cannot take a router link.** `PlBreadcrumbItem`, `PlListItem`, `PlMenuItem`, the bottom navigation items and `PlNavigationMenuLink` have no `render`; a caller who swaps `href` for `onClick` loses the link. `API addition`.
- **28.** **`PlDrawer`'s inline title is always an `<h2>`** (`PlDrawer.tsx` ~372). `API addition` (`titleLevel`).
- **29.** **`PlSelect` renders one hidden sizing element per option** (`sizer.tsx` ~41), about 2,500 elements for ten country selects. Picking only the widest candidates changes the measured width. `Decision needed`.
- **30.** **Closed content of `PlStepper` and `PlTree` and the folded steps of `PlBreadcrumb` are not in the server HTML.** `Decision needed` (the same kind of choice as `keepMounted`).
- **31.** **The glass blur costs GPU time on low-end phones**, nested in forms inside cards and once per chip. The blur is the material, so any mitigation (honouring `prefers-reduced-transparency`, recommending `content-visibility` for long lists) is a design decision. `Decision needed`.

## Decided and recorded

- **Time zones (item 32).** Only the clock is pinned to UTC for a server render and its hydration. A date a caller passes stays in each runtime's own zone, because the library treats a `Date` as a wall-clock day and pinning it would move dates east of UTC by a day; the locales guide tells a server-rendered page to build its dates from year, month and day. A date built from an instant (an ISO timestamp) can still differ between server and browser; a `timeZone` prop would be the way to close that, and is not planned.
- **Popup openings (item 17).** Profiled at 4x: most of a first opening is Base UI and React work, first-run compilation, the blur's raster and Base UI's positioner restyling the popup twice; Plass's own share was at most 15 ms. Only the pickers' needless second render was fixed.

## Noted differences

Small differences found in passing in batch 1. They are not items and are not worked.

- `PlSlider` ignores `PlassProvider`'s `locale` while `PlNumberField` and `PlMeter` read it (`PlSlider.tsx` ~233).
- `docs/{en,ko}/guide/defaults.md` ~102 leaves `PlSparkline` out of the components the provider's `locale` reaches.
- `PlCombobox.tsx` ~455 lower-cases with the runtime locale (it only decides whether the custom row appears).
- `getting-started.md`'s Next.js section does not point to the locale advice for server-rendered pages.
- A browser whose zone changes while a page is open can show the calendar's month and weekday names a day off: `format.ts` caches formatters, and `WEEKDAY_ORIGIN` (`date.ts` ~487) is built at load.
- `internal/wheel.ts` ~136 calls `getComputedStyle(element).direction` on every wheel event that moves a strip.
- `PlDataTable` skips unchanged rows only while `columns` keeps its identity; an inline `columns` array redraws every row.
- A `dir` changed at run time on a wrapper, with no `PlassProvider direction`, leaves a `PlTabs` fade and indicator where they were until something else changes (`rtl.md` already says to use the provider).
- The direction reset for the marquee and the progress segment is exact two levels deep; a right-to-left region inside a left-to-right one inside a right-to-left page runs the English way.
- `PlPanes` (~330, ~362) and `PlMockup` (`usePlElementSize`) measure the border or content box where CSS resolves against another box, so a padded split or mockup moves a few pixels at hydration.
- An inline `style` change that moves segments without resizing the set is no longer re-measured on that commit (`PlSegmentedButton`, `PlFloatingBottomNavigation`).
- `drawerSide()` (`internal/page-layout.ts` ~204) reads the document's computed style on every render of a collapsed sidebar; a `PlHeader` that changes only its `position` is not measured again.
- `localeWeekStart` (`internal/date.ts` ~568) builds an `Intl.DateTimeFormat` and an `Intl.Locale` on every picker render when no locale is given.
- `animate-counter.md` ~77 says a new `value` counts from where the last one landed; the code counts from `from` (`PlAnimateCounter.tsx` ~179).
- Docs: a Flutter reader still sees a 4px jump at hydration in a `<Demo>` (`docs.css` ~158 against `Demo.vue` `frameStyle`).
- `CLAUDE.md` says `src/internal/` has 47 modules; there are 59.
- Whether a browser fetches a module again after an `import()` of the same URL failed is up to its module cache; item 38 only guarantees the library asks again.
