---
title: PlTabs
order: 3
---

# PlTabs

<p class="plass-lede">One set of panels, one of which is shown. The indicator slides from the tab you left to the one you chose.</p>

<Demo src="tabs/hero" :min-height="200" />

::: fw react

```tsx
import { PlTab, PlTabPanel, PlTabs } from 'plass-ui';

<PlTabs defaultValue="account">
  <PlTab value="account">Account</PlTab>
  <PlTab value="billing">Billing</PlTab>

  <PlTabPanel value="account">Your name and your avatar.</PlTabPanel>
  <PlTabPanel value="billing">Cards and invoices.</PlTabPanel>
</PlTabs>;
```

The tabs and the panels are written as siblings and sorted apart by the component. There is no `<PlTabList>` to remember, and no array-of-subtrees prop. A panel is a subtree, and there is no useful shape for that which is not just children.

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlTabs<String>(
  value: tab,
  onChanged: (String next) => setState(() => tab = next),
  tabs: <PlTab<String>>[
    PlTab<String>(
      value: 'account',
      label: const Text('Account'),
      panel: const Text('Your name and your avatar.'),
    ),
    PlTab<String>(
      value: 'billing',
      label: const Text('Billing'),
      panel: const Text('Cards and invoices.'),
    ),
  ],
);
```

A tab and the panel it opens are **one description**, which is the whole of the difference: there is no `PlTabPanel` to keep in step, no third value to match up, and a panel that is not chosen is never built.

:::

## Props

<PropsTable name="PlTabs" />

::: fw react

The bar and the panels take a value of `string | number`.

:::

::: fw flutter

The bar is generic in its tab's type (`PlTabs<String>`, `PlTabs<Section>`), so `value` and `onChanged` are typed rather than `dynamic`, and it is **controlled**, like every other control in the package. `value` is nullable: `null` is a bar with nothing chosen and no panel under it.

:::

### PlTab

<PropsTable name="PlTab" />

::: fw react

### PlTabPanel

<PropsTable name="PlTabPanel" />

`variant`, `size`, `density` and `orientation` are read from the `PlTabs` around them. A tab that could disagree with its neighbours about any of those is a tab bar with a hole in it.

:::

::: fw flutter

A tab is a **`PlTab`, a description rather than a widget**, for the reason a [segment](../inputs/segmented-button) is one: the bar owns the roving focus, the arrow keys and the indicator that slides between the tabs, so it has to know which one is chosen and where each one is. Its `panel` rides along, because a tab and what it opens are the same fact written twice otherwise.

It carries no `variant`, no `size`, no `density` and no `orientation`, and could not. A tab that disagrees with its neighbours about any of those is a tab bar with a hole in it.

:::

What the shared axes (`variant` `size` `color` `density` `orientation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Tabs or a segmented button

Tabs swap whole panels of content. A [segmented button](../inputs/segmented-button) filters what is already on screen. That is also why the `solid` tile here is a pane of **clear** glass rather than the family's gradient. The gradient tile belongs to the segmented button, and a screen with both should be able to tell them apart.

## Examples

### variant

`glass` is the classic bar: a rule along its edge with the indicator riding on it. `solid` is a groove with a pane sliding in it. `ghost` is the same bar with the rule taken away, for tabs inside a `PlCard` that already has an edge of its own.

<Demo src="tabs/variants" :min-height="420">

::: fw react

<<< @/.vitepress/demos/tabs/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/variants.dart

:::

</Demo>

### orientation

`vertical` puts the tabs down the side and the panel beside them, and moves the arrow keys onto the other axis, <Fw react="which is Base UI's doing" flutter="which the bar does itself" />, and is what makes a vertical tab bar reachable.

**It is responsive**, so a set can run one way on a phone and the other on a laptop. <Fw react="A server renders the xs entry and the browser corrects it on hydration." flutter="It is resolved against the window's width during build, so the first frame is already right." /> See [breakpoints](../../design/breakpoints).

<Demo src="tabs/orientation" :min-height="200">

::: fw react

<<< @/.vitepress/demos/tabs/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/orientation.dart

:::

</Demo>

### fullWidth

<Demo src="tabs/full-width" :min-height="160">

::: fw react

<<< @/.vitepress/demos/tabs/full-width.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/full_width.dart

:::

</Demo>

### size

A tab is a control, so it takes the control height ladder. A `md` tab and a `md` `PlButton` are the same 40px, which is what lets a tab bar sit in a toolbar next to one without the row losing its baseline.

<Demo src="tabs/sizes" :min-height="380">

::: fw react

<<< @/.vitepress/demos/tabs/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/sizes.dart

:::

