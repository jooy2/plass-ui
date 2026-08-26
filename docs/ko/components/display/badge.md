---
title: PlBadge
order: 7
---

# PlBadge

<p class="plass-lede">다른 무언가의 모서리에 놓이는 작은 표시입니다 — 받은편지함 아이콘 위의 안 읽은 메일, avatar 위의 상태 점, 탭 위의 개수. children이 없으면 대신 inline으로 놓이고, 그것이 독립된 상태 pill입니다.</p>

<Demo src="badge/hero" :min-height="160" />

::: fw react

```tsx
import { PlBadge, PlButton } from 'plass-ui';

<PlBadge content={4} label="4 unread notifications">
  <PlButton aria-label="Notifications">
    <BellIcon />
  </PlButton>
</PlBadge>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlBadge(
  count: 4,
  label: '4 unread notifications',
  child: PlButton(semanticLabel: 'Notifications', startIcon: const BellGlyph(), onPressed: open),
);
```

:::

## Props

<PropsTable name="PlBadge" />

::: fw react

네이티브 `<span>` 속성은 앵커를 감싸는 껍데기가 아니라 **마커**에 그대로 전달됩니다. `color`와 `content`는 둘 다 여기서는 Plass의 prop이라 전달 대상에서 제외됩니다.

:::

::: fw flutter

`content`와 `count`는 하나가 아니라 두 개의 파라미터입니다. `max`와 `showZero`는 숫자일 때만 뜻이 있고, React의 단일 prop은 런타임에 무엇을 받았는지 물어야 합니다. 여기서는 타입이 곧 그 질문이고, 둘 다 넘기는 것은 생성자가 단언으로 막는 오류입니다.

:::

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### content, max, showZero

<Fw react="content" flutter="count" code />는 보통 개수이고 가끔 단어입니다. `max`를 넘는 숫자는 `+`를 붙여 자르고, 단어는 그대로 둡니다 — 배지는 단어를 어떻게 잘라야 할지 알 수 없습니다.

`0`은 `showZero`를 켜지 않는 한 아무것도 그리지 않습니다. 안 읽은 메시지 0개는 소식이 아니고, 사라지지 않는 배지는 아무 뜻도 갖지 못하게 됩니다.

::: fw flutter

`invisible`인 배지는 자기 상자를 그대로 지킵니다 — `maintainSize`를 켠 `Visibility` — 그래서 다시 나타나도 주변이 움직이지 않습니다. 불투명도가 아니라 가시성인 이유는, 반쯤 흐려진 배지는 거기 있는지 확인하려고 눈을 가늘게 떠야 하는 배지이기 때문입니다.

:::

<Demo src="badge/counts" :min-height="140">

::: fw react

<<< @/.vitepress/demos/badge/counts.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/counts.dart

:::

</Demo>

### dot

내용을 생략하면 배지는 점이 됩니다 — 알릴 것은 있지만 셀 것이 없을 때의 정직한 모양입니다. `dot`은 내용이 **있어도** 점으로 만들고, 내용은 여전히 읽힙니다. 조용한 모서리가 말 없는 모서리는 아닙니다.

<Demo src="badge/dot" :min-height="140">

::: fw react

<<< @/.vitepress/demos/badge/dot.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/dot.dart

:::

</Demo>

### variant

배지는 색을 입는 대상 자체라 시트가 틴트를 받습니다 — alert이 그렇고, card는 그렇지 않습니다. 또한 라이브러리에서 pill이 되는 것이 허용된 유일한 컴포넌트입니다. Plass의 모서리는 **표면**에 잡힌 필렛이고, 배지는 그 표면 위에 놓인 표시이기 때문입니다.

<Demo src="badge/variants" :min-height="120">

::: fw react

<<< @/.vitepress/demos/badge/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/variants.dart

:::

</Demo>

### placement와 overlap

`placement`는 전부 논리적이라, 오른쪽에 고정되는 대신 쓰기 방향에 따라 모서리가 뒤집힙니다.

::: fw flutter

