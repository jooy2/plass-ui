---
title: usePlElementSize
order: 7
---

# usePlElementSize

<p class="plass-lede">How big an element is, kept up to date as it changes. A <code>ResizeObserver</code> with the two things a hook has to add: when the first measurement happens, and which box it reports.</p>

<Demo src="hooks/element-size" :min-height="220" :flutter="false" />

::: fw react

```tsx
import { usePlElementSize } from 'plass-ui';

const box = useRef<HTMLDivElement>(null);
const size = usePlElementSize(box);
```

:::

::: fw flutter

Hooks are React-only. Flutter asks the same question of a `LayoutBuilder`, which already rebuilds when the constraints change:

```dart
LayoutBuilder(
  builder: (BuildContext context, BoxConstraints constraints) => Text('${constraints.maxWidth}'),
);
```

:::

## Signature

```ts
function usePlElementSize(
  target: RefObject<HTMLElement | null>
): { width: number; height: number } | null;
```

|          |                                                               |
| -------- | ------------------------------------------------------------- |
| `target` | A ref to the element to measure.                              |
| returns  | Its content box, or `null` while there is nothing to measure. |

## The first measurement

A `ResizeObserver`'s first callback arrives **after a frame has been painted**. A component that laid itself out from `0 × 0` for that frame flashes, and on a slow device it flashes visibly.

So the size is read in a **layout effect** as well, which runs before the browser paints. The observer then keeps it up to date.

## The box it reports

The room actually left inside the element once its own padding has been taken off.

A hand-written version nearly always reports `getBoundingClientRect()` or the observer's `borderBoxSize` instead, and those are a different number: they include the padding and the border. For the question that made somebody measure an element, how much room is there for what goes inside it, those are the wrong number.

## Examples

### Sizing something to its container

```tsx
const frame = useRef<HTMLDivElement>(null);
const size = usePlElementSize(frame);

<div ref={frame}>{size ? <Chart width={size.width} height={size.height} /> : null}</div>;
```

The `null` matters here: guessing `0` on the first render would let a caller divide by it.

### Deciding a layout from the element rather than the window

A [`usePlMediaQuery`](./use-media-query) asks about the **window**. This asks about the element, which is the right question for a component that can be dropped into a sidebar as easily as into a page.

```tsx
const size = usePlElementSize(panel);
const roomy = (size?.width ?? 0) > 480;
```

## Notes

- The same object is handed back when nothing moved, so a resize somewhere else on the page does not re-render every caller.
- A browser with no `ResizeObserver` gets **one** measurement rather than none: a layout that is right until something moves beats a layout that is never right.
- `null` on a server and on the first render, which is the honest answer where there is no element yet.
