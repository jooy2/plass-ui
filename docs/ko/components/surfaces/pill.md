---
title: PlPill
order: 8
---

# PlPill

<p class="plass-lede">살아 있는 정보를 조금 담고 떠 있는 알약입니다. 돌아가고 있는 녹화, 올라가고 있는 업로드, 아직 읽지 않은 알림 두 개.</p>

<Demo src="pill/hero" :min-height="140" />

::: fw react

```tsx
import { PlPill } from 'plass-ui';

<PlPill color="danger" title="Recording" description="00:41" startIcon={<Dot />} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlPill(
  color: PlassColor.danger,
  title: const Text('Recording'),
  description: const Text('00:41'),
  startIcon: const RecordingDot(),
);
```

:::

## Props

<PropsTable name="PlPill" />

::: fw react

나머지 `<div>` 속성은 모두 껍데기로 전달됩니다.

:::

라이브러리 전체에서 공유하는 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 스타디움 모양

모양은 **스타디움**입니다 — 반경이 정확히 행 높이의 절반 — 그리고 하우스 반경 규칙은 원래 그것을 금지합니다. 모든 컨트롤은 알약이 되어 버릴 50%에서 조금 못 미치게 유지되는데, 위아래 가장자리를 따라 남는 평평한 구간이 여전히 "모서리를 깎은 시트"로 읽히게 하는 것이기 때문입니다.

여기가 그 규칙이 겨누고 있던 예외이고, 규칙이 성립하는 것과 같은 이유로 성립합니다. **이것은 페이지 위에 놓인 시트가 아닙니다.** 페이지 위에 떠 있는 물건이고, 페이지 위에 떠 있는 물건이 페이지와 같은 재료에서 잘려 나온 것처럼 보여서는 안 됩니다. 떠 있는 바도 자기 캡슐에 대해 같은 주장을 합니다.

반경은 `rounded-full`이 아니라 **행**에 고정되어 있고, 그 차이는 알약이 자라야 비로소 드러납니다. 두 번째 줄이 생긴 상자에서 높이의 절반짜리 모서리는 모든 줄의 앞 두 단어를 잡아먹습니다. 행에 고정해 두는 것이 알약을 원래 갖고 있던 그 모서리 그대로 둥근 사각형으로 자라게 합니다.

`elevation`의 기본이 `2`인 것도 같은 이유입니다 — 자기가 떠 있는 내용 위에 평평하게 누운 알약은 실수로 읽힙니다.

## Examples

### variant

세 재질을 **컨트롤**의 방식으로 말합니다. 표면이 색을 받습니다. [`PlButton`](../inputs/button)이나 [`PlChip`](../display/chip)과 같습니다 — 알약은 남의 내용을 담은 시트가 아니라, 색이 입혀지는 그 물건 자체이기 때문입니다.

<Demo src="pill/variants" :min-height="280">

::: fw react

<<< @/.vitepress/demos/pill/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pill/variants.dart

:::

</Demo>

### 세 개의 슬롯

`startIcon`은 원으로 잘린 정사각형 상자입니다. 그래서 글리프만큼이나 이미지도 자연스럽게 들어갑니다 — 상자를 채우고 레터박스 대신 잘리는데, 20px짜리 인물 사진이 원하는 것이 그것입니다.

`title`과 `description`은 **가운데**입니다. 자기 열 안에서 중앙 정렬되고, 양옆 이웃에서 컨트롤 트랙의 약 두 배만큼 떨어져 있습니다. 글리프와 뒤쪽 슬롯은 알약의 가구이고, 알약이 *무엇에 대한 것인지*는 그 사이의 열입니다.

`endIcon`은 누를 수 있는 영역 **바깥**에 있어서 그 자체가 컨트롤일 수 있습니다 — 정지 버튼이나 닫기. 버튼 안의 버튼은 브라우저가 파싱하면서 다시 쓰는 마크업입니다.

### details

`expanded`일 때 드러나는 나머지 절반입니다. 알약은 다른 모양으로 바뀌는 대신 아래로 자랍니다. 한 물건이 더 말하는 것입니다.

높이는 어딘가에 적어 둔 숫자가 아니라 **본문 자신의 것**입니다. 그래서 내용이 바뀌는 details 영역(살아 있는 정보가 하는 일이 그것입니다)도 함께 자랍니다. 그리고 아무것도 변형되지 않습니다. [`PlCollapsible`](./collapsible)의 패널이 그렇듯, 알약은 열리는 창입니다.

::: fw react

내용이 바뀌어도 잰 높이가 정직하게 유지되도록 `ResizeObserver`가 지켜봅니다.

:::

<Demo src="pill/details" :min-height="220">

::: fw react

<<< @/.vitepress/demos/pill/details.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pill/details.dart

:::

</Demo>

### size

