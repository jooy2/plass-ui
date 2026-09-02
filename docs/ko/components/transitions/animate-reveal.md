---
title: PlAnimateReveal
order: 8
---

# PlAnimateReveal

<p class="plass-lede">움직이는 가장자리 뒤로 드러나는 내용. 아무것도 움직이지 않고 어떤 색도 바뀌지 않는 유일한 등장입니다 — 이미 그려진 픽셀은 전부 최종적으로 있게 될 그 자리에 있습니다.</p>

<Demo src="animate-reveal/hero" :min-height="220" />

::: fw react

```tsx
import { PlAnimateReveal } from 'plass-ui';

<PlAnimateReveal render={<h2 />}>Everything is where it was.</PlAnimateReveal>;

<PlAnimateReveal from="top" trigger="visible" duration={700}>
  <PlDivider />
</PlAnimateReveal>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateReveal(child: PlTypography('Everything is where it was.', level: PlTypographyLevel.h3));

const PlAnimateReveal(
  from: PlassSide.top,
  trigger: PlassAnimateTrigger.visible,
  duration: Duration(milliseconds: 700),
  child: PlDivider(),
);
```

:::

## Props

<PropsTable name="PlAnimateReveal" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과하고, `render`로 요소 자체를 바꿀 수 있습니다. 이 세트에서 `render`가 가장 자주 필요한 것이 이 컴포넌트입니다. reveal은 보통 이미 제 요소를 가진 제목이나 구분선을 감싸기 때문입니다.

:::

::: fw flutter

클립은 **그리는 시점**에 적용되므로 widget은 자기 크기 그대로 한 번 배치되고, 옆에 있는 것들은 다시 배치되지 않습니다. `widthFactor`를 준 `Align`과의 차이가 이것입니다. 그쪽은 상자 크기를 바꾸어 이웃들을 밀어냅니다.

:::

`from`은 라이브러리 전체가 그렇듯 **물리적**입니다 — `top`, `right`, `bottom`, `left`. 위에서 걷히는 제목은 어떤 쓰기 방향에서도 위에서 걷힙니다.

공유되는 열 가지 설정 — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — 은 모든 `PlAnimate*` 컴포넌트에서 같습니다. `trigger`의 네 값은 [PlAnimateFade](./animate-fade) 페이지에 있습니다. `timeline="view"`와 `range`도 같은 자리에 있고, 효과를 시계가 아니라 독자의 스크롤 위치에 맡깁니다.

::: fw react

세 가지가 더 있고, 이들은 효과를 상자에서 떼어 안의 것들로 옮깁니다. `stagger`는 각 자식을 자기 위치만큼 뒤로 미루고, `durationStep`은 자식마다 앞의 것보다 길거나 짧은 재생 시간을 주며, `reverse`는 집합의 끝에서부터 시작합니다. 키프레임 하나짜리 효과 여섯 개 모두에 있고, [PlAnimateFade](./animate-fade) 페이지에 설명이 있습니다.

:::

## 어떤 등장인가

세트에는 도착하는 방법이 다섯 가지 더 있고, 그 하나하나가 도착하면서 요소의 무언가를 바꿉니다. 이것은 **요소가 얼마나 그려졌는지**를 바꾸고 그 외에는 아무것도 바꾸지 않습니다.

- [PlAnimateFade](./animate-fade)는 잉크를 바꿉니다. 어떤 크기의 글 덩어리에도 안전하고 가장 먼저 손이 가야 하는 것이지만, 흐려졌다 나타난 제목은 독자가 두 번 읽어야 하는 제목입니다.
- [PlAnimateSlide](./animate-slide)는 위치를 바꿉니다. "이건 어디선가 도착했다"고 말하는데, 두 섹션 사이에 처음부터 있어야 했던 구분선에 대해서는 거짓말입니다.
- [PlAnimateGrow](./animate-grow)와 [PlAnimateZoom](./animate-zoom)은 크기를 바꾸므로, 안의 글자가 매 프레임 리샘플링됩니다.
- **PlAnimateReveal은 둘 다 바꾸지 않습니다.** 위치 자체가 정보인 곳에 쓰세요. 자기가 속한 문단 위의 제목, 두 섹션 사이의 구분선, 차트의 플롯 영역, 엉뚱한 자리에서 읽히면 안 되는 숫자 열.

