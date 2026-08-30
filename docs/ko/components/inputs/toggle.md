---
title: PlToggle
order: 16
---

# PlToggle

<p class="plass-lede">눌린 채로 남는 버튼, 그리고 하나의 상태를 나누는 그 묶음입니다. 꺼진 상태는 중립입니다 — 쉬고 있는 토글은 아직 취해지지 않은 액션이 아니라, 지금 거짓인 상태이기 때문입니다.</p>

<Demo src="toggle/hero" :min-height="180" />

::: fw react

```tsx
import { PlToggle, PlToggleGroup } from 'plass-ui';

<PlToggle pressed={bold} onPressedChange={setBold}>
  Bold
</PlToggle>;

<PlToggleGroup multiple value={marks} onValueChange={setMarks}>
  <PlToggle value="bold">Bold</PlToggle>
  <PlToggle value="italic">Italic</PlToggle>
</PlToggleGroup>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlToggle(
  pressed: bold,
  onPressedChanged: (bool next) => setState(() => bold = next),
  child: const Text('Bold'),
);

PlToggleGroup(
  multiple: true,
  value: marks,
  onValueChanged: (List<String> next) => setState(() => marks = next),
  children: const <Widget>[
    PlToggle(value: 'bold', child: Text('Bold')),
    PlToggle(value: 'italic', child: Text('Italic')),
  ],
);
```

:::

## Props

<PropsTable name="PlToggle" />

::: fw react

네이티브 `<button>` 속성은 모두 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라, `value`는 제출되는 값이 아니라 그룹 안에서 토글을 식별하는 것이라 제외됩니다.

:::

### PlToggleGroup

<PropsTable name="PlToggleGroup" />

공용 축(`variant` `size` `color` `density` `elevation`)이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 어느 컨트롤인가

- **토글**은 옆에 있는 것의 상태를 바꿉니다 — 선택한 글자의 볼드, 캔버스의 그리드, 목록의 필터. 컨트롤이고, 폼에는 들어가지 않습니다.
- [`PlSwitch`](./switch)는 설정을 바꾸고, 그 변화 자체가 핵심입니다.
- [`PlCheckbox`](./checkbox)는 컨트롤이 아니라 폼 안의 답입니다.
- 하나를 고르는 **값**이라면 [`PlSegmentedButton`](./segmented-button)이나 [`PlRadioGroup`](./radio-group)입니다. `multiple` 없는 `PlToggleGroup`은 그것처럼 보이지만 아닙니다. 담고 있는 것은 답이 아니라 상태입니다.

## 예제

### variant

**꺼져 있을 때** 키가 무엇으로 만들어졌는지입니다. 켜지면 어느 재질이든 색 계열이 나서고, 그때 내놓는 두 답은 `PlSegmentedButton`의 선택된 세그먼트가 내놓는 것과 같습니다 — `solid`는 그러데이션과 on-fill 잉크를, `glass`와 `ghost`는 시트를 밝히고 라벨을 accent로 둡니다.

꺼져 있을 때 잉크는 셋 다 `--plass-muted-fg`이고, 어느 것에도 색이 들어가지 않습니다. 꺼진 토글은 맑은 유리 한 조각이고, 색 계열은 누름과 함께 도착하지 그전에는 오지 않습니다.

<Demo src="toggle/variants" :min-height="220">

::: fw react

<<< @/.vitepress/demos/toggle/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle/variants.dart

:::

</Demo>

### elevation은 움직이지 않습니다

켜진 토글은 들어 올려진 토글이 아닙니다. `elevation`은 두 상태에서 같고 색만 바뀝니다. "켜짐"은 키가 페이지에서 얼마나 떠 있는지가 아니라 토글 옆에 있는 것에 대한 사실이기 때문입니다.

기본값은 `0`이고 [`PlButton`](./button)보다 한 단계 아래인데, 같은 이유입니다.

## size

컨트롤 사다리 그대로입니다. `md` 토글은 40px이고 옆의 필드·버튼과 줄이 맞습니다. `density`는 여백만 옮깁니다.

<Demo src="toggle/sizes" :min-height="140">

::: fw react

