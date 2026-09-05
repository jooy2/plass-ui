---
title: PlMeter
order: 12
---

# PlMeter

<p class="plass-lede">범위 안의 양을 막대로 그립니다. progress bar처럼 보이지만 아닙니다. progress는 진행 중인 것이고, meter는 이미 알고 있는 것입니다.</p>

<Demo src="meter/hero" :min-height="220" />

::: fw react

```tsx
import { PlMeter } from 'plass-ui';

<PlMeter
  value={82}
  label="Disk used"
  showValue
  thresholds={[
    { from: 75, color: 'warning' },
    { from: 90, color: 'danger' }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlMeter(
  value: 82,
  label: const Text('Disk used'),
  showValue: true,
  thresholds: const <PlMeterThreshold>[
    PlMeterThreshold(from: 75, color: PlassColor.warning),
    PlMeterThreshold(from: 90, color: PlassColor.danger),
  ],
);
```

:::

## Props

<PropsTable name="PlMeter" />

### PlMeterThreshold

<PropsTable name="PlMeterThreshold" />

네이티브 `<div>` 속성은 그대로 통과합니다. 라이브러리 전체에서 공유 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## meter와 progress bar

둘은 같은 홈과 같은 그라디언트로 그려지지만 다른 말을 합니다.

|  |  |
| --- | --- |
| [`PlProgressLinear`](./progress-linear) | 무언가가 **진행 중**입니다. 업로드, 설치, 네 단계 중 세 번째. 얼마나 남았는지 늘 알 수는 없으므로 미확정 상태가 있습니다. |
| `PlMeter` | 무언가가 **이미 알려져** 있습니다. 쓴 디스크, 찬 좌석, 비밀번호 강도, 배터리 잔량. 저절로 움직이지 않습니다. |

이 차이가 API로 이어집니다. 여기서는 `value`가 **필수**이고 sweep도 없습니다. 보고할 것이 없는 막대는 meter가 아니라 아직 그리지 말았어야 할 막대이기 때문입니다.

::: fw react

시맨틱으로도 이어집니다. role이 `progressbar`가 아니라 `meter`입니다. 스크린 리더는 둘을 다르게 읽고, 가만히 있는 수치를 진행 중이라고 말하는 것은 끝나지 않을 무언가를 기다리라고 말하는 것입니다.

그 전부는 Base UI의 `Meter`가 가집니다. role, 범위 속성, `aria-valuetext`, 서식, 채움 너비까지 — `Progress`가 progress bar에서 가지는 것과 같습니다. 여기 남는 것은 재질입니다.

:::

::: fw flutter

시맨틱은 두 빌드가 실제로 갈라지는 지점입니다. `SemanticsRole`에는 `meter`가 없고, `progressBar`를 주장하는 것은 이 위젯이 아니라고 말하려는 바로 그것을 알리는 일입니다. 그래서 Flutter 쪽은 role 없이 **이름과 값을 가진 노드**를 보고합니다. 실제로 두 경우 모두 플랫폼이 읽어 주는 것이 그것이고, 포기하는 것은 role 이름 자체뿐입니다.

:::

## thresholds

이 컴포넌트가 존재하는 이유인 prop입니다. 4분의 3에서 호박색으로, 90퍼센트에서 붉은색으로 바뀌는 할당량 막대는 고정된 색이 하지 못하는 말을 합니다. 색을 호출자가 바라보던 순간에 고르는 것이 아니라 값에서 끌어냅니다.

<Demo src="meter/thresholds" :min-height="240">

::: fw react

<<< @/.vitepress/demos/meter/thresholds.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/meter/thresholds.dart

:::

</Demo>

규칙은 셋이고, 어느 것에도 순서가 들어 있지 않습니다.

- 값보다 작거나 같은 `from` 중 **가장 큰 것**이 이깁니다. 목록은 훑는 것이 아니라 읽으므로, 어떤 순서로 적어도 답이 같습니다.
- `from`은 백분율이 아니라 meter 자신의 **단위**입니다. 범위가 마침 백분율일 때만 같습니다. `min`…`max` 밖의 구간은 그냥 도달하지 않습니다.
- `color`는 모든 구간 아래에서 막대가 무엇으로 만들어지는지입니다.

