---
title: 가입
order: 3
aside: false
---

# 가입

<p class="plass-lede">Halyard에 가입하는 세 단계를 한 열에 담았습니다. form은 컴포넌트 라이브러리가 맞물리는지 아닌지가 드러나는 자리입니다 — 여기 있는 컨트롤은 전부 다른 컴포넌트인데, 높이와 label의 위치와 error의 생김새에 대해 서로 합의가 되어 있어야 합니다.</p>

<Demo src="examples/signup" :flutter="false" :min-height="760" />

흐름 전체가 파일 하나입니다 — `docs/.vitepress/demos/examples/signup.tsx`. 살아 있는 화면이라 첫 단계를 비운 채로 넘겨 보면 error가 나타나고, 아무 숫자나 여섯 자리를 넣으면 코드 단계를 지나갑니다.

## 무엇으로 만들었나

| 블록 | 컴포넌트 | 눈여겨볼 점 |
| --- | --- | --- |
| 진행 | `PlTimeline` `PlProgressLinear` | bar만 두지 않고 가로 timeline을 씁니다. 단계에는 이름이 있고, bar는 그 이름을 말하지 못합니다 |
| 계정 | `PlTextField` `PlCheckbox` `PlDivider` `PlButton` `PlTextLink` | field의 `error`는 `description`을 대신하면서 `aria-describedby`까지 연결합니다. checkbox도 `error`를 받습니다 |
| 소셜 로그인 | `PlButton` | `startIcon`과 `fullWidth`. 넓으면 한 줄, 좁으면 위아래로 쌓입니다 |
| 인증 | `PlOtpField` `PlPopover` `PlButton` | `groupSize={3}`이 여섯 칸을 두 묶음으로 나누고, 붙여넣기 한 번에 여섯 칸이 채워집니다 |
| 프로필 | `PlTextField` `PlCombobox` `PlDatePicker` `PlFilePicker` `PlRadioGroup` `PlSwitch` | 같은 `size`에서 field와 combobox와 date picker의 높이가 같아, 2열 grid가 baseline을 유지합니다 |
| 완료 | `PlAlert` `PlIcon` `PlButton` | `success` alert 하나, 그리고 그것과 경쟁하는 것은 아무것도 없음 |
| Aside | `PlCard` `PlList` `PlBlockquote` `PlAvatar` `PlTextLink` | navigation이 아니라 안심시키는 정보이므로 `<aside>`이고, 가장 먼저 사라집니다 |

## Notes

- 검증은 평범한 React state입니다. 읽는 사람이 넘어가려고 시도하기 전까지는 아무것도 틀렸다고 표시하지 않습니다. `tried`가 있는 이유가 그것입니다 — 첫 field에 아직 타이핑하는 중에 빨개지는 form은 소리를 지르는 form입니다.
- 단계는 숫자 하나이고 각 섹션은 평범한 조건문입니다. Plass에 wizard 컴포넌트는 없고, 있을 필요도 없습니다. 단계는 state 조각이고 나머지는 레이아웃입니다.
- "Verify" 버튼이 기다리는 것은 `PlOtpField`입니다. 여섯 자리가 채워지면 활성화되고, 붙여넣기와 칸을 넘는 backspace와 숫자 키패드는 field가 알아서 처리합니다.

## Next

- 화면이 두 개 더 있습니다 — [관리자 대시보드](./dashboard)와 [랜딩 페이지](./landing).
- 컴포넌트별 prop과 예제는 [컴포넌트](../components/)에 있습니다.
