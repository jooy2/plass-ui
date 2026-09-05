---
title: PlAccordion
order: 1
---

# PlAccordion

<p class="plass-lede">한 번에 하나씩 펼쳐지는 섹션 묶음입니다. 무엇을 읽을지 먼저 훑어보는 참고성 내용(설정 그룹, 사양표, FAQ)에 씁니다.</p>

<Demo src="accordion/hero" :min-height="240" />

::: fw react

```tsx
import { PlAccordion, PlAccordionItem } from 'plass-ui';

<PlAccordion defaultValue={['shipping']}>
  <PlAccordionItem value="shipping" title="Shipping">
    Three to five working days.
  </PlAccordionItem>
  <PlAccordionItem value="returns" title="Returns">
    Thirty days from delivery.
  </PlAccordionItem>
</PlAccordion>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAccordion<String>(
  value: open,
  onChanged: (Set<String> next) => setState(() => open = next),
  items: const <PlAccordionItem<String>>[
    PlAccordionItem<String>(
      value: 'shipping',
      title: Text('Shipping'),
      child: Text('Three to five working days.'),
    ),
    PlAccordionItem<String>(
      value: 'returns',
      title: Text('Returns'),
      child: Text('Thirty days from delivery.'),
    ),
  ],
);
```

:::

## Props

<PropsTable name="PlAccordion" />

::: fw react

네이티브 `<div>` 속성은 그대로 전달됩니다. `color`는 위 표의 `color`와 충돌해서, `defaultValue`와 `onChange`는 accordion이 각각 배열형 `defaultValue`와 `onValueChange`로 쓰기 때문에 제외됩니다.

:::

::: fw flutter

accordion은 섹션 값 타입에 대해 제네릭입니다(`PlAccordion<String>`, `PlAccordion<Section>`). 그래서 `value`와 `onChanged`가 `dynamic`이 아니라 타입을 가지며, 패키지의 다른 컨트롤과 마찬가지로 **controlled**입니다. `multiple`이 꺼져 있어도 `value`는 `Set<T>`입니다. 닫힌 상태도 집합이기 때문입니다. 빈 집합입니다.

:::

### PlAccordionItem

<PropsTable name="PlAccordionItem" />

::: fw react

`size`, `density`, `dividers`는 item에 주는 prop이 아니라 감싸고 있는 `PlAccordion`에서 내려받습니다.

:::

::: fw flutter

섹션은 위젯이 아니라 **`PlAccordionItem`, 즉 설명**입니다. accordion은 어느 섹션이 열려 있는지, 누르면 무엇이 닫혀야 하는지, 사이의 선이 어디 들어가는지를 알아야 하는데, 불투명한 `Widget`에게는 그중 어느 것도 물어볼 수 없습니다.

`size`도 `density`도 `dividers`도 없고, 있을 수도 없습니다. 그것들은 accordion의 것이고, 타입 스케일이 두 개인 묶음은 한 장의 판이 아닙니다.

:::

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### variant

세 가지 재질을 **컨테이너** 입장에서 읽은 것입니다. `solid`는 가장 불투명한 맑은 유리로, 주변보다 앞으로 나와 있어야 하는 판에 씁니다. `glass`는 Plass의 기본 시트이자 기본값입니다. `ghost`는 시트가 아예 없어서, 이미 시트인 `PlCard` 안에 넣을 때 씁니다. 사각형 안의 또 다른 사각형은 사각형 하나가 더 많은 것입니다.

셋 중 어느 것에도 색이 들어가지 않습니다. accordion이 담는 내용은 자기 색을 가지고 오기 때문에, 색 계열은 hover 틴트와 열린 섹션의 제목, focus ring까지만 닿고 거기서 멈춥니다.

<Demo src="accordion/variants" :min-height="200">

::: fw react

<<< @/.vitepress/demos/accordion/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/accordion/variants.dart

:::

</Demo>

### multiple

