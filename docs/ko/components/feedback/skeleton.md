---
title: PlSkeleton
order: 4
---

# PlSkeleton

<p class="plass-lede">아직 로드되지 않은 것의 모양입니다. 진짜가 차지할 자리를 미리 잡아 두는 것이 이 컴포넌트가 하는 일 전부이고, spinner는 그것을 할 수 없습니다.</p>

<Demo src="skeleton/hero" :min-height="300" />

```tsx
import { PlSkeleton } from 'plass-ui';

<PlSkeleton lines={3} label="Loading the article" />;
<PlSkeleton shape="circle" />;
<PlSkeleton shape="rect" height={120} />;
```

## Props

<PropsTable name="PlSkeleton" />

네이티브 `<div>` 속성은 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 전달 대상에서 제외됩니다.

`variant`도, `elevation`도, `density`도 없습니다. skeleton은 일부러 유리로 **만들지 않습니다**. 라이브러리의 다른 모든 시트는 페이지 위에 놓인 물체이기에 흐려진 배경 위의 반투명한 판이지만, skeleton은 그 반대 — 아직 거기 없는 것의 모양입니다. 그래서 평평한 틴트일 뿐이고, 덕분에 placeholder 서른 개가 놓인 페이지가 backdrop filter를 서른 개 요구하지도 않습니다.

라이브러리 전체에서 공유 축(`size` `color`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### shape

세 가지 모양은 레이아웃이 만들어지는 세 가지 재료입니다 — 글줄, 덩어리, 원 — 그리고 각각은 진짜 컴포넌트가 쓰는 사다리로 크기가 정해집니다. `md` 줄은 `md` 글자와 같은 높이이고, `md` 원은 정확히 `md`의 `PlAvatar`입니다.

`lines`는 줄무늬 상자 하나가 아니라 막대를 쌓습니다. 그래서 사이의 틈이 진짜 틈입니다 — 글에는 행간이 있습니다. 마지막 줄은 문단의 마지막 줄처럼 짧게 그려집니다.

<Demo src="skeleton/shapes" :min-height="320">

<<< @/.vitepress/demos/skeleton/shapes.tsx

</Demo>

### 진짜를 대신하기

핵심은 내용이 도착했을 때 아무것도 움직이지 않는 것입니다. 이미지가 로드되면서 200px 자라는 card는 누군가 읽고 있는 동안 그 아래 전부를 밀어낸 것입니다.

<Demo src="skeleton/matching" :min-height="200">

<<< @/.vitepress/demos/skeleton/matching.tsx

</Demo>

### animated

지나가는 하이라이트는 기본적으로 켜져 있습니다. placeholder가 수십 개 놓인 페이지, 또는 기다림이 길어 움직임이 소음이 되는 곳에서 끄세요.

이것은 접근성 스위치가 아닙니다. reduced-motion 설정은 요청하지 않아도 이미 그 sweep을 색 맥동으로 바꿉니다.

<Demo src="skeleton/animated" :min-height="220">

<<< @/.vitepress/demos/skeleton/animated.tsx

</Demo>

### size

<Demo src="skeleton/sizes" :min-height="300">

<<< @/.vitepress/demos/skeleton/sizes.tsx

</Demo>

## Accessibility

- 라벨이 없으면 placeholder는 `aria-hidden`이고 아무 말도 하지 않습니다. 상자 열두 개가 저마다 자기를 알리는 것은 침묵보다 나쁩니다.
- 영역 전체를 대표하는 **하나**에만 `label`을 주면 그것이 `aria-busy`를 가진 `role="status"`가 됩니다 — 하나의 기다림에 하나의 알림.
- `prefers-reduced-motion`에서는 하이라이트가 지나가기를 멈추고 대신 placeholder 전체가 색으로 맥동합니다. 아예 멈추지 않는 이유는, 가만히 있는 skeleton은 아무것도 없이 로드가 끝난 빈 상자와 구별되지 않기 때문입니다.
