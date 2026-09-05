---
title: PlDateRangePicker
order: 13
---

# PlDateRangePicker

<p class="plass-lede">두 날 사이의 구간입니다. 달 두 개를 나란히 두고, 양 끝 사이의 띠는 두 번째 클릭이 닿기 전에 포인터를 따라 그려집니다.</p>

<Demo src="date-range-picker/hero" :min-height="200" />

::: fw react

```tsx
import { PlDateRangePicker } from 'plass-ui';

<PlDateRangePicker label="Stay" startPlaceholder="Check in" endPlaceholder="Check out" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlDateRangePicker(
  label: const Text('Stay'),
  startPlaceholder: const Text('Check in'),
  endPlaceholder: const Text('Check out'),
  value: stay,
  onChanged: (PlDateRange next) => setState(() => stay = next),
);
```

달력은 트리 밖으로 자기를 들어 올리므로 picker 위에 `Overlay`가 필요합니다.

:::

## Props

<PropsTable name="PlDateRangePicker" />

::: fw react

나머지 `<div>` 속성은 field 래퍼로 그대로 통과합니다. `color`는 위 표의 `color`와 겹쳐서, `defaultValue`는 DOM 속성이 아니라 값으로 쓰기 때문에, `children`은 달력이 곧 컴포넌트이기 때문에 제외했습니다.

`className`은 label과 control, 그 아래 두 줄을 함께 담는 stack에 붙습니다. 그 안쪽 네 부분에 닿는 것이 `classNames`입니다 — `label`, `control`(트리거), `description`, `error`.

:::

::: fw flutter

picker는 **controlled**입니다. `value`와 `onChanged`를 함께 주고, `value`는 `null`이 아닙니다 — 비어 있는 구간은 `PlDateRange.empty`입니다.

:::

[`PlDatePicker`](./date-picker)가 `locale`과 헤더와 경계와 날짜 라이브러리의 부재에 대해 말한 것은 여기서도 그대로 성립합니다. 이건 그 컴포넌트에 끝이 하나 더 붙은 것입니다.

### PlDateRange

<PropsTable name="PlDateRange" />

### PlDateRangePreset

<PropsTable name="PlDateRangePreset" />

## 값

`[Date, Date]` 튜플도, prop 두 개도 아닙니다. 구간은 **값 하나** 입니다 — 한 동작으로 고르고, 한 동작으로 비우고, 통째로 검증합니다. 그리고 이름 두 개가 호출자가 끝을 시작에 써 넣는 것을 막습니다.

반쪽짜리 구간은 실제로 존재하는 상태입니다 — 첫 클릭과 둘째 클릭 사이에 picker가 들고 있는 것이 그것입니다 — 그래서 `onValueChange`는 첫 클릭 뒤에 `{ start, end: null }`을, 둘째 뒤에 완성된 구간을 보고합니다. controlled 호출자가 요청하지 않은 중간 상태를 떠안는 일은 없습니다. 대기 중인 anchor는 폼이 아니라 컴포넌트 안에 삽니다.

## 미리보기 띠

띠는 두 번째 클릭이 닿기 전에 anchor와 포인터가 지금 올라가 있는 날 사이에 그려집니다. 그게 없으면 첫 클릭에는 눈에 보이는 결과가 없고, 그 1초 남짓 동안 컨트롤은 고장 난 것처럼 보입니다.

거꾸로 클릭하는 건 거부해야 할 실수가 아닙니다. 같은 구간을 반대 순서로 말한 것이고, 하나로 확정됩니다.

## Examples

### monthCount

두 달이 기본인 건 달을 넘나드는 구간이 예외가 아니라 보통이기 때문입니다 — 한 달짜리 picker는 그것을 2단계 탐색 문제로 만듭니다.

두 패널은 **반으로 나뉜 하나의 달력** 입니다. 왼쪽에는 앞으로 가는 stepper가 없고, 오른쪽에는 뒤로 가는 stepper가 없으며, 어느 헤더의 월/연도 버튼이든 둘 다를 움직입니다. stepper를 그리지 않는 자리에는 그 크기만큼의 빈칸을 남겨서, 두 제목이 같은 중심선에 머뭅니다.

바깥 달의 날도 **그리지 않습니다.** 취향의 문제가 아닙니다 — 두 패널이 모두 여섯 주를 다 그리면 8월 1일이 두 번 나타납니다. 한 번은 7월의 꼬리로, 한 번은 자기 자신으로. 한 팝업 안에 이름이 같은 칸 둘은 포인터에게 모호하고 스크린리더에게는 완전히 고장입니다.

