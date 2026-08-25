---
title: PlSegmentedButton
order: 10
---

# PlSegmentedButton

<p class="plass-lede">알약 하나에 담긴 두 개 이상의 선택지 중 정확히 하나가 선택됩니다. 타일이 떠난 세그먼트에서 고른 세그먼트로 미끄러집니다.</p>

<Demo src="segmented-button/hero" :min-height="120" />

```tsx
import { PlSegment, PlSegmentedButton } from 'plass-ui';

<PlSegmentedButton aria-label="Period" value={period} onValueChange={setPeriod}>
  <PlSegment value="day">Day</PlSegment>
  <PlSegment value="week">Week</PlSegment>
</PlSegmentedButton>;
```

## Props

<PropsTable name="PlSegmentedButton" />

네이티브 `<div>` 속성은 그대로 전달됩니다. `color`는 위 표의 `color`와 충돌해서, `defaultValue`와 `onChange`는 이 묶음이 각각 세그먼트 값으로서의 `defaultValue`와 `onValueChange`로 쓰기 때문에 제외됩니다.

### PlSegment

<PropsTable name="PlSegment" />

`variant`, `size`, `density`는 세그먼트에 주는 것이 아니라 감싸는 `PlSegmentedButton`에서 내려받습니다. 세 번째 세그먼트만 크기가 다른 segmented button은 segmented button이 아닙니다.

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Segmented button인가, tabs인가, select인가

- **Segmented button** — 이미 화면에 있는 것을 걸러 내는, 짧고 서로 배타적인 선택지 몇 개. 기간, 범위, 레이아웃.
- **Tabs** — 선택이 내용 패널 전체를 바꿀 때.
- **Select** — 선택지가 다섯 개를 넘거나, 하나하나가 길 때.

## Examples

### variant

홈은 `--plass-well`을 씁니다. 라이브러리의 유일한 inset 그림자이자 `solid` field가 그려지는 것과 같은 그림자이고, 쓰이는 곳은 이 둘뿐입니다. 홈과 채워진 field는 둘 다 무언가가 _들어앉는_ 상자입니다. slider의 레일은 그런 상자가 아니라서 더 이상 이 그림자를 쓰지 않습니다 — 레일은 따라 보는 선입니다.

`solid`는 타일에 색 계열의 그러데이션을 넣고 그 아래에 같은 계열의 틴트 그림자를 깝니다. 디자인 언어의 문장을 그대로 옮긴 것입니다 — 홈을 타고 가는 색 유리 키. `glass`와 `ghost`는 대신 맑은 유리판을 들어 올리고 라벨은 accent 색으로 둡니다.

<Demo src="segmented-button/variants" :min-height="220">

<<< @/.vitepress/demos/segmented-button/variants.tsx

</Demo>

### color

<Demo src="segmented-button/colors" :min-height="220">

<<< @/.vitepress/demos/segmented-button/colors.tsx

</Demo>

### size

`PlButton`과 같은 높이 사다리를 씁니다. 툴바 안의 segmented button이 옆의 버튼들과 줄을 맞춥니다.

<Demo src="segmented-button/sizes" :min-height="240">

<<< @/.vitepress/demos/segmented-button/sizes.tsx

</Demo>

### fullWidth

세그먼트들이 한 줄을 균등하게 나눠 가집니다. 타일은 크기가 바뀔 때마다 다시 측정되므로, 컨테이너 너비가 변해도 자기 세그먼트 아래에 남아 있습니다.

<Demo src="segmented-button/full-width" :min-height="120">

<<< @/.vitepress/demos/segmented-button/full-width.tsx

</Demo>

### startIcon과 endIcon

둘 다 `em`으로 크기가 정해지므로 라벨을 따라갑니다. 아이콘만 있는 세그먼트에는 `aria-label`이 필요합니다.

<Demo src="segmented-button/icons" :min-height="120">

<<< @/.vitepress/demos/segmented-button/icons.tsx

</Demo>

## Accessibility

- 묶음은 `role="radiogroup"`이고 각 세그먼트는 진짜 radio입니다. 접근성 논거는 이것이 전부입니다 — segmented button은 **"이 중 정확히 하나"** 입니다. `aria-pressed` 토글로 만들었다면 독립된 스위치 네 개를 읽어 주고, 그중 셋은 마침 꺼져 있는 상태가 됩니다.
- 묶음 전체가 tab stop 하나를 차지하고, <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd>로 그 안에서 움직입니다. roving tab index는 Base UI의 것입니다.
- 묶음에 `aria-label`을 주세요. 눈에 보이는 자기 라벨이 없고, 이름 없는 그룹은 스크린리더가 "radio group"이라고만 읽습니다.
- focus ring은 **안쪽으로** 그려집니다. 홈 안의 세그먼트에 바깥쪽 ring을 그리면 이웃 위에 덧칠됩니다.
- 타일은 `transform`이 아니라 `left`, `top`, `width`, `height`를 애니메이션합니다. 빈 상자라서 이동하는 동안 다시 샘플링되는 글자가 없습니다. 무언가 움직이는 것이 존재 이유인 컴포넌트에서도 no-transform 규칙이 살아남는 이유입니다.
- 아무것도 선택되지 않은 묶음의 첫 선택은 왼쪽 끝에서 날아오지 않고 **제자리에** 나타납니다 — 앉을 자리가 생기기 전까지 타일을 마운트하지 않기 때문입니다.
