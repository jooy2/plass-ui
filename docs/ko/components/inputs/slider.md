---
title: PlSlider
order: 5
---

# PlSlider

<p class="plass-lede">범위 위에서 값을 고릅니다. 레일은 중립 색의 홈이고, 그 홈을 채우는 구간은 버튼을 이루는 것과 같은 그러데이션입니다.</p>

레일은 `--plass-track`, `PlSwitch`의 꺼짐 상태와 같은 잉크입니다. 채워진 field가 그렇듯 유리에 inset 그림자를 넣은 것이 아닙니다. field는 _들여다보는_ 상자이고 레일은 _따라 보는_ 선이며, 레일에서 정작 중요한 것은 아무것도 올라가 있지 않은 구간인데, 흰 바탕에 흰 홈에는 바로 그 구간이 없습니다.

<Demo src="slider/hero" :min-height="120" />

::: fw react

```tsx
import { PlSlider } from 'plass-ui';

<PlSlider label="Volume" value={volume} onValueChange={setVolume} showValue />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlSlider(
  label: const Text('Volume'),
  values: <double>[volume],
  showValue: true,
  onChanged: (List<double> next) => setState(() => volume = next.first),
);
```

:::

## Props

<PropsTable name="PlSlider" />

::: fw react

Base UI `Slider.Root`의 나머지 prop은 그대로 전달됩니다 — `minStepsBetweenValues`, `largeStep`, `format`, `onValueCommitted`, `name`, `disabled`.

:::

::: fw flutter

`values`는 값이 하나일 때도 언제나 목록입니다. 어느 쪽이든 같은 파라미터이고, range로 만드는 것은 길이입니다.

:::

여기에는 `variant`가 없습니다. 세 재질은 "이 표면이 무엇으로 되어 있는가"에 대한 답인데, 슬라이더는 한 번에 두 표면입니다 — 홈, 그리고 그 위를 지나가는 키. 어느 쪽도 고를 여지가 없습니다.

