---
title: PlAnimateMarquee
order: 7
---

# PlAnimateMarquee

<p class="plass-lede">끝없이 일정하게 흘러가는 내용입니다. 내용이 두 번 깔려 있어서, 첫 번째 사본이 빠져나간 순간 두 번째 사본이 정확히 그것이 시작했던 자리에 서 있습니다. 이음매도, 튐도, 빈 프레임도 없습니다.</p>

<Demo src="animate-marquee/hero" :min-height="120" />

::: fw react

```tsx
import { PlAnimateMarquee } from 'plass-ui';

<PlAnimateMarquee gap="1.5rem" speed={45}>
  {names.map((name) => (
    <PlChip key={name}>{name}</PlChip>
  ))}
</PlAnimateMarquee>;
```

:::

## Props

<PropsTable name="PlAnimateMarquee" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과합니다. 여기에는 `render`가 없습니다. 컴포넌트가 자기 구조 — 사본들을 담아 잘라 내는 상자 — 를 직접 가지고 있어서, 바깥 요소를 바꿔서 얻을 것이 없습니다.

:::

`mode`도 `from`도 `fade`도 없습니다. marquee는 도착이 아니라 순환입니다.

나머지 공유 설정 — `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — 은 다른 곳에서와 같은 뜻입니다. `duration`만이 예외입니다. 두지 않으면 띠를 **재어서** 정하고, 그것이 `speed`가 있는 이유입니다.

## Examples

### speed

duration이 아니라 speed입니다. 그래서 로고 넷짜리 띠와 마흔짜리 띠가 같은 속도로 움직이지, 긴 쪽이 흐릿해지지 않습니다. 단위는 초당 픽셀이고, 띠는 크기가 바뀔 때마다 다시 재집니다. `duration`을 주면 측정을 통째로 덮어씁니다.

<Demo src="animate-marquee/speed" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-marquee/speed.tsx

:::

</Demo>

### orientation and reverse

세로로 쓰려면 상자에 높이가 있어야 합니다. 잘라 낼 기준이 달리 없습니다. `reverse`는 아래에서 위로, 또는 왼쪽에서 오른쪽으로 돌립니다.

<Demo src="animate-marquee/orientation" :min-height="220">

::: fw react

<<< @/.vitepress/demos/animate-marquee/orientation.tsx

:::

</Demo>

## Accessibility

::: fw react

- `prefers-reduced-motion`에서는 띠가 그대로 멈추고 내용은 있던 자리에 남습니다. 위에 있는 것은 전부 문서에 그대로 있고 그대로 닿을 수 있습니다. 슬라이드쇼가 아니라 그냥 한 줄이니까요.
- **첫 번째 사본만 읽힙니다.** 나머지는 `aria-hidden`을 답니다. 아니면 스크린리더가 띠 위의 모든 것을 깔린 횟수만큼 읽습니다.
- `pauseOnHover`는 기본으로 켜져 있고 장식이 아닙니다. 포인터 앞을 지나가는 내용은 안정적으로 클릭할 수 없고, 멈추지 않는 marquee 안의 링크는 아무도 따라갈 수 없는 링크입니다. focus에서는 멈추지 **않으므로**, 키보드로 닿아야 하는 내용이 띠 위에 있다면 정적인 목록을 쓰는 편이 낫습니다.
- 반드시 읽혀야 하는 것은 여기에 두지 마세요. 읽는 사람은 당신이 고른 속도로 한 번 지나가는 것을 볼 뿐이고, 되돌릴 방법이 없습니다.

:::
