# Audit TODO

The open findings of an audit of what `plass-ui` can do to the loading speed, the responsiveness and the search ranking of a website that uses it (Core Web Vitals and SEO), taken at `62e1b599` on 2026-10-04. Every docs demo was rendered with `renderToString` in Node and hydrated with `hydrateRoot` in a browser, its controls were pressed at a 4x CPU slowdown, and the source was read for layout, listener and markup problems. When no item is left, delete this file in a commit of its own.

A closed item is deleted from this file, not ticked, and its number is not used again.

**31 items are open, and the last number used is 31.**

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

Line numbers are from `62e1b599` and drift as the code changes; when one no longer matches, search for the symbol.

### High

- **1.** **Hydration fails when the server and the browser default to different locales.** With no `locale` given, `numberFormatter` and `dateFormatter` in `packages/react/src/internal/format.ts` (~44, ~62) pass `undefined` to `Intl`, which is each runtime's own default. Rendered on an en-US server and hydrated in a de-DE browser, `PlAnimateCounter`, `PlLineChart` and the dashboard example report "Hydration failed … this tree will be regenerated on the client". Approved fix (2026-10-04): render the server pass and the hydration pass in a fixed locale (the provider's `locale`, else `en-US`) and switch to the browser's locale right after hydration through `useSyncExternalStore`, so a client-only app renders exactly what it does today; say in the docs that a server-rendered site should give `PlassProvider` a `locale`.
- **2.** **`PlImage` stays transparent until hydration.** The server HTML carries `opacity-0` on the `<img>` (`PlImage.tsx` ~698, ~788), with `priority` too, so LCP waits for hydration and the picture never shows without JavaScript; `PlGallery` tiles share it. Approved fix (2026-10-04): an image rendered on the server and hydrated is opaque from the start; only an image mounted on the client fades in as today.
- **3.** **`PlSkeleton` and the indeterminate `PlProgressLinear` animate a layout property forever.** `plass-skeleton-sweep` and `plass-progress-sweep` in `styles.css` (~1135, ~1050) move `inset-inline-start`, which lays the box out again on every frame and records a layout shift each time (CLS 0.02 to 0.037 in 1.5 s on the demos, 0.39 in 5 s for a 600×340 skeleton). Approved fix (2026-10-04): move it with `translate` and flip the sign under RTL the way the marquee does (`[dir='rtl']` and `:dir(rtl)`).
- **4.** **A `fixed` header in `PlPageLayout` pushes the content down after hydration.** The header's height is measured in a `useEffect` (`PlPageLayout.tsx` ~319) and written to `--p-layout-header-inset`, which the padding reads (~398), so the first paint has no room for the header (CLS 0.06 to 0.23). The measurement also alternates `getComputedStyle`/`offsetHeight` reads with `style.setProperty` writes on the root (~278-300), which recalculates the whole page's style once per slot. Fix: measure in a layout effect, all reads before all writes, and reserve the header's height in CSS for the server-rendered first paint.

### Medium

