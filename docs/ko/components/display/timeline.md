---
title: PlTimeline
order: 13
---

# PlTimeline

<p class="plass-lede">일이 일어난 순서대로 늘어놓은 단계들입니다. <code>active</code>가 어디까지 왔는지 말하면, timeline이 각 단계의 bullet이 무엇이어야 하는지 계산합니다.</p>

<Demo src="timeline/hero" :min-height="360" />

::: fw react

```tsx
import { PlTimeline, PlTimelineItem } from 'plass-ui';

<PlTimeline active={2}>
  <PlTimelineItem title="Ordered" meta="Mon 09:12" bullet="1" />
  <PlTimelineItem title="Packed" meta="Mon 14:40" bullet="2" />
  <PlTimelineItem title="Shipped" meta="Tue 07:05" bullet="3" />
</PlTimeline>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlTimeline(
  active: 2,
  items: <PlTimelineItem>[
    PlTimelineItem(title: Text('Ordered'), meta: Text('Mon 09:12'), bullet: Text('1')),
    PlTimelineItem(title: Text('Packed'), meta: Text('Mon 14:40'), bullet: Text('2')),
    PlTimelineItem(title: Text('Shipped'), meta: Text('Tue 07:05'), bullet: Text('3')),
  ],
);
```

:::

## Props

<PropsTable name="PlTimeline" />

::: fw react

네이티브 `<ol>` 속성은 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 전달 대상에서 제외됩니다.

:::

::: fw flutter

단계는 children이 아니라 `items`이고, `PlTimelineItem`은 **위젯이 아니라 설명**입니다. [`PlBreadcrumb`](./breadcrumb)과 같은 판단이자 Flutter 자신의 관용구입니다. 어느 단계가 끝났는지는 인덱스 계산이고, 마지막 단계의 연결선은 자기가 마지막임을 알아야 합니다. 불투명한 `Widget`에는 둘 다 물어볼 수 없습니다.

:::

`variant`도 `elevation`도 없습니다. timeline은 페이지 위에 놓인 시트가 아니라 페이지를 따라 내려가는 표시의 줄입니다. 표면이 필요하면 `PlCard` 안에 넣으세요.

### PlTimelineItem

<PropsTable name="PlTimelineItem" />

::: fw react

네이티브 `<li>` 속성은 그대로 전달됩니다. `size`, `density`, `orientation`은 감싸는 `PlTimeline`에서 상속됩니다.

:::

항목의 **인덱스는 속성이 아니고, 될 수도 없습니다**. 목록에서 자기가 몇 번째인지 들어야 하는 항목은 모든 호출자가 틀린 자리에 놓을 수 있는 항목이고, 그러면 `active`는 아무 뜻도 갖지 못합니다. timeline이 단계들을 훑으면서 번호를 매깁니다.

