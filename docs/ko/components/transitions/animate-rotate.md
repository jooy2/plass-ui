---
title: PlAnimateRotate
order: 8
---

# PlAnimateRotate

<p class="plass-lede">한 점을 중심으로 도는 내용입니다. 각도가 하나가 아니라 둘이라서, 컴포넌트 하나가 제자리로 들어오는 4분의 1 회전과 끝나지 않는 회전을 모두 담습니다.</p>

<Demo src="animate-rotate/hero" :min-height="180" />

::: fw react

```tsx
import { PlAnimateRotate } from 'plass-ui';

<PlAnimateRotate from={0} to={360} duration={2400} easing="linear" repeat="infinite" fade={false}>
  <PlIcon icon={<RefreshGlyph />} label="Syncing" />
</PlAnimateRotate>;
```

:::

## Props

<PropsTable name="PlAnimateRotate" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과하고, `render`로 요소 자체를 바꿀 수 있습니다.

:::

공유되는 열 가지 설정 — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — 은 모든 `PlAnimate*` 컴포넌트에서 같습니다. `trigger`의 네 값은 [PlAnimateFade](./animate-fade) 페이지에 있습니다.

## Examples

### from and to

`from`만 있으면 도착입니다. 무언가 제자리로 들어와 멈춥니다. `from`과 `to`를 `repeat="infinite"`, `easing="linear"`와 함께 쓰면 끝나지 않는 회전이 됩니다. 배지나 로딩 표시, 장식용 글리프가 원하는 것이죠. 후자에서는 `fade`를 끄세요. 반복되는 fade는 깜빡임으로 읽힙니다.

<Demo src="animate-rotate/spin" :min-height="160">

::: fw react

<<< @/.vitepress/demos/animate-rotate/spin.tsx

:::

</Demo>

### origin

CSS `transform-origin`이면 무엇이든 됩니다. 모서리를 중심으로 도는 것은 바퀴가 아니라 경첩이고, 깃발이나 태그, 더미에 놓이는 카드가 원하는 것입니다.

<Demo src="animate-rotate/origin" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-rotate/origin.tsx

:::

</Demo>

## Accessibility

::: fw react

- `prefers-reduced-motion`에서는 애니메이션이 통째로 없어지고 내용은 그냥 거기 있습니다. 도착에는 맞는 처리이고, 회전에는 한 번 생각해 볼 문제입니다. 도는 것 자체가 *무언가 진행 중*이라고 말하고 있다면 [PlProgressCircular](../feedback/progress-circular)를 쓰세요. 그쪽은 멈추는 대신 느려집니다.
- **글자에는 쓰지 마세요.** 회전한 단어는 길이 전체에 걸쳐 다시 샘플링됩니다. 회전은 디자인 언어가 글리프 위에서 이견 없이 허용하는 유일한 움직임이고 — 라이브러리 전체에서 chevron은 다시 그려지는 대신 돌아갑니다 — 그것이 이 효과가 겨냥하는 종류의 것입니다.
- 누군가 읽고 있는 페이지의 구석에서 끝없이 도는 것은 이 라이브러리의 나머지가 거부하는 유일한 종류의 움직임입니다. 이유를 주세요.

:::
