---
title: PlBox
order: 5
---

# PlBox

<p class="plass-lede">내용을 얹은 유리 한 장입니다. 라이브러리에서 가장 단순한 표면이고, 하는 일은 묶는 것 하나뿐입니다.</p>

<Demo src="box/hero" :min-height="180" />

::: fw react

```tsx
import { PlBox } from 'plass-ui';

<PlBox>
  <p>Everything in here is grouped, and nothing else is claimed.</p>
</PlBox>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlBox(child: Text('Everything in here is grouped, and nothing else is claimed.'));
```

:::

## Props

<PropsTable name="PlBox" />

::: fw react

나머지 `<div>` 속성은 모두 전달되고, `render`로 요소를 바꿉니다.

:::

라이브러리 전체에서 공유하는 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## PlBox와 PlCard

제목, 부제, 푸터, 섹션을 가르는 얇은 선 같은 구조는 전부 [`PlCard`](./card)의 것입니다. 카드는 그 섹션들을 얹어 놓은 box입니다. 여기 남는 것은 시트 자체이고, 그것만으로도 따로 둘 값어치가 있습니다. 화면이 묶는 것의 대부분에는 제목이 없기 때문입니다: 폼 뒤의 우물, 선반 위의 타일, 차트를 감싼 판.

box 안에 제목과 본문을 손으로 넣고 있는 자신을 발견하는 순간, 원했던 컴포넌트는 카드입니다.

## `size`는 시트의 크기입니다

여기서 `size`는 컨트롤에서의 뜻과 다르고, 라이브러리에서 그런 곳은 여기 하나뿐입니다.

box는 담고 있는 것만큼 높고, 자식들은 자기 타이포그래피를 가지고 옵니다. 타입 스케일을 재설정하는 컨테이너였다면 같은 문단이 무엇으로 감싸였느냐에 따라 두 가지 크기로 렌더링됐을 것입니다. 그래서 `size`는 **시트**의 크기입니다. 반경과 여백, 그리고 그것뿐입니다.

<Demo src="box/sizes" :min-height="320">

::: fw react

<<< @/.vitepress/demos/box/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/box/sizes.dart

:::

</Demo>

## Examples

### variant

세 재질은 다른 곳에서 말하는 것을 그대로 말하되, *컨테이너*의 방식으로 씁니다. 시트에는 색이 들어가지 않습니다. box가 담는 것은 자기 색을 가지고 오고, 그 아래 판에 색을 넣으면 모든 내용이 자기가 선택되지 않은 배경 위에 놓입니다. 그래서 색 계열은 얇은 선과 focus ring까지만 닿고 멈춥니다.

`ghost`는 다른 표면 안에서 쓰는 것입니다. 테두리 있는 사각형 안의 두 번째 테두리 있는 사각형은 그냥 사각형이 하나 더 있는 것입니다.

<Demo src="box/variants" :min-height="280">

::: fw react

<<< @/.vitepress/demos/box/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/box/variants.dart

:::

</Demo>

### padded

기본은 켜져 있습니다. 가장자리까지 닿아야 하는 내용(이미지, 표, 자기 행을 직접 그리는 목록) 에서는 끄세요.

::: fw react

내용이 시트의 모서리에서 잘리도록 `overflow-hidden`을 더하세요.

:::

::: fw flutter

`clipped`가 내용을 시트의 모서리에서 잘라 냅니다. React 빌드에서는 클래스 하나면 되는 것이 여기서는 파라미터인데, 클립은 자식이 자기 바깥에 그리는 것(focus ring을 포함해)까지 잘라 내기 때문에 기본은 꺼져 있습니다.

:::

<Demo src="box/padded" :min-height="220">

::: fw react

<<< @/.vitepress/demos/box/padded.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/box/padded.dart

:::

</Demo>

### elevation

`0`이고 평평합니다. 그것이 맞는 기본값입니다. box를 페이지에서 떼어 놓는 것은 유리 가장자리입니다. 주변 내용 위에 진짜로 떠 있는 표면일 때만 올리세요. 그리고 `ghost` box에는 그림자가 떨어져 나올 시트가 없다는 것도 기억하세요.

::: fw react

```tsx
<PlBox elevation={2}>Floating clear of the page</PlBox>
```

:::

::: fw flutter

```dart
PlBox(elevation: 2, child: Text('Floating clear of the page'));
```

:::

## Accessibility

- box는 `<div>`이고 아무 role도 선언하지 않습니다. role도, 이름도, 문서 개요에서의 자리도 없습니다. 그것이 맞습니다. 눈을 위한 묶음은 스크린 리더를 위한 묶음이 아닙니다.
- 그 묶음이 _의미가 있을 때_(페이지의 한 영역, 목록의 항목, 제목이 있는 섹션)는 시트가 아니라 요소로 말하세요.

::: fw react

`render={<section aria-label="Storage" />}`와 `render={<li />}`가 가장 자주 나오는 둘입니다.

:::

::: fw flutter

box를 감싼 `Semantics(container: true, label: …)`가 그 묶음이 하나임을 말합니다. 시트 안이 아니라 바깥에 놓입니다.

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `render` | — | 바꿔 끼울 요소가 없습니다. `<section>`이 말하던 것은 box를 감싼 `Semantics`가 말합니다. |
| 클래스로 주는 `overflow-hidden` | `clipped` | 여기서 클립은 속성이 아니라 위젯이라 누군가의 결정이어야 합니다. 그리고 기본은 꺼져 있습니다. 클립은 자식이 자기 바깥에 그리는 것까지 잘라 냅니다. |
| `className`, `style` | — | 전달할 class 목록도 style 속성도 없습니다. |

:::
