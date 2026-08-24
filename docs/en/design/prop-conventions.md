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

## What a state prop must not do

Three states exist and each has its own axis; a fourth that overlaps one of them is a bug in the API rather than in the styling.

| State      | Native attribute | Focus | Fires handlers |
| ---------- | ---------------- | ----- | -------------- |
| `disabled` | yes              | lost  | no             |
| `readOnly` | `aria-disabled`  | kept  | no             |
| `loading`  | `aria-disabled`  | kept  | no             |

`loading` and `readOnly` keep focus on purpose: dropping out of the tab order costs keyboard users their sense of where they are on the page.
