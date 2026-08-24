---
title: PlAlert
order: 1
---

# PlAlert

<p class="plass-lede">일어난 일에 대한 메시지를, 그 일이 벌어진 페이지 안에 놓습니다. 한 줄, 글리프가 붙은 한 줄, 헤드라인과 그 아래 상세 — 세 가지 모양은 서로 다른 자리가 채워진 하나의 컴포넌트입니다.</p>

<Demo src="alert/hero" :min-height="200" />

```tsx
import { PlAlert } from 'plass-ui';

<PlAlert color="success">Your changes are live.</PlAlert>;
<PlAlert color="danger" title="The deploy failed">
  Two of the health checks never came back.
</PlAlert>;
```

## Props

<PropsTable name="PlAlert" />

네이티브 `<div>` 속성은 `role`을 포함해 그대로 전달됩니다 — 아래 live region 항목을 보세요. `color`와 `title`은 둘 다 여기서는 Plass의 prop이라 전달 대상에서 제외됩니다.

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### variant

alert는 색을 입는 **대상 자체**입니다 — 남의 내용을 담는 컨테이너가 아니라 심각도에 대한 알림이므로, `PlCard`와 달리 시트가 틴트를 받습니다.

`solid`는 색 계열의 그러데이션에 같은 계열의 그림자를 깔고, 채워진 `PlButton`이 그렇듯 gloss line은 없습니다. `glass`는 헤어라인과 글리프, 제목에 색 계열을 입습니다. `ghost`는 틴트뿐이며, form 필드들 사이에 놓여 사각형이 하나 더 늘어나면 안 되는 자리에 씁니다.

<Demo src="alert/variants" :min-height="260">

<<< @/.vitepress/demos/alert/variants.tsx

</Demo>

### color

기본값은 `primary`가 아니라 `info`입니다. `primary`가 거짓말이 되는 유일한 자리입니다 — alert는 무언가의 주요 액션이 아니라 알림이고, 팔레트에는 이미 그것을 가리키는 단어가 있습니다.

각 계열은 자기 색만이 아니라 자기 모양도 그립니다. 빨간색으로만 "잘못됐다"고 말하는 alert는 일부 독자에게만 말하는 alert입니다.

<Demo src="alert/colors" :min-height="240">

<<< @/.vitepress/demos/alert/colors.tsx

</Demo>

### 세 가지 모양

한 줄이면 `icon={false}`, 글리프가 붙은 한 줄이면 기본값, 헤드라인과 상세면 `title`에 `children`. 셋 사이에서 표면은 아무것도 바뀌지 않습니다 — 얼마나 쓰이는지만 다릅니다.

<Demo src="alert/shapes" :min-height="200">

<<< @/.vitepress/demos/alert/shapes.tsx

</Demo>

### action과 onClose

`action`은 메시지가 옆에서 줄바꿈되는 동안에도 첫 줄에 남습니다. `children` 뒤에 이어 붙이는 대신 prop인 이유입니다.

`onClose`를 주는 것이 닫기 버튼을 나타나게 합니다. 컴포넌트가 스스로 사라지지는 않습니다 — 닫혔을 때 무슨 일이 일어나는지는 호출하는 쪽의 몫이고, 알아서 사라진 alert는 언제 다시 나타나야 하는지 누군가 알려 줘야 합니다.

<Demo src="alert/dismiss" :min-height="160">

<<< @/.vitepress/demos/alert/dismiss.tsx

</Demo>

### size

<Demo src="alert/sizes" :min-height="280">

<<< @/.vitepress/demos/alert/sizes.tsx

</Demo>

## Accessibility

- alert는 live region이고, 어느 쪽인지는 심각도가 정합니다. `warning`과 `danger`는 `role="alert"`로 스크린리더가 읽고 있던 것을 끊고, 나머지는 `role="status"`로 쉬는 지점을 기다립니다. "실패했다"는 끊을 만하고 "저장됐다"는 그렇지 않습니다.
- 직접 넘긴 `role`이 이깁니다 — props가 기본값 뒤에 펼쳐집니다.
- 글리프는 장식이라 `aria-hidden`입니다. 심각도는 role과 모양, 색이 함께 나르며 색만으로 전달되지 않습니다.
- 글리프는 `1lh`로 메시지의 **첫 줄**에 맞춰 놓입니다. 세 줄짜리 alert도 글리프는 위쪽에 있습니다.
- `action`과 닫기 버튼은 각자 tab stop을 가진 진짜 버튼입니다. action에는 접근 가능한 이름을 주세요. 닫기 버튼은 이미 가지고 있습니다.
