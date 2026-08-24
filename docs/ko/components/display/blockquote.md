---
title: PlBlockquote
order: 8
---

# PlBlockquote

<p class="plass-lede">남의 말을 자기 말과 떼어 놓습니다. 시작하는 쪽 가장자리에 강조색 선이 서고, 인용문은 제목의 크기로 놓이며, 출처가 있으면 HTML 명세가 요구하는 마크업으로 붙습니다.</p>

<Demo src="blockquote/hero" :min-height="260" />

```tsx
import { PlBlockquote } from 'plass-ui';

<PlBlockquote author="Ada Lovelace" source="Notes on the Analytical Engine">
  Simplicity is hard.
</PlBlockquote>;
```

## Props

<PropsTable name="PlBlockquote" />

네이티브 `<figure>` 속성은 안쪽의 `<blockquote>`가 아니라 **감싸는 요소**에 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 전달 대상에서 제외됩니다.

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### author, source, cite

`author`는 사람이고 `source`는 저작물입니다. 이름 붙이기 취향의 문제가 아닙니다 — `<cite>`는 저작물의 제목을 위한 요소이고 명세상 사람 이름에는 쓰지 않으므로, 둘은 한 자리를 나눠 쓸 수 없습니다.

출처는 인용문에 **대한** 것이지 말해진 내용의 일부가 아닙니다. 그래서 출처를 넘기면 감싸는 요소가 `<figure>`가 되고, `<figcaption>`이 `<blockquote>` 바깥에 놓입니다. 출처가 없으면 감싸는 요소는 그냥 `<div>`입니다 — `<figcaption>`이 없는 `<figure>`는 아무것도 아닌 것의 그림입니다.

`cite`는 URL이고, `<blockquote>` 자신의 속성에 놓입니다. 기계만 읽고 아무에게도 보이지 않습니다.

<Demo src="blockquote/attribution" :min-height="320">

<<< @/.vitepress/demos/blockquote/attribution.tsx

</Demo>

### variant

`PlCard`가 그렇듯 시트에는 색이 들어가지 않습니다. 인용문은 남의 말을 담고 있고, 틴트가 깔린 판 위의 말은 그 배경을 두고 고른 적 없는 말입니다 — 그래서 색 계열은 선까지만 닿고 멈춥니다.

기본값 `ghost`는 흐르는 산문 안에 놓이는 모양입니다. 여백의 선 하나뿐이고, 선 위에 올려놓을 표면이라는 것이 생기기 훨씬 전부터 인용문은 그런 모양이었습니다.

<Demo src="blockquote/variants" :min-height="320">

<<< @/.vitepress/demos/blockquote/variants.tsx

</Demo>

### color

<Demo src="blockquote/colors" :min-height="280">

<<< @/.vitepress/demos/blockquote/colors.tsx

</Demo>

### size

<Demo src="blockquote/sizes" :min-height="420">

<<< @/.vitepress/demos/blockquote/sizes.tsx

</Demo>

## Accessibility

- 인용문은 진짜 `<blockquote>`이고 출처는 그 바깥의 진짜 `<figcaption>`입니다. 인용문 **안**에 든 이름은 말한 사람이 자기 이름을 말했다고 주장하는 것이 됩니다.
- 따옴표 글리프는 장식이라 `aria-hidden`입니다. 저자 앞의 em dash도 마찬가지입니다 — 이름 앞에서 "em dash"를 읽는 스크린리더는 텍스트가 아니라 타이포그래피를 읽고 있는 것입니다.
- `<blockquote>` 요소 자체에는 아무것도 그리지 않습니다. `blockquote`는 호스트 스타일시트가 아직도 태그 이름으로 스타일을 주는 몇 안 되는 태그이고, 표면과 선을 감싸는 요소로 옮긴 것이 호스트가 자기 버전을 되돌리면서 이쪽 것까지 되돌리지 않게 하는 방법입니다.
