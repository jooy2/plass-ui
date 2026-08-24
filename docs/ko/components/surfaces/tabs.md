---
title: PlTabs
order: 3
---

# PlTabs

<p class="plass-lede">여러 패널 중 하나를 보여 주는 묶음입니다. 인디케이터가 떠난 탭에서 고른 탭으로 미끄러집니다.</p>

<Demo src="tabs/hero" :min-height="200" />

```tsx
import { PlTab, PlTabPanel, PlTabs } from 'plass-ui';

<PlTabs defaultValue="account">
  <PlTab value="account">Account</PlTab>
  <PlTab value="billing">Billing</PlTab>

  <PlTabPanel value="account">Your name and your avatar.</PlTabPanel>
  <PlTabPanel value="billing">Cards and invoices.</PlTabPanel>
</PlTabs>;
```

탭과 패널은 형제로 쓰고, 컴포넌트가 알아서 둘을 갈라 놓습니다. 기억해야 할 `<PlTabList>`도 없고, 서브트리 배열 prop도 없습니다 — 패널은 서브트리이고, 그것을 담을 쓸 만한 모양은 결국 children뿐입니다.

## Props

<PropsTable name="PlTabs" />

### PlTab

<PropsTable name="PlTab" />

### PlTabPanel

<PropsTable name="PlTabPanel" />

`variant`, `size`, `density`, `orientation`은 감싸고 있는 `PlTabs`에서 내려받습니다. 이웃과 그중 무엇이든 달라질 수 있는 탭은 구멍 난 탭 바입니다.

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `orientation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Tabs인가 segmented button인가

tabs는 내용 패널 전체를 바꿉니다. [segmented button](../inputs/segmented-button)은 이미 화면에 있는 것을 걸러 냅니다. 여기서 `solid` 타일이 색 계열의 그러데이션이 아니라 **맑은** 유리판인 이유이기도 합니다 — 그러데이션 타일은 segmented button의 것이고, 둘이 한 화면에 있으면 구분이 되어야 합니다.

## Examples

### variant

`glass`는 고전적인 바입니다. 가장자리의 선 위를 인디케이터가 달립니다. `solid`는 홈 안에서 판이 미끄러집니다. `ghost`는 그 선을 뺀 바로, 이미 자기 테두리를 가진 `PlCard` 안의 탭에 씁니다.

<Demo src="tabs/variants" :min-height="420">

<<< @/.vitepress/demos/tabs/variants.tsx

</Demo>

### orientation

`vertical`은 탭을 옆으로 세우고 패널을 그 옆에 놓으며, 방향키를 다른 축으로 옮깁니다. Base UI가 하는 일이고, 세로 탭 바에 닿을 수 있게 만드는 것이 바로 이것입니다.

<Demo src="tabs/orientation" :min-height="200">

<<< @/.vitepress/demos/tabs/orientation.tsx

</Demo>

### fullWidth

<Demo src="tabs/full-width" :min-height="160">

<<< @/.vitepress/demos/tabs/full-width.tsx

</Demo>

### size

탭은 컨트롤이므로 컨트롤 높이 사다리를 씁니다 — `md` 탭과 `md` `PlButton`은 똑같이 40px이고, 그래서 탭 바가 툴바에서 버튼 옆에 놓여도 줄의 기준선이 유지됩니다.

<Demo src="tabs/sizes" :min-height="380">

<<< @/.vitepress/demos/tabs/sizes.tsx

</Demo>

### Controlled

<Demo src="tabs/controlled" :min-height="200">

<<< @/.vitepress/demos/tabs/controlled.tsx

</Demo>

## Accessibility

- 탭 바를 버튼 줄이 아니라 탭 바로 만드는 것은 전부 Base UI의 것입니다. 바 전체가 tab stop 하나가 되는 roving focus, 바가 놓인 축의 방향키, <kbd>Home</kbd>과 <kbd>End</kbd>, `tab` / `tabpanel` role, 그리고 둘을 잇는 `aria-controls`.
- `activateOnFocus`는 기본이 **꺼짐**입니다. 자동 활성화는 모든 패널이 이미 페이지에 있을 때만 친절합니다. 패널 하나라도 fetch를 하는 순간, 탭 네 개를 지나가면 요청이 네 번 나갑니다.
- 안에 focus 가능한 것이 없는 패널은 자기가 focus를 받으므로, 내용에 키보드로 닿을 수 있습니다.
- 탭의 focus ring은 안쪽으로 그려집니다. `solid` 홈 안의 탭에 바깥쪽 ring을 그리면 이웃 위에 덧칠됩니다.
- 인디케이터는 `transform`이 아니라 `left`, `top`, `width`, `height`를 애니메이션합니다. 빈 상자라서 글자가 담긴 것은 아무것도 움직이지 않습니다.
- 자리보다 탭이 많은 바는 줄바꿈 대신 스크롤됩니다. 두 줄이 된 탭 바는 이미 바가 아니고, 인디케이터가 앉을 만한 자리도 없습니다.
