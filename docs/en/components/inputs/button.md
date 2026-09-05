---
title: PlButton
order: 1
---

# PlButton

<p class="plass-lede">A control that runs an action. Use it for anything the user deliberately triggers — submitting a form, saving, deleting.</p>

<Demo src="button/hero" />

::: fw react

```tsx
import { PlButton } from 'plass-ui';

<PlButton onClick={save}>Save</PlButton>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlButton(onPressed: save, child: const Text('Save'));
```

:::

## Props

<PropsTable name="PlButton" />

::: fw react

Every native `<button>` attribute passes straight through. The one exception is `color`, omitted because it collides with the `color` in the table above.

:::

::: fw flutter

`PlButton` needs nothing above it in the tree. Without a `PlassTheme` it follows the platform's own brightness, so a button dropped into any app is already in the right theme. See [differences from the React build](#differences-from-the-react-build) for what does not carry across.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

`solid` is a pane of tinted glass and the primary action. `glass` is a clear sheet with a hairline, for secondary actions. `ghost` has no surface until the pointer is on it, for a toolbar or a row. Keep one `solid` per screen.

A `glass` button wears the family in its **text**, so <Fw react='color="secondary"' flutter='color: PlassColor.secondary' code /> is the quiet neutral button rather than a fourth variant.

All three carry the interaction light: a soft bloom that follows the pointer across the control, and a brighter flash on press that drains over about 700ms. On a touch screen it follows a finger dragged across the button. The bloom is white on a `solid` surface and the family's own tint on the other two.

<Demo src="button/variants">

::: fw react

<<< @/.vitepress/demos/button/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/variants.dart

:::

</Demo>

### color

Six role colours only; arbitrary colour values are not accepted. On `solid` the family is the gradient and the shadow under it; on `glass` and `ghost` it is the label.

<Demo src="button/colors" :min-height="100">

::: fw react

<<< @/.vitepress/demos/button/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/colors.dart

:::

</Demo>

### size

Sets the height and the type scale together: `xs` 24px · `sm` 32px · `md` 40px · `lg` 48px · `xl` 56px. `md` is the desktop default, and `lg` and `xl` both clear the 44px mobile touch target.

<Demo src="button/sizes">

::: fw react

<<< @/.vitepress/demos/button/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/sizes.dart

:::

</Demo>

### density

`density` changes horizontal padding and nothing else. Two buttons of the same `size` are the same height whatever their density, so a mixed row keeps its baseline.

::: fw flutter

The standard track is `PlassDensity.standard`. It is spelled `'default'` in the React package; `default` is a reserved word in Dart, and this is the only value in the shared vocabulary the two packages name differently.

:::

<Demo src="button/density">

::: fw react

<<< @/.vitepress/demos/button/density.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/density.dart

:::

</Demo>

### startIcon and endIcon

Icons are drawn at `1.2em`, so they track the label and never need a size of their own. With icons but no <Fw react="children" flutter="child" code /> the button goes square, and then it needs an <Fw react="aria-label" flutter="semanticLabel" code />.

::: fw flutter

The size arrives through `IconTheme`, which an `Icon` reads on its own; a glyph drawn some other way should read `IconTheme.of(context)` the way the demo below does.

:::

<Demo src="button/icons">

::: fw react

<<< @/.vitepress/demos/button/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/icons.dart

:::

</Demo>

### loading · readOnly · disabled

::: fw react

| prop | Appearance | Focus | Native `disabled` |
| --- | --- | --- | --- |
| `loading` | Unchanged; a spinner takes the `startIcon` slot | Kept | No |
| `readOnly` | Keeps its colour, goes flat, drains saturation | Kept | No |
| `disabled` | Loses the light and the shadow; the page shows through it | Lost | Yes |

:::

::: fw flutter

| parameter  | Appearance                                                | Focus |
| ---------- | --------------------------------------------------------- | ----- |
| `loading`  | Unchanged; a spinner takes the `startIcon` slot           | Kept  |
| `readOnly` | Keeps its colour, goes flat, drains saturation            | Kept  |
| `disabled` | Loses the light and the shadow; the page shows through it | Lost  |

All three are announced as unavailable, and only `disabled` also leaves the focus order. Flutter has no equivalent of `aria-busy`, so a screen reader cannot tell `loading` from `readOnly` — put the difference in the `semanticLabel` if it matters on your screen.

Leaving `onPressed` null does the same thing as `disabled: true`, which is what a Flutter developer will reach for first.

:::

None of the three let a tap reach the parent.

<Demo src="button/states">

::: fw react

<<< @/.vitepress/demos/button/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/states.dart

:::

</Demo>

### elevation