화살표 키나 rail 누름, 바깥에서 바꾼 값처럼 끌지 않고 바뀐 값에는 thumb이 **이동합니다**. 나머지 전부와 같은 duration이고, 뒤의 run도 같은 속도로 찹니다. 손가락 아래에서는 이동하지 않습니다. 포인터를 향해 서서히 따라가는 thumb은 포인터보다 뒤처져서 느린 컨트롤로 읽히기 때문입니다. 라이브러리에서 위치에 애니메이션을 주는 곳은 여기 하나뿐이고, [transform 금지 규칙](../../design/design-language#컨트롤은-움직이지-않습니다)도 지킵니다. 움직이는 것은 컨트롤이 아니라 값입니다.

라이브러리 전체에서 공유 축(`size` `color` `elevation` `orientation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### Range

값을 둘 이상 주면 항목 수만큼 thumb이 생기며 range 슬라이더가 됩니다. 별도의 `range` prop이 없는 이유는, 값의 모양이 이미 어느 쪽인지 말하고 있기 때문입니다.

::: fw flutter

thumb끼리 교차하지 않습니다. 값은 양옆 이웃 사이에 붙들리므로, 양 끝이 뒤바뀐 range는 거꾸로 입력된 range이고 그 처리는 모든 호출자가 아니라 여기에 있습니다.

:::

<Demo src="slider/range" :min-height="120">

::: fw react

<<< @/.vitepress/demos/slider/range.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/range.dart

:::

</Demo>

### color

채워진 구간은 색 계열의 그러데이션 — `solid` 버튼이 입는 것과 같은 135° 두 stop 스윕 — 이고, thumb은 그 위에 놓입니다. 페이지 자체의 surface 색으로 테두리를 둘러서 뒤의 구간에 녹아 사라지지 않습니다.

<Demo src="slider/colors" :min-height="280">

::: fw react

<<< @/.vitepress/demos/slider/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/colors.dart

:::

</Demo>

### min · max · step

`step`이 thumb이 멈출 수 있는 자리를 정합니다. 멈출 자리가 다섯 개인 슬라이더도 여전히 슬라이더이지 segmented control이 아닙니다 — 드래그로 고르고, 값들이 하나의 척도 위에 있기 때문입니다.

<Demo src="slider/steps" :min-height="260">

::: fw react

<<< @/.vitepress/demos/slider/steps.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/steps.dart

:::

</Demo>

### showValue

::: fw react

`true`는 값을 그대로 찍습니다. 함수를 주면 Base UI가 이미 지역화해 둔 문자열과 원래 숫자를 둘 다 받으므로, 통화나 퍼센트, 시간 표기가 한 줄로 끝납니다.

:::

::: fw flutter

`showValue`가 숫자를 켜고 `formatValue`가 무엇을 말할지 정합니다 — 통화, 퍼센트, 시간. 빼면 소수점 없이 찍고 en dash로 잇습니다.

:::

값은 thumb을 따라다니지 않고 라벨 줄의 끝에 놓입니다. 움직이는 숫자는 읽기 어렵고, 위아래로 쌓인 두 슬라이더 사이에서는 비교할 수도 없습니다.

### size

홈과 thumb, 라벨이 함께 움직입니다. 모든 단계에서 thumb은 홈보다 한참 큽니다 — 실제로 잡을 수 있는 부분은 thumb뿐이고, 6px 레일에 맞춘 thumb은 터치스크린에서 아무도 잡지 못합니다.

<Demo src="slider/sizes" :min-height="380">

::: fw react

<<< @/.vitepress/demos/slider/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/sizes.dart

:::

</Demo>

### orientation

세로 슬라이더는 자기 길이가 없어서 하나를 받습니다. 기본값은 160px이고, 믹서의 페이더처럼 더 길어야 하면 <Fw react="class로 덮어쓰세요" flutter="`length`로 덮어쓰세요" />.

<Demo src="slider/orientation" :min-height="220">

::: fw react

<<< @/.vitepress/demos/slider/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/orientation.dart

:::

</Demo>

### disabled

다른 곳과 마찬가지로 빛이 꺼지는 것입니다. 모양과 자리는 그대로 두고 채도와 불투명도 절반이 빠집니다.

<Demo src="slider/states" :min-height="140">

::: fw react

<<< @/.vitepress/demos/slider/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/states.dart

:::

</Demo>

## Accessibility

::: fw react

- 각 thumb은 진짜 `<input type="range">`입니다. 브라우저 자체의 slider 의미론, 포커스 순서, `disabled`가 전부 그대로 따라옵니다.
- `label`은 Base UI가 컨트롤에 엮어 줍니다. 라벨이 없는 경우 — 여러 개가 늘어선 페이더 같은 — 에는 `aria-label`을 주세요.
- 키보드는 primitive의 것입니다. <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd>로 한 칸씩, <kbd>PageUp</kbd> / <kbd>PageDown</kbd>으로 크게, <kbd>Home</kbd>과 <kbd>End</kbd>로 양 끝까지 갑니다.
- 포인터가 닿는 곳은 레일이 아니라 띠 전체입니다. 컨트롤 박스가 홈 두께의 몇 배라서, 띠 어디를 눌러도 thumb이 그리로 옵니다.
- thumb은 hover와 드래그 중에 자기가 커지는 대신 후광을 두릅니다 — 손가락 아래의 것은 절대 크기가 변하지 않습니다.
- `showValue`는 그려진 숫자일 뿐, 접근성 값의 대체물이 아닙니다. 그것은 input의 `aria-valuenow`이고 Base UI가 맞춰 줍니다.

:::

::: fw flutter

- 슬라이더로 알려지고, 현재 값이 그 값으로 함께 알려집니다. 보이는 `label`이 없다면 — 여러 개가 늘어선 페이더처럼 — `semanticLabel`을 주세요.
- <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd>가 `step` 하나만큼, <kbd>PageUp</kbd> / <kbd>PageDown</kbd>이 범위의 10분의 1만큼 옮기고, <kbd>Home</kbd>과 <kbd>End</kbd>가 양 끝으로 갑니다.
- thumb마다 자기 focus stop을 가집니다. range 슬라이더를 조작할 수 있게 하는 것이 이것입니다 — <kbd>Tab</kbd>으로 양 끝 사이를 옮깁니다.
- 포인터가 닿는 곳은 레일이 아니라 띠 전체입니다. 컨트롤 박스가 홈 두께의 몇 배라서, 띠 어디를 눌러도 가장 가까운 thumb이 그리로 옵니다.
- thumb은 hover와 드래그 중에 자기가 커지는 대신 후광을 두릅니다 — 손가락 아래의 것은 절대 크기가 변하지 않습니다.
- `showValue`는 그려진 숫자일 뿐, 알려지는 값의 대체물이 아닙니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| 숫자이거나 배열인 `value` | 언제나 목록인 `values` | 어느 쪽이든 파라미터는 하나이고, range로 만드는 것은 길이입니다. |
| `onValueChange` / `onValueCommitted` | `onChanged` / `onChangeEnd` | "움직이는 동안"과 "놓았을 때"에 대한 Flutter의 이름입니다. |
| boolean이거나 함수인 `showValue` | `showValue`와 `formatValue` | Dart에는 union 타입이 없으니, 숫자를 켜는 것과 무엇을 말할지 정하는 것이 두 파라미터가 됩니다. |
| `<input type="range">` | 직접 그린 띠와 자체 키 처리 | 키보드를 물려받을 네이티브 range input이 없으므로 키를 여기서 묶습니다 — <kbd>Page</kbd>와 <kbd>Home</kbd>/<kbd>End</kbd>를 포함해 같은 조합입니다. |
| `aria-label` | `semanticLabel` | Flutter의 이름입니다. |
| 세로 슬라이더 높이를 위한 `className` | `length` | 클래스 목록이 없습니다. 길이는 파라미터입니다. |

:::
