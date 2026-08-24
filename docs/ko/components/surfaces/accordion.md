---
title: PlAccordion
order: 1
---

# PlAccordion

<p class="plass-lede">한 번에 하나씩 펼쳐지는 섹션 묶음입니다. 무엇을 읽을지 먼저 훑어보는 참고성 내용 — 설정 그룹, 사양표, FAQ — 에 씁니다.</p>

<Demo src="accordion/hero" :min-height="240" />

```tsx
import { PlAccordion, PlAccordionItem } from 'plass-ui';

<PlAccordion defaultValue={['shipping']}>
  <PlAccordionItem value="shipping" title="Shipping">
    Three to five working days.
  </PlAccordionItem>
  <PlAccordionItem value="returns" title="Returns">
    Thirty days from delivery.
  </PlAccordionItem>
</PlAccordion>;
```

## Props

<PropsTable name="PlAccordion" />

네이티브 `<div>` 속성은 그대로 전달됩니다. `color`는 위 표의 `color`와 충돌해서, `defaultValue`와 `onChange`는 accordion이 각각 배열형 `defaultValue`와 `onValueChange`로 쓰기 때문에 제외됩니다.

### PlAccordionItem

<PropsTable name="PlAccordionItem" />

`size`, `density`, `dividers`는 item에 주는 prop이 아니라 감싸고 있는 `PlAccordion`에서 내려받습니다.

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### variant

세 가지 재질을 **컨테이너** 입장에서 읽은 것입니다. `solid`는 가장 불투명한 맑은 유리로, 주변보다 앞으로 나와 있어야 하는 판에 씁니다. `glass`는 Plass의 기본 시트이자 기본값입니다. `ghost`는 시트가 아예 없어서, 이미 시트인 `PlCard` 안에 넣을 때 씁니다 — 사각형 안의 또 다른 사각형은 사각형 하나가 더 많은 것입니다.

셋 중 어느 것에도 색이 들어가지 않습니다. accordion이 담는 내용은 자기 색을 가지고 오기 때문에, 색 계열은 hover 틴트와 열린 섹션의 제목, focus ring까지만 닿고 거기서 멈춥니다.

<Demo src="accordion/variants" :min-height="200">

<<< @/.vitepress/demos/accordion/variants.tsx

</Demo>

### multiple

기본값에서는 한 섹션을 열면 열려 있던 섹션이 닫힙니다. accordion이 collapsible을 쌓아 놓은 것과 다른 이유가 바로 이것으로, 다음을 열 때 앞의 것이 닫히는 덕분에 읽는 도중 페이지가 아래로 자라지 않습니다. `multiple`은 이 제약을 풉니다.

<Demo src="accordion/multiple" :min-height="220">

<<< @/.vitepress/demos/accordion/multiple.tsx

</Demo>

### dividers

기본으로 켜져 있습니다. 양 끝까지 닿는 헤어라인이 여러 섹션을 한 장의 판으로 묶어 줍니다. 끄면 각 섹션이 자기 타일이 되고, 여백으로 구분됩니다.

<Demo src="accordion/dividers" :min-height="180">

<<< @/.vitepress/demos/accordion/dividers.tsx

</Demo>

### title · subtitle · startIcon · action

`action`은 trigger **바깥**에 렌더링됩니다. 접히기도 하고 버튼도 쥐고 있는 헤더에는 누를 것이 두 개인데, 그중 하나를 다른 하나 안에 넣을 수는 없습니다 — 브라우저는 `<button>` 안의 `<button>`을 파싱 단계에서 다시 씁니다.

<Demo src="accordion/slots" :min-height="220">

<<< @/.vitepress/demos/accordion/slots.tsx

</Demo>

### size

제목과 본문, 그리고 둘을 감싸는 여백이 함께 움직입니다. accordion에 주면 모든 섹션이 내려받으므로, 한 묶음 안에 타입 스케일이 두 개가 되는 일이 없습니다.

<Demo src="accordion/sizes" :min-height="320">

<<< @/.vitepress/demos/accordion/sizes.tsx

</Demo>

### Controlled

`value`와 `onValueChange`를 함께 넘기면 열린 섹션 집합을 직접 쥘 수 있습니다. `multiple`이 꺼져 있어도 둘 다 배열입니다 — 전부 닫힌 상태는 `[]`입니다.

<Demo src="accordion/controlled" :min-height="280">

<<< @/.vitepress/demos/accordion/controlled.tsx

</Demo>

## Accessibility

- 각 헤더는 `aria-expanded`를 가진 진짜 `<button>`이고, `aria-controls`로 자기 패널을 가리킵니다. 패널은 헤더가 이름을 붙여 주는 `region`입니다.
- <kbd>Enter</kbd>와 <kbd>Space</kbd>로 섹션을 접고 폅니다. <kbd>Tab</kbd>은 헤더 사이와 열린 패널 안으로 이동합니다.
- `hiddenUntilFound`는 닫힌 패널을 `hidden="until-found"`로 렌더링하므로, 브라우저의 페이지 검색이 그 안의 글자를 찾아 해당 섹션을 열어 줍니다.
- chevron은 장식이라 `aria-hidden`입니다. 열림 상태는 `aria-expanded`가 나르며, 회전만으로 전달되는 정보는 없습니다.
- `action`에 넣은 것은 자기 tab stop을 가진 별개의 컨트롤이므로, 접근 가능한 이름도 따로 필요합니다.
- 패널은 `transform`이 아니라 height를 애니메이션합니다. 글자가 다시 샘플링되지 않고, 열리는 동안 패널 안의 내용이 밀리지도 않습니다.
