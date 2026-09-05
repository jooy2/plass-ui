---
title: PlProgressLinear
order: 9
---

# PlProgressLinear

<p class="plass-lede">차오르는 바입니다. 얼마나 남았는지를 한눈에 보여 줄 수 있는 유일한 indicator인데, 길이는 세지 않고도 비교할 수 있는 유일한 양이기 때문입니다.</p>

<Demo src="progress-linear/hero" :min-height="140" />

::: fw react

```tsx
import { PlProgressLinear } from 'plass-ui';

<PlProgressLinear label="Uploading" value={62} showValue />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlProgressLinear(label: const Text('Uploading'), value: 62, showValue: true);
```

:::

## Props

<PropsTable name="PlProgressLinear" />

::: fw react

나머지 `<div>` 속성은 그대로 통과합니다. `color`는 위 표의 `color`와 겹쳐서, `children`은 바가 아무것도 담지 않아서 제외했습니다.

:::

::: fw flutter

React가 옵션 객체를 받는 자리에서 `formatValue`는 함수를 받습니다. 넘어오지 못한 유일한 prop인데, 프레임워크에 옵션을 건넬 `Intl.NumberFormat`이 없고, 그것 하나 때문에 `package:intl`을 끌어오는 건 소비자 대신 의존성을 정하는 일이기 때문입니다. 앱에서 이미 숫자를 포매팅하는 무엇이든 이 숫자도 포매팅할 수 있습니다.

:::

`variant`도 `density`도 `elevation`도 없습니다. indicator는 재질이 하나뿐이고, 패딩을 줄 내용물이 없으며, 홈이 그렇듯 놓인 표면 **안으로** 파여 있습니다 — 그리고 홈은 뜨지 않습니다.

공유 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 구성

홈은 `--plass-track`입니다. [`PlSlider`](../inputs/slider)의 레일과 [`PlSwitch`](../inputs/switch)의 꺼진 트랙을 파낸 그 중립 잉크와 같은 것이라, slider와 switch와 progress bar가 한 폼에 있어도 재질이 셋이 아니라 하나입니다.

그 위를 덮는 조각은 색 계열의 그러데이션입니다. 즉 채워진 구간은 그 폼을 제출하는 버튼과 정확히 같은 재질입니다. 움직임이 `width`에 걸린 이유도 여기 있습니다 — 그러데이션은 transition할 수 없지만 길이는 할 수 있습니다.

홈과 조각 둘 다 완전히 둥근데, 알약을 금지하는 하우스 규칙이 적용되지 않는 유일한 자리입니다. 그 규칙은 글줄이 앉는 컨트롤 가장자리의 평평한 구간을 지키기 위한 것이고, 높이 6px에는 지킬 평평한 구간이 남아 있지 않습니다. 끝이 각진 바는 잘린 모서리가 아니라 렌더링 오류로 읽힙니다.

## Examples

### value

기본값인 `null`은 indeterminate입니다 — 뭔가 진행 중이고 얼마나 남았는지는 아무도 모르는 상태. 값이 없는 바는 비어 있는 대신 **훑고 지나갑니다.** 빈 바는 진행이 하나도 없었다는 주장이기 때문입니다.

`min`…`max` 밖의 값은 그리지 않고 잘라 냅니다. `value`는 대개 어딘가의 나눗셈에서 오고, 요청 하나가 두 번 끝났다고 140% 너비로 그려지는 바는 가득 찬 채 멈춘 바보다 나쁜 버그입니다.

<Demo src="progress-linear/indeterminate" :min-height="140">

::: fw react

<<< @/.vitepress/demos/progress-linear/indeterminate.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_linear/indeterminate.dart

:::

</Demo>

### size

