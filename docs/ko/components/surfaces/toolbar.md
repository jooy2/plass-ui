---
title: PlToolbar
order: 10
---

# PlToolbar

<p class="plass-lede">컨트롤이 늘어선 바입니다. 애플리케이션 헤더, 페이지의 액션 줄, 에디터 아래를 가로지르는 띠. 슬롯 셋과 한 줄.</p>

<Demo src="toolbar/hero" :flutter="false" :min-height="140" />

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

## Props

<PropsTable name="PlToolbar" />

::: fw react

나머지 `<div>` 속성은 모두 전달되고, `render`로 요소를 바꿉니다.

:::

라이브러리 전체에서 공유하는 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 높이를 갖지 않습니다

툴바는 안에 든 컨트롤에 자기 여백을 더한 만큼 높고, 그 여백은 다른 모든 표면이 쓰는 `size` / `density` 쌍입니다. 그래서 `density="compact"`가 같은 말을 하는 두 번째 prop 없이 촘촘한 바를 주고, 그 밑에서 타입 스케일은 움직이지 않습니다.

<Demo src="toolbar/density" :flutter="false" :min-height="200">

<<< @/.vitepress/demos/toolbar/density.tsx

</Demo>

## toolbar role이 없습니다

의도된 것입니다. `role="toolbar"`는 **키보드 동작에 대한 약속**입니다 — 바 전체에 탭 정지 하나, 그 안의 컨트롤 사이는 방향키. 그것을 구현하지 않은 채 선언한 바는 아무것도 선언하지 않은 바보다 키보드 독자에게 더 나쁩니다.

페이지 헤더가 원하는 것은 올바른 요소입니다. 진짜로 roving focus를 갖는 선택 묶음이 원하는 것은 [`PlSegmentedButton`](../inputs/segmented-button)이고, 그것은 실제로 그렇습니다.

## Examples

### 세 개의 슬롯

`start`와 `end`는 양 끝에 고정되고 `children`이 남는 자리를 차지합니다. 모든 툴바가 늘 취해 온 배치이므로, 호출하는 쪽과 그들이 기억해야 할 여백 채우개에 맡기는 대신 여기서 배치합니다. 가운데는 비어 있어도 자기 너비를 지킵니다. 그러지 않으면 양 끝이 바 한가운데로 모여 버립니다.

<Demo src="toolbar/slots" :flutter="false" :min-height="140">

<<< @/.vitepress/demos/toolbar/slots.tsx

</Demo>

### variant

세 재질을 *컨테이너*의 방식으로 말합니다. 바에는 색이 들어가지 않습니다. [`PlBox`](./box)와 같습니다 — 툴바는 남의 컨트롤을 담고, 그 컨트롤들은 자기 색을 가지고 옵니다.

<Demo src="toolbar/variants" :flutter="false" :min-height="240">

<<< @/.vitepress/demos/toolbar/variants.tsx

</Demo>

### position과 divider

`static`은 바를 흐름 안에 둡니다. `sticky`는 페이지가 거기까지 스크롤되면 가장자리에 붙잡아 두고, 그러면서도 자기 자리를 계속 차지합니다 — 그래서 아래쪽에 여백을 따로 줄 필요가 없습니다. `fixed`는 흐름에서 아예 빼내고, 그러면 페이지가 자기 여백을 가져야 합니다. 그러지 않으면 첫 화면이 바 뒤에 놓입니다.

고정된 바는 모서리를 잃습니다. 화면 가장자리에 맞닿은 둥근 모서리는 뒤에 아무것도 없는 틈입니다.

`elevation`은 고정되어도 `0`으로 남는데, 그것도 의도된 것입니다. 헤더 아래의 그림자는 "이 밑에 내용이 있다"고 말하는 방식이고, 그 말이 참이 되는 것은 페이지가 스크롤된 뒤부터입니다. 그때 직접 올리거나, 평평하게 두고 `divider`를 켜세요. 내용을 향한 가장자리에 얇은 선을 긋습니다 — `top` 바에서는 아래, `bottom` 바에서는 위에.

## Accessibility

- 바는 자기 role을 주장하지 않습니다. 무엇인지는 렌더링하는 요소가 정합니다.
- 안의 컨트롤들은 문서 순서 그대로의 평범한 컨트롤이고 각자 focus stop을 가집니다. roving focus를 약속하지 않은 바가 키보드 독자에게 빚진 것이 그것입니다.

::: fw react

- `render={<header />}`와 `render={<nav />}`가 가장 자주 나오는 둘입니다. 페이지의 헤더는 `<header>`여야 합니다.

:::
