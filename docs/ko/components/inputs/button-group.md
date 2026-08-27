---
title: PlButtonGroup
order: 2
---

# PlButtonGroup

<p class="plass-lede">함께 묶이는 버튼 한 줄입니다. 이웃과 맞닿는 모서리를 각지게 깎고, <code>variant</code> <code>size</code> <code>color</code> <code>density</code> <code>elevation</code> <code>disabled</code>를 묶음 단위로 한 번만 지정합니다.</p>

<Demo src="button-group/hero" :flutter="false" :min-height="120" />

::: fw react

```tsx
import { PlButton, PlButtonGroup } from 'plass-ui';

<PlButtonGroup variant="glass" color="secondary">
  <PlButton>Day</PlButton>
  <PlButton>Week</PlButton>
  <PlButton>Month</PlButton>
</PlButtonGroup>;
```

:::

## Props

<PropsTable name="PlButtonGroup" />

::: fw react

나머지 `<div>` 속성은 그대로 통과합니다. `color`는 위 표의 `color`와 이름이 겹쳐 제외했습니다.

:::

다섯 개의 스타일 축에는 **자기 기본값이 없습니다.** 그룹이 지정하지 않은 축은 각 버튼이 자기 기본값으로 돌아가는 축이라, 아무 prop도 주지 않은 그룹은 모서리 말고는 아무것도 바꾸지 않습니다. 버튼이 직접 지정한 축은 그룹보다 우선합니다 — secondary 액션 줄에 danger 버튼 하나가 섞이는 건 실제로 있는 일입니다.

공유 축(`variant` `size` `color` `density` `elevation`)이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## segmented control이 아닙니다

버튼은 진짜 [`PlButton`](./button)으로 남고, 그 무엇도 대체되지 않습니다. 그룹이 하는 일은 모서리 넷을 깎고 prop 여섯 개를 물려주는 것뿐입니다. 선택 상태를 관리하지 않고, value도 없으며, 어느 버튼도 _고른 것_ 이 되지 않습니다.

여럿 중 하나를 고르는 컨트롤 — 뷰 전환, 모드 토글 — 은 [`PlSegmentedButton`](./segmented-button)입니다. 그쪽이 roving focus와 `radiogroup` semantics까지 갖춘 진짜 그 컨트롤입니다.

## Examples

### variant

이음매를 처리해야 하는 건 `glass` 하나뿐입니다. 테두리를 그리는 유일한 variant이기도 해서, glass 키 둘이 맞닿으면 hairline이 두 겹으로 겹쳐 페이지의 다른 모든 선보다 두 배로 무거워집니다. 그래서 뒤쪽을 1px 당겨 두 키가 선 하나를 나눠 쓰게 합니다.

`solid`는 그렇게 하면 안 됩니다. 겹칠 테두리가 없고, 겹치면 한 키의 그러데이션이 다음 키의 시작을 덮습니다.

<Demo src="button-group/variants" :flutter="false" :min-height="140">

<<< @/.vitepress/demos/button-group/variants.tsx

</Demo>

### size

한 번만 지정하니 버튼 하나만 크기가 어긋날 수 없습니다. 높이는 라이브러리의 컨트롤 사다리 그대로입니다.

<Demo src="button-group/sizes" :flutter="false" :min-height="260">

<<< @/.vitepress/demos/button-group/sizes.tsx

</Demo>

### orientation

`vertical`은 줄을 세로로 쌓고, 옆면 대신 위아래를 각지게 깎습니다. 동등한 액션을 쌓은 메뉴에 쓰고, 기본값이 `horizontal`인 건 툴바가 그 모양이기 때문입니다.

<Demo src="button-group/orientation" :flutter="false" :min-height="180">

<<< @/.vitepress/demos/button-group/orientation.tsx

</Demo>

### fullWidth

그룹을 컨테이너 너비만큼 늘리고 버튼끼리 너비를 똑같이 나눠 갖게 합니다. 카드 아래 액션 세 개가 서로 다른 길이의 단어 셋이 아니라 똑같은 삼등분이 됩니다.

<Demo src="button-group/full-width" :flutter="false" :min-height="120">

<<< @/.vitepress/demos/button-group/full-width.tsx

</Demo>

## Accessibility

- 그룹은 `role="group"`입니다. 줄 자체에 이름이 필요하면 `aria-label`을 주세요 — 이게 세 개 놓인 바는 이름 없는 그룹 세 개입니다.
- `role="toolbar"`가 **아니고** roving focus도 없습니다. 그 role은 키보드 동작에 대한 약속이고, 여기서는 버튼 하나하나가 각자의 focus 정거장입니다 — 평범한 `<button>` semantics가 이미 말하고 있는 그대로입니다.
- 모서리는 logical property로 깎으므로, RTL에서는 첫 버튼이 오른쪽에 오고 깎이는 면도 따라갑니다.
- 버튼마다 stacking context가 생겨, border box 바깥에 그려지는 focus ring이 뒤에 오는 이웃에 덮이지 않습니다.
- 그룹의 `disabled`는 안의 모든 버튼을 끕니다. 버튼이 직접 지정한 `disabled`는 그대로 우선합니다.
