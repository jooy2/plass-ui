---
title: PlCheckbox
order: 6
---

# PlCheckbox

<p class="plass-lede">하나의 예/아니오, 또는 그런 항목 여러 개 중 하나입니다. 박스는 체크되기 전까지 작은 맑은 유리판이고, 체크되면 색 계열의 그러데이션이 됩니다.</p>

<Demo src="checkbox/hero" :min-height="160" />

```tsx
import { PlCheckbox } from 'plass-ui';

<PlCheckbox label="Email me about releases" defaultChecked />;
```

## Props

<PropsTable name="PlCheckbox" />

Base UI `Checkbox.Root`의 나머지 prop은 그대로 전달됩니다. `className`과 `style`은 tick이 아니라 field wrapper에 붙고, `render`는 제공하지 않습니다 — tick을 갈아 끼우면 더 이상 checkbox가 아니기 때문입니다.

`variant`는 없습니다. 켜짐과 꺼짐은 같은 재질의 두 세기가 아니라서, 박스는 사다리를 한 칸 옮기는 대신 표면 전체를 갈아 끼웁니다. 라이브러리에서 상태를 이렇게 표현하는 곳은 여기 하나뿐입니다.

라이브러리 전체에서 공유 축(`size` `color`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### color

체크되면 박스가 색 계열의 그러데이션으로 채워지고, 그 위의 표시는 계열 고유의 `on-solid` 잉크입니다. 대비를 측정한 기준이 바로 그 값입니다.

<Demo src="checkbox/colors" :min-height="120">

<<< @/.vitepress/demos/checkbox/colors.tsx

</Demo>

### size

tick은 컨트롤 높이에서 한 단계 내린 값이 아니라 자기 사다리를 씁니다. 안에 라벨을 넣을 수 있는 컨트롤이 아니라 라벨 옆에 놓이는 표시이므로, 행이 아니라 옆의 글자를 기준으로 크기가 정해집니다. 모서리 반경도 훨씬 작습니다 — 18px 박스에 `--plass-radius-md`를 주면 거의 원이 되는데, 둥근 checkbox는 radio button입니다.

<Demo src="checkbox/sizes" :min-height="220">

<<< @/.vitepress/demos/checkbox/sizes.tsx

</Demo>

### indeterminate

자식 항목 묶음 위에 놓인 부모 박스를 위한 세 번째 상태입니다. 체크도 해제도 아닌 상태로, 표시가 대시로 바뀌고 `aria-checked="mixed"`로 읽힙니다.

값이 아니라 표시 상태입니다 — indeterminate인 박스를 누르면 체크됩니다.

<Demo src="checkbox/indeterminate" :min-height="240">

<<< @/.vitepress/demos/checkbox/indeterminate.tsx

</Demo>

### readOnly · disabled · error

`error`는 checkbox를 invalid로도 만들고, 그러면 색 계열 전체가 `danger`를 가리킵니다 — 박스와 ring, 메시지가 함께 넘어갑니다.

<Demo src="checkbox/states" :min-height="280">

<<< @/.vitepress/demos/checkbox/states.tsx

</Demo>

## Accessibility

- Base UI가 `aria-checked`를 가진 `role="checkbox"` 컨트롤을 렌더링하고, `name`을 주면 네이티브 form 제출에 포함되는 hidden input도 함께 렌더링합니다.
- `label`, `description`, `error`는 Base UI의 Field가 컨트롤에 엮어 줍니다. 라벨을 누르면 체크되고, 스크린리더는 셋을 함께 읽습니다.
- tick은 `1lh`로 라벨의 **첫 줄**에 맞춰 중앙에 놓입니다. 라벨이 세 줄로 늘어나도 자리를 지킵니다.
- `indeterminate`는 `aria-checked="mixed"`로 읽히고, 색 없이도 그것을 말해 주는 것이 체크가 아닌 대시입니다.
- focus ring은 `:focus-visible`에서만 나타나므로 마우스 클릭에는 그려지지 않습니다.
- `label`이 없는 checkbox에는 `aria-label`이 필요합니다 — 옆에 아무것도 없는 박스는 아무도 이름을 붙일 수 없습니다.
