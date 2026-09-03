---
title: PlPanes
order: 4
---

# PlPanes

<p class="plass-lede">사이에 끌 수 있는 손잡이가 놓인 영역 묶음입니다. 분수로 크기가 정해져서, 창 크기가 바뀌어도 JavaScript 한 줄 돌지 않고 분할이 유지됩니다.</p>

<Demo src="panes/hero" :min-height="260" />

::: fw react

```tsx
import { PlPane, PlPanes } from 'plass-ui';

<PlPanes>
  <PlPane defaultSize="240px" minSize="180px" maxSize="50%">
    {sidebar}
  </PlPane>
  <PlPane>{body}</PlPane>
</PlPanes>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlPanes(
  panes: <PlPane>[
    PlPane(
      defaultSize: const PlPaneSize.pixels(240),
      minSize: const PlPaneSize.pixels(180),
      maxSize: const PlPaneSize.percent(50),
      child: sidebar,
    ),
    PlPane(child: body),
  ],
);
```

:::

## Props

<PropsTable name="PlPanes" />

### PlPane

<PropsTable name="PlPane" />

::: fw react

네이티브 `<div>` 속성은 둘 다 그대로 전달됩니다. 분할 쪽의 `color`는 거기서 Plass의 prop이라 제외됩니다.

:::

::: fw flutter

`PlPane`은 위젯이 아니라 **설명**입니다. 이 패키지가 아코디언의 접힘과 테이블의 열에 쓰는 관용구이고, 이유도 같습니다 — 세 크기 값을 읽는 것이 분할이라서, 분할이 그것을 읽을 수 있어야 합니다.

:::

pane도, 분할 자체도 자기 표면을 그리지 않습니다. 이것은 레이아웃이고, pane이 시트를 그리는 순간 `PlCard`나 `PlTable`이나 에디터를 담는 그릇으로 쓸 수 없게 됩니다. 표면이 필요하면 안에 `PlCard`를 넣으세요. 라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### 분할은 어떻게 재어지는가

pane의 크기는 **분수**이고, `flex-basis: calc((100% − 손잡이들) × 분수)`로 쓰입니다.

이 컴포넌트의 나머지 전부가 그 결정에서 따라 나옵니다. 백분율로 서술된 분할은 아무것도 실행되지 않아도 창 크기 변화를 견딥니다. 그래서 컴포넌트는 딱 두 번만 스스로를 잽니다 — 마운트 때 한 번, `'240px'` 기본값을 분수로 바꾸기 위해. 그리고 끌기가 시작될 때마다 한 번, 포인터가 1픽셀 움직이는 것이 얼마짜리인지 알기 위해.

::: fw react

측정은 한 번 읽는 대신 `ResizeObserver`입니다. 닫힌 `PlAccordion`이나 선택되지 않은 `PlTab` 안의 분할은 마운트될 때 너비가 0인데, 그것으로 나누면 모든 pane이 0이 되기 때문입니다.

:::

::: fw flutter

같은 발상을 Flutter가 더 어렵게가 아니라 더 쉽게 만드는 유일한 자리입니다. CSS는 스스로를 재기 때문에 React 빌드에는 `ResizeObserver`가 필요하고, 너비가 0인 채로 마운트되는 분할이 실제 위험입니다. `LayoutBuilder`는 배치 단계마다 크기를 건네받으므로 관찰할 것도, 다시 잴 것도 없습니다. 아직 자리가 없는 분할은 자리가 생길 때까지 그냥 pane을 고르게 배치합니다.

:::

### defaultSize, minSize, maxSize

**백분율**은 분할을 서술하는 보통의 방식이고, 창 크기가 바뀌어도 뜻이 유지됩니다. 절대 **길이**는 최소 너비가 있는 사이드바에 실제로 필요한 것입니다 — "최소 200픽셀"은 아직 아무도 모르는 너비의 백분율로 적어 두면 살아남지 못합니다.

<Fw react="숫자 하나가 백분율이고 문자열이 길이입니다 — '240px', '15rem', '20%'." flutter="Dart에는 number | string 유니온이 없어서 둘은 두 개의 생성자입니다 — PlPaneSize.percent와 PlPaneSize.pixels." />

`defaultSize`가 없는 pane들은 남은 자리를 똑같이 나눠 가집니다.

세 prop은 pane이 쓰는 것이 아니라 **분할**이 읽습니다. pane은 "절반"이 무엇인지 알 수 없고, 전부를 쥔 쪽만 알 수 있습니다. 그래서 `PlPanes`의 직계 자식은 `PlPane`이어야 합니다 — 다른 것으로 감싼 pane은 최소값이 없는 pane입니다.

<Demo src="panes/constraints" :min-height="240">

::: fw react

<<< @/.vitepress/demos/panes/constraints.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/panes/constraints.dart

:::

</Demo>

### orientation

`horizontal`은 pane을 나란히 놓고 사이에 세로 손잡이를 둡니다. `vertical`은 쌓습니다. 한쪽의 pane 안에 다른 쪽을 중첩하는 것이 세 영역짜리 레이아웃을 만드는 방법입니다.

