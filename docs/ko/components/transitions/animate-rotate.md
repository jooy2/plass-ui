---
title: PlAnimateRotate
order: 9
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

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateRotate(
  from: 0,
  to: 360,
  duration: Duration(milliseconds: 2400),
  curve: Curves.linear,
  repeat: null,
  fade: false,
  child: PlIcon(icon: RefreshGlyph()),
);
```

```

:::

## Props

<PropsTable name="PlAnimateRotate" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과하고, `render`로 요소 자체를 바꿀 수 있습니다.

:::

::: fw flutter

`from`과 `to`는 radian이 아니라 **도(degree)**입니다. 프레임워크는 radian으로 세고 디자인 언어는 도로 셉니다 — 패키지의 모든 그러데이션이 135°죠 — 그래서 변환은 호출하는 자리마다가 아니라 widget 안에서 한 번 일어납니다. `origin`은 `Alignment`입니다.

:::

공유되는 열 가지 설정 — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — 은 모든 `PlAnimate*` 컴포넌트에서 같습니다. `trigger`의 네 값은 [PlAnimateFade](./animate-fade) 페이지에 있습니다.

::: fw react

세 가지가 더 있고, 이들은 효과를 상자에서 떼어 안의 것들로 옮깁니다. `stagger`는 각 자식을 자기 위치만큼 뒤로 미루고, `durationStep`은 자식마다 앞의 것보다 길거나 짧은 재생 시간을 주며, `reverse`는 집합의 끝에서부터 시작합니다. 키프레임 하나짜리 효과 여섯 개 모두에 있고, [PlAnimateFade](./animate-fade) 페이지에 설명이 있습니다. `timeline="view"`와 `range`도 같은 자리에 있고, 효과를 시계가 아니라 독자의 스크롤 위치에 맡깁니다.

:::

## Examples

### from and to

`from`만 있으면 도착입니다. 무언가 제자리로 들어와 멈춥니다. `from`과 `to`를 `repeat="infinite"`, `easing="linear"`와 함께 쓰면 끝나지 않는 회전이 됩니다. 배지나 로딩 표시, 장식용 글리프가 원하는 것이죠. 후자에서는 `fade`를 끄세요. 반복되는 fade는 깜빡임으로 읽힙니다.

<Demo src="animate-rotate/spin" :min-height="160">

::: fw react

<<< @/.vitepress/demos/animate-rotate/spin.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_rotate/spin.dart

:::

</Demo>

### origin

CSS `transform-origin`이면 무엇이든 됩니다. 모서리를 중심으로 도는 것은 바퀴가 아니라 경첩이고, 깃발이나 태그, 더미에 놓이는 카드가 원하는 것입니다.

<Demo src="animate-rotate/origin" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-rotate/origin.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_rotate/origin.dart

:::

</Demo>

## Accessibility

::: fw react

- `prefers-reduced-motion`에서는 애니메이션이 통째로 없어지고 내용은 그냥 거기 있습니다. 도착에는 맞는 처리이고, 회전에는 한 번 생각해 볼 문제입니다. 도는 것 자체가 *무언가 진행 중*이라는 뜻이고 있다면 [PlProgressCircular](../feedback/progress-circular)를 쓰세요. 그쪽은 멈추는 대신 느려집니다.
- **글자에는 쓰지 마세요.** 회전한 단어는 길이 전체에 걸쳐 다시 샘플링됩니다. 회전은 디자인 언어가 글리프 위에서 이견 없이 허용하는 유일한 움직임이고 — 라이브러리 전체에서 chevron은 다시 그려지는 대신 돌아갑니다 — 그것이 이 효과가 겨냥하는 종류의 것입니다.
- 누군가 읽고 있는 페이지의 구석에서 끝없이 도는 것은 이 라이브러리의 나머지가 거부하는 유일한 종류의 움직임입니다. 이유를 주세요.

:::

::: fw flutter

- 플랫폼에서 애니메이션이 꺼져 있으면(`MediaQuery.disableAnimations`) 효과가 통째로 없어지고 내용은 그냥 거기 있습니다. 도착에는 맞는 처리이고, 회전에는 한 번 생각해 볼 문제입니다. 도는 것 자체가 *무언가 진행 중*이라는 뜻이고 있다면 [PlProgressCircular](../feedback/progress-circular)를 쓰세요. 그쪽은 멈추는 대신 느려집니다.
- **글자에는 쓰지 마세요.** 회전한 단어는 길이 전체에 걸쳐 다시 샘플링됩니다.
- 누군가 읽고 있는 화면 구석에서 끝없이 도는 것은 이 패키지의 나머지가 거부하는 유일한 종류의 움직임입니다. 이유를 주세요.

:::


::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `from`, `to`가 도 단위 | `double` 도, 내부에서 변환 | 프레임워크는 radian으로, 디자인 언어는 도로 셉니다. 변환은 한 자리에 있어야 합니다. |
| `origin`이 CSS `transform-origin` 문자열 | `Alignment` | 프레임워크에 이미 타입이 있습니다. |
| `easing="linear"` | `curve: Curves.linear` | 같은 곡선에 대한 Dart 자신의 이름입니다. |
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
