---
title: PlHighlight
order: 11
---

# PlHighlight

<p class="plass-lede">읽고 있던 글 안에서, 찾고 있던 단어를 표시합니다. 이 컴포넌트는 스타일링만이 아니라 검색 그 자체입니다 — <code>query</code>는 검색창이 들고 있는 바로 그 값입니다.</p>

<Demo src="highlight/hero" :min-height="240" />

```tsx
import { PlHighlight } from 'plass-ui';

<PlHighlight query={search}>{result.summary}</PlHighlight>;
```

## Props

<PropsTable name="PlHighlight" />

네이티브 `<span>` 속성은 감싸는 요소에 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 전달 대상에서 제외됩니다.

`size`는 없고, 이것이 아마 가장 먼저 찾게 될 prop일 것입니다. 표시는 흐르는 글 안에 놓이므로 그 글의 크기여야 합니다. `size` prop은 틀릴 방법만 늘려 줍니다.

라이브러리 전체에서 공유 축(`variant` `color`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### query

문자열은 한 단어입니다. 배열은 여러 개이고 긴 것부터 시도합니다 — 정규식의 교대(alternation)는 먼저 맞는 쪽이 이기므로, 그러지 않으면 `['data', 'database']`는 `data`만 표시하고 `base`를 표시 바깥에 남깁니다.

`RegExp`는 쓰인 그대로 쓰이되 global 플래그가 켜집니다. `caseSensitive`와 `wholeWord`는 무시되는데, 정규식은 이미 그 둘을 스스로 말하고 있기 때문입니다.

<Demo src="highlight/matching" :min-height="220">

<<< @/.vitepress/demos/highlight/matching.tsx

</Demo>

### 중첩된 내용

`children`은 문자열이 아니라 트리입니다. 요소는 안으로 걸어 들어가되 그 밖에는 손대지 않으므로, `<strong>` 안의 일치도 표시되고 `<strong>`도 살아남습니다. 문자열을 요구하는 것이 대부분의 라이브러리가 하는 일이고, 마크업이 들어 있는 첫 번째 검색 결과에서 곧바로 무너집니다.

<Demo src="highlight/nested" :min-height="140">

<<< @/.vitepress/demos/highlight/nested.tsx

</Demo>

### variant

여기서 `glass`는 일부러 흐리지 않습니다. 라이브러리에서 재질을 쓰는 대신 인용하는 유일한 자리입니다. 표시는 한 줄의 글 위에 놓인 높이 20px짜리 인라인 상자입니다 — 뒤에 문지를 만한 배경이 없고, 줄바꿈을 넘는 표시라면 두 개를 문지르게 됩니다.

<Demo src="highlight/variants" :min-height="180">

<<< @/.vitepress/demos/highlight/variants.tsx

</Demo>

### color

기본값 `warning`은 임의로 고른 것이 아닙니다. 그러데이션이 밝고 잉크가 어두운 유일한 계열이라, `solid` `warning` 표시는 색 덩어리 위의 흰 글자가 아니라 검은 글자 위의 노란 형광펜이 됩니다.

<Demo src="highlight/colors" :min-height="200">

<<< @/.vitepress/demos/highlight/colors.tsx

</Demo>

## Accessibility

- 표시는 진짜 `<mark>`입니다. 독자에게 관련 있는 텍스트를 위한 요소이고, 그렇게 읽힙니다.
- 여기에는 알아 둘 만한 결과가 하나 따라옵니다. 한 문단에서 열한 단어를 표시하는 것은 스크린리더에게 열한 가지가 중요하다고 말하는 것이고, 그것은 아무 말도 하지 않는 방법입니다. 표시는 몇 개의 일치를 위한 것입니다.
- 전체 텍스트는 언제나 순서 그대로 남아 있습니다. 표시는 문자열을 나눌 뿐, 다시 쓰거나 빠뜨리지 않습니다.
- 표시는 아주 약간의 padding을 더하고 같은 양을 음수 margin으로 되돌려 줍니다. 그래서 표시된 줄은 표시 전과 정확히 같은 길이입니다. 표시가 주변 글자를 움직여서는 안 됩니다.