</Demo>

### A bar with more tabs than room

A bar with more tabs than room **scrolls** rather than wrapping: a tab bar on two lines has stopped being a bar, and the indicator has nowhere sensible to sit.

Which is why the bar has to say it is scrolling, and a scrollbar does not. On a Mac it is an overlay that appears only while the strip is moving, and a reader decides whether there is more to look at the rest of the time. On Windows the same bar is fifteen pixels of permanent furniture under a row of labels. Both are taken away, and the end that still has tabs behind it is faded out instead. Only that end, so a faded edge always means there is more.

The fade takes the pixels away rather than painting over them, so it is right whatever the bar is sitting on. A component cannot know whether it is on the page, on a `PlCard` or on a tinted section, and a gradient painted in the wrong colour would be worse than no signal at all. It is dropped while a tab inside is showing a focus ring, because focusing a tab scrolls it flush against the edge the fade is strongest at.

Whether a bar overflows depends on the room it was given, so this is **measured** rather than declared. There is no prop for it.

::: fw react

The state is published as `data-overflow` on the tab list. `none`, `start`, `end` or `both`, in the reader's order, so a page can style against it or assert on it.

:::

### Controlled

<Demo src="tabs/controlled" :min-height="200">

::: fw react

<<< @/.vitepress/demos/tabs/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/controlled.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI owns everything that makes a tab bar a tab bar rather than a row of buttons: roving focus so the whole bar is one tab stop, the arrow keys on whichever axis it runs, <kbd>Home</kbd> and <kbd>End</kbd>, the `tab` / `tabpanel` roles, and the `aria-controls` wiring between them.
- `activateOnFocus` is **off** by default. Automatic activation is only kind when every panel is already on the page; the moment one of them fetches, walking past four tabs fires four requests.
- A panel with nothing focusable inside takes focus itself, so its content is reachable from the keyboard.
- The focus ring on a tab is drawn inset, because an offset ring on a tab inside a `solid` groove would be painted over its neighbours.
- The indicator animates `left`, `top`, `width` and `height` rather than a `transform`. It is an empty box: nothing with text in it moves.
- A bar with more tabs than room scrolls rather than wrapping, and fades the end that still has tabs behind it. A tab bar on two lines has stopped being a bar, and the indicator has nowhere sensible to sit.

:::

::: fw flutter

- **One** focus stop for the whole bar: exactly one tab is in the tab order and the rest are wrapped in an `ExcludeFocus`. That is what makes a bar a bar rather than a row of buttons.
- <kbd>←</kbd> <kbd>→</kbd> on a horizontal bar and <kbd>↑</kbd> <kbd>↓</kbd> on a vertical one move the choice, wrapping at both ends and stepping over a disabled tab. <kbd>Enter</kbd> and <kbd>Space</kbd> choose the focused one.
- Each tab is announced as one of a mutually exclusive set, chosen or not, and the bar is a container you can give a `semanticLabel`. Give it one. A bar has no visible label of its own.
- Moving the focus **moves the choice**, because only the chosen panel is built and a bar that let focus and content disagree would be showing one thing and reading another. If a panel is expensive, keep the work out of `build` rather than out of the tab.
- A tab's focus ring turns **inward**, because a ring drawn outside a tab in a `solid` groove would be painted over its neighbours.
- The indicator animates its **box**, position and size, rather than a transform. It is an empty rectangle: nothing with text in it moves. With animations turned off at the OS it jumps.
- A bar with more tabs than room scrolls rather than wrapping, and fades the end that still has tabs behind it. It used to be as wide as its tabs and overflow its box, and the advice was to wrap it yourself, which does not work: a `SingleChildScrollView` around a `PlTabs` scrolls the panel with the bar.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `<PlTab>` and `<PlTabPanel>` children | `tabs`, as descriptions, each carrying its `panel` | The bar owns the roving focus, the arrow keys and the sliding indicator, so it has to know which tab is chosen and where each one is. Pairing the panel with its tab removes the third place the value had to match. |
| `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter's own controls are controlled, and its name for the callback. |
| a value of `string \| number` | a generic `T` | Dart has generics, so the type is checked rather than restrained by convention. |
| every panel rendered, one shown | only the chosen panel built | A tab that is not open costs nothing. It also means a panel loses its state when you leave it, hold that state above the bar. |
| `activateOnFocus` | — | Moving focus moves the choice, always, because the panel is built from the choice. |
| `aria-label` | `semanticLabel` | Flutter's name. |
| the `tab` / `tabpanel` roles, `aria-controls` | a mutually exclusive selected node, and one panel | Flutter names the state on the node itself; there is no id to point at. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
