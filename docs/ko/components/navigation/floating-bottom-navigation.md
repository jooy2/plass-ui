---
title: PlFloatingBottomNavigation
order: 2
---

# PlFloatingBottomNavigation

<p class="plass-lede">창의 아래 가장자리에서 떠 있는 둥근 목적지 한 줄입니다. 맑은 유리 캡슐 안에 색이 든 유리 키 하나가 올라타 있는 것 — 이 디자인 언어가 자기 문장을 그대로 말하는 자리이고, 거기에 더한 것은 없습니다.</p>

<Demo src="floating-bottom-navigation/hero" :min-height="220" />

::: fw react

```tsx
import { PlFloatingBottomNavigation, PlFloatingBottomNavigationItem } from 'plass-ui';

<PlFloatingBottomNavigation value={where} onValueChange={setWhere} label="Main">
  <PlFloatingBottomNavigationItem value="home" icon={<HomeIcon />}>
    Home
  </PlFloatingBottomNavigationItem>
  <PlFloatingBottomNavigationItem value="search" icon={<SearchIcon />}>
    Search
  </PlFloatingBottomNavigationItem>
</PlFloatingBottomNavigation>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlFloatingBottomNavigation<String>(
  value: where,
  onChanged: (String next) => setState(() => where = next),
  label: 'Main',
  items: const <PlFloatingBottomNavigationItem<String>>[
    PlFloatingBottomNavigationItem<String>(value: 'home', label: 'Home', icon: HomeIcon()),
    PlFloatingBottomNavigationItem<String>(value: 'search', label: 'Search', icon: SearchIcon()),
  ],
);
```

:::

## Props

<PropsTable name="PlFloatingBottomNavigation" />

### PlFloatingBottomNavigationItem

<PropsTable name="PlFloatingBottomNavigationItem" />

::: fw react

바에는 네이티브 `<nav>` 속성이, 항목에는 네이티브 `<button>` 속성이 그대로 전달됩니다.

:::

::: fw flutter

바는 목적지 타입에 대해 제네릭이고 **controlled**이며, 목적지는 위젯이 아니라 설명입니다. [`PlBottomNavigation`](./bottom-navigation)이 내리는 것과 같은 세 결정이고, 이유도 같습니다.

:::

라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## 왜 별도의 컴포넌트인가

[`PlBottomNavigation`](./bottom-navigation)의 나머지 절반이고, 그것의 변형이 아니라 다른 물건입니다.

그 바는 창 가장자리에 **붙어** 있습니다. 전체 너비, 아래로 지나가는 내용에 대한 얇은 선, 홈 인디케이터 아래까지 닿는 시트, 그리고 평평함 — 가장자리에 기대 누운 것은 그 가장자리에 그림자를 드리우지 않습니다. 이쪽은 **페이지의 일부가 아예 아닙니다**. 뒤따르는 모든 것이 그 하나의 차이에서 나옵니다 — 캡슐, 그 아래의 틈, 기본으로 지는 그림자, 그리고 허용되는 알약 모서리.

`floating` boolean 하나가 더 작은 API였겠지만 더 나쁜 API였을 것입니다. 각 바의 prop 절반이 다른 쪽에서는 아무 뜻도 없게 되고, 처음으로 `divider={true} floating`을 쓰는 순간 뒤에 아무 내용도 없는 캡슐 위쪽에 얇은 선이 그어졌을 것입니다.

## Examples

### 원반

모든 목적지는 글리프 하나가 든 원반이고 이름은 그리지 않습니다. 다섯 개짜리 줄이 휴대폰 너비 안에 들어가는 이유가 그것입니다.

`rounded-full`은 라이브러리가 알약을 허용하는 아주 드문 자리 중 하나이고, `PlSegmentedButton`의 홈과 같은 이유로 허용됩니다 — 이것은 페이지 위에 놓인 시트가 아니라 페이지에서 떨어져 떠 있는 물건입니다. 하우스의 필렛은 모서리를 깎은 시트에 대한 것이고, 아무것에도 놓여 있지 않은 시트에는 깎을 모서리가 없습니다.

현재 목적지는 맑은 시트 안에 올라탄 **색이 든 유리** 키입니다. 나머지는 포인터가 올 때까지 아무 표면도 갖지 않습니다.

### 키는 이동합니다

키는 **하나의 요소**입니다. 현재인 원반에서 치수를 재고, [`PlSegmentedButton`](../inputs/segmented-button)의 타일과 같은 방식으로 원반 사이를 애니메이션합니다. 한 원반에서 칠이 나타나는 동안 다른 원반에서 칠이 사라지는 것이 아닙니다. 두 원반이 크로스페이드하는 것은 물건 두 개이고, 키가 든 바에는 물건이 하나뿐입니다 — 그 키가 어디로 가는지가 이 컴포넌트가 말하려는 전부입니다.

아무것도 변형되지 않습니다. 키는 자기 `left`·`top`·`width`·`height`로 움직이는 빈 상자여서, 이동하는 동안 줄 안의 어떤 글리프도 다시 샘플링되지 않습니다. 컨트롤을 움직이지 않는다는 하우스 규칙이, 무언가 움직이는 것이 존재 이유인 컴포넌트에서도 그대로 살아남습니다.

