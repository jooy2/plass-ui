---
title: PlHeader
order: 9
---

# PlHeader

<p class="plass-lede">페이지 위쪽을 가로지르는 바입니다. 한쪽 끝에 브랜드, 다른 쪽 끝에 action, 가운데에는 그 자리에 맞는 것. 진짜 <code>&lt;header&gt;</code>이고, 그래서 banner landmark가 됩니다.</p>

<Demo src="header/hero" :min-height="140" />

::: fw react

```tsx
import { PlButton, PlHeader } from 'plass-ui';

<PlHeader brand={<Logo />} actions={<PlButton size="sm">Sign in</PlButton>}>
  <Nav />
</PlHeader>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlHeader(
  brand: const <Widget>[Text('Acme')],
  actions: <Widget>[PlButton(onPressed: signIn, child: const Text('Sign in'))],
  child: navigation,
);
```

:::

## Props

<PropsTable name="PlHeader" />

::: fw react

네이티브 `<header>` 속성은 모두 그대로 전달됩니다. `color`와 `title`은 여기서 Plass의 prop이라 제외됩니다.

:::

::: fw flutter

`brand`와 `actions`는 위젯 하나가 아니라 리스트입니다. 슬롯이 곧 행이기 때문입니다 — 로고와 그 옆 이름 사이의 간격은 바가 정합니다. `PlToolbar`도 양 끝을 같은 모양으로 씁니다.

:::

공용 축(`variant` `size` `color` `density` `elevation`)이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 태그만 바꾼 PlToolbar가 아닙니다

[`PlToolbar`](../surfaces/toolbar)는 화면 어디에나 놓이는 컨트롤의 행이고, 높이는 padding만으로 정해집니다. header는 페이지의 **banner**입니다. 높이 하한, measure, brand 슬롯, 그리고 [`PlPageLayout`](./page-layout) 안의 자리를 갖는데, 표 옆에 놓인 컨트롤 행에는 그중 어느 것도 뜻이 없습니다.

가진 것이 컨트롤이면 toolbar를, 가진 것이 페이지의 꼭대기면 이것을 쓰세요.

## 예제

### 세 슬롯

`brand`, `children`, `actions` 순서입니다. 하위 컴포넌트가 아니라 prop인 이유는 [`PlCard`](../surfaces/card)와 같습니다 — 배치는 정해져 있고, 호출하는 쪽이 정하는 것은 각 자리에 무엇이 들어가느냐입니다.

비어 있는 슬롯은 아무것도 그리지 않습니다. brand만 있는 header는 영역 셋이 아니라 하나입니다.

### align

가운데가 어디에 앉는지입니다. `start`는 brand 쪽으로 붙이고 기본값이며, `end`는 actions 쪽으로 붙입니다.

설명할 값어치가 있는 것은 `center`입니다. _남은_ 공간의 가운데에 두면 brand가 끝나는 자리에 따라 위치가 정해져서, 로고가 한 글자 길어지면 내비게이션이 움직입니다. 같은 사이트의 두 페이지 사이에서 독자가 정확히 알아채는 것이 그것입니다. 그래서 양 끝에 같은 몫을 주고, 그러면 안에 무엇이 있든 가운데는 바 자신의 중심선에 놓입니다. 비어 있는 끝도 자기 절반을 차지합니다.

<Demo src="header/align" :min-height="240">

::: fw react

<<< @/.vitepress/demos/header/align.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/header/align.dart

:::

</Demo>

::: fw react

### position

기본은 `sticky`입니다. 페이지가 거기까지 스크롤되면 바가 창 위쪽에 붙고, 흐름 안에 남아 있으므로 아래의 무엇도 밀어낼 필요가 없습니다.

`fixed`는 흐름 밖으로 완전히 빼냅니다. `PlPageLayout` 안이라면 레이아웃이 바의 높이를 대신 비워 둡니다. `static`은 페이지와 함께 스크롤되어 지나가게 둡니다.

<Demo src="header/position" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/header/position.tsx

</Demo>

:::

### variant

세 재질을 **컨테이너**로 읽은 것입니다. 바에는 색이 들어가지 않습니다. 위에 얹히는 것 — chip, button, avatar — 이 자기 색을 갖고 오기 때문에, 색이 든 시트는 그 모두를 자기가 고려되지 않은 배경 위에 올려놓게 됩니다.

`divider`는 기본으로 켜져 있고, 실제로 바를 콘텐츠에서 떼어 놓는 것이 그것입니다. 스크롤되는 페이지 위에 고정된 반투명 시트는 아래로 늘 내용이 지나가는데, 가장자리를 표시하는 것이 없으면 그 일부처럼 읽힙니다.

<Demo src="header/variants" :min-height="240">

::: fw react

<<< @/.vitepress/demos/header/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/header/variants.dart

:::

</Demo>

### size

바의 하한은 같은 `size`의 컨트롤에 위아래 공기를 더한 것입니다. `md`는 64px이고, 40px 컨트롤에 양쪽 12px입니다. 높이가 아니라 하한이므로, 내용이 줄바꿈되는 바는 커지면서 padding을 유지합니다.

