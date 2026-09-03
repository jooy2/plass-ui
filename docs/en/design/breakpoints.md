---
title: Breakpoints
order: 4
---

# Breakpoints

<p class="plass-lede">Five names, four widths, and one place they are written down. Everything in the library that changes with the width of the window reads the same ladder — including your <code>md:</code> utilities, which is the point.</p>

## The ladder

| Rung | From | Notes |
| --- | --- | --- |
| `xs` | 0 | Everything is at or above it. It has no floor, which is why it is never a bound. |
| `sm` | 40rem · 640px |  |
| `md` | 48rem · 768px |  |
| `lg` | 64rem · 1024px |  |
| `xl` | 80rem · 1280px |  |

They are the same five names as `size`, deliberately. A reader who has learned the ladder once should not have to learn a second set of words for where a screen changes shape — they are not the same ladder, a size is how tall a control is and a breakpoint is how wide the window is, but they run in the same direction and turn up in the same sentence.

::: fw react

The widths are **Tailwind's own**, so a layout decided by a `md:` utility and a layout decided by this library change at the same moment. A page with two answers about how wide it is is a page that drifts by a few pixels for no reason anybody can find later.

:::

## Moving them

::: fw react

One line, in your own Tailwind theme:

```css
@import 'tailwindcss';
@import 'plass-ui/tailwind.css';

@theme {
  --breakpoint-md: 50rem;
}
```

Both halves of the library follow it — `PlGrid`'s cascade, `PlContainer`'s measure, `PlShow`, `usePlBreakpoint`, and a `PlSidebar`'s `collapseBelow`.

**There is no provider prop for this, and there cannot be.** A media query's _condition_ cannot read a custom property: `@media (width >= var(--x))` is not valid CSS and never will be. So a breakpoint the stylesheet decides at is resolved when the stylesheet is compiled, not when a component renders — the library writes its own with `@variant`, which is Tailwind's, which is your theme's.

The JavaScript half is the other kind of question. There a breakpoint is a _value_ rather than a condition, so it can be read off the document, and the stylesheet publishes it as four tokens for exactly that:

```css
--plass-breakpoint-sm: var(--breakpoint-sm, 40rem);
--plass-breakpoint-md: var(--breakpoint-md, 48rem);
--plass-breakpoint-lg: var(--breakpoint-lg, 64rem);
--plass-breakpoint-xl: var(--breakpoint-xl, 80rem);
```

Set the Tailwind variable, not these. Setting one of these moves the JavaScript half on its own, which leaves the two disagreeing — the exact failure the arrangement exists to prevent.

**On the precompiled path this is baked.** A project that imports `plass-ui/styles.css` gets a stylesheet we compiled, with our widths in it; there is no Tailwind on that side to re-run. Import `plass-ui/tailwind.css` instead if you need to move a breakpoint.

:::

::: fw flutter

The ladder is `PlassBreakpoint`, and its widths are the React package's, which are Tailwind's. There is no stylesheet here and so nothing to compile against: the widths are fixed.

:::

## Responsive values

A value that changes with the width is written the same way everywhere in the library. <Fw react="A bare value applies at every width; a map applies each entry from its own breakpoint up." flutter="The base value applies from zero up and every override applies from its own breakpoint up." />

::: fw react

```tsx
<PlGridItem span={6} />                    // six columns at every width
<PlGridItem span={{ xs: 12, md: 6 }} />    // full on a phone, half from 48rem
```

There is no `xs` fallback to write out: an entry cascades to the widths above it, which is what keeps a responsive prop to the breakpoints it actually names. `{ lg: 3 }` names one rung, not five.

:::

::: fw flutter

```dart
PlGridItem(span: const PlassResponsive<int>(6));               // six everywhere
PlGridItem(span: const PlassResponsive<int>(12, md: 6));       // full, then half
```

Dart has no untagged union, so the base value is the first positional argument and the overrides are named. `PlassResponsive(6)` is the whole of "six columns everywhere".

:::

Which props take one:

| Component | Prop |
| --- | --- |
| [`PlGrid`](../components/layout/grid) | `columns` `spacing` `rowSpacing` `columnSpacing` |
| [`PlGridItem`](../components/layout/grid) | `span` `offset` |
| [`PlContainer`](../components/layout/container) | `maxWidth` |
| [`PlPanes`](../components/layout/panes) [`PlTabs`](../components/surfaces/tabs) [`PlScrollZone`](../components/layout/scroll-zone) [`PlTimeline`](../components/display/timeline) [`PlStepper`](../components/navigation/stepper) | `orientation` |
| [`PlStack`](../components/layout/stack) | `direction` |

## Where a responsive value is resolved

::: fw react

This is the part worth understanding, because it decides what a responsive prop costs and what it can do.

**A value that decides only style is resolved in CSS.** The component writes one `--p-*` custom property per rung the caller named and the stylesheet cascades it down from the rung above. Nothing measures anything, nothing re-renders when a window is dragged, and the first paint a server sends is already correct at every width — because the browser is what resolves it. `PlGrid` and `PlContainer` work this way, and `PlShow` is the same idea with `display`.

**A value that decides structure cannot be.** An orientation changes which DOM a component builds, which ARIA it claims and which way its arrow keys go, and no stylesheet can do that. Those are resolved by [`usePlBreakpointValue`](../hooks/use-breakpoint), which is JavaScript — so a server renders the `xs` entry and the browser corrects it on hydration.

The library reaches for the CSS half whenever it can, and you should too.

:::

::: fw flutter

Everything is resolved in the widget, against `MediaQuery.sizeOf(context).width`, and it is correct on the first frame — there is no server render to disagree with. The breakpoint is the **window's** width rather than the widget's own box, which is what a media query measures and what makes two widgets side by side agree about which rung they are on however wide each of them ended up.

:::

## Showing one thing or another

[`PlShow`](../components/layout/show) is the gate: `from`, `until`, or both as a band.

::: fw react

It hides with `display: none`, so both halves are in the document and neither is read out twice. When only one of them should exist at all — it fetches, it is expensive, it holds state — use [`usePlBreakpointValue`](../hooks/use-breakpoint) and mount one.

:::

## Asking in JavaScript

::: fw react

Three hooks, for the decisions CSS cannot make — how many items to fetch, which of two components to mount, how many characters to truncate at.

- [`usePlBreakpoint()`](../hooks/use-breakpoint) — which rung the window is on.
- [`usePlBreakpointValue(value)`](../hooks/use-breakpoint) — a responsive value, resolved. The same shape and the same rule as a responsive prop.
- [`usePlMediaQuery(query)`](../hooks/use-media-query) — any query at all.

All three answer **`false` / `xs` on a server**, and that is not a bug to work around: it is what makes the markup a server sends deterministic. Anything that has to be right in the first frame belongs in CSS — a Tailwind variant, or `PlShow`. These are for what comes after.

:::

::: fw flutter

`PlassBreakpoint.of(MediaQuery.sizeOf(context).width)` is the whole of it, and `PlassResponsive.resolve(breakpoint)` reads a responsive value against it.

:::

## What a sidebar does with them

[`PlSidebar`](../components/layout/sidebar) collapses into a drawer below `collapseBelow`, and it is worth reading as the worked example of everything above: the decision is a media query in CSS for the first paint **and** `matchMedia` in JavaScript from then on, because the markup a server sends is the column and a phone must not draw one and throw it away.
