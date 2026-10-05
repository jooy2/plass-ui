# Audit TODO

The open findings of an audit of what `plass-ui` can do to the loading speed, the responsiveness and the search ranking of a website that uses it (Core Web Vitals and SEO), taken at `62e1b599` on 2026-10-04. Every docs demo was rendered with `renderToString` in Node and hydrated with `hydrateRoot` in a browser, its controls were pressed at a 4x CPU slowdown, and the source was read for layout, listener and markup problems. When no item is left, delete this file in a commit of its own.

A closed item is deleted from this file, not ticked, and its number is not used again.

**5 items are open, and the last number used is 157.** Batches 1 to 3 (2026-10-04 and 2026-10-05) closed items 1 to 152; what they fixed is in the changelogs, and what they decided to keep is in this file's history.

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

Line numbers are from `b44ec93b7` and drift as the code changes; when one no longer matches, search for the symbol.

### Low

- **153.** **A `paused` Flutter `PlAnimateMarquee` turns from the one scrollable copy reduced motion showed into the clipped strip of copies when the setting is turned off** (`pl_animate_marquee.dart` ~198, ~227, ~246, ~264: it reads reduced motion itself, and the scroll box is outside the run). Decided: after items 154 and 155, move the scroll box and the clip into the run's `builder` and `stillBuilder`, so a pause keeps the scrollable copy; a prototype of that passed the 17 marquee tests.
- **154.** **Turning reduced motion on or off remounts the content of every Flutter `PlAnimate*` effect** (`animate.dart` ~1407 returns `stillBuilder(...)` directly under the setting and ~1427 wraps the rest in an `AnimatedBuilder`), so a stateful child loses its state, an input its text and a list its scroll; a `PlAnimateFade`'s child mounted three times over two changes of the setting. React changes only CSS.
- **155.** **A Flutter `PlAnimateMarquee`'s `visible` trigger and off-screen rest measure the strip rather than the box** (`pl_animate_marquee.dart` ~211–270, `animate.dart` ~535, ~569): a strip longer than the screen can fail its `threshold` while the box is wholly in view (a `threshold: 0.5` marquee fully visible on a 300-wide page never starts). React measures the box.
- **156.** **`PlAnimateHeadline` waits a whole `interval` again after a pause, an off-screen rest or a change of `delay` or `interval`, and the whole `delay` too if it has not turned yet**, in both builds (`pl_animate_headline.dart` ~281–292 `_schedule`, `PlAnimateHeadline.tsx` ~183–201). Decided: it waits what was left, as the typewriter's hold does since item 67, and a new `interval` or `delay` is measured from when the wait began.
- **157.** **A `paused` React `PlAnimateMarquee` loses what reduced motion showed when the setting is turned off**: `styles.css` has no `.plass-marquee[data-plass-held]` rule, and the rules that hide the copies and let the box scroll (~3643–3655) sit only inside the reduced-motion query (read from the CSS, not run). Item 131's rule covers it: `paused` keeps what is on screen.
