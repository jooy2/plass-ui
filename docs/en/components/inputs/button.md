---
title: Button
order: 1
---

# Button

<p class="plass-lede">A control that runs an action. Use it for anything the user deliberately triggers — submitting a form, saving, deleting.</p>

<Demo src="button/hero" />

```tsx
import { Button } from 'plass-ui';

<Button onClick={save}>Save</Button>;
```

## Props

<PropsTable name="Button" />

Every native `<button>` attribute passes straight through. The one exception is `color`, omitted because it collides with the `color` in the table above.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

`solid` is a pane of tinted glass and the primary action. `glass` is a clear sheet with a hairline, for secondary actions. `ghost` has no surface until the pointer is on it, for a toolbar or a row. Keep one `solid` per screen.

A `glass` button wears the family in its **text**, so `color="secondary"` is the quiet neutral button rather than a fourth variant.

All three carry the interaction light: a soft bloom that follows the pointer across the control, and a brighter flash on press that drains over about 700ms. On a touch screen it follows a finger dragged across the button. The bloom is white on a `solid` surface and the family's own tint on the other two.

<Demo src="button/variants">

<<< @/.vitepress/demos/button/variants.tsx

</Demo>

### color

Six role colours only; arbitrary colour values are not accepted. On `solid` the family is the gradient and the shadow under it; on `glass` and `ghost` it is the label.

<Demo src="button/colors" :min-height="100">

<<< @/.vitepress/demos/button/colors.tsx

</Demo>

### size

Sets the height and the type scale together: `xs` 24px · `sm` 32px · `md` 40px · `lg` 48px · `xl` 56px. `md` is the desktop default, and `lg` and `xl` both clear the 44px mobile touch target.

<Demo src="button/sizes">

<<< @/.vitepress/demos/button/sizes.tsx

</Demo>

### density

`density` changes horizontal padding and nothing else. Two buttons of the same `size` are the same height whatever their density, so a mixed row keeps its baseline.

<Demo src="button/density">

<<< @/.vitepress/demos/button/density.tsx

</Demo>

### startIcon and endIcon

Icons are drawn at `1.2em`, so they track the label and never need a size of their own. With icons but no `children` the button goes square, and then it needs an `aria-label`.

<Demo src="button/icons">

<<< @/.vitepress/demos/button/icons.tsx

</Demo>

### loading · readOnly · disabled

| prop | Appearance | Focus | Native `disabled` |
| --- | --- | --- | --- |
| `loading` | Unchanged; a spinner takes the `startIcon` slot | Kept | No |
| `readOnly` | Keeps its colour, goes flat, drains saturation | Kept | No |
| `disabled` | Loses the light and the shadow; the page shows through it | Lost | Yes |

None of the three let a click reach the parent.

<Demo src="button/states">

<<< @/.vitepress/demos/button/states.tsx

</Demo>

### elevation

Drop shadow depth. The default is `1`, not `0`: a key rests **on** the sheet. Hovering adds a level and pressing removes one, which is what puts a default button down flush against the glass under the finger.

The tinted shadow a `solid` button casts in its own colour is **not** part of this ladder and does not scale with it — `elevation` says how far off the page a surface is, and a `danger` button one level higher is not a redder pane of glass.

<Demo src="button/elevation">

<<< @/.vitepress/demos/button/elevation.tsx

</Demo>

### fullWidth

Stretches to the width of the container.

<Demo src="button/full-width">

<<< @/.vitepress/demos/button/full-width.tsx

</Demo>

### render

Renders something other than a `<button>`. An action that navigates should be an `<a href>`: a crawler follows it, it appears in a screen reader's list of links, and the browser's own behaviour — open in a new tab, copy the address — keeps working. A router's `Link` goes in the same way.

The surface, the sizes and the press signature are unchanged. An `<a>` has no `disabled`, so a button that has to be unavailable stays a `<button>`.

<Demo src="button/render">

<<< @/.vitepress/demos/button/render.tsx

</Demo>

## Accessibility

- Renders a native `<button>` by default. `type` passes through, so `type="submit"` works inside a form.
- Changing the element with `render` keeps that element's semantics: an `<a href>` stays a link rather than being covered by `role="button"`.
- Give icon-only buttons an `aria-label`.
- The focus ring only appears on `:focus-visible`, so a mouse click never draws one.
- `loading` and `readOnly` keep focus: dropping out of the tab order costs keyboard users their sense of the page.
- Both ends of every gradient meet 4.5:1 against the label on them.
- The interaction light is decorative: it carries no state, and it is not the only signal for anything. `prefers-reduced-motion` stops it easing.
