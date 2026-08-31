---
title: PlEmpty
order: 13
---

# PlEmpty

<p class="plass-lede">아무것도 없는 자리 — 빈 목록, 결과가 없는 검색, 끝난 절차. 표시 하나, 한 줄, 한 문장, 그리고 빠져나갈 길.</p>

<Demo src="empty/hero" :min-height="300" />

::: fw react

```tsx
import { PlEmpty } from 'plass-ui';

<PlEmpty
  icon={<InboxIcon />}
  title="No projects yet"
  description="Start one and it will show up here."
  actions={<PlButton>New project</PlButton>}
/>;
```

:::

## Props

<PropsTable name="PlEmpty" />

네이티브 `<div>` 속성은 그대로 통과합니다. 공유 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 넷이 아니라 하나

빈 목록, 결과 없는 검색, 실패한 요청, 끝난 절차는 **같은 배치**입니다 — 표시 하나, 한 줄, 한 문장, 빠져나갈 길 — 그래서 하나의 컴포넌트입니다. 그것들을 구분하는 것은 `color`입니다.

|                    |                                                                          |
| ------------------ | ------------------------------------------------------------------------ |
| `secondary` (기본) | **아직** 아무것도 없습니다. 잘못된 것은 없습니다                         |
| `danger`           | 잘못된 것이 있습니다                                                     |
| `success`          | 끝났습니다 — 두 번째 컴포넌트 없이 "주문이 확인되었습니다" 화면이 됩니다 |

<Demo src="empty/kinds" :min-height="280">

::: fw react

<<< @/.vitepress/demos/empty/kinds.tsx

:::

</Demo>

## 표면을 그리지 않습니다

빈 상태는 언제나 무언가 **안에** 있습니다 — 카드, 표, 패널 — 그리고 시트 안의 시트는 시트 둘입니다. 이 컴포넌트가 정하는 것은 배치와 그 주위의 공간입니다.

<Demo src="empty/table" :min-height="280">

::: fw react

<<< @/.vitepress/demos/empty/table.tsx

:::

</Demo>

`PlTable`의 `empty` prop이 node를 받는데, 이것이 그 node가 기다리던 것입니다.

## 빠져나갈 길

제대로 할 가치가 있는 하나입니다. "프로젝트 없음"이라고 말하고 멈추는 화면은 막다른 길입니다. 같은 화면에 "새 프로젝트" 버튼이 있으면, 그것을 권하기에 절차 전체에서 가장 좋은 순간이 됩니다 — 사용자가 그것이 들어갈 자리를 똑바로 보고 있으니까요.

정말로 할 일이 없다면 — 결과 없는 검색처럼, 할 일이 "다른 걸 입력하기"라면 — 버튼을 지어내는 대신 description에 그렇게 쓰세요.

## Accessibility

- 글리프는 `aria-hidden`입니다. title이 그것이 말하는 바를 말하고, 사용자가 두 번 들어서는 안 됩니다.
- **자체 role이 없습니다.** 그 비어 있음이 사용자가 방금 한 일의 *결과*일 때 — 필터를 지웠거나 검색을 돌렸을 때 — `role="status"`를 붙여 변화가 알려지게 하세요. 페이지가 로드될 때부터 비어 있던 목록에는 붙이지 마세요. 이미 읽혔습니다.
- title은 heading이 아니라 `<p>`입니다. 문서 개요에서 그것이 어디에 속하는지는 페이지의 결정이지 이 컴포넌트의 것이 아닙니다. heading이어야 한다면 위에 `PlTypography`를 두세요.
