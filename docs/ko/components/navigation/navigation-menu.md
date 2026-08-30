---
title: PlNavigationMenu
order: 4
---

# PlNavigationMenu

<p class="plass-lede">사이트의 내비게이션입니다. 목적지의 행이고, 그중 일부는 더 많은 목적지가 든 패널을 엽니다. 모든 행이 진짜 링크이고, 이것이 menu가 아닌 이유가 전부 거기 있습니다.</p>

<Demo src="navigation-menu/hero" :min-height="200" />

::: fw react

```tsx
import { PlNavigationMenu, PlNavigationMenuItem, PlNavigationMenuLink } from 'plass-ui';

<PlNavigationMenu>
  <PlNavigationMenuItem label="Product" columns={2}>
    <PlNavigationMenuLink href="/analytics" title="Analytics" description="Numbers over time" />
  </PlNavigationMenuItem>
  <PlNavigationMenuItem label="Pricing" href="/pricing" />
</PlNavigationMenu>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlNavigationMenu(
  items: <PlNavigationMenuItem>[
    PlNavigationMenuItem(
      label: 'Product',
      columns: 2,
      links: <PlNavigationMenuLink>[
        PlNavigationMenuLink(title: 'Analytics', onPressed: openAnalytics),
      ],
    ),
    PlNavigationMenuItem(label: 'Pricing', onPressed: openPricing),
  ],
);
```

:::

## Props

<PropsTable name="PlNavigationMenu" />

::: fw react

네이티브 `<nav>` 속성은 모두 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라, `defaultValue`와 `onChange`는 value와 `onValueChange`로 표기하기 때문에 제외됩니다.

:::

### PlNavigationMenuItem

<PropsTable name="PlNavigationMenuItem" />

### PlNavigationMenuLink

<PropsTable name="PlNavigationMenuLink" />

공용 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## PlMenu가 아닙니다

차이는 행이 **무엇이냐**입니다.

[`PlMenu`](./menu)는 액션을 담습니다. 행은 `menuitem`이고, 전체가 화살표 키를 가두는 위젯이며, 하나를 고르면 닫힙니다.

이것은 **링크**를 담습니다. 진짜 `<a>`로 채워진 `<nav>`이고, 그것이 브라우저의 링크 목록, 포인터 아래 상태 표시줄, 가운데 클릭 메뉴, 크롤러의 색인에 그것들을 올립니다. 클릭 핸들러가 달린 `<div>`인 목적지는 그중 어디에도 없습니다.

행이 무언가를 _하면_ menu를, 행이 어딘가로 _가면_ 이것을 쓰세요.

## 예제

### 링크인 항목, 여는 항목

`href`만 있고 children이 없는 항목은 링크입니다. children이 있는 항목은 trigger와 패널입니다.

차이는 겉모습이 아닙니다. 앞의 것은 목적지로, 뒤의 것은 펼쳐지는 것으로 알려지므로, 스크린 리더가 둘 중 무엇을 누르려는지 미리 말해 줍니다.

<Demo src="navigation-menu/states" :min-height="180">

::: fw react

<<< @/.vitepress/demos/navigation-menu/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/navigation_menu/states.dart

:::

</Demo>

### columns