라이브러리 전체에서 공유 축(`size` `color` `density` `orientation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### active

값이 아니라 인덱스인 이유는 timeline에 선택이 없기 때문입니다. 여기서 고르는 것은 없고, 현실이 목록의 어디까지 왔는지만 묻습니다. 생략하면 모든 항목이 `upcoming`이고, 항목 개수를 넘기면 순서 전체가 끝난 것이 됩니다.

<Demo src="timeline/active" :min-height="340">

::: fw react

<<< @/.vitepress/demos/timeline/active.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline/active.dart

:::

</Demo>

### status

둘이 아니라 셋인 이유는 "지금 있는 곳"이 "끝났다"와 같은 주장이 아니기 때문입니다. 어느 단계가 현재인지 알리지 못하는 순서는 그냥 목록입니다.

각 상태는 불투명도가 아니라 서로 다른 **축**입니다. `complete`는 색 계열의 그러데이션, `current`는 그 그러데이션에 은은한 틴트의 halo, `upcoming`은 페이지 표면 위의 헤어라인 고리입니다. 색을 구별하지 못하는 독자에게도 채워진 모양, halo가 있는 모양, 빈 모양이 남습니다.

항목의 `status`는 `active`가 그 항목에 대해 계산한 값을 덮어씁니다: 실패해서 순서를 멈춘 단계, 건너뛴 단계.

<Demo src="timeline/status" :min-height="300">

::: fw react

<<< @/.vitepress/demos/timeline/status.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline/status.dart

:::

</Demo>

### connector

::: fw react

선은 채워진 `<div>`가 아니라 border 한 변으로 그려집니다. 그래서 `dashed`와 `dotted`가 브라우저 자신의 점선이고, 라이브러리의 다른 모든 가장자리처럼 기기 픽셀 격자에 정확히 얹힙니다.

:::

::: fw flutter

Flutter의 `BorderSide`에는 점선이 없어서 선은 직접 칠합니다. `dashed`와 `dotted`는 손으로 놓은 마디들이고, 굵기는 solid와 같습니다. 점은 길이 0인 마디에 둥근 캡을 씌운 것이라, 짧은 사각형이 아니라 원이 됩니다.

:::

선은 도착하는 항목이 아니라 떠나는 항목의 것입니다. 그래서 그 색이 "이 단계에 도달했는가"를 말할 수 있습니다. 마지막 항목의 선은 그려지지 않습니다. 순서 밖 아무것도 없는 곳으로 달려 나가게 되기 때문입니다.

<Demo src="timeline/connectors" :min-height="280">

::: fw react

<<< @/.vitepress/demos/timeline/connectors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline/connectors.dart

:::

</Demo>

### orientation

기본값 `vertical`은 단계 수에도, 각 단계에 대해 할 말의 양에도 제한이 없습니다. `horizontal`은 결제 화면 위쪽을 가로지르는 stepper이고, 모든 라벨이 짧을 때만 정직합니다.

**반응형입니다.** 그래서 한 집합이 폰에서는 이쪽으로, 노트북에서는 저쪽으로 갈 수 있습니다. <Fw react="서버는 xs 항목을 렌더링하고 브라우저가 hydration에서 고칩니다." flutter="build에서 창 너비를 기준으로 풀리므로 첫 프레임부터 정확합니다." /> [브레이크포인트](../../design/breakpoints) 참고.

<Demo src="timeline/orientation" :min-height="160">

::: fw react

<<< @/.vitepress/demos/timeline/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline/orientation.dart

:::

</Demo>

### size

<Demo src="timeline/sizes" :min-height="240">

::: fw react

<<< @/.vitepress/demos/timeline/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- 이것이 존재하는 이유 그대로 `<ol>`입니다. 순서가 **곧** 내용입니다. 순서 없는 목록 위에서 "5개 항목 목록"이라고 읽는 스크린리더는 다른 것을 설명하고 있는 셈입니다.
- `role="list"`를 명시적으로 씁니다. Tailwind의 리셋이 모든 `<ol>`에서 마커를 없애고, Safari는 그와 함께 목록 의미까지 없애기 때문입니다.
- 현재 단계는 `aria-current="step"`을 답니다. 순서에 맞는 값이 그것입니다. `"page"`는 문서의 자취이고 `"true"`는 선택지 중 하나입니다.
- bullet과 연결선은 `aria-hidden`입니다. 상태는 `aria-current`와 각 단계의 글에 담기고, 모양만으로 전달되지 않습니다.
- 아래에 Base UI 프리미티브가 없습니다. timeline에는 선택도, roving focus도, 키보드 규약도 없고, 복합 프리미티브를 끌어오면 사건의 기록에 위젯의 의미를 붙이게 됩니다.

:::

::: fw flutter

- 단계는 순서대로 읽힙니다. 그것이 이 순서열이 가진 전부입니다. 각 단계는 자기 노드입니다.
- bullet과 연결선은 semantics에서 제외됩니다. 숫자로 그려진 bullet은 단계의 제목이 이미 알리지 않는 것을 스크린리더에 더해 주지 않습니다.
- 알아 둘 만한 결과가 여기 있습니다. **상태는 스크린리더에 전달되지 않습니다.** Flutter의 semantics 트리에는 순서열을 위한 `current`가 없으므로, 끝난 단계와 남은 단계가 같은 방식으로 읽힙니다. 상태가 중요한 자리라면 말로 하세요: 단계의 `meta`에, 또는 본문에.
- timeline에는 선택도, roving focus도, 키보드 규약도 없고, 그런 것을 주장하지도 않습니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `<PlTimelineItem>` children | 설명으로서의 `items` | 어느 단계가 끝났는지는 인덱스 계산이고, 마지막 연결선은 자기가 마지막임을 알아야 합니다. 둘 다 `Widget`에는 물어볼 수 없습니다. |
| `aria-current="step"` | — | Flutter의 semantics 트리에는 `current`가 없습니다. 상태가 중요한 자리에서는 단계의 글로 말하세요. |
| `<ol>`과 `role="list"` | 묶인 semantics 노드 | 리셋할 마커도, 리셋이 앗아 갈 목록 의미도 없습니다. |
| `dashed`/`dotted`인 `border` | 칠해진 선 | `BorderSide`에는 점선이 없어서, 마디를 같은 굵기로 직접 놓습니다. |
| `render` | — | Flutter에는 요소를 바꿔 끼우는 수단이 없습니다. |
| 단계의 `children` | `child` | Flutter의 이름입니다. |

:::