`density`는 라이브러리의 다른 곳과 똑같이 gutter만 옮깁니다.

<Demo src="header/sizes" :min-height="380">

::: fw react

<<< @/.vitepress/demos/header/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/header/sizes.dart

:::

</Demo>

### maxWidth

시트는 창을 가로지른 채로, 슬롯의 행만 measure에 맞춰 가운데 둡니다. 넓은 화면의 사이트 헤더가 거의 언제나 원하는 것입니다.

[`PlContainer`](./container)의 `maxWidth`와 같은 `rem` 사다리(`xs` 30 · `sm` 40 · `md` 48 · `lg` 64 · `xl` 80)이므로, 로고와 그 아래 페이지의 첫 문단이 거의 같은 두 줄이 아니라 하나의 선 위에 놓입니다.

<Demo src="header/measure" :min-height="200">

::: fw react

<<< @/.vitepress/demos/header/measure.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/header/measure.dart

:::

</Demo>

### PlPageLayout 안에서

::: fw react

header는 레이아웃에 자신을 등록하고, 레이아웃은 그것을 재서 창에서 얼마를 가져가는지 자기 root에 씁니다. 자기 자리를 지키는 sidebar가, 그 높이를 바 말고는 아무도 모르는 바 아래에서 시작할 수 있는 이유가 그것입니다.

이를 위해 넘겨야 할 것은 없습니다. 레이아웃 밖에서는 등록이 아무 데도 가지 않고, 바는 그냥 바입니다.

:::

::: fw flutter

넘겨야 할 것도, 재야 할 것도 없습니다. 레이아웃의 `Column`이 이미 header가 가져가지 않은 만큼을 band에 남겨 두었으므로, 그 옆의 sidebar는 구조상 바 아래에서 시작합니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `position` | — | `fixed`나 `sticky`는 무언가를 기준으로 삼아야 합니다. 위젯은 화면이 두는 자리에 정확히 놓이고, 고정되어야 하는 바는 화면 자신의 레이아웃에 속합니다. |
| 레이아웃에 등록 | — | `Column`이 이미 그 산수를 끝냈습니다. 어디에도 쓸 높이가 없습니다. |
| 노드 하나인 `brand`, `actions` | `List<Widget>` | 슬롯이 곧 행이고, 그 안의 간격은 바가 정합니다. `PlToolbar`와 같은 모양입니다. |
| `maxWidth: 'none'` | `maxWidth: null` | "measure를 정하지 않았다"를 Dart가 말하는 방식입니다. |
| `<header>`, `banner` landmark | `semanticLabel`과 `region` role | Flutter semantics에는 `banner` role이 없습니다. 이름이 있는 바는 region이고, 이름이 없으면 아무것도 주장하지 않습니다 — 라벨 없는 region은 아무것도 설명하지 못하기 때문입니다. |
| `label` | `semanticLabel` | Flutter의 이름이고, 여기서는 하나를 더 합니다 — 바를 landmark로 만드는 것이 그것입니다. |
| `render` | — | 바꿀 태그가 없습니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 class 목록도 style 속성도 없습니다. |

:::

## 접근성

::: fw react

- 진짜 `<header>`를 그립니다. 문서의 최상위에서 그것은 `banner` landmark이고, 스크린 리더의 landmark 목록, 리더 모드, 검색 엔진이 모두 그것을 읽습니다.
- `label`이 바의 이름입니다. 페이지에 두 개가 있을 때 써 둘 값어치가 있습니다. "banner"가 두 번 나오면 어느 쪽이 어느 쪽인지 전혀 알려 주지 못하기 때문입니다.
- 바는 `role="toolbar"`도 `role="navigation"`도 주장하지 않습니다. 앞의 것은 구현하지 않은 키보드 동작에 대한 약속이고, 뒤의 것은 호출하는 쪽이 가운데 슬롯에 넣는 `<nav>`의 몫입니다.
- 슬롯은 배치되지만 순서가 바뀌지는 않으므로, 읽는 순서는 쓴 순서 그대로입니다.

:::

::: fw flutter

- `semanticLabel`이 바의 이름이고, 그것이 바를 `region` landmark로 만듭니다. 이름이 없으면 바는 아무것도 주장하지 않는데, 의도된 것입니다. Flutter는 라벨 없는 region을 거부합니다 — 이름 붙일 수 없는 landmark는 건너뛸 수도 없는 landmark이기 때문입니다.
- 대신 주장할 `banner` role은 없습니다. 이름 있는 region이 가장 참에 가까운 것이고, 프레임워크에 없는 role을 주장하는 것은 아무것도 주장하지 않는 것보다 나쁩니다.
- 바는 toolbar semantics를 주장하지 않습니다. 구현하지 않은 키보드 동작에 대한 약속이기 때문입니다.
- 슬롯은 배치되지만 순서가 바뀌지는 않으므로, 순회 순서는 쓴 순서 그대로입니다.

:::
