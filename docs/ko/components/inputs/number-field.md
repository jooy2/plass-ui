---
title: PlNumberField
order: 11
---

# PlNumberField

<p class="plass-lede">숫자만 담는 field입니다. 껍데기는 <code>PlTextField</code>와 픽셀 단위로 같고, 그 위에 진짜 숫자 컨트롤이 얹힙니다 — 방향키, 스테퍼, 범위 고정, locale을 아는 서식.</p>

<Demo src="number-field/hero" :min-height="260" />

::: fw react

```tsx
import { PlNumberField } from 'plass-ui';

<PlNumberField label="Quantity" min={1} max={12} defaultValue={2} />;
<PlNumberField label="Budget" locale="en-US" format={{ style: 'currency', currency: 'USD' }} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlNumberField(
  label: const Text('Quantity'),
  min: 1,
  max: 12,
  value: quantity,
  onChanged: (double? next) => setState(() => quantity = next),
);

PlNumberField(
  label: const Text('Budget'),
  value: budget,
  format: (double value) => '\$${value.toStringAsFixed(2)}',
  onChanged: (double? next) => setState(() => budget = next),
);
```

:::

## Props

<PropsTable name="PlNumberField" />

::: fw react

네이티브 `<div>` 속성은 field를 감싸는 요소에 그대로 전달됩니다. `color`, `defaultValue`, `children`은 셋 다 여기서는 Plass의 prop이라 전달 대상에서 제외됩니다.

`className`은 label과 control, 그 아래 두 줄을 함께 담는 stack에 붙습니다. 그 안쪽 네 부분에 닿는 것이 `classNames`입니다 — `label`, `control`(stepper까지 포함한 껍데기), `description`, `error`.

:::

::: fw flutter

패키지의 다른 입력들과 마찬가지로 **controlled**입니다. `value`를 받고 값이 무엇이 되어야 하는지를 보고합니다. `defaultValue`는 없고, `value`는 `double?`입니다 — `null`이 빈 상자입니다.

콜백이 하나가 아니라 둘이고, 그 차이가 라이브러리의 다른 어디보다 여기서 중요합니다. `onChanged`는 키를 누를 때마다 **입력된 것**과 함께 불리고, `onCommitted`는 field가 정착할 때 정착한 값과 함께 불립니다. `50`으로 가는 길의 `5`는 10에서 시작하는 범위 밖에 있는 것이 아니라 아직 덜 쓰인 것이라, 범위 고정은 field가 정착할 때까지 기다립니다.

:::

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### steppers

`end`는 두 버튼을 뒤쪽 가장자리에 둡니다. spinner가 늘 그래 온 모양입니다. `split`은 빼기를 앞에, 더하기를 뒤에 두고 숫자를 그 사이에 놓습니다 — 타이핑하기보다 툭툭 밀어 올리는 수량을 위한 것입니다. `none`은 버튼을 빼지만 field는 여전히 숫자 field입니다. 방향키도, 범위 고정도, 서식도 그대로입니다.

반높이 chevron을 위아래로 쌓는 형태는 일부러 없습니다. `xs`에서 화살표 하나는 3px도 되지 않고, 그만한 표적은 아무도 맞히지 못합니다.

<Demo src="number-field/steppers" :min-height="300">

::: fw react

<<< @/.vitepress/demos/number-field/steppers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/steppers.dart

:::

</Demo>

### format

::: fw react

`Intl.NumberFormat`으로 그대로 넘어갑니다. 그래서 화면에는 `$1,240.00`이나 `18.5%`가 보이고 `value`는 평범한 숫자로 남습니다. 입력된 것도 같은 locale로 되읽히는데, 그것이 쉼표가 소수점이어야 할 곳에서 소수점이 되게 하는 이유입니다.

:::

::: fw flutter

옵션 객체 하나가 아니라 함수 둘입니다. `format`은 정착한 값을 쓰고 `parse`는 입력된 글자를 되읽습니다. Dart SDK에는 `Intl.NumberFormat`이 없고 이 패키지에는 의존성이 없으니, locale을 아는 field는 앱이 자기 formatter로 만드는 것입니다 — 어차피 다른 화면들에도 필요해서 이미 갖고 있을 그것으로요.

둘 다 생략하면 `format`은 정수를 소수점 없이 쓰고, `parse`는 숫자와 부호, 소수점을 뺀 나머지를 전부 버립니다. 통화가 보이는 field에 `$1,240.50`을 그대로 칠 수 있는 것이 이 기본 짝 덕분입니다.

:::

<Demo src="number-field/format" :min-height="200">

::: fw react

<<< @/.vitepress/demos/number-field/format.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/format.dart

:::

</Demo>

### step, largeStep, smallStep

방향키와 스테퍼는 둘 다 `step`만큼 움직이고, <kbd>Shift</kbd>는 `largeStep`을, <kbd>Alt</kbd>는 `smallStep`을 씁니다 — 수정 키는 눌린 키에도, 눌린 스테퍼에도 똑같이 셉니다. `snapOnStep`은 한 걸음이 하나만큼 움직이는 대신 배수에 내려앉게 합니다.

::: fw flutter

