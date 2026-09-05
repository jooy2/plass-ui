---
title: usePlMediaQuery
order: 1
---

# usePlMediaQuery

<p class="plass-lede">Whether the window matches a CSS media query, as a boolean that re-renders when the answer changes. The library has always had this; it is public now because writing it by hand is three lines that are nearly always subscribed one render too late.</p>

<Demo src="hooks/media-query" :min-height="200" />

::: fw react

```tsx
import { usePlMediaQuery } from 'plass-ui';

const coarse = usePlMediaQuery('(pointer: coarse)');
```

:::

::: fw flutter

Hooks are React-only. Flutter asks the same question of `MediaQuery`, which is already an inherited widget and already rebuilds:

```dart
final wide = MediaQuery.sizeOf(context).width >= 768;
```

:::

## Signature

```ts
function usePlMediaQuery(query: string): boolean;
```

|         |                                                                      |
| ------- | -------------------------------------------------------------------- |
| `query` | Any CSS media query, written exactly as a stylesheet would write it. |
| returns | `true` while the window matches it.                                  |

It is also available from `plass-ui/hooks` for a project that wants the hooks without the barrel.

## The first answer

There is no window to measure while HTML is being generated, so this returns `false` on the server **and through the render that hydrates it**. The real answer arrives in the render after that.

That is not a limitation to work around. It is what `useSyncExternalStore` guarantees, and it is why the library's own components pair the hook with a CSS class rather than replacing one with the other. A `PlSidebar` ships the column in its markup and hides it below the breakpoint with a Tailwind variant, so a phone never paints a full-width sidebar; the hook is only what decides, once there is a window to ask, that the drawer should exist at all.

> Anything that must be right in the **first** frame belongs in CSS. Reach for this when the decision is one CSS cannot make, whether a component is mounted, how many rows to fetch, which of two behaviours a handler takes.

## Examples

### A query the design system does not have

The breakpoint ladder covers width. Everything else a page might want to know, the pointer, the colour scheme, the reader's motion preference, whether the display is high-density. Is a query and nothing more.

```tsx
const coarse = usePlMediaQuery('(pointer: coarse)');
const dark = usePlMediaQuery('(prefers-color-scheme: dark)');
const dense = usePlMediaQuery('(resolution >= 2dppx)');
```

### Mounting rather than hiding

The case CSS genuinely cannot answer. `display: none` still builds the subtree, still runs its effects and still fetches whatever it fetches.

```tsx
const wide = usePlMediaQuery('(width >= 64rem)');

return wide ? <PlTable columns={columns} rows={rows} /> : <PlList>{…}</PlList>;
```

## Notes

- One `MediaQueryList` is kept per query string and shared by every component that asks for it, so a page with twenty responsive components installs one listener rather than twenty.
- The query is read by the same engine the stylesheet is read by, so `(width >= 48rem)` here and `md:` in a class name change at the same moment, including when the reader has changed their root font size, which a measured `innerWidth` would get wrong.
- A browser with no `matchMedia` answers `false` rather than throwing.
