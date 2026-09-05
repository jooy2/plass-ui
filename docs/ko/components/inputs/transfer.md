---
title: PlTransfer
order: 17
---

# PlTransfer

<p class="plass-lede">두 목록과 그 사이의 화살표입니다. 고를 수 있는 모든 것이 한쪽에, 고른 것이 다른 쪽에 있습니다. 체크는 선택이 아닙니다 — 체크는 다음 누름이 무엇을 옮길지를 말합니다.</p>

<Demo src="transfer/hero" :min-height="320" />

::: fw react

```tsx
import { PlTransfer } from 'plass-ui';

<PlTransfer
  items={columns}
  value={value}
  onValueChange={setValue}
  sourceLabel="Available columns"
  targetLabel="In the report"
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlTransfer(
  items: columns,
  value: value,
  onValueChanged: (List<String> next) => setState(() => value = next),
  sourceLabel: 'Available columns',
  targetLabel: 'In the report',
);
```

:::

## Props

<PropsTable name="PlTransfer" />

::: fw react

네이티브 `<div>` 속성은 모두 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라, `defaultValue`는 값의 목록으로 표기하기 때문에, `onChange`는 `onValueChange`로 보고하기 때문에 제외됩니다.

:::

### PlTransferItem

<PropsTable name="PlTransferItem" />

공용 축(`variant` `size` `color` `density` `elevation`)이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 언제 쓰나

선택지가 **길** 때입니다. 필드에 칩이 마흔 개 든 [`PlCombobox`](./combobox)는 더 이상 읽히지 않고, 체크박스 마흔 개의 목록은 "내가 결국 뭘 골랐지"에 아무 답도 주지 못합니다.

열두 개쯤 아래라면 그 둘 중 하나가 더 작은 컴포넌트입니다. 이것은 독자에게 목록 둘과 화살표 한 쌍을 치르게 하는데, 그 값을 하는 건 답 자체를 되읽을 값어치가 있을 때입니다.

## 체크는 선택이 아닙니다

`value`는 행이 어느 쪽에 있는지입니다. **체크**는 다음 누름이 어느 행을 옮길지이고, 일부러 별도의 상태입니다. 둘을 떼어 놓는 것이, 누름을 목록을 훑는 부수 효과가 아니라 의도한 행위로 만듭니다.

거기서 세 가지가 따라 나옵니다.

- `items`의 순서가 **두** 목록이 보여 주는 순서입니다. 건너갔다 돌아온 행이 자리를 옮기지 않습니다.
- 옮기는 것은 옮겨진 것의 체크를 떨구고 나머지는 남깁니다. 반대편에 도착한 행은 아직 거기로 보내지기를 기다리고 있지 않습니다.
- 필터가 숨기고 있던 행은 애초에 그 누름의 일부가 아니었습니다.

## Examples

### searchable

각 목록 위에 필터를 두고, 각자 자기 쪽만 좁힙니다.

접기는 대소문자와 결합 문자를 무시합니다 — `cafe`가 `Café`를 찾습니다. "내가 친 것과 맞는다"에 대한 라이브러리의 단 하나의 답이고, 안의 모든 필터가 그것을 함께 씁니다. 제품의 어느 검색 상자에서 배운 것이 다음 것에서도 맞습니다.

문자열이 아니라 노드인 라벨은 맞춰 볼 텍스트가 없으므로 **남습니다**. 그러지 않으면 결코 만족시킬 수 없는 필터에서 행이 사라지게 됩니다.

<Demo src="transfer/searchable" :min-height="300">

::: fw react

<<< @/.vitepress/demos/transfer/searchable.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/transfer/searchable.dart

:::

</Demo>

### variant

두 패널은 시트가 아니라 **필드**의 껍데기를 입습니다. 값을 담는 목록은 필드 모양의 것이기 때문입니다 — `solid`는 well, `glass`는 헤어라인 판, `ghost`는 포인터가 오기 전까지 표면 없음. 화살표도 따라갑니다. 가장자리가 있는 패널 옆에서는 `glass`, 없는 패널 옆에서는 `ghost`입니다.

어느 패널에도 색이 들어가지 않습니다. 담고 있는 것은 누군가의 데이터이고, 색 계열은 체크, 화살표, focus ring까지 갑니다.

<Demo src="transfer/variants" :min-height="420">

::: fw react

<<< @/.vitepress/demos/transfer/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/transfer/variants.dart

:::

</Demo>

### 옮길 수 없는 행

항목의 `disabled`는 그것을 목록에 남기고 모든 누름에서 뺍니다. 제목의 전체 선택도 마찬가지라, 그 체크가 넷 중 넷이 아니라 넷 중 셋이라고 보고합니다. 고를 수 없다고 사라지는 선택지는 독자가 찾아 헤매게 되는 선택지입니다.

쌍 전체의 `disabled`는 모든 것을 한 번에 멈춥니다.

<Demo src="transfer/states" :min-height="400">

::: fw react

<<< @/.vitepress/demos/transfer/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/transfer/states.dart

:::

</Demo>

### Controlled

`value`를 `onValueChange`와 함께 넘기세요. 값은 뒤쪽에 있는 `value`들의 목록이고 `items` 순서입니다. 객체가 아닙니다 — transfer는 폼 컨트롤이고, 담는 것은 폼이 제출하는 것입니다. 식별자는 여기 두고 객체는 반대편에서 찾으세요.

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `ReactNode`인 `label`, 문자열이 아니면 필터가 남겨 둠 | `String`인 `label` | 필터는 라벨을 읽고, 읽을 수 없는 행은 결코 만족시킬 수 없는 검색에서 사라지는 행입니다. 텍스트로 만드는 것이 모든 행을 구조적으로 검색 가능하게 합니다. |
| 대소문자 **와** 결합 문자를 접음 | 대소문자만 | Dart 코어에는 `String.normalize`가 없고, 이 패키지에는 의존성이 없습니다. 검색 상자가 악센트를 접자고 의존성을 들이면 비교 한 번을 위해 모든 소비자의 바이너리에 그것이 들어갑니다. |
| 숫자나 CSS 길이인 `height` | `double`인 `height` | 이름 붙일 두 번째 단위가 없습니다. |
| `onValueChange` | `onValueChanged` | Flutter의 이름입니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 class 목록도 style 속성도 없습니다. |

:::

## Accessibility

- 모든 행은 행의 라벨을 이름으로 갖는 진짜 [`PlCheckbox`](./checkbox)입니다. 스크린 리더가 목록을 실제 모습대로, 체크박스의 목록으로 읽습니다.
- 각 제목의 체크도 체크박스이고 `selectAllLabel`이 이름이며, 목록의 일부만 체크된 상태에서는 `indeterminate`를 보고합니다.
- 두 화살표는 진짜 이름을 가진 [`PlIconButton`](./icon-button)이고, 누름이 실제로 무언가를 옮길 수 있을 때까지 disabled입니다. 보이는 사람이 보는 상태를, 보지 못하는 사람도 알 수 있게.
- 각 목록에는 제목 옆에 자기 개수(`체크/전체`)가 있습니다. 행을 세지 않고 "방금 얼마나 골랐나"에 답하는 것이 그것입니다.
- 목록은 각자 스크롤되고 스크롤 위치를 유지하므로, 행 하나를 옮겼다고 독자가 맨 위로 되돌려지지 않습니다.
