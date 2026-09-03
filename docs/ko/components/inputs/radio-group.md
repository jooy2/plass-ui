---
title: PlRadioGroup
order: 7
---

# PlRadioGroup

<p class="plass-lede">여러 옵션 중 정확히 하나를 고르는 묶음입니다. 묶음 전체가 tab stop 하나를 차지하고, 그 안에서는 방향키로 움직입니다.</p>

<Demo src="radio-group/hero" :min-height="240" />

::: fw react

```tsx
import { PlRadio, PlRadioGroup } from 'plass-ui';

<PlRadioGroup label="Plan" defaultValue="team">
  <PlRadio value="starter" label="Starter" />
  <PlRadio value="team" label="Team" />
</PlRadioGroup>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlRadioGroup<String>(
  label: const Text('Plan'),
  value: plan,
  onChanged: (String next) => setState(() => plan = next),
  options: const <PlRadioOption<String>>[
    PlRadioOption<String>(value: 'starter', label: Text('Starter')),
    PlRadioOption<String>(value: 'team', label: Text('Team')),
  ],
);
```

:::

## Props

<PropsTable name="PlRadioGroup" />

::: fw react

Base UI `RadioGroup`의 나머지 prop은 그대로 전달됩니다. `className`과 `style`은 field wrapper에 붙고, `render`는 제공하지 않습니다.

그 wrapper 안쪽 네 부분에 닿는 것이 `classNames`입니다 — `label`, `control`(radio들이 늘어선 줄), `description`, `error`.

:::

::: fw flutter

그룹은 옵션 값의 타입에 대해 제네릭입니다 — `PlRadioGroup<String>`, `PlRadioGroup<Plan>` — 그래서 `value`와 `onChanged`가 `dynamic`이 아니라 타입을 가지고, 묶음에 속하지 않는 값은 컴파일되지 않습니다.

그리고 **controlled**입니다. 패키지의 다른 모든 컨트롤과 같습니다.

:::

::: fw react

### PlRadio

<PropsTable name="PlRadio" />

:::

::: fw flutter

### PlRadioOption

<PropsTable name="PlRadioOption" />

:::

::: fw react

`size`와 `color`는 옵션에 주는 것이 아니라 감싸는 `PlRadioGroup`에서 내려받습니다. radio button은 혼자서는 아무 말도 하지 않으므로, 어떻게 보이는지는 묶음의 몫입니다. 옵션마다 주는 것은 넷 중 하나를 틀릴 기회를 네 번 만드는 일입니다.

:::

::: fw flutter

옵션은 **위젯이 아니라 설명인 `PlRadioOption`**이고, 여기서의 이유는 [breadcrumb](../display/breadcrumb)의 이유보다 더 분명합니다. 그룹이 roving focus와 화살표 키를 소유하므로, 어느 옵션이 선택되었는지, 어느 것을 고를 수 있는지, 각각의 다음이 무엇인지를 알아야 합니다. 그중 어느 것도 `Widget`에는 물어볼 수 없습니다.

`size`도 `color`도 가지지 않으며, 가질 수도 없습니다. radio button은 혼자서는 아무 말도 하지 않으므로, 어떻게 보이는지는 묶음의 몫입니다.

:::

