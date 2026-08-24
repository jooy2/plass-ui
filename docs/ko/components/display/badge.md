---
title: PlBadge
order: 7
---

# PlBadge

<p class="plass-lede">다른 무언가의 모서리에 놓이는 작은 표시입니다 — 받은편지함 아이콘 위의 안 읽은 메일, avatar 위의 상태 점, 탭 위의 개수. children이 없으면 대신 inline으로 놓이고, 그것이 독립된 상태 pill입니다.</p>

<Demo src="badge/hero" :min-height="160" />

```tsx
import { PlBadge, PlButton } from 'plass-ui';

<PlBadge content={4} label="4 unread notifications">
  <PlButton aria-label="Notifications">
    <BellIcon />
  </PlButton>
</PlBadge>;
```

## Props

<PropsTable name="PlBadge" />

네이티브 `<span>` 속성은 앵커를 감싸는 껍데기가 아니라 **마커**에 그대로 전달됩니다. `color`와 `content`는 둘 다 여기서는 Plass의 prop이라 전달 대상에서 제외됩니다.

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### content, max, showZero

`content`는 보통 개수이고 가끔 단어입니다. `max`를 넘는 숫자는 `+`를 붙여 자르고, 단어는 그대로 둡니다 — 배지는 단어를 어떻게 잘라야 할지 알 수 없습니다.

`0`은 `showZero`를 켜지 않는 한 아무것도 그리지 않습니다. 안 읽은 메시지 0개는 소식이 아니고, 사라지지 않는 배지는 아무 뜻도 갖지 못하게 됩니다.

<Demo src="badge/counts" :min-height="140">

<<< @/.vitepress/demos/badge/counts.tsx

</Demo>

### dot

`content`를 생략하면 배지는 점이 됩니다 — 알릴 것은 있지만 셀 것이 없을 때의 정직한 모양입니다. `dot`은 content가 **있어도** 점으로 만들고, content는 스크린리더를 위해 DOM에 남습니다. 조용한 모서리가 말 없는 모서리는 아닙니다.

<Demo src="badge/dot" :min-height="140">

<<< @/.vitepress/demos/badge/dot.tsx

</Demo>

### variant

배지는 색을 입는 대상 자체라 시트가 틴트를 받습니다 — alert이 그렇고, card는 그렇지 않습니다. 또한 라이브러리에서 pill이 되는 것이 허용된 유일한 컴포넌트입니다. Plass의 모서리는 **표면**에 잡힌 필렛이고, 배지는 그 표면 위에 놓인 표시이기 때문입니다.

<Demo src="badge/variants" :min-height="120">

<<< @/.vitepress/demos/badge/variants.tsx

</Demo>

### placement와 overlap

`placement`는 전부 논리 속성이라, 오른쪽에 고정되는 대신 쓰기 방향에 따라 모서리가 뒤집힙니다.

`overlap`은 아래에 놓인 것의 모양입니다. 원의 모서리는 배지가 기준으로 삼는 상자 안쪽으로 지름의 15%쯤 들어와 있어서, 아이콘 버튼에 맞춘 배지는 avatar 위에서 아래에 틈을 두고 떠 보입니다.

<Demo src="badge/placement" :min-height="160">

<<< @/.vitepress/demos/badge/placement.tsx

</Demo>

<Demo src="badge/overlap" :min-height="140">

<<< @/.vitepress/demos/badge/overlap.tsx

</Demo>

### color

<Demo src="badge/colors" :min-height="120">

<<< @/.vitepress/demos/badge/colors.tsx

</Demo>

### size

컨트롤 사다리보다 훨씬 아래에 있는 자기 사다리입니다. 컨트롤의 높이는 **행**이 맞춰 서는 숫자이고, 배지는 아무것에도 맞춰 서지 않습니다 — 다른 것의 모서리에 매달릴 뿐입니다.

<Demo src="badge/sizes" :min-height="120">

<<< @/.vitepress/demos/badge/sizes.tsx

</Demo>

## Accessibility

- 종 옆의 `content={3}`은 "3"으로 읽히고, 그것만으로는 아무 뜻도 없습니다. `label="3 unread notifications"`를 주면 숫자 대신 그 문장이 읽힙니다.
- 점은 아무것도 그리지 않지만, 받은 `label`이나 `content` 중 하나는 그대로 읽습니다.
- `invisible`인 배지와 내용이 빈 배지는 접근성 트리에서 완전히 숨겨지고, 텍스트도 전혀 남기지 않습니다 — 잘려 있는 상자에 남은 텍스트는 페이지 내 찾기가 여전히 찾아내는 텍스트입니다.
- 배지는 role도 tab stop도 더하지 않습니다. 상호작용하는 것은 그 안의 앵커이고, 앵커는 호출하는 쪽의 요소입니다.
- 앵커를 감싸는 껍데기는 `inline-flex`이고 감싼 것과 정확히 같은 너비라, 배지가 붙은 아이콘 버튼도 옆의 맨 버튼과 그대로 줄을 맞춥니다.