두께만 바뀝니다. 바는 라벨을 안에 넣을 수 있는 컨트롤이 아니고, `md`에서는 버튼의 1/4이 아니라 두 문단 사이 괘선 정도의 무게이길 바랍니다. 그래서 이 값들은 `PlSlider`의 레일 두께 그대로입니다 — 레일과 바는 같은 채널이고, 하나는 끌고 하나는 지켜볼 뿐입니다.

<Demo src="progress-linear/sizes" :min-height="240">

::: fw react

<<< @/.vitepress/demos/progress-linear/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_linear/sizes.dart

:::

</Demo>

### color

<Demo src="progress-linear/colors" :min-height="280">

::: fw react

<<< @/.vitepress/demos/progress-linear/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_linear/colors.dart

:::

</Demo>

### showValue와 format

`format`이 없으면 값은 `min`…`max`에 대한 백분율로 쓰입니다. 아무도 설명하지 않은 범위에 대해 성립하는 유일한 형식이기 때문입니다 — 4단계 중 3단계를 "3%"라고 말하는 건 아무 말도 안 하느니만 못합니다.

`format`을 주면 숫자는 그대로 `Intl.NumberFormat`으로 갑니다. 바이트도 통화도 단위도 되고, 값은 호출자가 부여한 의미를 그대로 지킵니다.

<Demo src="progress-linear/format" :min-height="160">

::: fw react

<<< @/.vitepress/demos/progress-linear/format.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_linear/format.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI가 `role="progressbar"`를 렌더링하고 `aria-valuenow` `aria-valuemin` `aria-valuemax`를 prop과 맞춰 둡니다.
- indeterminate인 바는 0이 아니라 **값 자체를 보고하지 않습니다.** 그래야 스크린리더가 진행도를 알 수 없다고 읽어 줍니다.
- `aria-valuetext`는 `showValue`가 그리는 문자열과 같습니다. 들리는 것과 읽히는 것이 한 문장입니다. `format`이 없으면 그건 100에 대한 게 아니라 범위에 대한 백분율입니다.
- `label`은 무엇이 진행 중인지를 말합니다. 라벨 없는 바는 스크린리더가 숫자로밖에 설명할 수 없는 바입니다.
- `prefers-reduced-motion`에서는 조각이 이동을 멈추고 홈을 채운 채 숨을 쉽니다. 멈추지는 않습니다 — 가만히 있는 indeterminate indicator는 자기 존재 이유와 정반대를 말합니다.

:::

::: fw flutter

- 바는 `SemanticsRole.progressBar`와 값을 지닌 하나의 병합된 semantics 노드입니다. 라벨과 바가 함께 읽히지, 이름 없는 indicator 옆에 이름만 떠 있지 않습니다.
- 값이 없으면 role은 `SemanticsRole.loadingSpinner`이고 값 자체가 없습니다 — 그래야 플랫폼이 0이 아니라 "진행도를 알 수 없음"으로 읽어 줍니다.
- 그려진 백분율은 `ExcludeSemantics` 뒤에 있습니다. 같은 문자열이 이미 노드의 값이고, 한 번만 들려야 합니다.
- `MediaQuery.disableAnimations`에서는 조각이 이동을 멈추고 홈을 채운 채 숨을 쉽니다 — 같은 대역, 같은 축입니다.

:::

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `format: Intl.NumberFormatOptions` | `formatValue: String Function(double)` | 프레임워크에 `Intl.NumberFormat`이 없고, 그것을 위해 `package:intl`을 끌어오는 건 소비자 대신 의존성을 정하는 일입니다. |
| `label: ReactNode`, `min`/`max`/`value`가 `number` | `Widget?`와 `double` | 같은 것을 Dart가 부르는 이름입니다. |
| 조각이 `inset-inline-start`로 이동 | 방향성 `Alignment`로 이동 | 둘 다 transform이 아니고, 둘 다 RTL에서 알아서 반대로 흐릅니다. |
| `className`, `style`, 네이티브 속성 | — | 통과시킬 class 목록도 style 속성도 없습니다. |
