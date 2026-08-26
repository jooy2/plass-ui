---
title: PlChip
order: 10
---

# PlChip

<p class="plass-lede">작고 촘촘한 토큰입니다 — 태그, 필터, 상태, 목록에서 집어낸 개체 하나. 개수를 달 수도, 눌릴 수도, 지워질 수도, 셋 다일 수도 있습니다.</p>

<Demo src="chip/hero" :min-height="180" />

::: fw react

```tsx
import { PlChip } from 'plass-ui';

<PlChip>design</PlChip>;
<PlChip selected onClick={toggle} count={12}>
  open
</PlChip>;
<PlChip onDelete={remove}>infra</PlChip>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlChip(child: Text('design'));
PlChip(selected: on, onPressed: toggle, count: const Text('12'), child: const Text('open'));
PlChip(onDeleted: remove, child: const Text('infra'));
```

:::

## Props

<PropsTable name="PlChip" />

::: fw react

네이티브 `<span>` 속성은 껍데기에 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 전달 대상에서 제외됩니다.

:::

::: fw flutter

`count`는 숫자가 아니라 `Widget?`입니다. 배지의 것과 달리 잘리는 일이 없고, 판은 받은 것을 그대로 담습니다.

:::

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### <Fw react="onClick과 onDelete" flutter="onPressed와 onDeleted" />

::: fw react

껍데기는 언제나 `<span>`입니다. 바뀌는 것은 그 안에 든 것입니다 — 그냥 내용이 놓이거나, `onClick`이 주어지면 그 내용을 감싸는 진짜 `<button>`이 놓이고, `onDelete`를 위한 두 번째 버튼이 붙습니다.

이것은 불필요한 겹침이 아닙니다. `<button>` 안의 `<button>`은 브라우저가 파싱하면서 풀어 버리는 잘못된 HTML이고, 껍데기를 `<span>`으로 두는 것이 "이 chip을 실행한다"와 "이 chip을 지운다"를 둘 다 진짜 focus 가능한 버튼으로 만드는 방법입니다.

:::

::: fw flutter

누를 수 있는 chip과 지울 수 있는 chip은 서로 다른 두 개의 focus stop이고, 어느 쪽도 다른 쪽의 제스처 인식기 안에 들어 있지 않습니다. 이유는 React 빌드가 껍데기를 `<span>`으로 두는 이유와 같은 것을 반대편에서 만난 것입니다 — 둘 다에 닿는 탭 하나는 둘 다를 실행합니다.

`onPressed`가 없는 chip은 focus stop을 가지지 않고 버튼이 아니라 내용으로 알려집니다. 그것은 태그이고, 태그는 누르는 것이 아닙니다.

:::

<Demo src="chip/interactive" :min-height="140">

::: fw react

<<< @/.vitepress/demos/chip/interactive.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/interactive.dart

:::

</Demo>

### variant

chip은 색을 입는 **대상 자체**입니다 — 태그는 특정한 하나를 가리킵니다 — 그래서 `PlCard`와 달리 시트가 틴트를 받습니다. `ghost`는 맨몸이 아니라 쉬는 상태에서도 옅은 색을 지니는데, 그것이 토큰과 컨트롤의 차이입니다. ghost **버튼**은 포인터가 오기 전까지 아무것도 없습니다.

기본값이 `solid`가 아니라 `glass`입니다. 필터 바는 chip이 늘어선 줄이고, 그러데이션 키가 늘어선 줄에서는 전부가 주요 액션이라서 아무것도 주요 액션이 아닙니다.

<Demo src="chip/variants" :min-height="120">

::: fw react

<<< @/.vitepress/demos/chip/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/variants.dart

:::

</Demo>

### selected

선택은 색 계열을 바꾸는 대신, 그 variant가 이미 놓여 있는 사다리에서 한 칸 올라갑니다. 켜진 필터도 여전히 같은 필터이기 때문입니다.