<kbd>Page Up</kbd>과 <kbd>Page Down</kbd>도 `largeStep`을 쓰고, <kbd>Home</kbd>과 <kbd>End</kbd>는 `min`과 `max`가 있으면 그리로 갑니다. 스테퍼를 누르고 있으면 짧은 정지 뒤에 반복되고, 눌렀다 뗀 스테퍼는 정확히 한 걸음입니다. 라이브러리의 다른 모든 버튼이 그런 것처럼요.

:::

<Demo src="number-field/steps" :min-height="240">

::: fw react

<<< @/.vitepress/demos/number-field/steps.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/steps.dart

:::

</Demo>

### variant

껍데기는 `PlTextField`와 픽셀 단위로 같습니다. 수량 상자만 주변 상자들과 높이나 모서리가 다른 form은 설계된 것이 아니라 조립된 것처럼 보이는 form입니다 — 그래서 여기서도 `solid`는 색이 들어간 판이 아니라 시트에 파인 우물입니다.

<Demo src="number-field/variants" :min-height="300">

::: fw react

<<< @/.vitepress/demos/number-field/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/variants.dart

:::

</Demo>

### 상태

`readOnly`는 숫자를 읽을 수 있게 두고 스테퍼를 없앱니다. 바뀔 수 없는 값에는 누를 것이 없습니다. `error`는 field 자체를 invalid로 만들고, 그것이 색 계열 전체를 `danger`로 돌려세워 가장자리와 ring, 캐럿, 메시지가 함께 넘어가게 합니다.

<Demo src="number-field/states" :min-height="380">

::: fw react

<<< @/.vitepress/demos/number-field/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/states.dart

:::

</Demo>

### size

<Demo src="number-field/sizes" :min-height="420">

::: fw react

<<< @/.vitepress/demos/number-field/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- 어려운 부분은 Base UI의 NumberField가 가집니다. locale에 맞춰 입력을 해석하는 것, `min`/`max`로 고정하는 것, 스테퍼를 누르고 있을 때의 반복, form과 함께 제출되는 숨은 input.
- 라벨과 설명, 오류는 Base UI의 Field가 컨트롤에 연결하므로 어느 것도 호출하는 쪽의 `id`를 필요로 하지 않습니다.
- 두 스테퍼에는 이미 접근 가능한 이름이 있습니다. `incrementLabel`과 `decrementLabel`이 그것을 바꿉니다.
- 범위 끝에 닿은 스테퍼는 흐려지기만 하는 것이 아니라 진짜로 `disabled`입니다.
- `allowWheelScrub`은 기본적으로 꺼져 있습니다. 포인터 아래에서 스크롤되는 페이지와 값이 바뀌는 field는 같은 동작이고, 의도된 것은 둘 중 하나뿐입니다.

:::

::: fw flutter

- field는 보이는 것을 담은 텍스트 field로 읽힙니다. 그래서 스크린리더는 `1240`이 아니라 `$1,240.00`을 읽습니다. 그려진 것이 읽히는 것입니다.
- 두 스테퍼에는 이미 이름이 있습니다. `incrementLabel`과 `decrementLabel`이 그것을 바꿉니다. 각각은 숫자 다음의 자기 focus stop을 가집니다.
- 범위 끝에 닿은 스테퍼는 흐려지기만 하는 것이 아니라 사용할 수 없다고 읽힙니다.
- 방향키는 field **안쪽**에, 앱 자신의 텍스트 편집 단축키보다 편집기에 가까이 묶여 있습니다. 위 방향키가 캐럿이 아니라 숫자를 움직이게 하는 것이 이것입니다.
- `allowWheelScrub`은 기본적으로 꺼져 있고, 켜도 field가 focus를 가진 **동시에** 포인터가 그 위에 있어야 합니다. 포인터 아래에서 스크롤되는 페이지와 값이 바뀌는 field는 같은 동작이고, 의도된 것은 둘 중 하나뿐입니다.
- 라벨과 설명, 오류는 컴포넌트의 일부라, 연결할 `id`도 없고 연결하는 것을 잊을 일도 없습니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `value` / `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter의 컨트롤은 controlled이고, 콜백 이름도 Flutter의 것입니다. |
| `onValueCommitted` | `onCommitted` | 같은 생각, 더 짧은 이름. 범위 고정이 일어나는 자리입니다. |
| `Intl.NumberFormatOptions`인 `format` | 함수 둘인 `format`과 `parse` | Dart SDK에는 `Intl.NumberFormat`이 없고 이 패키지에는 의존성이 없습니다. 되읽지 못하는 서식은 입력할 수 없는 field이므로, 양쪽 다 호출하는 쪽의 몫입니다. |
| `locale` | — | 앱이 넘기는 formatter의 것입니다. 그 formatter는 이미 자기가 어느 locale로 쓰는지 압니다. |
| `number \| null` 값 | `double?` | Dart의 부동소수점 타입입니다. 정수 field는 `step: 1`에 소수를 쓰지 않는 `format`입니다. |
| 숨은 input, `name`, `required` | — | 함께 제출될 네이티브 form이 없습니다. |
| `id` | — | 여기서는 무엇도 id로 다른 것을 가리키지 않습니다. 라벨과 메시지는 컴포넌트의 일부입니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
