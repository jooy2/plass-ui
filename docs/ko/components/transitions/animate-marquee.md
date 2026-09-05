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

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAnimateMarquee(
  gap: 24,
  speed: 45,
  children: <Widget>[for (final String name in names) PlChip(child: Text(name))],
);
```

```

:::

## Props

<PropsTable name="PlAnimateMarquee" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과합니다. 여기에는 `render`가 없습니다. 컴포넌트가 자기 구조 — 사본들을 담아 잘라 내는 상자 — 를 직접 가지고 있어서, 바깥 요소를 바꿔서 얻을 것이 없습니다.

:::

::: fw flutter

`gap`은 논리 픽셀 단위의 `double`이고 `speed`도 그렇습니다 — 초당 논리 픽셀입니다. `duration`은 `Duration?`이라, 두지 않으면 띠를 **재어서** 정합니다. 그것이 `speed`가 있는 이유입니다.

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

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_marquee/speed.dart

:::

</Demo>

### orientation and reverse

세로로 쓰려면 상자에 높이가 있어야 합니다. 잘라 낼 기준이 달리 없습니다. `reverse`는 아래에서 위로, 또는 왼쪽에서 오른쪽으로 돌립니다.

<Demo src="animate-marquee/orientation" :min-height="220">

::: fw react

<<< @/.vitepress/demos/animate-marquee/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_marquee/orientation.dart

:::

</Demo>

## Accessibility

::: fw react

- `prefers-reduced-motion`에서는 띠가 그대로 멈추고 내용은 있던 자리에 남습니다. 위에 있는 것은 전부 문서에 그대로 있고 그대로 닿을 수 있습니다. 슬라이드쇼가 아니라 그냥 한 줄이기 때문입니다.
- **첫 번째 사본만 읽힙니다.** 나머지는 `aria-hidden`을 답니다. 아니면 스크린리더가 띠 위의 모든 것을 깔린 횟수만큼 읽습니다.
- `pauseOnHover`는 기본으로 켜져 있고 장식이 아닙니다. 포인터 앞을 지나가는 내용은 안정적으로 클릭할 수 없고, 멈추지 않는 marquee 안의 링크는 아무도 따라갈 수 없는 링크입니다. focus에서는 멈추지 **않으므로**, 키보드로 닿아야 하는 내용이 띠 위에 있다면 정적인 목록을 쓰는 편이 낫습니다.
- 반드시 읽혀야 하는 것은 여기에 두지 마세요. 읽는 사람은 당신이 고른 속도로 한 번 지나가는 것을 볼 뿐이고, 되돌릴 방법이 없습니다.

:::

::: fw flutter

- 플랫폼에서 애니메이션이 꺼져 있으면(`MediaQuery.disableAnimations`) 띠는 시작한 자리에 서 있습니다. 위에 있는 것은 전부 트리에 그대로 있고 그대로 닿을 수 있습니다. 슬라이드쇼가 아니라 그냥 한 줄이기 때문입니다.
- **첫 번째 사본만 읽힙니다.** 나머지는 `ExcludeSemantics` 뒤에 있습니다. 아니면 스크린리더가 띠 위의 모든 것을 깔린 횟수만큼 읽습니다.
- `pauseOnHover`는 기본으로 켜져 있고 장식이 아닙니다. 포인터 앞을 지나가는 내용은 안정적으로 누를 수 없습니다. focus에서는 멈추지 **않으므로**, focus를 받아야 하는 내용이 띠 위에 있다면 정적인 목록을 쓰는 편이 낫습니다.
- 반드시 읽혀야 하는 것은 여기에 두지 마세요. 읽는 사람은 당신이 고른 속도로 한 번 지나가는 것을 볼 뿐이고, 되돌릴 방법이 없습니다.

:::


::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| 첫 사본 이후에 붙는 `aria-hidden` | `ExcludeSemantics` | 같은 제외에 대한 프레임워크 자신의 이름입니다. |
| 상자의 `overflow: hidden` | `clipBehavior: Clip.hardEdge`인 `UnconstrainedBox` | 띠는 의도적으로 상자보다 깁니다. 그래서 주축을 무제한으로 두고 레이아웃해야 합니다. 자르기만 해서는 페인트만 잘리고 flex가 넘쳤다고 단언합니다. |
| `-100% - gap`의 translate, 아무것도 재지 않음 | 띠를 재어 그만큼의 픽셀로 이동 | CSS의 백분율 translate는 요소 자기 상자를 기준으로 풀립니다. 여기서는 측정이 거리와 duration을 둘 다 정하고, 띠 크기가 바뀔 때마다 다시 잽니다. |
| `gap`이 CSS 길이 | `double` | 논리 픽셀입니다. |
| reduced motion에서 `animation: none` | `t`를 `0`에 붙들어 둠 | 같은 결과를 두 가지로 말한 것입니다. marquee의 완료 상태는 내용이 시작한 자리에 서 있는 것이고, 등장의 완료 상태와는 반대입니다. |
| `duration`, `delay`가 밀리초 | `Duration` | 프레임워크에 이미 타입이 있습니다. |
| `easing`이 CSS 문자열 | `curve`, `Curve` | 같은 것에 대한 Dart 자신의 이름입니다. |
| `repeat: number \| 'infinite'` | `int?`, `null`이 멈추지 않음 | 적을 `'infinite'`가 없고, `-1`은 caller가 찾아봐야 하는 sentinel입니다. |
| `trigger="visible"`이 `IntersectionObserver` | 가장 가까운 `Scrollable`을 봅니다 | 여기에는 observer가 없습니다. 위에 scrollable이 없으면 볼 것이 없으므로 그냥 돕니다. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | 플랫폼 자신의 신호입니다. |
| `className`, `style` | — | 통과시킬 class 목록도 style 속성도 없습니다. |

:::
```
