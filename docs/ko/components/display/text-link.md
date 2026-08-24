---
title: PlTextLink
order: 2
---

# PlTextLink

<p class="plass-lede">문장 안에, 또는 홀로 놓이는 링크입니다. 표면도 높이도 없고, 요청하지 않으면 색도 없습니다. 가진 것은 "여기로 간다"는 뜻으로 이미 모두가 아는 표시 하나입니다.</p>

<Demo src="text-link/hero" :min-height="120" />

```tsx
import { PlTextLink } from 'plass-ui';

<PlTextLink href="/pricing">the colour reference</PlTextLink>;
<PlTextLink href="https://www.w3.org/TR/WCAG22/" newTab>
  WCAG 2.2
</PlTextLink>;
```

## Props

<PropsTable name="PlTextLink" />

네이티브 `<a>` 속성은 그대로 전달됩니다. `color`는 위 표의 `color`와 충돌해서 제외됩니다. `rel`은 호출하는 쪽의 값을 덮어쓰지 않고 **합치는** 유일한 항목입니다 — 아래를 보세요.

라이브러리 전체에서 공유 축(`size` `color`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### underline

기본값이 `always`인 이유는 `color`에 있습니다. 링크는 요청하지 않으면 색 계열을 입지 않으므로, 밑줄까지 끄면 주변 문장과 구분할 것이 아무것도 남지 않습니다.

hover는 **글자** 색은 일부러 건드리지 않고 밑줄만 진하게 합니다. 문단 속 링크가 포인터 아래에서 색이 바뀌면, 읽고 있던 줄에서 눈이 끌려 나갑니다.

<Demo src="text-link/underline" :min-height="160">

<<< @/.vitepress/demos/text-link/underline.tsx

</Demo>

### color

라이브러리의 다른 모든 컨트롤과 달리 기본값이 **없습니다**. 이미 색이 칠해진 채로 도착하는 컴포넌트는 페이지가 되돌려야 하는 컴포넌트이고, 문단 속 링크는 보통 그 문단의 색에 밑줄만 그은 것입니다.

<Demo src="text-link/colors" :min-height="100">

<<< @/.vitepress/demos/text-link/colors.tsx

</Demo>

### newTab

창이 바뀌는 것은 링크에서 미리 볼 수 없는 유일한 일입니다. 그래서 `newTab`은 세 가지를 함께 합니다 — `target="_blank"`, 새 페이지가 `window.opener`로 되돌아오지 못하게 막는 `rel`, 그리고 표시. 표시는 눈에는 화살표로, 스크린리더에는 라벨 뒤에 붙는 한 마디로 전달됩니다.

`rel`은 덮어쓰지 않고 합칩니다. 직접 `rel`을 쓰는 흔한 이유는 `nofollow`나 `sponsored`인데 그것은 SEO 결정이고, 단순한 덮어쓰기였다면 새 탭으로 열리는 링크에서 보호 장치가 조용히 사라졌을 것입니다.

### icon

`true`는 `newTab`일 때 상자를 빠져나가는 화살표를, 아니면 체인을 그립니다. `false`는 아무것도 그리지 않고, 노드를 주면 그것이 글리프를 대신합니다. 생략하면 `newTab`을 따릅니다 — 창을 가져가는 링크는 그렇다고 말해야 하고, 조용한 쪽은 호출하는 쪽이 요청해야 합니다.

글리프는 컨트롤 안의 아이콘이 쓰는 `1.2em`이 아니라 `0.95em`으로 놓입니다. 이것은 문장 안에 앉아 있고, 줄 높이만 한 아이콘은 주변 단어들을 벌려 놓습니다.

<Demo src="text-link/icons" :min-height="160">

<<< @/.vitepress/demos/text-link/icons.tsx

</Demo>

### size

이것도 기본값이 없습니다. 문장 속 링크는 그 문장의 크기입니다. 홀로 서는 링크에만 지정하세요.

<Demo src="text-link/sizes" :min-height="200">

<<< @/.vitepress/demos/text-link/sizes.tsx

</Demo>

### render

밑줄과 표시, focus ring을 그대로 둔 채 라우터의 `Link`를 씁니다. `href`도 함께 전달되므로 한 번만 씁니다.

```tsx
import NextLink from 'next/link';

<PlTextLink href="/pricing" render={<NextLink href="/pricing" />}>
  Pricing
</PlTextLink>;
```

## Accessibility

- 진짜 `<a href>`로 렌더링됩니다. 브라우저의 링크 목록에 들어가고, <kbd>Enter</kbd>로 따라가며, 새 탭으로 열거나 주소를 복사할 수 있습니다.
- `newTab`은 그려지기만 하는 것이 아니라 읽힙니다. 화살표는 볼 수 있는 사람에게, 화면에 보이지 않는 문구는 나머지 모두에게 새 탭이라고 말합니다.
- 주된 신호는 밑줄이고, 색이 유일한 신호였던 적은 없습니다. `underline="none"`은 주변이 이미 무엇인지 말해 주는 링크를 위한 것입니다.
- focus ring은 `:focus-visible`에서 나타나고 작은 모서리 반경을 가지므로, 줄 상자 전체가 아니라 라벨을 따라갑니다.
- 컴포넌트의 클래스는 스타일시트에서 두 번 겹쳐 씁니다(`.plass-link.plass-link`). 호스트 페이지의 `.prose a`나 `.vp-doc a`가 링크에서 색과 밑줄을 빼앗아 가지 못하게 하기 위해서입니다.
