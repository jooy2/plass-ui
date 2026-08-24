---
title: PlAvatar
order: 6
---

# PlAvatar

<p class="plass-lede">사람이나 사물의 사진을 정해진 크기로 놓되, 절대 빈 상자가 되지 않습니다. 사진이 없으면 이니셜이, 이니셜도 없으면 실루엣이 그려집니다.</p>

<Demo src="avatar/hero" :min-height="140" />

```tsx
import { PlAvatar } from 'plass-ui';

<PlAvatar name="Ada Lovelace" src="/portrait-1.svg" />;
<PlAvatar name="Ada Lovelace" />;
```

## Props

<PropsTable name="PlAvatar" />

네이티브 `<span>` 속성은 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 전달 대상에서 제외됩니다.

`density`는 없습니다 — avatar에는 좁힐 여백이 없습니다. 자체 상태 점도 가지지 않습니다. 초록 점이 붙은 avatar는 avatar를 담은 [`PlBadge`](./badge)입니다.

라이브러리 전체에서 공유 축(`variant` `size` `color` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### 폴백

그려질 수 있는 것은 세 가지이고, 한 번에 정확히 하나입니다. `src`가 주어졌고 로드되면 사진, 아니면 그 자리를 대신하는 것 — `children`, `initials`, 또는 `name`에서 파생한 이니셜 — 그리고 그 셋 다 없으면 실루엣.

어느 것이 보일지는 Base UI의 `Avatar`가 정합니다. "이미지가 로드됐는가"는 답이 넷이고 중간에 race가 끼어 있는 질문이기 때문입니다.

파생 규칙은 첫 단어의 첫 글자와 마지막 단어의 첫 글자입니다 — "Jane Doe"는 `JD`. 단어가 하나면 글자도 하나인데, 한국어·일본어·중국어 이름의 두 글자는 40px에서 얼룩이고 한 글자는 이름이기 때문입니다.

<Demo src="avatar/fallback" :min-height="180">

<<< @/.vitepress/demos/avatar/fallback.tsx

</Demo>

### variant

avatar는 색을 입는 **대상 자체**입니다 — 특정한 한 사람의 초상이므로, `PlAlert`이 그렇듯 시트가 틴트를 받습니다. `PlCard`와는 다릅니다.

기본값이 `solid`가 아니라 `ghost`인 것은 `PlButton`과 정반대입니다. 디렉터리는 avatar로 가득한 페이지이고, 채도 높은 원으로 가득한 페이지에서는 아무도 이름을 읽어 내지 못합니다.

<Demo src="avatar/variants" :min-height="120">

<<< @/.vitepress/demos/avatar/variants.tsx

</Demo>

### shape

기본값은 `circle`입니다. 초상이라는 것이 있어 온 내내 초상은 그런 모양이었습니다. `square`는 대신 라이브러리 자신의 필렛을 씁니다. 로고나 저장소 아이콘이 원하는 모양이 그것입니다 — 그런 그림은 사각형 가장자리까지 그려져 있어서 원형 크롭이 잘라먹습니다.

<Demo src="avatar/shapes" :min-height="120">

<<< @/.vitepress/demos/avatar/shapes.tsx

</Demo>

### size

컨트롤 높이와 같은 사다리라, 툴바에서 avatar와 그 옆 버튼이 같은 baseline에 놓입니다.

<Demo src="avatar/sizes" :min-height="120">

<<< @/.vitepress/demos/avatar/sizes.tsx

</Demo>

### color

<Demo src="avatar/colors" :min-height="120">

<<< @/.vitepress/demos/avatar/colors.tsx

</Demo>

### 겹쳐 쌓기

`PlAvatarGroup`은 없습니다. 쌓기는 음수 margin과 ring일 뿐이고, 얼마나 겹칠지와 ring을 무엇에 대고 그릴지는 둘 다 컴포넌트가 아니라 페이지의 몫입니다.

<Demo src="avatar/group" :min-height="120">

<<< @/.vitepress/demos/avatar/group.tsx

</Demo>

## Accessibility

- 사진은 `alt`를 받고, 없으면 `name`, 그것도 없으면 **빈** `alt`를 씁니다. 비우는 것과 빼는 것은 다릅니다 — 행 안에서 사람 이름 옆에 놓인 avatar는 장식이고, `alt`를 아예 빼면 스크린리더가 파일 이름을 읽습니다.
- `JD`를 소리 내 읽으면 사람이 아니라 글자 두 개입니다. 이름이 있으면 그것이 폴백의 접근 가능한 이름이 되고, 이니셜은 그것이 대신하고 있는 그림으로 남아 숨겨집니다.
- 실루엣은 아무 말도 하지 않습니다. 읽을 이름이 없고, "그래픽"은 정보가 아닙니다.
- 링크나 버튼이기도 한 avatar는 진짜 그것이어야 합니다. 진짜 `<a>`나 `<button>` 안에 넣고, 이름은 그 요소에 주세요.
