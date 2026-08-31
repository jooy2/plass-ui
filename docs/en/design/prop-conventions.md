---
title: Prop conventions
order: 3
---

# Prop conventions

<p class="plass-lede">One vocabulary, shared by every component. A <code>size</code> of <code>md</code> is the same height everywhere, and an idea that already has a name does not get a second one.</p>

## The five shared axes

They live in `src/types.ts` and every styled component draws from them.

| Prop        | Type                                   | Means                           |
| ----------- | -------------------------------------- | ------------------------------- |
| `variant`   | `'solid' \| 'glass' \| 'ghost'`        | What the surface is made of     |
| `size`      | `'xs' \| 'sm' \| 'md' \| 'lg' \| 'xl'` | Height and type scale, together |
| `color`     | six role names                         | Which semantic family           |
| `density`   | `'default' \| 'compact'`               | Padding, and only padding       |
| `elevation` | `0 \| 1 \| 2 \| 3`                     | How far off the page            |

### `variant` names a material

`solid`, `glass`, `ghost` — not `filled`, `outlined`, `text`. The three words are the three answers to the question the [design language](./design-language) makes every surface answer, and naming them after what they _are_ rather than after what they look like is what keeps the answer consistent when a component is hard to place.

The one place the same word means two things is `solid` on something typed into: there it is the **well**, not a tinted pane. See [PlTextField](../components/inputs/text-field#variant).

### `size` is one decision

Height and type scale move together, always. There is no `size="md" textSize="lg"`, because two controls of the same `size` that are not the same height are two controls that will never line up in a row.

### `color` is a role, never a value

Six names, no arbitrary colours. A component that needs a colour that is not one of the six is asking for a design token, and that is a change to [Colour](./color) rather than a prop.

### `density` is padding

It never touches the height and never touches the type scale. A compact control and a default control of the same `size` sit on the same baseline.

### `elevation` defaults differ, and the default is the statement

`0` on anything that holds content, `1` on anything pressed. A key rests **on** the sheet; a field is cut **into** it. Where a component's default is not what you would guess, its props table says so.

## Naming rules

These are the rules a new component is checked against.

- **Do not invent a second spelling for an idea that already has one.** If a component needs "how big", it is `size`. If it needs "which semantic colour", it is `color`. A `scale`, a `tone` or an `intent` prop is a fork in the vocabulary.
- **Boolean props are named for the state they turn on**, and default to `false`: `loading`, `readOnly`, `disabled`, `fullWidth`, `multiline`, `invalid`.
- **Slots are `ReactNode`, named for where they go**: `startIcon`, `endIcon`, `label`, `description`, `error`. Never `renderIcon`, never `iconLeft`.
- **`start`/`end`, never `left`/`right`.** They flip under RTL; the physical words do not.
- **Durations and delays are numbers in milliseconds**, never CSS strings. A prop typed `string` invites `'0.4s'`, and then two components on one screen are written in two units.
- **`render` is the escape hatch**, spelled the same way everywhere — Base UI's own prop, passed through. It replaces the element without changing the surface.
- **Native attributes pass through.** A component that wraps an `<input>` takes every `<input>` attribute, minus the ones that collide with an axis above (`color`, `size`).

## Binding a key

`PlTextField`, `PlNumberField`, `PlOtpField`, `PlCombobox` and `PlSelect` take a **`hotKeys`** map: a chord, and what pressing it does.

```tsx
<PlTextField hotKeys={{ 'Mod+Enter': save, Escape: cancel }} />
```

Three rules hold across all five.

- **The chord is spelled the way a key cap is spelled** — the same vocabulary [`PlHotKeys`](../components/display/hot-keys) draws. `Mod` resolves per platform (⌘ on a Mac, <kbd>Ctrl</kbd> everywhere else), and `Esc`, `Return`, `Cmd` and `Option` fold onto the same keys their caps do. A shortcut a component displays and a shortcut it binds must be one string, or the cap on the screen is a claim nobody checked.
- **A modifier is checked in both directions.** `Enter` does not fire on <kbd>Shift</kbd>+<kbd>Enter</kbd>, so a field that saves on Enter does not also save on every chord that happens to end in one.
- **A chord that matches is consumed.** The handler runs and the key goes no further — not to the control's own key handling, not to the form, not to the dialog above it. Bind chords rather than letters: a field with `{ a: … }` cannot type an `a`.

::: fw react

`hotKeys` sits on the **control** rather than on the stack around it, so a chord is answered by the thing that has the focus. It is a convenience over `onKeyDown`, not a replacement: the raw handler is still there, still passes through to the same element, and runs **first** — if it calls `preventDefault()`, the map is skipped.

:::

::: fw flutter

The map is bound closer to the focused node than the widget's own key handling, which is what lets a caller take a key from the control. `PlSelect` is the one place that cannot be done by nesting — a `FocusableActionDetector` binds Enter closer than anything a field can wrap around it — so the trigger **stands down** from Enter instead, whenever the map asks for it.

There is no `onKeyDown` underneath this one. A widget that needs finer key handling than a chord map wraps the field in its own `Focus`.

:::

## Styling a component from outside

::: fw react

Four channels, and they are not interchangeable. Reach for them in this order.

### 1. `className`, for layout

A `className` lands on the one element a reader would point at and call the component: a `PlButton`'s `<button>`, a `PlModal`'s sheet, a field's stack. It joins the component's own classes rather than replacing them, and each component's Props section says which element that is.

It is the right channel for where a component sits and how much room it takes — a `w-full`, a margin, a grid position. Those are properties the library does not set on itself, so nothing is competing for them.

### 2. `classNames`, for the parts `className` cannot reach

Some components draw more than one thing. A field draws its label and the two lines of text under it; a portalled surface paints a scrim behind itself. `classNames` is a map to those parts, and only to those — the component's own surface keeps one prop and not two, so there is never a question of which of them wins.

```tsx
<PlTextField
  label="Email"
  className="w-full"
  classNames={{ control: 'font-mono', error: 'italic' }}
/>
```

The keys mean the same part everywhere they appear: `label`, `control`, `description` and `error` on a labelled control; `backdrop` on a portalled surface.

### 3. Tokens, for anything the component already paints

**This is the one that always works**, and the reason is worth understanding rather than taking on trust.

The library writes its edge, its shadow, its focus ring and its fill as Tailwind _arbitrary properties_ — `[box-shadow:var(--p-elev),var(--p-lift)]` and the like. Tailwind sorts those **last** in the generated stylesheet, and a stylesheet is what decides which of two classes wins. Appending `shadow-none` after one puts it earlier in the file, so it loses.

The custom property underneath does not, because an inline `style` beats every class there is. See [Setting a token from React](./color#setting-a-token-from-react).

### Where a plain `className` loses

The order of two classes in an attribute means nothing. What decides is their order in the generated stylesheet, and Tailwind's sort is by _name_ — numeric scales ascending, everything else alphabetically — which has no relationship to what a caller intended.

| The component writes                    | You write     | Wins              |
| --------------------------------------- | ------------- | ----------------- |
| `text-sm` (at `size="sm"`)              | `text-lg`     | **the component** |
| `bg-transparent` (at `variant="ghost"`) | `bg-red-500`  | **the component** |
| `w-full` (at `fullWidth`)               | `w-auto`      | **the component** |
| `h-10` (at `size="md"`)                 | `h-8`         | **the component** |
| `[box-shadow:…]`                        | `shadow-none` | **the component** |
| `h-10`                                  | `h-12`        | you               |
| `rounded-(--plass-radius-md)`           | `rounded-3xl` | you               |
| `p-4`                                   | `px-8`        | you               |

Two ways out, both reliable:

- **A token**, per the section above. It is the only channel that reaches an arbitrary property at all.
- **The `!` modifier** — `shadow-none!`, `text-lg!`. Nothing in the library is `!important`, so an important utility always wins. The one place it is not optional is `PlTextLink`, whose `.plass-link.plass-link` rule outranks a single class whatever the order.

### It also depends on which stylesheet you imported

| Import | What decides a conflict |
| --- | --- |
| `plass-ui/tailwind.css` or `plass-ui/css/*.css` | Tailwind's sort, per the table above — your classes and the components' are generated in one pass |
| `plass-ui/styles.css` | **The order of your `@import`s.** The package's CSS is already compiled, so it cannot take part in your Tailwind build; import it _before_ your own stylesheet or it outranks everything in it |

### 4. `render`, when the element itself is wrong

Base UI's own prop, passed through where it makes sense — `<PlButton render={<a href="/pricing" />}>`. It replaces the element without changing the surface, which is the thing no amount of CSS can do.

:::

## What a state prop must not do

Three states exist and each has its own axis; a fourth that overlaps one of them is a bug in the API rather than in the styling.

| State      | Native attribute | Focus | Fires handlers |
| ---------- | ---------------- | ----- | -------------- |
| `disabled` | yes              | lost  | no             |
| `readOnly` | `aria-disabled`  | kept  | no             |
| `loading`  | `aria-disabled`  | kept  | no             |

`loading` and `readOnly` keep focus on purpose: dropping out of the tab order costs keyboard users their sense of where they are on the page.
