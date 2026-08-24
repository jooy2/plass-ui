---
title: PlList
order: 12
---

# PlList

<p class="plass-lede">행이 쌓인 묶음입니다. 목록이 시트이고 행은 그 위에 놓인 것이므로, <code>size</code>와 <code>density</code>는 묶음의 속성이고 행은 그것을 물려받습니다.</p>

<Demo src="list/hero" :min-height="360" />

```tsx
import { PlList, PlListItem } from 'plass-ui';

<PlList>
  <PlListItem description="Three unread" onClick={open}>
    Inbox
  </PlListItem>
  <PlListItem description="One saved">Drafts</PlListItem>
</PlList>;
```

## Props

<PropsTable name="PlList" />

네이티브 `<ul>` 속성은 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 전달 대상에서 제외됩니다.

### PlListItem

<PropsTable name="PlListItem" />

네이티브 `<li>` 속성은 안쪽의 button이나 link가 아니라 `<li>`에 그대로 전달됩니다. `size`, `density`, `dividers`는 감싸는 `PlList`에서 상속됩니다 — 그중 하나를 두고 이웃과 의견이 다른 행은 구멍 난 목록입니다.

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### 행 하나

껍데기는 언제나 `<li>`입니다. 바뀌는 것은 그 안에 든 것입니다 — 그냥 내용이 놓이거나, `onClick`이나 `href`가 주어지면 그 내용을 감싸는 진짜 `<button>` 또는 `<a>`가 놓입니다.

`action`은 일부러 그 누를 수 있는 영역 바깥에 놓입니다. 이동도 하고 토글도 담는 행에는 누를 것이 둘이고, `<button>` 안의 `<button>`은 브라우저가 파싱하며 다시 쓰는 마크업입니다.

<Demo src="list/rows" :min-height="380">

<<< @/.vitepress/demos/list/rows.tsx

</Demo>

### dividers

dividers를 켜면 선이 시트의 양 끝까지 닿아야 하므로, 목록은 안쪽 여백을 내놓고 행은 둥근 모서리를 내놓습니다. 행이 떠 있는 타일이면서 동시에 그어진 줄일 수는 없습니다.

<Demo src="list/dividers" :min-height="260">

<<< @/.vitepress/demos/list/dividers.tsx

</Demo>

### variant

`PlCard`가 그렇듯 시트에는 색이 들어가지 않습니다. 목록은 남의 내용을 담고, 그 내용은 자기 색을 가지고 도착합니다.

card 안이라면 `ghost`입니다. card가 이미 시트인데, 그 안의 두 번째 테두리 사각형은 사각형이 하나 더 늘어난 것뿐입니다.

<Demo src="list/variants" :min-height="380">

<<< @/.vitepress/demos/list/variants.tsx

</Demo>

### size

<Demo src="list/sizes" :min-height="380">

<<< @/.vitepress/demos/list/sizes.tsx

</Demo>

## Accessibility

- 아래에 Base UI 프리미티브가 없는 것은 의도입니다. 목록은 복합 위젯이 아닙니다 — roving focus도, 선택 모델도, 자기만의 키보드 규약도 없습니다. menu나 listbox 프리미티브를 끌어오면 그냥 링크 목록에 메뉴의 의미를 붙이게 됩니다.
- `role="list"`를 명시적으로 씁니다. Tailwind의 리셋이 모든 `<ul>`에서 불릿을 없애고, Safari는 그와 함께 목록 의미까지 없애기 때문입니다.
- 선택된 링크는 `aria-current="page"`를, 선택된 button은 `aria-current="true"`를 답니다. 앞의 것은 "지금 보고 있는 페이지", 뒤의 것은 "이것들 중 고른 하나"입니다. `aria-pressed`는 세 번째 것, 즉 토글이고, 선택된 행은 토글이 아닙니다.
- `onClick`도 `href`도 없는 행은 role도 tab stop도 더하지 않습니다. click 핸들러만 달린 죽은 `<div>`는 키보드에 보이지 않습니다.
- `action`에 든 컨트롤에는 자기 이름을 주세요. 행과는 별개의 tab stop이고, 거기 있는 이유가 그것입니다.
