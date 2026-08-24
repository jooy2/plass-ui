# Changelog

## 0.0.1 (2026-08-24)

The first release, and a preview rather than a product. Two components ship; what is actually being released is the shape everything after them will be poured into — the prop vocabulary, the token sheet, the build, the test setup and the documentation site.

### Added

- **The design language.** A Plass surface is **a moulded plastic key resting on a sheet of glass**, and every surface answers one question: is this pressed, or does it hold something? A thing that is pressed is plastic — a three-stop gradient at 135°, a specular highlight along its top edge, a hairline of light on that edge, and a drop shadow **tinted with its own colour**. A thing that holds something is glass — translucent at one of three opacities, `blur(22px) saturate(160%)`, a white hairline round it, and never dyed, because a sheet holds other people's content and that content arrives with its own colours.
- **`Button`.** `variant` (`solid` · `glass` · `ghost`), `size`, `color`, `density` and `elevation` off the shared vocabulary, plus `startIcon`, `endIcon`, `loading`, `readOnly`, `disabled`, `fullWidth` and `render`. A `glass` button wears the family in its **label** rather than in its sheet, which is what makes `color="secondary"` the quiet neutral button instead of a fourth variant nobody would remember the name of.
- **`elevation` defaults to `1` on Button**, against the `0` a flatter language would use: a key rests _on_ the sheet rather than lying flush with it. Hover adds a level and pressing removes one, so a default button presses down onto the glass under the finger and a raised one comes back to where it was.
- **`TextField`.** Single- or multi-line, with `label`, `description` and `error` as part of the component rather than three elements wired together by the caller — Base UI's `Field` points the label at the control and puts both messages in its `aria-describedby`. `error` carries a message _and_ turns the field invalid, which re-points the whole slot family at `danger` so the hairline, the ring, the caret and the message all turn over together; `invalid` and `invalid={false}` are the two escape hatches for a form library that owns the validity.
- **`solid` means the deepest glass on a field, not plastic.** A gradient under a caret, a text selection and a placeholder is not legible, so a `solid` TextField is the **well** — `--plass-well`, the one shadow in the library that points inward. Same word, one rule underneath it: `solid` is the heaviest thing a variant can be while still doing its job.
- **Six colour families, two hand-picked values each.** `--plass-{color}-solid` and `-on-solid` are declared once and are the same in both themes — a piece of plastic is the same piece of plastic in a dark room — and everything a component reads (`-fill`, `-glow`, `-soft`, `-line`, `-ring`) is computed from them with `color-mix()`. Adding a family is two edits.
- **Every gradient stop clears 4.5:1 against its own label.** The stop that decides a family's lightness is the _lightest_ one, the 5% lift toward white at the top-left corner — which is why the fills sit where they do. `warning` is the one family with dark ink, because white on amber does not reach 4.5:1 at any lightness worth calling amber.
- **Tinted shadows, and they are deliberately not part of the elevation ladder.** `--plass-{color}-glow` is the difference between a button that is blue and a button that is _made of_ blue. `elevation` says how far off the page a surface is; the glow says what it is made of, and a `danger` button one level higher is not a redder piece of plastic.
- **Press is light, not paint.** A gradient cannot be transitioned, so hover and press are `filter: brightness()` — 1.05 up, 0.95 down — with the elevation and the glow moving in the same direction and the specular highlight dropping to 30% as the key tips away from the light. One duration and one curve, applied identically in both directions.
- **`.plass-gloss`**, the specular layer, as real CSS rather than a Tailwind arbitrary variant: one composited layer that never repaints, no pointer tracking, no ripple element, no timer and no JavaScript.
- **The stylesheet ships twice.** `plass-ui/styles.css` is finished CSS — the reset, the compiled utilities and the tokens — for a project with no Tailwind; `plass-ui/tailwind.css` is the token sheet for a project that runs Tailwind v4 itself, and its own `@source '.'` is what means a consumer never writes one.
- `src/types.ts` — `PlassSize`, `PlassColor`, `PlassDensity`, `PlassVariant`, `PlassElevation`, `PlassOrientation`, `PlassSide`, `PlassAlign` and the `PlassStyleProps` bundle. A `size` of `md` is 40px on everything, and an idea that already has a name does not get a second one.

### Documentation

- The VitePress site, in English and Korean, with every preview a real React island rendering the components from `src/` rather than a screenshot: a home page with a live sign-in hero and a full sample screen, the component index, a page each for Button and TextField, and three design pages — design language, colour and prop conventions.
- `docs/public/llms.txt`, the whole site flattened for an agent.

### Notes

- Node 20.19 or later, React 18 or 19, one runtime dependency (`@base-ui/react`).
- The tokens use `color-mix()` and `backdrop-filter`. Where `backdrop-filter` is missing only the blur drops out.
