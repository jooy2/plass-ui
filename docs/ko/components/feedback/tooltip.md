---
title: PlTooltip
order: 6
---

# PlTooltip

<p class="plass-lede">포인터가 무언가에 머무를 때 나타나는 짧은 라벨입니다. 컴포넌트 전체가 감싸개일 뿐이라 레이아웃에 요소를 더하지 않고, 자식은 원래의 그것으로 남습니다.</p>

<Demo src="tooltip/hero" :min-height="140" />

::: fw react

```tsx
import { PlTooltip } from 'plass-ui';

<PlTooltip content="Copy to clipboard">
  <PlButton aria-label="Copy">
    <CopyIcon />
  </PlButton>
</PlTooltip>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlTooltip(
  content: const Text('Copy to clipboard'),
  child: PlButton(
    semanticLabel: 'Copy',
    onPressed: copy,
    child: const PlIcon(icon: CopyGlyph()),
  ),
);
```

tooltip은 판을 트리 밖으로 들어 올리므로 위쪽에 `Overlay`가 필요합니다 — navigator가 있는 `WidgetsApp`과 `MaterialApp`이 둘 다 제공합니다. 감싸개 자체는 레이아웃에 상자를 더하지 않습니다.

:::

## Props

<PropsTable name="PlTooltip" />

::: fw react

네이티브 `<div>` 속성은 판에 그대로 전달됩니다. `color`, `content`, `children`은 셋 다 여기서는 Plass의 prop이라 전달 대상에서 제외됩니다.

:::

::: fw flutter

`open`은 `bool?`이고, 기본값인 `null`은 tooltip이 포인터와 길게 누르기, focus로 자기를 움직인다는 뜻입니다. **패키지에서 컴포넌트가 자기 상태를 쥐는 유일한 자리**입니다 — 나머지가 전부 controlled인 이유는 값에 대해 호출하는 쪽이 의견을 갖기 때문인데, 포인터가 버튼 위에 머물러 있는지에 대해서는 아무도 의견이 없습니다. `onOpenChanged`는 어느 쪽이든 보고합니다.

`color`는 없습니다. tooltip은 무언가에 대한 메모이지 그 무언가 자체가 아니므로 판은 언제나 중립적인 시트입니다 — 삭제 버튼 위의 빨간 tooltip은 tooltip이 알지 못하는 것을 말하고 있는 것입니다.

:::

`variant`도 `elevation`도 없습니다. 판은 `PlSelect`의 popup과 같은 떠 있는 시트입니다 — 가장 불투명한 유리, 그 둘레의 흰 헤어라인, 사다리 꼭대기의 그림자 — 대부분의 라이브러리가 tooltip을 그리는 채워진 키가 아닙니다. tooltip은 무언가에 **대한** 메모이지 누르는 물건이 아니고, 한 화면에 떠 있는 시트가 두 종류인 것은 하나가 너무 많은 것입니다.

라이브러리 전체에서 공유 축(<Fw react="`size` `color` `density` `side` `align`" flutter="`size` `density` `side` `align`" />)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### side와 align

`side`는 자리가 없으면 반대편 변으로 뒤집힙니다. 그것이 옳은 동작입니다 — 화면 밖으로 반쯤 나간 tooltip은 아무 말도 하지 않습니다.

::: fw flutter

**뒤집을 뿐 미끄러지지는 않습니다.** 요청한 쪽에 자리가 없으면 판은 반대편으로 가고, 자기가 놓인 변을 따라 옆으로 밀리지는 않습니다. 미끄러지려면 판의 위치를 매 프레임 뷰포트에 대해 다시 계산해야 하는데, 스크롤하는 앵커에 판을 붙여 두는 layer link가 존재하는 이유가 바로 그것을 피하기 위해서입니다 — 그리고 트리거가 가장자리에 가까워질수록 옆으로 기어가는 판은 쐐기가 아무것도 가리키지 않는 판입니다.

:::

<Demo src="tooltip/sides" :min-height="200">

::: fw react

<<< @/.vitepress/demos/tooltip/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tooltip/sides.dart

:::

</Demo>

<Demo src="tooltip/align" :min-height="180">

::: fw react

<<< @/.vitepress/demos/tooltip/align.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tooltip/align.dart

:::

</Demo>

### PlTooltipProvider

여러 tooltip이 하나의 delay를 나눠 씁니다. 그중 하나가 한 번 열리고 나면 이웃들은 즉시 열리고, 잠시 쉬면 기다림이 다시 돌아옵니다.

툴바를 감쌀 만합니다. 이것이 없으면 아이콘 버튼이 늘어선 줄을 따라 움직일 때마다 매번 delay를 끝까지 기다려야 하고, 그것이 tooltip이 포인터와 싸우는 것처럼 느껴지게 만드는 이유입니다.

<PropsTable name="PlTooltipProvider" />

<Demo src="tooltip/provider" :min-height="120">

::: fw react

<<< @/.vitepress/demos/tooltip/provider.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tooltip/provider.dart

:::

</Demo>

### delay, closeDelay, disabled

`disabled`는 트리거는 그대로 두고 tooltip만 열리지 않게 합니다 — 라벨이 잘렸을 때만 존재하는 tooltip을 위한 것입니다.

