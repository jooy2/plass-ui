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

::: fw react

세 가지가 더 있고, 이들은 효과를 상자에서 떼어 안의 것들로 옮깁니다 — `stagger`, `durationStep`, `reverse`. 아래 [자식들을 하나씩 떼어 놓기](#자식들을-하나씩-떼어-놓기)를 보세요.

:::

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

### 자식들을 하나씩 떼어 놓기

::: fw react

`stagger`는 효과를 **상자에서 떼어 안의 것들로** 옮겨, 하나씩 차례로 재생하게 합니다. 각 자식의 delay에 더해지는 밀리초이고, 기본값 `0`은 상자 자체를 재생합니다. 하나를 감쌀 때는 그것이 계속 옳습니다.

켜지는 순간 상자는 애니메이션을 완전히 멈춥니다. 자식 여덟이 나타나는 위에서 상자까지 나타나면 같은 내용을 두 번 나타내는 것이고, 두 번째는 공짜가 아닙니다.

<Demo src="animate-fade/stagger" :min-height="140">

<<< @/.vitepress/demos/animate-fade/stagger.tsx

</Demo>

`durationStep`은 자식마다 앞의 것보다 긴 — 음수면 짧은 — 재생 시간을 주며, `0` 아래로는 내려가지 않습니다. `reverse`는 집합의 끝에서부터 시작합니다. **순서**만 뒤집히고 그 외에는 아무것도 바뀌지 않습니다. 거꾸로 도는 효과는 `mode="out"`이기 때문입니다.

간격은 자식 *하나*마다이므로 무엇을 넘기는지가 중요합니다. 자식 다섯은 다섯 단계이고, 다섯 개를 담은 자식 하나는 한 단계입니다. 집합의 일부를 빼는 방법도 이것입니다 — 묶으세요.

애니메이션은 자식을 감싼 래퍼가 아니라 자식 자신에게 쓰이므로, `<li>` 줄은 `<li>` 줄로 남고 그리드의 칸은 그리드의 직계 자식으로 남습니다. 대가는 자식이 `className`과 `style`을 받아야 한다는 것입니다. 받지 않는 자식은 애니메이션되지 않습니다. 문자열 하나는 쓸 요소가 없으므로, 유일하게 `<span>`으로 감싸집니다.

키프레임 하나짜리 효과 여섯 개가 모두 이 셋을 받습니다. [`PlAnimateMarquee`](./animate-marquee), [`PlAnimateHeadline`](./animate-headline), [`PlAnimateTyping`](./animate-typing), [`PlAnimateLighting`](./animate-lighting)은 받지 않고, 받을 수도 없습니다. 앞의 셋은 이미 자식이 무엇인지 읽고 있고, 마지막은 움직임이 pseudo-element에 있어서 남의 자식에 얹을 방법이 없습니다. [`PlAnimateAppear`](./animate-appear)는 같은 이름의 같은 세 prop이고, `stagger`의 기본값만 `70`입니다. 간격이 없는 집합은 집합이 아니기 때문입니다.

**`PlAnimateStagger`는 의도적으로 없습니다.** 간격은 효과가 아니라 차등이고, 래퍼는 효과들이 이미 말할 수 있는 것을 두 번째 방식으로 철자하는 일이 됩니다. `Pulse`(`blink` + `alternate`)와 `Bounce`(`grow` + `alternate`)를 라이브러리에 넣지 않는 것과 같은 규칙입니다.

:::

::: fw flutter

차등을 준 집합은 [`PlAnimateAppear`](./animate-appear)입니다. React 빌드는 호출자의 CSS가 여전히 자식들을 배치하고 있으므로 임의의 자식에 효과를 써 넣을 수 있습니다. 여기에는 그 일을 할 스타일시트가 없어서, 차등을 준 효과는 행이나 열까지 자기가 가져야 합니다. 그것이 바로 `PlAnimateAppear`이고, 그것을 여섯 개 더 만드는 일이 됩니다.

:::

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
| `stagger`, `durationStep`, `reverse` | — | React 빌드는 효과를 자식들 자신에게 써 넣으므로 호출자의 레이아웃은 그대로입니다. Flutter에는 집합을 배치할 스타일시트가 없어서, 차등을 준 효과는 행이나 열까지 자기가 가져야 합니다. 그것이 바로 [`PlAnimateAppear`](./animate-appear)이고, 그것을 여섯 개 더 만드는 일이 됩니다. |
| `className`, `style` | — | 통과시킬 class 목록도 style 속성도 없습니다. |

:::
