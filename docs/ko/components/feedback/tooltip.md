---
title: PlTooltip
order: 6
---

# PlTooltip

<p class="plass-lede">포인터가 무언가에 머무를 때 나타나는 짧은 라벨입니다. 컴포넌트 전체가 감싸개일 뿐이라 레이아웃에 요소를 더하지 않고, 자식은 원래의 그것으로 남습니다.</p>

<Demo src="tooltip/hero" :min-height="140" />

```tsx
import { PlTooltip } from 'plass-ui';

<PlTooltip content="Copy to clipboard">
  <PlButton aria-label="Copy">
    <CopyIcon />
  </PlButton>
</PlTooltip>;
```

## Props

<PropsTable name="PlTooltip" />

네이티브 `<div>` 속성은 판에 그대로 전달됩니다. `color`, `content`, `children`은 셋 다 여기서는 Plass의 prop이라 전달 대상에서 제외됩니다.

`variant`도 `elevation`도 없습니다. 판은 `PlSelect`의 popup과 같은 떠 있는 시트입니다 — 가장 불투명한 유리, 그 둘레의 흰 헤어라인, 아래의 shadow 3 — 대부분의 라이브러리가 tooltip을 그리는 채워진 키가 아닙니다. tooltip은 무언가에 **대한** 메모이지 누르는 물건이 아니고, 한 화면에 떠 있는 시트가 두 종류인 것은 하나가 너무 많은 것입니다.

라이브러리 전체에서 공유 축(`size` `color` `density` `side` `align`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### side와 align

`side`는 자리가 없으면 반대편 변으로 뒤집힐 수 있습니다. Base UI가 하는 일이고, 그것이 옳은 동작입니다 — 화면 밖으로 반쯤 나간 tooltip은 아무 말도 하지 않습니다.

<Demo src="tooltip/sides" :min-height="200">

<<< @/.vitepress/demos/tooltip/sides.tsx

</Demo>

<Demo src="tooltip/align" :min-height="180">

<<< @/.vitepress/demos/tooltip/align.tsx

</Demo>

### PlTooltipProvider

여러 tooltip이 하나의 delay를 나눠 씁니다. 그중 하나가 한 번 열리고 나면 이웃들은 즉시 열리고, 잠시 쉬면 기다림이 다시 돌아옵니다.

툴바를 감쌀 만합니다. 이것이 없으면 아이콘 버튼이 늘어선 줄을 따라 움직일 때마다 매번 delay를 끝까지 기다려야 하고, 그것이 tooltip이 포인터와 싸우는 것처럼 느껴지게 만드는 이유입니다.

<Demo src="tooltip/provider" :min-height="120">

<<< @/.vitepress/demos/tooltip/provider.tsx

</Demo>

### delay, closeDelay, disabled

`disabled`는 트리거는 그대로 두고 tooltip만 열리지 않게 합니다 — 라벨이 잘렸을 때만 존재하는 tooltip을 위한 것입니다.

<Demo src="tooltip/delay" :min-height="120">

<<< @/.vitepress/demos/tooltip/delay.tsx

</Demo>

### size

<Demo src="tooltip/sizes" :min-height="220">

<<< @/.vitepress/demos/tooltip/sizes.tsx

</Demo>

## Accessibility

- 판에는 `role="tooltip"`이, 트리거에는 그것을 가리키는 `aria-describedby`가 붙습니다 — **열려 있는 동안에만**입니다. 문서에 없는 요소를 가리키는 참조는 아무것도 가리키지 않는 참조이기 때문입니다. Base UI는 popup이 여러 가지일 수 있어 둘 다 호출하는 쪽에 맡기지만, 여기서는 언제나 tooltip이므로 컴포넌트가 직접 연결합니다.
- Base UI의 Trigger는 자기 상자를 그리는 대신 자식에 합쳐집니다. 그래서 tooltip은 레이아웃에 요소도, 자기 tab stop도 더하지 않습니다.
- focus에서 열리되 클릭에서 온 focus에서는 열리지 않고, Escape에서 닫힙니다. 셋 다 프리미티브의 것입니다.
- **tooltip은 라벨이 아닙니다.** 설명할 뿐 이름을 붙이지 않습니다. 아이콘만 있는 버튼에는 자기 `aria-label`이 따로 필요합니다 — 접근 가능한 이름이 없는 트리거는 음성 제어로 도달할 수 없고, tooltip은 그 이름을 대신 줄 만큼 페이지에 늘 있지 않습니다.
- tooltip 안의 무엇도 누를 수 없고, 터치 화면에는 머무를 포인터가 없습니다. 둘 중 하나가 필요한 내용은 자리를 지키는 곳에 있어야 합니다.
