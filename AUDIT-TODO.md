# Audit TODO

The findings of a full audit of both packages, the documentation site and the repository, taken at `148a20e4` on 2026-09-13, and how far fixing them has got. The work goes in batches of twenty. When every item below is ticked, delete this file in a commit of its own.

Numbers 39 and 180 are missing on purpose. They were two security findings whose details were kept out of this public file, in a local note that is no longer on the machine, and the Prompter dropped them rather than reconstructing them. Nothing else is renumbered.

**388 of 409 items are ticked.** Line numbers in the items are from `148a20e4` and drift as the code changes; when one no longer matches, search for the symbol.

## Working through a batch

When the Prompter asks to continue the audit, run a batch as written here, without asking how.

1. **Answers first.** Do what the Prompter approved under [Waiting for an answer](#waiting-for-an-answer) before the batch; that work does not count towards its twenty. Tick an item the Prompter declined and append `— declined`. Remove every answered question from that section.
1. **Pick twenty items.** Take open items by severity, High before Medium before Low, and by number within one severity. Skip an item flagged `Decision needed` or `Breaking change`, and an item that turns out to need a decision once the work starts, and take the next one instead.
1. **Confirm before fixing.** Check the finding against the code first, because the audit can be wrong or already out of date. An item that no longer reproduces is ticked with `— no longer reproduces` and gets no commit.
1. **One item, one commit.** For each item:
   - Fix every package the item names, following `CLAUDE.md` and the code around the change.
   - Add a test that fails without the fix, and prove it: commit first, then check the sources out of the parent commit with `git checkout HEAD~1 -- <paths>`, run the test, and check them back with `git checkout HEAD -- <paths>`. Never `git stash`; every worktree of a repository shares one stash, and a batch worked in several worktrees at once loses another agent's entry that way. When a test cannot show the difference, say so in the report.
   - Add a user-facing entry under `## vNext` in `packages/react/CHANGELOG.md`, `packages/flutter/CHANGELOG.md` or both, at the top of `Fixed`, `Changed` or `Breaking changes`. A change no user can notice gets no entry. The site copies both changelogs, so write `{{` in either inside `<code v-pre>`.
   - Update the documentation pages, `docs/en` and `docs/ko` together, and the props tables when documented behaviour changes.
   - Commit with the tags in `CONTRIBUTING.md`: `[javascript]` or `[dart]` for one package and no prefix for both. No `Co-Authored-By` trailer.
1. **Stay inside the item.** A problem found in passing is not fixed; note it for the report. The exception is a problem the item's own change caused, such as a test exemption the change made unnecessary.
1. **Verify the batch** with the commands below, all of them.
1. **Ask, then update this file and push.** Ask every question the batch raised through the prompt, as the standing decision below says, and record the answers: a bug the Prompter wants fixed becomes a new item under [Added after the audit](#11-added-after-the-audit), an approved change goes under [Waiting for an answer](#waiting-for-an-answer), and a question answered "keep" is dropped. Tick the batch's items (`- [x]`), update the count at the top, commit this file on its own and push.
1. **Report in Korean and stop.** Give a table of the items with their number, package and what changed, the verification results, and the notes the Prompter needs.

Standing decisions that apply to every batch:

- React 18 stays in the peer range, but only React 19 is tested. Do not add a React 18 job or test run.
- Questions go to the Prompter through the prompt (AskUserQuestion), all of them at once: several calls of four questions in one message. Each question says what the problem is and how it would be fixed, each option carries its pros and cons, and one option is marked recommended. Check the facts in the code before writing a recommendation.
- An entry under [Waiting for an answer](#waiting-for-an-answer) has been answered and is approved: do it at the start of the next batch without asking again.

### Verifying a batch

```bash
cd packages/react && npm run lint && npm run typecheck && npx prettier --check src test CHANGELOG.md scripts && npm test && npm run build && npm run size
cd packages/flutter && dart format --line-length 100 lib test example/lib && flutter analyze && flutter test
cd packages/flutter/example && flutter analyze lib
cd docs && npm run typecheck && npm run lint && npx prettier --check . && npm run build
```

- `npm run size` allows 2% of drift per scenario. When a batch moves a number past that on purpose, run `npm run size -- --update` and commit the budget on its own.
- `npm run build` in `docs` takes a few minutes and compiles the Flutter demos first. Run it last.
- CI formats the Flutter package with Flutter 3.41.0 and with the newest stable, and the newest formatter lays some code out differently from older ones. Check with it too: `dart pub global activate dart_style`, then `dart pub global run dart_style:format --page-width=100 --language-version=3.11 --output=none --set-exit-if-changed .` in `packages/flutter`. A named argument after a closure, as in `testWidgets('…', (tester) async {…}, variant: …)`, is laid out in opposite ways by the two, so avoid it.

## Batches so far

| Batch | Commits              | Items                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| ----- | -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1     | `148a20e4..16d59107` | The High items: 1, 2, 4, 6, 18, 40, 43, 44, 68, 87, 121, 126, 144, 145, 154, 156, 188, 196, 202, 237                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| 2     | `16d59107..c37ec085` | 3, 5, 7, 8, 9, 10 (part), 11, 13, 14, 15, 16, 17 (part), 22, 24, 142, 143, 152, 197, 268                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| 3     | `c37ec085..4885268c` | The rest of 10 and 17, 25, 26, 27, 28, 37, 38, 41, 42, 45, 46, 47, 48, 50, 51, 53, 54, 60, 64, 66, 69                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| 4     | `4885268c..c99f09c1` | 72, 75, 76, 85, 86, 88, 90, 91, 92, 94, 95, 98, 101, 103, 113, 114, 116, 122, 123, 127                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| 5     | `29684cc1..8e75337c` | 82, 129, 132, 135, 146, 147, 149, 155, 157, 158, 159, 163, 166, 167, 174, 175, 176, 177, 182, 183                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| 6     | `012573fb..b869de54` | 185, 186, 187 (part), 189, 190, 191, 193, 198, 200, 203, 205, 206, 207, 209, 211, 214, 215, 220, 221, 222                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| 7     | `daf5a084..58280a60` | Answers first: 12, 89, 93, 109, 128, 178, 181, 192, 213. Then 225, 226, 230, 236, 239, 240, 241, 244, 252, 254, 255, 259, 262, 263, 264, 266, 269, 273, 274, 275                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| 8     | `f6ca7d29..c6e581df` | Answers first: `<Fw>` backticks, Flutter `PlAlert`, Flutter `PlWindowPane` buttons, `PlGallery` and `PlChip` labels, React `PlTransfer` headings, `PlRating` decimals, small cleanups. Then 276, 277, 278, 279, 280, 281, 287, 288, 290, 291, 292, 293, 294, 295, 304, 305, 306 (part), 307, 317, 321                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| 9     | `3b2d1bfa..57604faa` | Answers first: item 298, the hover focus, the Counter and Scramble delay, grapheme cutting, `PlAnimateSplit` wrapping, `PlWindowPane` focus, the shared `textOf`, the Flutter cleanups and dartdoc, and six documentation answers. Then 23, 29, 30, 31, 33, 34, 35, 36, 49, 55, 56, 57, 258, 306, 311, 324, 331, 335, 338, 339, with 302 closed by the grapheme answer                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| 10    | `02344e1b..4b6cd081` | No answers first: the Prompter passed over every question. Then 61, 62, 65, 67, 70, 71, 73, 74, 77, 78, 79, 80, 81, 83, 96, 97, 99, 102, 104, 105, and a fix to batch 9's label test on Windows                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| 11    | `9a22ef17..f3c086e3` | Answers first: a `.gitattributes`, the failing React tests as items 355 to 369, all of them worked, the chart arithmetic and the dismiss × as items 346 to 354, 312 to 315 with the label count, the 47 Flutter props rows, `PlTransfer` ticks, the label pack test, the summaries, Korean `animate-rotate.md`, two comments, the `PlGallery` rows, the line chart keys, the code block name, the timeline table and the sparkline foot. Then 106, 108, 110, 111, 112, 115, 117, 119, 120, 124, 125, 131, 133, 136, 137, 138, 139, 140, 141, 148                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| 12    | `d7392f82..74316388` | Answers first: `'instant'` scrolling under reduced motion, the `PlCarousel` handlers as item 370 and three carousel tests, the pausing tests on the frame clock, two drag tests and the forced-colours pointer, 247 Flutter props rows typed with `?` and four rows removed, the bar and area chart keys, the defaults guide, the text slips, the Flutter table page, `PlImage` preview names, the `PlChip` focus ring, and item 371 added. Then 150, 151, 153, 160, 161, 162, 164, 165, 169, 171, 172, 173, 179, 184, 194, 199, 204, 208, 210, 212                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| 13    | `28c12bf6..247a13cb` | Answers first: the counter `easing` test, the `PlWindowPane` drag test and `'instant'` hold and wheel steps, `PlImage` preview tests and names, item 371 with a `key` for `PlTimelineItem`, disabled `PlCalendar` semantics, a Friday in the picker samples, `readOnly` `PlSwitch` and `PlRadioGroup`, the colour picker thumb, and five docs answers. Then 218, 219, 224, 227, 231, 232, 234, 235, 242, 243, 245, 246, 249, 250, 251, 257, 260, 261, 265, 267, with item 372 added                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| 14    | `c1bff556..609ae6f9` | Answers first: the fourteen recommended answers, among them items 217 and 372 together. Then 271, 272, 283, 284, 285, 286, 289, 296, 299, 300, 301, 303, 309, 310, 318, 319, 320, 322, 323, 325                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| 15    | `b65c5bf7..ca8154bb` | Answers first: the four recommended answers. Then 326, 327, 328, 329, 330, 332, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 352, 353                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| 16    | `1bb27381..60c9e871` | Every question asked through the prompt first. Answers first: the Flutter radius and motion tokens, a `BackdropGroup` per glass sheet and overlay, keyboard-walkable Flutter charts, the dashed legend key, one dash loop, Flutter number grouping, sparkline clipping, `Infinity` progress, per-thumb slider values, the gallery reading order, manual-paging row keys, stable card and pill trees, the README counts, a marquee `label`, the code block alias table and `auto` theme, the combobox clear target, focus after clearing a picker, the transfer select-all sentence and announcement, the calendar year step and disabled wrappers, the FAB parameters, the expanded pill, repeated accordion values, the tab reveal offset, the `PlShow` Flutter demo, the `plass-lang` rename, the reset media rules, the field description helper and the Korean emphases. Then 354, 58, 107, 118, 130, 134, 168, 170, 187, 195, 201, 216, 223, 228, 229, 233, 238, 247, 248, 256, with 308 closed as no longer reproducing |
| 17    | `ec4bc112..c3ece1b3` | Answers first: 253, 270, 282, 297, 333, 334, 336 and 337, glass on opaque surfaces, the confirm ×, opening a Flutter `PlCombobox` on a press, a `PlTable` `label`, `loadingLabel`, the `PlNavigationMenu` size transition checked and added as item 391, `Escape` on a React chart, the Flutter token section, `fieldGlowStrength` and eased Flutter overlay fades. Then 373 to 390, every item left                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |

The answers to batch 4's questions went in as `363c243b..2a8fb470`: the decode half of item 100, the `PlAnimateTyping` caret, and a `headingLevel` for `PlCard` with the card page corrected.

Batch 7 took the recommended answers to the batch 5 and 6 questions first, together with the findings they led to: the calendar header names in Flutter, the width samples of every `fullWidth` picker, the `PlSlider` run, `PlChip` and the shared `plassTextOf`, `PlBackTop` and `PlAnchor` sharing their focus and target helpers, and the Korean pagination page. Several items were worked in parallel in git worktrees and brought onto `main` one commit at a time, with their changelog entries added there.

Batch 8 took the recommended answers to the batch 7 questions first. Its items were worked in eight worktrees at once and brought onto `main` one commit at a time, with their changelog entries added there. Item 298 needed a decision once the work started, so item 321 took its place.

Batch 9 took the recommended answers to the batch 7 and 8 questions first, item 298 among them, and item 302 closed with the grapheme answer. Its work ran in eight worktrees at once and was brought onto `main` one commit at a time, with the changelog entries added there. Items 306 and 311 are edits to `CLAUDE.md`, which is gitignored, so they have no commit. A worktree does not hold `CLAUDE.md`; a worker in one reads it from the main checkout.

Batch 10 took no answers first, because the Prompter asked to pass over every question for this batch, so the recommended answers to the batch 7 to 9 questions still wait for the next batch. Its twenty items are all Low and ran in eight worktrees at once, brought onto `main` one commit at a time with the changelog entries added there. Item 58 was passed over as a breaking change and is asked below. Checking CI after the batch showed the Flutter jobs on Windows failing since batch 9: the label test from item 35 searched `date.dart` for `'\n}\n'`, which a Windows checkout ends in CRLF. That was batch 9's own change, so `4b6cd081` fixes it; the React test jobs have failed for longer, and that is asked below.

Batch 11 took every recommended answer to the batch 7 to 10 questions first. The CI answer turned the failing React tests into items 355 to 366, worked before the batch: most were tests that a pointer left over the page by an earlier file, a machine locale, a fixed wait or a Firefox pointer id could fail, and one was a `PlImage` bug that Firefox users get. Items 312 to 314 and the label count are edits to the gitignored `CLAUDE.md`. A worker's worktree starts from the pushed `origin/main`, not from local commits, so push before launching workers who must read something just committed. The size budget for `PlImage` and `PlGallery` moved past its 2% with items 96, 104, 105 and 362 and was updated in a commit of its own. The first push left two React jobs red on tests a stopped shard had hidden before, so items 367 and 368 were added and worked after it: a `PlToggle` that lost its forced-colours fill under the pointer, and a `PlAnimateScramble` test that measured wall time. The second push left the two WebKit jobs red on a marquee test, item 369, which read a media query WebKit had not updated yet; every test now emulates media through `test/support/media.ts`.

Batch 12 took the sixteen recommended answers to the batch 11 questions first, one of them the `PlCarousel` bug that became item 370, and one a check that reproduced and became item 371, asked below because it adds a parameter. Its twenty items are all Low. CI was green at its start, and every React test the batch touched was run in all three browsers.

Batch 13 took the eighteen recommended answers to the batch 12 questions first. Item 217 needed a decision once the work started, because a floating React `PlBackTop` turned out not to float at all; that became item 372 and a question, and item 267 took 217's place. Item 245 reproduced only in Flutter.

Batch 14 took the fourteen recommended answers to the batch 13 questions first, and two of them were items: 372 and 217 went in together, which is what that answer asked for. One answer needed no change — a Flutter `PlButton` that is `loading` or `readOnly` stays announced as unavailable — and one turned out to need none: React does not bring a chosen tab into view when `value` changes from outside either, so the Flutter bar already matches it. Its twenty items are all Low. Item 286 no longer reproduces: every regression test it asks for was written by the batch that fixed the bug. Item 301's finding was half right — a new `Intl.NumberFormat` is built on every render around the counter rather than on every frame — and the fix is the one the item proposed. The work was done in one checkout rather than in worktrees.

Batch 15 took the four recommended answers to the batch 14 questions first. Its twenty items are all Low, and fourteen of them are the documentation site and the chart arithmetic. Item 347 no longer reproduces: both builds keep the time of day a `min` names, and `_alignTime` and `alignTime` are the same function. Two of the chart items had not been traced when they were raised, and both came down to a difference between the languages rather than to the drawing: Dart's `List.sort` is a quicksort past thirty-two items where a JavaScript `sort` is stable, and Dart's `~/` truncates towards zero where `Math.floor` floors. Items 348 and 352 overlap, since the zero-span guard of the first is what a pre-1970 axis fell into once every tick landed past its data. Item 349's compact number is written out in Dart rather than taken from `Intl`, which the package does not ship, so a number is still not grouped; that is asked below.

Batch 16 asked every question through the prompt, sixty-four at the start and twenty-two at the end, each with the fix, what every option costs and a recommendation, and every one was answered with its recommendation. Items 39 and 180 stay dropped. Item 308 no longer reproduces and half of item 336 does not either: both were fixed on another machine, which checking the code before writing the recommendations showed. The work ran in nine worktrees at once, and the Flutter tokens in a tenth once the rest were on `main`, brought over one commit at a time with the changelog entries added there. Three worker changes were adjusted on `main`: `PlTransfer`'s `selectAllLabel` stays a string, because turning it into a function was a breaking change nobody had asked for; `PlBackTop`'s new desktop assert waits for the first frame, because it went off for a scroll view built with `primary: true`; and the English "Loading" moved to a module of its own, because the size check splits code and the whole label set had come into every bundle with a button. The label counts had drifted by three keys since the chart options commit and now say 107 and 106. The eighteen bugs the second round chose to fix are items 373 to 390. After the push, CI failed in two places the local run could not see, and three commits fixed them: a new tabs test pressed Tab, which Firefox does not deliver to the page from the runner's frame, and a new `PlBackTop` test passed `variant:` after its closure, which the newest Flutter formatter lays out differently from the one on this machine. Every CI job was green at `60c9e871`.

Batch 17 had no questions to ask at its start: every entry under Waiting for an answer had been answered in batch 16. It worked those eighteen answers first, eight of them items, and then the eighteen items left, 373 to 390, in eight worktrees at once, brought onto `main` one commit at a time with the changelog entries added there. The `PlNavigationMenu` size transition reproduced when it was checked, so it became item 391. Item 383 left the sparkline alone, because the React sparkline turned out not to go through the shared writer either; that is answered below. `moveWindow` joined the label set, which now counts 108 entries in React and 107 in Dart, and `llms.txt` became a short list beside `llms-full.txt`, which now holds the long descriptions and the counts. Eleven questions were asked at the end, and the twenty bugs they chose to fix are items 392 to 411. After the push, CI failed on the fix for item 391 three times. The first two looked like a test sampling frames too coarsely and were rewritten; the third showed the fix itself: on CI's runners a controlled menu stopped short of the next panel's size and an uncontrolled one did not ease. The fix and its tests were reverted, and item 391 stays open with what was learned.

## Waiting for an answer

Asked through the prompt at the end of batch 17. Every entry here was answered with its recommended option and is approved: do it first in the next batch, without asking again.

1. **The sparkline's numbers.** Write them through the shared writers in both packages, `writeChartValue` in React and `compactNumber` in Flutter, as every other chart now does.
1. **The resting brightness filter.** Replace the identity `ColorFiltered` item 379 left in the tree with a small render object that paints its child directly at a brightness of 1 and pushes the filter layer only otherwise, so the tree keeps its shape and a control at rest carries no extra layer.
1. **Reversing a Flutter curve.** Give the folds and the fades `reverseCurve: curve.flipped`, so a close eases the way a CSS transition does.
1. **The focus after a `PlMenu` a pointer opened.** Hand it back to the trigger as Base UI does, and draw the ring only while Flutter's focus highlight mode is the keyboard's; make `PlMenubar` do the same.
1. **Naming a caption-less `PlTable`.** Put `label` on the `<table>` as its `aria-label` too, as Flutter's `semanticLabel` names the table.
1. **A press on a Flutter carousel's dots and arrows.** Stop the autoplay, as a click does in React, where it brings the focus into the carousel.

## Passed over and not yet asked

None. Every flagged item passed over so far is asked above.

## Items

### 1. Across components

- [x] **1.** `inert` never reaches the DOM on React 18 (Accessibility · React · High)
- [x] **2.** In Flutter tabs, radios and segmented buttons, one arrow key press throws focus out of the group (Accessibility · Flutter · High)
- [x] **3.** Flutter horizontal arrow keys are not reversed in RTL (Accessibility · Flutter · Medium)
- [x] **4.** Pressable rows in Flutter have no tap action in their semantics (Accessibility · Flutter · High)
- [x] **5.** Flutter floating layers do not close on Escape (Accessibility · Flutter · Medium)
- [x] **6.** Flutter modal layers do not hide the screen behind them from screen readers (Accessibility · Flutter · High)
- [x] **7.** Flutter layers do not account for the safe area or the soft keyboard (Bug · Flutter · Medium)
- [x] **8.** In Flutter lists, the row highlighted with the arrow keys moves out of view (Accessibility · Flutter · Medium)
- [x] **9.** Flutter builds long lists all at once and rebuilds every item on each hover (Performance · Flutter · Medium)
- [x] **10.** Default strings ignore label pack keys that already exist for them (Bug · Both · Medium)
- [x] **11.** Fixed strings have no key in the label pack (Bug · Both · Medium)
- [x] **12.** Accessibility strings that contain a value cannot be translated (Accessibility · Both · Medium)
- [x] **13.** A partial `labels` on a nested `PlassProvider` replaces the whole outer pack (Bug · React · Medium)
- [x] **14.** Shortcut matching fails for macOS `Alt+letter` and for Shift symbols (Bug · React · Medium)
- [x] **15.** Key presses during IME composition are not filtered out (Accessibility · React · Medium)
- [x] **16.** Focus ring contrast is about 2.2:1, below WCAG 1.4.11 (3:1) (Accessibility · Both · High)
- [x] **17.** In forced-colours mode (Windows High Contrast), the edges of `solid` controls disappear (Accessibility · React · Medium)
- [x] **18.** The per-component Tailwind scan manifests leave out components used internally (Bug · React · High)
- [x] **19.** The reset in `plass-ui/styles.css` wipes the host page's default styles (Bug · React · Medium)
  - Location: `packages/react/src/reset.css:33`, `:77`, `:83`
  - Problem: Author styles beat UA defaults even at specificity 0. In an existing app without Tailwind, the bullets on body text lists, heading sizes, `<hr>` and native input borders disappear. This goes against the principle in the file header, "do not touch other people's pages".
  - Proposal: Move the list and heading resets into the utilities of the components that need them, and reduce the element selector rules.
  - Flag: Decision needed, Breaking change — the scope of the move has to be decided, and host pages will render differently.
- [x] **20.** Changing a base token on a non-root element does not update the derived tokens (Bug · React · Medium)
  - Location: `packages/react/src/styles.css:569`
  - Problem: Derived values such as `-fill`, `-tint`, `-ring` and `--plass-shadow-*` are computed only on `:root, .dark, .light, [data-theme]`. A button inside `<div style={{ '--plass-primary-solid': … }}>` keeps its gradient and ring unchanged, but `design/color.md` says tokens "can be set on any element".
  - Proposal: Add a hook class such as `.plass-theme` to the selector of the derived block and document it, or state in the docs and the type comments that this works on the root only.
  - Flag: Decision needed
- [x] **21.** A Flutter app has no way to change the palette, radius or blur tokens (Bug · Flutter · Medium)
  - Location: `packages/flutter/lib/src/theme/tokens.dart:192`, `theme/theme.dart:40`
  - Problem: `PlassTokens` has only a private constructor and `light()`/`dark()`, so the only values that can be passed to `PlassTheme.tokens` are the two default sets. The "Overriding a family" section of `color.md` is outside any `fw` block, so Flutter readers see it too.
  - Proposal: Make `copyWith` and a way to replace a family public, or state the Flutter limitation in the docs.
  - Flag: Decision needed — it has to be decided which tokens to open up as public API.
- [x] **22.** In the Flutter dark theme, the chart grid, axis and baseline colours differ from the CSS (Bug · Flutter · Medium)
- [x] **23.** `PlCodeBlock theme="auto"` is painted dark on a page that forces light with `.light` (Bug · React · Low)
- [x] **24.** The interaction light on a clickable `PlPill` spreads to the size of the nearest positioned ancestor (Bug · React · Medium)
- [x] **25.** `PlColorSchemeScript` does not escape `</script>` in its inline script (Security · React · Medium)
- [x] **26.** `usePlColorScheme` throws during render where storage access is blocked (Bug · React · Medium)
- [x] **27.** `usePlElementSize` and `usePlOnScreen` never observe an element that is attached later (Bug · React · Medium)
- [x] **28.** Resize and drag handles have no `touch-action: none` (Accessibility · React · Medium)
- [x] **29.** `PlSidebar` reimplements the drag handling in `internal/drag.ts` (Optimisation · React · Low)
- [x] **30.** The popup arrow is duplicated in three components, and the copies already draw it differently (Optimisation · React · Low)
- [x] **31.** The statement "one listener per query" is wrong (Docs · Both · Low)
- [x] **32.** Each Flutter glass surface's `BackdropFilter` reads the backdrop separately (Performance · Flutter · Medium)
  - Location: `packages/flutter/lib/src/internal/surface.dart:175`
  - Problem: With dozens of glass surfaces, as in a list of cards, the σ22 blur reads the backdrop once per surface. `BackdropFilter.grouped` is available in the minimum version, 3.41, but it is not used.
  - Proposal: Group surfaces that do not overlap, and give overlapping glass, such as a field inside a card, a new group.
  - Flag: Decision needed — it has to be decided whether the library or the app sets the group boundaries.
- [x] **33.** `PlassLabels` and `PlDateNames` have no `==`, so the theme causes needless full rebuilds (Performance · Flutter · Low)
- [x] **34.** Every paint of an inset shadow runs `Path.combine` (Optimisation · Flutter · Low)
- [x] **35.** The Flutter label pack test does not catch a single missing translation (Test · Flutter · Low)
- [x] **36.** `size.mjs` does not check as much as its comments say (Test · React · Low)
- [x] **37.** The React format check in CI always passes (Bug · CI · Medium)
- [x] **38.** The documentation site is not verified on PRs (Test · CI · Medium)

### 2. Charts

- [x] **40.** Mark charts redraw everything every time the pointer moves (Performance · React · High)
- [x] **41.** With large data, O(N) work repeats every time the active column changes (Performance · React · Medium)
- [x] **42.** Flutter charts rebuild and repaint everything with `setState` on every 1px of movement (Performance · Flutter · Medium)
- [x] **43.** At narrow widths, Flutter category labels are always cut to `J…` and `…` (Bug · Flutter · High)
- [x] **44.** In Flutter, a series that starts with `hidden: true` cannot be turned back on from the legend (Bug · Flutter · High)
- [x] **45.** Flutter date categories appear as ISO strings on the axis and in the tooltip (Bug · Flutter · Medium)
- [x] **46.** Flutter tooltips are clipped at the chart edges (Bug · Flutter · Medium)
- [x] **47.** A Flutter legend with `side: left/right` lays out in one horizontal row and overflows (Bug · Flutter · Medium)
- [x] **48.** A Flutter cartesian chart throws when `empty` is given `Text.rich`, and ignores any other widget (Bug · Flutter · Medium)
- [x] **49.** Flutter tooltip `mode: item` is ignored, and pie also ignores `none` (Bug · Flutter · Low)
- [x] **50.** On an axis with one end fixed, the axis opens past the fixed value when every value equals it (Bug · React · Medium)
- [x] **51.** The SSR output of pie and gauge shows the empty-state text instead of the data (Bug · React · Medium)
- [x] **52.** `aria-describedby` uses the whole data table as the description, so every value is read on each focus (Accessibility · React · Medium)
  - Location: `internal/chart-frame.tsx:1470`(same structure in pie and heatmap)
  - Problem: NVDA and JAWS read hundreds of values on every focus, and the arrow key instructions are pushed to the end. The same table is also in the reading order, so it is heard twice.
  - Proposal: Point `aria-describedby` at a short summary, and keep the table only as a sibling element.
  - Flag: Decision needed — the form of the summary text and the way the table is linked have to be decided.
- [x] **53.** The tooltip, table and summary of a 100% stacked chart ignore `format` or treat the share as the value (Bug · Both · Medium)
- [x] **54.** Arrow key navigation in cartesian charts is effectively untested (Test · React · Medium)
- [x] **55.** Hovering the legend entry of a hidden series dims every drawn mark (Bug · Both · Low)
- [x] **56.** Chart arithmetic that both languages should share gives different values (Bug · Both · Low)
- [x] **57.** In RTL, a legend with `side: left/right` is drawn on the opposite side (Bug · Both · Low)
- [x] **58.** `tickFormat` prints `[object Object]` when it returns a ReactNode (Bug · React · Low)
  - Location: `packages/react/src/types.ts:849`, `internal/chart-frame.tsx:1007`
  - Problem: The type allows ReactNode, but the result is passed through `String()`.
  - Proposal: Narrow the return type to `string | number`.
  - Flag: Breaking change — the public type becomes narrower.
- [x] **59.** In Flutter line, bar and area charts, only the last value can be reached by screen reader or keyboard (Accessibility · Flutter · Medium)
  - Location: `packages/flutter/lib/src/internal/chart_frame.dart:936`
  - Problem: The summary holds only the last value of each series, and the frame has no focus or key handling. Scatter and heatmap in the same package carry every value.
  - Proposal: Add a focus node and arrow key navigation, or give each column its own semantics node.
  - Flag: Decision needed — `CLAUDE.md` specifies that Flutter carries only the summary.
- [x] **60.** The site has no descriptions of the fields of `PlassChartAxis`, `PlassChartLegend` and `PlassChartTooltip` (Docs · Docs · Medium)
- [x] **61.** The chart Accessibility sections describe the per-series summary, which only Flutter has, as if both packages had it (Docs · Docs · Low)
  - Location: `docs/en/components/charts/line-chart.md:174`, `bar-chart.md:122`, `area-chart.md:110` (same in ko)
  - Problem: React has only the `aria-label` and the table.
  - Proposal: Move that sentence into `::: fw flutter`.
- [x] **62.** `PlassTimelinePoint` and `PlassTimelineSeries` are declared twice, and their comments contradict each other (Optimisation · React · Low)
  - Location: `packages/react/src/types.ts:710`, `:740`
  - Problem: One comment says overlapping spans are drawn over each other. The other says they are moved into lanes. The second one matches the actual behaviour.
  - Proposal: Delete the first declaration.
- [x] **63.** Flutter `PlassChartSeries.dashed` does nothing (Bug · Flutter · Medium)
  - Location: `lib/src/types.dart:694`, `internal/chart_line.dart:161`, `docs/.vitepress/data/props-flutter.ts:1735`
  - Problem: The field description and the props table say the line is drawn dashed, but the line drawing code never reads this value. The React type has no such field.
  - Proposal: Implement it and add it to React too, or remove the field and its table row.
  - Flag: Decision needed — removing it changes the public API.
- [x] **64.** Flutter `smooth` and `step` stacked areas have a straight lower edge, so the bands pull apart or overlap (Bug · Flutter · Medium)
- [x] **65.** With `valueLabels="last"`, no label appears when the last value is a gap, and `extremes` is O(n²) (Bug · Both · Low)
  - Location: `bar-chart/PlBarChart.tsx:302`, `:363`, `bar_chart/pl_bar_chart.dart:383`, `:384`
  - Problem: The code compares against `one.length - 1`, so the 20 in `[10, 20, null]` gets no label. A calculation that rescans the whole series for every bar runs again on every hover render. The line chart (`chart-line.tsx:306`, `:314`) already solves both problems.
  - Proposal: Share the line chart's `labelledPoints` and its extreme-value calculation.
- [x] **66.** When a scatter chart's `x` is a `Date`, the x-axis shows millisecond numbers (Bug · Both · Medium)
- [x] **67.** The Flutter scatter summary leaves out `z` and reads series that were switched off in the legend (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/scatter_chart/pl_scatter_chart.dart:292`
  - Problem: The docs (`scatter-chart.md:98`) say `z` is added in parentheses. The summary also decides visibility from the initial value.
  - Proposal: Add `z` as `_readout` does, and use the frame's `visible`.
- [x] **68.** Flutter treemap tiles, tooltips and summary carry the first group's name (Bug · Flutter · High)
- [x] **69.** The React treemap's hidden table puts other groups' values under the first group's column name (Accessibility · React · Medium)
- [x] **70.** In a React heatmap grid, ↑/↓ do not move between rows (Accessibility · React · Low)
  - Location: `heatmap-chart/PlHeatmapChart.tsx:412`
  - Problem: `ArrowDown` does the same as `ArrowRight`, so in a 7×24 grid it takes 24 presses to reach the cell directly below.
  - Proposal: In a grid, make ↑/↓ move to the neighbouring row in the same column.
- [x] **71.** The heatmap column-name stride is set separately for each label, so labels overlap their neighbours (Bug · Both · Low)
  - Location: `PlHeatmapChart.tsx:546`, `pl_heatmap_chart.dart:717`
  - Problem: Each label computes the stride from its own width, so the labels around a long label overlap.
  - Proposal: Compute `tickStride` once, from the widest label.
- [x] **72.** When a timeline range is slightly longer than a day, the axis, tooltip and table show no date (Bug · Both · Medium)
- [x] **73.** In a timeline, spans outside a fixed `min`/`max` can be selected with hover and the keyboard (Bug · Both · Low)
  - Location: `PlTimelineChart.tsx:170`, `pl_timeline_chart.dart:187`
  - Problem: Drawing skips these spans, but they stay in the mark list. Navigation lands on spans that cannot be seen, and the tooltip appears outside the plot.
  - Proposal: Drop spans that do not overlap the plot, and clip the x of spans that cross its edge.
- [x] **74.** A `PlSparkline` `bar` with all-negative values is drawn above the strip, outside it (Bug · Both · Low)
  - Location: `sparkline/PlSparkline.tsx:213`, `sparkline/pl_sparkline.dart:256`
  - Problem: The baseline is `y(Math.max(low, 0))`, so the y of 0 falls outside the box and the bars cover the content next to it.
  - Proposal: Clamp the baseline into the range with `Math.min(Math.max(low, 0), high)`.

### 3. Display

- [x] **75.** When `PlCodeBlock`'s `code` or `language` changes, the old code stays visible until the new highlighting finishes (Bug · React · Medium)
- [x] **76.** `PlCodeBlock`'s trailing-whitespace regular expression `\s+$` takes quadratic time on long runs of whitespace (Security · Both · Medium)
- [x] **77.** `highlightLines` ranges have no upper bound, so a single typo freezes the tab (Bug · Both · Low)
  - Location: `PlCodeBlock.tsx:286`, `pl_code_block.dart:518`
  - Problem: `'1-100000000'` builds a `Set` of 100 million entries. In Flutter, `int.parse` throws on a very large number and the build fails.
  - Proposal: Limit the loop to the actual line range, and use `int.tryParse` in Dart.
- [x] **78.** When `PlCodeBlock`'s `title` is not a string, the focusable region has no name (Accessibility · React · Low)
  - Location: `PlCodeBlock.tsx:555`, `:636`
  - Problem: A title given as an element cannot produce an `aria-label`.
  - Proposal: Give the title `<span>` an id and link it with `aria-labelledby`.
- [x] **79.** A name registered with `registerLanguage` is ignored when it matches a built-in alias (Bug · React · Low)
  - Location: `packages/react/src/internal/highlight.ts:202`
  - Problem: Aliases are checked first, so `language="vue"` is still highlighted as `xml` after `registerLanguage('vue', vue)`. The JSDoc says a registration replaces the built-in.
  - Proposal: Check registered keys before aliases.
- [x] **80.** The Flutter `PlCodeBlock` region name uses `codeLabel` before the language (Bug · Flutter · Low)
  - Location: `pl_code_block.dart:842`
  - Problem: With `language: 'dart', codeLabel: 'Code'`, the name is `dart` in React and `Code` in Flutter.
  - Proposal: Use the order `languageName ?? codeLabel ?? labels.code`, and document that the Flutter name cannot come from `title`, as it can on React.
- [x] **81.** Flutter `PlCodeBlock` does not pass the raw toggle state or the copy result to screen readers (Accessibility · Flutter · Low)
  - Location: `pl_code_block.dart:1151`
  - Problem: There is no `toggled`, and nothing is announced after a copy. React uses `aria-pressed` and `aria-live`.
  - Proposal: Add `toggled: raw` and a live region announcement.
- [x] **82.** The code-block page's Accessibility section promises behaviour for both packages that Flutter does not have (Docs · Docs · Medium)
- [x] **83.** The `copyFailedLabel` JSDoc gives the wrong default (Docs · React · Low)
  - Location: `PlCodeBlock.tsx:178`
  - Problem: The JSDoc says `'Copy failed'`, but the actual default is `'Could not copy'`.
  - Proposal: Fix the JSDoc.
- [x] **84.** A `RegExp` in the `query` list of Flutter `PlHighlight` is escaped and matched as literal text (Bug · Flutter · Medium)
  - Location: `packages/flutter/lib/src/components/highlight/pl_highlight.dart:177`, `:187`
  - Problem: `query: [RegExp(r'\d+')]` looks for the literal text `\d+` and marks nothing. The docs say the list accepts both String and RegExp values.
  - Proposal: Join a `RegExp` in the list without escaping it, or restrict the list to `List<String>` and fix the docs.
  - Flag: Decision needed
- [x] **85.** Scaling up the text size in Flutter `PlHighlight` enlarges only the marked words twice (Accessibility · Flutter · Medium)
- [x] **86.** Expanding the collapsed steps of `PlBreadcrumb` loses keyboard focus (Accessibility · React · Medium)
- [x] **87.** The sort headers of Flutter `PlDataTable` cannot be reached with the keyboard (Accessibility · Flutter · High)
- [x] **88.** In descending order, `PlDataTable` puts empty values first (Bug · Both · Medium)
- [x] **89.** `PlDataTable`'s default row key and callback `index` are relative to the current page, so selection lands on the wrong row (Bug · Both · Medium)
- [x] **90.** An uncontrolled Flutter `PlDataTable` never calls `onPageChanged` (Bug · Flutter · Medium)
- [x] **91.** Setting a controlled Flutter `sort` back to `null` brings back the sort still held internally (Bug · Flutter · Medium)
- [x] **92.** Flutter `PlDataTable` sorting is not stable, so rows with equal values change order (Bug · Flutter · Medium)
- [x] **93.** React `PlGallery` masonry follows columns for focus and reading order, and tiles remount when the column count changes (Accessibility · React · Medium)
- [x] **94.** When an arrow button of `PlGalleryViewer` is disabled at either end, focus and the arrow keys stop working (Accessibility · React · Medium)
- [x] **95.** The large image in the Flutter `PlGallery` viewer has no name (Accessibility · Flutter · Medium)
- [x] **96.** On a pressable gallery tile, `title` and `description` do not reach screen readers (Accessibility · Both · Low)
  - Location: `PlGallery.tsx:472-476`, `pl_gallery.dart:600-601`
  - Problem: The button name is fixed as `alt — n of m`, and the caption is hidden.
  - Proposal: Link the caption with `aria-describedby` in React and with `hint` in Flutter.
- [x] **97.** The React props table for `PlGallery` has no `classNames` row (Docs · Docs · Low)
  - Location: `docs/.vitepress/data/props.ts:12975`
  - Problem: It is a public prop and the page text describes it, but the table does not list it.
  - Proposal: Add the row, following the shared `classNames` row definition.
- [x] **98.** Every `PlChip` remove button has the same name, "Remove" (Accessibility · Both · Medium)
- [x] **99.** The × inside chips, comboboxes and picker triggers is about 15px, below WCAG 2.5.8 (24px) (Accessibility · Both · Low)
  - Location: `packages/react/src/internal/styles.ts:448-455`, `internal/picker.tsx:315`, `chip/pl_chip.dart:301-306`
  - Problem: It sits 2px from the label button or the trigger, so it does not qualify for the spacing exception either. On touch screens it is easy to mix up opening and clearing.
  - Proposal: Keep the visible size, and widen only the hit area to 24px with a pseudo-element or transparent padding.
- [x] **100.** Flutter `PlAvatar` and `PlGallery` decode images at full resolution (Performance · Flutter · Medium)
  - Location: `gallery/pl_gallery.dart` (`LayoutBuilder` board and `_tile`)
  - Done in `eaabbe83`: `PlAvatar`, `PlImage` and the gallery viewer decode at the size they are drawn, through `internal/decode.dart`.
  - Problem left: the gallery builds every tile at once, so a gallery of 60 pictures asks for 60 decodes before any of them is on screen.
  - Proposal: Build only the tiles near the view, and take the item when that is done.
- [x] **101.** The `rel` merge for new-tab links is skipped on some code paths (Security · React · Medium)
- [x] **102.** The `PlTextLink` `icon` row in the Flutter props table inherits React's true/false description (Docs · Docs · Low)
  - Location: `docs/.vitepress/data/props-flutter.ts:5297`
  - Problem: In Flutter, `icon` is a Widget, and `showIcon` decides whether it is drawn.
  - Proposal: Replace it with a Flutter-only description.
- [x] **103.** Changing `PlImage`'s `src` to a new image that is already cached does not call `onStatusChange` (Bug · React · Medium)
- [x] **104.** A `placement: 'tile'` watermark does not cover the corners of wide or tall photos (Bug · Both · Low)
  - Location: `packages/react/src/internal/watermark.tsx:117-121`, `packages/flutter/lib/src/internal/watermark.dart:204-205`
  - Problem: The rotated layer has a fixed size, such as 150% of the box, so empty triangles appear in the diagonal corners from 16:9 (React) and 2:1 (Flutter) onwards. This contradicts the comment.
  - Proposal: Size the layer from the diagonal of the box.
- [x] **105.** A tile watermark `color` given as a token or `currentColor` is drawn black (Bug · React · Low)
  - Location: `internal/watermark.tsx:72`
  - Problem: `var()` does not resolve inside an SVG data URI. The value is also not escaped, so a `"` in it breaks the tile.
  - Proposal: Draw the tile with `mask-image` and `background-color` together, or document that only literal colours are accepted and escape the value.
- [x] **106.** The Flutter `PlImage` preview photo has no description, the decorative-image flag merges into the parent, and the failure label is read twice (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/image/pl_image.dart:548`, `:711-717`, `:733-738`
  - Problem: The photo in the open overlay has `excludeFromSemantics: true`, so only "Preview" is heard. The `image: true` of an unlabelled image merges into a parent node such as `PlButton`. When loading fails, the label is read as "X X".
  - Proposal: Give the overlay a `semanticLabel`, use `ExcludeSemantics` when there is no label, and exclude the default fallback text as well.
- [x] **107.** On an SSR page, the whole `PlMockup` is `visibility: hidden` until hydration (Performance · React · Medium)
  - Location: `packages/react/src/components/mockup/PlMockup.tsx:231-235`, `:313-316`
  - Problem: The measurement is `null` on the server, so `hidden` is baked into the SSR HTML. A mockup in a landing hero drops out of the LCP candidates, and it looks empty when JS loads late.
  - Proposal: Compute the scale on the server when numeric `width`/`height` are given. Otherwise, decide what to show before the measurement.
  - Flag: Decision needed
- [x] **108.** Screen readers read the clock in the Flutter `PlMockup` system bar (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/mockup.dart:664-667`
  - Problem: In React the whole chrome is `aria-hidden`, and the docs say both packages hide it, but Flutter reads "9:41".
  - Proposal: Wrap the chrome and the cutout in `ExcludeSemantics`.
- [x] **109.** React `PlTree` rebuilds the whole loaded tree every time focus moves one step (Performance · React · Medium)
- [x] **110.** Pressing → on an open branch with no visible children moves to the next sibling (Bug · Both · Low)
  - Location: `PlTree.tsx:253`, `tree/pl_tree.dart:290`
  - Problem: With `children: []`, or when every child is `disabled`, the next row is a sibling. Under the APG, nothing happens in this case.
  - Proposal: Move only when the next row's level is the current level + 1.
- [x] **111.** The tree docs' advice to leave "`children: undefined` until opened" cannot be followed (Docs · Both · Low)
  - Location: `docs/en/components/display/tree.md:123` (same in ko), `PlTree.tsx:32-34`
  - Problem: `undefined` makes a leaf that cannot be opened. Line 113 of the same page recommends `children: []`.
  - Proposal: Change all three places to `children: []`.
- [x] **112.** The map of row `FocusNode`s in Flutter `PlTree` is never cleaned up (Performance · Flutter · Low)
  - Location: `pl_tree.dart:183`, `:196-197`
  - Problem: Nodes for ids removed from `items` stay until dispose, and each node's key closure holds on to the old list.
  - Proposal: After build, dispose the nodes whose ids are not in the current rows.
- [x] **113.** `PlTypography` cuts a `lines` value above 6 to 6 lines, and truncation with an ellipsis does not work on `caption`/`overline` (Bug · React · Medium)
- [x] **114.** Flutter `PlTypography` does not pass on the heading level, and the docs explain that "Flutter has no depth" (Accessibility · Flutter · Medium)
- [x] **115.** The typography docs' claim that "Flutter `lines` actually discards the cut text" is wrong (Docs · Flutter · Low)
  - Location: `docs/en/components/display/typography.md:187` (same in ko)
  - Problem: `RenderParagraph` builds the semantics label from the whole string, so screen readers get the full text.
  - Proposal: Change it to "cuts the text visually only".
- [x] **116.** Hovering or focusing one Flutter `PlTable` row rebuilds the whole table and recomputes the intrinsic layout (Performance · Flutter · Medium)
- [x] **117.** The `PlTable` `stickyHeader` JSDoc claim that it "also works inside an outer pane" is wrong (Docs · React · Low)
  - Location: `packages/react/src/components/table/PlTable.tsx:95-99`
  - Problem: The `overflow-x-auto` wrapper becomes the sticky scroll container, so the header does not stick without `maxHeight`. The description on the docs page is correct.
  - Proposal: Change the JSDoc to say "`maxHeight` is required".
- [x] **118.** The scroll area of a horizontally overflowing `PlTable` cannot be reached with the keyboard (Safari) (Accessibility · React · Low)
  - Location: `PlTable.tsx:255-266`
  - Problem: In a wide table with no focusable cells, the remaining columns cannot be reached (WCAG 2.1.1).
  - Proposal: Give the scroll wrapper `tabIndex={0}`, `role="region"` and a name based on the caption.
  - Flag: Decision needed — decide whether to add these always or only when the table overflows (which needs a hook).
- [x] **119.** React `PlStat` prints `change` unformatted, so floating-point errors show and the output differs from Flutter (Bug · React · Low)
  - Location: `packages/react/src/components/stat/PlStat.tsx:185`
  - Problem: `change={0.1 + 0.2}` renders as `+0.30000000000000004%`. Flutter `formatChange` rounds to one decimal place.
  - Proposal: Add the same `formatChange` to React, and make both packages hide the arrow when the value rounds to 0.
- [x] **120.** Inserting an item at the start of `PlTimeline` remounts every item (Performance · React · Low)
  - Location: `packages/react/src/components/timeline/PlTimeline.tsx:339`, `:364`
  - Problem: The Provider key is `index`, so adding a new event to the front of an activity feed wipes the item state and images fade in again.
  - Proposal: Use `item.key ?? index`.

### 4. Feedback

- [x] **121.** `PlTour` leaves the card beside the first target after moving to the next step, and shows no card on a step without a target (Bug · React · High)
- [x] **122.** Flutter `PlTour` does not move focus to the card when it opens, so Escape does not work (Accessibility · Flutter · Medium)
- [x] **123.** `PlTour` does not pass the new title and content to screen readers when the step changes (Accessibility · Both · Medium)
- [x] **124.** `PlTour` scrolling ignores reduced motion (Accessibility · Both · Low)
  - Location: `PlTour.tsx:318`, `pl_tour.dart:327`
  - Problem: It always scrolls smoothly. `PlBackTop`, `PlCarousel` and `PlScrollZone` follow the setting.
  - Proposal: Move instantly when reduced motion is on.
- [x] **125.** `PlTour` cuts no hole when the target is an SVG element (Bug · React · Low)
  - Location: `PlTour.tsx:313`
  - Problem: It measures the position only when the target is an `instanceof HTMLElement`. When the tour points at a chart bar, the whole page goes dark and the target cannot be pressed either.
  - Proposal: Check with `instanceof Element`.
- [x] **126.** A Flutter toast that is already closing gets a new timer, which throws on a disposed controller 5 seconds later (Bug · Flutter · High)
- [x] **127.** The loading toast of Flutter `showFuture` closes on its timeout, so the result toast never appears (Bug · Flutter · Medium)
- [x] **128.** Screen readers never read a Flutter toast with the default `low` priority (Accessibility · Flutter · Medium) — every toast is now a live region; Flutter has no assertive level to give `high`
- [x] **129.** The Flutter toast timer does not pause on keyboard focus, on touch, or when the app goes to the background (Accessibility · Flutter · Medium)
- [x] **130.** A React toast dismissed with a swipe jumps back to its original place before it disappears (Bug · React · Low)
  - Location: `packages/react/src/components/toast/PlToast.tsx:289`
  - Problem: When the finger is lifted, Base UI clears the inline `transform` and leaves the position to the swipe variables, but this component handles only the opacity.
  - Proposal: Keep the position with the swipe variables in `data-[ending-style]`, or turn swiping off.
  - Flag: Decision needed — keeping the position adds one more exception to the no-transform rule.
- [x] **131.** The toast docs say "the × is not in the tab order", which does not match the actual behaviour (Docs · React · Low)
  - Location: `docs/en/components/feedback/toast.md:200`(same in ko)
  - Problem: Base UI `Toast.Root` has `tabIndex=0` and `Close` is an ordinary button, so Tab reaches it.
  - Proposal: Correct it to say that both Tab and F6 reach it.
- [x] **132.** `initialFocus` is not applied again for the next question in the `PlConfirmProvider` queue (Accessibility · Both · Medium)
- [x] **133.** The Flutter confirm dialog empties its content and resets its buttons to the defaults while it closes (Bug · Flutter · Low)
  - Location: `pl_confirm.dart:248`
  - Problem: The comment says the request is kept until the fade ends, but the code sets it to `null` at once. The title disappears for 260ms, and an alert gains a Cancel button.
  - Proposal: Keep the request being drawn separate from the request waiting for an answer, and change only `_open` when closing.
- [x] **134.** The confirm docs wrongly say "there is no difference matching `dismissible: false`" (Docs · Flutter · Low)
  - Location: `docs/en/components/feedback/confirm.md:64`(same in ko)
  - Problem: Flutter also has `dismissible`. The Flutter confirm dialog has no ×, but the React confirm dialog draws one because of the `PlModal` default.
  - Proposal: Delete the sentence, and decide whether React should also match with `showClose={false}`.
  - Flag: Decision needed
- [x] **135.** While a Flutter `dismissible` popover is open, the screen behind it cannot be pressed or scrolled (Bug · Flutter · Medium)
- [x] **136.** When `disabled` turns on while a Flutter tooltip is open, every tooltip in the same group then opens with no delay (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/tooltip/pl_tooltip.dart:229`
  - Problem: `didUpdateWidget` turns off only `_open` and does not call `_release()`, so the provider's open count is left behind.
  - Proposal: Keep `_hold`/`_release` in step with every change of the open state, and cancel the pending timer.
- [x] **137.** Pressing the × on a React uncontrolled `inline` drawer does not close it (Bug · React · Low)
  - Location: `packages/react/src/components/drawer/PlDrawer.tsx:390`, `:442`
  - Problem: Inline mode has no internal state and only reads `open ?? defaultOpen ?? true`.
  - Proposal: Give inline mode uncontrolled state as well, or do not draw the × when `open` is not given.
- [x] **138.** The segment of a Flutter indeterminate progress bar moves only inside the track and jumps at the end (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/progress_linear/pl_progress_linear.dart:290`
  - Problem: `AlignmentDirectional(-1…1)` only aligns the segment to the inner ends of the track, so it jumps instantly from the right end to the left end. In React the segment enters from outside the track and leaves past it.
  - Proposal: Widen the x range to about ±2.64 to match the React path.
- [x] **139.** Giving React `PlSkeleton` a `label` does not announce it to screen readers (Accessibility · React · Low)
  - Location: `packages/react/src/components/skeleton/PlSkeleton.tsx:196`
  - Problem: A `role="status"` with only an `aria-label` and no text is mounted in that form from the start, so no announcement happens.
  - Proposal: Put the label in as visually hidden text, or correct the docs.
- [x] **140.** Flutter `PlSkeleton` runs a separate `AnimationController` and clip for every bar (Performance · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/skeleton/pl_skeleton.dart:234`, `:267`
  - Problem: A list of 12 rows runs 36 separate tickers, and their phases drift apart.
  - Proposal: Share the controller, and use the `borderRadius` of `BoxDecoration` instead of `ClipRRect`.
- [x] **141.** The three React progress components do not use the `locale` from `PlassProvider` (Bug · React · Low)
  - Location: `packages/react/src/internal/progress.ts:217`, `progress-linear/PlProgressLinear.tsx:75`(same in Circular and Box)
  - Problem: Unlike `PlMeter`, they do not pass the locale, so the SSR display can mismatch, and the default percentage is fixed to `${n}%`. The comment "the Base UI default is `${value}%`" also does not match 1.8.
  - Proposal: Pass `locale={defaults.locale}` and use Base UI's `formattedValue`.

### 5. Inputs

- [x] **142.** The pickers, `PlCalendar`, `PlColorPicker` and `PlFilePicker` do not take part in `PlForm` (Bug · React · High)
- [x] **143.** The pickers' hidden input has no `required` and no `disabled` (Bug · React · Medium)
- [x] **144.** A picker trigger with a label does not read out the selected value (Accessibility · React · High)
- [x] **145.** The time column (`TimeGrid`) cannot be used with the keyboard (Accessibility · Both · High)
- [x] **146.** The names of the month and year buttons in the calendar header override the text on screen (Accessibility · React · Medium)
- [x] **147.** Keyboard focus on a Flutter calendar cell does not appear in the semantics tree (Accessibility · Flutter · Medium)
- [x] **148.** The × on a Flutter picker trigger does not take focus (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/picker.dart:267`
  - Problem: It is only a `GestureDetector`, so the value cannot be cleared with the keyboard. `PlColorPicker` has no Clear in its footer, so it has no way to be emptied with the keyboard at all.
  - Proposal: Replace it with a focusable interactive widget.
- [x] **149.** The calendar keyboard model and the date arithmetic have no tests (Test · Both · Medium)
- [x] **150.** The range picker comments say the opposite of what the code does (Optimisation · Both · Low)
  - Location: `date-range-picker/PlDateRangePicker.tsx:170`, `date_range_picker/pl_date_range_picker.dart:267`
  - Problem: The comments say "a range with only one end is never passed", but the first click passes `{ start: day, end: null }`, and the tests expect that too.
  - Proposal: Correct the comments.
- [x] **151.** The Flutter formula that builds the display samples is copied into four files (Optimisation · Flutter · Low)
  - Location: `date_picker/pl_date_picker.dart:55`, `date_range_picker/pl_date_range_picker.dart:18`, `date_time_picker/pl_date_time_picker.dart:18`, `time_picker/pl_time_picker.dart:19`
  - Problem: If only one copy changes, the trigger width differs from one component to another. React has a single `displaySamples`.
  - Proposal: Move it to `internal/date.dart`.
- [x] **152.** Choosing a day in `PlDateTimePicker` commits a moment outside `minDate`/`maxDate` (Bug · Both · High)
- [x] **153.** The `::: fw react` in the date-time-picker docs is stuck to the end of a list line and breaks (Docs · Docs · Low)
  - Location: `docs/en/components/inputs/date-time-picker.md:157`(same in ko)
  - Problem: The container does not open, so `:::` shows as text, and the hidden input item is visible to Flutter readers too.
  - Proposal: Move `::: fw react` onto a line of its own, and fix the sentence about the time column together with item 145.
- [x] **154.** The files `PlFilePicker` submits with a form differ from the list on screen (Bug · React · High)
- [x] **155.** The field `label` of `PlFilePicker` is not included in the name of the drop zone button (Accessibility · Both · Medium)
- [x] **156.** The value input of Flutter `PlColorPicker` loses focus after every character (Bug · Flutter · High)
- [x] **157.** The hue and opacity rails ignore ↑/↓ and Home/End (Accessibility · Both · Medium)
- [x] **158.** The `label` and `error` of an `inline` colour picker are not connected to the panel (Accessibility · Both · Medium)
- [x] **159.** Flutter colour swatches do not receive keyboard focus (Accessibility · Flutter · Medium)
- [x] **160.** A swatch that fails to parse remains as a button that does nothing when pressed (Bug · Both · Low)
  - Location: `PlColorPicker.tsx:498`, `:515`, `pl_color_picker.dart:943`
  - Problem: `swatches={['red']}` draws an active red button in React, but its clicks are ignored. In Flutter it becomes a transparent circle. React puts the raw string into the inline `backgroundColor`.
  - Proposal: Skip swatches that fail to parse, and paint with a colour built from the parsed value.
- [x] **161.** A React inline colour picker can still be operated inside a disabled `fieldset` (Bug · React · Low)
  - Location: `PlColorPicker.tsx:318`, `:676`
  - Problem: The square and the rails are `div` elements with `tabIndex={0}`, so `<fieldset disabled>` does not affect them.
  - Proposal: Check whether the picker is inside a disabled fieldset, and merge that into the disabled state.
- [x] **162.** The Flutter colour picker calculates the thumb position with the `md` size (Bug · Flutter · Low)
  - Location: `pl_color_picker.dart:832`
  - Problem: At `xs` and `xl`, the centre of the thumb is 2px off the value.
  - Proposal: Pass the actual thumb size.
- [x] **163.** Choosing an option with Enter in Flutter `PlCombobox` makes the input lose focus (Bug · Flutter · Medium)
- [x] **164.** Flutter `PlCalendar` does not become disabled when there is no `onChanged` (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/calendar/pl_calendar.dart:206`, `:226`
  - Problem: The docs say the calendar is inert when `onChanged` is null, but its cells are read as active buttons and take focus and taps.
  - Proposal: Apply `ExcludeFocus` and `IgnorePointer`.
- [x] **165.** The Accessibility section of the calendar docs promises React-only keys to Flutter as well (Docs · Both · Low)
  - Location: `docs/en/components/inputs/calendar.md:163`(same in ko), `internal/calendar.dart:845`, `:978`
  - Problem: `role="grid"` and moving by year with Shift+PageUp/PageDown are listed with no fw split, but Flutter does not handle them.
  - Proposal: Add the key handling to Flutter, and wrap the React-only items in `::: fw react`.
- [x] **166.** In Flutter `PlForm` `onSubmit` mode, errors remain after a failed submit even when the values are corrected (Bug · Flutter · Medium)
- [x] **167.** Flutter `PlFloatingActionButton` reads its name twice when `extended` (Accessibility · Flutter · Medium)
- [x] **168.** The floating action button position ignores the device safe area (Accessibility · Both · Medium)
  - Location: `floating-action-button/PlFloatingActionButton.tsx:133`, `pl_floating_action_button.dart:148`
  - Problem: The offset is fixed at `1.5rem`/`24`, so on an edge-to-edge screen the button overlaps the navigation bar or the home indicator.
  - Proposal: Add `MediaQuery.paddingOf` in Flutter and `env(safe-area-inset-*)` in React.
  - Flag: Decision needed — decide whether the component or the caller is responsible for the safe area.
- [x] **169.** The FAB docs promise props that Flutter does not have, and leave props it does have out of the table (Docs · Flutter · Low)
  - Location: `docs/en/components/inputs/floating-action-button.md:40`, `docs/.vitepress/data/props-flutter.ts:3121`
  - Problem: The docs say it "accepts everything PlButton accepts", but Flutter has no `readOnly`, `onLongPress`, `focusNode` or `autofocus`. The table is missing `color`, `loading` and `disabled`, which Flutter does have. The `corner` and `floating` examples exist only in TSX.
  - Proposal: Split the sentence with fw, add the three rows to the table, and add Dart examples.
- [x] **170.** `PlButton` does not tell assistive technology when it changes to `loading` (Accessibility · Both · Low)
  - Location: `button/PlButton.tsx:256`, `button/pl_button.dart:546`
  - Problem: React only changes `aria-busy`, and the spinner is `aria-hidden`, so the start and the end of the work are not heard.
  - Proposal: While loading, announce it with hidden status text or a polite live region.
  - Flag: Decision needed — decide whether to add a new label key, and how to announce it.
- [x] **171.** Flutter reads a `readOnly` checkbox as disabled (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/checkbox/pl_checkbox.dart:292`
  - Problem: Because of `enabled: _interactive`, a read-only checkbox that takes focus is announced as "disabled".
  - Proposal: Split it into `enabled: !_disabled` and `readOnly`.
- [x] **172.** Disabled Flutter input fields stay in the Tab order and even draw a focus ring (Accessibility · Flutter · Low)
  - Location: `text_field/pl_text_field.dart:288`, `:394`, `number_field/pl_number_field.dart:540`, `otp_field/pl_otp_field.dart:395`
  - Problem: `disabled` is carried over only to `readOnly`, so keyboard users stop on disabled fields. This differs from the rule in React and in Flutter `PlButton`.
  - Proposal: Apply `ExcludeFocus` or `canRequestFocus: false` when `disabled`.
- [x] **173.** The ko toggle page's `## size` is at a different level from `### size` in en, so the examples after it fall outside Examples (Docs · Docs · Low)
  - Location: `docs/ko/components/inputs/toggle.md:108`
  - Problem: The structure of the two locales does not match.
  - Proposal: Change it to `###` to match.
- [x] **174.** With `allowWheelScrub` in Flutter `PlNumberField`, the wheel moves both the value and the page (Bug · Flutter · Medium)
- [x] **175.** Flutter `PlNumberField` has two overlapping text field semantics nodes (Accessibility · Flutter · Medium)
- [x] **176.** In Flutter `PlNumberField`, the visible number and the value drift apart when the parent rejects a value (Bug · Flutter · Medium)
- [x] **177.** Holding a Flutter `PlNumberField` stepper calls `onCommitted` every 60ms, even after the limit is reached (Bug · Flutter · Medium)
- [x] **178.** Every cell of React `PlOtpField` is read with the same name (Accessibility · React · Medium)
- [x] **179.** The otp-field docs' statement that "every cell has `autocomplete="one-time-code"`" is not true (Docs · Docs · Low)
  - Location: `docs/en/components/inputs/otp-field.md:191`(same in ko)
  - Problem: Base UI gives `one-time-code` only to the first cell, and the rest get `off`.
  - Proposal: Change "every cell" to "the first cell".
- [x] **181.** React `PlPagination` loses focus on the pressed button when the page changes (Accessibility · React · Medium)
- [x] **182.** Flutter `PlPagination` does not mark the current page for screen readers (Accessibility · Flutter · Medium)
- [x] **183.** React `PlRadioGroup` `disabled` is not reflected in how the options look (Bug · React · Medium)
- [x] **184.** Flutter `PlRating` drops to 0 when End is pressed at the top score (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/rating/pl_rating.dart:175`, `:272`, `:283`
  - Problem: With the default `clearable: true`, End is handled as "picking the same score again".
  - Proposal: Ignore Home/End when the value is already the same.
- [x] **185.** Flutter `PlSegmentedButton` does not measure the tile position again when its size changes (Bug · Flutter · Medium)
- [x] **186.** Flutter `PlSelect` trigger name leaves out the field `label` and reads the selected value twice (Accessibility · Flutter · Medium)
- [x] **187.** `PlSelect` trigger always renders every option label to work out its width (Performance · Both · Medium)
  - Location: `select/PlSelect.tsx` (`sizerSamples`), `internal/sizer.tsx`, `pl_select.dart` (`_value`)
  - Done in `998d019d`: a `fullWidth` trigger renders no samples in either package.
  - Problem left: a trigger without `fullWidth` still renders every label, so a list of 250 countries with a flag in each still requests 250 images.
  - Proposal: Leave labels that are not strings out of the sample, or limit how many are sampled.
  - Flag: Decision needed — leaving them out lets such a trigger change width with its value, and a limit needs a number.
- [x] **188.** Flutter `PlSlider` cannot be adjusted with a screen reader (Accessibility · Flutter · High)
- [x] **189.** Tapping a Flutter `PlSlider` thumb moves the value by the thumb's radius (Bug · Flutter · Medium)
- [x] **190.** Flutter `PlSlider` rounds the value it reads out to an integer and ignores `formatValue` (Accessibility · Flutter · Medium) — no longer reproduces
- [x] **191.** React `PlSlider` has no way to give each thumb its own name and `aria-valuetext` (Accessibility · React · Medium)
- [x] **192.** Pressing a `PlTransfer` move button loses focus and does not announce the result (Accessibility · Both · Medium)
- [x] **193.** `PlTransfer` arrows point the wrong way in RTL (Bug · Both · Medium)
- [x] **194.** The "Select all" checkboxes of the two `PlTransfer` lists have the same name (Accessibility · Both · Low)
  - Location: `PlTransfer.tsx:141`, `pl_transfer.dart:358`
  - Problem: By ear, there is no way to tell which list a checkbox belongs to.
  - Proposal: Add the panel title to the name.
- [x] **195.** One tick in `PlTransfer` redraws every row of both lists (Performance · Both · Medium)
  - Location: `PlTransfer.tsx:181-192`, `:275`, `pl_transfer.dart:377-406`
  - Problem: Every row renders a `PlCheckbox` with no virtualisation, so in lists of thousands of items, input stalls on every tick.
  - Proposal: Wrap rows in `React.memo` and virtualise long lists (`ListView.builder` in Flutter).

### 6. Layout

- [x] **196.** A responsive slot set by a parent is inherited by nested children (Bug · React · High)
- [x] **197.** Flutter `PlGrid` throws when a cell contains a widget that uses `LayoutBuilder` (Bug · Flutter · High)
- [x] **198.** Flutter `PlScrollArea` and `PlScrollZone` cannot be scrolled with the keyboard (Accessibility · Flutter · Medium)
- [x] **199.** The pointer drag path has no tests (Test · React · Low)
  - Location: `internal/drag.ts`, `test/components/scroll-zone/`, `panes/`, `sidebar/`
  - Problem: A regression in restoring the selection when unmounting during a drag, in `pointercancel`, or in `PlScrollZone` suppressing the click after a drag would go unnoticed.
  - Proposal: Verify the teardown and the click suppression with pointer events.
- [x] **200.** `PlHeader` and `PlFooter` inside the body take over the `PlPageLayout` slot registration (Bug · React · Medium)
- [x] **201.** Nesting `PlPageLayout` duplicates `<main>`, `id="main"` and the skip link (Accessibility · React · Medium)
  - Location: `PlPageLayout.tsx:401`, `docs/en/components/layout/page-layout.md:176`
  - Problem: `height="auto"` is meant for a layout that is not the page, but used that way it creates a `<main>` inside a `<main>` and a second "Skip to content". The docs say the layout guarantees exactly one per page, and the docs demo also duplicates the id inside VitePress's `<main>`.
  - Proposal: When there is an outer layout, render a `div` and turn off the skip link, or fix the sentence in the docs.
  - Flag: Decision needed
- [x] **202.** Flutter `PlSidebar` resets the dragged width to the default on every parent rebuild (Bug · Flutter · High)
- [x] **203.** The focusable separator in React `PlSidebar` has no `aria-valuenow` (Accessibility · React · Medium)
- [x] **204.** React `PlSidebar` drawer direction ignores `PlassProvider direction` (Bug · React · Low)
  - Location: `packages/react/src/internal/page-layout.ts:193-201`
  - Problem: It reads only the document's `direction`, so a collapsed start sidebar in an RTL subtree of an LTR document opens from the opposite side. Flutter follows the surrounding `Directionality`.
  - Proposal: Use the value from Base UI `useDirection()`.
- [x] **205.** React `PlPanes` handles have no way to take an accessible name (Accessibility · React · Medium)
- [x] **206.** In React `PlScrollZone`, an unfinished mouse drag makes the strip move on hover alone (Bug · React · Medium)
- [x] **207.** React `PlScrollZone` scroller is always a tab stop, even with nothing to scroll (Accessibility · React · Medium)
- [x] **208.** React `PlScrollArea` scrolls horizontally with `orientation="vertical"` (Bug · React · Low)
  - Location: `scroll-area/PlScrollArea.tsx:176-190`
  - Problem: The Base UI viewport has `overflow: scroll` on both axes, so a `<pre>` or a long URL scrolls sideways with no scrollbar. Flutter scrolls vertically only.
  - Proposal: For a single axis, set `overflow-*-hidden` on the other axis.
- [x] **209.** `PlShow` docs say that descendants which portal out are hidden too (Docs · React · Medium)
- [x] **210.** `PlShow` is always a `<div>`, which causes a hydration error in inline contexts (Bug · React · Low)
  - Location: `PlShow.tsx:67-76`
  - Problem: With SSR inside a `<p>`, the parser closes the `<p>` and causes a mismatch. There is no `render` prop to switch it to a `span`.
  - Proposal: Add a `render` prop based on `useRender`.
- [x] **211.** Passing `style` to `PlContainer` loses `maxWidth` (Bug · React · Medium)
- [x] **212.** The size-tracking test for `usePlElementSize` does not verify tracking (Test · React · Low)
  - Location: `packages/react/test/hooks/usePlElementSize.test.tsx:49-57`
  - Problem: The second `render` mounts a new root, so the test passes even if ResizeObserver updates break.
  - Proposal: Change the style of one element, then poll the same output.

### 7. Navigation

- [x] **213.** React `PlAnchor` follows only the window scroll, so no row becomes active inside a scroll container (Bug · React · Low)
- [x] **214.** Pressing a Flutter `PlAnchor` row ignores `offset` and the setting that turns animations off (Bug · Flutter · Medium)
- [x] **215.** Focus stays on a hidden button after React `PlBackTop` is pressed (Accessibility · React · Medium)
- [x] **216.** Flutter `PlBackTop` never shows its button on desktop or desktop web when `controller` is left out (Bug · Flutter · Medium)
  - Location: `back_top/pl_back_top.dart:109`, `docs/en/components/navigation/back-top.md:47`
  - Problem: `PrimaryScrollController` is inherited automatically only on mobile platforms, so `hasClients` is always false. This default path has no test either.
  - Proposal: Document the limitation and point to `controller`, or add a debug assert.
  - Flag: Decision needed
- [x] **217.** React `PlBackTop` `floating` position does not account for the safe area or bottom navigation (Accessibility · React · Low)
- [x] **218.** The back-top page has no `## Accessibility` section, and its `label` tooltip description is wrong (Docs · Docs · Low)
  - Location: `docs/en/components/navigation/back-top.md:88` (same in ko)
  - Problem: It is the only component page without this section. `PlIconButton` does not set `title`, so no tooltip appears.
  - Proposal: Move the content into an Accessibility section and delete the tooltip sentence.
- [x] **219.** Flutter `PlBottomNavigation` stops marking the current destination when `onChanged` is left out (Bug · Flutter · Low)
  - Location: `bottom_navigation/pl_bottom_navigation.dart:268`, `:282-294`
  - Problem: Every item becomes `unavailable`, so even the selected item is drawn without its background. The dartdoc says it "stops where it is".
  - Proposal: Keep the wash and the accent on the selected item, and apply only the dimming.
- [x] **220.** React `PlFloatingBottomNavigation` leaves the key under the previous disc when `value` matches no item (Bug · React · Medium)
- [x] **221.** React `PlCommandPalette` keeps the search text when it is closed by running a command or by the parent (Bug · React · Medium)
- [x] **222.** The keyboard run path of React `PlCommandPalette` has no tests (Test · React · Medium)
- [x] **223.** React `PlCommandPalette` renders every filtered result without virtualisation (Performance · React · Low)
  - Location: `PlCommandPalette.tsx:336-393`
  - Problem: At around 2,000 commands, the first open and typing a short search become slow.
  - Proposal: Add a result cap (`limit`) or virtualisation.
  - Flag: Decision needed — whether to set a default cap has to be decided.
- [x] **224.** Flutter `PlCommandPalette` row names are read twice (Accessibility · Flutter · Low)
  - Location: `command_palette/pl_command_palette.dart:549`, `:558`
  - Problem: The `Text` under `Semantics(label:)` is not excluded.
  - Proposal: Exclude the children, and put the description and the shortcut in the label or the hint.
- [x] **225.** React `PlMenuItem` ignores `disabled` when it has `href` (Bug · React · Medium)
- [x] **226.** Submenus open on the wrong side in RTL, and the chevron is not flipped (Bug · Both · Medium)
- [x] **227.** The docs say disabled Flutter `PlMenu` rows can be found by typeahead, which does not match the code (Docs · Flutter · Low)
  - Location: `pl_menu.dart:97`, `:612`, `docs/en/components/navigation/menu.md:239`
  - Problem: `_typeahead` skips disabled rows. React finds them.
  - Proposal: Make the code match React, or fix the docs.
- [x] **228.** Flutter `PlMenubar` claims the `menuBar` role but has no arrow-key movement (Accessibility · Flutter · Medium)
  - Location: `packages/flutter/lib/src/components/menubar/pl_menubar.dart:146-151`
  - Problem: On the web it is output as `role="menubar"`, so screen readers expect arrow-key operation. Instead, Tab stops on every word, and in an open menu the left and right keys only close it. This goes against the library principle of "not claiming a role without the behaviour".
  - Proposal: Implement roving focus and left and right movement, or remove the role until that is implemented.
  - Flag: Decision needed
- [x] **229.** Links inside React `PlNavigationMenu` panels are not in the HTML until a panel is opened (SEO · React · Medium)
  - Location: `packages/react/src/components/navigation-menu/PlNavigationMenu.tsx:284-293`
  - Problem: `Content` has no `keepMounted`, so the links are missing from both the SSR output and the DOM after hydration, and crawlers that do not hover cannot find them. The docs (`navigation-menu.md:74`) promise that crawlers index them.
  - Proposal: Pass `keepMounted`, or fix the sentence in the docs.
  - Flag: Decision needed — it is a trade-off against DOM size.
- [x] **230.** Top-level navigation links have no way to mark the current page (Accessibility · Both · Medium)
- [x] **231.** The `aria-labelledby` on React `PlStepper` horizontal panels is on a `div` with no role, so it is not read (Accessibility · React · Low)
  - Location: `packages/react/src/components/stepper/PlStepper.tsx:242-250`
  - Problem: A generic element cannot have a name, so the step name is not announced when focus enters the panel. The docs (`stepper.md:167`) say it is announced.
  - Proposal: Add `role="group"` as well.
- [x] **232.** In vertical React `PlStepper`, a `status` override also changes which panel is shown (Bug · React · Low)
  - Location: `PlStepper.tsx:439`
  - Problem: The condition is `resolved === 'current'`, so giving a failed step `status="current"` opens two panels. The horizontal orientation and Flutter go by `active`.
  - Proposal: Base the condition on `index === active`.
- [x] **233.** A `fixed` bottom bar covers the end of the page, with no way to reserve space and no guidance (Accessibility · React · Medium)
  - Location: `bottom-navigation/PlBottomNavigation.tsx:140-144`, `PlFloatingBottomNavigation.tsx:155-159`
  - Problem: The default is `position="fixed"`, so the last 56px or more is always covered. When Tab reaches the footer links, focus hides under the bar (WCAG 2.4.11).
  - Proposal: Add a `padding-bottom` and `scroll-padding-bottom` example to the docs, and expose the bar height as a CSS variable.
  - Flag: Decision needed — whether to add a token has to be decided.
- [x] **234.** Nothing says that `safeArea` needs `viewport-fit=cover` to work (Docs · React · Low)
  - Location: `docs/en/components/navigation/bottom-navigation.md`, `floating-bottom-navigation.md:147`
  - Problem: Without this meta tag, `env(safe-area-inset-bottom)` is 0.
  - Proposal: Add the one meta line to the setup example.
- [x] **235.** The floating-bottom-navigation page's Accessibility list shows React-only sentences to Flutter readers too (Docs · Docs · Low)
  - Location: `docs/en/components/navigation/floating-bottom-navigation.md:167-169` (same in ko)
  - Problem: The sentences about `<nav>`, `aria-current` and the clipped box are outside `::: fw react`. React has no default `label` either, so "it has a name" is true only when the caller provides one.
  - Proposal: Move them into a React block, and add a Flutter block and guidance on `label`.

### 8. Surfaces

- [x] **236.** `PlSpoiler` and `PlWindowPane` lose focus when the pressed button is hidden (Accessibility · Both · Medium)
- [x] **237.** React `PlCarousel` scrolls the whole page every time it moves to another slide (Bug · React · High)
- [x] **238.** Carousel `autoPlay` has no stop control, and its pause is released too easily (Accessibility · Both · Medium)
  - Location: `PlCarousel.tsx:293`, `carousel/pl_carousel.dart:311`
  - Problem: There is no stop button, which WCAG 2.2.2 and the APG carousel pattern require. Hover and focus share one flag, so a mouse passing over it starts playback again even while keyboard focus is inside. Flutter does not stop on focus at all.
  - Proposal: Add a stop/play button, stay stopped once focus enters until playback is started explicitly, and separate the two flags.
  - Flag: Decision needed — the button placement and the restart rule have to be decided.
- [x] **239.** Carousel `autoPlay` does not advance when the parent redraws often (Bug · Both · Medium)
- [x] **240.** Carousel dot indicators have a hit area of 4–8px (Accessibility · Both · Medium)
- [x] **241.** No tests for carousel `autoPlay` (Test · React · Medium)
- [x] **242.** The carousel slide wrapper is keyed by index, so inserting a slide at the front remounts every slide (Bug · React · Low)
  - Location: `PlCarousel.tsx:329`
  - Problem: Contrary to the comment on line 164, the key is `key={slideIndex}`, so state such as a video's is reset.
  - Proposal: Use `slide.key ?? slideIndex`.
- [x] **243.** The carousel docs item "it needs somewhere to report the move" does not match React's behaviour (Docs · Docs · Low)
  - Location: `docs/en/components/surfaces/carousel.md:121` (same in ko)
  - Problem: React still moves, uncontrolled, without `onValueChange`.
  - Proposal: Move the item inside a `::: fw flutter` block.
- [x] **244.** In React `PlTabs`, a `PlTabPanel` inside a Fragment or a wrapper renders inside the tablist (Bug · React · Medium)
- [x] **245.** In an overflowing tab bar, the initially selected tab is off screen (Bug · Both · Low)
  - Location: `PlTabs.tsx:527`, `tabs/pl_tabs.dart:384`
  - Problem: On a narrow screen, if `defaultValue` is the 8th tab, the reader cannot see which tab is selected.
  - Proposal: On the first selection and on every change, scroll only the strip to that tab.
- [x] **246.** The tabs docs difference table wrongly says "every panel renders and only one is visible" (Docs · Docs · Low)
  - Location: `docs/en/components/surfaces/tabs.md:287` (same in ko)
  - Problem: React `PlTabPanel` defaults `keepMounted` to false, so closed panels are not rendered.
  - Proposal: Delete the row, or rewrite it as a difference in `keepMounted`.
- [x] **247.** With the defaults, closed content of React `PlAccordion` and `PlCollapsible` is not in the HTML (SEO · React · Medium)
  - Location: `accordion/PlAccordion.tsx:215`, `collapsible/PlCollapsible.tsx:155`
  - Problem: `hiddenUntilFound` and `keepMounted` are both false, so FAQ answers are missing from the server HTML and from find-in-page. The accordion docs cover this prop in a single Accessibility line.
  - Proposal: Consider changing the default of `hiddenUntilFound` to true. At the least, add an example section.
  - Flag: Decision needed, Breaking change — DOM size and behaviour change.
- [x] **248.** React `PlAccordion` headers are always `<h3>` (Accessibility · React · Medium)
  - Location: `PlAccordion.tsx:309`
  - Problem: An FAQ placed directly under an `h1` makes the heading structure skip `h2`. The APG requires a level that fits the page.
  - Proposal: Expose a `headingLevel` prop or the Header's `render`.
  - Flag: Decision needed — the shape of the API has to be chosen.
- [x] **249.** Flutter `PlAccordion` headers have no heading semantics (Accessibility · Flutter · Low)
  - Location: `accordion/pl_accordion.dart:420`
  - Problem: The headers do not appear in screen reader heading navigation.
  - Proposal: Add `header: true`.
- [x] **250.** When Flutter `PlAccordion` collapses, the content disappears at once and only the empty space shrinks (Bug · Flutter · Low)
  - Location: `pl_accordion.dart:446`
  - Problem: The moment `open` becomes false, the child is replaced with a `SizedBox`. React and `PlCollapsible` clip the content as they close.
  - Proposal: Use `PlassFold`, and keep the content until the animation ends.
- [x] **251.** The accordion `action` is described as "before the chevron", the opposite of where it is placed (Docs · Both · Low)
  - Location: `PlAccordion.tsx:113`, `pl_accordion.dart:110`, `docs/.vitepress/data/props.ts:826`
  - Problem: `action` is attached at the end, outside the trigger, so it sits after the chevron.
  - Proposal: Change the description to "after the chevron, at the end of the header".
- [x] **252.** Flutter `PlCollapsible` loses the panel State on every close, even with `keepMounted` (Bug · Flutter · Medium)
- [x] **253.** `PlCollapsible` lacks `PlAccordion`'s title wrap option and the space above the body (Bug · Both · Low)
  - Location: `PlCollapsible.tsx:223`, `:278`, `pl_collapsible.dart:281`, `:381`
  - Problem: The title is always cut to one line, and with the default header there is no space above the body. A comment in the same file (line 97) says the space is needed.
  - Proposal: Match the accordion, or leave a comment explaining why the two differ.
  - Flag: Decision needed — someone has to judge whether the difference is intended.
- [x] **254.** Flutter `PlCard` remounts all of its content when hover starts and ends (Bug · Flutter · Medium)
- [x] **255.** Flutter `PlCard` does not lift when only `interactive` is set (Bug · Flutter · Medium)
- [x] **256.** The whole-card link pattern that the React `PlCard` docs recommend creates nested interactive elements (Accessibility · React · Medium)
  - Location: `card/PlCard.tsx:73`, `docs/en/components/surfaces/card.md:161`
  - Problem: Using `render={<a>}` together with `footer={<PlButton>}` or `headerAction` produces `<a><button>`. An `<h2>` inside a `<button>` is invalid, and the accessible name becomes the whole text of the card.
  - Proposal: When a slot holds a control, document the pattern that stretches the title link with `::after`, or add a dedicated prop.
  - Flag: Decision needed
- [x] **257.** The React `PlCard` `interactive` lift still moves under reduced motion (Accessibility · React · Low)
  - Location: `PlCard.tsx:113`
  - Problem: `hover:-translate-y-0.5` has no `motion-reduce` handling. Flutter handles it.
  - Proposal: Use a `motion-reduce:` variant to set the transition to 0.
- [x] **258.** A finding in React `PlChatBubble` (Security · React · Medium)
- [x] **259.** The ko chat-bubble page was not updated after the Flutter port (Docs · Docs · Medium)
- [x] **260.** React `PlChatBubble` loads every preview image immediately (Performance · React · Low)
  - Location: `PlChatBubble.tsx:490`
  - Problem: In a long conversation with many link cards, it requests images that are off screen too.
  - Proposal: Add `loading="lazy"` and `decoding="async"`.
- [x] **261.** Flutter `PlChatBubble` typing dots stop under reduced motion (Bug · Flutter · Low)
  - Location: `chat_bubble/pl_chat_bubble.dart:486`
  - Problem: React only slows the dots down, because stopping them would reverse their meaning. Flutter calls `stop()`.
  - Proposal: Only lengthen the duration.
- [x] **262.** Flutter `PlSpoiler` resets the child's State when the cover is removed (Bug · Flutter · Medium)
- [x] **263.** The button that opens and closes `PlPill`'s `details` has no expanded state (Accessibility · Both · Medium)
- [x] **264.** In Flutter `PlPill`, pressing the expanded `details` or the `endIcon` also calls `onPressed` (Bug · Flutter · Medium)
- [x] **265.** React `PlPill` recreates its `ResizeObserver` on every render (Performance · React · Low)
  - Location: `PlPill.tsx:268`
  - Problem: Inline JSX `details` is an effect dependency. For a pill that updates every second, disconnect, observe and setState repeat every second.
  - Proposal: Change the dependency to `hasContent(details)`, and take the first measurement in a layout effect.
- [x] **266.** The `list-none` `<ol>` in React `PlHowToSteps` has no `role="list"` (Accessibility · React · Medium)
- [x] **267.** A React `PlHoverCard` comment describes an `aria-describedby` link that does not exist (Optimisation · React · Low)
  - Location: `hover-card/PlHoverCard.tsx:41`, `:153`
  - Problem: Base UI `PreviewCard` does not add describedby.
  - Proposal: Make the comment match the actual behaviour.
- [x] **268.** When a controlled Flutter `PlWindowPane` passes `offset` back, the window runs away faster than the pointer (Bug · Flutter · High)
- [x] **269.** The React props table for `PlWindowPane` is missing the state callbacks and label props (Docs · Docs · Medium)
- [x] **270.** Moving a `PlWindowPane` has no keyboard or single-pointer alternative (Accessibility · Both · Low)
  - Location: `PlWindowPane.tsx:679`, `pl_window_pane.dart:513`
  - Problem: Resizing works with the arrow keys, but a `draggable` pane moves only by dragging (WCAG 2.5.7).
  - Proposal: Add a focusable move handle, or document how to build an alternative with `offset` control.
  - Flag: Decision needed — how much a decorative frame should provide has to be decided.
- [x] **271.** Minimising a Flutter `PlWindowPane` removes the body from the tree (Bug · Flutter · Low)
- [x] **272.** A `PlWindowPane` comment gives the wrong number of OSes (Optimisation · React · Low)

### 9. Transitions

- [x] **273.** With `trigger="hover"`, the caller's pointer and focus handlers are lost, or the hover trigger stops working (Bug · React · Medium)
- [x] **274.** Restarting an animation also rewinds other `PlAnimate*` components nested inside it (Bug · React · Medium)
- [x] **275.** The JS-driven Counter, Scramble and Typing do not replay from the second hover with `trigger="hover"` (Bug · React · Medium)
- [x] **276.** Counter and Scramble start over instead of continuing when `paused` is released (Bug · React · Medium)
- [x] **277.** Flutter `trigger: hover` adds an unnamed Tab stop (Accessibility · Flutter · Medium)
- [x] **278.** Flutter `trigger: visible` only watches the nearest `Scrollable` (Bug · Flutter · Medium)
- [x] **279.** The `PlAnimateHeadline` timer is reset on every parent render, so the line may never advance (Bug · Both · Medium)
- [x] **280.** No guidance that an effect moving for more than 5 seconds needs a way to stop it (Accessibility · Docs · Medium)
- [x] **281.** 20 files in the transitions docs have unpaired code fences that render empty code blocks (Docs · Docs · Medium)
- [x] **282.** Under reduced motion, an animation falls to its start state instead of its end state (Bug · Both · Low)
  - Location: `packages/react/src/styles.css:2424-2429`, `internal/animate.dart:527-529`
  - Problem: React `<PlAnimateRotate from={0} to={90}>` shows 0deg, and Flutter shows 90°. With `mode="out"`, the element does not disappear in either package. In React, `animationend` never fires, so a caller that unmounts on that event gets stuck.
  - Proposal: Decide whether to apply the end frame statically under reduced motion or to keep the current behaviour.
  - Flag: Decision needed — the docs state that an exit is "not a way to hide", so there are two possible directions.
- [x] **283.** The sr-only copy in text effects makes copied text appear twice (Accessibility · React · Low)
- [x] **284.** Default values and rows in the transitions props tables do not match the code (Docs · Docs · Low)
- [x] **285.** With a `PlAnimateMarquee` `speed` of 0 or less, Flutter throws and React renders a stopped strip (Bug · Both · Low)
- [x] **286.** The transitions bugs above have no regression tests (Test · Both · Low) — no longer reproduces
- [x] **287.** Tab reaches links and buttons inside the hidden copies of `PlAnimateMarquee` (Accessibility · Both · Medium)
- [x] **288.** Under reduced motion there is no way to see `PlAnimateMarquee` items outside the box, but the docs say they can be reached (Accessibility · Both · Medium)
- [x] **289.** `PlAnimateMarquee` forces a layout and reconnects its `ResizeObserver` on every parent render (Performance · React · Low)
- [x] **290.** `PlAnimateSplit` with `effect="slide"` does not move, and `zoom` is the same as `grow` (Bug · React · Medium)
- [x] **291.** `PlAnimateSplit` `by="character"` breaks lines in the middle of a word (Bug · Both · Medium)
- [x] **292.** Flutter character splitting and scramble cut text by UTF-16 code units, which breaks emoji (Bug · Flutter · Medium)
- [x] **293.** `PlAnimateTyping` drops the text of elements in its children, but the docs say the opposite (Bug · React · Medium)
- [x] **294.** `PlAnimateTyping` grows while typing and pushes the content around it, but the docs say there is no reflow (Bug · React · Medium)
- [x] **295.** Flutter `PlAnimateTyping` throws a debug exception when it disposes the caret under reduced motion (Bug · Flutter · Medium)
- [x] **296.** `PlAnimateTyping` does not retype a new string that has the same number of characters (Bug · React · Low)
- [x] **297.** `PlAnimateHeadline`'s `repeat` has no effect but is documented as a setting shared by both packages (Optimisation · Both · Low)
  - Location: `PlAnimateHeadline.tsx:71`, `:96`, `docs/.vitepress/data/props.ts:1241`
  - Problem: Only `loop` decides whether the animation repeats.
  - Proposal: Remove `repeat` with `Omit` and drop it from the table.
  - Flag: Breaking change — it removes a public prop.
- [x] **298.** `PlAnimateSlide` with `trigger="visible"` does not start inside an `overflow: hidden` box (Bug · React · Medium) — the parent observer measures the resting box, option C
- [x] **299.** `PlAnimateLighting` ignores `easing` (Bug · React · Low)
- [x] **300.** A hover or `play` restart does not rewind `PlAnimateLighting` when `repeat` is finite (Bug · React · Low)
- [x] **301.** `PlAnimateCounter` creates a new `Intl.NumberFormat` on every frame when given an inline `format` (Performance · React · Low)
- [x] **302.** `PlAnimateScramble` mixes halves of surrogate pairs into its noise, so broken glyphs flicker (Bug · React · Low) — closed by the grapheme cut item 298's batch brought to `PlAnimateSplit` and `PlAnimateScramble`
- [x] **303.** `PlAnimateFloat`'s string `distance` does not work with `calc()`, `var()` or negative values (Bug · React · Low)

### 10. Docs, repository and site

- [x] **304.** The root `README.md` component list is missing 17 components (Docs · Docs · Medium)
- [x] **305.** The `README.md` Hooks table does not match the hooks that are actually exported (Docs · Docs · Medium)
- [x] **306.** Following the instruction to "run `npm run flutter:demos` again" does not rebuild the Flutter previews (Docs · Docs · Medium) — the `CLAUDE.md` half is done in the working tree, which is gitignored
- [x] **307.** `packages/react/README.md` gives the wrong component count and the wrong runtime dependency count (Docs · Docs · Medium)
- [x] **308.** The `packages/react/README.md` component list has only 75 components and no Charts group (Docs · Docs · Medium) — no longer reproduces
  - Location: `packages/react/README.md:117-147`
  - Problem: 55 components are missing. The `CLAUDE.md` checklist names only the root README list as something to update, so the two lists keep drifting apart.
  - Proposal: Match it to the root list and add it to the checklist, or remove the list and link to the documentation site instead.
  - Flag: Decision needed
- [x] **309.** The second example in `packages/flutter/README.md` does not compile with only the import above it (Docs · Docs · Low)
- [x] **310.** The `CONTRIBUTING.md` commit rules lack the codebase prefix and "one commit per component" (Docs · Docs · Low)
- [x] **311.** The list in `CLAUDE.md` of places that state the component count is incomplete (Docs · Docs · Medium) — `CLAUDE.md` is gitignored, so the change is local
- [x] **312.** `CLAUDE.md` gives the number of `internal/` modules as 40, but it is 41 (Docs · Docs · Low)
  - Location: `CLAUDE.md:60`
  - Problem: `image.ts` was added, which makes 41.
  - Proposal: Change it to 41.
- [x] **313.** The `order:` instruction in the `CLAUDE.md` checklist has no effect on component pages (Docs · Docs · Low)
  - Location: `CLAUDE.md:136`, `docs/.vitepress/config.ts:739-762`
  - Problem: `arrangeSidebar` sorts the pages inside a component group by name, so `order` is used only in Design. The "a clash is silent" warning belongs to a step with nothing to do. During the audit, this sentence also led to a number clash in the inputs group being reported as a defect.
  - Proposal: Remove the `order:` instruction from step 9, or state that pages inside a group are sorted by name.
- [x] **314.** The claim in `CLAUDE.md` that "CI requires both lockfiles through `npm ci`" does not match the documentation workflow (Docs · Docs · Low)
  - Location: `CLAUDE.md:493`, `.github/workflows/publish-documentation.yml`
  - Problem: The documentation workflow caches `node_modules` and runs `npm install` only when there is no cache, so it does not fail when a lockfile is out of sync.
  - Proposal: Make the sentence match what actually happens, or change the workflow to `npm ci`.
- [x] **315.** `CLAUDE.md` and `llms.txt` describe the slider rail and the switch track as `--plass-well` (Docs · Docs · Low)
  - Location: `CLAUDE.md:175`, `docs/public/llms.txt:136`, `:137`
  - Problem: Both components have already moved to `--plass-track` (`PlSlider.tsx:100-118`, `PlSwitch.tsx:99-160`), and the switch thumb is white, not `--plass-surface`. Only the segmented button still uses `--plass-well`.
  - Proposal: Update the three places to match the current implementation.
- [x] **316.** Three claims in the vNext Documentation entries of the React `CHANGELOG.md` are false (Docs · Docs · Low)
  - Location: `packages/react/CHANGELOG.md:67`, `:69`, `:71`
  - Problem: The rule it cites as "the heading form that CONTRIBUTING.md requires" is not in CONTRIBUTING. "133 previews" is actually 130. It says em dashes remain only in table cells, but 53 lines outside tables in `docs/en` still have them.
  - Proposal: Remove the sentence that cites the source, and make the number and the em dash sentence match the facts.
- [x] **317.** The Flutter getting-started list of components that need an `Overlay` is incomplete, and the provider placement example throws when followed (Docs · Flutter · Medium)
- [x] **318.** The browser support summary in getting started does not match the browser support page (Docs · Docs · Low)
- [x] **319.** The React-only `usePlassDefaults` example in `defaults.md` is also shown to Flutter readers (Docs · Docs · Low)
- [x] **320.** The sentence in `locales.md` that explains the difference in Flutter label counts says the opposite of what it means (Docs · Docs · Low)
- [x] **321.** `'--plass-blur': '10px'` in the `color.md` example removes the glass blur (Docs · Docs · Medium)
- [x] **322.** The base colour `#3558ef` is not in any token, and the radius ratio of 29% does not match the calculation (Docs · Docs · Low)
- [x] **323.** "Adding a colour family takes two edits" does not match the actual work (Docs · Docs · Low)
- [x] **324.** "The library ships no translations" in `rtl.md` contradicts the translation guide (Docs · Docs · Medium)
- [x] **325.** React-only content appears in Flutter mode as empty sections or "No Flutter version" frames (Docs · Docs · Low)
- [x] **326.** The `PlStack` named in the landing example's description is not in the code (Docs · Docs · Low)
- [x] **327.** The component list page gives the preview count as 133, but there are 130 (Docs · Docs · Low)
- [x] **328.** Replacing em dashes with full stops left broken sentences (Docs · Docs · Low)
- [x] **329.** On ko pages, particles after italic text appear with a space before them (Docs · Docs · Low)
- [x] **330.** "훑기" on the ko colour page does not make sense, and colour names are spelled inconsistently (Docs · Docs · Low)
- [x] **331.** The group structure of `llms.txt` is wrong (Docs · Site · Medium)
- [x] **332.** `llms.txt` has no links to Breakpoints or the changelog, and the description on line 21 does not match the actual layout (Docs · Site · Low)
- [x] **333.** At 190KB, `llms.txt` is closer to the full documentation than to a summary list (Optimisation · Site · Low)
  - Location: `docs/public/llms.txt`
  - Problem: The description on a single link line has a median length of about 1,100 characters and a maximum of about 4,500. The `llms.txt` format is a short summary and a list of links.
  - Proposal: Split it into a short `llms.txt` and an `llms-full.txt` that holds the current content.
  - Flag: Decision needed
- [x] **334.** Several component pages have design rationale sections that are not part of the page skeleton (Docs · Docs · Low)
  - Location: `docs/en/components/feedback/drawer.md:79`, `:109`, `confirm.md:68`, `inputs/date-picker.md:66`, `:107`, `inputs/color-picker.md:48`, `inputs/floating-action-button.md:42`, `:66`, `:72`, `:96`, `inputs/fieldset.md:123`, `transitions/animate-split.md` (no Examples) (same in ko)
  - Problem: The page rules in `CLAUDE.md` set the order as Props → Examples → Accessibility and say that design rationale does not belong on the page. animate-split has only prose sections and one hero demo instead of `## Examples`.
  - Proposal: Keep only the necessary facts under Props, and move the rationale to the design documents or delete it. For animate-split, move the `by`, `effect` and `stagger` examples into Examples, each with a demo.
  - Flag: Decision needed — decide whether to move the rationale or delete it.
- [x] **335.** The changelog page's description is an unrelated paragraph from the middle of the body (SEO · Site · Medium)
- [x] **336.** The site changelog covers only React, and `/ko/changelog` carries the English original marked as `ko-KR` (SEO · Site · Low)
  - Location: `docs/scripts/copy-changelog.mjs:27`
  - Problem: The site covers both frameworks but publishes only the React changelog, and the same English text is indexed under two languages.
  - Proposal: Publish the Flutter changelog as well, or limit the title to React. For the ko copy, point its canonical at the English page, or do not generate it.
  - Flag: Decision needed
- [x] **337.** The generated `robots.txt` does not treat AI training crawlers separately (SEO · Site · Low)
  - Location: `docs/.vitepress/config.ts:506-511`
  - Problem: It writes only `User-agent: *` and `Allow: /`. The shared SEO rules say to block `GPTBot`, `ClaudeBot` and `Google-Extended` by default.
  - Proposal: Add blocks for those crawlers.
  - Flag: Decision needed — the maintainer decides whether the open source documentation may be used for training.
- [x] **338.** Changing the preview theme reloads the Flutter iframe (Performance · Site · Medium)
- [x] **339.** Every page loads the props data for all 130 components (Performance · Site · Medium)
- [x] **340.** Pages with no preview still download ReactDOM (Performance · Site · Low)
- [x] **341.** The framework selection group is named "Language"/"언어" (Accessibility · Site · Low)
- [x] **342.** The required marker in the props table carries its meaning only in the `title` attribute (Accessibility · Site · Low)
- [x] **343.** All Flutter iframes on a page use the same `title` (Accessibility · Site · Low)
- [x] **344.** The home hero logo's `alt` repeats the heading right after it, and the file is larger than its display size (Accessibility · Site · Low)
- [x] **345.** Values in the site config and CSS comments do not match the facts (Docs · Site · Low)

### 11. Added after the audit

Findings raised in a batch report and approved as new items. Their line numbers are from the commit that raised them.

- [x] **346.** The Flutter cross marker is two overlapping rectangles, so its ring strokes a hatch through the middle (Bug · Flutter · Low)
- [x] **347.** `timeScale` with a `min` keeps the time of day in React and sets it to midnight in Flutter (Bug · Both · Low) — no longer reproduces
- [x] **348.** A time span of zero stacks every mark on the origin in Flutter and pushes them off the plot in React (Bug · Both · Low)
- [x] **349.** A chart's default number format is `48.3K` in React and `48300` in Flutter (Bug · Flutter · Low)
- [x] **350.** The Flutter scatter marker ring is twice as thick as React's (Bug · Flutter · Low)
- [x] **351.** A treemap with equal values can colour its tiles differently in the two packages (Bug · Both · Low)
- [x] **352.** A time axis under a minute before 1970 starts a minute apart in the two packages (Bug · Both · Low)
- [x] **353.** `stackToFull` is written twice on the Dart side, and `categoryToNumber` is never used (Optimisation · Flutter · Low)
- [x] **354.** The dismiss × on alerts, toasts, modals, drawers, popovers, tours and the file picker may be under the 24px target size (Accessibility · Both · Low)
  - Location: `packages/flutter/lib/src/internal/dismiss.dart` (`PlassDismissButton`) and the matching React close buttons
  - Problem: Drawn at about 16px, and not measured. Item 99 widened the × on chips and picker triggers only.
  - Proposal: Measure it in both packages, and widen the hit area of the ones under 24px as item 99 did.
- [x] **355.** `test/package/use-client.test.ts` fails on Windows in CI (Test · React · Medium)
  - Location: `packages/react/test/package/use-client.test.ts:85`
  - Problem: It reads a file's first line with `split('\n')`, and a Windows checkout ended its lines in CRLF, so 133 of 280 cases failed in the Chromium and WebKit jobs on Windows.
  - Proposal: Check files out with LF through a `.gitattributes`.
- [x] **356.** The `PlCarousel` `autoPlay` tests time out in CI Chromium (Test · React · Medium)
  - Location: `packages/react/test/components/carousel/PlCarousel.test.tsx:187`, `:236`
  - Problem: "moves the strip without scrolling the page while it plays" failed on Ubuntu, Windows and macOS, and "holds still while the pointer is over it" on macOS, in run `34921614559`. Locally both pass in Chromium.
  - Proposal: Find what the tests wait on that a slow runner misses, and wait for the state rather than for time.
- [x] **357.** `PlAnimateCounter` "pausing" fails in CI Chromium on macOS (Test · React · Medium)
  - Location: `packages/react/test/components/animate-counter/PlAnimateCounter.test.tsx`, the `pausing` group
  - Problem: "waits out only what was left of `delay` when it is let go" failed in run `34921614559` and passes locally.
  - Proposal: The same as item 356.
- [x] **358.** The hover tests in `test/internal/animate.test.tsx` fail in Firefox every time, and in Chromium now and then (Test · React · Medium)
  - Location: `packages/react/test/internal/animate.test.tsx`, "the hover trigger beside a caller's own handlers" and "a second hover"
  - Problem: The caller's `onPointerEnter` is called twice, a real `pointerover` counted beside the dispatched one, and `PlAnimateMarquee` starts running before the hover. In Firefox all seventeen and "plays PlAnimateCounter again" fail; in Chromium they failed in two full runs and passed on a rerun.
  - Proposal: Park the pointer before the hover tests with `commands.parkPointer()`, and fix whatever Firefox still fails after that.
- [x] **359.** The `PlSidebar` resize handle drag test fails in Firefox (Test · React · Medium)
  - Location: `packages/react/test/components/sidebar/PlSidebar.test.tsx`, "marks itself, takes the selection and reports every step while it is dragged"
  - Problem: The step callback is never called. It fails in every CI Firefox job and locally.
  - Proposal: Find whether the drag the test dispatches or `internal/drag.ts` is what Firefox does not answer, and fix that one.
- [x] **360.** The `PlScrollZone` selection test fails in Firefox (Test · React · Medium)
  - Location: `packages/react/test/components/scroll-zone/PlScrollZone.test.tsx`, "takes the document selection at the threshold and gives it back at the end"
  - Problem: `data-dragging` never becomes `true`. It fails locally; CI stopped at an earlier shard.
  - Proposal: The same as item 359.
- [x] **361.** Two `PlTimePicker` rendering tests fail in Firefox (Test · React · Medium)
  - Location: `packages/react/test/components/time-picker/PlTimePicker.test.tsx`, "writes the chosen time the way the locale does" and "reflects a changed value on re-render"
  - Problem: Firefox writes half past nine in `en-GB` as `09:30` where Chromium writes `9:30`, and the tests expected Chromium's. They fail in every CI Firefox job and locally.
  - Proposal: Find whether the component or the test is wrong in Firefox, and fix that one.
- [x] **362.** `PlImage` "starts again when the src changes" fails in Firefox (Test · React · Medium)
  - Location: `packages/react/test/components/image/PlImage.test.tsx:609`
  - Problem: `onStatusChange` reports `loaded` twice before `error` when the whole file runs, and passes alone. It fails with batch 9's sources too.
  - Proposal: Find whether a second `loaded` is a real report a user would get, and fix the component or the test accordingly.
- [x] **363.** `PlScatterChart` "renders again only when the nearest mark changes" fails in CI WebKit on Ubuntu (Test · React · Medium)
  - Location: `packages/react/test/components/scatter-chart/PlScatterChart.test.tsx`
  - Problem: It failed in run `34921614559`; it passes locally on macOS.
  - Proposal: Read the job log, and fix the test's assumption about how often WebKit renders or the extra render.
- [x] **364.** The `PlPill` press light test is half a pixel out in WebKit (Test · React · Medium)
  - Location: `packages/react/test/components/pill/PlPill.test.tsx:96`
  - Problem: `toBeCloseTo` allows 0.5 and WebKit is 0.586 off, in CI on macOS and locally.
  - Proposal: Compare within a pixel, or measure the way WebKit rounds.
- [x] **365.** The `PlWindowPane` traffic light focus test fails in WebKit (Test · React · Low)
  - Location: `packages/react/test/styles/window-pane.test.tsx`, "shows the mark of the light the keyboard has reached, and only that one"
  - Problem: The button never holds the focus in WebKit locally, so the active element stays `<body>`. CI stopped at an earlier shard.
  - Proposal: Find how WebKit hands a button the focus from the keyboard, and reach it the way a WebKit user does.
- [x] **366.** Number formatting tests fail in a browser whose locale is not English (Test · React · Low)
  - Location: `packages/react/vitest.config.ts`; `PlAnimateCounter` "folds a big number when it is asked to", `PlLineChart` "passes format through to the table", `PlProgressLinear` "formats the value when told how"
  - Problem: WebKit takes the machine's locale, so on a Korean system a compact number reads `120만` where the tests expect `1.2M`. CI runs in English and does not see it.
  - Proposal: Give every browser the `en-US` locale in the test configuration.
- [x] **367.** The forced-colours `PlToggle` case in `test/styles/standalone.test.tsx` fails in CI on Windows Chromium (Test · React · Medium)
  - Location: `packages/react/test/styles/standalone.test.tsx:628`, `packages/react/src/components/toggle/PlToggle.tsx`
  - Problem: "fills a chosen PlToggle with the highlight, and nothing else" finds nothing filled with `Highlight` in run `34930148927`, while every other forced-colours case passes there and this one passes on Ubuntu and macOS. Windows never reached this shard before items 355 to 366.
  - Proposal: Find whether a pressed toggle shows its state in Windows high contrast, and fix the component or the test accordingly.
- [x] **368.** The `PlAnimateScramble` delay test fails in CI on macOS Chromium (Test · React · Medium)
  - Location: `packages/react/test/components/animate-scramble/PlAnimateScramble.test.tsx:156`
  - Problem: "waits out only what was left of `delay` when it is let go" measures wall time and read 601.7ms against 600 in run `34930148927`, the failure item 357 fixed for `PlAnimateCounter`.
  - Proposal: Draw the frames from a clock the test holds, as item 357 does, and share that helper instead of copying it a third time.
- [x] **369.** The `PlAnimateMarquee` tab stop test fails in CI WebKit (Test · React · Medium)
  - Location: `packages/react/test/components/animate-marquee/PlAnimateMarquee.test.tsx:229`, and every test that calls `commands.emulateMedia`
  - Problem: "is not one while the strip moves, since there is nothing to scroll to" found a `tabindex` in run `34932100843` on Ubuntu and macOS WebKit, and failed two runs in three locally. Right after `emulateMedia` switches reduced motion off, WebKit still reports the old `matches` on a `MediaQueryList` made before the call until its next frame, and the library reads such a list while rendering.
  - Proposal: Emulate media through one helper that waits until the page's existing lists agree with a fresh one.
- [x] **370.** A caller's pointer and focus handlers turn off the `PlCarousel` autoplay pause (Bug · React · Low)
  - Location: `packages/react/src/components/carousel/PlCarousel.tsx`
  - Problem: `{...props}` is spread after the component's own `onPointerEnter`, `onPointerLeave`, `onFocus` and `onBlur`, so a caller who passes one of them replaces the pause, and the strip keeps moving under the pointer or with the focus inside.
  - Proposal: Merge the caller's handlers with the pause, as `internal/animate.ts` does with `mergeProps`.

- [x] **371.** Inserting an item at the start of a Flutter `PlTimeline` hands a step's state to the step after it (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/timeline/pl_timeline.dart` (`PlTimeline.build`, `PlTimelineItem`)
  - Problem: The steps are built by position and `PlTimelineItem` has no key, so a stateful `child` takes the state of the step that was in its place, and a key on the child cannot fix it from outside.
  - Proposal: Add `final Key? key` to `PlTimelineItem` and key each step with it.
- [x] **372.** A floating React `PlBackTop` does not float (Bug · React · Medium)

- [x] **373.** A React `PlCarousel` given a `defaultValue` or `value` other than 0 shows the first slide (Bug · React · Medium)
  - Location: `packages/react/src/components/carousel/PlCarousel.tsx` (the effect that scrolls to the current slide)
  - Problem: The effect skips its first run, so the dots mark the chosen slide while the strip still shows slide 1.
  - Proposal: Place the strip at the current slide on mount, without an animation.

- [x] **374.** Flutter `PlTabs` does not bring the tab the arrow keys move to into view (Accessibility · Flutter · Medium)
  - Location: `packages/flutter/lib/src/components/tabs/pl_tabs.dart`
  - Problem: On a 320px bar, six presses of → leave the chosen and focused tab at about x 1148 while the bar ends at 560. React's Base UI scrolls it into view.
  - Proposal: Reveal the tab the keys move to, with the edge-fade offset batch 16 added.

- [x] **375.** Flutter `PlMenu` does not hand the focus back to its trigger when it closes (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/menu/pl_menu.dart`
  - Problem: The focus stays on the menu's own node, so a `PlButton` trigger loses its focus ring. `PlMenubar` now does it for its own words.
  - Proposal: Return the focus to the trigger on close, as Base UI does.

- [x] **376.** Four Flutter folds never dispose their `CurvedAnimation` (Bug · Flutter · Low)
  - Location: `pl_accordion.dart`, `pl_collapsible.dart`, `pl_pill.dart`, `pl_tree.dart`
  - Problem: The `CurvedAnimation` each builds over its controller is not disposed, so its listener outlives the state.
  - Proposal: Dispose it in `dispose`.

- [x] **377.** A Flutter `PlPill` that cannot be pressed still takes taps (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/pill/pl_pill.dart`
  - Problem: The tap recogniser stays when the pill is not interactive, so a tap on it never reaches what is around it.
  - Proposal: Use `PlassInteractive`'s `pressable` switch, as `PlCard` does since batch 16.

- [x] **378.** Flutter carousel dots take no keyboard focus (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/carousel/pl_carousel.dart`
  - Problem: The dots can be pressed but not reached with Tab.
  - Proposal: Make each dot a focusable control named after its slide, as the React dots are.

- [x] **379.** Flutter brightness filters build their content again when a hover or a press starts or ends (Performance · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/surface.dart` (`plassStateFilter`), `packages/flutter/lib/src/components/button/pl_button.dart`
  - Problem: They return the child at a brightness of 1 and a `ColorFiltered` around it otherwise, so the tree above the content changes shape.
  - Proposal: Keep the `ColorFiltered` in the tree, with an identity matrix at rest.

- [x] **380.** A Flutter gallery builds a tile again when it moves to another lane, and a quilted board reads out of order (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/gallery/pl_gallery.dart`, `packages/flutter/lib/src/internal/gallery.dart`
  - Problem: With one `Column` per lane, a tile that changes lanes when the number of lanes changes is built again and loses its picture's state and its focus. A dense quilted layout lets a later tile fill an earlier gap, so it is read in the order it is drawn.
  - Proposal: Lay the tiles out in one list, as React did in item 93, and give quilted tiles their place in the list as a sort key.

- [x] **381.** The `PlDataTable` scroll box cannot be scrolled from the keyboard (Accessibility · React · Low)
  - Location: `packages/react/src/components/data-table/PlDataTable.tsx` (about line 657)
  - Problem: It is `PlTable`'s problem before item 118.
  - Proposal: Make the box a tab stop while it overflows, as item 118 did.

- [x] **382.** React `PlBackTop` clears only the bottom safe area (Accessibility · React · Low)
  - Location: `packages/react/src/components/back-top/PlBackTop.tsx`
  - Problem: It adds `env(safe-area-inset-bottom)` but not the inline end, so a landscape cutout can cover it. The floating action button adds both since item 168.
  - Proposal: Add the inline-end inset as the floating action button does.

- [x] **383.** Several Flutter chart numbers skip the shared number writer (Bug · Flutter · Low)
  - Location: `PlLineChart`'s value labels (`_write`), the scatter, pie, heatmap, gauge and sparkline in `packages/flutter/lib/src/components/`
  - Problem: They neither compact nor group, where React writes them through `writeChartValue`, and a compact mantissa of five digits or more is `1,500,000T` in React and `1500000T` here.
  - Proposal: Write them all through `compactNumber`, and group the mantissa.

- [x] **384.** A Flutter `nearest` card has no category and a timeline card has no row (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/chart_frame.dart`
  - Problem: The `nearest` card's title is the series name alone, while the live region reads the category; the timeline card has no row name, though the docs say it has.
  - Proposal: Write both cards as React does.

- [x] **385.** Flutter `PlTransfer` draws an empty heading for `sourceLabel: ''` (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/transfer/pl_transfer.dart`
  - Problem: React falls back to the pack's name for the list; Flutter draws nothing.
  - Proposal: Fall back as React does.

- [x] **386.** The Flutter time grid's live region may be dropped from the semantics tree (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/calendar.dart` (about line 1350)
  - Problem: It is a 0×0 box, and batch 16 found a zero-sized semantics node dropped in the charts. Not confirmed for the calendar.
  - Proposal: Check it, and give it a 1px box as the charts' readout has.

- [x] **387.** Toasts share the page's backdrop key under an app's `BackdropGroup` (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/toast/pl_toast.dart`
  - Problem: The toast stack opens no group of its own, as the other overlays do since batch 16, so a toast reads the backdrop where the app's group began.
  - Proposal: Open a group for the stack, as the portals do.

- [x] **388.** `PlColorPicker`'s description spells out the shared classes (Optimisation · React · Low)
  - Location: `packages/react/src/components/color-picker/PlColorPicker.tsx` (about line 841)
  - Problem: It writes the list `fieldDescriptionClasses` holds, less `m-0`.
  - Proposal: Use `fieldDescriptionClasses`.

- [x] **389.** Korean bold that does not render, and particles a space away from it (Docs · Docs · Low)
  - Location: `docs/ko`: `components/display/tree.md:60`, `components/inputs/form.md:73`, `components/inputs/radio-group.md:87`, `components/inputs/segmented-button.md:71`, `components/inputs/tree-select.md:75` and `:77`, `components/surfaces/carousel.md:69`, `components/transitions/animate-rotate.md:54`, `design/rtl.md:84`, `:88` and `:104`; bold followed by a spaced particle on the progress box, time picker, date picker, date range picker, date time picker, segmented button and breakpoints pages; `components/inputs/combobox.md:86` (`_검색_ 하는`)
  - Problem: A closing `**` after punctuation or a backtick with a particle straight after it is printed rather than read, and a particle a space away reads as a word of its own.
  - Proposal: Rewrite each so the marker closes, as item 329 and batch 16 did for `_`; `segmented-button`'s `**"…"** 입니다` needs a different shape.

- [x] **390.** The date picker's keyboard list is in the React block only (Docs · Docs · Low)
  - Location: `docs/en/components/inputs/date-picker.md` and the Korean twin
  - Problem: The arrows, Home and End, and PageUp and PageDown work the same in both builds now.
  - Proposal: Move the list into the shared text.

- [ ] **391.** A `PlNavigationMenu` popup jumps to its new size in one frame (Bug · React · Low)
  - Location: `packages/react/src/components/navigation-menu/PlNavigationMenu.tsx`
  - Problem: The popup never reads the `--popup-width` and `--popup-height` Base UI sets while the panel changes, so its size goes from `auto` to `auto` and there is nothing to ease.
  - Proposal: Batch 17 read them on the popup and set them back to `auto` when a controlled `value` changed. That eased the resize on this machine, but on CI's runners a menu whose page holds the value stopped about 50px off the next panel's size and an uncontrolled one did not ease at all, which is worse than the jump, so it was reverted. A fix has to hold when frames are slow: ease the positioner as Base UI's own example does, which is item 402's problem too, and see it pass on CI before the item is ticked.

- [ ] **392.** A Flutter `PlButton` builds its content again when the focus ring, `loading`, `readOnly` or `disabled` changes (Performance · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/button/pl_button.dart` (the focus ring's `CustomPaint`, the two glow layers, the `Opacity`), `packages/flutter/lib/src/internal/surface.dart` (`plassStateFilter`)
  - Problem: Each of these wrappers comes and goes with its state, so the tree above the content changes shape and the label and anything stateful in it is built again.
  - Proposal: Keep the wrappers in the tree and switch their settings, as item 379 did for the brightness.

- [ ] **393.** A Flutter gallery's grid and justified tiles, and a tile's or a step's focus ring, build their content again (Performance · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/gallery/pl_gallery.dart`, `packages/flutter/lib/src/components/stepper/pl_stepper.dart`
  - Problem: A grid lays out one `Row` per row and a justified board breaks its rows again when the width changes, so a tile that moves rows is built again; a tile's and a step's focus ring wrap the content only while focused, which builds it again and reloads a tile's picture.
  - Proposal: Keep the tiles in one list, as item 380 did for the masonry, and keep the ring's `CustomPaint` in the tree.

- [ ] **394.** The Flutter toast stack builds toasts again when one above leaves, fades linearly and repeats a comment (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/toast/pl_toast.dart`
  - Problem: The `ValueKey` is on `_Toast`, one level below the `Column`'s own children, so the toasts below a leaving one are built again; a toast's fade is linear while the overlays ease on `motionEase` since batch 17; the "Newest nearest the edge" comment is written twice.
  - Proposal: Key the `Column`'s children, run the fade on `motionEase`, and drop the second comment.

- [ ] **395.** Flutter surfaces painted with a plain `DecoratedBox` open no `BackdropGroup` (Bug · Flutter · Low)
  - Location: components that paint a fill without `PlassSurfaceBox`
  - Problem: Batch 17's rule that every surface painting a fill opens a group covers `PlassSurfaceBox` and `PlButton` only, so a glass control on another filled surface still blurs the page behind it under an app's group.
  - Proposal: Find those surfaces and give them the same rule, or draw them through `PlassSurfaceBox`.

- [ ] **396.** A Flutter anchored popup swallows presses on its anchor while it is open (Bug · Flutter · Medium)
  - Location: `packages/flutter/lib/src/internal/anchored.dart` (`_PressShield`), `packages/flutter/lib/src/components/combobox/pl_combobox.dart`
  - Problem: While the list is open, a press on the anchor is taken and closes it, so the × on a `multiple` combobox's chip does not remove the chip and a press to move the caret closes the list; a read-only combobox cannot be opened to look through. Base UI leaves the input group out of the outside press and opens a read-only combobox.
  - Proposal: Let presses on the anchor reach it, and let a read-only combobox open its list.

- [ ] **397.** A Flutter `PlWindowPane` neither fills its box when maximized nor rolls up when minimized (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/window_pane/pl_window_pane.dart`
  - Problem: `maximized` only squares the corners and relabels the button, and the bar can still be dragged; a minimized pane keeps its `height`.
  - Proposal: Fill the container and stop the drag while maximized, as React does, and roll a minimized pane up to its title bar.

- [ ] **398.** A Flutter table cannot be scrolled from the keyboard (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/table.dart` (`PlassGrid`, about line 418)
  - Problem: `PlTable` and `PlDataTable` scroll in a plain `SingleChildScrollView`, so a table held by `maxHeight`, or wider than its box, has no stop a keyboard can scroll.
  - Proposal: Scroll it through `PlassKeyboardScroll`, a stop while it overflows, named as the React one is.

- [ ] **399.** React `PlHeatmapChart` takes `Escape` whatever it holds (Bug · React · Low)
  - Location: `packages/react/src/components/heatmap-chart/PlHeatmapChart.tsx` (about line 509)
  - Problem: Its own `onKeyDown` answers `Escape` unconditionally, outside the chart frame batch 17 changed.
  - Proposal: Take it only while there is a readout to clear, as the frame does.

- [ ] **400.** A React carousel mounted at no width opens on the first slide (Bug · React · Low)
  - Location: `packages/react/src/components/carousel/PlCarousel.tsx`
  - Problem: Inside a hidden tab the track has no width when item 373's placement runs, so the first slide shows when it appears, whatever `defaultValue` says.
  - Proposal: Place the strip when the track first has a width.

- [ ] **401.** Flutter carousel dots have no hover colour (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/carousel/pl_carousel.dart`
  - Problem: A resting React dot turns the accent colour under the pointer; a Flutter dot does not change.
  - Proposal: Colour it under the pointer as React does.

- [ ] **402.** A `PlNavigationMenu` popup jumps between triggers and wraps its content again while it resizes (Bug · React · Low)
  - Location: `packages/react/src/components/navigation-menu/PlNavigationMenu.tsx`
  - Problem: When the panel changes, the popup moves under the new trigger in one frame, and its content wraps again as the size eases.
  - Proposal: Ease the positioner as Base UI's example does, minding the stale `--positioner-width` after a controlled change and long descriptions on a narrow screen.

- [ ] **403.** `PlPopconfirm` does not pass `loadingLabel` on (Bug · Both · Low)
  - Location: the popconfirm in both packages
  - Problem: It hands `loading` to its confirm button but takes no `loadingLabel`, so the word said while it waits cannot be changed there.
  - Proposal: Take `loadingLabel` and pass it on.

- [ ] **404.** The scatter chart's card and table differ between the builds (Bug · Both · Low)
  - Location: the scatter charts and `internal/chart-frame.tsx`, `internal/chart_frame.dart`
  - Problem: React heads the card with x and writes the series and y below it, and its table writes y and z uncompacted; Flutter heads it with the series and writes `x, y (z)`.
  - Proposal: One shape in both, written through the shared writers.

- [ ] **405.** A Flutter timeline's live region leaves out the row (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/chart_frame.dart`
  - Problem: React reads "Wireframes, Design: …"; Flutter leaves the row name out, and a test holds that wording.
  - Proposal: Read the row as React does, and change the test.

- [ ] **406.** Flutter's `compactNumber` writes infinity as `InfinityT` (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/chart.dart`
  - Problem: A non-finite value goes through the compacting and comes out with a unit.
  - Proposal: Write it as React's writer does.

- [ ] **407.** Flutter `PlAnimateSplit` has no `mode` (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/animate_split/`
  - Problem: The React split takes `mode`, so a split exit exists on the web only.
  - Proposal: Add `mode`, as the other animate widgets have.

- [ ] **408.** `PlAnimateHeadline.repeat` is still described as it was before item 297, and a Korean sentence on its page has no verb (Docs · Docs · Low)
  - Location: the Flutter dartdoc, the React JSDoc inherited from `PlassAnimateProps`, `docs/ko/components/transitions/animate-headline.md`
  - Problem: Both comments say `repeat` is how many times it runs; the Korean page reads "컴포넌트가 자기 그리드를 있고".
  - Proposal: Word both as the props tables now do, and finish the sentence.

- [ ] **409.** The fieldset page's shared Accessibility list states React-only facts (Docs · Docs · Low)
  - Location: `docs/{en,ko}/components/inputs/fieldset.md`
  - Problem: The list is shared but speaks of `<fieldset>` and Base UI.
  - Proposal: Put what differs in `::: fw` blocks.

- [ ] **410.** The colour picker's `alpha` example explains how the chequer is drawn (Docs · Docs · Low)
  - Location: `docs/{en,ko}/components/inputs/color-picker.md`
  - Problem: Four linear stops rather than conic gradients is an internal detail the page rules keep off component pages.
  - Proposal: Move it to the source or the design documents.

- [ ] **411.** The Flutter `PlWindowPane` props table misses three rows, and a window-pane style test presses Tab from the runner (Docs · Docs · Low)
  - Location: `docs/.vitepress/data/props-flutter.ts`, `packages/react/test/styles/window-pane.test.tsx`
  - Problem: `maximizeLabel`, `restoreLabel` and `closeLabel` have no rows; the traffic-light test presses `{Tab}` from the runner's frame, which Firefox does not hand to the page.
  - Proposal: Add the rows, and focus the element directly in the test.
