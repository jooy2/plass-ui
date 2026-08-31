---
title: usePlReducedMotion
order: 3
---

# usePlReducedMotion

<p class="plass-lede">Whether the reader has asked their platform for less movement. The library already answers it everywhere it moves; this is the same answer, for the motion an application writes itself.</p>

<Demo src="hooks/reduced-motion" :min-height="260" />

::: fw react

```tsx
import { usePlReducedMotion } from 'plass-ui';

const still = usePlReducedMotion();
```

:::

::: fw flutter

Hooks are React-only. Flutter asks `MediaQuery`, which rebuilds on its own:

```dart
final still = MediaQuery.disableAnimationsOf(context);
```

:::

## Signature

```ts
function usePlReducedMotion(): boolean;
```

`true` while the platform reports `prefers-reduced-motion: reduce`. It re-renders when that changes, so a reader who turns the setting on does not have to reload.

## "Reduced" is not "none"

The library's own components disagree with each other here, on purpose, and the disagreement is the useful part:

| Kind of motion | What Plass does | Why |
| --- | --- | --- |
| An entrance — `PlAnimateFade`, `PlAnimateSlide` | Dropped entirely; the content is simply there | An animation that never played has still delivered everything it was carrying |
| A loading indicator — `PlProgressCircular` | **Slowed**, never stopped | A spinner that stopped would be lying about whether anything is still happening |
| A decorative loop — `PlAnimateBlink`, a spin | Dropped | Nothing was being said |

Which of those an effect is, is the question to answer before reaching for this hook. If the movement is what carries the message, take the message out of the movement rather than switching the movement off.

## Examples

### Motion written in JavaScript

CSS keyframes are already handled — every one in the stylesheet is switched off at once by a media query. This is for the movement there is no rule to switch off.

```tsx
const still = usePlReducedMotion();

element.scrollIntoView({ behavior: still ? 'auto' : 'smooth' });
```

### A count that lands rather than counts up

```tsx
const still = usePlReducedMotion();

return still ? <>{total}</> : <CountUp to={total} />;
```

## Notes

- The server's answer is `false` — it has no reader and so no preference — and so is the first answer in a browser. That is the safe direction: the preference arrives in the render after hydration, before any of this has had a frame to run in. The same rule [`usePlMediaQuery`](./use-media-query) explains.
- It is `usePlMediaQuery('(prefers-reduced-motion: reduce)')` with a name on it, and the name is the point — the query is easy to typo and the mistake is silent.