첫 배치는 어떻게 요청되었든 즉시입니다. 막 마운트된 키에는 _출발할_ 자리가 없으므로, 바가 처음 열리는 목적지는 캡슐 왼쪽 가장자리에서 날아 들어오는 대신 자기 원반 아래에 그냥 나타납니다.

### 이름

`children`은 실질적으로 필수이고 **절대 그려지지 않습니다**. 글리프 하나가 든 원반에는 접근 가능한 이름이 전혀 없고, 이름 없는 글리프의 줄은 `PlIconButton`의 `label`이 불가능하게 만들려는 바로 그 결함입니다 — 여기서도 똑같이 쉽게 저지를 수 있습니다.

눈으로 보는 독자에게도 단어가 필요하다면 항목을 `PlTooltip`으로 감싸세요. 이 컴포넌트가 하지 않을 일은 어떤 원반에는 이름을 그리고 어떤 원반에는 그리지 않는 것입니다. 하나는 캡슐이고 넷은 원인 줄은 목적지가 바뀔 때마다 레이아웃이 튀는 줄입니다.

### variant

기본값 `glass`가 핵심입니다 — 흐린 배경 위의 맑은 시트에 얇은 선을 두른 것. `solid`는 같은 시트를 가장 불투명하게 한 것으로, 사진 위에 놓이는 바를 위한 것입니다. `ghost`에는 캡슐이 아예 없습니다 — 원반들이 스스로 떠 있습니다.

<Demo src="floating-bottom-navigation/variants" :min-height="320">

::: fw react

<<< @/.vitepress/demos/floating-bottom-navigation/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_bottom_navigation/variants.dart

:::

</Demo>

### color

캡슐은 `PlCard`에서와 마찬가지로 절대 물들지 않습니다. 색 가족을 나르는 것은 현재인 원반 하나입니다.

<Demo src="floating-bottom-navigation/colors" :min-height="260">

::: fw react

<<< @/.vitepress/demos/floating-bottom-navigation/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_bottom_navigation/colors.dart

:::

</Demo>

### size, elevation, 그리고 틈

`size`는 원반의 지름이고 컨트롤 사다리를 씁니다. `md`인 떠 있는 바는 40px 원반의 줄이고, 다른 모든 것과 같은 수 위에 놓입니다.

`elevation`은 나머지 거의 전부가 기본으로 쓰는 `0`이 아니라 `2`이고, 그것은 불일치가 아닙니다. 라이브러리의 다른 모든 시트는 페이지 위에 놓여 있고 유리 가장자리로 자기 분리를 벌기 때문에 그림자가 선택 사항입니다. 이쪽은 그 아래 무엇이 있든 그 위에 떠 있고, 자기가 떠 있는 내용에 평평하게 누운 캡슐은 실수로 읽힙니다.

바 아래의 틈도 같은 `size` 사다리에서 나오고, `safeArea`가 켜져 있는 동안에는 거기에 `env(safe-area-inset-bottom)`이 더해집니다.

<Demo src="floating-bottom-navigation/sizes" :min-height="280">

::: fw react

<<< @/.vitepress/demos/floating-bottom-navigation/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_bottom_navigation/sizes.dart

:::

</Demo>

## Accessibility

- 이름이 붙은 `<nav>` 랜드마크이고, 모든 원반이 문서 순서대로 놓인 진짜 링크 또는 버튼입니다 — 각자 탭 정지 하나씩.
- 현재 목적지는 `aria-current="page"`를 답니다. `aria-pressed`는 절대 아닙니다.
- 모든 원반에 접근 가능한 이름이 있고, 그중 어느 것도 그려지지 않습니다. 이름은 1px로 잘린 상자 안에 있습니다 — 눈으로 보는 독자에게는 보이지 않고, 다른 모든 방식에는 존재합니다.

::: fw react

- 캡슐이 가운데 놓이는 띠는 창을 가로지르지만 **포인터 이벤트를 받지 않습니다**. 되받는 것은 캡슐뿐입니다. 페이지 아래를 가로지르는 투명한 띠가 누름을 삼킨다면, 아무도 그 위로 스크롤할 수 없습니다.

:::

- 원반의 포커스 링은 붙어 있지 않고 떨어져 있습니다. 라이브러리의 나머지가 하지 않는 예외입니다 — 원에 딱 붙은 링은 원 자신의 가장자리가 두꺼워지는 것이고, 그것은 포커스가 아니라 테두리로 읽힙니다.

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `<PlFloatingBottomNavigationItem>` children | `items: List<…<T>>` | 바가 자기 멤버에 대해 판단해야 합니다. 패키지의 나머지가 쓰는 관용구입니다. |
| 항목의 `children` | `String`인 `label` | 여기서는 시맨틱 라벨로만 쓰이고, 시맨틱 라벨은 문자열입니다. |
| `value` / `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter 자체 컨트롤이 controlled입니다. |
| `position` | — | Flutter 화면에는 빠져나올 페이지 스크롤이 없고, 바를 놓는 것은 앱입니다. |
| 포인터 이벤트를 받지 않는 전체 너비 띠 | — | 만들 띠가 없습니다. `fixed` 요소는 무언가를 가로질러야 하지만, Flutter 위젯은 놓인 자리에 정확히 있습니다. 그래서 바는 자기 캡슐만큼만 넓습니다. |
| `href` | — | 링크 요소도 없고 Flutter 앱을 크롤링하는 것도 없습니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
