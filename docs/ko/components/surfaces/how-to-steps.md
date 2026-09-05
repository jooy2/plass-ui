---
title: PlHowToSteps
order: 12
---

# PlHowToSteps

<p class="plass-lede">번호가 붙은 지시 사항과, 각 단계 아래에 무엇을 할지가 적혀 있습니다. stepper와 timeline은 지금 어디인지를 말하고, 이것은 무엇을 할지를 말합니다. 그래서 모든 단계의 본문이 한꺼번에 열려 있습니다.</p>

<Demo src="how-to-steps/hero" :min-height="280" />

::: fw react

```tsx
import { PlHowToStep, PlHowToSteps } from 'plass-ui';

<PlHowToSteps>
  <PlHowToStep title="Add the package">npm install plass-ui</PlHowToStep>
  <PlHowToStep title="Import the stylesheet">One line in your CSS entry point.</PlHowToStep>
</PlHowToSteps>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlHowToSteps(
  steps: const <PlHowToStep>[
    PlHowToStep(title: Text('Add the package'), child: Text('flutter pub add plass_ui')),
    PlHowToStep(title: Text('Import it'), child: Text('One line at the top of the file.')),
  ],
);
```

:::

## Props

<PropsTable name="PlHowToSteps" />

### PlHowToStep

<PropsTable name="PlHowToStep" />

라이브러리 전체에서 공유 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 어디인지, 아니면 무엇을 할지

순서를 다루는 컴포넌트가 셋 있고, 차이는 그림이 아닙니다.

|  |  |
| --- | --- |
| [`PlStepper`](../navigation/stepper) | 지금 지나가고 있는 과정에서 **어디인지**. 단계가 버튼이고 그중 하나가 패널을 가집니다. |
| [`PlTimeline`](../display/timeline) | 이미 일어난 순서에서 **어디인지**. |
| `PlHowToSteps` | **무엇을 할지.** 모든 단계의 본문이 한꺼번에 열려 있습니다. |

마지막 줄에서 나머지 모양이 전부 따라 나옵니다. 지시를 따르는 사람은 앞을 미리 읽고, 한 단계 돌아가고, 자기 속도로 갑니다. 한 번에 한 단계만 보여 주는 안내는 "다음에 무엇을 요구받게 되는가"의 답을 감추는 셈입니다.

**`active`가 여기서는 선택인** 이유도 그것입니다. 사용자가 어디까지 왔는지 안다고 주장하는 안내는 추측을 하는 것입니다. 정말로 아는 경우 — 이미 대신 해 준 일을 보고하는 설정 마법사 같은 경우 — 에만 주십시오.

## numbered

기본이 켜짐입니다. 지시란 것이 그렇기 때문입니다. "이걸 하고, 그다음 이걸"은 순서이고, 번호는 한눈 팔았다 돌아온 사람이 자리를 다시 찾는 방법입니다.

**아무 순서로나** 해도 되는 일들이라면 끄십시오. 그건 how-to가 아니라 체크리스트입니다. 보통 `connector="none"`과 함께 씁니다. 단계 사이의 선은 같은 주장의 나머지 절반이기 때문입니다.

<Demo src="how-to-steps/plain" :min-height="220">

::: fw react

<<< @/.vitepress/demos/how-to-steps/plain.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/how_to_steps/plain.dart

:::

</Demo>

`icon`은 원판 안의 번호를 대신하면서 **순서에서의 자리는 그대로 둡니다**. 안내가 자식을 훑으며 번호를 매기므로 바뀌는 것은 그려지는 것뿐입니다.

## Examples

### 가운데에 끼워 넣는 단계

손으로 번호를 다시 매길 일이 없습니다. 애초에 손으로 매기지 않았기 때문입니다. 단계는 인덱스를 받지 않고, 안내가 자식을 훑으며 셉니다. 조건에 걸려 아무것도 그리지 않은 단계는 번호를 가져가지 않습니다.

```tsx
<PlHowToSteps>
  <PlHowToStep title="Install">…</PlHowToStep>
  {needsAuth ? <PlHowToStep title="Sign in">…</PlHowToStep> : null}
  <PlHowToStep title="Deploy">…</PlHowToStep>
</PlHowToSteps>
```

### 한 단계만 완료로 표시하기

단계의 `status`는 안내가 계산한 것을 덮어씁니다. "완료"가 단순히 "지금 자리보다 앞"이 아닌 안내를 위한 것입니다.

```tsx
<PlHowToStep title="Install the CLI" status="complete">
  …
</PlHowToStep>
```

## Notes

- 불릿과 후광과 연결선은 [stepper](../navigation/stepper), [timeline](../display/timeline)이 그리는 것과 같은 셋이고 표 하나에서 옵니다. 후광이 있는 불릿이 한 라이브러리 안에서 두 가지를 뜻해서는 안 됩니다.
- 연결선은 그것이 **떠나는** 단계의 것이므로, 색이 그 단계에 도달했는지를 말합니다. 마지막 단계에는 떠날 곳이 없습니다.
- 표면을 그리지 않습니다. 안내는 [`PlCard`](./card) 안이나 페이지 위에 놓입니다.

## Accessibility

::: fw react

- 진짜 `<ol>`과 `<li>`이고, 사용자가 보는 번호가 목록이 나르는 번호입니다. 스크린 리더는 "목록, 다섯 항목, 두 번째 항목"이라고 스스로 말해 줍니다. 단계마다 heading을 두어도 근사치밖에 되지 않는 위치 정보입니다.
- 현재 단계는 `aria-current="step"`을 답니다. `active`가 지정했을 때만입니다.
- 원판은 `aria-hidden`입니다. 그 안의 숫자는 목록 자신의 것이고, 단계마다 "2"를 먼저 듣는 것은 소음입니다.

:::

::: fw flutter

- **위치는 각 단계의 semantics에 직접 적힙니다.** React 쪽과 갈라지는 유일한 지점입니다. 저쪽에서는 진짜 `<ol>`이 공짜로 주는 것이고, Flutter에는 물려받을 순서 목록이 없습니다. `semanticStepLabel`이 그 문구를 정하고, 프레임워크에 `Intl`이 없으므로 문자열 쌍이 아니라 콜백입니다.

:::