`solid`에는 올라갈 불투명도 사다리가 없습니다 — 그러데이션 fill이 곧 fill입니다. 그래서 디자인 언어가 허용하는 다른 방식으로 답합니다. 아래 시트에 자기 색을 드리우는 것입니다. 선택된 키는 떠오르고, 선택되지 않은 키는 납작하게 놓입니다.

<Demo src="chip/selected" :min-height="200">

::: fw react

<<< @/.vitepress/demos/chip/selected.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/selected.dart

:::

</Demo>

### startIcon, endIcon, count

`count`는 자기 판 위에 그려집니다. 그래서 "Errors 12"가 두 단어가 아니라 개수를 가진 하나의 토큰으로 읽힙니다.

<Demo src="chip/slots" :min-height="120">

::: fw react

<<< @/.vitepress/demos/chip/slots.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/slots.dart

:::

</Demo>

### color

<Demo src="chip/colors" :min-height="120">

::: fw react

<<< @/.vitepress/demos/chip/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/colors.dart

:::

</Demo>

### size

chip은 나머지 모든 것보다 컨트롤 사다리에서 한 칸 아래에 놓입니다 — `md` chip은 `sm` 컨트롤이고, 40px가 아니라 32px입니다. 컨트롤 높이를 그대로 쓰면 `glass` chip과 `glass` 버튼은 같은 물체가 되고, 그런 것으로 가득한 화면은 무엇을 누를 수 있는지 아무 말도 하지 않습니다.

<Demo src="chip/sizes" :min-height="120">

::: fw react

<<< @/.vitepress/demos/chip/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- `onClick`이 있는 chip은 `aria-pressed`를 가진 진짜 `<button>`이라, 켜진 필터가 켜졌다고 말합니다. 없는 chip은 role도 tab stop도 더하지 않습니다 — click 핸들러만 달린 죽은 `<span>`은 컴포넌트 라이브러리가 키보드 사용자를 잃는 가장 흔한 경로입니다.
- 라벨과 삭제 버튼은 서로 다른 두 개의 tab stop이고, 어느 쪽도 다른 쪽 안에 들어 있지 않습니다.
- 삭제 버튼에는 이미 접근 가능한 이름이 있습니다. `deleteLabel`은 그것을 바꾸는 prop입니다.
- `disabled`는 라벨을 아예 버튼이 아니게 만듭니다. focus는 되는데 아무 일도 안 하는 버튼을 남기는 대신입니다. 그리고 껍데기에 `aria-disabled`를 붙여 상태는 여전히 읽히게 합니다.

:::

::: fw flutter

- `onPressed`가 있는 chip은 버튼으로 알려지고 선택 여부를 보고하므로, 켜진 필터가 켜졌다고 말합니다. 없는 chip은 role도 focus stop도 더하지 않습니다.
- 라벨과 삭제 표시는 서로 다른 두 개의 focus stop이고, 어느 쪽도 다른 쪽 안에 들어 있지 않습니다.
- 삭제 표시에는 이미 이름이 있습니다 — "Remove". `deleteLabel`은 그것을 바꿉니다.
- <kbd>Enter</kbd>, <kbd>Space</kbd>, 넘패드 <kbd>Enter</kbd>가 누를 수 있는 chip을 실행합니다. chip 자신에 묶여 있으므로 위에 app 위젯이 있든 없든 똑같이 동작합니다.
- `disabled`는 chip을 focus 순서에서 빼고 실행되지 않게 하며, 삭제 표시도 함께 잠급니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `onClick` | `onPressed` | Flutter의 이름입니다. |
| `onDelete` | `onDeleted` | 같은 자리에 대한 Flutter의 이름입니다. |
| `<span>` 안의 `<button>` | 형제인 focus stop 둘 | 같은 이유의 같은 모양입니다. HTML은 그 중첩을 금지하고, 여기서는 중첩된 인식기가 탭 하나를 두 번 받습니다. |
| `ReactNode`인 `count` | `Widget?`인 `count` | 같은 것을 Flutter로 쓴 것입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