기본값에서는 한 섹션을 열면 열려 있던 섹션이 닫힙니다. accordion이 collapsible을 쌓아 놓은 것과 다른 이유가 바로 이것으로, 다음을 열 때 앞의 것이 닫히는 덕분에 읽는 도중 페이지가 아래로 자라지 않습니다. `multiple`은 이 제약을 풉니다.

<Demo src="accordion/multiple" :min-height="220">

::: fw react

<<< @/.vitepress/demos/accordion/multiple.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/accordion/multiple.dart

:::

</Demo>

### dividers

기본으로 켜져 있습니다. 양 끝까지 닿는 헤어라인이 여러 섹션을 한 장의 판으로 묶어 줍니다. 끄면 각 섹션이 자기 타일이 되고, 여백으로 구분됩니다.

<Demo src="accordion/dividers" :min-height="180">

::: fw react

<<< @/.vitepress/demos/accordion/dividers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/accordion/dividers.dart

:::

</Demo>

### title · subtitle · startIcon · action

제목과 부제는 **줄바꿈됩니다**. 접힘 제목은 대개 한 문장이고(FAQ는 질문의 목록입니다) 말줄임하면 독자는 문장의 끝을 잃습니다. 툴팁도 없고 확인할 방법도 없습니다. 반대로 줄바꿈이 치르는 값은 두 줄짜리 헤더인데, 높이가 변하는 것이 존재 이유인 컴포넌트에서는 그것이 값이라 하기 어렵습니다. `truncate`는 둘을 다시 한 줄로 되돌립니다. 데이터베이스에서 온 이름을 컨트롤 옆에 놓는 헤더를 위한 것입니다.

`action`은 접히는 부분 **바깥**에 그려집니다. 접히기도 하고 버튼도 쥐고 있는 헤더에는 누를 것이 두 개인데, 그중 하나를 다른 하나 안에 넣을 수는 없습니다.

::: fw react

브라우저가 `<button>` 안의 `<button>`을 파싱 단계에서 다시 쓰므로, 이것은 취향의 문제가 아닙니다.

:::

::: fw flutter

여기서는 트리를 다시 쓰는 주체가 없지만, 컨트롤 안의 컨트롤은 한 번 누르면 두 번 발생하는 이벤트이고 스크린리더에는 버튼 안의 버튼입니다.

:::

<Demo src="accordion/slots" :min-height="220">

::: fw react

<<< @/.vitepress/demos/accordion/slots.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/accordion/slots.dart

:::

</Demo>

### size

제목과 본문, 그리고 둘을 감싸는 여백이 함께 움직입니다. accordion에 주면 모든 섹션이 내려받으므로, 한 묶음 안에 타입 스케일이 두 개가 되는 일이 없습니다.

본문은 아래쪽뿐 아니라 위쪽에도 자기 여백을 둡니다. 열린 헤더는 아래 모서리가 붙은 색 띠이고, 그 모서리에서 바로 시작하는 본문은 첫 줄이 제목 밑 half leading 자리에 놓입니다. 제목과 그것을 설명하는 문단이 색만 바뀐 한 덩어리 글로 읽히게 됩니다. 헤더의 여백이 사는 것은 제목 둘레의 자리이고, 본문의 자리는 본문이 삽니다.

<Demo src="accordion/sizes" :min-height="320">

::: fw react

<<< @/.vitepress/demos/accordion/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/accordion/sizes.dart

:::

</Demo>

### Controlled

::: fw react

`value`와 `onValueChange`를 함께 넘기면 열린 섹션 집합을 직접 쥘 수 있습니다. `multiple`이 꺼져 있어도 둘 다 배열입니다. 전부 닫힌 상태는 `[]`입니다.

:::

::: fw flutter

uncontrolled 모드는 없습니다. accordion을 움직이는 방법은 언제나 `value`와 `onChanged`입니다. `multiple`이 꺼져 있어도 `value`는 `Set<T>`이고(전부 닫힌 상태는 `<String>{}`입니다) `onChanged`를 주지 않으면 열려 있는 상태 그대로 굳습니다. 읽기 전용 요약은 그렇게 씁니다.

