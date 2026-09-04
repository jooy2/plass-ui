---
title: PlSidebar
order: 13
---

# PlSidebar

<p class="plass-lede">페이지 콘텐츠 옆의 열이고, 창이 그것을 담기에 너무 좁아지면 drawer가 됩니다. 하나의 패널을 두 모습으로 보여 주므로, 브레이크포인트에서 컴포넌트를 바꿔 끼울 일이 없습니다.</p>

<Demo src="sidebar/hero" :min-height="360" />

::: fw react

```tsx
import { PlPageLayout, PlSidebar } from 'plass-ui';

<PlPageLayout sidebar={<PlSidebar label="Main navigation">{nav}</PlSidebar>}>{page}</PlPageLayout>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlPageLayout(
  sidebar: PlSidebar(semanticLabel: 'Main navigation', child: navigation),
  child: page,
);
```

:::

## Props

<PropsTable name="PlSidebar" />

::: fw react

네이티브 `<aside>` 속성은 모두 그대로 전달됩니다. `color`와 `title`은 여기서 Plass의 prop이라 제외됩니다.

:::

### PlSidebarTrigger

<PropsTable name="PlSidebarTrigger" />

나머지는 전부 [`PlIconButton`](../inputs/icon-button)의 것이고 그대로입니다.

공용 축(`variant` `size` `color` `density` `elevation`)이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 두 모습, 하나의 패널

`collapseBelow` 위에서 sidebar는 레이아웃 안의 `<aside>`이고 콘텐츠가 그 둘레로 배치됩니다. 아래에서는 같은 children이 scrim 위의 [`PlDrawer`](../feedback/drawer)가 되고, focus trap과 <kbd>Esc</kbd>와 trigger로 돌아가는 길이 함께 옵니다.

하나의 컴포넌트인 이유는 하나의 것이기 때문이고, 그래야 children이 어느 쪽에서도 **한 번만** 존재하기 때문입니다. 두 번 그려지면 스크린 리더가 두 번 읽습니다.

둘 중 무엇이 보이는지는 media query이고, 첫 페인트는 CSS가, 그 뒤로는 JavaScript가 답합니다. 이 분담은 의도된 것입니다 — 서버가 보내는 마크업은 열이므로, 좁은 화면은 전체 너비 sidebar를 그렸다가 곧바로 버리게 됩니다. 브레이크포인트 아래에서 그것을 숨기는 클래스가 그걸 막고, 물어볼 창이 생긴 뒤에 drawer가 존재해야 한다고 정하는 것이 `matchMedia`입니다.

## 예제

### side

물리적이 아니라 논리적입니다. `start`는 영어 페이지의 왼쪽이고 아랍어 페이지의 오른쪽입니다. 내비게이션 레일은 어느 쓰기 방향에서든 자기가 속한 글 옆에 있기 때문입니다.

[`PlPageLayout`](./page-layout) 안에서는 sidebar를 어느 슬롯에 넘겼는지가 이미 정하므로, 다시 쓰는 것은 레이아웃과 의견을 달리하는 방법일 뿐입니다.

<Demo src="sidebar/sides" :min-height="260">

::: fw react

<<< @/.vitepress/demos/sidebar/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/sidebar/sides.dart

:::

</Demo>

### collapseBelow

열이 drawer가 되는 창 너비입니다. 기본값은 레이아웃 자신의 `collapseBelow`이고, 레이아웃 밖에서는 `none`입니다 — 되돌릴 방법이 페이지에 없는 채로 접히는 sidebar는 독자가 잃어버린 sidebar이기 때문입니다.

되돌리는 것이 `PlSidebarTrigger`입니다. [`PlHeader`](./header)의 `brand` 슬롯, 로고 앞에 두세요. 30년의 햄버거가 독자에게 거기를 보라고 가르쳐 온 자리입니다. 상태가 아니라 **같은 media query**로 숨겨지므로, 페이지가 도착하고 잠시 뒤에 튀어나오는 대신 서버가 보내는 마크업에 들어 있습니다.

`title`은 sidebar가 drawer일 때만 그려집니다. 열에는 자기가 무엇인지 말해 줄 페이지가 둘레에 있지만, 페이지를 덮은 패널에는 없습니다.

<Demo src="sidebar/collapse" :min-height="300">

::: fw react

<<< @/.vitepress/demos/sidebar/collapse.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/sidebar/collapse.dart

:::

</Demo>

### resizable

기본은 꺼져 있습니다. 크기를 바꿀 수 있는 sidebar는 그 너비가 독자의 것이 된 sidebar라서, 이걸 켜는 쪽은 보통 `onResizeEnd`가 알려 주는 값을 저장하기도 합니다.

끌어서 정해진 너비는 state가 아니라 요소에 곧바로 씁니다. 그 숫자에 의존하는 것은 CSS 선언 하나뿐이고, 포인터가 움직일 때마다 `setState`를 하면 패널의 모든 행이 다시 그려집니다. 호출하는 쪽은 `onResize`로 매 단계를 그대로 듣습니다.

손잡이는 가장자리 안이 아니라 가장자리를 걸치고 있습니다 — 1px 헤어라인은 1px짜리 표적이니까요. 스크롤바가 하는, 그려지는 것과 잡을 수 있는 것 사이의 같은 분리입니다.

<Demo src="sidebar/resizable" :min-height="260">

::: fw react

<<< @/.vitepress/demos/sidebar/resizable.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/sidebar/resizable.dart

:::

</Demo>

### variant

