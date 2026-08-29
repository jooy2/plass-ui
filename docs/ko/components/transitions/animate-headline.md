---
title: PlAnimateHeadline
order: 5
---

# PlAnimateHeadline

<p class="plass-lede">한 줄이 위의 줄을 대신합니다, 타이머에 맞춰서. 모든 줄이 같은 그리드 칸에 있어서 상자는 첫 프레임부터 가장 긴 줄만큼 크고, 릴이 돌아도 크기가 변하지 않습니다.</p>

<Demo src="animate-headline/hero" :min-height="180" />

::: fw react

```tsx
import { PlAnimateHeadline } from 'plass-ui';

<PlAnimateHeadline interval={2200}>
  <span>ships on Friday</span>
  <span>reads like prose</span>
  <span>weighs almost nothing</span>
</PlAnimateHeadline>;
```

:::

## Props

<PropsTable name="PlAnimateHeadline" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과합니다. `render`도 `alternate`도 없습니다. 컴포넌트가 자기 그리드를 가지고 있고, 릴에는 돌아갈 다른 방향이 없습니다.

:::

`interval`은 주기의 시작이 아니라 **줄이 도착한 순간부터** 셉니다. 그래서 `duration`을 올려도 읽는 시간이 조용히 깎이지 않습니다.

나머지 공유 설정 — `duration`, `delay`, `easing`, `repeat`, `paused`, `trigger`, `play`, `once`, `threshold` — 은 다른 곳에서와 같은 뜻입니다. `delay`는 릴이 돌기 시작하기 전에 일어나는 일이므로 줄마다가 아니라 한 번만 더해집니다.

## Examples

### Controlled

`index`를 넘기면 릴이 자기 타이머를 돌리지 않습니다. controlled headline은 다른 누군가의 시계이고, 그 아래에서 두 번째 시계가 돌면 같은 상태를 두고 다투게 됩니다. 폼의 단계, 탭, 또는 직접 가진 타이머로 돌리세요.

<Demo src="animate-headline/controlled" :min-height="220">

::: fw react

<<< @/.vitepress/demos/animate-headline/controlled.tsx

:::

</Demo>

### rise

줄이 올라오거나 나갈 때 이동하는 거리입니다. `'100%'`는 줄 하나의 높이이고, 릴처럼 읽히게 만드는 것이 그것입니다. 몇 픽셀이면 방향이 살짝 있는 crossfade에 가깝습니다.

<Demo src="animate-headline/rise" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-headline/rise.tsx

:::

</Demo>

## Accessibility

::: fw react

- `prefers-reduced-motion`에서도 줄은 바뀌지만 미끄러지지는 않습니다. 나가는 줄은 애니메이션 없이 사라집니다. 릴 자체가 내용이므로, 통째로 끄면 첫 줄만 남습니다.
- **읽는 사람이 반드시 봐야 하는 내용에는 쓰지 마세요.** 한 줄이 떠 있는 2초 동안 누가 보고 있으리라는 보장이 없고, 스크린리더는 묶음이 아니라 마침 떠 있는 줄을 받습니다. 어느 것이었어도 괜찮았을 문구들에 쓰세요.
- 모든 줄은 첫 프레임부터 문서에 있고, 떠 있지 않은 줄은 레이아웃에서 빠지는 대신 `visibility`로 자리를 지킵니다. 상자가 크기를 바꾸지 않는 이유이고, 아무것도 두 번 읽히지 않는 이유이기도 합니다.
- 자연스러운 끝이 있는 것이라면 `loop={false}`를 생각해 보세요. 멈추지 않는 릴은 누군가 읽고 있는 페이지 구석의 움직임입니다.

:::
