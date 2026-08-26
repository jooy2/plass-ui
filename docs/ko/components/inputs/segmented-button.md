---
title: PlSegmentedButton
order: 10
---

# PlSegmentedButton

<p class="plass-lede">알약 하나에 담긴 두 개 이상의 선택지 중 정확히 하나가 선택됩니다. 타일이 떠난 세그먼트에서 고른 세그먼트로 미끄러집니다.</p>

<Demo src="segmented-button/hero" :min-height="120" />

::: fw react

```tsx
import { PlSegment, PlSegmentedButton } from 'plass-ui';

<PlSegmentedButton aria-label="Period" value={period} onValueChange={setPeriod}>
  <PlSegment value="day">Day</PlSegment>
  <PlSegment value="week">Week</PlSegment>
</PlSegmentedButton>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlSegmentedButton<String>(
  semanticLabel: 'Period',
  value: period,
  onChanged: (String next) => setState(() => period = next),
  segments: const <PlSegment<String>>[
    PlSegment<String>(value: 'day', label: Text('Day')),
    PlSegment<String>(value: 'week', label: Text('Week')),
  ],
);
```

:::

## Props

<PropsTable name="PlSegmentedButton" />

::: fw react

네이티브 `<div>` 속성은 그대로 전달됩니다. `color`는 위 표의 `color`와 충돌해서, `defaultValue`와 `onChange`는 이 묶음이 각각 세그먼트 값으로서의 `defaultValue`와 `onValueChange`로 쓰기 때문에 제외됩니다.

:::

::: fw flutter

묶음은 세그먼트 값의 타입에 대해 제네릭입니다 — `PlSegmentedButton<String>`, `PlSegmentedButton<Period>` — 그래서 `value`와 `onChanged`가 `dynamic`이 아니라 타입을 가지고, 패키지의 다른 모든 컨트롤과 마찬가지로 **controlled**입니다.

:::

### PlSegment

<PropsTable name="PlSegment" />

::: fw react

`variant`, `size`, `density`는 세그먼트에 주는 것이 아니라 감싸는 `PlSegmentedButton`에서 내려받습니다. 세 번째 세그먼트만 크기가 다른 segmented button은 segmented button이 아닙니다.

:::

::: fw flutter

세그먼트는 **위젯이 아니라 설명인 `PlSegment`**입니다. [radio 옵션](./radio-group)이 그런 것과 같은 이유로, 묶음이 roving focus와 화살표 키, 그리고 세그먼트 사이를 미끄러지는 타일을 소유하므로 어느 것이 선택되었고 각각이 어디 있는지를 알아야 합니다.

`variant`도 `size`도 `density`도 가지지 않으며, 가질 수도 없습니다. 세 번째 세그먼트만 크기가 다른 segmented button은 segmented button이 아닙니다.

:::

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Segmented button인가, tabs인가, select인가

- **Segmented button** — 이미 화면에 있는 것을 걸러 내는, 짧고 서로 배타적인 선택지 몇 개. 기간, 범위, 레이아웃.
- **Tabs** — 선택이 내용 패널 전체를 바꿀 때.
- **Select** — 선택지가 다섯 개를 넘거나, 하나하나가 길 때.

## Examples

### variant

홈은 `--plass-well`을 씁니다. 라이브러리의 유일한 inset 그림자이자 `solid` field가 그려지는 것과 같은 그림자이고, 쓰이는 곳은 이 둘뿐입니다. 홈과 채워진 field는 둘 다 무언가가 _들어앉는_ 상자입니다. slider의 레일은 그런 상자가 아니라서 더 이상 이 그림자를 쓰지 않습니다 — 레일은 따라 보는 선입니다.

`solid`는 타일에 색 계열의 그러데이션을 넣고 그 아래에 같은 계열의 틴트 그림자를 깝니다. 디자인 언어의 문장을 그대로 옮긴 것입니다 — 홈을 타고 가는 색 유리 키. `glass`와 `ghost`는 대신 맑은 유리판을 들어 올리고 라벨은 accent 색으로 둡니다.

<Demo src="segmented-button/variants" :min-height="220">

::: fw react

<<< @/.vitepress/demos/segmented-button/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/variants.dart

:::

</Demo>

### color

<Demo src="segmented-button/colors" :min-height="220">

::: fw react

<<< @/.vitepress/demos/segmented-button/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/colors.dart

:::

</Demo>

### size

`PlButton`과 같은 높이 사다리를 씁니다. 툴바 안의 segmented button이 옆의 버튼들과 줄을 맞춥니다.

