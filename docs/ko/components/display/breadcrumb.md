---
title: PlBreadcrumb
order: 9
---

# PlBreadcrumb

<p class="plass-lede">지금 읽고 있는 페이지 위쪽으로 이어지는 자취입니다. 마지막 단계는 독자가 이미 있는 곳이라 스스로 링크이기를 그만두고, 읽기에 너무 긴 자취는 가운데를 <code>…</code> 뒤로 접어 둡니다.</p>

<Demo src="breadcrumb/hero" :min-height="120" />

```tsx
import { PlBreadcrumb, PlBreadcrumbItem } from 'plass-ui';

<PlBreadcrumb>
  <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
  <PlBreadcrumbItem href="/settings">Settings</PlBreadcrumbItem>
  <PlBreadcrumbItem>Billing</PlBreadcrumbItem>
</PlBreadcrumb>;
```

## Props

<PropsTable name="PlBreadcrumb" />

네이티브 `<nav>` 속성은 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 전달 대상에서 제외됩니다.

`variant`도 `elevation`도 없습니다. 자취는 페이지 위에 놓인 표면이 아니라 페이지 위쪽을 가리키는 한 줄의 글입니다.

### PlBreadcrumbItem

<PropsTable name="PlBreadcrumbItem" />

네이티브 `<li>` 속성은 안쪽의 링크가 아니라 `<li>`에 그대로 전달됩니다. `size`는 감싸는 `PlBreadcrumb`에서 상속됩니다 — 타입 스케일을 두고 이웃과 의견이 다른 단계는 구멍 난 자취입니다.

라이브러리 전체에서 공유 축(`size` `color` `density`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### 현재 단계

마지막 단계는 지금 보고 있는 페이지이므로 아예 링크가 아닙니다. `aria-current="page"`를 달고, `href`가 있어도 눌리지 않습니다. 모든 호출자가 그것을 기억하게 하는 대신 컴포넌트가 알아서 판단합니다.

자취에서 그 표시를 달 수 있는 요소는 정확히 하나이므로, `current`로 표시를 가져가는 단계가 있으면 마지막 단계에서 표시가 사라집니다. 손으로 하려면 요청한 적도 없는 단계에 `current={false}`를 써야 합니다.

<Demo src="breadcrumb/current" :min-height="200">

<<< @/.vitepress/demos/breadcrumb/current.tsx

</Demo>

### separator

아무것이나 받는 대신 이름이 붙은 네 가지입니다. 구분자는 하루에도 수백 번 읽히고, 그 차이는 장식이 아니라 의미이기 때문입니다 — `chevron`과 `arrow`는 "그다음", `slash`는 "경로", `dot`은 "한 가지의 동렬"이라고 말합니다. 그 밖의 것은 노드로 넘길 수 있습니다.

방향을 가리키는 둘은 한 번 그려 놓고 돌린 것이고, RTL에서는 되돌아갑니다 — 자취는 언어가 흐르는 방향으로 흐릅니다.

<Demo src="breadcrumb/separators" :min-height="260">

<<< @/.vitepress/demos/breadcrumb/separators.tsx

</Demo>

### maxItems

일곱 단계짜리 자취는 아무도 읽지 않는 자취입니다. 그래서 가운데가 `…`로 접히고, 누르면 되돌아옵니다. `itemsBeforeCollapse`와 `itemsAfterCollapse`가 양 끝에 얼마를 남길지 정하고, `expandable={false}`는 접힌 표시를 그냥 표시로 남깁니다.

접기는 실제로 무언가를 없앨 때만 일어납니다. 양 끝에 하나씩 남기는 세 단계짜리 자취에서 `…`는 정확히 한 단계를 대신하게 되는데, 그것은 대신한 단계보다 깁니다.

<Demo src="breadcrumb/collapse" :min-height="160">

<<< @/.vitepress/demos/breadcrumb/collapse.tsx

</Demo>

### structuredData

올바른 마크업만으로는 검색 결과 아래에 경로가 붙지 않습니다. 붙게 하는 것은 structured data입니다. `structuredData`는 자취를 `schema.org`의 `BreadcrumbList`로 한 번 더 내보냅니다 — `<ol>` 대신이 아니라 그 옆에.

기본은 꺼짐입니다. 페이지에는 이것이 하나만 있을 수 있고, 아주 많은 앱이 이미 자기 SEO 계층에서 내보내고 있습니다. 이 컴포넌트가 **곧** 그 자취인 자리에서 켜세요.

```tsx
<PlBreadcrumb structuredData baseUrl="https://example.com">
  <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
  <PlBreadcrumbItem href="/docs">Docs</PlBreadcrumbItem>
  <PlBreadcrumbItem>Breadcrumb</PlBreadcrumbItem>
</PlBreadcrumb>
```

`maxItems`로 접혀 보이지 않는 단계까지 전부 들어갑니다. 무엇이 접히는지는 행에 자리가 얼마나 있느냐의 문제이고, 경로는 어느 쪽이든 그 경로입니다. `baseUrl`이 URL을 절대 경로로 만들고, 그것이 크롤러가 원하는 형태입니다.

### size

<Demo src="breadcrumb/sizes" :min-height="220">

<<< @/.vitepress/demos/breadcrumb/sizes.tsx

</Demo>

## Accessibility

- 자취는 접근 가능한 이름을 가진 `<nav>`이고 그 안에 `<ol>`이 있습니다. 순서가 곧 의미이므로 순서 있는 목록입니다.
- `role="list"`를 명시적으로 씁니다. Tailwind의 리셋이 모든 `<ol>`에서 불릿을 없애고, Safari는 그와 함께 목록 의미까지 없애기 때문입니다.
- 현재 단계는 `"true"`가 아니라 `aria-current="page"`를 답니다. 자취는 내비게이션이고, 독자가 있는 단계는 선택지 중 고른 하나가 아니라 **페이지**입니다.
- 구분자는 `aria-hidden`입니다. 단계마다 "보다 큼"을 읽는 스크린리더는 문장부호를 읽고 있는 것입니다.
- `onClick`만 있는 단계는 진짜 `<button>`이고, `href`가 있는 단계는 진짜 `<a>`입니다. 어느 쪽도 핸들러가 달린 `<span>`이 아닙니다.