:::

<Demo src="accordion/controlled" :min-height="280">

::: fw react

<<< @/.vitepress/demos/accordion/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/accordion/controlled.dart

:::

</Demo>

## Accessibility

::: fw react

- 각 헤더는 `aria-expanded`가 붙은 진짜 `<button>`이고, `aria-controls`로 자기 패널을 가리킵니다. 패널은 헤더가 이름을 붙여 주는 `region`입니다.
- <kbd>Enter</kbd>와 <kbd>Space</kbd>로 섹션을 접고 폅니다. <kbd>Tab</kbd>은 헤더 사이와 열린 패널 안으로 이동합니다.
- `hiddenUntilFound`는 닫힌 패널을 `hidden="until-found"`로 렌더링하므로, 브라우저의 페이지 검색이 그 안의 글자를 찾아 해당 섹션을 열어 줍니다.
- chevron은 장식이라 `aria-hidden`입니다. 열림 상태는 `aria-expanded`가 나르며, 회전만으로 전달되는 정보는 없습니다.
- `action`에 넣은 것은 자기 tab stop이 붙은 별개의 컨트롤이므로, 접근 가능한 이름도 따로 필요합니다.
- 패널은 `transform`이 아니라 height를 애니메이션합니다. 글자가 다시 샘플링되지 않고, 열리는 동안 패널 안의 내용이 밀리지도 않습니다.

:::

::: fw flutter

- 각 헤더는 펼쳐졌는지 접혔는지가 표시된 버튼으로 읽힙니다. 그 상태는 플래그가 나르며, chevron의 회전만으로 전달되는 정보는 없습니다.
- <kbd>Enter</kbd>와 <kbd>Space</kbd>로 섹션을 접고 폅니다. <kbd>Tab</kbd>은 헤더 사이와 열린 패널 안으로 이동합니다. 헤더는 저마다 자기 focus stop이 있습니다. accordion은 버튼 묶음이지 roving 그룹이 아닙니다.
- 닫힌 패널은 트리에 아예 없습니다. 열리기 전까지 그 안의 어떤 것도 닿거나 포커스되거나 읽히지 않습니다.
- chevron은 그려지되 이름이 없고, 비활성 섹션은 포인터에도 키보드에도 답하지 않습니다.
- `action`에 넣은 것은 자기 focus stop이 붙은 별개의 컨트롤이므로, 이름도 따로 필요합니다.
- 패널은 transform이 아니라 **높이**를 애니메이션합니다. 글자가 다시 샘플링되지 않고, 열리는 동안 패널 안의 내용이 밀리지도 않습니다. OS에서 애니메이션을 끄면 즉시 펼쳐집니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `<PlAccordionItem>` children | 설명 목록인 `items` | accordion은 어느 섹션이 열려 있는지, 누르면 무엇이 닫히는지, 선이 어디 들어가는지를 알아야 합니다. 불투명한 위젯에게는 물어볼 수 없습니다. |
| `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter의 컨트롤은 controlled이고, 콜백 이름도 Flutter의 것입니다. |
| `string` 값 | 제네릭 `T` | Dart에는 제네릭이 있으니 섹션 타입은 관습이 아니라 타입 검사로 지켜집니다. |
| 배열인 `value` | `Set<T>`인 `value` | 열린 섹션은 순서도 중복도 없는 집합이고, Dart에는 그 자료형이 있습니다. |
| `hiddenUntilFound` | — | 섹션을 대신 열어 줄 브라우저 페이지 검색이 없습니다. 닫힌 패널은 그냥 만들어지지 않습니다. |
| `aria-expanded`, `aria-controls`, `region` | 펼쳐짐이 표시된 버튼과, 있거나 없는 패널 | Flutter는 상태를 노드 자체에 적습니다. 가리킬 id가 없습니다. |
| `children` | `child` | Flutter의 이름입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