배치 비용도 다섯 중 가장 쌉니다. 배치할 것이 없기 때문입니다. 래퍼도, `overflow` 상자도, 흐름에 들어가는 두 번째 요소도 없습니다. 클립은 요소를 덜 그릴 뿐이고, 주변 페이지는 무슨 일이 있었는지 끝내 알지 못합니다.

## Examples

### from

네 모서리이고, `mode="out"`은 열린 쪽으로 닫힙니다.

<Demo src="animate-reveal/sides" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-reveal/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_reveal/sides.dart

:::

</Demo>

### fade

**기본이 꺼짐**이고, 이는 이 prop을 제공하는 다른 모든 효과와 반대입니다. 켜는 것은 등장을 한 번에 둘 요구하는 일이고, 이 효과에 손을 뻗은 이유는 보통 그 첫 번째가 문제였기 때문입니다.

## Accessibility

::: fw react

- `prefers-reduced-motion`에서는 애니메이션이 통째로 걷히고 내용이 그냥 거기 있습니다. 클립도 함께 걷히므로 반쯤 그려진 채 남는 것은 없습니다.
- 도는 동안 아무것도 리플로우되지 않고 아무것도 리샘플링되지 않습니다. fade만큼 글 덩어리에 안전하고, 크기를 바꾸는 어떤 것보다 안전합니다.
- 잘려 있는 부분도 문서 안에 있고 그대로 읽힙니다. 이것은 등장이지 숨기는 방법이 아닙니다. 없어야 한다면 unmount하세요.
- 같은 요소에 caller가 건 `clip-path`는 효과가 도는 동안 덮어써집니다. 둘 중 하나는 래퍼에 두세요.

:::

::: fw flutter

- 플랫폼에서 애니메이션이 꺼져 있으면(`MediaQuery.disableAnimations`) 효과가 통째로 걷히고 내용이 그냥 거기 있습니다.
- 도는 동안 아무것도 다시 배치되지 않습니다. 클립은 그리는 시점에 일어나므로 widget도 그 옆의 것도 크기가 바뀌지 않습니다.
- 잘려 있는 부분도 트리 안에 있고 semantics에도 있습니다. 이것은 등장이지 숨기는 방법이 아닙니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 왜 |
| --- | --- | --- |
| `clip-path: inset()` | clipper를 준 `ClipRect` | 같은 사각형을 각 플랫폼이 부르는 이름으로 부른 것입니다. |
| `mode="in" \| "out"` | `PlassAnimateMode.enter` / `.exit` | `in`은 Dart의 예약어입니다. |
| `render` | — | Flutter에는 요소를 바꿔 끼울 자리가 없습니다. |
| `duration`, `delay`가 밀리초 | `Duration` | 프레임워크에 이미 그 타입이 있습니다. |
| `easing`이 CSS 문자열 | `curve`, `Curve` | 같은 것을 Dart가 부르는 이름입니다. |
| `repeat: number \| 'infinite'` | `int?`, `null`이면 멈추지 않음 | 여기에는 쓸 `'infinite'`가 없고, `-1`은 찾아봐야 아는 표식이 됩니다. |
| `IntersectionObserver`를 쓰는 `trigger="visible"` | 가장 가까운 `Scrollable`을 지켜봄 | 여기에는 observer가 없습니다. 위에 scrollable이 없으면 지켜볼 것이 없으므로 그냥 돕니다. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | 플랫폼 자신의 신호입니다. |
| `stagger`, `durationStep`, `reverse` | — | React 빌드는 효과를 자식들 자신에게 써 넣으므로 호출자의 레이아웃은 그대로입니다. Flutter에는 집합을 배치할 스타일시트가 없어서, 차등을 준 효과는 행이나 열까지 자기가 가져야 합니다. 그것이 바로 [`PlAnimateAppear`](./animate-appear)이고, 그것을 여섯 개 더 만드는 일이 됩니다. |
| `timeline="view"` | — | `animation-timeline`은 여기에 대응물이 없는 CSS 속성입니다. Flutter에서 스크롤 연동 효과는 `ScrollPosition`으로 구동하는 `AnimationController`이고, 위젯이 prop으로 받는 것이 아니라 애플리케이션 자신의 배선입니다. |
| `className`, `style` | — | 통과시킬 class 목록도 style 속성도 없습니다. |

:::
