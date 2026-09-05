---
title: usePlOnScreen
order: 8
---

# usePlOnScreen

<p class="plass-lede">Whether an element is on screen. An <code>IntersectionObserver</code> with the three things a hook has to decide — and the interesting one is that it stops watching once it has seen it.</p>

<Demo src="hooks/on-screen" :min-height="260" :flutter="false" />

::: fw react

```tsx
import { usePlOnScreen } from 'plass-ui';

const section = useRef<HTMLDivElement>(null);
const seen = usePlOnScreen(section, { rootMargin: '200px' });
```

:::

::: fw flutter

Hooks are React-only, and the Flutter half of this lives inside the widgets that need it: every `PlAnimate*` takes `trigger: PlassAnimateTrigger.visible` and does its own watching against the nearest `Scrollable`.

:::

## Signature

```ts
function usePlOnScreen(
  target: RefObject<Element | null>,
  options?: {
    threshold?: number;
    rootMargin?: string;
    root?: RefObject<Element | null>;
    once?: boolean;
  }
): boolean;
```

|              |                                                                          |
| ------------ | ------------------------------------------------------------------------ |
| `target`     | A ref to the element to watch.                                           |
| `threshold`  | How much of it has to be showing to count, `0`…`1`. `0` by default.      |
| `rootMargin` | How far outside still counts — `'200px'` starts a fetch a screen early.  |
| `root`       | What it is measured against. The viewport when it is not given.          |
| `once`       | Stops watching the first time it appears. **On by default** — see below. |
| returns      | `true` once it is on screen.                                             |

## once is on

The question a caller almost always has is "**has this been seen yet**", not "is it on screen right now": a lazily loaded picture, a section that animates once, a page that fetches the next batch. All three want the first answer, and none of them wants to be told again.

A hook that kept answering the second question would re-render a page of lazily loaded pictures every time the reader scrolled past any of them, for nothing.

Turn it off for the answer that genuinely keeps changing — a floating bar that appears once a section has left the screen, a video that pauses when it is scrolled away from.

## The first answer

**`false`** on a server and on the first render, which is the safe answer for both of the things this is used for: nothing is fetched that did not need to be, and nothing plays before a reader could see it.

**`true`** in a browser with no `IntersectionObserver`. There is no way to find out there, and a picture that never loads is worse than one that loads early.

## Examples

### A picture that loads a screen early

```tsx
const frame = useRef<HTMLDivElement>(null);
const near = usePlOnScreen(frame, { rootMargin: '400px' });

<div ref={frame}>{near ? <PlImage src={src} alt={alt} ratio="16 / 9" /> : null}</div>;
```

### Inside a scrolling panel rather than the page

```tsx
const seen = usePlOnScreen(row, { root: panel });
```

## Notes

- For an **animation** that plays when it arrives, reach for the `trigger="visible"` every `PlAnimate*` already takes rather than wiring this up by hand. It is the same observer with the effect attached.
- It disconnects on unmount, and — with `once` — the moment it has an answer.
