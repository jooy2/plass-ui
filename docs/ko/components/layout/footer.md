---
title: PlFooter
order: 8
---

# PlFooter

<p class="plass-lede">페이지 끝의 시트입니다. 진짜 <code>&lt;footer&gt;</code>이고, 그래서 글의 연장이 아니라 사이트 자신의 정보가 됩니다. 슬롯은 하나도 없습니다 — 푸터의 내용은 아무도 대신 짐작할 수 없기 때문입니다.</p>

<Demo src="footer/hero" :flutter="false" :min-height="280" />

::: fw react

```tsx
import { PlFooter } from 'plass-ui';

<PlFooter>
  <p>© 2026 Acme</p>
</PlFooter>;
```

:::

## Props

<PropsTable name="PlFooter" />

::: fw react

네이티브 `<footer>` 속성은 모두 그대로 전달됩니다. `color`와 `title`은 여기서 Plass의 prop이라 제외됩니다.

:::

공용 축(`variant` `size` `color` `density` `elevation`)이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 슬롯이 없고, 그게 핵심입니다

[`PlHeader`](./header)에는 셋이 있습니다. header의 영역은 brand · 가운데 · actions로 정해진 배치이고, 같은 사이트의 두 페이지가 어긋나지 않도록 한 번 써 둘 값어치가 있기 때문입니다.

푸터는 그렇지 않습니다. 어떤 사이트에서는 링크 네 열이고, 다음 사이트에서는 저작권 한 줄이며, 세 번째에서는 언어 전환기와 주소입니다. 배치를 짐작한 컴포넌트는 두 사이트 중 하나가 싸우게 되는 컴포넌트라서, 이것은 **시트**만 정합니다 — 표면, gutter, measure, 문서가 끝났다고 말하는 헤어라인, 그리고 바가 손 닿는 곳에 남는지 여부.

## 예제

### position

기본은 `static`이고, header와 정반대입니다. 푸터는 문서의 끝이고 스크롤해서 닿는 것입니다.

`sticky`와 `fixed`는 화면 아래쪽의 다른 종류의 바를 위한 것입니다 — 폼의 저장 줄, 쿠키 알림, 일괄 작업 띠. [`PlPageLayout`](./page-layout) 안에서는 `fixed`가 흐름에서 빼낸 높이를 레이아웃이 대신 비워 두므로, 마지막 문단 위에 올라앉지 않습니다.

<Demo src="footer/position" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/footer/position.tsx

</Demo>

### variant

세 재질을 **컨테이너**로 읽은 것입니다. 시트에는 색이 들어가지 않습니다. 푸터에 얹히는 것은 링크와 글이고, 그것들이 자기 색을 갖고 옵니다.

`divider`는 기본으로 켜져 있고 **위** 가장자리를 긋습니다 — 내용을 마주하는 쪽입니다. 푸터는 바로 위에 무언가가 있고 아래에는 아무것도 없는 페이지의 유일한 시트라, 그 선이 문서가 끝났다고 말하는 전부입니다.

<Demo src="footer/variants" :flutter="false" :min-height="260">

<<< @/.vitepress/demos/footer/variants.tsx

</Demo>

### size

`size`는 *시트*의 크기입니다. gutter와 내용 위아래의 공기이지요. 여기 어느 것도 높이가 아니고 — 푸터는 내용만큼 높습니다 — 타입 스케일도 건드리지 않습니다. 그건 내용이 갖고 옵니다.

`density`는 여백만 옮깁니다.

<Demo src="footer/sizes" :flutter="false" :min-height="380">

<<< @/.vitepress/demos/footer/sizes.tsx

</Demo>

### maxWidth

시트는 창을 가로지른 채로, 내용만 measure에 맞춰 가운데 둡니다. [`PlContainer`](./container)의 `maxWidth`와 같은 `rem` 사다리이므로, 페이지의 마지막 줄과 푸터의 첫 줄이 하나의 선 위에 놓입니다.

<Demo src="footer/measure" :flutter="false" :min-height="200">

<<< @/.vitepress/demos/footer/measure.tsx

</Demo>

## 접근성

- 진짜 `<footer>`를 그립니다. 문서 최상위에서 그것은 `contentinfo` landmark이고, 스크린 리더의 landmark 목록과 리더 모드가 그것을 읽습니다.
- `label`이 바의 이름입니다. 페이지에 둘이 있을 때 — 글 자신의 footer와 사이트의 footer — 써 둘 값어치가 있습니다. 그러지 않으면 landmark 목록이 "contentinfo"를 두 번 내놓습니다.
- `<article>`이나 `<section>` **안**의 footer는 `contentinfo`가 아닙니다. 브라우저는 문서 최상위에서만 그 태그를 승격시킵니다. 이 컴포넌트의 규칙이 아니라 태그 자신의 규칙입니다.
- 링크 열은 자기 이름을 가진 `<nav>`에 담아 footer 안에 넣으세요. footer는 영역의 이름을, `<nav>`는 목록의 이름을 냅니다.
