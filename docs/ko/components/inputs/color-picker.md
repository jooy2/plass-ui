---
title: PlColorPicker
order: 20
---

# PlColorPicker

<p class="plass-lede">눈으로 고르는 색입니다. 채도 사각형 옆에 색상 레일이 놓이는데, 모든 디자인 도구가 정착한 배치입니다 — 한 색상의 모든 색이 포인터 한 번의 움직임 안에 들어오기 때문입니다.</p>

<Demo src="color-picker/hero" :min-height="220" />

::: fw react

```tsx
import { PlColorPicker } from 'plass-ui';

<PlColorPicker label="Project colour" value={color} onValueChange={setColor} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlColorPicker(
  label: const Text('Project colour'),
  value: colour,
  onValueChanged: (String next) => setState(() => colour = next),
);
```

:::

## Props

<PropsTable name="PlColorPicker" />

::: fw react

네이티브 `<div>` 속성은 모두 wrapper로 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 제외됩니다 — 컨트롤이 켜지는 *계열*이지, 담고 있는 색이 아닙니다 — 그리고 `defaultValue`와 `onChange`는 value와 `onValueChange`로 표기하기 때문입니다.

:::

공용 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## HSV가 모델이고, 거기서 나가지 않습니다

패널의 상태는 색상·채도·명도입니다. 문자열은 거기서 파생되고, 반대는 결코 아닙니다.

취향의 문제가 아닙니다. RGB를 거치면 **검정의 모든 음영이 같은 색**입니다 — `#000000`에는 되읽을 색상이 없습니다 — 그래서 자기 출력을 다시 파싱하는 피커는 포인터가 사각형 바닥에 닿는 순간 색상 레일을 빨강으로 튕겨 버립니다. 모델을 쥐고 있는 것이 레일을 가만히 있게 합니다.

들어오는 `value`는 모델이 이미 뜻하는 것과 다를 때만 모델을 다시 심습니다. 그리고 "다름"은 문자열이 아니라 *색*으로 비교합니다. `#FF0000`과 `#ff0000`은 두 번 쓰인 같은 색이고, 문자열 비교라면 방금 자기가 만들어 낸 값으로 매 렌더마다 영원히 모델을 다시 심게 됩니다.

## Examples

### inline

트리거 없이 페이지에 패널을 그립니다. 색이 열 개 중 한 필드가 아니라 편집 대상 자체인 사이드바나 설정 창을 위한 것입니다.

<Demo src="color-picker/inline" :min-height="360">

::: fw react

<<< @/.vitepress/demos/color-picker/inline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/inline.dart

:::

</Demo>

### format

나가는 값이 어떤 표기법으로 쓰이는지입니다 — `hex`, `rgb`, `hsl`.

셋 다 색이 불투명하면 alpha를 뺍니다. `alpha`를 켠 적 없는 호출자가 세 채널만 쓴 컨트롤에서 `rgba(…, 1)`을 보게 되면 안 되니까요.

<Demo src="color-picker/formats" :min-height="160">

::: fw react

<<< @/.vitepress/demos/color-picker/formats.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/formats.dart

:::

</Demo>

### alpha

세 번째 레일을 더하고 값이 네 번째 채널을 갖게 합니다. 레일은 체커보드 위에 그려지고, 체커는 conic 그러데이션 둘이 아니라 45°의 linear stop 넷입니다. conic으로 그린 체커는 소수 device pixel ratio에서 모든 타일 한가운데에 이음매가 생깁니다.

<Demo src="color-picker/alpha" :min-height="420">

::: fw react

<<< @/.vitepress/demos/color-picker/alpha.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/alpha.dart

:::

</Demo>

### swatches

제품이 실제로 쓰는 몇 개의 색을 클릭 한 번 거리에 둡니다. 배열을 넘기면 기본 세트를 대체하고, `false`면 아무것도 그리지 않습니다.

기본 세트는 스펙트럼에 회색을 더한 것이고, 일부러 라이브러리의 여섯 계열이 **아닙니다**. 그것들은 의미론적 역할이고, 피커에는 의미가 아니라 색을 요청하기 때문입니다.

선택된 스와치의 체크는 상대 휘도로 정해진 검정 또는 흰색입니다 — 고정된 흰 체크는 노랑 위에서 사라지고, 밝기만 보면 초록에서 반대로 놓입니다.