<Demo src="date-range-picker/months" :min-height="200">

::: fw react

<<< @/.vitepress/demos/date-range-picker/months.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_range_picker/months.dart

:::

</Demo>

### presets

달력 옆에 놓이는 이름 붙은 구간 — 사람들이 실제로 고르는 것들입니다. 오늘에 달려 있다면 `value`를 **함수** 로 주세요. 대개 그렇습니다. 모듈 로드 시점에 계산한 "지난 7일"은 탭을 밤새 열어 둔 사람에게는 틀린 구간입니다.

<Demo src="date-range-picker/presets" :min-height="200">

::: fw react

<<< @/.vitepress/demos/date-range-picker/presets.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_range_picker/presets.dart

:::

</Demo>

### minDate · maxDate · shouldDisableDate

[`PlDatePicker`](./date-picker)의 그 셋을 양 끝에 적용한 것입니다. 막힌 날은 그리드에 남고 화살표 경로에서 자기 자리를 지키며, 구간의 색을 입지 않습니다 — 띠를 두른 막힌 날은 자기가 낄 수 없는 구간의 일부라고 광고하는 셈입니다.

<Demo src="date-range-picker/bounds" :min-height="200">

::: fw react

<<< @/.vitepress/demos/date-range-picker/bounds.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_range_picker/bounds.dart

:::

</Demo>

### Controlled

`value`를 `onValueChange`와 함께 주세요. 콜백은 언제나 객체를 받으므로 `null` 구간을 방어할 필요가 없습니다 — 비워진 picker는 `{ start: null, end: null }`입니다.

<Demo src="date-range-picker/controlled" :min-height="200">

::: fw react

<<< @/.vitepress/demos/date-range-picker/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_range_picker/controlled.dart

:::

</Demo>

## Accessibility

- 두 그리드 다 각자 roving tab stop을 하나씩 가지며, 키보드는 [`PlDatePicker`](./date-picker)의 것 그대로입니다.

::: fw react

- 두 그리드 다 `role="grid"`입니다.
- 모든 칸의 접근성 이름은 **날짜 전체** 이고, 한 팝업 안에 같은 날짜가 두 번 나타나지 않습니다 — 바깥 달의 날을 끈 대가로 얻는 것이 그것입니다.
- 푸터는 다음 클릭이 어느 쪽을 채우는지 말합니다. trigger의 두 반쪽도 같은 말을 하지만, 팝업이 떠 있는 동안 trigger는 그 뒤에 가려집니다. 읽힐 자리에서 그 말을 할 수 있는 곳은 푸터뿐입니다.
- trigger 두 반쪽 사이의 화살표는 `aria-hidden`이고 RTL에서 뒤집힙니다.
- trigger의 각 반쪽은 자기가 담을 수 있는 모든 날짜에 대해 자기 너비를 붙잡아 둡니다. 그래서 두 번째 끝을 채워도 첫 번째가 크기를 바꾸지 않습니다. 그 샘플들은 `aria-hidden`이고 generated content로 그려집니다.
- `name`이 있으면 같은 이름의 hidden input 둘이 양 끝을 로컬 `YYYY-MM-DD`로 담아, `FormData.getAll(name)`으로 옵니다.

:::

::: fw flutter

- trigger는 양 끝을 label에 접어 넣는 대신 semantics **value** 로 지닙니다.
- 두 반쪽 사이의 화살표는 RTL에서 돌아가므로 언제나 첫 끝에서 둘째 끝을 가리킵니다.
- 너비를 잡아 주는 샘플들은 `ExcludeSemantics` 뒤에 있습니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `locale` / `format` | `names` / `formatValue` | [`PlDatePicker`](./date-picker)가 설명하는 그 거래입니다 — 프레임워크에 `Intl`이 없습니다. |
| `value: PlDateRange \| null` | `value: PlDateRange`, null 없음 | `PlDateRange.empty`가 그것을 말하고, non-nullable 값은 호출자가 방어할 것이 하나 줄어드는 일입니다. |
| preset의 `value`는 구간이거나 함수 | `build`는 언제나 함수 | preset은 거의 언제나 오늘에 달려 있고, 언제나 맞는 한 가지 모양이 두 가지보다 쌉니다. |
| hidden input, `name` | — | 참여할 네이티브 form 제출이 없습니다. |
| `className`, `style`, 네이티브 속성 | — | 통과시킬 class 목록도 style 속성도 없습니다. |

:::