**반응형입니다.** 그래서 한 집합이 폰에서는 이쪽으로, 노트북에서는 저쪽으로 갈 수 있습니다. <Fw react="CSS가 아니라 JavaScript에서 풀립니다 — orientation은 DOM과 ARIA와 방향키가 걷는 방향을 정하는데 어떤 스타일시트도 그것을 할 수 없습니다. 그래서 서버는 xs 항목을 렌더링하고 브라우저가 hydration에서 고칩니다. 맨값은 아무것도 구독하지 않습니다." flutter="build에서 창의 너비를 상대로 풀리므로 첫 프레임부터 정확합니다. 그리고 이 위젯 자기 상자가 아니라 창의 너비여서, 나란히 놓인 둘이 같은 칸에 있다고 합의합니다." /> [브레이크포인트](../../design/breakpoints) 참고.

<Demo src="panes/orientation" :min-height="260">

::: fw react

<<< @/.vitepress/demos/panes/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/panes/orientation.dart

:::

</Demo>

### resizable

컨트롤이 아니라 레이아웃인 분할에서는 꺼 두세요. 손잡이는 남습니다 — 여전히 두 영역 사이의 선입니다 — 다만 포인터를 받지 않고 탭 순서에서 빠집니다.

<Demo src="panes/fixed" :min-height="200">

::: fw react

<<< @/.vitepress/demos/panes/fixed.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/panes/fixed.dart

:::

</Demo>

### size와 color

`size`는 손잡이의 두께입니다. _그려지는_ 것은 얇은 선이고, **잡을 수 있는** 것은 그 둘레의 트랙입니다. 스크롤바가 둘 사이에 두는 것과 같은 구분이고, 1픽셀짜리 선이 표적이 아닌 이유입니다.

분할은 시트를 그리지 않으므로 `color`는 세 곳에 닿고 멈춥니다 — 포인터가 올라간 손잡이의 얇은 선, 그 아래의 색조, 그리고 포커스 링.

<Demo src="panes/sizes" :min-height="360">

::: fw react

<<< @/.vitepress/demos/panes/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/panes/sizes.dart

:::

</Demo>

## Accessibility

- 모든 손잡이는 `role="separator"`이고 `aria-valuenow`로 앞 pane의 몫을 들고 있습니다. 그래서 스크린 리더가 경계가 있다는 사실이 아니라 경계가 어디인지를 말할 수 있습니다.
- 분할의 크기를 바꿀 수 있는 동안 손잡이는 탭 정지이고, 화살표 키가 그것을 움직입니다. `resizable`이 꺼지면 탭 순서에서 완전히 빠집니다 — 조작할 수 없는 컨트롤은 조작할 수 있는 컨트롤로 가는 길목의 정거장이 되어서는 안 됩니다.
- 키 누름은 그 자체로 하나의 완결된 동작이라서 `onResizeEnd`가 함께 발생합니다. 기다릴 "놓기"가 없습니다.

::: fw react

- 손잡이에 포커스를 주는 것은 컴포넌트가 아니라 브라우저입니다. 직접 포커스를 주면, 그냥 끌기만 한 손잡이에까지 키보드 포커스 링이 붙습니다.
- 끌기는 누름에 `preventDefault`를 거는 대신 끌기가 이어지는 동안 페이지의 텍스트 선택을 가져갑니다. `preventDefault`가 바로 위의 포커스를 막아 버리기 때문입니다. 속성은 `setProperty`로 `-webkit-user-select`라고 씁니다. WebKit은 접두사 붙은 이름만 구현하고 있어서, 거기서 `style.userSelect = 'none'`은 아무 일도 하지 않고 조용히 지나갑니다.
- 진행 중인 끌기는 분할이 언마운트되면 정리됩니다. 라우트가 바뀐 뒤에는 그것을 끝냈을 `pointerup`이 영영 오지 않고, 남는 것은 떨어져 나간 노드에 걸린 리스너 둘만이 아닙니다 — 텍스트를 더 이상 선택할 수 없는 페이지가 남습니다.

:::

::: fw flutter

- 손잡이는 구분선이 아니라 **슬라이더**입니다. 여기서 스크린 리더에게 그것이 실제로 무엇인지가 그렇습니다 — Flutter의 시맨틱 트리에는 separator role도 `valuenow`도 없지만, 값을 올리고 내릴 수 있는 컨트롤은 있습니다. `label`이 그것에 이름을 줍니다.
- 화살표 키가 그것을 움직이고, 쓰기 방향을 따릅니다. RTL에서는 끌기와 마찬가지로 반대로 움직입니다.
- 다른 빌드가 가진 끌기의 세 가지 함정은 여기에 하나도 없습니다. 가져갈 문서 선택도 없고, 누름에 무언가에 포커스를 주는 브라우저도 없으며, 제스처 인식기는 그것을 소유한 위젯과 함께 폐기됩니다.

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `<PlPane>` children | `panes: List<PlPane>` | 분할이 멤버에게서 세 크기 값을 읽는데 `Widget`은 불투명합니다. |
| `number \| string` 크기 | `PlPaneSize.percent` / `.pixels` | Dart에는 유니온이 없습니다. 두 생성자가 그 두 갈래입니다. |
| `ResizeObserver` | `LayoutBuilder` | CSS는 스스로를 재고, Flutter는 배치 단계에서 묻는 쪽에 크기를 건네줍니다. |
| `role="separator"`, `aria-valuenow` | 슬라이더 시맨틱 | Flutter의 트리에는 둘 다 없고, 값을 가진 컨트롤이 정직한 서술입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
