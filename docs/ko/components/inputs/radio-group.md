---
title: PlRadioGroup
order: 7
---

# PlRadioGroup

<p class="plass-lede">여러 옵션 중 정확히 하나를 고르는 묶음입니다. 묶음 전체가 tab stop 하나를 차지하고, 그 안에서는 방향키로 움직입니다.</p>

<Demo src="radio-group/hero" :min-height="240" />

```tsx
import { PlRadio, PlRadioGroup } from 'plass-ui';

<PlRadioGroup label="Plan" defaultValue="team">
  <PlRadio value="starter" label="Starter" />
  <PlRadio value="team" label="Team" />
</PlRadioGroup>;
```

## Props

<PropsTable name="PlRadioGroup" />

Base UI `RadioGroup`의 나머지 prop은 그대로 전달됩니다. `className`과 `style`은 field wrapper에 붙고, `render`는 제공하지 않습니다.

### PlRadio

<PropsTable name="PlRadio" />

`size`와 `color`는 옵션에 주는 것이 아니라 감싸는 `PlRadioGroup`에서 내려받습니다. radio button은 혼자서는 아무 말도 하지 않으므로, 어떻게 보이는지는 묶음의 몫입니다. 옵션마다 주는 것은 넷 중 하나를 틀릴 기회를 네 번 만드는 일입니다.

라이브러리 전체에서 공유 축(`size` `color` `orientation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### orientation

기본은 세로입니다. 세로로 늘어선 옵션은 개수가 늘어도 훑을 수 있지만, 가로줄은 라벨 하나가 예상보다 길어지는 순간 조용히 읽기 어려워집니다.

<Demo src="radio-group/orientation" :min-height="280">

<<< @/.vitepress/demos/radio-group/orientation.tsx

</Demo>

### color

선택되면 dot이 색 계열의 그러데이션으로 채워지고, 안쪽 원은 계열 고유의 `on-solid` 잉크입니다. dot은 둥글고, 라이브러리에서 둥근 것 둘 중 하나입니다 — 둥근 모양이 "이 중 하나"와 "이 중 아무거나"를 구분해 주고, 이 관습은 깨는 비용이 얻는 것보다 큰 정도로 오래된 것입니다.

<Demo src="radio-group/colors" :min-height="180">

<<< @/.vitepress/demos/radio-group/colors.tsx

</Demo>

### size

그룹에 주면 모든 옵션이 물려받으므로, 한 묶음 안에 dot 크기가 두 가지가 되는 일이 없습니다.

각 단계의 안쪽 원은 바깥 원의 content box와 **홀짝이 같습니다** — 12/6, 14/6, 16/8, 18/8, 22/10 — 그래서 둘레 여백이 정수 픽셀입니다. 1px 테두리를 가진 18px 원 안의 7px 점은 정확히 가운데에 있으면서 사방으로 4.5px 떨어져 있고, 네 변이 모두 절반만 칠해진 원은 왼쪽 위로 밀린 것처럼 읽힙니다. dot과 라벨이 함께 쓰는 line box가 정수인 것도 같은 이유입니다. 그 대가로 비율이 38%에서 44% 사이를 오가는데, 얻는 것에 비하면 보이지 않는 차이입니다.

<Demo src="radio-group/sizes" :min-height="180">

<<< @/.vitepress/demos/radio-group/sizes.tsx

</Demo>

### readOnly · disabled · error

그룹의 `disabled`는 모든 옵션을 멈추고, `PlRadio` 하나의 `disabled`는 그 옵션만 멈춥니다. 그래도 목록에는 남습니다 — 고를 수 없다고 사라지는 옵션은 읽는 사람이 계속 찾게 되는 옵션입니다.

그룹의 `error`는 invalid 상태도 만들고, 그러면 색 계열 전체가 `danger`를 가리킵니다.

<Demo src="radio-group/states" :min-height="260">

<<< @/.vitepress/demos/radio-group/states.tsx

</Demo>

### Controlled

`value`와 `onValueChange`를 함께 넘기세요. 값은 `PlRadio`에 준 것 그대로입니다 — 보통은 문자열이지만, Base UI가 identity로 비교하므로 렌더 사이에 안정적이기만 하면 무엇이든 됩니다.

<Demo src="radio-group/controlled" :min-height="180">

<<< @/.vitepress/demos/radio-group/controlled.tsx

</Demo>

## Accessibility

- Base UI가 진짜 radio들을 담은 `role="radiogroup"`을 렌더링하고 `aria-checked`를 맞춰 주며, roving tab index를 소유합니다 — 묶음이 tab stop 하나를 차지하고 <kbd>↑</kbd> <kbd>↓</kbd> <kbd>←</kbd> <kbd>→</kbd>로 그 안에서 움직입니다. radio group이 `<div>`에 input을 담은 것이 아니라 컴포넌트여야 하는 이유가 바로 이것입니다.
- 그룹의 `label`, `description`, `error`는 Base UI의 Field가 엮어 주고, 각 옵션의 라벨도 마찬가지입니다 — 라벨을 누르면 그 옵션이 선택됩니다.
- 각 dot은 자기 라벨의 **첫 줄**에 맞춰 중앙에 놓이므로, 라벨이 줄바꿈되어도 자리를 지킵니다.
- 선택된 dot은 색이 바뀌기만 하는 것이 아니라 채워진 원입니다. 채움을 볼 수 없는 사람에게는 모양이 상태를 나릅니다.
- `name`을 주면 Base UI가 hidden input을 렌더링해서 선택이 네이티브 form 제출에 포함됩니다.
