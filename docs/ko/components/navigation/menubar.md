---
title: PlMenubar
order: 6
---

# PlMenubar

<p class="plass-lede">애플리케이션 위쪽의 단어 띠입니다 — File, Edit, View — 각각이 메뉴를 엽니다. 하나가 열린 뒤 띠를 가로지르면, 떠나온 것이 닫히는 대신 다른 메뉴들을 걸어서 지납니다.</p>

<Demo src="menubar/hero" :flutter="false" :min-height="140" />

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

## Props

<PropsTable name="PlMenubar" />

::: fw react

네이티브 `<div>` 속성은 모두 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 제외됩니다.

:::

### PlMenubarMenu

<PropsTable name="PlMenubarMenu" />

공용 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 무엇이 이것을 바로 만드는가

겉모습이 아닙니다. 따로 놓인 [`PlMenu`](./menu) 여러 개도 똑같이 보이지만, 중요한 한 가지에서 다르게 굽니다. 하나가 열린 상태에서 포인터를 다음 단어로 옮기면, 앞의 것이 닫히고 아무것도 열리지 않습니다.

바에서는 띠를 가로지르면 메뉴들을 걸어서 지나가고, 화살표 키가 메뉴 안에서만이 아니라 메뉴 사이에서도 움직이며, 전체가 접근성 트리에서 하나의 `menubar`입니다. 전부 Base UI의 것입니다.

## 같은 메뉴입니다

`PlMenubarMenu`는 [`PlMenu`](./menu)가 받는 행들을 그대로 받습니다 — `PlMenuItem`, `PlMenuSeparator`, `PlMenuGroup`, `PlMenuSubmenu`, `PlMenuCheckboxItem`, `PlMenuRadioItem`. trigger만 다른 같은 메뉴이기 때문입니다.

받지 **않는** 것은 `size`, `color`, `density`입니다. 셋은 바의 것입니다. 축을 한 번 정해 띠 위의 모든 메뉴에 적용할 수 있는 유일한 자리이고, 세 번째 메뉴만 크기가 다른 바는 바가 아닙니다.

<Demo src="menubar/rows" :flutter="false" :min-height="140">

<<< @/.vitepress/demos/menubar/rows.tsx

</Demo>

## 예제

### size

띠는 매 단계에서 컨트롤 사다리보다 한 칸 **아래**에 앉고, `density="default"`에서도 compact 여백 트랙을 씁니다.

둘 다 같은 결정입니다. 메뉴 바는 *단어*의 띠이고, 보통 이미 자기 높이를 가진 것 안에 들어갑니다 — [`PlToolbar`](../surfaces/toolbar), [`PlHeader`](../layout/header). 컨트롤 크기로 잡으면 `File Edit View`가 버튼 세 개가 되고, 바가 자기가 얹힌 것보다 높아집니다.

<Demo src="menubar/sizes" :flutter="false" :min-height="240">

<<< @/.vitepress/demos/menubar/sizes.tsx

</Demo>

### orientation

`vertical`은 메뉴가 옆으로 늘어선 레일의 모양입니다. 화살표 키는 어느 쪽이든 따라갑니다.

<Demo src="menubar/orientation" :flutter="false" :min-height="200">

<<< @/.vitepress/demos/menubar/orientation.tsx

</Demo>

### 표면을 그리지 않습니다

메뉴 바는 무언가 _위에_ 앉습니다. 이미 시트 위에 있는 띠 아래에 또 시트를 두면 시트가 둘입니다. 바가 보태는 것은 flex row 하나와 색 슬롯 넷, 그게 전부입니다.

열린 메뉴는 색으로만 표시됩니다 — 단어가 움직이지 않고 띠의 높이가 바뀌지 않습니다. 포인터 아래에서 라이브러리의 모든 컨트롤이 따르는 같은 규칙입니다.

## 접근성

- 띠는 진짜 `menubar`이고 각 단어는 `aria-expanded`를 보고하는 `menuitem`입니다.
- 화살표 키가 바를 따라, 그리고 열린 메뉴 안으로 움직입니다. <kbd>Esc</kbd>가 닫고 focus를 그 단어로 되돌립니다. `loopFocus`가 양 끝에서 도는지 정합니다.
- `modal`은 기본으로 켜져 있어서, 열린 메뉴가 포인터가 말을 거는 대상이 됩니다. 뒤의 페이지는 닫힐 때까지 inert입니다.
- 단어의 focus ring은 **안쪽**으로 그려집니다. 띠의 항목들은 서로 머리카락 하나 거리이고, 바깥에 그린 링은 이웃과 겹칩니다.
- `disabled` 메뉴는 단어를 바에 남기고 아무것도 열지 않습니다. 바의 `disabled`는 모든 메뉴에 한 번에 그렇게 합니다.