<Demo src="segmented-button/sizes" :min-height="240">

::: fw react

<<< @/.vitepress/demos/segmented-button/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/sizes.dart

:::

</Demo>

### fullWidth

세그먼트들이 한 줄을 균등하게 나눠 가집니다. 타일은 배치가 끝날 때마다 다시 측정되므로, 컨테이너 너비가 변해도 자기 세그먼트 아래에 남아 있습니다.

<Demo src="segmented-button/full-width" :min-height="120">

::: fw react

<<< @/.vitepress/demos/segmented-button/full-width.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/full_width.dart

:::

</Demo>

### startIcon과 endIcon

둘 다 `em`으로 크기가 정해지므로 라벨을 따라갑니다. 아이콘만 있는 세그먼트에는 `aria-label`이 필요합니다.

<Demo src="segmented-button/icons" :min-height="120">

::: fw react

<<< @/.vitepress/demos/segmented-button/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/icons.dart

:::

</Demo>

## Accessibility

::: fw react

- 묶음은 `role="radiogroup"`이고 각 세그먼트는 진짜 radio입니다. 접근성 논거는 이것이 전부입니다 — segmented button은 **"이 중 정확히 하나"** 입니다. `aria-pressed` 토글로 만들었다면 독립된 스위치 네 개를 읽어 주고, 그중 셋은 마침 꺼져 있는 상태가 됩니다.
- 묶음 전체가 tab stop 하나를 차지하고, <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd>로 그 안에서 움직입니다. roving tab index는 Base UI의 것입니다.
- 묶음에 `aria-label`을 주세요. 눈에 보이는 자기 라벨이 없고, 이름 없는 그룹은 스크린리더가 "radio group"이라고만 읽습니다.
- focus ring은 **안쪽으로** 그려집니다. 홈 안의 세그먼트에 바깥쪽 ring을 그리면 이웃 위에 덧칠됩니다.
- 타일은 `transform`이 아니라 `left`, `top`, `width`, `height`를 애니메이션합니다. 빈 상자라서 이동하는 동안 다시 샘플링되는 글자가 없습니다. 무언가 움직이는 것이 존재 이유인 컴포넌트에서도 no-transform 규칙이 살아남는 이유입니다.
- 아무것도 선택되지 않은 묶음의 첫 선택은 왼쪽 끝에서 날아오지 않고 **제자리에** 나타납니다 — 앉을 자리가 생기기 전까지 타일을 마운트하지 않기 때문입니다.

:::

::: fw flutter

- 각 세그먼트는 서로 배타적인 묶음의 하나로, 선택 여부와 함께 알려집니다 — segmented button은 **"이 중 정확히 하나"** 입니다. 토글로 만들었다면 독립된 스위치 네 개를 읽어 주고, 그중 셋은 마침 꺼져 있는 상태가 됩니다.
- 묶음 전체가 focus stop **하나**를 차지합니다. 정확히 한 세그먼트만 tab 순서에 있고 나머지는 `ExcludeFocus`로 감싸여 있습니다. <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd>가 선택을 옮기고, 양 끝에서 순환합니다.
- focus ring은 **안쪽으로** 그려집니다. 홈 안의 세그먼트에 바깥쪽 ring을 그리면 이웃 위에 덧칠됩니다.
- 타일은 측정된 사각형을 애니메이션합니다. 빈 상자라서 이동하는 동안 다시 샘플링되는 글자가 없습니다.
- 묶음에 `semanticLabel`을 주세요. 눈에 보이는 자기 라벨이 없습니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `<PlSegment>` children | 설명으로서의 `segments` | 묶음이 roving focus와 화살표 키, 미끄러지는 타일을 소유하므로 어느 것이 선택되었고 각각이 어디 있는지 알아야 합니다. |
| `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter 자신의 컨트롤이 controlled이고, 콜백 이름도 Flutter의 것입니다. |
| `string \| number`인 값 | 제네릭 `T` | Dart에는 제네릭이 있어, 관례로 제한하는 대신 타입이 검사됩니다. |
| 타일 위의 CSS 커스텀 속성 넷 | 측정된 `Rect`와 `AnimatedPositioned` | 같은 생각 — 선택된 세그먼트를 재고, 상자를 애니메이션한다 — 을 Flutter의 말로 한 것입니다. 어느 쪽도 transform하지 않습니다. |
| `aria-label` | `semanticLabel` | Flutter의 이름입니다. |
| `name`과 hidden input | — | 포함될 네이티브 form 제출이 없습니다. |

:::
