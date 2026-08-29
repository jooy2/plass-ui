---
title: PlAnimateAppear
order: 1
---

# PlAnimateAppear

<p class="plass-lede">여러 개가 차례로 제자리에 내려앉습니다. 효과가 개별 항목이 아니라 묶음에 속하므로, 읽는 사람의 눈이 읽어야 할 순서대로 목록을 따라 내려갑니다.</p>

<Demo src="animate-appear/hero" :min-height="360" />

::: fw react

```tsx
import { PlAnimateAppear } from 'plass-ui';

<PlAnimateAppear className="flex flex-col gap-2">
  {services.map((service) => (
    <PlCard key={service.name} title={service.name} />
  ))}
</PlAnimateAppear>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAnimateAppear(
  spacing: 8,
  children: <Widget>[
    for (final Service service in services) PlCard(title: Text(service.name)),
  ],
);
```

```

:::

## Props

<PropsTable name="PlAnimateAppear" />

::: fw react

애니메이션은 자식을 감싸는 wrapper가 아니라 **자식 자신에게** 쓰입니다. `<li>` 한 줄은 `<li>` 한 줄로 남고, 그리드의 셀은 그리드의 직계 자식으로 남고, 목록이 애니메이션된다고 레이아웃에 대해 달라지는 것이 없습니다. 자식이 이미 가지고 있던 class와 style은 이것이 더하는 것 옆에 그대로 남습니다. 맨 문자열만은 쓸 요소가 없어서 `<span>`으로 감싸집니다.

네이티브 `<div>` 속성은 그대로 통과하고, `render`로 컨테이너를 다른 요소로 바꿀 수 있습니다.

:::

::: fw flutter

이 widget은 **자식을 직접 배치합니다**. React 빌드는 그럴 필요가 없죠. 여기에는 컨테이너에 `display: flex`를 걸어 줄 스타일시트가 없으므로, `orientation`과 `spacing`이 `className`이 했을 일을 합니다. 행이나 열보다 복잡한 배치는 자식 *안*에 두세요. 그러면 그 배치 전체가 시차의 한 단계가 되기도 합니다. `distance`는 논리 픽셀 단위의 `double`입니다.

:::

공유되는 열 가지 설정 — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — 은 모든 `PlAnimate*` 컴포넌트에서 같습니다. `delay`는 **첫 단계 이전**에 일어나는 일이므로, 자식마다가 아니라 한 번만 더해집니다.

## Examples

### stagger

효과의 전부입니다. 나머지는 자식 하나가 하는 일 — 짧은 이동과 fade — 이고, 그것을 순서로 만드는 것이 시차입니다.

**자식**을 세지, 잎을 세지 않습니다. 자식 여덟이면 여덟 단계이고, 여덟 개를 담은 자식 하나는 한 단계입니다. 목록의 일부를 빼는 방법도 이것입니다. 묶으세요.

<Demo src="animate-appear/stagger" :min-height="280">

::: fw react

<<< @/.vitepress/demos/animate-appear/stagger.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_appear/stagger.dart

:::

</Demo>

### from and reverse

`from`은 각 자식이 들어오는 모서리이고, `reverse`는 마지막 자식부터 첫 자식까지 목록을 거꾸로 돌립니다. 거리가 짧은 것은 의도입니다. 이것은 화면 밖에서의 등장이 아니라 내려앉음이고, 여덟 개짜리 목록 위에서의 긴 이동은 덩어리 전체를 움직이는 무언가로 만듭니다. 하나가 먼 데서 오는 것이라면 [PlAnimateSlide](./animate-slide)를 쓰세요.

<Demo src="animate-appear/direction" :min-height="300">

::: fw react

<<< @/.vitepress/demos/animate-appear/direction.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_appear/direction.dart

:::

</Demo>

## Accessibility

::: fw react

- `prefers-reduced-motion`에서는 애니메이션이 통째로 없어지고 목록 전체가 그냥 거기 있습니다.
- 어느 시점에도 스크린리더에게 숨겨지는 것은 없습니다. 자식은 전부 첫 프레임부터 문서에 있고, 시차가 붙는 것은 각각이 언제 그려지는지이지 언제 존재하는지가 아닙니다.
- 전체 길이를 짧게 두세요. 자식 여덟에 70ms면 마지막이 앉기까지 0.5초이고, 300ms면 2.5초입니다. 그동안 읽는 사람은 완성되지 않은 목록을 보고 있습니다.
- 시차는 장식이지 순서가 아닙니다. 순서가 중요하다면 마크업에 있어야 합니다.

:::

::: fw flutter

- 플랫폼에서 애니메이션이 꺼져 있으면(`MediaQuery.disableAnimations`) 효과가 통째로 없어지고 목록 전체가 그냥 거기 있습니다.
- 어느 시점에도 스크린리더에게 숨겨지는 것은 없습니다. 모든 자식은 첫 프레임부터 트리에 있고, 시차가 붙는 것은 각각이 언제 그려지는지이지 언제 존재하는지가 아닙니다.
- 전체 길이를 짧게 두세요. 자식 여덟에 70ms면 마지막이 앉기까지 0.5초이고, 300ms면 2.5초입니다.
- 시차는 장식이지 순서가 아닙니다. 순서가 중요하다면 트리에 있어야 합니다.

:::


::: fw flutter

## Differences from the React build

| React | Flutter | 이유 |
| --- | --- | --- |
| 애니메이션을 자식 자신의 `className`과 `style`에 씀 | 자식을 각각 감쌈 | 더할 class 목록이 없습니다. 감싸는 것은 `Flex`에 투명하지만, 무언가의 직계 자식이어야 하는 것 — `Expanded` 같은 — 은 이 widget 바깥에 두어야 합니다. |
| 컨테이너가 caller가 스타일링하는 맨 `<div>` | `orientation`과 `spacing` | 스타일시트가 없으니 widget이 자식을 배치해야 합니다. |
| `distance`가 CSS 길이 | `double` | 논리 픽셀입니다. |
| `render` | — | Flutter에는 다형적 요소가 없습니다. |
| `duration`, `delay`가 밀리초 | `Duration` | 프레임워크에 이미 타입이 있습니다. |
| `easing`이 CSS 문자열 | `curve`, `Curve` | 같은 것에 대한 Dart 자신의 이름입니다. |
| `repeat: number \| 'infinite'` | `int?`, `null`이 멈추지 않음 | 적을 `'infinite'`가 없고, `-1`은 caller가 찾아봐야 하는 sentinel입니다. |
| `trigger="visible"`이 `IntersectionObserver` | 가장 가까운 `Scrollable`을 봅니다 | 여기에는 observer가 없습니다. 위에 scrollable이 없으면 볼 것이 없으므로 그냥 돕니다. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | 플랫폼 자신의 신호입니다. |
| `className`, `style` | — | 통과시킬 class 목록도 style 속성도 없습니다. |

:::
```
