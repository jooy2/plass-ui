---
title: PlBlockquote
order: 8
---

# PlBlockquote

<p class="plass-lede">남의 말을 자기 말과 떼어 놓습니다. 시작하는 쪽 가장자리에 강조색 선이 서고, 인용문은 제목의 크기로 놓이며, 출처가 있으면 HTML 명세가 요구하는 마크업으로 붙습니다.</p>

<Demo src="blockquote/hero" :min-height="260" />

::: fw react

```tsx
import { PlBlockquote } from 'plass-ui';

<PlBlockquote author="Ada Lovelace" source="Notes on the Analytical Engine">
  Simplicity is hard.
</PlBlockquote>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlBlockquote(
  author: Text('Ada Lovelace'),
  source: Text('Notes on the Analytical Engine'),
  child: Text('Simplicity is hard.'),
);
```

:::

## Props

<PropsTable name="PlBlockquote" />

::: fw react

네이티브 `<figure>` 속성은 안쪽의 `<blockquote>`가 아니라 **감싸는 요소**에 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 전달 대상에서 제외됩니다.

:::

::: fw flutter

`cite`는 없습니다. Flutter에 없는 요소에 붙는, 아무도 아무것도 읽지 않는 기계용 URL입니다. 독자가 보아야 할 부분에는 `source`를 쓰세요.

`icon`은 `Widget?`이고 그 옆에 `showIcon`이 스위치로 있습니다. React는 둘을 세 갈래 prop 하나로 나타내는데, Dart에는 그럴 값이 없습니다. `null`이 있고 위젯이 있을 뿐, "치워라"에 해당하는 값이 없습니다.

:::

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### author와 source

`author`는 사람이고 `source`는 저작물입니다. 이름 붙이기 취향의 문제가 아닙니다. `<cite>`는 저작물의 제목을 위한 요소이고 명세상 사람 이름에는 쓰지 않으므로, 둘은 한 자리를 나눠 쓸 수 없습니다.

출처는 인용문에 **대한** 것이지 말해진 내용의 일부가 아닙니다. 그래서 출처를 넘기면 감싸는 요소가 `<figure>`가 되고, `<figcaption>`이 `<blockquote>` 바깥에 놓입니다. 출처가 없으면 감싸는 요소는 그냥 `<div>`입니다. `<figcaption>`이 없는 `<figure>`는 아무것도 아닌 것의 그림입니다.

::: fw react

`cite`는 URL이고, `<blockquote>` 자신의 속성에 놓입니다. 기계만 읽고 아무에게도 보이지 않습니다.

:::

<Demo src="blockquote/attribution" :min-height="320">

::: fw react

<<< @/.vitepress/demos/blockquote/attribution.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/blockquote/attribution.dart

:::

</Demo>

### variant

`PlCard`가 그렇듯 시트에는 색이 들어가지 않습니다. 인용문은 남의 말을 담고 있고, 틴트가 깔린 판 위의 말은 그 배경을 두고 고른 적 없는 말입니다. 그래서 색 계열은 선까지만 닿고 멈춥니다.

기본값 `ghost`는 흐르는 산문 안에 놓이는 모양입니다. 여백의 선 하나뿐이고, 선 위에 올려놓을 표면이라는 것이 생기기 훨씬 전부터 인용문은 그런 모양이었습니다.

<Demo src="blockquote/variants" :min-height="320">

::: fw react

<<< @/.vitepress/demos/blockquote/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/blockquote/variants.dart

:::

</Demo>

### color

<Demo src="blockquote/colors" :min-height="280">

::: fw react

<<< @/.vitepress/demos/blockquote/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/blockquote/colors.dart

:::

</Demo>

### size

<Demo src="blockquote/sizes" :min-height="420">

::: fw react

<<< @/.vitepress/demos/blockquote/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/blockquote/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- 인용문은 진짜 `<blockquote>`이고 출처는 그 바깥의 진짜 `<figcaption>`입니다. 인용문 **안**에 든 이름은 말한 사람이 자기 이름을 말했다고 주장하는 것이 됩니다.
- 따옴표 글리프는 장식이라 `aria-hidden`입니다. 저자 앞의 em dash도 마찬가지입니다. 이름 앞에서 "em dash"를 읽는 스크린리더는 텍스트가 아니라 타이포그래피를 읽고 있는 것입니다.
- `<blockquote>` 요소 자체에는 아무것도 그리지 않습니다. `blockquote`는 호스트 스타일시트가 아직도 태그 이름으로 스타일을 주는 몇 안 되는 태그이고, 표면과 선을 감싸는 요소로 옮긴 것이 호스트가 자기 버전을 되돌리면서 이쪽 것까지 되돌리지 않게 하는 방법입니다.

:::

::: fw flutter

- 인용문과 출처는 하나의 semantics 노드로, 순서대로 읽힙니다. 출처는 말해진 내용 안이 아니라 그 뒤에 옵니다. 인용문 안에 든 이름은 말한 사람이 자기 이름을 말했다고 주장하는 것이 됩니다.
- 따옴표 글리프는 타이핑한 것이 아니라 그린 것이고 semantics에서 제외됩니다. 저자 앞의 em dash도 마찬가지입니다. 이름 앞에서 "em dash"를 읽는 스크린리더는 텍스트가 아니라 타이포그래피를 읽고 있는 것입니다.
- 선은 테두리가 아니라 텍스트 옆에 칠해집니다. 그 쪽 모서리가 각진 채로 남는 이유입니다. 자기가 표시하는 텍스트에서 휘어져 달아나는 2px 선은 여백의 선이 아니라 괄호입니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `<figure>` / `<figcaption>` / `<blockquote>` | semantics 노드 하나 | Flutter에는 제대로 맞춰야 할 문서 마크업이 없습니다. React 빌드가 공들이는 것(출처가 어느 요소 안에 사는가) 에는 대응물이 없고, 남는 것은 읽히는 순서입니다. |
| `cite` | — | 존재하지 않는 요소에 붙는, 아무도 읽지 않는 URL입니다. 독자가 보는 부분은 `source`입니다. |
| `icon={false}` | `showIcon: false` | Dart에는 `null`도 위젯도 아닌 값이 없으니, "치워라"가 자기 이름을 갖습니다. |
| `children` | `child` | Flutter의 이름입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

따옴표 글리프는 양쪽이 같은 16단위 상자에서 단위 하나까지 같은 그림입니다. 진짜 `“`였다면 페이지가 쓰는 서체를 따라 모양도 굵기도 baseline도 바뀌었을 텐데, 2em에서 그것은 이 컴포넌트에서 가장 큰 글리프 하나이므로 바뀌는 것 중 가장 눈에 띄는 것이 됩니다.

:::