**`showValue`를 함께 켜십시오.** 구간은 얼마나 찼는지를 말하는 두 번째 방법이지 유일한 방법이 되어서는 안 됩니다. 호박색과 붉은색을 구별하지 못하는 사람에게는 숫자 없는 막대만 남습니다.

## Examples

### 백분율이 아닌 범위

`min`과 `max`는 수치가 실제로 놓인 단위이고, `format`이 그 단위로 써 줍니다. `format`이 없으면 값은 범위의 백분율로 읽히는데, 아무도 설명하지 않은 범위에 대해 성립하는 유일한 서식이 그것입니다.

::: fw react

```tsx
<PlMeter
  value={18}
  max={100}
  label="Documents"
  showValue
  format={{ style: 'unit', unit: 'gigabyte' }}
/>
```

:::

::: fw flutter

`formatValue`는 옵션 객체가 아니라 콜백이고, 의도한 것입니다. 프레임워크에 `Intl.NumberFormat`이 없고, 그것을 주려고 `package:intl`을 끌어오는 패키지는 소비자를 대신해 의존성을 결정하는 셈이기 때문입니다. 앱에서 이미 숫자를 서식화하는 무언가가 이것도 서식화합니다.

```dart
PlMeter(
  value: 18,
  label: const Text('Documents'),
  showValue: true,
  formatValue: (double value) => '${value.toStringAsFixed(0)} of 100 GB',
);
```

:::

### 비밀번호 강도

백 단계가 아니라 네 단계입니다. `min`과 `max`가 그것을 위한 것입니다.

```tsx
<PlMeter
  value={score}
  min={0}
  max={4}
  label="Password strength"
  thresholds={[
    { from: 2, color: 'warning' },
    { from: 3, color: 'success' }
  ]}
  color="danger"
/>
```

## Notes

- 범위 밖의 값은 **잘라 냅니다**. 두 쪽이 함께 잘립니다. 막대는 범위의 끝에 그려지고 알리는 값도 잘라 낸 값이라, 읽히는 숫자와 화면이 어긋나지 않습니다. `value`는 보통 어딘가의 나눗셈에서 오고, 한 숫자를 두 번 세는 바람에 140% 너비로 그려진 막대는 가득 찬 채 서 있는 막대보다 나쁜 버그입니다.
- 빈 범위(`max`가 `min` 이하)에서는 막대가 비어 있습니다. 상태가 아니라 호출자의 실수이고, 여기서 가득 찬 막대를 그리는 것은 주장이 됩니다.
- 홈은 `--plass-track`으로, slider의 레일과 switch의 꺼진 상태를 새긴 것과 같은 중립 잉크입니다. 채움은 색 계열의 그라디언트입니다. 움직이는 것은 **너비**인데, 그라디언트는 전환할 수 없고 길이는 할 수 있기 때문입니다.
- `variant`도 `density`도 `elevation`도 없습니다. meter는 한 가지 재질이고, 넣을 여백이 없으며, 홈이 그렇듯 놓인 표면 _안으로_ 파여 있습니다.

## Accessibility

- 값은 맨 숫자가 아니라 **텍스트**로 알립니다. React에서는 `aria-valuetext`, Flutter에서는 노드의 값입니다. 0–100이 아닌 범위에서 "3"은 플랫폼이 잘못 짐작할 백분율입니다.
- `label`이 meter의 이름이고, 눈으로 보는 사람이 읽는 것과 같은 문자열입니다. 이름이 없으면 아무것에도 붙지 않은 숫자가 됩니다.
- `showValue`를 켜면 수치가 그려지는 **동시에** 노드에 실립니다. 그려진 쪽은 접근성 트리에서 감추므로 두 번이 아니라 한 번 읽힙니다.
- 색이 구간을 나르는 유일한 수단이 되는 일은 없습니다. `thresholds`는 `showValue`와 함께 쓰십시오.
