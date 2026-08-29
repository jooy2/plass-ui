---
title: PlAnimateBlink
order: 2
---

# PlAnimateBlink

<p class="plass-lede">완전한 불투명도와 바닥값 사이를 오가며 맥동하는 내용입니다. 주기가 대칭이라 — 진하게, 옅게, 진하게 — 몇 번을 돌든 시작한 자리에서 끝납니다.</p>

<Demo src="animate-blink/hero" :min-height="160" />

::: fw react

```tsx
import { PlAnimateBlink } from 'plass-ui';

<PlAnimateBlink min={0.45}>
  <PlChip color="warning">Awaiting approval</PlChip>
</PlAnimateBlink>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateBlink(
  min: 0.45,
  child: PlChip(color: PlassColor.warning, child: Text('Awaiting approval')),
);
```

```

:::

## Props

<PropsTable name="PlAnimateBlink" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과하고, `render`로 요소 자체를 바꿀 수 있습니다.

:::

::: fw flutter

`repeat`은 `int?`이고 여기서는 기본값 그대로 `null`, 즉 멈추지 않음입니다. `mode`도 `fade`도 없습니다. blink는 도착이 아니라 주기입니다.

:::

`mode`도 `fade`도 없습니다. blink는 도착이 아니라 주기이므로 돌아갈 방향이 없고, 따로 fade할 것도 없습니다.

`repeat`의 기본값이 여기서는 `'infinite'`이고 나머지 전부에서는 `1`입니다. 한 번뿐인 blink는 깜빡임이고, 깜빡임을 요청하는 사람은 없기 때문입니다. 나머지 공유 설정 — `duration`, `delay`, `easing`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — 은 다른 모든 `PlAnimate*` 컴포넌트에서와 같은 뜻입니다.

## Examples

### min

주기의 바닥에서 얼마나 옅어지는지입니다. `0`이면 내용이 사라집니다. 맥동하는 동안에도 읽혀야 하는 것 — 대부분이 그렇습니다 — 이라면 올려 잡으세요. 절반의 시간에만 있는 단어는 누군가 놓칠 단어입니다.

<Demo src="animate-blink/min" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-blink/min.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_blink/min.dart

:::

</Demo>

### repeat

횟수는 무언가에 영원히가 아니라 한 번 시선을 끄는 방법입니다. 주기가 대칭이라, 끝난 실행은 내용을 찾았던 그대로 두고 갑니다.

<Demo src="animate-blink/count" :min-height="220">

::: fw react

<<< @/.vitepress/demos/animate-blink/count.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_blink/count.dart

:::

</Demo>

## Accessibility

::: fw react

- `prefers-reduced-motion`에서는 애니메이션이 통째로 없어지고 내용은 완전한 불투명도로 남습니다. **그러므로 `min`이 메시지를 나르는 유일한 수단이어서는 안 됩니다.** 급한 일이라면 말로도 쓰세요.
- 누군가 읽고 있는 페이지의 구석에서 끝없이 움직이는 것은 이 라이브러리의 나머지가 거부하는 유일한 종류의 움직임입니다. `'infinite'`보다는 횟수를, 둘보다는 색을 먼저 쓰세요.
- 초당 세 번 깜빡이는 것과는 확실히 거리를 두세요. 기본값이 느린 맥동이고, 그대로 두어야 합니다.

:::

::: fw flutter

- 플랫폼에서 애니메이션이 꺼져 있으면(`MediaQuery.disableAnimations`) 효과가 없어지고 내용은 완전한 불투명도로 남습니다. **그러므로 `min`이 메시지를 나르는 유일한 수단이어서는 안 됩니다.** 급한 일이라면 말로도 쓰세요.
- 누군가 읽고 있는 화면 구석에서 끝없이 움직이는 것은 이 패키지의 나머지가 거부하는 유일한 종류의 움직임입니다. `null` repeat보다는 횟수를, 둘보다는 색을 먼저 쓰세요.
- 초당 세 번 깜빡이는 것과는 확실히 거리를 두세요. 기본값이 느린 맥동이고, 그대로 두어야 합니다.

:::


::: fw flutter

## Differences from the React build

| React | Flutter | 이유 |
| --- | --- | --- |
| `repeat="infinite"` | `repeat: null` | 여기서의 기본값이고, 멈추지 않음을 뜻하는 값입니다. |
| `render` | — | Flutter에는 다형적 요소가 없습니다. |
| `duration`, `delay`가 밀리초 | `Duration` | 프레임워크에 이미 타입이 있습니다. |
| `easing`이 CSS 문자열 | `curve`, `Curve` | 같은 것에 대한 Dart 자신의 이름입니다. |
| `repeat: number \| 'infinite'` | `int?`, `null`이 멈추지 않음 | 적을 `'infinite'`가 없고, `-1`은 caller가 찾아봐야 하는 sentinel입니다. |
| `trigger="visible"`이 `IntersectionObserver` | 가장 가까운 `Scrollable`을 봅니다 | 여기에는 observer가 없습니다. 위에 scrollable이 없으면 볼 것이 없으므로 그냥 돕니다. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | 플랫폼 자신의 신호입니다. |
| `className`, `style` | — | 통과시킬 class 목록도 style 속성도 없습니다. |

:::
```