접힌 알약은 같은 `size`의 [`PlButton`](../inputs/button)과 나란히 놓았을 때 줄이 맞습니다 — 행의 바닥이 컨트롤 사다리입니다. 높이가 아니라 **최솟값**인데, description을 단 알약은 두 줄 높이이고 고정 높이였다면 두 번째 줄이 잘렸을 것이기 때문입니다.

<Demo src="pill/sizes" :min-height="300">

::: fw react

<<< @/.vitepress/demos/pill/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pill/sizes.dart

:::

</Demo>

### 너비

::: fw react

알약은 `inline-flex`이므로 어디에 두든 늘 내용만큼 넓습니다 — block 안이든 flex row 안이든. 너비를 주고 싶다면 너비가 있는 것 안에 넣으세요.

:::

::: fw flutter

**알약은 주어진 너비를 채우고, 주어지지 않은 곳에서는 자기 너비를 가집니다.** `SizedBox` · `PlCard` · `Wrap` 안에서는 제공된 자리를 채우므로, 카드가 늘어선 열 안의 알약은 카드와 줄이 맞습니다. `Row` 안이나 모서리 하나만 지정한 `Positioned` 안에서는 채울 너비가 없고, 알약은 자기 가장 넓은 부분만큼만 넓습니다.

```dart
Stack(
  children: <Widget>[
    const MyScreen(),
    PositionedDirectional(
      top: 16,
      start: 16,
      child: PlPill(title: const Text('Recording'), description: const Text('00:41')),
    ),
  ],
)
```

어느 쪽도 `Expanded`나 `SizedBox`로 감쌀 필요가 없습니다. loose constraint도 너비로 치므로 `Wrap`에 담은 알약들은 행이 아니라 열이 됩니다 — 그쪽을 원했다면 [`PlChip`](../display/chip)을 쓰세요.

:::

::: fw react

### position

`static`은 흐름 안에 둡니다. `sticky`는 페이지가 거기까지 스크롤되면 가장자리에 붙잡아 둡니다. `fixed`는 뷰포트에 고정하고 가운데 놓는데, 이 모양이 존재하는 이유가 그 배치입니다.

가운데 놓기는 자기 너비의 절반만큼 translate하는 것이 아니라 전폭 상자 안의 `mx-auto`입니다. [표면을 변형하지 않는다는 규칙](../../design/design-language)이 여기서도 지켜지고, `auto` 마진은 방향에 무관하므로 RTL에서도 알약은 가운데 있습니다.

```tsx
<PlPill position="fixed" side="bottom" title="Recording" />
```

:::

::: fw flutter

여기에는 `position`이 없습니다. [`PlFloatingBottomNavigation`](../navigation/floating-bottom-navigation)에 없는 것과 같은 이유입니다 — `fixed` 요소는 가운데 놓이려면 무언가를 가로질러야 하는데, Flutter 위젯은 화면이 놓아 준 바로 그 자리에 있습니다. 고정된 알약이 놓이는 자리는 `Positioned`가 든 `Stack`이고, 그것은 앱의 것입니다.

:::

## Accessibility

- 누를 것이 없는 알약은 컨트롤이 아니고 아무것도 주장하지 않습니다. 핸들러를 주면 가운데가 진짜 버튼이 되어 키보드로 닿을 수 있고 그것으로 안내됩니다.
- `endIcon`은 그 버튼 바깥에 있으므로 거기 놓인 컨트롤은 자기 focus stop을 가집니다.
- 접힌 `details` 패널은 포커스 순서에서 빠지고 **동시에** 접근성 트리에서도 빠집니다. 높이 0인 상자 안에서도 내용은 여전히 완벽하게 포커스를 받고, 스크린 리더에서만 숨겼다면 없다고 들은 자리로 키보드 독자가 탭해 들어갔을 것입니다.

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `position`, `side` | — | `fixed` 요소는 가운데 놓이려면 무언가를 가로질러야 합니다. Flutter 위젯은 화면이 놓아 준 자리에 그대로 있고, 고정된 알약은 앱 자신의 `Stack` 속 `Positioned`입니다. |
| `onClick` | `onPressed` | 누름이 부르는 것에 이 패키지가 붙인 이름입니다. |
| `children` | `child` | 슬롯 하나이고, Dart는 그것을 `child`라고 씁니다. |
| 접힌 패널의 `inert` | `ExcludeFocus` + `ExcludeSemantics` | 그 속성이 하는 두 가지를, 그 두 가지를 하는 위젯으로 말한 것입니다. |
| `className`, `style` | — | 전달할 class 목록도 style 속성도 없습니다. |
| 늘 내용만큼 넓음 | 주어진 너비를 채움 | `inline-flex`는 어디에 두든 내용에 맞춰 줄어듭니다. 너비를 제안받은 Flutter widget은 그것을 받는 것이 프레임워크의 관례입니다 — 두 경우와 각각의 쓰임은 [너비](#너비)를 보세요. |

:::
