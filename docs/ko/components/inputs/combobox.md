---
title: PlCombobox
order: 5
---

# PlCombobox

<p class="plass-lede">입력할 수도 있고 고를 수도 있는 field입니다. 입력한 글자가 목록을 거르고, 막지 않는 한 그 글자 자체가 값이 될 수도 있습니다.</p>

<Demo src="combobox/hero" :min-height="180" />

::: fw react

```tsx
import { PlCombobox } from 'plass-ui';

<PlCombobox
  label="Framework"
  placeholder="Search…"
  items={[
    { value: 'react', label: 'React' },
    { value: 'vue', label: 'Vue' }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlCombobox<String>(
  label: const Text('Framework'),
  placeholder: 'Search…',
  value: framework,
  onChanged: (String? next) => setState(() => framework = next),
  options: const <PlComboboxOption<String>>[
    PlComboboxOption<String>(value: 'react', label: 'React'),
    PlComboboxOption<String>(value: 'vue', label: 'Vue'),
  ],
);
```

목록은 트리 밖으로 자기를 들어 올리므로 combobox 위에 `Overlay`가 필요합니다 — navigator가 있는 `WidgetsApp`과 `MaterialApp` 둘 다 하나씩 제공합니다.

:::

## Props

<PropsTable name="PlCombobox" />

::: fw react

나머지 `<div>` 속성은 field 래퍼로 그대로 통과합니다. `color`는 위 표의 `color`와 겹쳐서, `defaultValue`는 DOM 속성이 아니라 값으로 쓰기 때문에, `children`은 옵션이 `items`이기 때문에 제외했습니다.

`className`은 label과 control, 그 아래 두 줄을 함께 담는 stack에 붙습니다. 그 안쪽 네 부분에 닿는 것이 `classNames`입니다 — `label`, `control`(chip까지 포함한 field의 껍데기), `description`, `error`.

:::

::: fw flutter

combobox는 값의 타입에 대해 generic이고 — `PlCombobox<String>`, `PlCombobox<Tag>` — 패키지의 다른 모든 입력과 마찬가지로 **controlled**입니다. 여러 값을 담는 건 두 번째 생성자인 `PlCombobox.multiple`이고, `values`를 받아 `List<T>`를 보고합니다. `multiple` 플래그 하나를 가진 위젯이라면 두 가지 모양의 값을 다 들고 있어야 하고 둘 다 타입이 붙지 않습니다.

`onCreate`는 React의 `allowCustom`에 해당하고, 플래그가 아니라 콜백인 데는 React에는 없는 이유가 있습니다. 저쪽에서 값은 언제나 `string`이나 `number`라 field가 질의로부터 스스로 하나를 만들 수 있습니다. 여기서 값은 `T`이고, 그걸 만드는 법은 호출자만 압니다 — 그래서 허가와 만드는 법이 같은 파라미터입니다. `PlCombobox<String>`이라면 `(String query) => query`입니다.

:::

### PlComboboxOption

<PropsTable name="PlComboboxOption" />

공유 축(`variant` `size` `color` `density` `elevation`)이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## PlTextField 위에 세운 것

픽셀 단위로 그렇고, [`PlSelect`](./select)의 trigger도 마찬가지입니다. 폼 안에서 셋이 구분되지 않아야 폼이 조립된 게 아니라 설계된 것으로 보입니다. 껍데기가 셋 중 어디도 아닌 `internal/styles`에 사는 이유입니다.

다른 건 글자가 하는 일입니다. select에서 글자는 값이고, 여기서 글자는 목록을 거르며 값이 될 수도 있습니다.

## Examples

### 고르기와 입력하기

[`PlSelect`](./select)는 닫힌 집합에서 고르는 컨트롤입니다. 이건 집합을 _검색_ 하는 컨트롤이고, 기본값인 `allowCustom`이 켜져 있으면 거기에 더할 수도 있는 컨트롤입니다.

입력한 글자는 목록 끝의 자기 행으로 제안됩니다. 그래서 그것을 확정하는 건 사용자가 하는 선택이지, blur에서 사용자에게 일어나는 일이 아닙니다. 값이 정말로 닫힌 집합이면 `allowCustom`을 끄세요 — 그러면 검색되는 select가 됩니다.

<Demo src="combobox/custom" :min-height="260">

::: fw react

<<< @/.vitepress/demos/combobox/custom.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/custom.dart

:::

</Demo>

### multiple

고른 값들이 field 안의 [`PlChip`](../display/chip)이 되고 입력은 그 뒤로도 계속 필터링합니다. field가 한 번도 닫히지 않은 채 태그 묶음이 만들어집니다.

이때 field는 고정 높이를 가질 수 없습니다 — chip이 줄바꿈하니까요 — 그래서 패딩이 `(컨트롤 높이 − chip 높이) / 2`가 되고, 한 줄짜리 combobox는 옆의 field와 정확히 같은 높이가 됩니다.

<Demo src="combobox/multiple" :min-height="180">

::: fw react

<<< @/.vitepress/demos/combobox/multiple.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/multiple.dart

:::

</Demo>

### size

다른 모든 컨트롤과 같은 높이 사다리입니다. `multiple`에서는 위의 이유로 그 숫자가 높이가 아니라 최소 높이가 됩니다.

<Demo src="combobox/sizes" :min-height="300">

::: fw react

<<< @/.vitepress/demos/combobox/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/sizes.dart

:::

</Demo>

### readOnly · disabled · error

`error`는 combobox를 invalid로도 만들고, 그러면 색 계열 전체가 `danger`로 옮겨 갑니다 — 테두리와 ring과 caret과 메시지가 함께 넘어갑니다. `invalid`는 메시지 없이 같은 일을 합니다.

