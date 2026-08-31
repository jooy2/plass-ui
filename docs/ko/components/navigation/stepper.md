---
title: PlStepper
order: 7
---

# PlStepper

<p class="plass-lede">사용자가 지나가고 있는 절차, 그리고 그 안에서 지금 어디인지. 각 step은 버튼이고, 현재 step이 패널을 갖고, 누르면 사용자가 옮겨 갑니다.</p>

<Demo src="stepper/hero" :min-height="320" />

::: fw react

```tsx
import { PlStep, PlStepper } from 'plass-ui';

<PlStepper active={step} onActiveChange={setStep}>
  <PlStep label="Account">…</PlStep>
  <PlStep label="Verify">…</PlStep>
  <PlStep label="Profile" optional>
    …
  </PlStep>
</PlStepper>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlStepper(
  active: step,
  onActiveChanged: (int next) => setState(() => step = next),
  steps: const <PlStep>[
    PlStep(label: Text('Account'), child: Text('…')),
    PlStep(label: Text('Verify'), child: Text('…')),
    PlStep(label: Text('Profile'), optional: Text('Optional'), child: Text('…')),
  ],
);
```

:::

## Props

<PropsTable name="PlStepper" />

### PlStep

<PropsTable name="PlStep" />

네이티브 `<div>` 속성은 stepper로, `<li>` 속성은 step으로 그대로 통과합니다. 공유 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

::: fw flutter

step은 children이 아니라 **리스트**입니다. `PlTimeline`의 것이 그런 이유와 같습니다 — stepper가 그것들에 대해 *추론*해야 하고(어느 것이 complete인지는 인덱스 산수이고, 어느 것에 닿을 수 있는지도 같은 인덱스 산수입니다), 두 질문 모두 불투명한 `Widget`에게는 물을 수 없습니다. React 빌드가 경고해야 하는 날카로운 모서리도 그것으로 사라집니다 — step 셋을 품은 wrapper를 건넬 방법이 아예 없습니다.

`optional`은 `bool`이 아니라 `Widget`을 받습니다. 물러설 기본 문자열이 없기 때문입니다 — 패키지는 번역을 싣지 않고, 지어낸 단어는 어느 한 언어의 것입니다.

:::

## stepper인가 timeline인가

둘은 **같은 레일**을 그립니다 — 같은 세 가지 bullet 상태, 같은 connector — 그리고 소스에서도 그것을 공유합니다. 후광이 진 bullet이 두 가지를 뜻해서는 안 되기 때문입니다. 차이는 각각이 무엇을 _위한_ 것이냐입니다.

|  |  |
| --- | --- |
| [`PlTimeline`](../display/timeline) | **보고합니다.** 이미 일어난 시퀀스를 텍스트로. 아무것도 누를 수 없습니다 |
| `PlStepper` | 시퀀스 **그 자체**입니다. step이 버튼이고, 현재 step이 패널을 갖고, 사용자가 그 안에 있습니다 |

아무것도 클릭할 수 없어야 한다면 그것은 timeline입니다.

## Examples

### active

timeline의 것과 똑같이 값이 아니라 **인덱스**입니다 — stepper에는 선택이 없습니다. 그 앞은 전부 complete, 그 자리가 current, 그 뒤는 전부 upcoming입니다.

`defaultActive`로 제어하지 않거나, `active`와 `onActiveChange`로 제어합니다. 폼 마법사가 원하는 것이 후자입니다. Next 버튼은 호출자의 것이고, 그것이 움직일지 정하는 유효성 검사도 마찬가지입니다.

### linear

기본이 켜짐이고, 이것이 이 컴포넌트를 탭 한 줄이 아니라 절차로 만듭니다. 가입 세 번째 단계를 두 번째보다 먼저 채울 수는 없습니다. 사용자 **뒤에** 있는 step은 언제나 닿을 수 있습니다 — 답을 고치러 돌아갈 수 있다는 것이 stepper가 문이 하나뿐인 마법사가 아닌 이유 전부입니다.

모든 step이 이미 답해졌고 사용자가 하나를 확인하러 돌아가는 검토 화면에서는 끄세요.

```tsx
<PlStepper active={3} linear={false}>
  …
</PlStepper>
```

### orientation

가로는 패널을 레일 전체 아래에 놓습니다. **세로는 각 step의 패널을 그 step 안에 놓습니다.** 애초에 세로로 두는 이유가 그것입니다 — 답이 레일 아래가 아니라 질문 아래에 놓입니다.

<Demo src="stepper/vertical" :min-height="340">

::: fw react

<<< @/.vitepress/demos/stepper/vertical.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/stepper/vertical.dart

:::

</Demo>

### status와 color

세 상태 전부를 `active`가 정하고, `status`가 그중 하나를 덮어씁니다. 사용자가 세 단계 더 간 사이에 유효성 검사에 걸린 step을 위한 것입니다 — stepper를 움직이지 않고 그 step만 다시 `current`가 되고, `color="danger"`가 이유를 말합니다.

<Demo src="stepper/status" :min-height="160">

::: fw react

<<< @/.vitepress/demos/stepper/status.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/stepper/status.dart

:::

</Demo>

### optional

`true`는 "Optional"이라는 단어를 그립니다. node를 주면 그 node를 대신 그리고, 그것이 이 단어를 번역하는 방법입니다 — `optionalLabel` prop이 없는 이유는, 둘 다 받는 prop 하나면 prop이 하나이기 때문입니다.

```tsx
<PlStep label="Profile" optional="건너뛸 수 있음" />
```

## Notes

::: fw react

> **step은 stepper의 직계 자식이어야 합니다.** stepper는 자식을 걸어가며 번호를 매기므로, step 세 개를 돌려주는 여러분의 컴포넌트는 셋을 품은 자식 **하나**이고 그 안의 모든 step이 1번이 됩니다. 감싸는 컴포넌트 대신 `.map()`이나 배열로 목록을 만드세요 — 둘 다 평탄화됩니다.

- 아무것도 렌더링하지 않은 조건부 step은 뒤 step들의 번호를 밀지 않습니다.
- stepper 밖의 step도 렌더링됩니다. 앞뒤에 아무것도 없는 step 하나입니다.

:::

::: fw flutter

step이 리스트이므로 잘못 감쌀 wrapper 자체가 없습니다 — props 표 위의 설명을 보세요.

:::

## Accessibility

- 진짜 `<ol>`과 `<li>`이고, 현재 step이 `aria-current="step"`을 답니다.
- 일부러 `role="tablist"`가 **아닙니다.** tab list는 키보드 사용자에게 tab stop 하나와 화살표 키를, 스크린 리더에게 탭마다 패널 하나를 빚집니다. stepper는 서로 다른 컨트롤의 시퀀스이고, 동작 없이 role만 주장하는 것은 아예 주장하지 않는 것보다 나쁩니다. 닿을 수 있는 각 step이 각자의 tab stop이며, 그것이 stepper의 step이 하는 일입니다.
- 닿을 수 없는 step은 disabled 버튼이 아니라 아예 버튼이 아닙니다 — 아직 누를 것이 거기 없습니다.
- 패널은 그것이 속한 step으로 이름 붙습니다. 그래서 패널에 도착한 스크린 리더가 어느 step의 패널인지 듣습니다.

::: fw flutter

현재 step은 `selected`로 표시합니다. 프레임워크가 가진 것 중 `aria-current="step"`에 가장 가까운 것입니다. 닿을 수 없는 step은 disabled 버튼이 아니라 그냥 상자입니다.

:::
