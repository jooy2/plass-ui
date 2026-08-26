---
title: PlAccordion
order: 1
---

# PlAccordion

<p class="plass-lede">A stack of sections that fold open one at a time. Use it for reference material a reader scans before choosing what to read — settings groups, specifications, an FAQ.</p>

<Demo src="accordion/hero" :min-height="240" />

::: fw react

```tsx
import { PlAccordion, PlAccordionItem } from 'plass-ui';

<PlAccordion defaultValue={['shipping']}>
  <PlAccordionItem value="shipping" title="Shipping">
    Three to five working days.
  </PlAccordionItem>
  <PlAccordionItem value="returns" title="Returns">
    Thirty days from delivery.
  </PlAccordionItem>
</PlAccordion>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAccordion<String>(
  value: open,
  onChanged: (Set<String> next) => setState(() => open = next),
  items: const <PlAccordionItem<String>>[
    PlAccordionItem<String>(
      value: 'shipping',
      title: Text('Shipping'),
      child: Text('Three to five working days.'),
    ),
    PlAccordionItem<String>(
      value: 'returns',
      title: Text('Returns'),
      child: Text('Thirty days from delivery.'),
    ),
  ],
);
```

:::

## Props

<PropsTable name="PlAccordion" />

::: fw react

Every native `<div>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above, and `defaultValue` and `onChange` because the accordion spells them `defaultValue` (an array) and `onValueChange`.

:::

::: fw flutter

The accordion is generic in its section's type — `PlAccordion<String>`, `PlAccordion<Section>` — so `value` and `onChanged` are typed rather than `dynamic`, and it is **controlled**, like every other control in the package. `value` is a `Set<T>` even with `multiple` off, because closed is a set too: an empty one.

:::

### PlAccordionItem

<PropsTable name="PlAccordionItem" />

::: fw react

`size`, `density` and `dividers` are read from the `PlAccordion` around the item, not set on it.

:::

::: fw flutter

A section is a **`PlAccordionItem`, a description rather than a widget**. The accordion has to know which sections are open, which one a press should close, and where the rules between them go, and none of that can be asked of an opaque `Widget`.

It carries no `size`, no `density` and no `dividers`, and could not: those are the accordion's, and a stack with two type scales in it is not one pane.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

The three materials, read the way a **container** reads them. `solid` is the clear glass at its most opaque, for a pane that has to sit forward of everything around it. `glass` is the canonical Plass sheet and the default. `ghost` has no sheet at all — reach for it inside a `PlCard`, where a second bordered rectangle is a second rectangle.

None of the three is dyed. What an accordion holds arrives with its own colours; the family reaches the hover tint, the open section's title and the focus ring, and stops.

<Demo src="accordion/variants" :min-height="200">

::: fw react

<<< @/.vitepress/demos/accordion/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/accordion/variants.dart

:::

</Demo>

### multiple

By default opening a section closes the one that was open, which is the whole reason an accordion is not a stack of collapsibles: closing the last as you open the next is what keeps the page from growing under the reader. `multiple` lifts that.

<Demo src="accordion/multiple" :min-height="220">

::: fw react

<<< @/.vitepress/demos/accordion/multiple.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/accordion/multiple.dart

:::

</Demo>

### dividers

On by default: a hairline reaching both edges is what says the folds are parts of one pane. Turn it off and each section becomes its own tile, told apart by space.

<Demo src="accordion/dividers" :min-height="180">

::: fw react

<<< @/.vitepress/demos/accordion/dividers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/accordion/dividers.dart

:::

</Demo>

### title · subtitle · startIcon · action

`action` is rendered **outside** the fold. A header that both folds and holds a button has two things to press, and one of them cannot be inside the other.

::: fw react

The browser rewrites a `<button>` inside a `<button>` on parse, so this is not a preference.

:::

::: fw flutter

Nothing rewrites the tree here, but a control nested in a control is a press that fires twice and a screen reader reading a button inside a button.

:::

<Demo src="accordion/slots" :min-height="220">

::: fw react

<<< @/.vitepress/demos/accordion/slots.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/accordion/slots.dart

:::

</Demo>

### size

Moves the title, the body and the padding around both together. It is set on the accordion and inherited by every section, so a stack cannot end up with two type scales in it.

The body keeps padding of its own above it as well as below. An open header is a tinted band with a bottom edge, and a body that starts at that edge puts its first line half a leading under the title — the heading and the paragraph explaining it read as one run of text broken by a colour change. What the header's padding buys is room around the title; the body buys its own.

<Demo src="accordion/sizes" :min-height="320">

::: fw react

<<< @/.vitepress/demos/accordion/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/accordion/sizes.dart

:::

</Demo>

### Controlled

::: fw react

Pass `value` with `onValueChange` to own the open set. Both are arrays even when `multiple` is off — a closed accordion is `[]`.

:::

::: fw flutter

There is no uncontrolled mode: `value` and `onChanged` are how the accordion is driven, always. `value` is a `Set<T>` even when `multiple` is off — a closed accordion is `<String>{}` — and leaving `onChanged` off freezes it at whatever is open, which is how a read-only summary is spelled.

:::

<Demo src="accordion/controlled" :min-height="280">

::: fw react

<<< @/.vitepress/demos/accordion/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/accordion/controlled.dart

:::

</Demo>

## Accessibility

::: fw react

- Each header is a real `<button>` carrying `aria-expanded`, pointed at its panel with `aria-controls`. The panel is a `region` labelled by its header.
- <kbd>Enter</kbd> and <kbd>Space</kbd> fold a section; <kbd>Tab</kbd> moves between headers and into an open panel.
- `hiddenUntilFound` renders closed panels with `hidden="until-found"`, so the browser's own page search finds text inside them and opens the section it is in.
- The chevron is decorative and `aria-hidden`; the open state is carried by `aria-expanded`, never by the rotation alone.
- Anything in `action` is a separate control with its own tab stop, and needs its own accessible name.
- The panel animates its height rather than a `transform`, so no text is resampled and nothing shifts inside the panel while it opens.

:::

::: fw flutter

- Each header is announced as a button, expanded or collapsed. The state is carried by that flag, never by the chevron's rotation alone.
- <kbd>Enter</kbd> and <kbd>Space</kbd> fold a section; <kbd>Tab</kbd> moves between headers and into an open panel. Every header is its own focus stop — an accordion is a stack of buttons, not a roving group.
- A closed panel is not in the tree at all, so nothing inside it is reachable, focusable or read out until it is open.
- The chevron is drawn and not named, and a disabled section stops answering both the pointer and the keyboard.
- Anything in `action` is a separate control with its own focus stop, and needs its own name.
- The panel animates its **height** rather than a transform, so no text is resampled and nothing shifts inside the panel while it opens. With animations turned off at the OS it snaps.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `<PlAccordionItem>` children | `items`, as descriptions | The accordion has to know which sections are open, which one a press closes, and where the rules go. None of that can be asked of an opaque widget. |
| `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter's own controls are controlled, and its name for the callback. |
| a value of `string` | a generic `T` | Dart has generics, so the section's type is checked rather than restrained by convention. |
| `value` as an array | `value` as a `Set<T>` | The open sections are a set — unordered, no duplicates — and Dart has one. |
| `hiddenUntilFound` | — | There is no browser page-search to open a section for. A closed panel simply is not built. |
| `aria-expanded`, `aria-controls`, `region` | an expanded button, and a panel that exists or does not | Flutter names the state on the node itself; there is no id to point at. |
| `children` | `child` | Flutter's name. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
