---
title: PlPageLayout
order: 8
---

# PlPageLayout

<p class="plass-lede">페이지를 걸어 두는 뼈대입니다. header, footer, sidebar 하나 또는 둘, 그리고 그 사이의 콘텐츠. 자기 표면은 아무것도 그리지 않고, 배치와 landmark만 보탭니다.</p>

<Demo src="page-layout/hero" :min-height="360" />

::: fw react

```tsx
import { PlPageLayout } from 'plass-ui';

<PlPageLayout header={<header>…</header>} sidebar={<nav>…</nav>} footer={<footer>…</footer>}>
  {page}
</PlPageLayout>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlPageLayout(
  header: const PlToolbar(child: Text('Acme')),
  sidebar: const SizedBox(width: 200, child: Text('Navigation')),
  footer: const PlToolbar(side: PlassSide.bottom, child: Text('© 2026 Acme')),
  child: page,
);
```

:::

## Props

<PropsTable name="PlPageLayout" />

::: fw react

네이티브 `<div>` 속성은 모두 root로 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 제외됩니다.

:::

::: fw flutter

레이아웃은 받은 공간을 채웁니다 — header, [`Expanded`](https://api.flutter.dev/flutter/widgets/Expanded-class.html) band, footer의 구성이라 높이가 정해진 것 아래에 두세요. 콘텐츠는 scroll view로 감싸지 않습니다. 무엇이 어느 방향으로 스크롤되는지는 `child`에 넣은 것의 몫입니다.

:::

공용 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 무엇을 위한 것인가

landmark입니다. `<div>`만으로 조립한 페이지는 스크린 리더가 구분 없는 영역 하나로 내놓고 검색 엔진도 구분 없는 덩어리 하나로 읽는 페이지입니다. 같은 페이지를 `<header>`, `<nav>`, `<aside>`, `<main>`, `<footer>`로 지으면 목차가 있는 페이지가 됩니다.

그 태그들은 이 컴포넌트가 배치하는 컴포넌트들이 냅니다. 레이아웃 자신이 문서에 보태는 것은 요소 하나, 그리고 `<main>`과 거기로 건너뛰는 링크뿐입니다.

gutter도 measure도 그리지 않습니다. 그건 [`PlContainer`](./container)의 일이고, 안에 하나 넣으면 됩니다 — 그래야 한 route에서는 넓은 대시보드, 다음 route에서는 좁은 글이 될 수 있습니다.

## 예제

### headerSpan · footerSpan

header와 sidebar 중 어느 쪽이 위 모서리를 차지하는지입니다.

`full`은 웹사이트의 배치입니다. 바 하나가 전체 너비를 가로지르고 열은 그 아래에서 시작합니다. `content`는 애플리케이션의 배치입니다. sidebar가 창의 전체 높이를 차지하고 바는 그 사이에 앉아, 사이트가 아니라 화면에 속합니다.

footer는 같은 질문에 따로 답합니다. 전체 높이 내비게이션 레일이 있는 대시보드도 저작권 줄은 보통 레일 아래가 아니라 콘텐츠 아래에 두기 때문입니다.

<Demo src="page-layout/spans" :min-height="260">

::: fw react

<<< @/.vitepress/demos/page-layout/spans.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/page_layout/spans.dart

:::

</Demo>

::: fw react

### scroll · height

`scroll="page"`가 기본값이고, 거의 모든 페이지가 원하는 값입니다. 문서가 스크롤되고, 휴대폰에서 브라우저 주소 표시줄이 숨고, 뒤로 가기에서 스크롤 위치가 복원되고, `sticky` header는 아무것도 밀어내지 않고 자기 자리를 지킵니다.

`scroll="content"`는 레이아웃을 정확히 창 높이로 만들고 바 사이 영역만 스크롤합니다. 페이지가 문서가 아니라 작업 공간일 때 쓰세요.

`height`는 기본이 `viewport`, 페이지가 아닌 레이아웃(미리 보기, 더 큰 도구의 한 pane)에는 `auto`, 그 외에는 아무 CSS 길이나 됩니다. 페이지가 스크롤될 때는 최소 높이, 콘텐츠만 스크롤될 때는 정확한 높이입니다.

<Demo src="page-layout/scroll" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/page-layout/scroll.tsx

</Demo>

:::

::: fw react

### skipLink

기본으로 켜져 있고, 여기서 유일하게 스타일 결정이 아닌 항목입니다. 내비게이션에 링크가 마흔 개 있는 페이지에 도착한 키보드 사용자는 글에 닿기까지 매 페이지마다 마흔 개를 지나야 합니다. 이 링크 하나가 그걸 면하게 해 주고, focus를 받기 전까지는 보이지 않으므로 눈으로 읽는 사람에게는 아무 비용도 들지 않습니다.

`mainId`는 쌍의 양쪽을 함께 바꿉니다 — `<main>`의 `id`와 링크가 가리키는 `href`.

<Demo src="page-layout/skip-link" :flutter="false" :min-height="220">

<<< @/.vitepress/demos/page-layout/skip-link.tsx

</Demo>

:::

### collapseBelow

::: fw react

sidebar가 열이기를 그만두고 drawer가 되는 창 너비입니다. `none`이면 어떤 너비에서도 열로 남고, sidebar가 없는 레이아웃과 이 페이지의 미리 보기들이 그 값을 씁니다.

:::

::: fw flutter

sidebar가 열이기를 그만두고 drawer가 되는 너비입니다. `null`이면 어떤 너비에서도 열로 남고, sidebar가 없는 레이아웃과 이 페이지의 미리 보기들이 그 값을 씁니다.

비교 대상은 창이 아니라 **이 레이아웃이 받은 공간**입니다. media query가 못 하는 것이 이것입니다 — 어떤 pane 안에 든 앱 셸은 창이 아니라 그 pane이 좁을 때 접힙니다.

:::

각 drawer가 열려 있는지도 레이아웃이 쥡니다. route가 바뀔 때 닫을 수 있도록, 앞쪽 열은 `sidebarOpen` / `onSidebarOpenChange`, 뒤쪽 열은 `endSidebarOpen` / `onEndSidebarOpenChange`입니다.

::: fw react

## 바를 어떻게 재는가

자기 자리를 지키는 sidebar는 header 아래에서 시작해야 하는데, 그 높이는 header 말고 아무도 모릅니다. 그래서 레이아웃은 두 바를 재서 창에서 얼마를 가져가는지 자기 root에 씁니다 — `--p-layout-header`와 `--p-layout-footer`, 그리고 각각의 `-inset`.

하나가 아니라 둘인 이유는, 바가 어떻게 배치되었는지에 따라 가져가는 것이 다르기 때문입니다. `sticky` 바는 여전히 흐름 안에 있으므로 자리를 따로 비워 둘 필요가 없지만, 창 위쪽을 늘 가로막고 있으므로 열은 그 아래에서 시작해야 합니다. `fixed` 바는 흐름 밖이므로 페이지가 그 높이를 _비워 둬야_ 합니다. 둘 중 어느 쪽인지는 prop으로 전달받는 대신 요소에서 읽습니다.

등록하지 않은 바는 0으로 남습니다. 측정은 `querySelector`가 아니라 슬롯이 스스로 참여하는 계약이라서, `render={<MyBar />}`로 그려진 바도 그렇지 않은 바만큼 확실하게 찾힙니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `scroll`, `height` | — | 레이아웃은 받은 공간을 채우고, 스크롤되는 것은 `child`에 넣은 것입니다. 영역 대신 스크롤할 문서라는 것이 없습니다. |
| 측정된 `--p-layout-*` 속성 | — | `Column`이 이미 그 산수를 끝냈습니다. header 아래의 band는 정확히 header가 남긴 만큼이라 잴 것이 없습니다. |
| 창 너비 기준의 `collapseBelow` | 이 레이아웃 자신의 너비 기준 | `LayoutBuilder`는 레이아웃이 받은 constraints를 봅니다. media query는 창만 봅니다. |
| `'none'` | `null` | "정해 둔 하한이 없다"를 Dart가 말하는 방식입니다. |
| `skipLink`, `skipLabel`, `mainId` | — | 건너뛰기 링크는 fragment로 가는 링크입니다. fragment가 없고, 순회 순서도 문서가 아니라 semantics 트리의 것입니다. |
| `mainProps`, `color` | `mainSemanticLabel` | React 빌드가 `<main>`에 얹던 것 중 여기에 대응하는 것은 이름뿐입니다. 레이아웃은 아무것도 칠하지 않으므로 나를 색도 없습니다. |
| `defaultSidebarOpen` | — | uncontrolled가 기본입니다. `sidebarOpen`을 빼면 레이아웃이 닫힌 상태로 시작해 상태를 쥡니다. |
| `children` | `child` | Flutter의 이름입니다. |

:::

## 접근성

::: fw react

- children은 진짜 `<main>` 안에 들어가고, 그것이 `main` landmark입니다. 페이지당 정확히 하나여야 하며, 그걸 보장하는 것이 레이아웃입니다.
- 건너뛰기 링크는 문서의 맨 앞이고, 숨겨지는 대신 1px로 잘려 있어서 Tab 키가 찾을 수 있습니다. `hidden`이면 화면과 함께 접근성 트리에서도 사라져 tab할 것이 남지 않습니다.
- `<main>`에는 `tabindex`를 주지 않습니다. 거기로 건너뛰는 것은 읽는 위치를 옮기는 일이고 그게 핵심입니다. focus 가능하게 만들면 모든 페이지에 tab stop이 하나 늘어납니다.
- 이름 붙일 영역이 둘 이상인 페이지라면 `aria-label`은 `mainProps`에 넣습니다.
- 레이아웃 자체는 어떤 role도 주장하지 않습니다. `<div>` 하나를 보탤 뿐이고, landmark는 안에 든 컴포넌트들이 그리는 태그에서 나옵니다.

:::

::: fw flutter

- 콘텐츠는 `SemanticsRole.main`으로 감싸집니다. 반대쪽의 `<main>` 요소가 하는 것과 같은 주장입니다 — 여기가 chrome이 아닌 부분이라는 것.
- 이름 붙일 영역이 둘 이상인 화면이라면 `mainSemanticLabel`이 그 영역의 이름입니다. 없으면 안에 든 것으로 불립니다.
- 레이아웃은 그 밖에 아무것도 주장하지 않습니다. 나머지 이름은 안에 든 컴포넌트들에서 나옵니다.

:::