세 재질을 **컨테이너**로 읽은 것입니다. 패널에는 색이 들어가지 않습니다. sidebar에 얹히는 것은 누군가의 내비게이션이고, 그것이 자기 색을 갖고 옵니다.

`divider`는 **안쪽** 가장자리 — 콘텐츠를 마주하는 쪽 — 를 긋습니다. 바깥쪽 가장자리는 창을 향하고 있고, 그 너머에는 구분할 것이 없습니다.

<Demo src="sidebar/variants" :min-height="220">

::: fw react

<<< @/.vitepress/demos/sidebar/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/sidebar/variants.dart

:::

</Demo>

::: fw react

### sticky

기본으로 켜져 있고, 필요 없을 때는 아무 비용도 들지 않습니다. 페이지가 스크롤될 때 열은 `sticky`가 되고 header 아래로 창에 남은 만큼 높아집니다. `--p-layout-header`와 `--p-layout-footer`를 재는 이유가 그것입니다. 콘텐츠만 스크롤될 때는 열이 이미 레이아웃만큼 높으므로 아무것도 달라지지 않습니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| 창 너비 기준의 `collapseBelow`, 기본값은 레이아웃의 것 | 같지만, 레이아웃의 답은 **자기 너비** 기준 | `LayoutBuilder`는 레이아웃이 받은 constraints를 보고, media query는 창만 봅니다. 여기에 값을 주면 창을 재게 되며, 그것이 곧 재정의입니다. |
| `'none'` | `null` | "정해 둔 하한이 없다"를 Dart가 말하는 방식입니다. |
| media query로 숨기는 trigger | 아예 만들지 않는 trigger | 웹에서 그 클래스는 서버가 보내는 마크업에 버튼을 남겨 두기 위한 것입니다. 여기에는 붙들 첫 페인트가 없습니다. |
| `sticky` | — | 열은 레이아웃이 준 band만큼 높습니다. 자리를 지킬 문서 스크롤이라는 것이 없습니다. |
| `aria-label`로 물러나는 `title` | `semanticLabel`로 물러나고 **그려지는** `title` | `PlDrawer`는 자기가 그리는 것으로 불리므로, 영역의 이름이 보이지 않는 라벨이 아니라 제목이 됩니다. |
| `aria-valuenow`를 가진 `role="separator"` 손잡이 | 논리 픽셀 값을 가진 `Semantics(slider: true)` 손잡이 | Flutter semantics에는 separator role도 `valuenow`도 없습니다. 손잡이는 실제로 그것인 것 — 값을 올리고 내릴 수 있는 컨트롤 — 이 됩니다. |
| 요소에 직접 쓰는 너비 | `ValueNotifier`에 담은 너비 | 같은 결정의 다른 철자입니다. 그 숫자에 의존하는 것은 상자 하나뿐이고, 포인터가 움직일 때마다 패널을 다시 지으면 그 안의 모든 행이 다시 지어집니다. |
| `label` | `semanticLabel` | Flutter의 이름입니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 class 목록도 style 속성도 없습니다. |

:::

## 접근성

::: fw react

- 열은 진짜 `<aside>`이고, 그것이 `complementary` landmark입니다.
- `label`은 사실상 필수이고 기본값은 `Sidebar`입니다. sidebar가 둘인 페이지는 각각에 이름을 **반드시** 줘야 합니다. 그러지 않으면 스크린 리더가 "complementary"라는 영역을 둘 내놓습니다.
- 접힌 상태에서는 dialog입니다. focus가 갇히고, <kbd>Esc</kbd>가 닫고, 뒤의 페이지는 inert가 되고, focus는 열었던 것으로 돌아갑니다. 전부 [`PlDrawer`](../feedback/drawer)의 것이고, 그건 Base UI의 것입니다.
- trigger는 `aria-expanded`를 지니므로, 누르기 전에 패널이 열려 있는지 스크린 리더가 먼저 알려 줍니다.
- 크기 조절 손잡이는 `aria-orientation="vertical"`인 `role="separator"`이고, `resizable`인 동안 tab stop이며 <kbd>←</kbd> <kbd>→</kbd>로 움직입니다. 키 누름은 그 자체로 하나의 완결된 제스처이므로 `onResize`와 함께 `onResizeEnd`도 발생시킵니다.
- 드래그는 `preventDefault` 대신 `-webkit-user-select`로 페이지의 텍스트 선택을 거둡니다. WebKit이 구현한 유일한 이름이고, `preventDefault`는 브라우저가 손잡이에 focus를 주는 것까지 막습니다.

:::

::: fw flutter

- 열은 `SemanticsRole.complementary`를 주장합니다. 반대쪽의 `<aside>` 태그가 지니는 것과 같은 landmark입니다.
- `semanticLabel`이 이름이고 기본값은 `Sidebar`입니다. sidebar가 둘인 화면은 각각에 이름을 **반드시** 줘야 합니다. Flutter는 라벨 없이 중복된 landmark를 대놓고 거부합니다.
- 접힌 상태에서는 `PlDrawer`입니다. focus가 갇히고, barrier가 닫고, focus는 열었던 것으로 돌아갑니다.
- 크기 조절 손잡이는 너비를 값으로 갖는 `Semantics(slider: true)`이고, `onIncrease` / `onDecrease`가 화살표 키와 같은 단계에 연결되어 있습니다. 포인터 없이도 스크린 리더가 가장자리를 옮길 수 있습니다.
- trigger는 누르면 무엇이 일어나는지 말해 주는 이름을 가진 진짜 `PlIconButton`입니다.

:::
