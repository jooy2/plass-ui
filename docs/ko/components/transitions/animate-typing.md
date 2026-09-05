---
title: PlAnimateTyping
order: 11
---

# PlAnimateTyping

<p class="plass-lede">글자가 하나씩 나타납니다. 문자열 전체는 첫 프레임부터 문서에 있어서, 보지 못하는 사람에게는 아무 비용도 들지 않고 보는 사람에게는 아무것도 reflow시키지 않습니다.</p>

<Demo src="animate-typing/hero" :min-height="160" />

::: fw react

```tsx
import { PlAnimateTyping } from 'plass-ui';

<PlAnimateTyping text="npm install plass-ui" speed={14} hold={1600} erase repeat="infinite" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateTyping(
  'flutter pub add plass_ui',
  speed: 14,
  hold: Duration(milliseconds: 1600),
  erase: true,
  repeat: null,
);
```

```

:::

## Props

<PropsTable name="PlAnimateTyping" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과합니다. 다만 `children`은 예외로, 그것이 텍스트입니다. `render`도 `easing`도 `alternate`도 없습니다. 컴포넌트가 자기 span 두 개를 있고, 타자기는 곡선을 따라가는 것이 아니라 글자 단위로 나아갑니다.

:::

::: fw flutter

텍스트는 `PlTypography`가 데이터를 받는 방식대로 **첫 위치 인자**이고 평범한 `String`입니다. 여기에는 펼칠 것이 없습니다. 타자기는 문자열을 grapheme 단위로 드러내므로 입력도 문자열입니다. 그리기는 자기가 놓인 `DefaultTextStyle` 그대로입니다.

:::

**텍스트만 타이핑됩니다.** 문자열 하나 또는 여럿을 넘기세요. children 사이의 요소는 자기 텍스트만 보태고 마크업은 아무것도 보태지 않습니다. 링크의 절반을 정직하게 드러낼 방법이 없기 때문입니다.

`duration`은 **문자열 전체**에 걸리는 시간으로 해석되고 `speed`를 덮어씁니다. 여기서 자연스러운 단위는 `speed`입니다. 긴 문단과 짧은 문단은 같은 시간이 아니라 같은 속도로 쳐져야 하기 때문입니다. 그래서 기본값이 그쪽입니다.

## Examples

### speed

초당 글자 수입니다. 24 언저리가 사람이 치는 것처럼 읽히고, 10 아래는 기계가 찍는 것, 60 위는 줄이 그냥 나타나는 쪽에 가깝습니다.

<Demo src="animate-typing/speed" :min-height="240">

::: fw react

<<< @/.vitepress/demos/animate-typing/speed.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_typing/speed.dart

:::

</Demo>

### erase

`repeat`, `hold`, `erase`가 이것을 순환으로 만듭니다. 치고, 붙들고, 지우고, 다시 칩니다. `erase` 없이는 반복이 한 프레임에 지워지는데, 다시 쓰이는 것이 아니라 **교체되는** 줄에는 그쪽이 맞습니다.

<Demo src="animate-typing/erase" :min-height="160">

::: fw react

<<< @/.vitepress/demos/animate-typing/erase.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_typing/erase.dart

:::

</Demo>

## Accessibility

::: fw react

- 문자열 전체는 잘려 있는 상자 안에 있고 스크린리더는 그것을 **한 번** 읽습니다. 애니메이션되는 눈에 보이는 사본은 `aria-hidden`입니다. 아무도 공연을 끝까지 앉아 있을 필요가 없습니다.
- `prefers-reduced-motion`에서는 텍스트가 그냥 거기 있습니다. "아무 일도 일어나지 않음"이 아닙니다. 컴포넌트가 담고 있던 것을 그대로 전달하는 유일한 결과입니다.
- 나아가는 단위는 code point가 아니라 **grapheme**입니다. `👩‍👩‍👧`는 읽는 사람에게 한 글자이고 JavaScript에게 code point 일곱 개이며, code point 단위로 나아가는 타자기는 그것을 아무 뜻도 없는 조각들로 조립하는 데 네 프레임을 씁니다.
- 상자는 도착한 글자들로부터 레이아웃되지 않으므로 주변 텍스트가 매 프레임 reflow하지 않습니다. 다만 컨테이너가 허용하는 만큼 넓어지므로, 줄바꿈이 중요하다면 한 줄짜리 효과에는 `white-space: nowrap`이나 너비를 주세요.

:::

::: fw flutter

- 문자열 전체가 widget의 접근성 label이고 그려지는 사본은 `ExcludeSemantics` 뒤에 있습니다. 그래서 스크린리더는 텍스트를 **한 번** 받고, 공연을 끝까지 앉아 있을 필요가 없습니다.
- 플랫폼에서 애니메이션이 꺼져 있으면(`MediaQuery.disableAnimations`) 텍스트가 그냥 거기 있습니다. "아무 일도 일어나지 않음"이 아닙니다. widget이 담고 있던 것을 그대로 전달하는 유일한 결과입니다.
- 나아가는 단위는 code point가 아니라 **grapheme**입니다. `👩‍👩‍👧`는 읽는 사람에게 한 글자이고 Dart에게 code point 일곱 개입니다.
- 문자열 전체가 차지할 상자는 첫 프레임부터 잡혀 있어서, 글자가 도착하는 동안 주변의 어떤 것도 다시 레이아웃되지 않습니다.

:::


::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `text` 또는 children을 문자열로 펼침 | 위치 인자 `String` 하나 | 펼칠 것이 없습니다. 타자기의 입력은 텍스트이므로 텍스트를 받습니다. |
| 스크린리더용 잘린 사본 + `aria-hidden`인 보이는 사본 | `ExcludeSemantics` 위의 `Semantics(label:)` | 같은 두 가지 일을 노드 하나 덜 써서 합니다. |
| 도착한 글자로 상자를 레이아웃하지 않음 | 전체 문자열을 부분 문자열 아래에 보이지 않게 그림 | Flutter의 `Text`는 담고 있는 것으로 레이아웃되므로, 전체 문자열을 담은 무언가가 자리를 잡아 주어야 합니다. |
| `Intl.Segmenter` | `String.characters` | 둘 다 grapheme의 끝을 압니다. 이쪽은 프레임워크와 함께 옵니다. |
| `duration`, `delay`가 밀리초 | `Duration` | 프레임워크에 이미 타입이 있습니다. |
| `easing`이 CSS 문자열 | `curve`, `Curve` | 같은 것에 대한 Dart 자신의 이름입니다. |
| `repeat: number \| 'infinite'` | `int?`, `null`이 멈추지 않음 | 적을 `'infinite'`가 없고, `-1`은 caller가 찾아봐야 하는 sentinel입니다. |
| `trigger="visible"`이 `IntersectionObserver` | 가장 가까운 `Scrollable`을 봅니다 | 여기에는 observer가 없습니다. 위에 scrollable이 없으면 볼 것이 없으므로 그냥 돕니다. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | 플랫폼 자신의 신호입니다. |
| `className`, `style` | — | 통과시킬 class 목록도 style 속성도 없습니다. |

:::
```
