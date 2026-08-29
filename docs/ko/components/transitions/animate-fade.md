---
title: PlAnimateFade
order: 3
---

# PlAnimateFade

<p class="plass-lede">불투명도만으로 도착하거나 떠나는 내용입니다. 아무것도 움직이지 않으니 reflow도 없고 다시 샘플링되는 것도 없습니다. 어떤 크기의 본문 위에서도 안전한 유일한 등장입니다.</p>

<Demo src="animate-fade/hero" :min-height="260" />

::: fw react

```tsx
import { PlAnimateFade } from 'plass-ui';

<PlAnimateFade>
  <p>Two services restarted, no errors.</p>
</PlAnimateFade>;

<PlAnimateFade trigger="visible" duration={600}>
  <PlCard title="Usage">…</PlCard>
</PlAnimateFade>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateFade(child: Text('Two services restarted, no errors.'));

const PlAnimateFade(
  trigger: PlassAnimateTrigger.visible,
  duration: Duration(milliseconds: 600),
  child: PlCard(title: Text('Usage'), child: Text('…')),
);
```

:::

## Props

<PropsTable name="PlAnimateFade" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과합니다. `render`로 요소 자체를 바꿀 수 있습니다 — `<section>`이든 `<li>`든 주변 마크업이 필요로 하는 것으로요.

:::

::: fw flutter

`duration`과 `delay`는 `Duration`이고 `curve`는 `Curve`입니다. `repeat`은 `int?`이며 **`null`이 멈추지 않음**을 뜻합니다. 적을 `'infinite'`가 없습니다.

:::

공유되는 열 가지 설정 — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — 은 모든 `PlAnimate*` 컴포넌트에서 같고, 각각에서 같은 것을 뜻합니다. 라이브러리 전체의 공유 스타일 축이 무엇을 뜻하는지는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### trigger

들어오는 방법 네 가지이고, 공유 설정이 존재하는 이유이기도 합니다. `mount`는 caller에게 아무것도 요구하지 않습니다. `visible`은 요소가 화면 안으로 스크롤될 때까지 기다립니다 — 기다리는 동안 자기 첫 프레임에 멈춰 있으므로, 다 그려져 있다가 도착하는 순간 깜빡 사라졌다 다시 시작하는 일이 없습니다. `hover`는 포인터와 **focus** 양쪽에서 시작합니다. 그러지 않으면 마우스를 쥐고 있지 않은 사람에게는 닿지 않는 효과가 됩니다. `manual`은 혼자서는 절대 돌지 않고, `play`가 `false` → `true`가 될 때마다 처음부터 다시 돕니다.

<Demo src="animate-fade/triggers" :min-height="280">

::: fw react

<<< @/.vitepress/demos/animate-fade/triggers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_fade/triggers.dart

:::

</Demo>

### mode

`out`은 두 번째 애니메이션이 아니라 같은 키프레임을 거꾸로 돌린 것입니다. 그래서 비용이 들지 않고, 그래서 **끝난 자리에 붙들려 있습니다**. 사라진 요소는 사라진 채로 남고, 실행이 끝났다고 화면으로 튀어 돌아오지 않습니다.

<Demo src="animate-fade/mode" :min-height="160">

::: fw react

<<< @/.vitepress/demos/animate-fade/mode.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_fade/mode.dart

:::

</Demo>

### delay

요소마다 다른 delay가 여러 개를 하나의 순서로 만듭니다. 목록의 자식들이 같은 효과를 차례로 받는 경우라면 [PlAnimateAppear](./animate-appear)가 단계를 대신 세어 줍니다.

<Demo src="animate-fade/timing" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-fade/timing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_fade/timing.dart

:::

</Demo>

## Accessibility

::: fw react

- `prefers-reduced-motion`에서는 애니메이션이 통째로 없어지고 내용은 그냥 거기 있습니다. 로딩 인디케이터와 정반대이고, 그 차이는 각자가 무슨 말을 하고 있는지에서 옵니다. 멈춘 spinner는 무언가 진행 중인지에 대해 거짓말을 하지만, 재생되지 않은 등장은 담고 있던 것을 이미 다 전달했습니다.
- wrapper는 role도 label도 붙이지 않습니다. 이미 자기가 무엇인지 말하는 내용을 감싼 `<div>`일 뿐입니다.
- 여기 있는 어떤 것도 내용을 숨기는 방법이 아닙니다. `mode="out"`인 요소도 문서에 그대로 있고 그대로 읽힙니다. 없어져야 한다면 unmount하세요.
- `trigger="hover"`는 focus에서도 시작하므로, 키보드로 닿을 수 있는 것 위의 효과는 마우스를 쥐고 있지 않은 사람에게도 돕니다.

:::

::: fw flutter

- 플랫폼에서 애니메이션이 꺼져 있으면(`MediaQuery.disableAnimations`) 효과가 통째로 없어지고 내용은 그냥 거기 있습니다. 로딩 인디케이터와 정반대이고, 그 차이는 각자가 무슨 말을 하고 있는지에서 옵니다. 멈춘 spinner는 무언가 진행 중인지에 대해 거짓말을 하지만, 재생되지 않은 등장은 담고 있던 것을 이미 다 전달했습니다.
- widget은 자기 semantics를 붙이지 않습니다. 이미 자기가 무엇인지 말하는 내용을 감싼 `Opacity`일 뿐입니다.
- 여기 있는 어떤 것도 내용을 숨기는 방법이 아닙니다. `PlassAnimateMode.exit`인 widget도 트리에 그대로 있고 semantics에도 그대로 있습니다. 없어져야 한다면 빼세요.
- `PlassAnimateTrigger.hover`는 focus에서도 시작하므로, 키보드로 닿을 수 있는 것 위의 효과는 마우스를 쥐고 있지 않은 사람에게도 돕니다.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | 이유 |
| --- | --- | --- |
| `duration`, `delay`가 밀리초 | `Duration` | 프레임워크에 이미 타입이 있습니다. `int` 밀리초를 받는 패키지는 그것을 쓰는 모든 파일에서 혼자 다른 말을 하게 됩니다. |
| `easing`이 CSS 문자열 | `curve`, `Curve` | 같은 것에 대한 Dart 자신의 이름입니다. |
| `repeat: number \| 'infinite'` | `int?`, `null`이 멈추지 않음 | 적을 `'infinite'`가 없고, `-1`은 caller가 찾아봐야 하는 sentinel입니다. `PlProgressLinear`가 null `value`로 하는 것과 같은 거래입니다. |
| `mode="in" \| "out"` | `PlassAnimateMode.enter` / `.exit` | `in`은 Dart의 예약어라 enum 값이 될 수 없습니다. |
| `trigger="visible"`이 `IntersectionObserver` | 가장 가까운 `Scrollable`을 봅니다 | 여기에는 observer가 없습니다. 위에 scrollable이 없으면 볼 것이 없으므로 그냥 돕니다. 브라우저에 observer가 없을 때 React 빌드가 하는 것과 같습니다. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | 플랫폼 자신의 신호입니다. |
| `render` | — | Flutter에는 다형적 요소가 없습니다. |
| `className`, `style` | — | 통과시킬 class 목록도 style 속성도 없습니다. |

:::
