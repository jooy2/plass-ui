---
title: 랜딩 페이지
order: 2
aside: false
---

# 랜딩 페이지

<p class="plass-lede">존재하지 않는 제품 Halyard의 소개 페이지입니다. 랜딩 페이지는 앱과 정반대의 질문을 던집니다 — 600행짜리 표를 견딜 수 있느냐가 아니라, 이 부품들로 누군가 읽고 싶어 하는 페이지 하나가 만들어지느냐입니다.</p>

<Demo src="examples/landing" :flutter="false" :min-height="1000" />

페이지 전체가 파일 하나입니다 — `docs/.vitepress/demos/examples/landing.tsx`. 살아 있는 페이지라 요금제를 월 단위로 바꾸고, 후기를 넘겨 보고, FAQ를 열어 볼 수 있습니다.

## 무엇으로 만들었나

| 블록 | 컴포넌트 | 눈여겨볼 점 |
| --- | --- | --- |
| Nav | `PlToolbar` `PlTextLink` `PlButton` | `render={<header />}`가 진짜 landmark로 만들고, `position="sticky"`가 call to action을 계속 손 닿는 곳에 둡니다 |
| Hero | `PlChip` `PlTypography` `PlButton` `PlAvatar` `PlRating` | 겹친 avatar는 `PlStack`입니다. 음수 margin과 ring이고, avatar에 대한 것은 아무것도 없습니다 |
| 제품 화면 | `PlTabs` `PlTab` `PlTabPanel` `PlAspectRatio` | 같은 비율의 panel 셋이라 전환해도 페이지가 움직이지 않습니다 |
| 기능 | `PlGrid` `PlGridItem` `PlCard` `PlIcon` | 각 item에 responsive `span` 하나 — 12, 6, 3 — 이 그 줄의 규칙 전부입니다 |
| 후기 | `PlCarousel` `PlBlockquote` | scroll snap 위에 얹혀 있어서 휴대폰에서 스와이프되고 RTL에서 방향이 뒤집힙니다 |
| 요금제 | `PlSegmentedButton` `PlCard` `PlChip` `PlIcon` `PlButton` | 월/연은 둘 중 하나이고, 추천 요금제는 다른 색이 아니라 `elevation={3}`입니다 |
| FAQ | `PlAccordion` `PlAccordionItem` | 하나는 열린 채로 시작합니다. 전부 접힌 accordion은 제목 목록처럼 보입니다 |
| 가입 영역 | `PlTextField` `PlButton` `PlTextLink` | 진짜 `<form>`에 진짜 `type="submit"`이라 field 안에서 Enter가 동작합니다 |
| Footer | `PlDivider` `PlTextLink` | `underline="hover"` — 항상 밑줄이 그어진 링크 줄은 경고처럼 읽힙니다 |

## 참고

- 추천 요금제는 **elevation과 chip**으로 표시합니다. 채도 높은 fill이 아닙니다. 카드가 전부 색을 두르고 있으면 더 강조할 것이 남지 않습니다.
- 섹션 배경은 `--plass-glass-press`, 라이브러리가 눌린 표면에 쓰는 그 token입니다. 이 파일을 위해 새로 만든 팔레트가 아니라 페이지 자신의 구조입니다.
- 모든 제목은 `PlTypography`의 `level`입니다. 이 페이지의 타입 스케일은 섹션마다 고른 Tailwind 크기가 아니라 라이브러리의 것입니다.

## 다음

- 화면이 두 개 더 있습니다 — [관리자 대시보드](./dashboard)와 [가입](./signup).
- 컴포넌트별 prop과 예제는 [컴포넌트](../components/)에 있습니다.
