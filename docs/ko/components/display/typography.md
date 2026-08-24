---
title: PlTypography
order: 14
---

# PlTypography

<p class="plass-lede">라이브러리의 타입 스케일 그 자체입니다. 산문을 card로 감싸지 않고도 페이지가 이 사다리를 쓸 수 있게 합니다. <code>level</code>이 크기와 요소를 한 번에 정합니다.</p>

<Demo src="typography/hero" :min-height="260" />

```tsx
import { PlTypography } from 'plass-ui';

<PlTypography level="h2">A material rather than a theme</PlTypography>;
<PlTypography>Every surface answers one question.</PlTypography>;
```

## Props

<PropsTable name="PlTypography" />

네이티브 `<p>` 속성은 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 전달 대상에서 제외됩니다.

`variant`도, `elevation`도, `size`도 없습니다. `level`이 **곧** 크기입니다 — 그 옆에 `size`가 있으면 `xs`짜리 `h1`을 요청할 수 있게 되는데, 그것은 heading이 아닌 heading입니다.

라이브러리 전체에서 공유 축(`color` `align`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### level

`body`는 `md`에서 `PlCard`의 본문과 같은 사다리에 놓입니다 — 22px 행간에 13px — 그래서 card 안의 문단과 홀로 선 문단이 같은 텍스트입니다. heading은 거기서 장3도쯤씩 올라가고, 커질수록 행간은 좁아집니다. 30px 줄은 13px 줄과 같은 1.7 비율을 원하지 않습니다.

`caption`과 `overline`은 기본적으로 흐립니다. 나머지는 페이지의 잉크를 그대로 씁니다 — 미리 회색이 입혀진 채 도착한 heading은 디자이너가 되돌려야 하는 heading입니다.

<Demo src="typography/levels" :min-height="420">

<<< @/.vitepress/demos/typography/levels.tsx

</Demo>

### render

`level`은 스케일과 요소를 **함께** 정하고, 그것이 보통의 경우입니다. 둘이 달라야 할 때 — 문서 개요에 들어가면 안 되는 소제목, `h3`처럼 보여야 하는 `<p>` — `render`가 그 매듭을 풉니다.

<Demo src="typography/render" :min-height="200">

<<< @/.vitepress/demos/typography/render.tsx

</Demo>

### weight

두 번째 클래스를 쌓는 대신 JavaScript에서 결정되므로, `font-*` 유틸리티는 언제나 정확히 하나만 나옵니다. 같은 specificity의 둘은 생성된 스타일시트에서의 순서로 승부가 갈리고, 거기서는 무엇을 요청했든 `font-semibold`가 `font-normal`을 이깁니다.

<Demo src="typography/weight" :min-height="180">

<<< @/.vitepress/demos/typography/weight.tsx

</Demo>

### lines

한 줄은 `text-overflow: ellipsis`이고, 텍스트는 자기 baseline에 그대로 남습니다. 두 줄 이상은 line-clamp 상자가 필요한데, 그것이 말줄임을 하는 이유는 WebKit이 그렇게 정했기 때문입니다.

<Demo src="typography/lines" :min-height="240">

<<< @/.vitepress/demos/typography/lines.tsx

</Demo>

### color

<Demo src="typography/colors" :min-height="200">

<<< @/.vitepress/demos/typography/colors.tsx

</Demo>

## Accessibility

- `level`이 `h1`~`h6`면 그 heading으로 그려지고, 문서 개요에 들어갑니다. 얼마나 커 보여야 하는지가 아니라 그 구획이 **무엇인지**로 level을 고르고, 둘이 어긋날 때 `render`를 쓰세요.
- `lines`는 시각적으로만 자르고 문자열 전체를 DOM에 남깁니다. 스크린리더도 페이지 내 찾기도 전부를 그대로 받습니다.
- `gutter`는 기본적으로 꺼져 있습니다. margin을 주입하는 컴포넌트는 레이아웃이 싸워야 하는 컴포넌트이고, 간격은 페이지의 결정입니다.
