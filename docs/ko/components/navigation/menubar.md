---
title: PlMenubar
order: 6
---

# PlMenubar

<p class="plass-lede">애플리케이션 위쪽의 단어 띠입니다 — File, Edit, View — 각각이 메뉴를 엽니다. 스크린 리더에게 하나의 덩어리이고, 메뉴는 언제나 하나만 열립니다.</p>

<Demo src="menubar/hero" :min-height="140" />

::: fw react

```tsx
import { PlMenubar, PlMenubarMenu, PlMenuItem } from 'plass-ui';

<PlMenubar>
  <PlMenubarMenu label="File">
    <PlMenuItem shortcut="Mod+N">New</PlMenuItem>
  </PlMenubarMenu>
</PlMenubar>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlMenubar(
  menus: <PlMenubarMenu>[
    PlMenubarMenu(
      label: 'File',
      items: <PlMenuEntry>[PlMenuItem(label: 'New', shortcut: '⌘N')],
    ),
  ],
);
```

:::

## Props

<PropsTable name="PlMenubar" />

::: fw react

네이티브 `<div>` 속성은 모두 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 제외됩니다.

:::

### PlMenubarMenu

<PropsTable name="PlMenubarMenu" />

공용 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 구성

겉모습이 아닙니다. 따로 놓인 [`PlMenu`](./menu) 여러 개도 똑같이 보이지만, 중요한 곳에서 다르게 굽니다. 스크린 리더에게는 단어들이 `menuitem`인 하나의 `menubar`가 아니라 버튼이 늘어선 행이고, 둘이 동시에 열리는 것을 막는 것도 없습니다.

::: fw react

바에서는 띠를 가로지르면 메뉴들을 걸어서 지나가고, 화살표 키가 메뉴 안에서만이 아니라 메뉴 사이에서도 움직입니다. 전부 Base UI의 것입니다.

:::

## PlMenu와 공유하는 것

`PlMenubarMenu`는 [`PlMenu`](./menu)가 받는 행들을 그대로 받습니다 — `PlMenuItem`, `PlMenuSeparator`, `PlMenuGroup`, `PlMenuSubmenu`, `PlMenuCheckboxItem`, `PlMenuRadioItem`. trigger만 다른 같은 메뉴이기 때문입니다.

받지 **않는** 것은 `size`, `color`, `density`입니다. 셋은 바의 것입니다. 축을 한 번 정해 띠 위의 모든 메뉴에 적용할 수 있는 유일한 자리이고, 세 번째 메뉴만 크기가 다른 바는 바가 아닙니다.

<Demo src="menubar/rows" :min-height="140">

<<< @/.vitepress/demos/menubar/rows.tsx

</Demo>

## Examples

### size

띠는 매 단계에서 컨트롤 사다리보다 한 칸 **아래**에 앉고, `density="default"`에서도 compact 여백 트랙을 씁니다.

둘 다 같은 결정입니다. 메뉴 바는 *단어*의 띠이고, 보통 이미 자기 높이를 가진 것 안에 들어갑니다 — [`PlToolbar`](../surfaces/toolbar), [`PlHeader`](../layout/header). 컨트롤 크기로 잡으면 `File Edit View`가 버튼 세 개가 되고, 바가 자기가 얹힌 것보다 높아집니다.

<Demo src="menubar/sizes" :min-height="240">

<<< @/.vitepress/demos/menubar/sizes.tsx

</Demo>

### orientation

`vertical`은 메뉴가 옆으로 늘어선 레일의 모양입니다.

<Demo src="menubar/orientation" :min-height="200">

<<< @/.vitepress/demos/menubar/orientation.tsx

</Demo>

### 표면 없음

메뉴 바는 무언가 _위에_ 앉습니다. 이미 시트 위에 있는 띠 아래에 또 시트를 두면 시트가 둘입니다. 바가 보태는 것은 flex row 하나와 색 슬롯 넷, 그게 전부입니다.

열린 메뉴는 색으로만 표시됩니다 — 단어가 움직이지 않고 띠의 높이가 바뀌지 않습니다. 포인터 아래에서 라이브러리의 모든 컨트롤이 따르는 같은 규칙입니다.

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| 조합된 `PlMenubarMenu` 자식 | 데이터로서의 `menus: List<PlMenubarMenu>` | 바 위의 메뉴는 단어 하나와 행 목록이고, 띠가 셀 수 있는 것은 목록입니다. |
| 띠를 가로지르면 메뉴들을 지나감 | 다른 곳을 누르면 열린 것이 닫힘 | 열린 메뉴의 dismiss 레이어가 포인터와 띠 사이에 있어서, 단어들은 포인터가 도착한 것을 듣지 못합니다. 어느 쪽이든 열리는 것은 하나뿐입니다. |
| `modal`, `loopFocus` | — | inert로 만들 페이지도, 화살표 키가 돌 고리도 없습니다. 열린 메뉴가 이미 포인터를 가져갑니다. |
| 단어의 `aria-expanded` | `expanded`를 단 `SemanticsRole.menuItem` | 같은 상태를 프레임워크의 이름으로 부른 것입니다. 메뉴가 열리면 그것이 접근성 트리가 되므로, 띠는 어느 것이 열렸는지를 색으로도 말합니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::

## Accessibility

- 띠는 진짜 `menubar`이고 각 단어는 펼쳐졌는지를 보고하는 `menuitem`입니다.
- 단어의 focus ring은 **안쪽**으로 그려집니다. 띠의 항목들은 서로 머리카락 하나 거리이고, 바깥에 그린 링은 이웃과 겹칩니다.
- `disabled` 메뉴는 단어를 바에 남기고 아무것도 열지 않습니다. 바의 `disabled`는 모든 메뉴에 한 번에 그렇게 합니다.

::: fw react

- 화살표 키가 바를 따라, 그리고 열린 메뉴 안으로 움직입니다. <kbd>Esc</kbd>가 닫고 focus를 그 단어로 되돌립니다. `loopFocus`가 양 끝에서 도는지 정합니다.
- `modal`은 기본으로 켜져 있어서, 열린 메뉴가 포인터가 말을 거는 대상이 됩니다. 뒤의 페이지는 닫힐 때까지 inert입니다.

:::