`transform`이 아니라 방향을 아는 `Stack`으로 고정합니다. React 빌드가 음수 margin으로 하는 것과 같은 선택입니다 — 컨트롤을 transform으로 움직이지 않는다는 집안 규칙은 절대적이고, 어느 쪽이든 모서리는 정렬 둘과 여백 한 쌍입니다.

:::

`overlap`은 아래에 놓인 것의 모양입니다. 원의 모서리는 배지가 기준으로 삼는 상자 안쪽으로 지름의 15%쯤 들어와 있어서, 아이콘 버튼에 맞춘 배지는 avatar 위에서 아래에 틈을 두고 떠 보입니다.

<Demo src="badge/placement" :min-height="160">

::: fw react

<<< @/.vitepress/demos/badge/placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/placement.dart

:::

</Demo>

<Demo src="badge/overlap" :min-height="140">

::: fw react

<<< @/.vitepress/demos/badge/overlap.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/overlap.dart

:::

</Demo>

### color

<Demo src="badge/colors" :min-height="120">

::: fw react

<<< @/.vitepress/demos/badge/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/colors.dart

:::

</Demo>

### size

컨트롤 사다리보다 훨씬 아래에 있는 자기 사다리입니다. 컨트롤의 높이는 **행**이 맞춰 서는 숫자이고, 배지는 아무것에도 맞춰 서지 않습니다 — 다른 것의 모서리에 매달릴 뿐입니다.

<Demo src="badge/sizes" :min-height="120">

::: fw react

<<< @/.vitepress/demos/badge/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- 종 옆의 `content={3}`은 "3"으로 읽히고, 그것만으로는 아무 뜻도 없습니다. `label="3 unread notifications"`를 주면 숫자 대신 그 문장이 읽힙니다.
- 점은 아무것도 그리지 않지만, 받은 `label`이나 `content` 중 하나는 그대로 읽습니다.
- `invisible`인 배지와 내용이 빈 배지는 접근성 트리에서 완전히 숨겨지고, 텍스트도 전혀 남기지 않습니다 — 잘려 있는 상자에 남은 텍스트는 페이지 내 찾기가 여전히 찾아내는 텍스트입니다.
- 배지는 role도 tab stop도 더하지 않습니다. 상호작용하는 것은 그 안의 앵커이고, 앵커는 호출하는 쪽의 요소입니다.
- 앵커를 감싸는 껍데기는 `inline-flex`이고 감싼 것과 정확히 같은 너비라, 배지가 붙은 아이콘 버튼도 옆의 맨 버튼과 그대로 줄을 맞춥니다.

:::

::: fw flutter

- 종 옆의 `count: 3`은 "3"으로 읽히고, 그것만으로는 아무 뜻도 없습니다. `label: '3 unread notifications'`를 주면 숫자 대신 그 문장이 읽힙니다.
- 점은 아무것도 그리지 않지만, 받은 `label`이나 개수 중 하나는 그대로 읽습니다.
- `invisible`인 배지와 내용이 빈 배지는 semantics 트리에서 완전히 제외됩니다.
- 배지는 role도 focus stop도 더하지 않습니다. 상호작용하는 것은 그 안의 앵커이고, 앵커는 호출하는 쪽의 위젯입니다.
- 앵커를 감싸는 껍데기는 앵커만으로 크기가 정해지므로, 배지가 붙은 아이콘 버튼도 옆의 맨 버튼과 그대로 줄을 맞춥니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `content` prop 하나 | `content`와 `count` | `max`와 `showZero`는 숫자일 때만 뜻이 있습니다. 파라미터가 둘이면 런타임의 `typeof` 대신 타입이 질문이 됩니다. |
| 음수 margin | 방향을 아는 `Stack` | 같은 이유의 같은 결정입니다 — 어느 쪽도 마커를 transform으로 움직이지 않습니다. |
| `visibility: hidden` | `Visibility(maintainSize: true)` | 같은 것을 Flutter의 말로 한 것입니다. 상자가 남으니 배지가 돌아와도 아무것도 움직이지 않습니다. |
| `children` | `child` | Flutter의 이름입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
