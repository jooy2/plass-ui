---
title: PlProgressCircular
order: 10
---

# PlProgressCircular

<p class="plass-lede">차오르는 링입니다. 바를 놓을 자리가 없는 곳(테이블 행 안, 필드 옆, 글줄 끝)에 쓰는 모양입니다.</p>

<Demo src="progress-circular/hero" :min-height="140" />

::: fw react

```tsx
import { PlProgressCircular } from 'plass-ui';

<PlProgressCircular label="Syncing" value={68} showValue />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlProgressCircular(label: const Text('Syncing'), value: 68, showValue: true);
```

:::

## Props

<PropsTable name="PlProgressCircular" />

표는 [`PlProgressLinear`](./progress-linear)의 것 그대로이고, 뜻이 달라지는 것은 `size` 하나뿐입니다. 바에서는 두께, 링에서는 지름입니다. indicator들이 하는 주장이 바로 이것(하나의 컴포넌트, 세 개의 모양)이고, 그래서 각자 어긋날 표 셋 대신 표 하나를 나눠 씁니다.

::: fw react

나머지 `<div>` 속성은 그대로 통과합니다. `color`는 위 표의 `color`와 겹쳐서, `children`은 링이 아무것도 담지 않아서 제외했습니다.

:::

::: fw flutter

React가 옵션 객체를 받는 자리에서 `formatValue`는 함수를 받습니다. 이유는 [`PlProgressLinear`](./progress-linear)에 있습니다.

:::

## arc

::: fw react

SVG stroke에는 CSS 그러데이션을 줄 수 없어서, 링은 바의 fill을 이루는 바로 그 두 stop으로 같은 135°의 `<linearGradient>`를 스스로 만듭니다.

:::

::: fw flutter

stroke는 decoration이 아니라 `Shader`를 받으므로, 패키지의 나머지가 `PlassCssGradient`에서 얻는 그 sweep을 여기서는 직접 요청합니다. 라이브러리에서 shader를 손으로 만드는 유일한 자리입니다.

:::

어느 쪽이든 그만한 값어치가 있습니다. 훑고 지나가는 바 옆의 납작한 링은 하나의 아이디어에 재질이 둘인 것이기 때문입니다.

그 아래 트랙은 `--plass-track`, 바의 홈과 같은 중립 잉크입니다. 한 화면의 링과 바가 같은 표면에 파여 있게 됩니다.

## 값 라벨

안이 아닙니다. 다이얼 한가운데의 숫자는 누구나 이 컴포넌트 하면 떠올리는 그림이지만, 다섯 단계 중 둘에서만 통합니다. `xs`에서 링은 지름 14px이고 "40%"가 들어갈 자리가 없습니다. 옆에 두면 모든 단계에서 읽힙니다.

## Examples

### value

기본값인 `null`은 indeterminate입니다. 그러면 링은 고정된 1/4 호를 그린 채 회전하는데, 라이브러리가 스스로 무언가를 움직이는 유일한 자리이고, 그 예외는 버튼의 스피너가 이미 갖고 있는 것과 같습니다. 가만히 있는 indeterminate indicator는 장식입니다.

값이 있으면 링은 멈춰 서고 대신 틈이 닫힙니다. 둘 다 하나의 원 위 하나의 dash 패턴입니다.

<Demo src="progress-circular/indeterminate" :min-height="140">

::: fw react

<<< @/.vitepress/demos/progress-circular/indeterminate.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_circular/indeterminate.dart

:::

</Demo>

### size

지름이고, 모든 단계에서 컨트롤 사다리 바로 아래에 앉는 사다리입니다(`md` 링은 40px 컨트롤 안의 20px). 그래서 버튼이나 필드나 테이블 행에 링을 떨어뜨려도 행이 원래보다 높아지지 않습니다.

<Demo src="progress-circular/sizes" :min-height="140">

::: fw react

<<< @/.vitepress/demos/progress-circular/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_circular/sizes.dart

:::

</Demo>

### color

<Demo src="progress-circular/colors" :min-height="160">

::: fw react

<<< @/.vitepress/demos/progress-circular/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_circular/colors.dart

:::

</Demo>

### 행 안에서

크기 사다리가 있는 이유가 이것입니다. 테이블 셀 안의 `xs` 링은 14px이고, 행은 원래 되려던 높이 그대로입니다.

<Demo src="progress-circular/inline" :min-height="220">

::: fw react

<<< @/.vitepress/demos/progress-circular/inline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_circular/inline.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI가 `role="progressbar"`를 렌더링하고 `aria-valuenow` `aria-valuemin` `aria-valuemax`를 prop과 맞춰 둡니다.
- indeterminate인 링은 0이 아니라 **값 자체를 보고하지 않습니다.** 그래야 스크린리더가 진행도를 알 수 없다고 읽어 줍니다.
- `<svg>`는 `aria-hidden`입니다. 그건 그림이고, 그것이 말하는 것은 이미 role과 값에 다 들어 있습니다.
- `aria-valuetext`는 `showValue`가 그리는 문자열과 같습니다. `format`이 없으면 100이 아니라 범위에 대한 백분율입니다.
- `prefers-reduced-motion`에서는 링을 멈추는 대신 움직임으로 읽히지 않을 만큼 느리게 합니다. 애초에 도는 이유와 같은 이유입니다.

:::

::: fw flutter

- 링은 `SemanticsRole.progressBar`와 값을 지닌 하나의 병합된 semantics 노드입니다. 라벨과 링이 함께 읽힙니다.
- 값이 없으면 role은 `SemanticsRole.loadingSpinner`이고 값 자체가 없습니다. 그래야 플랫폼이 진행도를 알 수 없다고 읽어 줍니다.
- 그려진 백분율은 `ExcludeSemantics` 뒤에 있습니다. 같은 문자열이 이미 노드의 값입니다.
- `MediaQuery.disableAnimations`에서는 링을 멈추는 대신 느리게 합니다.

:::

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `format: Intl.NumberFormatOptions` | `formatValue: String Function(double)` | 프레임워크에 `Intl.NumberFormat`이 없고, 그것을 위해 `package:intl`을 끌어오는 것은 소비자 대신 의존성을 정하는 일입니다. |
| `<linearGradient>`가 붙은 `<svg>` | `ui.Gradient` shader를 쓰는 `CustomPainter` | 같은 두 stop, 같은 135°. stroke는 decoration이 아니라 shader를 받습니다. |
| `className`, `style`, 네이티브 속성 | — | 통과시킬 class 목록도 style 속성도 없습니다. |