<Demo src="color-picker/swatches" :min-height="380">

::: fw react

<<< @/.vitepress/demos/color-picker/swatches.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/swatches.dart

:::

</Demo>

### readOnly · disabled · error

`error`는 컨트롤을 invalid로 만들고, 그러면 색 계열 전체가 `danger`로 넘어갑니다 — 가장자리, 링, 메시지가 함께 뒤집힙니다. `invalid`는 메시지 없이 같은 일을 합니다.

`readOnly` 피커는 색을 보여 주고 아무것도 받지 않습니다. 레일은 값을 지키고 tab stop을 잃습니다. `disabled`는 tab 순서에서 빠집니다.

<Demo src="color-picker/states" :min-height="180">

::: fw react

<<< @/.vitepress/demos/color-picker/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/states.dart

:::

</Demo>

### 아래에 색 라이브러리가 없습니다

변환은 `internal/color.ts`입니다 — HSV, RGB, HSL과 파서 하나, 포매터 하나. 삼각함수 없는 산수 백 줄 남짓입니다. 색을 _계산하는_ 컴포넌트가 그걸 해 주는 의존성 없이 배포되는 이유가 전부 그것입니다.

읽는 것: 네 가지 길이의 hex, 그리고 콤마와 공백 문법 양쪽의 `rgb()`/`rgba()`/`hsl()`/`hsla()`. 일부러 읽지 않는 것: 이름 있는 색과 `color()`. 피커는 읽을 수 있는 모든 값을 쓸 수도 있어야 하는데, `rebeccapurple`에서 패널 위의 한 점으로 정직하게 돌아올 길이 없습니다.

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `value` / `defaultValue` | nullable인 `value` | `null`은 "피커 자신의 파랑"입니다. 첫 변경 이후로는 문자열이 호출자의 것이고, 이 패키지의 다른 모든 필드가 그렇습니다. |
| `swatches: false` | `swatches: []` | 빈 리스트가 두 번째 타입 없이 같은 말을 합니다. |
| `open` / `defaultOpen` / `onOpenChange` | — | 팝업은 피커 자신의 것이고, 그것을 붙들어야 하는 route guard 같은 모양이 여기에는 없습니다. |
| `name`과 hidden input | — | 참여할 네이티브 폼 제출이 없습니다. |
| linear 그러데이션 넷으로 만든 체커 | painter | `CustomPainter`에는 피할 이음매도, 싸울 타일링도 없습니다. |
| partial인 `labels` | 기본값을 가진 클래스 `PlColorPickerLabels` | Dart는 선택적 필드에 이름을 붙입니다. 레코드의 partial 같은 것은 없습니다. |
| `className`, `style` | — | 전달할 class 목록도 style 속성도 없습니다. |

:::

## Accessibility

- 사각형과 각 레일은 `aria-valuenow`를 지닌 진짜 `slider`이고 화살표 키로 움직입니다. 한 단계, <kbd>Shift</kbd>와 함께면 열 단계 — 라이브러리의 모든 슬라이더가 쓰는 같은 한 쌍입니다.
- 사각형은 두 채널을 함께 보고합니다. `aria-valuenow`는 채도이고 `aria-valuetext`는 `"채도%, 명도%"`입니다. 숫자 하나로는 평면 위의 한 점을 설명할 수 없기 때문입니다.
- 색상 레일은 멈추지 않고 **감깁니다**. 빨강에서 한 단계 뒤는 0°가 아니라 358°입니다. 색상환은 원이고 레일은 그것의 그림입니다.
- 피커가 답하지 않는 키는 건드리지 않으므로, <kbd>Tab</kbd>이 그러데이션에 삼켜지지 않고 지나갑니다.
- 모든 스와치는 자기 색으로 이름 붙은 진짜 `<button>`이고, 선택된 것에 `aria-pressed`가 붙습니다.
- `labels`는 글자가 없는 부분들의 이름을 하나씩 바꿉니다. 기본적으로 전부 영어로 이름이 붙어 있습니다.
- 드래그는 요소에서 pointer capture를 가져가므로, 드래그 중 포인터가 패널을 벗어나도 색이 계속 바뀝니다.
