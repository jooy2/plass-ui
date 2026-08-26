---
title: PlPanes
order: 4
---

# PlPanes

<p class="plass-lede">사이에 끌 수 있는 손잡이가 놓인 영역 묶음입니다. 분수로 크기가 정해져서, 창 크기가 바뀌어도 JavaScript 한 줄 돌지 않고 분할이 유지됩니다.</p>

<Demo src="panes/hero" :min-height="260" :flutter="false" />

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

## Props

<PropsTable name="PlPanes" />

### PlPane

<PropsTable name="PlPane" />

::: fw react

네이티브 `<div>` 속성은 둘 다 그대로 전달됩니다. 분할 쪽의 `color`는 거기서 Plass의 prop이라 제외됩니다.

:::

pane도, 분할 자체도 자기 표면을 그리지 않습니다. 이것은 레이아웃이고, pane이 시트를 그리는 순간 `PlCard`나 `PlTable`이나 에디터를 담는 그릇으로 쓸 수 없게 됩니다. 표면이 필요하면 안에 `PlCard`를 넣으세요. 라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### 분할은 어떻게 재어지는가

pane의 크기는 **분수**이고, `flex-basis: calc((100% − 손잡이들) × 분수)`로 쓰입니다.

이 컴포넌트의 나머지 전부가 그 결정에서 따라 나옵니다. 백분율로 서술된 분할은 아무것도 실행되지 않아도 창 크기 변화를 견딥니다. 그래서 컴포넌트는 딱 두 번만 스스로를 잽니다 — 마운트 때 한 번, `'240px'` 기본값을 분수로 바꾸기 위해. 그리고 끌기가 시작될 때마다 한 번, 포인터가 1픽셀 움직이는 것이 얼마짜리인지 알기 위해.

측정은 한 번 읽는 대신 `ResizeObserver`입니다. 닫힌 `PlAccordion`이나 선택되지 않은 `PlTab` 안의 분할은 마운트될 때 너비가 0인데, 그것으로 나누면 모든 pane이 0이 되기 때문입니다.

### defaultSize, minSize, maxSize

숫자 하나는 **백분율**입니다. 분할을 서술하는 보통의 방식이고, 창 크기가 바뀌어도 뜻이 유지됩니다. 문자열은 절대 길이(`'240px'`, `'15rem'`, `'20%'`)이고, 최소 너비가 있는 사이드바에 실제로 필요한 것이 그것입니다 — "최소 200픽셀"은 아직 아무도 모르는 너비의 백분율로 적어 두면 살아남지 못합니다.

`defaultSize`가 없는 pane들은 남은 자리를 똑같이 나눠 가집니다.

세 prop은 pane이 쓰는 것이 아니라 **분할**이 읽습니다. pane은 "절반"이 무엇인지 알 수 없고, 전부를 쥔 쪽만 알 수 있습니다. 그래서 `PlPanes`의 직계 자식은 `PlPane`이어야 합니다 — 다른 것으로 감싼 pane은 최소값이 없는 pane입니다.

<Demo src="panes/constraints" :min-height="240" :flutter="false">

::: fw react

<<< @/.vitepress/demos/panes/constraints.tsx

:::

</Demo>

### orientation

`horizontal`은 pane을 나란히 놓고 사이에 세로 손잡이를 둡니다. `vertical`은 쌓습니다. 한쪽의 pane 안에 다른 쪽을 중첩하는 것이 세 영역짜리 레이아웃을 만드는 방법입니다.

<Demo src="panes/orientation" :min-height="260" :flutter="false">

::: fw react

<<< @/.vitepress/demos/panes/orientation.tsx

:::

</Demo>

### resizable

컨트롤이 아니라 레이아웃인 분할에서는 꺼 두세요. 손잡이는 남습니다 — 여전히 두 영역 사이의 선입니다 — 다만 포인터를 받지 않고 탭 순서에서 빠집니다.

<Demo src="panes/fixed" :min-height="200" :flutter="false">

::: fw react

<<< @/.vitepress/demos/panes/fixed.tsx

:::

</Demo>

### size와 color

`size`는 손잡이의 두께입니다. *그려지는* 것은 얇은 선이고, **잡을 수 있는** 것은 그 둘레의 트랙입니다. 스크롤바가 둘 사이에 두는 것과 같은 구분이고, 1픽셀짜리 선이 표적이 아닌 이유입니다.

분할은 시트를 그리지 않으므로 `color`는 세 곳에 닿고 멈춥니다 — 포인터가 올라간 손잡이의 얇은 선, 그 아래의 색조, 그리고 포커스 링.

<Demo src="panes/sizes" :min-height="360" :flutter="false">

::: fw react

<<< @/.vitepress/demos/panes/sizes.tsx

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