`readOnly` combobox는 값과 포커스를 유지하되 입력을 받지 않고, chip의 ×도 사라집니다. `disabled`는 포커스 순서에서 빠집니다.

옵션 하나만 `disabled`일 수도 있습니다. 그래도 목록에 남습니다 — 고를 수 없다고 사라지는 옵션은 독자가 찾아 헤매게 되는 옵션입니다.

<Demo src="combobox/states" :min-height="300">

::: fw react

<<< @/.vitepress/demos/combobox/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/states.dart

:::

</Demo>

### Controlled

`value`를 `onValueChange`와 함께 주세요. 값은 `string`이나 `number`이고 — `multiple`이면 그 배열입니다 — 절대 객체가 아닙니다. combobox는 form 컨트롤이고, 그 값은 form이 보내는 것입니다. 식별자를 여기 두고 객체는 반대편에서 찾으세요.

## Accessibility

::: fw react

- Base UI가 `combobox`/`listbox` 쌍을 렌더링하고 `aria-expanded`와 `aria-activedescendant`를 맞춰 두며, 필터링과 collator도 소유합니다.
- `label` `description` `error`는 Base UI의 Field가 입력창과 엮어 주므로 `htmlFor`가 필요 없습니다.
- 키보드는 primitive의 것입니다. <kbd>↑</kbd> <kbd>↓</kbd>로 목록을 움직이고, <kbd>Enter</kbd>로 강조된 행을 취하고, <kbd>Esc</kbd>로 닫습니다. `multiple`에서는 <kbd>←</kbd> <kbd>→</kbd>가 chip 사이를 걷고 <kbd>Backspace</kbd>가 하나를 지웁니다.
- 입력하는 동안 첫 일치 항목에 불이 들어와서, 화살표 없이 <kbd>Enter</kbd>만으로 확정됩니다. "이걸 추가" 행이 키보드로 닿을 수 있는 이유도 이것입니다 — 목록에 없는 값은 유일한 일치 항목이니까요.
- "이걸 추가" 행은 키 처리의 특수 케이스가 아니라 **진짜 option**입니다. 클릭도, <kbd>Enter</kbd>도, 화살표도 다른 모든 행과 똑같은 방식으로 닿습니다.
- 행은 `:hover`가 아니라 `data-highlighted`로 켜집니다. 포인터와 화살표가 같은 행을 밝힙니다.
- chip의 ×는 자기 chip의 이름을 답니다 — `Remove`가 아니라 `Remove Seoul`. 똑같은 버튼 여섯 개를 읽어 주는 스크린리더는 아무것도 말해 주지 않은 것과 같습니다.
- `name`이 있으면 Base UI가 hidden input을 렌더링해 값이 네이티브 form 제출에 포함됩니다.
- 팝업은 `<body>` 끝으로 portal되고 positioner가 `.plass-portal`을 답니다. CSS 리셋을 subtree에 한정한 호스트가 같은 리셋을 걸 수 있는 자리입니다.

:::

::: fw flutter

- field는 목록이 열려 있는지 말해 주는 text field로 읽힙니다. 각 행은 서로 배타적인 묶음 중 하나로, 취해졌는지 여부와 함께 읽힙니다.
- **키는 field에 머뭅니다.** 포커스도 그렇습니다. <kbd>↑</kbd> <kbd>↓</kbd>가 강조를 옮기고, <kbd>Enter</kbd>가 강조된 행을 취하고, <kbd>Escape</kbd>가 아무것도 취하지 않고 닫습니다. 목록은 field의 목록이지 두 번째로 머물 자리가 아닙니다.
- 질의가 바뀔 때마다 첫 일치 항목에 불이 들어와서, 화살표 없이 <kbd>Enter</kbd>만으로 확정됩니다 — 생성 행이 키보드로 닿을 수 있는 이유도 이것입니다.
- 강조는 행마다의 hover 상태가 아니라 숫자 하나입니다. 그래서 포인터와 화살표가 같은 행을 밝힙니다.
- 취할 수 없는 행도 목록에 남고, 사용할 수 없다고 읽힙니다.
- chip의 ×는 자기 chip의 이름을 답니다.
- 포커스가 떠날 때 아무것도 확정되지 않습니다. 질의는 값으로 되돌아가고, 목록에 없는 값은 오직 그 행을 취해야만 값이 됩니다.

:::

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `items` | `options` | 패키지의 나머지가 선택지 목록을 부르는 이름입니다. |
| 값이 `string \| number` | generic `T` | 여기서는 제출되는 것이 없으므로 값이 그 물건 자체일 수 있고, 타입 검사기가 지켜 줍니다. |
| prop으로서의 `multiple` | 두 번째 생성자 `PlCombobox.multiple` | 플래그 하나짜리 위젯은 두 모양의 값을 다 들고 있어야 하고 둘 다 타입이 붙지 않습니다. |
| `allowCustom` (기본이 켜진 `boolean`) | `onCreate` (`T Function(String)`) | field는 질의로부터 `T`를 만들 수 없습니다. 허가와 만드는 법이 같은 파라미터입니다. |
| `ReactNode` label, Base UI collator 기반 필터 | `Widget`, 대소문자 접은 `contains` 필터 | label이 여전히 `String`인 건 같은 이유입니다 — 필터가 그것을 읽고, field에 써 넣습니다. |
| hidden input, `name`, `required` | — | 참여할 네이티브 form 제출이 없습니다. |
| `className`, `style`, 네이티브 속성 | — | 통과시킬 class 목록도 style 속성도 없습니다. |
