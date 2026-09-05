---
title: PlProgressBox
order: 11
---

# PlProgressBox

<p class="plass-lede">불이 들어오는 작은 유리판들의 줄입니다. 세 번째 모양이고, 양이 아니라 재질에 대한 모양입니다.</p>

<Demo src="progress-box/hero" :min-height="160" />

::: fw react

```tsx
import { PlProgressBox } from 'plass-ui';

<PlProgressBox label="Step 3 of 5" value={3} max={5} count={5} showValue />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlProgressBox(label: const Text('Step 3 of 5'), value: 3, max: 5, count: 5, showValue: true);
```

:::

## Props

<PropsTable name="PlProgressBox" />

`count` 위쪽은 전부 [`PlProgressLinear`](./progress-linear)의 표 그대로입니다. `size`가 재는 대상만 다릅니다. 홈의 두께가 아니라 플레이트 한 장의 크기입니다.

::: fw react

나머지 `<div>` 속성은 그대로 통과합니다. `color`는 위 표의 `color`와 겹쳐서, `children`은 플레이트 줄이 아무것도 담지 않아서 제외했습니다.

:::

::: fw flutter

React가 옵션 객체를 받는 자리에서 `formatValue`는 함수를 받습니다. 이유는 [`PlProgressLinear`](./progress-linear)에 있습니다.

:::

## 언제 쓰나

바와 링은 둘 다 _얼마나 끝났는가_ 에 답합니다. 플레이트 줄은 _지금 돌아가고 있다_ 에 답하는데, 그것도 이 라이브러리 자신의 어휘로(같은 홈, 같은 모서리, 같은 그러데이션으로) 답합니다. 그래서 Plass 표면 **안쪽** 의 로딩 상태에 맞습니다. 거기에 낯선 회색 스피너를 두면 빌려 온 것처럼 보입니다.

단계로도 읽히는 유일한 모양이기도 합니다. 기다리는 대상에 실제로 단계가 있다면 `count`를 그 수로 두세요. 줄이 측정이 아니라 진행 _순서_ 가 됩니다.

## Examples

### value와 count

플레이트는 순서대로 차오르고 맨 앞 한 장은 부분적으로 찹니다. 그래서 플레이트 넷의 30%는 1/4로 반올림된 것이 아니라 한 장이 가득 차고 다음 장이 1/5쯤 찬 모습입니다. 플레이트 하나하나가 자기 홈인 이유가 이것입니다. 그렇지 않으면 플레이트 넷은 0, 25, 50, 75, 100밖에 보여 줄 수 없습니다.

<Demo src="progress-box/count" :min-height="200">

::: fw react

<<< @/.vitepress/demos/progress-box/count.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_box/count.dart

:::

</Demo>

### Indeterminate

기본값인 `null`은 줄을 순환시키고, 각 플레이트는 자기 index만큼 늦게 켜집니다. 순환하는 것은 fill의 **opacity**이고 절대 칠 자체가 아닙니다. Plass의 fill은 그러데이션이고 `background-image`는 그러데이션과 없음 사이를 보간하지 못하므로, background를 바꾸는 플레이트는 켜지는 것이 아니라 튑니다.

플레이트는 움직이지 않습니다. 플레이트 줄은 누군가 읽고 있는 페이지 구석에서 뛰는 무언가가 아니라, 무언가 기록되고 있는 표면으로 읽힙니다.

<Demo src="progress-box/indeterminate" :min-height="160">

::: fw react

<<< @/.vitepress/demos/progress-box/indeterminate.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_box/indeterminate.dart

:::

</Demo>

### size

플레이트 자신의 사다리이고, [`PlCheckbox`](../inputs/checkbox)의 박스와 [`PlRadio`](../inputs/radio-group)의 링이 올라 있는 tick 사다리입니다. 플레이트는 라벨 옆의 표시이지 라벨을 안에 넣을 수 있는 컨트롤이 아닙니다.

<Demo src="progress-box/sizes" :min-height="240">

::: fw react

<<< @/.vitepress/demos/progress-box/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_box/sizes.dart

:::

</Demo>

### color

<Demo src="progress-box/colors" :min-height="180">

::: fw react

<<< @/.vitepress/demos/progress-box/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_box/colors.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI가 `role="progressbar"`를 렌더링하고 `aria-valuenow` `aria-valuemin` `aria-valuemax`를 prop과 맞춰 둡니다. 플레이트 자체는 `aria-hidden`입니다. 그건 그림이기 때문입니다.
- indeterminate인 줄은 0이 아니라 **값 자체를 보고하지 않습니다.** 그래야 스크린리더가 진행도를 알 수 없다고 읽어 줍니다.
- `aria-valuetext`는 `showValue`가 그리는 문자열과 같습니다. `format`이 없으면 100이 아니라 범위에 대한 백분율이고, 플레이트 다섯 장이 보통 `max={5}`를 뜻하는 여기서 그것이 가장 중요합니다.
- `prefers-reduced-motion`에서는 파도를 멈추는 대신 움직임으로 읽히지 않을 만큼 느리게 합니다. 가만히 있는 플레이트 줄은 작업이 멈췄다고 말합니다.

:::

::: fw flutter

- 줄은 `SemanticsRole.progressBar`와 값을 지닌 하나의 병합된 semantics 노드입니다. 라벨과 플레이트가 함께 읽히고, 플레이트 자체는 아무것도 더하지 않습니다. 그건 그림이기 때문입니다.
- 값이 없으면 role은 `SemanticsRole.loadingSpinner`이고 값 자체가 없습니다. 그래야 플랫폼이 진행도를 알 수 없다고 읽어 줍니다.
- 그려진 백분율은 `ExcludeSemantics` 뒤에 있습니다. 같은 문자열이 이미 노드의 값입니다.
- `MediaQuery.disableAnimations`에서는 파도를 멈추는 대신 느리게 합니다.

:::

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `format: Intl.NumberFormatOptions` | `formatValue: String Function(double)` | 프레임워크에 `Intl.NumberFormat`이 없고, 그것을 위해 `package:intl`을 끌어오는 것은 소비자 대신 의존성을 정하는 일입니다. |
| 소수 `count`를 내림 | `count`가 `int` | Dart의 타입이 이미 그렇게 알립니다. 1 미만이 1이 되는 것은 그대로입니다. |
| 파도가 플레이트마다 자기 delay가 붙은 keyframe | 컨트롤러 하나를 플레이트들이 각자의 위상으로 읽음 | 같은 파도이고, 플레이트마다 하나가 아니라 줄마다 ticker 하나입니다. |
| `className`, `style`, 네이티브 속성 | — | 통과시킬 class 목록도 style 속성도 없습니다. |
