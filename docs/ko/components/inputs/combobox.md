---
title: PlCombobox
order: 5
---

# PlCombobox

<p class="plass-lede">입력할 수도 있고 고를 수도 있는 field입니다. 입력한 글자가 목록을 거르고, 막지 않는 한 그 글자 자체가 값이 될 수도 있습니다.</p>

<Demo src="combobox/hero" :flutter="false" :min-height="180" />

::: fw react

```tsx
import { PlCombobox } from 'plass-ui';

<PlCombobox
  label="Framework"
  placeholder="Search…"
  items={[
    { value: 'react', label: 'React' },
    { value: 'vue', label: 'Vue' }
  ]}
/>;
```

:::

## Props

<PropsTable name="PlCombobox" />

::: fw react

나머지 `<div>` 속성은 field 래퍼로 그대로 통과합니다. `color`는 위 표의 `color`와 겹쳐서, `defaultValue`는 DOM 속성이 아니라 값으로 쓰기 때문에, `children`은 옵션이 `items`이기 때문에 제외했습니다.

:::

### PlComboboxOption

<PropsTable name="PlComboboxOption" />

공유 축(`variant` `size` `color` `density` `elevation`)이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## chevron을 단 PlTextField입니다

픽셀 단위로 그렇고, [`PlSelect`](./select)의 trigger도 마찬가지입니다. 폼 안에서 셋이 구분되지 않아야 폼이 조립된 게 아니라 설계된 것으로 보입니다. 껍데기가 셋 중 어디도 아닌 `internal/styles`에 사는 이유입니다.

다른 건 글자가 하는 일입니다. select에서 글자는 값이고, 여기서 글자는 목록을 거르며 값이 될 수도 있습니다.

## Examples

### 고르기와 입력하기

[`PlSelect`](./select)는 닫힌 집합에서 고르는 컨트롤입니다. 이건 집합을 _검색_ 하는 컨트롤이고, 기본값인 `allowCustom`이 켜져 있으면 거기에 더할 수도 있는 컨트롤입니다.

입력한 글자는 목록 끝의 자기 행으로 제안됩니다. 그래서 그것을 확정하는 건 사용자가 하는 선택이지, blur에서 사용자에게 일어나는 일이 아닙니다. 값이 정말로 닫힌 집합이면 `allowCustom`을 끄세요 — 그러면 검색되는 select가 됩니다.

<Demo src="combobox/custom" :flutter="false" :min-height="260">

<<< @/.vitepress/demos/combobox/custom.tsx

</Demo>

### multiple

고른 값들이 field 안의 [`PlChip`](../display/chip)이 되고 입력은 그 뒤로도 계속 필터링합니다. field가 한 번도 닫히지 않은 채 태그 묶음이 만들어집니다.

이때 field는 고정 높이를 가질 수 없습니다 — chip이 줄바꿈하니까요 — 그래서 패딩이 `(컨트롤 높이 − chip 높이) / 2`가 되고, 한 줄짜리 combobox는 옆의 field와 정확히 같은 높이가 됩니다.

<Demo src="combobox/multiple" :flutter="false" :min-height="180">

<<< @/.vitepress/demos/combobox/multiple.tsx

</Demo>

### size

다른 모든 컨트롤과 같은 높이 사다리입니다. `multiple`에서는 위의 이유로 그 숫자가 높이가 아니라 최소 높이가 됩니다.

<Demo src="combobox/sizes" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/combobox/sizes.tsx

</Demo>

### readOnly · disabled · error

`error`는 combobox를 invalid로도 만들고, 그러면 색 계열 전체가 `danger`로 옮겨 갑니다 — 테두리와 ring과 caret과 메시지가 함께 넘어갑니다. `invalid`는 메시지 없이 같은 일을 합니다.

`readOnly` combobox는 값과 포커스를 유지하되 입력을 받지 않고, chip의 ×도 사라집니다. `disabled`는 포커스 순서에서 빠집니다.

옵션 하나만 `disabled`일 수도 있습니다. 그래도 목록에 남습니다 — 고를 수 없다고 사라지는 옵션은 독자가 찾아 헤매게 되는 옵션입니다.

<Demo src="combobox/states" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/combobox/states.tsx

</Demo>

### Controlled

`value`를 `onValueChange`와 함께 주세요. 값은 `string`이나 `number`이고 — `multiple`이면 그 배열입니다 — 절대 객체가 아닙니다. combobox는 form 컨트롤이고, 그 값은 form이 보내는 것입니다. 식별자를 여기 두고 객체는 반대편에서 찾으세요.

## Accessibility

- Base UI가 `combobox`/`listbox` 쌍을 렌더링하고 `aria-expanded`와 `aria-activedescendant`를 맞춰 두며, 필터링과 collator도 소유합니다.
- `label` `description` `error`는 Base UI의 Field가 입력창과 엮어 주므로 `htmlFor`가 필요 없습니다.
- 키보드는 primitive의 것입니다. <kbd>↑</kbd> <kbd>↓</kbd>로 목록을 움직이고, <kbd>Enter</kbd>로 강조된 행을 취하고, <kbd>Esc</kbd>로 닫습니다. `multiple`에서는 <kbd>←</kbd> <kbd>→</kbd>가 chip 사이를 걷고 <kbd>Backspace</kbd>가 하나를 지웁니다.
- 입력하는 동안 첫 일치 항목에 불이 들어와서, 화살표 없이 <kbd>Enter</kbd>만으로 확정됩니다. "이걸 추가" 행이 키보드로 닿을 수 있는 이유도 이것입니다 — 목록에 없는 값은 유일한 일치 항목이니까요.
- "이걸 추가" 행은 키 처리의 특수 케이스가 아니라 **진짜 option**입니다. 클릭도, <kbd>Enter</kbd>도, 화살표도 다른 모든 행과 똑같은 방식으로 닿습니다.
- 행은 `:hover`가 아니라 `data-highlighted`로 켜집니다. 포인터와 화살표가 같은 행을 밝힙니다.
- chip의 ×는 자기 chip의 이름을 답니다 — `Remove`가 아니라 `Remove Seoul`. 똑같은 버튼 여섯 개를 읽어 주는 스크린리더는 아무것도 말해 주지 않은 것과 같습니다.
- `name`이 있으면 Base UI가 hidden input을 렌더링해 값이 네이티브 form 제출에 포함됩니다.
- 팝업은 `<body>` 끝으로 portal되고 positioner가 `.plass-portal`을 답니다. CSS 리셋을 subtree에 한정한 호스트가 같은 리셋을 걸 수 있는 자리입니다.