<<< @/.vitepress/demos/toggle/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle/sizes.dart

:::

</Demo>

### PlToggleGroup

두 가지가 일어나는데 그중 하나만 시각적입니다. 이웃을 마주하는 모서리가 각지는 것 — 그게 겉모습입니다. 나머지 절반은 세트가 값을 쥔다는 것입니다. 토글들이 하나의 배열로 보고하고, `variant`, `size`, `color`, `density`, `elevation`, `disabled`는 토글마다가 아니라 그룹에서 한 번 정해집니다.

값은 **두 경우 모두 배열**입니다. `multiple`을 켜도 타입이 바뀌지 않는 유일한 모양입니다.

<Demo src="toggle/group" :min-height="300">

::: fw react

<<< @/.vitepress/demos/toggle/group.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle/group.dart

:::

</Demo>

### 아이콘만, 라벨 없이

`children`을 빼면 토글은 받은 아이콘 둘레로 정사각형이 됩니다. 툴바 토글이 바로 그것입니다. 그래도 `aria-label`은 필요합니다 — 라벨이 통째로 그림인 컨트롤에는 접근 가능한 이름이 아예 없습니다.

<Demo src="toggle/icons" :min-height="140">

::: fw react

<<< @/.vitepress/demos/toggle/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle/icons.dart

:::

</Demo>

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| Base UI의 `aria-pressed` | `Semantics(toggled:)` | 프레임워크 자신의 이름으로 된 같은 주장입니다 — 무언가를 하는 버튼이 아니라 상태를 가진 버튼. |
| 그룹 전체가 tab stop 하나, 안에서는 화살표 키 | 토글마다 focus stop 하나 | Base UI의 roving tab index에 대응하는 것이 `widgets.dart`에는 없고, 잘못 구현한 roving focus는 플랫폼 자신의 순회보다 나쁩니다. 값이 정말로 필요한 자리에서는 `PlSegmentedButton`이 진짜를 지니고 있습니다. |
| 자유롭게 조합하는 `children` | 그룹의 `children: List<Widget>` | 어느 구성원이 양 끝인지 알아야 올바른 모서리를 각지게 할 수 있고, 그룹이 셀 수 있는 것이 리스트입니다. |
| `loopFocus` | — | 돌릴 roving focus가 없습니다. |
| `onPressedChange` | `onPressedChanged` | Flutter의 이름입니다. |
| `aria-label` | `semanticLabel` | Flutter의 이름입니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 class 목록도 style 속성도 없습니다. |

:::

## 접근성

::: fw react

- Base UI가 `aria-pressed`를 지닌 진짜 `<button>`을 그립니다. "이건 무언가를 한다"가 아니라 "이건 상태다"라고 말하는 것이 그것입니다.
- `PlToggleGroup`은 tab stop 하나이고 화살표 키가 구성원 사이를 움직입니다. 토글 여덟 개짜리 툴바가 여덟 번이 아니라 두 번의 키 누름 깊이가 되는 이유입니다. `loopFocus`가 양 끝에서 화살표가 돌아가는지 정합니다.
- 아이콘만 있는 토글에는 `aria-label`이 필요합니다. 다른 무엇도 그것에 이름을 주지 못합니다.
- `disabled`는 토글을 tab 순서에서 뺍니다. 그룹의 `disabled`는 모든 구성원에 한 번에 그렇게 합니다.
- 포인터 빛은 disabled인 동안 꺼집니다. 아무도 누를 수 없는 표면이 포인터에 답하지 않도록.

:::

::: fw flutter

- 토글은 `Semantics(button: true, toggled: …)`이고, 반대쪽의 `aria-pressed`와 같은 주장입니다.
- 라벨 없이 아이콘만 있는 토글에는 `semanticLabel`이 필요합니다. 다른 무엇도 그것에 이름을 주지 못합니다.
- `disabled`는 토글을 focus 순서에서 빼고 포인터에 아예 답하지 않게 합니다. 빛도 함께 꺼집니다.
- 그룹 안의 토글은 각자 하나의 focus stop입니다. roving focus는 여기에 없고, React 빌드에 있고 여기에 없는 유일한 것이 그것입니다.

:::
