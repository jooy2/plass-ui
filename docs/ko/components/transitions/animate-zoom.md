---
title: PlAnimateZoom
order: 11
---

# PlAnimateZoom

<p class="plass-lede">끝날 자리의 한가운데에서 도착하는 내용입니다. 화면에서 끼어들어야 하는 단 하나 — 확인, 결과, 방금 나온 숫자 — 에 쓰세요.</p>

<Demo src="animate-zoom/hero" :min-height="280" />

::: fw react

```tsx
import { PlAnimateZoom } from 'plass-ui';

<PlAnimateZoom>
  <PlBox color="success">92</PlBox>
</PlAnimateZoom>;
```

:::

## Props

<PropsTable name="PlAnimateZoom" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과하고, `render`로 요소 자체를 바꿀 수 있습니다.

:::

`origin`은 의도적으로 **없습니다**. 모서리에 고정된 zoom은 grow이고, 라이브러리는 하나의 생각에 두 가지 표기를 주지 않습니다. 옆에 있는 것에서 나와야 한다면 [PlAnimateGrow](./animate-grow)를 쓰세요.

공유되는 열 가지 설정 — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — 은 모든 `PlAnimate*` 컴포넌트에서 같습니다. `trigger`의 네 값은 [PlAnimateFade](./animate-fade) 페이지에 있습니다.

## Examples

### from

기본값이 grow의 두 배가 넘는 거리이고, 그것이 느낌의 차이 전부입니다. `1`보다 작으면 페이지 밖으로 나오고, 크면 실제보다 크게 도착해 제자리로 내려앉습니다. 후자는 읽는 사람 _쪽으로_ 오는 것처럼 읽힙니다.

<Demo src="animate-zoom/from" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-zoom/from.tsx

:::

</Demo>

### 결과 알리기

이 효과가 존재하는 이유입니다. 화면에 하나, 한 번, 그것이 참이 되는 순간에.

<Demo src="animate-zoom/result" :min-height="220">

::: fw react

<<< @/.vitepress/demos/animate-zoom/result.tsx

:::

</Demo>

## Accessibility

::: fw react

- `prefers-reduced-motion`에서는 애니메이션이 통째로 없어지고 내용은 그냥 거기 있습니다.
- wrapper는 role도 label도 붙이지 않습니다. 알려야 하는 결과라면 자체 live region이 필요합니다. 효과는 보는 사람이 보는 것이지, 스크린리더가 듣는 것이 아닙니다.
- 이동 거리가 길어서 글자가 눈에 띄게 다시 샘플링됩니다. 숫자나 글리프, 작은 카드에 두세요. 문단에는 [PlAnimateFade](./animate-fade)가 맞습니다.
- 기본적으로 반복하지 않고, 이 효과는 그대로 두는 편이 좋습니다. 두 번 zoom하는 것은 첫 번째에 도착하지 못한 것입니다.

:::
