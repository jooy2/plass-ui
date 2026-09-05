---
title: PlToolbar
order: 10
---

# PlToolbar

<p class="plass-lede">컨트롤이 늘어선 바입니다. 애플리케이션 헤더, 페이지의 액션 줄, 에디터 아래를 가로지르는 띠에 씁니다. 슬롯 셋과 한 줄이 전부입니다.</p>

<Demo src="toolbar/hero" :min-height="140" />

::: fw react

```tsx
import { PlButton, PlToolbar, PlTypography } from 'plass-ui';

<PlToolbar
  render={<header />}
  start={<PlTypography level="h6">Reports</PlTypography>}
  end={<PlButton>New</PlButton>}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlToolbar(
  start: const <Widget>[PlTypography('Reports', level: PlTypographyLevel.h6)],
  end: <Widget>[PlButton(onPressed: create, child: const Text('New'))],
);
```

:::

## Props

<PropsTable name="PlToolbar" />

::: fw react

나머지 `<div>` 속성은 모두 전달되고, `render`로 요소를 바꿉니다.

:::

라이브러리 전체에서 공유하는 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 높이

툴바는 안에 든 컨트롤에 자기 여백을 더한 만큼 높고, 그 여백은 다른 모든 표면이 쓰는 `size` / `density` 쌍입니다. 그래서 `density="compact"`가 같은 말을 하는 두 번째 prop 없이 촘촘한 바를 주고, 그 밑에서 타입 스케일은 움직이지 않습니다.

<Demo src="toolbar/density" :min-height="200">

::: fw react

<<< @/.vitepress/demos/toolbar/density.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toolbar/density.dart

:::

</Demo>

## toolbar role 없음

의도된 것입니다. `role="toolbar"`는(그리고 그 뒤에 있는 시맨틱은) **키보드 동작에 대한 약속**입니다. 바 전체에 탭 정지 하나, 그 안의 컨트롤 사이는 방향키. 그것을 구현하지 않은 채 선언한 바는 아무것도 선언하지 않은 바보다 키보드 독자에게 더 나쁩니다.

진짜로 roving focus를 갖는 선택 묶음이 원하는 것은 [`PlSegmentedButton`](../inputs/segmented-button)이고, 그것은 실제로 그렇습니다.

::: fw react

페이지 헤더가 원하는 것은 올바른 요소입니다. `render={<header />}`.

:::

## Examples

### 세 개의 슬롯

`start`와 `end`는 양 끝에 고정되고 가운데가 남는 자리를 차지합니다. 모든 툴바가 늘 취해 온 배치이므로, 호출하는 쪽과 그들이 기억해야 할 여백 채우개에 맡기는 대신 여기서 배치합니다. 가운데는 비어 있어도 자기 너비를 지킵니다. 그러지 않으면 양 끝이 바 한가운데로 모여 버립니다.

<Demo src="toolbar/slots" :min-height="140">

::: fw react

<<< @/.vitepress/demos/toolbar/slots.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toolbar/slots.dart

:::

</Demo>

### variant

세 재질을 *컨테이너*의 방식으로 씁니다. 바에는 색이 들어가지 않습니다. [`PlBox`](./box)와 같습니다. 툴바는 남의 컨트롤을 담고, 그 컨트롤들은 자기 색을 가지고 옵니다.

<Demo src="toolbar/variants" :min-height="240">

::: fw react

<<< @/.vitepress/demos/toolbar/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toolbar/variants.dart

:::

</Demo>

### 가장자리에 붙잡아 둘 때

::: fw react

`static`은 바를 흐름 안에 둡니다. `sticky`는 페이지가 거기까지 스크롤되면 가장자리에 붙잡아 두고, 그러면서도 자기 자리를 계속 차지합니다. 그래서 아래쪽에 여백을 따로 줄 필요가 없습니다. `fixed`는 흐름에서 아예 빼내고, 그러면 페이지가 자기 여백을 가져야 합니다. 그러지 않으면 첫 화면이 바 뒤에 놓입니다.

고정된 바는 모서리를 잃습니다. 화면 가장자리에 맞닿은 둥근 모서리는 뒤에 아무것도 없는 틈입니다.

:::

::: fw flutter

여기에는 `position`이 없습니다. [`PlFloatingBottomNavigation`](../navigation/floating-bottom-navigation)에 없는 것과 같은 이유입니다. `fixed` 요소는 무언가를 가로질러야 하고, Flutter 위젯은 화면이 놓아 준 자리에 정확히 놓입니다. 자리를 지켜야 하는 바는 화면 자신의 레이아웃에 속합니다: `Positioned`를 둔 `Stack`이거나, 내용이 그 아래로 스크롤되는 `Column`의 맨 위.

남는 것은 눈에 보이는 결과 하나, `rounded`입니다. 레이아웃 안에 앉은 바에서는 켜고, 가장자리에 붙잡아 둔 바에서는 끕니다. 화면 가장자리에 맞닿은 둥근 모서리는 뒤에 아무것도 없는 틈이기 때문입니다.

:::

그다음 `side`가 정하는 것은 하나뿐입니다. `divider`가 얇은 선을 어느 가장자리에 긋는지, `top` 바에서는 아래, `bottom` 바에서는 위에.

`elevation`은 고정되어도 `0`으로 남는데, 그것도 의도된 것입니다. 헤더 아래의 그림자는 "이 밑에 내용이 있다"고 말하는 방식이고, 그 말이 참이 되는 것은 페이지가 스크롤된 뒤부터입니다. 그때 직접 올리거나, 평평하게 두고 `divider`를 켜세요.

## Accessibility

- 바는 자기 role을 선언하지 않습니다.
- 안의 컨트롤들은 읽히는 순서 그대로의 평범한 컨트롤이고 각자 focus stop을 가집니다. roving focus를 약속하지 않은 바가 키보드 독자에게 빚진 것이 그것입니다.

::: fw react

- 바가 *무엇인지*는 렌더링하는 요소가 정합니다. `render={<header />}`와 `render={<nav />}`가 가장 자주 나오는 둘입니다. 페이지의 헤더는 `<header>`여야 합니다.

:::

::: fw flutter

- `semanticLabel`은 바 자신에게 이름이 필요할 때 그 이름을 줍니다. 안의 컨트롤들은 자기 노드를 그대로 유지하므로, 그 이름은 바의 것이지 바와 그 안의 전부를 한 덩어리로 읽은 것이 아닙니다.

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `position` | — | `fixed` 요소는 무언가를 가로질러야 합니다. Flutter 위젯은 화면이 놓아 준 자리에 정확히 놓이고, 자리를 지켜야 하는 바는 화면 자신의 레이아웃에 속합니다. |
| 모서리가 `position`을 따름 | `rounded` | 같은 판단을 곧바로 말합니다. 흐름 안에서는 켜고, 가장자리에서는 끕니다. |
| `side`가 붙는 가장자리*와* 선의 가장자리를 정함 | `side`가 선의 가장자리를 정함 | 그 외에 정할 것이 남지 않습니다. |
| `render` | 바를 짓는 자리의 요소 | 바꿔 끼울 요소가 없습니다. 바에 이름을 주는 것은 `semanticLabel`입니다. |
| 노드 하나인 `start`, `end` | `List<Widget>` | Dart에는 fragment가 없으니, 슬롯이 어차피 담게 될 목록을 그대로 받고 간격도 대신 줍니다. |
| `children` | `child` | 슬롯 하나이고, Dart는 그것을 `child`라고 씁니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
