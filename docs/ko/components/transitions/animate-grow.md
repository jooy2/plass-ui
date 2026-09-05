---
title: PlAnimateGrow
order: 4
---

# PlAnimateGrow

<p class="plass-lede">한 점에서 펼쳐지는 내용입니다. 최종 크기에 가까운 데서 시작하고 어느 모서리에도 고정할 수 있어서, 옆에 있는 것에서 열려 나오는 것처럼 읽힙니다.</p>

<Demo src="animate-grow/hero" :min-height="260" />

::: fw react

```tsx
import { PlAnimateGrow } from 'plass-ui';

<PlAnimateGrow origin="top">
  <PlBox>Sort, group and column visibility.</PlBox>
</PlAnimateGrow>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateGrow(
  origin: Alignment.topCenter,
  child: PlBox(child: Text('Sort, group and column visibility.')),
);
```

```

:::

## Props

<PropsTable name="PlAnimateGrow" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과하고, `render`로 요소 자체를 바꿀 수 있습니다.

:::

::: fw flutter

`origin`은 CSS `transform-origin` 문자열이 아니라 `Alignment`입니다. 프레임워크에 이미 타입이 있으니까요. `duration`과 `delay`는 `Duration`, `curve`는 `Curve`, `repeat`은 `null`이 멈추지 않음을 뜻하는 `int?`입니다.

:::

공유되는 열 가지 설정 — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — 은 모든 `PlAnimate*` 컴포넌트에서 같습니다. `trigger`의 네 값은 [PlAnimateFade](./animate-fade) 페이지에 있습니다.

::: fw react

세 가지가 더 있고, 이들은 효과를 상자에서 떼어 안의 것들로 옮깁니다. `stagger`는 각 자식을 자기 위치만큼 뒤로 미루고, `durationStep`은 자식마다 앞의 것보다 길거나 짧은 재생 시간을 주며, `reverse`는 집합의 끝에서부터 시작합니다. 키프레임 하나짜리 효과 여섯 개 모두에 있고, [PlAnimateFade](./animate-fade) 페이지에 설명이 있습니다. `timeline="view"`와 `range`도 같은 자리에 있고, 효과를 시계가 아니라 독자의 스크롤 위치에 맡깁니다.

:::

## Examples

### origin

고정점이 이것과 `PlAnimateZoom`을 가르는 전부입니다. `top`에서 펼쳐지는 패널은 위에 있는 컨트롤에서 나오는 패널이고, `bottom right`에서 펼쳐지는 것은 고정된 모서리에서 나오는 것입니다. 가운데에 고정된 것은 zoom이고, 그 생각에 대한 컴포넌트는 하나뿐입니다.

<Demo src="animate-grow/origin" :min-height="160">

::: fw react

<<< @/.vitepress/demos/animate-grow/origin.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_grow/origin.dart

:::

</Demo>

### from

`1`보다 크면 실제보다 크게 도착해서 제자리로 내려앉습니다. 짧은 이동 거리가 유리 위에서 이것을 안전하게 만듭니다. `0.8`에서 커지는 시트는 처음부터 끝까지 알아볼 수 있는 같은 시트이고, 뒤의 blur가 곧 될 크기의 5분의 1짜리 표면을 풀어내야 할 일이 없습니다.

<Demo src="animate-grow/from" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-grow/from.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_grow/from.dart

:::

</Demo>

### 패널 열기

가장 흔한 쓰임이고, 기본값이 그것을 위해 골라졌습니다. `origin="top"`, 짧은 거리, 빠른 duration. 패널이 옆에 나타나는 대신 그것을 연 컨트롤에서 펼쳐집니다.

<Demo src="animate-grow/panel" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-grow/panel.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_grow/panel.dart

:::

</Demo>

## Accessibility

::: fw react

- `prefers-reduced-motion`에서는 애니메이션이 통째로 없어지고 내용은 그냥 거기 있습니다.
- wrapper는 role도 label도 붙이지 않습니다. 이미 자기가 무엇인지 말하는 내용을 감싼 `<div>`일 뿐입니다.
- 배율 변화는 안에 있는 것을 다시 샘플링하므로, 본문 위에서는 이동 거리를 짧게 두세요. `from`의 기본값이 `0.8`인 이유입니다. 긴 이동은 도형이나 아이콘, 사진의 몫입니다.
- 이것은 wrapper이지 disclosure가 아닙니다. 내용을 mount하고 unmount하는 것은 caller의 몫이고, 그 일을 한 컨트롤에 붙을 `aria-expanded`도 마찬가지입니다.

:::

::: fw flutter

- 플랫폼에서 애니메이션이 꺼져 있으면(`MediaQuery.disableAnimations`) 효과가 통째로 없어지고 내용은 그냥 거기 있습니다.
- widget은 자기 semantics를 붙이지 않습니다. 이미 자기가 무엇인지 말하는 내용을 감싼 `Transform`일 뿐입니다.
- 배율 변화는 안에 있는 것을 다시 샘플링하므로, 본문 위에서는 이동 거리를 짧게 두세요. `from`의 기본값이 `0.8`인 이유입니다. 긴 이동은 도형이나 아이콘, 사진의 몫입니다.
- 이것은 wrapper이지 disclosure가 아닙니다. 내용을 넣고 빼는 것은 caller의 몫이고, 그것에 대해 스크린리더에게 무엇을 말할지도 마찬가지입니다.

:::


::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `origin`이 CSS `transform-origin` 문자열 | `Alignment` | 프레임워크에 이미 타입이 있고, `Alignment.topCenter`가 `'top'`보다 잘 읽힙니다. |
| `fade`가 항상 opacity 레이어를 그림 | `fade`가 꺼지면 `Opacity` widget 자체가 없음 | 합성할 레이어가 하나 줄고, 하지 않는 일을 한다고 주장하는 것이 트리에 없습니다. |
| `mode="in" \| "out"` | `PlassAnimateMode.enter` / `.exit` | `in`은 Dart의 예약어입니다. |
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
