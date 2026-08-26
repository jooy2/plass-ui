---
title: PlSelect
order: 4
---

# PlSelect

<p class="plass-lede">여러 값 중 하나를 고릅니다. trigger는 chevron을 단 <code>PlTextField</code>의 껍데기 그대로라, 같은 form 안의 select와 field가 하나의 물건으로 읽힙니다.</p>

<Demo src="select/hero" :min-height="180" />

::: fw react

```tsx
import { PlSelect } from 'plass-ui';

<PlSelect
  label="City"
  placeholder="Pick a city"
  items={[
    { value: 'seoul', label: 'Seoul' },
    { value: 'lisbon', label: 'Lisbon' }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlSelect<String>(
  label: const Text('City'),
  placeholder: const Text('Pick a city'),
  value: city,
  onChanged: (String? next) => setState(() => city = next),
  options: const <PlSelectOption<String>>[
    PlSelectOption<String>(value: 'seoul', label: Text('Seoul')),
    PlSelectOption<String>(value: 'lisbon', label: Text('Lisbon')),
  ],
);
```

목록은 자기를 트리 밖으로 들어 올리므로 select 위쪽에 `Overlay`가 필요합니다 — navigator가 있는 `WidgetsApp`과 `MaterialApp`이 둘 다 제공합니다.

:::

## Props

<PropsTable name="PlSelect" />

::: fw react

네이티브 `<div>` 속성은 field wrapper로 그대로 전달됩니다. `color`는 위 표의 `color`와 충돌해서, `defaultValue`는 DOM 속성이 아니라 값으로 쓰기 때문에, `children`은 옵션이 `items`이기 때문에 제외됩니다.

:::

::: fw flutter

select는 값 타입에 대해 제네릭입니다 — `PlSelect<String>`, `PlSelect<Currency>` — 그래서 `value`와 `onChanged`가 관습이 아니라 타입으로 지켜지며, 패키지의 다른 입력들과 마찬가지로 **controlled**입니다.

그 제네릭이 React 빌드의 조언과 갈리는 유일한 지점입니다. 거기서 값이 일부러 `string`이나 `number`인 이유는 그것이 form이 제출하는 것이기 때문인데, 여기서는 제출되는 것이 없으니 값이 그 대상 자체일 수 있고 타입 검사기가 그것을 지켜 줍니다.

:::

### PlSelectOption

<PropsTable name="PlSelectOption" />

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### variant

`PlTextField`가 입는 것과 똑같은 세 재질을, 똑같은 껍데기 위에서 씁니다. `solid`는 색 유리판이 아니라 **우물** — 가장 불투명한 유리에 안쪽으로 떨어지는 그림자 — 입니다. 그러데이션 위에서 읽어야 하는 값은 결국 그러데이션 위에서 읽어야 하는 값이기 때문입니다.

<Demo src="select/variants" :min-height="140">

::: fw react

<<< @/.vitepress/demos/select/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/variants.dart

:::

</Demo>

### size

다른 모든 컨트롤과 같은 높이 사다리를 씁니다. trigger를 field의 껍데기 위에 그리는 이유가 바로 이것입니다 — select만 주변 field와 높이나 모서리, 재질이 다른 form은 설계된 것이 아니라 조립된 것처럼 보입니다.

<Demo src="select/sizes" :min-height="220">

::: fw react

<<< @/.vitepress/demos/select/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/sizes.dart

:::

</Demo>

### readOnly · disabled · error

`error`는 select를 invalid로도 만들고, 그러면 색 계열 전체가 `danger`를 가리킵니다 — 테두리, ring, 메시지가 함께 넘어갑니다. `invalid`는 메시지 없이 같은 일을 합니다. 외부 form 라이브러리가 유효성을 쥐고 있을 때 쓰세요.

`readOnly`인 select는 값과 focus를 유지하지만 열리지 않습니다. `disabled`인 것은 포커스 순서에서 빠집니다.

옵션 하나만 `disabled`로 둘 수도 있습니다. 그래도 목록에는 남습니다 — 고를 수 없다고 사라지는 옵션은 읽는 사람이 계속 찾게 되는 옵션입니다.

<Demo src="select/states" :min-height="200">

::: fw react

<<< @/.vitepress/demos/select/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/states.dart

:::

</Demo>

### Controlled

::: fw react

`value`와 `onValueChange`를 함께 넘기세요. 값은 언제나 `string`이나 `number`이고 객체가 아닙니다 — select는 form 컨트롤이고, 그 값은 form이 제출하는 것입니다. 식별자만 여기 두고 객체는 반대쪽에서 찾으세요.

:::

::: fw flutter

여기서는 이것이 유일한 방식입니다. `value`와 `onChanged`이고, 값은 `T`입니다 — enum이든, id든, 객체 자체든. `null`은 아무것도 고르지 않은 select입니다.

:::

<Demo src="select/controlled" :min-height="160">

::: fw react

<<< @/.vitepress/demos/select/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/controlled.dart

:::

