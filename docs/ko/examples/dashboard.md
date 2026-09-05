---
title: 관리자 대시보드
order: 1
aside: false
---

# 관리자 대시보드

<p class="plass-lede">존재하지 않는 상점 Grange의 백오피스입니다. rail 하나, app bar 하나, 지표 네 개, filter 한 줄, 그리고 행마다 action이 붙은 table — 전부 한 화면에, 전부 같은 <code>size</code>로. size 사다리가 실제로 맞아떨어지는지 보여 주는 배치입니다.</p>

<Demo src="examples/dashboard" :flutter="false" :min-height="900" />

화면 전체가 파일 하나입니다 — `docs/.vitepress/demos/examples/dashboard.tsx`. 살아 있는 화면이라 table을 검색하고, 채널이나 상태로 거르고, 행을 몇 개 선택하면 일괄 action이 나타납니다.

## 구성

| 블록 | 컴포넌트 | 눈여겨볼 점 |
| --- | --- | --- |
| Rail | `PlList` `PlListItem` `PlIcon` `PlBadge` `PlPill` `PlCard` `PlProgressLinear` | `render={<nav />}`가 list를 진짜 landmark로 만들고, `selected`가 현재 행을 표시하며, 안 읽은 개수는 `endIcon`에 들어갑니다 |
| App bar | `PlToolbar` `PlBreadcrumb` `PlBadge` `PlIconButton` `PlTooltip` `PlAvatar` | `position="sticky"` 덕분에 페이지가 아래로 흘러도 action에 계속 닿을 수 있습니다 |
| Alert | `PlAlert` | 신경 써야 할 일 하나를, 맨 위에서, 한 번만, 자기 `action`과 함께 |
| 지표 | `PlCard` `PlTypography` `PlProgressLinear` `PlProgressCircular` | 목표까지의 진행은 bar로, 숫자 자체가 전체 중 일부인 경우에는 ring으로 |
| Filter | `PlTextField` `PlSelect` `PlDateRangePicker` `PlSegmentedButton` | 같은 `size="sm"`에서 field와 select와 range picker의 높이가 같아, 한 줄이 baseline을 유지합니다 |
| Table | `PlTable` `PlCheckbox` `PlChip` `PlMenu` `PlIconButton` `PlPagination` | 전체 선택은 header cell 안의 `indeterminate` checkbox이고, 모든 행이 자기 `PlMenu`를 가집니다 |
| 일괄 action | `PlButton` `PlModal` `PlToast` | 선택이 있을 때만 나타납니다. 파괴적인 쪽은 `PlModal`로 한 번 확인하고, 되돌릴 수 있는 toast로 결과를 알립니다 |
| 아래 줄 | `PlCard` `PlTimeline` `PlSwitch` `PlDivider` | 무슨 일이 있었는지와 무엇이 나에게 도달하는지 — 같은 elevation의 같은 card, 두 번 |
| 설정 | `PlDrawer` `PlSelect` `PlSwitch` | 화면에 있을 필요가 없는 설정은 화면 위로 미끄러져 들어오는 sheet 안에 |

## Notes

- 상태 filter는 `PlTabs`가 아니라 `PlSegmentedButton`입니다. 아래에 있는 것은 panel이 아니라 어느 쪽이든 같은 table이고, segmented button은 넷 중 하나를 고르는 컨트롤입니다.
- filter는 평범한 React state입니다. `PlTable`은 넘겨받은 것을 그리고, 그것이 아무것도 아니면 `empty`를 보여 줍니다.
- 모든 행 action에는 어느 행의 것인지 말해 주는 접근 가능한 이름이 있습니다. trigger `PlIconButton`의 `label`에 주문 id가 들어가기 때문입니다.
- 일괄 action의 `PlModal`은 `modal="trap-focus"`를 넘깁니다. 완전한 modal은 뒤 페이지를 inert로 만드는데, 앱에서는 맞고 문서 안 미리 보기에서는 틀립니다.

## Next

- 화면이 두 개 더 있습니다 — [랜딩 페이지](./landing)와 [가입](./signup).
- 컴포넌트별 prop과 예제는 [컴포넌트](../components/)에 있습니다.