Drop shadow depth. The default is `1`, not `0`: a key rests **on** the sheet. Hovering adds a level and pressing removes one, which is what puts a default button down flush against the glass under the finger.

The tinted shadow a `solid` button casts in its own colour is **not** part of this ladder and does not scale with it — `elevation` says how far off the page a surface is, and a `danger` button one level higher is not a redder pane of glass.

<Demo src="button/elevation">

::: fw react

<<< @/.vitepress/demos/button/elevation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/elevation.dart

:::

</Demo>

### fullWidth

Stretches to the width of the container.

<Demo src="button/full-width">

::: fw react

<<< @/.vitepress/demos/button/full-width.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/full_width.dart

:::

</Demo>

::: fw react

### render

Renders something other than a `<button>`. An action that navigates should be an `<a href>`: a crawler follows it, it appears in a screen reader's list of links, and the browser's own behaviour — open in a new tab, copy the address — keeps working. A router's `Link` goes in the same way.

The surface, the sizes and the press signature are unchanged. An `<a>` has no `disabled`, so a button that has to be unavailable stays a `<button>`.

<Demo src="button/render">

<<< @/.vitepress/demos/button/render.tsx

</Demo>

:::

## Accessibility

::: fw react

- Renders a native `<button>` by default. `type` passes through, so `type="submit"` works inside a form.
- Changing the element with `render` keeps that element's semantics: an `<a href>` stays a link rather than being covered by `role="button"`.
- Give icon-only buttons an `aria-label`.
- The focus ring only appears on `:focus-visible`, so a mouse click never draws one.
- `loading` and `readOnly` keep focus: dropping out of the tab order costs keyboard users their sense of the page.
- Both ends of every gradient meet 4.5:1 against the label on them.
- The interaction light is decorative: it carries no state, and it is not the only signal for anything. `prefers-reduced-motion` stops it easing.

:::

::: fw flutter

- Announced as a button, enabled or not, with its label read off its `child`.
- Give icon-only buttons a `semanticLabel`.
- The focus ring only appears on what CSS calls `:focus-visible` — a keyboard reaching the control, never a pointer clicking it. Flutter's name for the same distinction is `FocusableActionDetector`'s focus highlight.
- <kbd>Enter</kbd>, <kbd>Space</kbd> and the numpad <kbd>Enter</kbd> activate the button. They are bound on the button itself, so it behaves the same with or without an app widget above it.
- `loading` and `readOnly` keep focus: dropping out of the focus order costs keyboard users their sense of the page.
- Both ends of every gradient meet 4.5:1 against the label on them.
- The interaction light is decorative: it carries no state, and it is not the only signal for anything. A platform with animations turned off (`MediaQuery.disableAnimations`) stops it easing.

:::

::: fw flutter

## Differences from the React build

Everything above is the same in both packages. These are the places where it is not, and why.

| React | Flutter | Why |
| --- | --- | --- |
| `render` | — | Flutter has no polymorphic element. An action that navigates calls your router from `onPressed`. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. `focusNode`, `autofocus` and `onLongPress` are offered instead. |
| `onClick` | `onPressed` | Flutter's name, and `onPressed: null` disables the button the way it does everywhere else in Flutter. |
| `children` | `child` | Flutter's name. |
| `aria-label` | `semanticLabel` | Flutter's name. |
| `density="default"` | `PlassDensity.standard` | `default` is a reserved word in Dart. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | The platform's own signal. |

Two more that are not API, but are visible:

- **The font.** Neither package sets one — a button inherits whatever its host uses, and supplying it is the app's job on both sides. The React previews here are drawn in the documentation site's UI font; the Flutter gallery ships Inter. It is the same button in two typefaces, not two buttons.

  This matters more than it sounds, because **a label is weight 600 and not every font has one.** Flutter's engine carries a single face, Roboto Regular, and synthesises anything else by widening its strokes, and Roboto's own family goes 400, 500, 700 with no 600 in it. An app on a font with no real SemiBold gets a label that is heavier and visibly softer than the one above. Inter, Pretendard, SF and Noto Sans all have the weight; Roboto does not.

- **The blur.** `glass` blurs what is painted behind it, and in Flutter that means _inside the same app_. The previews here are iframes, so the gallery paints the page's backdrop itself — which is why a `glass` button in a Flutter preview has something to be in front of.

Everything else is matched deliberately, including the parts where the same number would have been wrong: shadow blur is converted from the CSS radius to Flutter's sigma so the two shadows are the same size, and the `solid` gradient computes its endpoints the way `linear-gradient(135deg, …)` does rather than running corner to corner, which on a wide button is a visibly different sweep.

:::