::: fw flutter

두 delay는 숫자가 아니라 `Duration`입니다. **길게 눌러** 연 tooltip은 자기 시계를 따릅니다. 손가락이 떨어진 뒤에도 1.5초 동안 남아 있는데, 포인터가 떠나는 것은 읽기를 그만둔 독자이고 손가락이 떨어지는 것은 이제 막 읽기 시작한 독자이기 때문입니다.

:::

<Demo src="tooltip/delay" :min-height="120">

::: fw react

<<< @/.vitepress/demos/tooltip/delay.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tooltip/delay.dart

:::

</Demo>

### size

<Demo src="tooltip/sizes" :min-height="220">

::: fw react

<<< @/.vitepress/demos/tooltip/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tooltip/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- 판에는 `role="tooltip"`이, 트리거에는 그것을 가리키는 `aria-describedby`가 붙습니다 — **열려 있는 동안에만**입니다. 문서에 없는 요소를 가리키는 참조는 아무것도 가리키지 않는 참조이기 때문입니다. Base UI는 popup이 여러 가지일 수 있어 둘 다 호출하는 쪽에 맡기지만, 여기서는 언제나 tooltip이므로 컴포넌트가 직접 연결합니다.
- Base UI의 Trigger는 자기 상자를 그리는 대신 자식에 합쳐집니다. 그래서 tooltip은 레이아웃에 요소도, 자기 tab stop도 더하지 않습니다.
- focus에서 열리되 클릭에서 온 focus에서는 열리지 않고, Escape에서 닫힙니다. 셋 다 프리미티브의 것입니다.
- **tooltip은 라벨이 아닙니다.** 설명할 뿐 이름을 붙이지 않습니다. 아이콘만 있는 버튼에는 자기 `aria-label`이 따로 필요합니다 — 접근 가능한 이름이 없는 트리거는 음성 제어로 도달할 수 없고, tooltip은 그 이름을 대신 줄 만큼 페이지에 늘 있지 않습니다.
- tooltip 안의 무엇도 누를 수 없고, 터치 화면에는 머무를 포인터가 없습니다. 둘 중 하나가 필요한 내용은 자리를 지키는 곳에 있어야 합니다.

:::

::: fw flutter

- 판이 말하는 것은 **트리거**가 자기 tooltip으로 나릅니다. 스크린리더가 그것을 얻는 방법이 그것입니다. 판 자체는 semantics에서 제외되는데, 떠 있는 노드가 같은 문구를 되풀이하면 스크린리더가 그것을 두 번 읽기 때문입니다. `content`가 `Text`이면 그 문자열이 알아서 쓰이고, 그 외에는 `semanticLabel`이 필요합니다.
- 감싸개는 레이아웃에 상자도, 자기 focus stop도 더하지 않습니다. 자식은 원래의 그것으로 남습니다.
- hover와 길게 누르기, focus에서 열리고, 그중 무엇이 끝나든 판은 사라집니다.
- **tooltip은 라벨이 아닙니다.** 설명할 뿐 이름을 붙이지 않습니다. 아이콘만 있는 버튼에는 자기 `semanticLabel`이 따로 필요합니다 — 자기 이름이 없는 트리거는 무엇도 읽어 줄 수 없는 트리거입니다.
- tooltip 안의 무엇도 누를 수 없고, 터치 화면에는 머무를 포인터가 없습니다. 둘 중 하나가 필요한 내용은 자리를 지키는 곳에 있어야 합니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `open` / `defaultOpen` / `onOpenChange` | `open: bool?` / `onOpenChanged` | `null`이 tooltip이 스스로를 움직이는 상태, 즉 uncontrolled였던 것입니다. 값을 주면 넘겨받습니다. |
| 밀리초인 `delay`, `closeDelay` | `Duration` | 시간 길이에 대한 Dart 자신의 타입입니다. |
| `role="tooltip"`과 `aria-describedby` | 트리거 자신의 tooltip | Flutter는 상태를 노드 자체에 적습니다. 가리킬 id가 없고, 판은 제외되어 문구가 한 번만 읽힙니다. |
| 판이 읽어 주는 `content` | 그려지는 `content`와 읽히는 `semanticLabel` | 위젯은 읽어 줄 수 없습니다. `Text`는 문자열을 알아서 내주고, 그 외에는 뜻하는 바를 적습니다. |
| `color` | — | 내용이 읽던 슬롯에만 닿았고, 여기서 내용은 자기 색을 가지고 옵니다. |
| 두 축 모두의 충돌 처리 | 미끄러짐 없는 뒤집기 | 미끄러지려면 매 프레임 뷰포트에 대해 위치를 다시 계산해야 하고, 트리거에서 벗어난 쐐기는 아무것도 가리키지 않습니다. |
| focus에서 열되 클릭에서 온 focus에서는 안 열림 | focus에서 열림 | tooltip이 감싸는 노드에서 "이 focus는 포인터에서 왔다"에 해당하는 것이 Flutter에는 없습니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 클래스 목록도 style 속성도 없습니다. |

delay 그룹은 여기에도 같은 이름으로 있습니다. 툴바를 `PlTooltipProvider`로 감싸세요.

:::
