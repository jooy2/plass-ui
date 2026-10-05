# Audit TODO

The open findings of an audit of what `plass-ui` can do to the loading speed, the responsiveness and the search ranking of a website that uses it (Core Web Vitals and SEO), taken at `62e1b599` on 2026-10-04. Every docs demo was rendered with `renderToString` in Node and hydrated with `hydrateRoot` in a browser, its controls were pressed at a 4x CPU slowdown, and the source was read for layout, listener and markup problems. When no item is left, delete this file in a commit of its own.

A closed item is deleted from this file, not ticked, and its number is not used again.

**3 items are open, and the last number used is 168.** Batches 1 to 3 (2026-10-04 and 2026-10-05) closed items 1 to 165; what they fixed is in the changelogs, and what they decided to keep is in this file's history.

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

Line numbers are from `79cad2ec0` and drift as the code changes; when one no longer matches, search for the symbol.

### Low

- **166.** **A `PlAnimateHeadline` let go of its `index` goes on in React with the wait it had before it was controlled** (`PlAnimateHeadline.tsx` ~218 leaves `waited` alone while `index` is set), so it can turn at once; Flutter counts from the beginning (`pl_animate_headline.dart` ~305, a new `index` is `fresh`). Decided: React counts from the beginning too.
- **167.** **A finite Flutter run that landed under reduced motion and is given `repeat: null` turns again** (`animate.dart` ~1262 `_recount`, and ~1395, ~1407 when the setting goes); React stands it at the end of one pass (`data-plass-landed` and `--p-anim-still-repeat: 1`, `styles.css` ~3706, `animate.ts` ~182; read from the code). Decided: Flutter stays, as items 132 and 164 set; it runs when it runs again.
- **168.** **A Flutter run that finished moving before reduced motion arrived has its clock put back to the run's end when the setting comes** (`animate.dart` ~1382 `_clockAt = _runTime`), where a React keyframe's clock runs on from its start, so a higher `repeat` given after the setting has gone starts from another point, and one given while the setting is on stands at the end once it goes (~1431 `_pass = repeat`) where React plays on its clock (read from the code). Decided: Flutter keeps the clock running from the start, as React does.
