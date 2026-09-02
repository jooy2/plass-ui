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

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateZoom(
  child: PlBox(color: PlassColor.success, child: Text('92')),
);
```

```

:::

## Props

<PropsTable name="PlAnimateZoom" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과하고, `render`로 요소 자체를 바꿀 수 있습니다.

:::

::: fw flutter

`duration`과 `delay`는 `Duration`, `curve`는 `Curve`, `repeat`은 `null`이 멈추지 않음을 뜻하는 `int?`입니다.

:::

`origin`은 의도적으로 **없습니다**. 모서리에 고정된 zoom은 grow이고, 라이브러리는 하나의 생각에 두 가지 표기를 주지 않습니다. 옆에 있는 것에서 나와야 한다면 [PlAnimateGrow](./animate-grow)를 쓰세요.

공유되는 열 가지 설정 — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — 은 모든 `PlAnimate*` 컴포넌트에서 같습니다. `trigger`의 네 값은 [PlAnimateFade](./animate-fade) 페이지에 있습니다.

::: fw react

세 가지가 더 있고, 이들은 효과를 상자에서 떼어 안의 것들로 옮깁니다. `stagger`는 각 자식을 자기 위치만큼 뒤로 미루고, `durationStep`은 자식마다 앞의 것보다 길거나 짧은 재생 시간을 주며, `reverse`는 집합의 끝에서부터 시작합니다. 키프레임 하나짜리 효과 여섯 개 모두에 있고, [PlAnimateFade](./animate-fade) 페이지에 설명이 있습니다. `timeline="view"`와 `range`도 같은 자리에 있고, 효과를 시계가 아니라 독자의 스크롤 위치에 맡깁니다.

:::

## Examples

### from

기본값이 grow의 두 배가 넘는 거리이고, 그것이 느낌의 차이 전부입니다. `1`보다 작으면 페이지 밖으로 나오고, 크면 실제보다 크게 도착해 제자리로 내려앉습니다. 후자는 읽는 사람 _쪽으로_ 오는 것처럼 읽힙니다.

<Demo src="animate-zoom/from" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-zoom/from.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_zoom/from.dart

:::

</Demo>

### 결과 알리기

이 효과가 존재하는 이유입니다. 화면에 하나, 한 번, 그것이 참이 되는 순간에.

<Demo src="animate-zoom/result" :min-height="220">

::: fw react

<<< @/.vitepress/demos/animate-zoom/result.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_zoom/result.dart

:::

</Demo>

## Accessibility

::: fw react

- `prefers-reduced-motion`에서는 애니메이션이 통째로 없어지고 내용은 그냥 거기 있습니다.
- wrapper는 role도 label도 붙이지 않습니다. 알려야 하는 결과라면 자체 live region이 필요합니다. 효과는 보는 사람이 보는 것이지, 스크린리더가 듣는 것이 아닙니다.
- 이동 거리가 길어서 글자가 눈에 띄게 다시 샘플링됩니다. 숫자나 글리프, 작은 카드에 두세요. 문단에는 [PlAnimateFade](./animate-fade)가 맞습니다.
- 기본적으로 반복하지 않고, 이 효과는 그대로 두는 편이 좋습니다. 두 번 zoom하는 것은 첫 번째에 도착하지 못한 것입니다.

:::

::: fw flutter

- 플랫폼에서 애니메이션이 꺼져 있으면(`MediaQuery.disableAnimations`) 효과가 통째로 없어지고 내용은 그냥 거기 있습니다.
- widget은 자기 semantics를 붙이지 않습니다. 알려야 하는 결과라면 자체 `Semantics(liveRegion: true)`가 필요합니다. 효과는 보는 사람이 보는 것이지, 스크린리더가 듣는 것이 아닙니다.
- 이동 거리가 길어서 글자가 눈에 띄게 다시 샘플링됩니다. 숫자나 글리프, 작은 카드에 두세요. 문단에는 [PlAnimateFade](./animate-fade)가 맞습니다.
- 기본적으로 반복하지 않고, 이 효과는 그대로 두는 편이 좋습니다.

:::


::: fw flutter

## Differences from the React build

| React | Flutter | 이유 |
| --- | --- | --- |
| `mode="in" \| "out"` | `PlassAnimateMode.enter` / `.exit` | `in`은 Dart의 예약어입니다. |
| `fade`가 항상 opacity 레이어를 그림 | `fade`가 꺼지면 `Opacity` widget 자체가 없음 | 합성할 레이어가 하나 줄어듭니다. |
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