</Demo>

### startIcon

옆의 값보다 1.2배로 그려져 그 크기를 따라갑니다. `endIcon`은 없습니다 — trigger의 끝자리는 chevron의 것입니다.

<Demo src="select/icons" :min-height="160">

::: fw react

<<< @/.vitepress/demos/select/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/icons.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI가 `role="combobox"` trigger와 진짜 `option` 행을 가진 `listbox` 팝업을 렌더링하고, `aria-expanded`와 `aria-activedescendant`를 맞춰 주며, 목록이 열려 있는 동안 focus를 가둡니다.
- `label`, `description`, `error`는 Base UI의 Field가 trigger에 엮어 주므로 `htmlFor`가 필요 없습니다.
- 키보드는 primitive의 것입니다. <kbd>↑</kbd> <kbd>↓</kbd> <kbd>Home</kbd> <kbd>End</kbd>로 이동하고, 글자를 치면 prefix로 건너뛰며, <kbd>Enter</kbd>로 고르고 <kbd>Esc</kbd>로 닫습니다.
- 행은 `:hover`가 아니라 `data-highlighted`에서 밝아집니다. 포인터와 방향키가 같은 행을 비춥니다.
- `name`을 주면 Base UI가 hidden input을 렌더링해서 값이 네이티브 form 제출에 포함됩니다.
- trigger는 보여 줄 수 있는 가장 긴 라벨의 너비로 벌어져 있습니다. 짧은 옵션을 골랐다고 방금 고른 포인터 아래에서 필드가 줄어들지 않습니다. 이 샘플들은 `aria-hidden`이고 생성 콘텐츠로 그려지므로, 읽히지도 않고 페이지 내 검색에 걸리지도 않습니다.
- 팝업은 `<body>` 끝으로 portal되고, positioner에 `.plass-portal`이 붙습니다. reset을 subtree에 한정해 둔 호스트가 같은 reset을 걸 수 있는 자리입니다.

:::

::: fw flutter

- trigger는 무엇이 골라졌는지와 목록이 열려 있는지를 말하는 버튼으로 읽힙니다. 각 행은 서로 배타적인 묶음의 하나로, 골라졌는지 아닌지와 함께 읽힙니다.
- **키는 trigger에 남고**, focus도 그렇습니다. <kbd>↑</kbd> <kbd>↓</kbd>가 하이라이트를 옮기고, <kbd>Home</kbd>과 <kbd>End</kbd>가 양 끝으로 가며, <kbd>Enter</kbd>가 하이라이트된 행을 고르고 <kbd>Escape</kbd>는 고르지 않고 닫습니다. 목록은 trigger의 목록이지 따로 가 있어야 할 두 번째 장소가 아닙니다.
- 하이라이트는 행마다의 hover 상태가 아니라 숫자 하나입니다. 포인터와 방향키가 같은 행을 비추게 하는 것이 그것입니다.
- 고를 수 없는 행도 목록에 남고, 사용할 수 없다고 읽힙니다. 고를 수 없다고 사라지는 옵션은 읽는 사람이 계속 찾게 되는 옵션입니다.
- trigger는 말할 수 있는 가장 긴 라벨의 너비로 벌어져 있습니다. 그 샘플들은 배치되되 그려지지 않고 semantics에서도 제외되므로, 읽히는 것이 늘지 않습니다.
- 목록을 열면 focus가 trigger로 갑니다. 목록의 키가 거기 묶여 있기 때문입니다 — 아무 데도 focus가 없는 열린 select는 방향키가 닿을 수 없는 목록입니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `items` | `options` | 선택지 목록에 대해 패키지의 나머지가 쓰는 단어입니다 — radio group의 것도 `options`입니다. |
| `string \| number` 값 | 제네릭 `T` | 여기서는 제출되는 것이 없으니 값이 그 대상 자체일 수 있고, 타입 검사기가 지켜 줍니다. |
| `value` / `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter의 컨트롤은 controlled이고, 콜백 이름도 Flutter의 것입니다. |
| 글자를 쳐서 prefix로 건너뛰기 | — | typeahead에는 모든 라벨의 글자가 필요한데, 여기서 라벨은 위젯입니다. 긴 목록에는 추측 대신 위에 놓인 검색 field가 낫습니다. |
| focus가 팝업으로 이동 | focus는 trigger에 남음 | 목록은 trigger의 목록입니다. 시작한 자리에 focus를 두는 것이, 닫을 때 되돌릴 것이 없게 만드는 방법이기도 합니다. |
| hidden input, `name`, `required` | — | 함께 제출될 네이티브 form이 없습니다. |
| `id` | — | 여기서는 무엇도 id로 다른 것을 가리키지 않습니다. 라벨과 메시지는 컴포넌트의 일부입니다. |
| `role="combobox"`, `aria-activedescendant` | 펼쳐짐이 표시된 버튼과, 배타적 묶음의 행들 | Flutter는 상태를 노드 자체에 적습니다. 가리킬 id가 없습니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
