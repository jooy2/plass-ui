---
title: PlAnimateLighting
order: 6
---

# PlAnimateLighting

<p class="plass-lede">무언가의 바깥을 도는 빛입니다. 무엇을 움직여서가 아니라 빛으로 시선을 끕니다. 이 라이브러리가 "여기"라고 말하면서 "그리고 움직였다"고 말하지 않는 유일한 방법입니다.</p>

<Demo src="animate-lighting/hero" :min-height="260" />

::: fw react

```tsx
import { PlAnimateLighting } from 'plass-ui';

<PlAnimateLighting size="lg" color="primary">
  <PlCard size="lg" title="Recommended">
    …
  </PlCard>
</PlAnimateLighting>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateLighting(
  size: PlassSize.lg,
  child: PlCard(size: PlassSize.lg, title: Text('Recommended'), child: Text('…')),
);
```

```

:::

## Props

<PropsTable name="PlAnimateLighting" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과합니다. `color`는 여기서 Plass prop이라 통과에서 제외되고, `render`로 요소 자체를 바꿀 수 있습니다.

:::

::: fw flutter

`glow`는 CSS 색 문자열이 아니라 `Color?`입니다. `spread`와 `blur`는 논리 픽셀 단위의 `double`이고, `arc`는 도 단위입니다.

:::

**`size`는 안에 있는 것의 radius와 맞아야 합니다.** 빛은 wrapper 자신의 모서리를 따라가므로, `xs` Lighting 안의 `lg` 카드는 카드가 이미 둥글게 깎아 낸 네 모서리에서 빛이 삐져나옵니다.

빛은 내용 위가 아니라 **뒤에**, 자기만의 stacking context 안에 있습니다. 그래서 안에 있는 것은 바뀌지도 덮이지도 않고, 내용은 그대로 읽힙니다.

공유되는 열 가지 설정 — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — 은 모든 `PlAnimate*` 컴포넌트에서 같습니다. 다만 `repeat`의 기본값이 여기서는 `'infinite'`입니다.

## Examples

### color

호는 지나가면서 **계열의 두 끝 사이를 돕니다**. 라이브러리의 모든 채워진 표면이 따르는 규칙 그대로입니다. 평평한 색의 호는 페인트일 텐데, 여기에 페인트는 없습니다. 의미론적 계열이 원하는 바가 아니라면 `glow`가 CSS 색 하나를 받고, 그때는 호가 돌아갈 곳이 없습니다.

<Demo src="animate-lighting/colors" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-lighting/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_lighting/colors.dart

:::

</Demo>

### arc, blur and spread

윤곽선 중 한 번에 얼마나 밝아지는지, 빛이 얼마나 부드러운지, 내용 바깥으로 얼마나 뻗는지입니다. 작은 호는 모서리를 달리는 불꽃이고, 큰 호는 훑고 지나가는 빛입니다. `blur={0}`에서는 빛이기를 그만두고 도형이 됩니다.

<Demo src="animate-lighting/shape" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-lighting/shape.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_lighting/shape.dart

:::

</Demo>

## Accessibility

::: fw react

- `prefers-reduced-motion`에서는 호가 도는 것을 멈추고 고른 빛이 됩니다. 장식은 남고 움직임은 사라집니다.
- 빛은 스크린리더에게 아무 말도 하지 않고, 그럴 필요도 없습니다. 그것이 표시하고 있는 것 — 처리 중인 행, 추천되는 요금제 — 은 내용에도 적혀 있어야 합니다.
- 화면에 하나만. 세 개가 빛나는 페이지에는 지금 눈길을 끄는 하나가 없습니다.

:::

::: fw flutter

- 플랫폼에서 애니메이션이 꺼져 있으면(`MediaQuery.disableAnimations`) 호가 도는 것을 멈추고 고른 빛이 됩니다. 장식은 남고 움직임은 사라집니다.
- 빛은 스크린리더에게 아무 말도 하지 않고, 그럴 필요도 없습니다. 그것이 표시하고 있는 것은 내용에도 적혀 있어야 합니다.
- 화면에 하나만. 세 개가 빛나는 화면에는 지금 눈길을 끄는 하나가 없습니다.

:::


::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `glow`가 CSS 색 문자열 | `Color?` | 프레임워크에 이미 타입이 있습니다. |
| `::before` 위의 conic gradient | 자식 뒤 `Positioned` 레이어 위의 `SweepGradient` | 가상 요소가 없습니다. 레이어는 `clipBehavior: Clip.none`인 `Stack`의 첫 자식이라, 빛이 내용 바깥까지 닿으면서도 그 아래에 있습니다. |
| 각도를 애니메이션하려는 `@property` | sweep 위의 `GradientRotation` | 움직이는 것은 레이어가 아니라 그러데이션 자신의 회전입니다. 레이어를 돌리면 4분의 1 회전마다 모서리가 내용 밖으로 튀어나오고, CSS가 요소 대신 각도를 애니메이션하는 이유도 같습니다. |
| `filter: blur()` | `ImageFiltered` | 같은 필터에 대한 프레임워크 자신의 이름입니다. |
| `render` | — | Flutter에는 다형적 요소가 없습니다. |
| `duration`, `delay`가 밀리초 | `Duration` | 프레임워크에 이미 타입이 있습니다. |
| `easing`이 CSS 문자열 | `curve`, `Curve` | 같은 것에 대한 Dart 자신의 이름입니다. |
| `repeat: number \| 'infinite'` | `int?`, `null`이 멈추지 않음 | 적을 `'infinite'`가 없고, `-1`은 caller가 찾아봐야 하는 sentinel입니다. |
| `trigger="visible"`이 `IntersectionObserver` | 가장 가까운 `Scrollable`을 봅니다 | 여기에는 observer가 없습니다. 위에 scrollable이 없으면 볼 것이 없으므로 그냥 돕니다. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | 플랫폼 자신의 신호입니다. |
| `className`, `style` | — | 통과시킬 class 목록도 style 속성도 없습니다. |

:::
```
