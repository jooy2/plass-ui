---
title: PlSwitch
order: 8
---

# PlSwitch

<p class="plass-lede">즉시 반영되는 켜짐/꺼짐입니다. 꺼져 있을 때 트랙은 중립 색의 홈이고, 켜지면 색 계열의 그러데이션이 됩니다.</p>

<Demo src="switch/hero" :min-height="160" />

::: fw react

```tsx
import { PlSwitch } from 'plass-ui';

<PlSwitch label="Dark mode" checked={dark} onCheckedChange={setDark} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlSwitch(
  value: dark,
  onChanged: (bool next) => setState(() => dark = next),
  label: const Text('Dark mode'),
);
```

:::

## Props

<PropsTable name="PlSwitch" />

::: fw react

Base UI `Switch.Root`의 나머지 prop은 그대로 전달됩니다. `className`과 `style`은 트랙이 아니라 field wrapper에 붙고, `render`는 제공하지 않습니다.

:::

::: fw flutter

switch는 패키지의 다른 모든 컨트롤과 마찬가지로 **controlled**입니다. `value`를 받고 값이 무엇이 되어야 하는지를 보고합니다. `onChanged: null`은 비활성화합니다.

:::

`variant`는 없습니다. `PlCheckbox`에 없는 이유와 같습니다 — 켜짐과 꺼짐은 같은 재질의 두 세기가 아닙니다.

라이브러리 전체에서 공유 축(`size` `color`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Switch인가 checkbox인가

차이는 생김새가 아니라 **시간**에 있습니다. checkbox는 form과 함께 제출되는 값이고, switch는 움직이는 순간 적용됩니다. 아래에 Save 버튼이 있다면 그것은 checkbox였어야 합니다.

## Examples

### color

켜지면 트랙이 색 계열의 그러데이션이 되고, 그 아래에 같은 계열의 틴트 그림자가 깔립니다. 꺼지면 **홈**이 됩니다 — `PlSlider`의 레일과 같은 중립 잉크이므로, 설정 패널에 놓인 두 컨트롤이 눈에 보이게 같은 재료로 만들어집니다.

thumb은 두 상태, 두 테마 모두에서 흰색입니다. thumb은 트랙 위의 빛이지 두 번째 색 있는 물체가 아니고, 색 있는 트랙 위의 색 있는 thumb은 16픽셀을 두고 다투는 두 가지입니다.

꺼진 트랙에는 inset 그림자도, 둘레의 헤어라인도 없습니다. 가장 불투명한 유리로 그린 꺼짐 상태는 흰 알약 안에 흰 thumb이 든 모양이고, 밝은 페이지에서는 이미 눌러 보기 전에는 찾을 수 없는 switch입니다. 그리고 그것이 _보이던_ 어두운 쪽에서는, 볼록한 thumb 아래 파인 자리가 이 디자인 언어가 그리지 않으려고 존재하는 바로 그 옛날식 로커 스위치였습니다.

<Demo src="switch/colors" :min-height="120">

::: fw react

<<< @/.vitepress/demos/switch/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/switch/colors.dart

:::

</Demo>

### size

thumb은 사방으로 2px 안쪽에 들어가 있습니다. 그래서 지름이 언제나 트랙 높이 빼기 4이고, 둘이 어긋날 일이 없습니다.

<Demo src="switch/sizes" :min-height="220">

::: fw react

<<< @/.vitepress/demos/switch/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/switch/sizes.dart

:::

</Demo>

### labelPlacement

기본값인 <Fw react="end" flutter="PlassAlign.end" code />는 컨트롤에 붙은 설명처럼 읽힙니다. <Fw react="start" flutter="PlassAlign.start" code />는 설정 목록용입니다 — 라벨이 한 열을 이루고 모든 스위치가 행의 끝 쪽에 정렬됩니다.

<Demo src="switch/placement" :min-height="220">

::: fw react

<<< @/.vitepress/demos/switch/placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/switch/placement.dart

:::

</Demo>

### readOnly · disabled

<Demo src="switch/states" :min-height="220">

::: fw react

<<< @/.vitepress/demos/switch/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/switch/states.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI가 `aria-checked`를 가진 `role="switch"` 컨트롤을 렌더링하고, `name`을 주면 네이티브 form 제출에 포함되는 hidden input도 함께 렌더링합니다.
- `label`, `description`, `error`는 Base UI의 Field가 컨트롤에 엮어 주므로, 라벨을 누르면 스위치가 전환됩니다.
- <kbd>Space</kbd>와 <kbd>Enter</kbd> 둘 다 전환합니다. focus ring은 `:focus-visible`에서만 나타납니다.
- thumb의 위치만이 신호는 아닙니다. 트랙의 재질도 함께 바뀌므로, 36px 알약의 양 끝을 구분하기 어려운 사람에게도 상태가 전달됩니다.
- thumb은 라이브러리에서 움직이는 유일한 것이고, 글자를 담고 있지 않습니다 — no-transform 규칙은 손가락 아래에서 컨트롤이 자기 라벨을 다시 샘플링하는 것에 대한 것이고, thumb은 그럴 수가 없습니다. 다른 모든 것이 변하는 것과 같은 150ms 동안 이동합니다.
- `label`이 없는 switch에는 `aria-label`이 필요합니다.

:::

::: fw flutter

- 트랙과 라벨, 설명은 **하나의** semantics 노드이고, 켜짐/꺼짐으로 알려집니다.
- 라벨을 누르면 전환됩니다. 대상은 행 전체입니다.
- <kbd>Enter</kbd>, <kbd>Space</kbd>, 넘패드 <kbd>Enter</kbd>가 전환합니다. focus ring은 CSS가 `:focus-visible`이라고 부르는 것에서만 나타납니다.
- thumb의 위치만이 신호는 아닙니다. 트랙의 재질도 함께 바뀌므로, 36px 알약의 양 끝을 구분하기 어려운 사람에게도 상태가 전달됩니다.
- thumb은 라이브러리에서 움직이는 유일한 것이고, 글자를 담고 있지 않습니다. 다른 모든 것이 변하는 것과 같은 150ms 동안 이동합니다.
- `label`이 없는 switch에는 `semanticLabel`이 필요합니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `checked` / `onCheckedChange` | `value` / `onChanged` | Flutter의 이름이고, `onChanged: null`은 다른 모든 곳과 마찬가지로 비활성화합니다. |
| `name`과 hidden input | — | 포함될 네이티브 form 제출이 없습니다. |
| `labelPlacement="start"` | `labelPlacement: PlassAlign.start` | 공유 어휘에서 온 같은 값입니다. `PlassAlign.center`는 단언으로 막습니다 — switch의 라벨은 행의 한쪽 끝이나 다른 쪽 끝에 놓입니다. |
| `aria-label` | `semanticLabel` | Flutter의 이름입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
