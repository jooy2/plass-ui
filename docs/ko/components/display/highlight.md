---
title: PlHighlight
order: 11
---

# PlHighlight

<p class="plass-lede">읽고 있던 글 안에서, 찾고 있던 단어를 표시합니다. 이 컴포넌트는 스타일링만이 아니라 검색 그 자체입니다. <code>query</code>는 검색창이 들고 있는 바로 그 값입니다.</p>

<Demo src="highlight/hero" :min-height="240" />

::: fw react

```tsx
import { PlHighlight } from 'plass-ui';

<PlHighlight query={search}>{result.summary}</PlHighlight>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlHighlight(result.summary, query: search);
```

:::

## Props

<PropsTable name="PlHighlight" />

::: fw react

네이티브 `<span>` 속성은 감싸는 요소에 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 전달 대상에서 제외됩니다.

:::

::: fw flutter

텍스트는 첫 번째 위치 인자이고 위젯이 아니라 `String`입니다. 그 대가와 이유는 아래 [중첩된 내용](#중첩된-내용)에 있습니다.

`query`의 타입은 `Object`인데, Dart에 없는 union을 쓰는 방법입니다. `String`, `RegExp`, 또는 둘 중 하나의 `List`이고, 생성자가 그것을 단언합니다.

:::

`size`는 없고, 이것이 아마 가장 먼저 찾게 될 prop일 것입니다. 표시는 흐르는 글 안에 놓이므로 그 글의 크기여야 합니다. `size` prop은 틀릴 방법만 늘려 줍니다.

라이브러리 전체에서 공유 축(`variant` `color`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### query

문자열은 한 단어입니다. 배열은 여러 개이고 긴 것부터 시도합니다. 정규식의 교대(alternation)는 먼저 맞는 쪽이 이기므로, 그러지 않으면 `['data', 'database']`는 `data`만 표시하고 `base`를 표시 바깥에 남깁니다.

`RegExp`는 쓰인 그대로 쓰입니다. `caseSensitive`와 `wholeWord`는 무시되는데, 정규식은 이미 그 둘을 스스로 나타내고 있기 때문입니다.

<Demo src="highlight/matching" :min-height="220">

::: fw react

<<< @/.vitepress/demos/highlight/matching.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/highlight/matching.dart

:::

</Demo>

### 중첩된 내용

::: fw react

`children`은 문자열이 아니라 트리입니다. 요소는 안으로 걸어 들어가되 그 밖에는 손대지 않으므로, `<strong>` 안의 일치도 표시되고 `<strong>`도 살아남습니다. 문자열을 요구하는 것이 대부분의 라이브러리가 하는 일이고, 마크업이 들어 있는 첫 번째 검색 결과에서 곧바로 무너집니다.

<Demo src="highlight/nested" :min-height="140">

<<< @/.vitepress/demos/highlight/nested.tsx

</Demo>

:::

::: fw flutter

Flutter 빌드는 `String`을 받고, 그것은 빠뜨린 것이 아니라 진짜 차이입니다. React의 `children`은 안으로 걸어 들어갈 `props.children`을 가진 요소의 트리이지만 Flutter의 `Widget`은 불투명합니다. 건네받은 `Text` 안의 문자열에 닿을 방법이 없고, 그 문자열을 표시한 채로 위젯을 다시 만들 방법은 더더욱 없습니다.

그래서 텍스트는 글자로 들어오고 표시는 span으로 나옵니다. 이 방식으로 다룰 수 없는 경우는 이미 중간에 스타일이 바뀌는 글이고, 이 컴포넌트가 존재하는 이유인 검색 결과는 문자열로 들어옵니다.

:::

### variant

여기서 `glass`는 일부러 흐리지 않습니다. 라이브러리에서 재질을 쓰는 대신 인용하는 유일한 자리입니다. 표시는 한 줄의 글 위에 놓인 높이 20px짜리 상자입니다. 뒤에 문지를 만한 배경이 없습니다.

<Demo src="highlight/variants" :min-height="180">

::: fw react

<<< @/.vitepress/demos/highlight/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/highlight/variants.dart

:::

</Demo>

### color

기본값 `warning`은 임의로 고른 것이 아닙니다. 그러데이션이 밝고 잉크가 어두운 유일한 계열이라, `solid` `warning` 표시는 색 덩어리 위의 흰 글자가 아니라 검은 글자 위의 노란 형광펜이 됩니다.

<Demo src="highlight/colors" :min-height="200">

::: fw react

<<< @/.vitepress/demos/highlight/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/highlight/colors.dart

:::

</Demo>

## Accessibility

::: fw react

- 표시는 진짜 `<mark>`입니다. 독자에게 관련 있는 텍스트를 위한 요소이고, 그렇게 읽힙니다.
- 여기에는 알아 둘 만한 결과가 하나 따라옵니다. 한 문단에서 열한 단어를 표시하는 것은 스크린리더에게 열한 가지가 중요하다고 알리는 것이고, 그것은 아무 말도 하지 않는 방법입니다. 표시는 몇 개의 일치를 위한 것입니다.
- 전체 텍스트는 언제나 순서 그대로 남아 있습니다. 표시는 문자열을 나눌 뿐, 다시 쓰거나 빠뜨리지 않습니다.
- 표시는 아주 약간의 padding을 더하고 같은 양을 음수 margin으로 되돌려 줍니다. 그래서 표시된 줄은 표시 전과 정확히 같은 길이입니다. 표시가 주변 글자를 움직여서는 안 됩니다.

:::

::: fw flutter

- 스크린리더에 닿는 것은 문자열 전체이고, 순서대로 한 번 읽힙니다. 표시는 문단 안에 놓인 위젯이라, 그렇게 하지 않으면 표시되지 않은 글 사이사이에 placeholder가 늘어선 것을 듣게 됩니다.
- 그래도 표시는 몇 개의 일치를 위한 것입니다. 여기서는 표시가 스스로를 알리지 않으니 이유가 눈으로 보는 쪽에 있습니다. 한 문단에서 열한 단어를 표시하는 것은 아무것도 표시하지 않는 방법입니다.
- 전체 텍스트는 언제나 순서 그대로 남아 있습니다. 표시는 문자열을 나눌 뿐, 다시 쓰거나 빠뜨리지 않습니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| 트리로서의 `children` | `String`으로서의 텍스트 | `Widget`은 불투명합니다. 건네받은 위젯 안의 텍스트에 닿을 방법이 없습니다. [중첩된 내용](#중첩된-내용)을 보세요. |
| 읽히는 진짜 `<mark>` | 위젯 span, 그리고 라벨로서의 문자열 전체 | Flutter에는 mark role이 없습니다. 대신 있는 것은 여전히 한 문장으로 읽혀야 하는 문단입니다. |
| 표시가 자기 padding을 상쇄함 | 상쇄하지 않음 | 음수 margin은 Flutter의 `Padding`이 받아 주지 않습니다. 표시는 표시하는 단어보다 4px 넓고, 흐르는 글 위에서 이 문서가 밝혀야 할 차이가 그것입니다. |
| 줄바꿈을 넘는 `box-decoration-clone` | 표시는 줄을 넘지 않음 | 표시는 줄 안의 위젯 하나라, 긴 구절은 자기 표면 안에서 줄바꿈하는 대신 통째로 다음 줄로 넘어갑니다. |
| `caseSensitive`, `wholeWord` | 같은 이름, 같은 두 규칙 | `wholeWord`는 여기서도 모든 문자 체계의 글자·숫자·밑줄을 셉니다. `café`에는 뜻대로 동작하고, 한국어에는 거의 아무 뜻이 없습니다. |

:::
