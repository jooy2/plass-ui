---
title: PlAnimateSlide
order: 9
---

# PlAnimateSlide

<p class="plass-lede">한쪽 모서리에서 들어오는 내용입니다. 기본 이동 거리가 요소 자신의 크기라서, 정확히 화면 밖에서 시작하고 있어서는 안 될 자리에 반쯤 그려지는 일이 없습니다.</p>

<Demo src="animate-slide/hero" :min-height="280" />

::: fw react

```tsx
import { PlAnimateSlide } from 'plass-ui';

<div className="overflow-hidden">
  <PlAnimateSlide from="right">
    <PlCard title="New message">Ada replied to your review.</PlCard>
  </PlAnimateSlide>
</div>;
```

:::

## Props

<PropsTable name="PlAnimateSlide" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과하고, `render`로 요소 자체를 바꿀 수 있습니다.

:::

`from`은 라이브러리 전체의 `PlassSide`가 그렇듯 **물리적**입니다 — `top`, `right`, `bottom`, `left`. 위에서 내려오는 패널은 어떤 쓰기 방향에서도 위에서 내려옵니다.

공유되는 열 가지 설정 — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — 은 모든 `PlAnimate*` 컴포넌트에서 같습니다. `trigger`의 네 값은 [PlAnimateFade](./animate-fade) 페이지에 있습니다.

## Examples

### from

네 개의 모서리이고, `mode="out"`은 도착했을 그 모서리로 나갑니다.

<Demo src="animate-slide/sides" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-slide/sides.tsx

:::

</Demo>

### distance

숫자는 픽셀이고, 문자열은 어떤 CSS 길이든 됩니다. `'100%'`는 요소 자신의 너비나 높이입니다. `overflow: hidden`인 상자에 넣으면 그 상자의 모서리 뒤에서 패널이 나타나는 효과가 됩니다. 짧은 거리는 다른 몸짓입니다. 등장이 아니라 무언가 바뀌었다고 말하는 툭 침이죠.

<Demo src="animate-slide/distance" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-slide/distance.tsx

:::

</Demo>

## Accessibility

::: fw react

- `prefers-reduced-motion`에서는 애니메이션이 통째로 없어지고 내용은 그냥 거기 있습니다.
- 실행되는 동안 페이지의 어떤 것도 reflow하지 않습니다. 레이아웃 변화가 아니라 `translate`이므로 요소 *주변*은 움직이지 않습니다.
- 화면 밖에서 시작하는 slide는 담고 있는 상자가 잘라 내지 않으면 넘칩니다. 잘라 내세요. 아니면 애니메이션이 도는 동안 페이지에 스크롤바가 생깁니다.
- 목록을 훨씬 짧은 거리로 하나씩 지나가게 하려면 [PlAnimateAppear](./animate-appear)를 쓰세요. 그 효과를 만드는 것은 시차이고, 자식마다 slide를 두면 delay를 직접 써야 합니다.

:::
