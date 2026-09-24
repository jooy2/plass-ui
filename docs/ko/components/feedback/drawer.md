---
title: PlDrawer
order: 7
---

# PlDrawer

<p class="plass-lede">창의 한 가장자리에 붙은 판입니다. 한 컴포넌트에 두 가지가 들어 있는데, 사실 같은 판이기 때문입니다: 열어서 쓰는 서랍과, 그냥 페이지의 일부인 서랍.</p>

<Demo src="drawer/hero" :min-height="140" />

::: fw react

```tsx
import { PlButton, PlDrawer, PlDrawerClose } from 'plass-ui';

<PlDrawer side="right" trigger={<PlButton>Filters</PlButton>} title="Filters">
  Everything you can narrow by.
</PlDrawer>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlDrawer(
  side: PlassSide.right,
  open: filtering,
  onOpenChanged: (bool next) => setState(() => filtering = next),
  title: const Text('Filters'),
  child: const FilterForm(),
);
```

:::

## Props

<PropsTable name="PlDrawer" />

::: fw react

나머지 `<div>` 속성은 모두 판으로 전달되고, `className`도 마찬가지입니다. overlay 모드에서 판 뒤에 깔리는 scrim은 같은 portal 안의 다른 요소이므로 `classNames.backdrop`으로 닿습니다. inline 모드에는 그 scrim이 없습니다.

:::

판이 무엇인지는 `mode`가 정하고, 그 밖의 모든 것은 두 mode에서 같습니다.

- **`overlay`**: 열어서 쓰고, 스크림 위에서 페이지 위에 떠 있고, 포커스를 붙잡고, 닫힙니다. 메뉴 버튼 뒤의 내비게이션 서랍, 표 옆의 필터 판이 이것입니다.
- **`inline`**: 레이아웃의 일부이고 페이지가 그 주위로 배치됩니다. 스크림도, 포커스 트랩도, 닫을 것도 없습니다. 그냥 거기 있는 사이드바입니다.

그래서 브레이크포인트에서 메뉴 버튼으로 바뀌는 사이드바는 컴포넌트를 바꾸지 않고 `mode`만 바꿉니다.

::: fw react

`defaultOpen`은 `mode`를 따라 `overlay`에서는 `false`, `inline`에서는 `true`입니다.

:::

`variant`도 `elevation`도 없습니다. `overlay` 서랍은 사다리 맨 위의 그림자를 달고, `inline` 서랍은 그림자가 없습니다. 판은 페이드로만 나타나고 사라지며 미끄러지지 않습니다. 두 가지의 이유는 [디자인 언어](../../design/design-language)에 있습니다.

라이브러리 전체에서 공유하는 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## Examples

### mode

`inline`은 판을 레이아웃 안에 놓고, 페이지는 그 옆으로 배치됩니다.

<Demo src="drawer/inline" :min-height="300">

::: fw react

<<< @/.vitepress/demos/drawer/inline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/drawer/inline.dart

:::

</Demo>

### side

`PlassSide`가 어디서나 그렇듯 논리적이 아니라 물리적입니다. 창 위쪽을 따라 놓인 서랍은 어떤 쓰기 방향에서도 위쪽에 있습니다.

판은 **창 쪽은 각지고 자유로운 쪽은 둥글게 깎여** 있습니다. 페이지를 향한 모서리는 하우스 필렛을 받고, 가장자리에 붙은 둘은 받지 않습니다. 얇은 선도 같은 규칙을 따라 자유로운 가장자리에만 그려집니다.

`left`나 `right` 판은 `size`가 뜻하는 너비를 가지고, `top`이나 `bottom` 판은 안에 든 것만큼 높되 창의 85%까지입니다. 세 줄이 든 바텀 시트는 세 줄 높이여야 합니다. `extent`가 어느 쪽이든 덮어씁니다.

<Demo src="drawer/sides" :min-height="140">

::: fw react

<<< @/.vitepress/demos/drawer/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/drawer/sides.dart

:::

</Demo>

### dividers

헤더와 본문과 액션 사이를 여백 대신 얇은 선으로 가릅니다. 본문이 스크롤되기 시작하는 순간부터 켤 만합니다. 헤더가 제자리에 있었다고 말해 주는 것이 그 선입니다.

어느 쪽이든 스크롤되는 것은 본문뿐입니다.

## Accessibility

- `overlay` 서랍은 떠 있는 동안 포커스를 붙잡고, 나갈 때 원래 자리로 돌려주며, 뒤의 화면을 가져갑니다.
- `description`이 설명하고 `title`은 heading으로 안내됩니다. 둘 다 그냥 근처에 놓이는 것이 아니라 판에 연결됩니다.
- `inline` 서랍은 dialog가 **아니고** 그 어느 것도 선언하지 않습니다. 레이아웃 속의 판이고, 제목도 평범한 제목입니다.
- `dismissible={false}`는 Escape도 스크림 누름도 거절합니다. 그 둘을 거절하는 서랍에는 그것에 답할 액션을 주세요. 다른 출구가 없습니다.

::: fw react

- `title`이 서랍의 이름이 됩니다.
- 포커스 트랩, 스크롤 잠금, `aria-labelledby` / `aria-describedby` 연결, 뒤 페이지의 inert 처리는 전부 Base UI의 것입니다. `modal="trap-focus"`는 포커스는 안에 붙잡아 두면서 페이지는 스크롤하고 클릭할 수 있게 남겨 둡니다.
- `PlDrawerClose`는 uncontrolled 서랍의 Cancel 버튼이 부를 것이 있도록 존재합니다. `render`가 그것을 진짜 Plass 버튼으로 만듭니다: `<PlDrawerClose render={<PlButton variant="ghost">Cancel</PlButton>} />`.

:::

::: fw flutter

- `label`은 `overlay` 서랍을 안내할 때 쓰는 이름입니다. `title`은 위젯이라 넘겨줄 글자가 없으므로, `label`이 없는 서랍은 이름 없이 열립니다. 제목과 같은 말을 주세요.
- 들어 올리기, 스크림, focus scope, <kbd>Escape</kbd>, 나갈 때 포커스를 되돌려주는 것은 전부 `PlassPortal`의 것입니다. `PlModal`과 `PlOverlay`가 서 있는 것과 같은 층이라, 오버레이 위에 열린 서랍에 이음매가 보이지 않습니다.

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `open` / `defaultOpen` / `onOpenChange` | `open` / `onOpenChanged` | Flutter의 컨트롤은 controlled이고, 이 패키지의 상태 있는 위젯도 전부 그렇습니다. |
| `trigger` | — | 여기서는 트리거를 연결할 *대상*이 없습니다. 앱이 `open`을 세워 서랍을 열고, 그 일을 하는 버튼은 앱의 것입니다. |
| `PlDrawerClose` | — | 저쪽에서는 _uncontrolled_ 서랍의 Cancel 버튼이 부를 것이 필요해서 있습니다. 여기서는 모든 서랍이 controlled이므로 버튼에는 이미 `onOpenChanged`가 있습니다. |
| `extent: number \| string` | `extent: double` | 픽셀은 픽셀 그대로입니다. 받을 CSS 길이가 없습니다. |
| `modal: boolean \| 'trap-focus'` | `modal: bool` | 달라지는 두 값은 "포인터를 막는다"와 "막지 않는다"입니다. Flutter에는 세 번째가 될 스크롤 잠금이 없습니다. |
| `className`, `style` | — | 전달할 class 목록도 style 속성도 없습니다. |

:::
