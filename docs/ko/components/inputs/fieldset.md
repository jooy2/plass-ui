---
title: PlFieldset
order: 19
---

# PlFieldset

<p class="plass-lede">한 질문에 함께 답하는 컨트롤 묶음이고, 그 위에 이름이 붙습니다. 표면은 그리지 않습니다. 묶음은 시트가 아니고, 시트는 이미 있습니다.</p>

<Demo src="fieldset/hero" :min-height="300" />

::: fw react

```tsx
import { PlFieldset, PlTextField } from 'plass-ui';

<PlFieldset legend="Billing address" description="Where the invoice goes.">
  <PlTextField label="Street" />
  <PlTextField label="City" />
</PlFieldset>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlFieldset(
  legend: const Text('Billing address'),
  description: const Text('Where the invoice goes.'),
  children: <Widget>[streetField, cityField],
);
```

:::

## Props

<PropsTable name="PlFieldset" />

::: fw react

네이티브 `<fieldset>` 속성은 모두 그대로 전달됩니다. `color`는 fieldset에 색을 칠할 표면이 없어서 제외됩니다.

:::

공용 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 이 컴포넌트가 쥐는 세 가지

셋뿐입니다.

- **legend.** 안에 든 모든 컨트롤의 접근 가능한 이름에 들어갑니다. 각각 앞에 놓아도 말이 되는 구절이어야 하는 이유가 그것입니다. "받는 주소"이지 "어디로 보낼까요?"가 아닙니다.
- **간격.** 컨트롤이 서는 거리이고, 시트 사다리를 씁니다.
- **`disabled`.** 진짜 `<fieldset>`만 할 수 있는 그 하나입니다. 안의 모든 컨트롤에 닿습니다: 세 단계 아래의 컴포넌트가 그리고 이쪽이 존재조차 모르는 것까지.

표면을 그리지 않고 `color`, `variant`, `elevation`도 받지 않습니다. 필드의 묶음은 묶음입니다. 시트가 필요하면 [`PlCard`](../surfaces/card)나 [`PlBox`](../surfaces/box) 안에 넣으세요.

## Examples

### disabled

`<div>` 대신 fieldset을 쓰는 이유입니다. 켜면 안의 모든 컨트롤이 tab 순서에서도 폼에서도 빠집니다. fieldset이 그것들이 무엇인지 알 필요 없이.

<Demo src="fieldset/disabled" :min-height="280">

::: fw react

<<< @/.vitepress/demos/fieldset/disabled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/fieldset/disabled.dart

:::

</Demo>

### size

legend의 타입 스케일과 컨트롤 사이의 간격이고, 시트 사다리를 씁니다. [`PlCard`](../surfaces/card)가 섹션을 나눌 때 쓰는 그 사다리인데, fieldset은 폼 안의 컨트롤이 아니라 폼의 한 섹션이기 때문입니다.

<Demo src="fieldset/sizes" :min-height="360">

::: fw react

<<< @/.vitepress/demos/fieldset/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/fieldset/sizes.dart

:::

</Demo>

### 시트 안에서

카드 하나에 fieldset 둘이 흔한 배치이고, 표면을 그리지 않는 규칙이 값을 하는 자리가 거기입니다. 카드가 시트이고, 각 묶음은 그 위의 이름과 간격입니다.

<Demo src="fieldset/on-a-sheet" :min-height="360">

::: fw react

<<< @/.vitepress/demos/fieldset/on-a-sheet.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/fieldset/on_a_sheet.dart

:::

</Demo>

## 되돌린 브라우저 기본값 둘

`<fieldset>`은 자기만의 border, padding, margin을 갖고 도착하는데, 셋 다 이 라이브러리의 것이 아닙니다. 전부 되돌립니다.

`min-width: min-content`도 마찬가지입니다. 모든 브라우저가 fieldset에만 주는 값이고, 넓은 표를 담은 fieldset이 flex row 안에서 줄어들기를 거부하는 이유가 그것입니다. `min-w-0`이 그것을 되돌립니다.

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| 네이티브 `<fieldset>` 속성인 `disabled` | 포인터를 거두고, focus를 거두고, 묶음을 비움 | Flutter에는 그런 cascade가 없습니다. 그 속성이 실제로 사 주는 세 가지를 대신 합니다. 못 하는 것은 안의 필드가 스스로 "쓸 수 없음"이라고 _말하게_ 하는 것이라, 그렇게 알려야 하는 필드에는 자기 `disabled`를 주세요. |
| 브라우저의 border·padding·margin·`min-width`를 되돌린 `<fieldset>` | `Column` | 되돌릴 것이 없습니다. |
| 모든 컨트롤의 접근 가능한 이름에 들어가는 legend | 이름 있는 컨테이너 위의 heading인 legend | 물려받을 `<fieldset>`/`<legend>` 짝이 Flutter에는 없고, 컨트롤 이름마다 앞에 붙이면 묶음의 이름을 컨트롤 수만큼 말하게 됩니다. |
| `children` | `children: List<Widget>` | 스택을 여기서 배치하므로 받은 것을 셉니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 class 목록도 style 속성도 없습니다. |

:::

## Accessibility

- 진짜 `<fieldset>`이고, 그것이 `group`이며, legend가 이름을 냅니다.
- legend는 그려진 `<legend>`가 아니라 `aria-labelledby`가 가리키는 `<div>`입니다. Base UI의 결정이고, 그 덕에 묶음이 평범한 flex 컨테이너가 됩니다. 진짜 `<legend>`는 모든 브라우저가 fieldset의 content box 밖으로 들어 올리므로, `gap`이 그 아래에 아무 공간도 만들지 못합니다.
- fieldset의 `disabled`는 네이티브 속성이라 플랫폼이 하는 방식으로 자손을 비활성화합니다. context도, prop을 꿰는 일도, 나중에 추가된 컨트롤에서 잊을 것도 없습니다.
- `legend`도 `description`도 없는 fieldset은 heading 블록을 아예 그리지 않습니다. 빈 이름은 없는 것보다 나쁩니다. 모든 컨트롤 이름 앞에 공백을 붙이기 때문입니다.
