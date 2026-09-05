---
title: PlAnimateSlide
order: 10
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

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const ClipRect(
  child: PlAnimateSlide(
    from: PlassSide.right,
    child: PlCard(title: Text('New message'), child: Text('Ada replied to your review.')),
  ),
);
```

```

:::

## Props

<PropsTable name="PlAnimateSlide" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과하고, `render`로 요소 자체를 바꿀 수 있습니다.

:::

::: fw flutter

`distance`는 논리 픽셀 단위의 `double?`이고, **기본값인 `null`이 widget 자신의 너비나 높이**입니다. 적을 CSS 길이가 없습니다. widget 자기 크기에 대한 비율은 `FractionalTranslation`이 이미 뜻하는 것이고, 거리가 주어지지 않으면 widget이 그것을 씁니다.

:::

`from`은 라이브러리 전체의 `PlassSide`가 그렇듯 **물리적**입니다 — `top`, `right`, `bottom`, `left`. 위에서 내려오는 패널은 어떤 쓰기 방향에서도 위에서 내려옵니다.

공유되는 열 가지 설정 — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — 은 모든 `PlAnimate*` 컴포넌트에서 같습니다. `trigger`의 네 값은 [PlAnimateFade](./animate-fade) 페이지에 있습니다.

::: fw react

세 가지가 더 있고, 이들은 효과를 상자에서 떼어 안의 것들로 옮깁니다. `stagger`는 각 자식을 자기 위치만큼 뒤로 미루고, `durationStep`은 자식마다 앞의 것보다 길거나 짧은 재생 시간을 주며, `reverse`는 집합의 끝에서부터 시작합니다. 키프레임 하나짜리 효과 여섯 개 모두에 있고, [PlAnimateFade](./animate-fade) 페이지에 설명이 있습니다. `timeline="view"`와 `range`도 같은 자리에 있고, 효과를 시계가 아니라 독자의 스크롤 위치에 맡깁니다.

:::

## Examples

### from

네 개의 모서리이고, `mode="out"`은 도착했을 그 모서리로 나갑니다.

<Demo src="animate-slide/sides" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-slide/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_slide/sides.dart

:::

</Demo>

### distance

숫자는 픽셀이고, 문자열은 어떤 CSS 길이든 됩니다. `'100%'`는 요소 자신의 너비나 높이입니다. `overflow: hidden`인 상자에 넣으면 그 상자의 모서리 뒤에서 패널이 나타나는 효과가 됩니다. 짧은 거리는 다른 몸짓입니다. 등장이 아니라 무언가 바뀌었다고 말하는 툭 침이죠.

<Demo src="animate-slide/distance" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-slide/distance.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_slide/distance.dart

:::

</Demo>

## Accessibility

::: fw react

- `prefers-reduced-motion`에서는 애니메이션이 통째로 없어지고 내용은 그냥 거기 있습니다.
- 실행되는 동안 페이지의 어떤 것도 reflow하지 않습니다. 레이아웃 변화가 아니라 `translate`이므로 요소 *주변*은 움직이지 않습니다.
- 화면 밖에서 시작하는 slide는 담고 있는 상자가 잘라 내지 않으면 넘칩니다. 잘라 내세요. 아니면 애니메이션이 도는 동안 페이지에 스크롤바가 생깁니다.
- 목록을 훨씬 짧은 거리로 하나씩 지나가게 하려면 [PlAnimateAppear](./animate-appear)를 쓰세요. 그 효과를 만드는 것은 시차이고, 자식마다 slide를 두면 delay를 직접 써야 합니다.

:::

::: fw flutter

- 플랫폼에서 애니메이션이 꺼져 있으면(`MediaQuery.disableAnimations`) 효과가 통째로 없어지고 내용은 그냥 거기 있습니다.
- 실행되는 동안 주변의 어떤 것도 다시 레이아웃되지 않습니다. 레이아웃 변화가 아니라 widget을 움직이는 것입니다.
- 화면 밖에서 시작하는 slide는 담고 있는 상자가 잘라 내지 않으면 넘칩니다. `ClipRect`로 감싸세요.
- 목록을 훨씬 짧은 거리로 하나씩 지나가게 하려면 [PlAnimateAppear](./animate-appear)를 쓰세요.

:::


::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `distance`가 CSS 길이 또는 숫자 | `double?`, `null`이 자기 크기 | widget 자기 크기에 대한 비율은 `FractionalTranslation`이 이미 뜻하는 것이라, 문자열로 적을 것이 없습니다. |
| `mode="in" \| "out"` | `PlassAnimateMode.enter` / `.exit` | `in`은 Dart의 예약어입니다. |
| wrapper의 `overflow: hidden` | `ClipRect` | 같은 잘라 내기에 대한 프레임워크 자신의 이름입니다. |
| `render` | — | Flutter에는 다형적 요소가 없습니다. |
| `duration`, `delay`가 밀리초 | `Duration` | 프레임워크에 이미 타입이 있습니다. |
| `easing`이 CSS 문자열 | `curve`, `Curve` | 같은 것에 대한 Dart 자신의 이름입니다. |
| `repeat: number \| 'infinite'` | `int?`, `null`이 멈추지 않음 | 적을 `'infinite'`가 없고, `-1`은 caller가 찾아봐야 하는 sentinel입니다. |
| `trigger="visible"`이 `IntersectionObserver` | 가장 가까운 `Scrollable`을 봅니다 | 여기에는 observer가 없습니다. 위에 scrollable이 없으면 볼 것이 없으므로 그냥 돕니다. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | 플랫폼 자신의 신호입니다. |
| `stagger`, `durationStep`, `reverse` | — | React 빌드는 효과를 자식들 자신에게 써 넣으므로 호출자의 레이아웃은 그대로입니다. Flutter에는 집합을 배치할 스타일시트가 없어서, 차등을 준 효과는 행이나 열까지 자기가 가져야 합니다. 그것이 바로 [`PlAnimateAppear`](./animate-appear)이고, 그것을 여섯 개 더 만드는 일이 됩니다. |
| `timeline="view"` | — | `animation-timeline`은 여기에 대응물이 없는 CSS 속성입니다. Flutter에서 스크롤 연동 효과는 `ScrollPosition`으로 구동하는 `AnimationController`이고, 위젯이 prop으로 받는 것이 아니라 애플리케이션 자신의 배선입니다. |
| `className`, `style` | — | 통과시킬 class 목록도 style 속성도 없습니다. |

:::
```