패널이 링크를 몇 열로 배치할지입니다. [`PlNavigationMenuLink`](#plnavigationmenulink)가 한 행이고, `title`과 그 아래의 muted `description`, 그리고 앞의 글리프를 가질 수 있습니다.

한 번에 하나의 패널만 열려 있고, 닫혔다 다시 열리는 대신 항목 사이를 **크기를 바꾸며 이동**합니다. 행을 가로지르는 것이 셋이 아니라 하나의 표면으로 읽히는 이유가 그것입니다.

<Demo src="navigation-menu/columns" :min-height="200">

::: fw react

<<< @/.vitepress/demos/navigation-menu/columns.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/navigation_menu/columns.dart

:::

</Demo>

### orientation

`vertical`은 패널이 아래가 아니라 옆으로 열리는 nav rail입니다. 화살표 키는 어느 쪽이든 따라갑니다.

<Demo src="navigation-menu/orientation" :min-height="200">

::: fw react

<<< @/.vitepress/demos/navigation-menu/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/navigation_menu/orientation.dart

:::

</Demo>

### 행에는 표면이 없습니다

쉬고 있을 때 항목은 페이지 자신의 단어입니다. 채움도, 가장자리도, 그림자도 없습니다. 사이트 위쪽을 가로지르는 테두리 상자 다섯 개는 내비게이션이 아니라 툴바이고, 내비게이션은 손이 갈 때까지 글자로 읽혀야 합니다.

색 계열은 포인터와 함께, 그리고 열린 패널과 함께 도착합니다. 시트 자체에는 색이 들어가지 않습니다 — 패널은 [`PlMenu`](./menu)와 [`PlPopover`](../feedback/popover)가 그리는 것과 같은 서리 유리입니다.

### 다른 곳에서 열리는 링크

항목의 `target`은 `<a>`에서 하는 일을 그대로 하고, 이 탭이 아닌 곳으로 열리면 요청된 `rel`에 `noopener noreferrer`가 **합쳐집니다**.

대체가 아니라 합침입니다. `rel`을 손으로 쓰는 흔한 이유는 `nofollow`나 `sponsored`인데, 그것을 덮어쓰기로 적으면 다른 곳에서 열리는 링크의 보호가 조용히 사라집니다.

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| 항목과 링크의 `href` | `onPressed` | 이 패키지에는 navigator도, 해석할 주소도 없습니다. 목적지가 *어디인지*는 앱 자신의 라우터의 몫입니다. |
| 조합된 `PlNavigationMenuItem` 자식 | 데이터인 `items: List<PlNavigationMenuItem>` | 한 번에 하나의 패널만 열어 두려면 행이 어느 항목이 어느 것인지 알아야 하고, 셀 수 있는 것이 리스트입니다. |
| `value` / `defaultValue` | `initialValue` | `String?`으로는 "호출자가 말하지 않았다"와 "닫혔다고 말했다"를 구분할 수 없어서, controlled 모드는 바깥에서 닫을 수 없는 모드가 됩니다. 어느 패널이 열려 있는지는 앱이 아니라 포인터의 상태입니다. |
| 항목 사이에서 크기가 바뀌는 하나의 패널 | 항목마다 하나씩, 페이드 | 크기 변화는 Base UI가 나가는 패널과 들어오는 패널을 재어 그 사이를 애니메이션하는 것입니다. 여기서는 각 항목이 자기 팝업을 앵커하므로, 행을 가로지르면 패널이 자라는 대신 바뀝니다. |
| `target`과 합쳐지는 `rel` | — | 앵커가 없으니 지킬 `rel`도 없습니다. |
| `<nav>` landmark | `SemanticsRole.navigation` | 프레임워크 자신의 이름으로 된 같은 landmark입니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 class 목록도 style 속성도 없습니다. |

:::

## 접근성

- 진짜 `<a>`로 채워진 진짜 `<nav>`입니다. 이 컴포넌트의 주장이 전부 그것이고, 아래의 모든 것이 거기서 따라 나옵니다.
- 키보드는 Base UI의 것입니다. 화살표 키가 행을 따라 움직이고, <kbd>Enter</kbd>와 <kbd>Space</kbd>가 패널을 열고, <kbd>Esc</kbd>가 닫으며 focus는 trigger로 돌아가고, <kbd>Tab</kbd>이 열린 패널의 링크로 들어갑니다.
- trigger는 `aria-expanded`를 보고하므로, 누르면 무엇이 일어날지 미리 알려집니다.
- `disabled` 항목은 단어를 행에 남기고 아무것도 열지 않습니다. 색을 바꾸는 대신 흐려지는데, 라이브러리 전체에서 `disabled`가 그렇게 보입니다.
- 팝업은 `<body>` 끝으로 portal되고 positioner가 `.plass-portal`을 지닙니다. CSS reset을 범위 지정한 호스트가 같은 reset을 거는 자리가 그것입니다.
- 패널이 미끄러지는 대신 셰브런이 돕니다. 여기서 포인터 아래에서 움직이는 것은 없습니다.