- **5.** **`hiddenUntilFound` on `PlAccordion` and `PlCollapsible` makes Base UI warn.** Plass passes `keepMounted={false}` explicitly (`PlAccordion.tsx` ~283, `PlCollapsible.tsx` ~280), and Base UI warns when `hiddenUntilFound` meets an explicit `false` (`AccordionRoot.mjs` ~44, `CollapsiblePanel.mjs` ~33). Pass `undefined` when the caller gave nothing, and test `hiddenUntilFound`. The tabs page should also say that an inactive panel is not in the server HTML unless the panel is `keepMounted`, as the accordion page does.
- **6.** **Below `md`, `PlSidebar`'s links leave the DOM after hydration.** A collapsed sidebar becomes an overlay `PlDrawer` (`PlSidebar.tsx` ~391), whose closed portal renders nothing, so mobile-first indexing sees no navigation links. Approved fix (2026-10-04): an opt-in `keepMounted` on `PlDrawer` and `PlSidebar`, off by default.
- **7.** **Animated text is doubled or garbled in the server HTML.** The screen-reader copy and the `aria-hidden` drawn copy are both text nodes: `PlAnimateCounter value={12345}` reads "12,3450" (`PlAnimateCounter.tsx` ~257), `PlAnimateScramble` and `PlAnimateSplit` repeat the sentence, `PlAnimateHeadline` runs its lines together. Approved fix (2026-10-04): draw the visible copy from `data-text` with `::before { content: attr(data-text) }`, as `PlAnimateTyping` already does.
- **8.** **`PlAnimateCounter` and `PlAnimateScramble` change width while they run.** The text around them moves (CLS 0.017 in a centred paragraph). Approved fix (2026-10-04): overlay the final string invisibly in the same cell, as `PlAnimateTyping` does, so the width is the final one from the start.
- **9.** **Infinite effects keep running off screen.** `PlAnimateLighting` repaints on the main thread every frame (a registered custom property under `filter: blur`), and the marquee, float, blink, the caret and the headline and typing timers never pause. Approved fix (2026-10-04): pause an infinite effect while it is off screen and resume where it stopped, through the pause `useAnimationRun` already has.
- **10.** **`PlConfirmProvider` and `PlSidebar` load the dialog stack up front.** `PlConfirmProvider.tsx` ~5 imports `PlModal` and `PlSidebar.tsx` ~7 imports `PlDrawer`; an app shell of provider, toast, confirm, page layout, sidebar and header weighs 37.6 kB gzip, 18.6 kB without the two. Approved fix (2026-10-04): `React.lazy` with an idle-time preload; the modal mounts on the first `ask()`, the drawer only while the sidebar is collapsed.
- **11.** **`PlDataTable` selection and search grow with the row count.** Every render calls `selected.includes` per row (~548, ~816) and every keystroke folds every cell again (~433); with `paging='scroll'` every row renders. Use a `Set`, cache the folded strings, memoise the row.
- **12.** **`PlSegmentedButton` and `PlFloatingBottomNavigation` force layouts.** Each reads, writes, then forces a layout with `void offsetWidth` (`PlSegmentedButton.tsx` ~392-401, `PlFloatingBottomNavigation.tsx` ~351-366), and both layout effects depend on `children` (~414, ~375), so they measure again on every parent render; several mounted together recalculate between each other's writes.
- **13.** **A horizontal `PlTabs` or `PlScrollZone` adds a non-passive wheel listener even when nothing overflows** (`internal/wheel.ts` ~132), so scrolling the page over it waits for the main thread. Attach it only while the strip overflows.
- **14.** **`preview` on `PlImage` and `PlGallery` downloads the overlay before it is opened.** The lazy `PlImagePreview` is rendered inside `Suspense` while closed (`PlImage.tsx` ~917, `PlGallery.tsx` ~651), so its chunk is fetched on every page that has a preview, and `renderToString` logs "Switched to client rendering" for the boundary. Mount it on the first open and prefetch on pointer-enter or focus.
- **15.** **Some layouts are worked out again after hydration.** `PlPanes` splits evenly until an effect sizes the panes (`PlPanes.tsx` ~251, ~534; CLS 0.066), a masonry `PlGallery` is two lanes on the server and four on a desktop after hydration (`PlGallery.tsx` ~332), and `PlMockup` at `width='100%'` is `visibility: hidden` until it is measured (`PlMockup.tsx` ~344), which delays the first paint of anything inside it.
- **16.** **The per-component stylesheets scan the whole of `internal/`.** `dist/css/base.css` has `@source '../internal'`, so one `PlButton` costs 14.1 kB where the modules it reaches would cost 11.0 kB. `build-styles.mjs` already computes the graph; list each component's own `internal` files instead. The README says this saves "about 5 kB" and the measured figure is about 8 kB.
- **17.** **Opening a popup is slow.** At a 4x CPU slowdown, opening a date range picker took 250 to 300 ms and a date or date-time picker, `PlMenu`, `PlDrawer` or `PlCommandPalette` 200 to 240 ms; the handler itself takes 1 to 10 ms and the rest is the popup's render and paint. Profile and fix what can be fixed without a visible change. The measurement used a software GPU, which inflates blur paint.
- **18.** **`PlCodeBlock` highlights every block in one task, and fetches the grammar after the core.** `highlight.ts` ~267 highlights all blocks in one microtask chain, and ~227/232 waits for the core before asking for the grammar. Yield between blocks and fetch both at once.
- **19.** **`PlTabs` and `PlSidebar` read layout more often than they need to.** `PlTabs.tsx` ~434 is a layout effect with no dependencies that reads `scrollWidth` after every commit, and ~412 calls `getComputedStyle(...).direction` on every scroll event; `PlSidebar.tsx` ~202 calls `getComputedStyle(document.documentElement).fontSize` during render.
- **20.** **`PlTreeSelect` and `PlTransfer` normalise every item's text on every keystroke** (`PlTreeSelect.tsx` ~131, `PlTransfer.tsx` ~322). Cache the folded strings.
- **21.** **Docs: a reader who picked Flutter gets a Vue hydration mismatch on every page with a `<Demo>`.** `Demo.vue` renders the Flutter frame on its first client render while the server rendered the React half; `FrameworkSelect.vue` already avoids the same problem with a `hydrated` flag.

### Low

- **22.** **`PlEmpty` draws its title inside a `<p>`** (`PlEmpty.tsx` ~120), so a heading passed as the title is invalid HTML (`<p><h2>`).
- **23.** **`PlAvatar` has no `<img>` in the server HTML.** Base UI mounts the image only once it has loaded, so the request starts after hydration. Check whether Base UI's own options can render it from the start without changing what is shown.
- **24.** **`PlHotKeys` swaps `Ctrl` for `⌘` right after hydration on Apple platforms**, which moves the text after it (CLS 0.015 on the demo). The server cannot know the platform; reserve the width or accept it. `Decision needed`.
- **25.** **A chart draws nothing but its frame until hydration.** The plot, the ticks and a `PlGaugeChart`'s value are drawn once the width is measured, so a chart that is the largest element on screen delays LCP until JavaScript runs. An opt-in initial width would let the server draw it. `API addition`.
- **26.** **`PlAppLogo` defaults `alt` to `''`**, so a logo rendered as a home link with only `src` is a link with no name. `Decision needed` (a required `alt` is a type change).
- **27.** **Some link items cannot take a router link.** `PlBreadcrumbItem`, `PlListItem`, `PlMenuItem`, the bottom navigation items and `PlNavigationMenuLink` have no `render`; a caller who swaps `href` for `onClick` loses the link. `API addition`.
- **28.** **`PlDrawer`'s inline title is always an `<h2>`** (`PlDrawer.tsx` ~372). `API addition` (`titleLevel`).
- **29.** **`PlSelect` renders one hidden sizing element per option** (`sizer.tsx` ~41), about 2,500 elements for ten country selects. Picking only the widest candidates changes the measured width. `Decision needed`.
- **30.** **Closed content of `PlStepper` and `PlTree` and the folded steps of `PlBreadcrumb` are not in the server HTML.** `Decision needed` (the same kind of choice as `keepMounted`).
- **31.** **The glass blur costs GPU time on low-end phones**, nested in forms inside cards and once per chip. The blur is the material, so any mitigation (honouring `prefers-reduced-transparency`, recommending `content-visibility` for long lists) is a design decision. `Decision needed`.
