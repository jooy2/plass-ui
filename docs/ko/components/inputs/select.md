---
title: PlSelect
order: 4
---

# PlSelect

<p class="plass-lede">여러 값 중 하나를 고릅니다. trigger는 chevron을 단 <code>PlTextField</code>의 껍데기 그대로라, 같은 form 안의 select와 field가 하나의 물건으로 읽힙니다.</p>

<Demo src="select/hero" :min-height="180" />

```tsx
import { PlSelect } from 'plass-ui';

<PlSelect
  label="City"
  placeholder="Pick a city"
  items={[
    { value: 'seoul', label: 'Seoul' },
    { value: 'lisbon', label: 'Lisbon' }
  ]}
/>;
```

## Props

<PropsTable name="PlSelect" />

네이티브 `<div>` 속성은 field wrapper로 그대로 전달됩니다. `color`는 위 표의 `color`와 충돌해서, `defaultValue`는 DOM 속성이 아니라 값으로 쓰기 때문에, `children`은 옵션이 `items`이기 때문에 제외됩니다.

### PlSelectOption

<PropsTable name="PlSelectOption" />

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### variant

`PlTextField`가 입는 것과 똑같은 세 재질을, 똑같은 껍데기 위에서 씁니다. `solid`는 색 유리판이 아니라 **우물** — 가장 불투명한 유리에 안쪽으로 떨어지는 그림자 — 입니다. 그러데이션 위에서 읽어야 하는 값은 결국 그러데이션 위에서 읽어야 하는 값이기 때문입니다.

<Demo src="select/variants" :min-height="140">

<<< @/.vitepress/demos/select/variants.tsx

</Demo>

### size

다른 모든 컨트롤과 같은 높이 사다리를 씁니다. trigger를 field의 껍데기 위에 그리는 이유가 바로 이것입니다 — select만 주변 field와 높이나 모서리, 재질이 다른 form은 설계된 것이 아니라 조립된 것처럼 보입니다.

<Demo src="select/sizes" :min-height="220">

<<< @/.vitepress/demos/select/sizes.tsx

</Demo>

### readOnly · disabled · error

`error`는 select를 invalid로도 만들고, 그러면 색 계열 전체가 `danger`를 가리킵니다 — 테두리, ring, 메시지가 함께 넘어갑니다. `invalid`는 메시지 없이 같은 일을 합니다. 외부 form 라이브러리가 유효성을 쥐고 있을 때 쓰세요.

`readOnly`인 select는 값과 focus를 유지하지만 열리지 않습니다. `disabled`인 것은 포커스 순서에서 빠집니다.

옵션 하나만 `disabled`로 둘 수도 있습니다. 그래도 목록에는 남습니다 — 고를 수 없다고 사라지는 옵션은 읽는 사람이 계속 찾게 되는 옵션입니다.

<Demo src="select/states" :min-height="200">

<<< @/.vitepress/demos/select/states.tsx

</Demo>

### Controlled

`value`와 `onValueChange`를 함께 넘기세요. 값은 언제나 `string`이나 `number`이고 객체가 아닙니다 — select는 form 컨트롤이고, 그 값은 form이 제출하는 것입니다. 식별자만 여기 두고 객체는 반대쪽에서 찾으세요.

<Demo src="select/controlled" :min-height="160">

<<< @/.vitepress/demos/select/controlled.tsx

</Demo>

### startIcon

`1.2em`으로 그려져 옆의 값 크기를 따라갑니다. `endIcon`은 없습니다 — trigger의 끝자리는 chevron의 것입니다.

<Demo src="select/icons" :min-height="160">

<<< @/.vitepress/demos/select/icons.tsx

</Demo>

## Accessibility

- Base UI가 `role="combobox"` trigger와 진짜 `option` 행을 가진 `listbox` 팝업을 렌더링하고, `aria-expanded`와 `aria-activedescendant`를 맞춰 주며, 목록이 열려 있는 동안 focus를 가둡니다.
- `label`, `description`, `error`는 Base UI의 Field가 trigger에 엮어 주므로 `htmlFor`가 필요 없습니다.
- 키보드는 primitive의 것입니다. <kbd>↑</kbd> <kbd>↓</kbd> <kbd>Home</kbd> <kbd>End</kbd>로 이동하고, 글자를 치면 prefix로 건너뛰며, <kbd>Enter</kbd>로 고르고 <kbd>Esc</kbd>로 닫습니다.
- 행은 `:hover`가 아니라 `data-highlighted`에서 밝아집니다. 포인터와 방향키가 같은 행을 비춥니다.
- `name`을 주면 Base UI가 hidden input을 렌더링해서 값이 네이티브 form 제출에 포함됩니다.
- trigger는 보여 줄 수 있는 가장 긴 라벨의 너비로 벌어져 있습니다. 짧은 옵션을 골랐다고 방금 고른 포인터 아래에서 필드가 줄어들지 않습니다. 이 샘플들은 `aria-hidden`이고 생성 콘텐츠로 그려지므로, 읽히지도 않고 페이지 내 검색에 걸리지도 않습니다.
- 팝업은 `<body>` 끝으로 portal되고, positioner에 `.plass-portal`이 붙습니다. reset을 subtree에 한정해 둔 호스트가 같은 reset을 걸 수 있는 자리입니다.
