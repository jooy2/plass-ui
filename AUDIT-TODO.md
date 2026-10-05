# Audit TODO

The open findings of an audit of what `plass-ui` can do to the loading speed, the responsiveness and the search ranking of a website that uses it (Core Web Vitals and SEO), taken at `62e1b599` on 2026-10-04. Every docs demo was rendered with `renderToString` in Node and hydrated with `hydrateRoot` in a browser, its controls were pressed at a 4x CPU slowdown, and the source was read for layout, listener and markup problems. When no item is left, delete this file in a commit of its own.

A closed item is deleted from this file, not ticked, and its number is not used again.

**4 items are open, and the last number used is 161.** Batches 1 to 3 (2026-10-04 and 2026-10-05) closed items 1 to 157; what they fixed is in the changelogs, and what they decided to keep is in this file's history.

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

Line numbers are from `5ba93a90d` and drift as the code changes; when one no longer matches, search for the symbol.

### Low

- **158.** **An endless Flutter `PlAnimateMarquee` or `PlAnimateLighting` goes on from where its clock stands when reduced motion is turned off** (since item 154 keeps the run; `animate.dart` ~1322–1340), so the strip jumps from 0 to where its passes would be; React switches both off under the setting (`styles.css` ~3630, ~3663) and starts them from the beginning after their `delay`. Decided: Flutter starts these two from the beginning, as React does; the other endless effects keep item 129's rule.
- **159.** **A finite Flutter `PlAnimateMarquee` or `PlAnimateLighting` that landed under reduced motion and is held by `paused` turns into the strip or the arc when the setting is turned off** (`animate.dart` ~1322–1340 keeps the reduced-motion view only for an endless run and one paused before it started); React keeps it for every held run since item 157. Item 131's rule covers it.
- **160.** **A Flutter `PlAnimateMarquee` drops every copy but the first under reduced motion** (`pl_animate_marquee.dart` ~300), so the copies are built again, and lose any state, when the setting changes; React keeps them on the page and hides them.
- **161.** **Adding lines to a `PlAnimateHeadline` or changing its `loop` starts the whole `interval` again**, in both builds (`pl_animate_headline.dart` ~293, `PlAnimateHeadline.tsx` ~203); item 156 measures a new `interval` from when the wait began.