점은 채움과 함께 켜지지 않고 **고리 한가운데에서 자라며**, 묶음의 다른 옵션이 값을 가져가면 다시 줄어듭니다. 커지는 것은 상자이지 `transform`이 아닙니다. 고리가 고정 크기 자식을 가운데 두므로 변화의 양쪽 끝이 같은 점을 중심으로 배치되고, 옵션 주위의 무엇도 움직이지 않습니다. [모션](../../design/design-language#표식은-켜지는-것이-아니라-그려집니다)을 보세요.

라이브러리 전체에서 공유 축(`size` `color` `orientation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### orientation

기본은 세로입니다. 세로로 늘어선 옵션은 개수가 늘어도 훑을 수 있지만, 가로줄은 라벨 하나가 예상보다 길어지는 순간 조용히 읽기 어려워집니다.

<Demo src="radio-group/orientation" :min-height="280">

::: fw react

<<< @/.vitepress/demos/radio-group/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/orientation.dart

:::

</Demo>

### color

선택되면 dot이 색 계열의 그러데이션으로 채워지고, 안쪽 원은 계열 고유의 `on-solid` 잉크입니다. dot은 둥글고, 라이브러리에서 둥근 것 둘 중 하나입니다 — 둥근 모양이 "이 중 하나"와 "이 중 아무거나"를 구분해 주고, 이 관습은 깨는 비용이 얻는 것보다 큰 정도로 오래된 것입니다.

<Demo src="radio-group/colors" :min-height="180">

::: fw react

<<< @/.vitepress/demos/radio-group/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/colors.dart

:::

</Demo>

### size

그룹에 주면 모든 옵션이 물려받으므로, 한 묶음 안에 dot 크기가 두 가지가 되는 일이 없습니다.

각 단계의 안쪽 원은 바깥 원의 content box와 **홀짝이 같습니다** — 12/6, 14/6, 16/8, 18/8, 22/10 — 그래서 둘레 여백이 정수 픽셀입니다. 1px 테두리를 가진 18px 원 안의 7px 점은 정확히 가운데에 있으면서 사방으로 4.5px 떨어져 있고, 네 변이 모두 절반만 칠해진 원은 왼쪽 위로 밀린 것처럼 읽힙니다. dot과 라벨이 함께 쓰는 line box가 정수인 것도 같은 이유입니다. 그 대가로 비율이 38%에서 44% 사이를 오가는데, 얻는 것에 비하면 보이지 않는 차이입니다.

<Demo src="radio-group/sizes" :min-height="180">

::: fw react

<<< @/.vitepress/demos/radio-group/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/sizes.dart

:::

</Demo>

### readOnly · disabled · error

그룹의 `disabled`는 모든 옵션을 멈추고, `PlRadio` 하나의 `disabled`는 그 옵션만 멈춥니다. 그래도 목록에는 남습니다 — 고를 수 없다고 사라지는 옵션은 읽는 사람이 계속 찾게 되는 옵션입니다.

그룹의 `error`는 invalid 상태도 만들고, 그러면 색 계열 전체가 `danger`를 가리킵니다.

<Demo src="radio-group/states" :min-height="260">

::: fw react

<<< @/.vitepress/demos/radio-group/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/states.dart

:::

</Demo>

### Controlled

::: fw react

`value`와 `onValueChange`를 함께 넘기세요. 값은 `PlRadio`에 준 것 그대로입니다 — 보통은 문자열이지만, Base UI가 identity로 비교하므로 렌더 사이에 안정적이기만 하면 무엇이든 됩니다.

:::

::: fw flutter

controlled 형태 하나뿐입니다. `value`와 `onChanged`. 옵션은 `==`로 비교하므로, 합리적인 동등성을 가진 값 타입 — `String`, `enum`, `@immutable`인 것 무엇이든 — 이면 빌드 사이에 같은 인스턴스를 유지하지 않아도 됩니다.

:::

<Demo src="radio-group/controlled" :min-height="180">

::: fw react

<<< @/.vitepress/demos/radio-group/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/controlled.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI가 진짜 radio들을 담은 `role="radiogroup"`을 렌더링하고 `aria-checked`를 맞춰 주며, roving tab index를 소유합니다 — 묶음이 tab stop 하나를 차지하고 <kbd>↑</kbd> <kbd>↓</kbd> <kbd>←</kbd> <kbd>→</kbd>로 그 안에서 움직입니다. radio group이 `<div>`에 input을 담은 것이 아니라 컴포넌트여야 하는 이유가 바로 이것입니다.
- 그룹의 `label`, `description`, `error`는 Base UI의 Field가 엮어 주고, 각 옵션의 라벨도 마찬가지입니다 — 라벨을 누르면 그 옵션이 선택됩니다.
- 각 dot은 자기 라벨의 **첫 줄**에 맞춰 중앙에 놓이므로, 라벨이 줄바꿈되어도 자리를 지킵니다.
- 선택된 dot은 색이 바뀌기만 하는 것이 아니라 채워진 원입니다. 채움을 볼 수 없는 사람에게는 모양이 상태를 나릅니다.
- `name`을 주면 Base UI가 hidden input을 렌더링해서 선택이 네이티브 form 제출에 포함됩니다.

:::

::: fw flutter

- 각 옵션은 서로 배타적인 묶음의 하나로, 선택 여부와 함께 알려집니다.
- 묶음은 focus stop **하나**를 차지합니다. 정확히 한 옵션만 tab 순서에 있고 나머지는 `ExcludeFocus`로 감싸여 있는데, 그것이 위젯 하나로 쓴 roving tab index입니다. <kbd>↑</kbd> <kbd>↓</kbd> <kbd>←</kbd> <kbd>→</kbd>가 선택을 옮기고, 양 끝에서 순환하며, 고를 수 없는 옵션은 건너뜁니다.
- 순환은 radio group에서 화살표 키가 하는 일이고 목록에서는 하지 않는 일입니다. 묶음은 시작이 없는 대안들의 고리입니다.
- 라벨을 누르면 그 옵션이 선택됩니다. 대상은 행 전체입니다.
- 각 dot은 자기 라벨의 **첫 줄**에 맞춰 중앙에 놓이므로, 라벨이 줄바꿈되어도 자리를 지킵니다.
- 선택된 dot은 색이 바뀌기만 하는 것이 아니라 채워진 원입니다. 채움을 볼 수 없는 사람에게는 모양이 상태를 나릅니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `<PlRadio>` children | 설명으로서의 `options` | 그룹이 roving focus와 화살표 키를 소유하므로, 어느 옵션이 선택되었고 그다음이 무엇인지 알아야 합니다. `Widget`은 불투명합니다. |
| `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter 자신의 컨트롤이 controlled이고, 콜백 이름도 Flutter의 것입니다. |
| identity로 비교하는 `unknown` 값 | `==`로 비교하는 제네릭 `T` | Dart에는 제네릭이 있어 타입이 검사됩니다 — 그리고 합리적인 동등성을 가진 값은 빌드 사이에 같은 인스턴스일 필요가 없습니다. |
| `name`과 hidden input | — | 포함될 네이티브 form 제출이 없습니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
