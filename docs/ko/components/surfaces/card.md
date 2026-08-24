---
title: PlCard
order: 2
---

# PlCard

<p class="plass-lede">화면의 나머지를 묶어 놓는 시트입니다. 제목, 부제, 본문, 푸터 — 카드를 이루는 부분들이 이미 배치되어 있습니다.</p>

<Demo src="card/hero" :min-height="240" />

```tsx
import { PlButton, PlCard } from 'plass-ui';

<PlCard title="Team plan" subtitle="Billed yearly" footer={<PlButton>Upgrade</PlButton>}>
  Shared projects, audit logs and a seat for anyone you invite.
</PlCard>;
```

## Props

<PropsTable name="PlCard" />

네이티브 `<div>` 속성은 그대로 전달됩니다. `color`와 `title`은 둘 다 여기서는 Plass의 prop이라 제외됩니다.

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### variant

세 가지 재질을 **컨테이너** 입장에서 읽은 것입니다. `solid`는 가장 불투명한 맑은 유리로, 주변보다 앞으로 나와 있어야 하는 판에 씁니다. `glass`는 Plass의 기본 시트이자 기본값입니다. `ghost`는 시트가 아예 없어서, 카드 안의 카드처럼 사각형이 하나 더 늘어나면 안 되는 자리에 씁니다.

셋 중 어느 것에도 색이 들어가지 않습니다. 카드가 담는 내용은 자기 색을 가지고 오는데, 그 아래 시트에 색을 넣으면 모든 내용이 고려된 적 없는 배경 위에 올라앉게 됩니다.

<Demo src="card/variants" :min-height="160">

<<< @/.vitepress/demos/card/variants.tsx

</Demo>

### title · subtitle · headerAction · footer

각 영역이 하위 컴포넌트가 아니라 prop인 이유는 `PlTextField`가 `label`과 `description`을 prop으로 받는 이유와 같습니다. 배치는 고정되어 있고, 호출하는 쪽이 정하고 싶은 것은 각 자리에 무엇을 넣느냐입니다.

비어 있는 자리는 아무것도 그리지 않습니다 — `children`만 있는 카드는 섹션이 셋이 아니라 하나입니다.

<Demo src="card/slots" :min-height="360">

<<< @/.vitepress/demos/card/slots.tsx

</Demo>

### dividers

기본은 꺼져 있고, 섹션은 여백으로 구분됩니다. 켜면 헤어라인으로 나뉘는데, 시트 자기 테두리와 같은 `--plass-glass-line`이라 판에 금을 그은 것처럼 읽힙니다. 선이 양 끝까지 닿아야 하므로 여백이 카드에서 각 섹션으로 옮겨 갑니다.

<Demo src="card/dividers" :min-height="200">

<<< @/.vitepress/demos/card/dividers.tsx

</Demo>

### padded

끄면 시트가 안쪽 여백을 전혀 갖지 않고, 내용이 자기 여백을 가져옵니다 — 네 모서리까지 닿는 배너 이미지, 자기 행을 직접 그리는 표. 내용이 카드의 모서리 반경에 맞춰 잘리도록 `overflow-hidden`과 함께 쓰세요.

<Demo src="card/padded" :min-height="280">

<<< @/.vitepress/demos/card/padded.tsx

</Demo>

### interactive

포인터 아래에서 시트를 들어 올리고 그림자를 한 단계 더합니다. 라이브러리가 `transform`을 허용하는 유일한 자리이고, 이는 규칙의 구멍이 아니라 규칙 그 자체입니다. 움직이면 안 되는 것은 손가락 **아래**에 있는 것이고, 내용을 _담는_ 시트는 다른 종류의 표면입니다.

카드가 보이는 방식만 바꿉니다. 실제로 누를 수 있는 카드라면 `render={<a href="…" />}`나 `render={<button type="button" />}`로 진짜 요소를 주어야 focus가 가고, 이름이 읽히고, 키보드로 닿을 수 있습니다.

<Demo src="card/interactive" :min-height="160">

<<< @/.vitepress/demos/card/interactive.tsx

</Demo>

### size

모서리 반경, 타입 스케일, 안쪽 여백이 함께 움직입니다. 컨트롤과 달리 카드의 `size`는 높이를 정하지 않습니다 — 카드의 높이는 담고 있는 내용이 정합니다.

<Demo src="card/sizes" :min-height="360">

<<< @/.vitepress/demos/card/sizes.tsx

</Demo>

## Accessibility

- role 없는 평범한 `<div>`로 렌더링됩니다. 컨테이너에는 이것이 맞습니다. 마크업이 더 말해야 한다면 `render`로 `<section>`, `<li>`, `<article>`, 링크가 되게 하세요.
- 문자열 `title`은 heading이 아니라 스타일이 적용된 `<div>`입니다. 카드가 문서 개요에 들어가야 하면 `title={<h2>…</h2>}`를 넘기세요. 브라우저 기본 서식 대신 카드의 타이포그래피를 물려받습니다.
- `interactive`는 시각적인 상태일 뿐입니다. role도, `tabIndex`도, 키 처리도 붙지 않습니다 — `<div>`에 `onClick`을 얹는 대신 `render`로 진짜 요소를 주세요.
- focus ring은 `:focus-visible`에서만 그려지고 시트의 테두리를 따라갑니다. 카드가 실제로 focus를 받을 수 있게 된 뒤에만 나타납니다.
