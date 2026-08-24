---
title: PlOverlay
order: 3
---

# PlOverlay

<p class="plass-lede">페이지 전체를 덮어 쓸 수 없게 만드는 판입니다. scrim 하나와, 그 위에 호출하는 쪽이 올려놓는 것 — 대개는 spinner와 무엇을 기다리는지 적은 한 줄입니다.</p>

<Demo src="overlay/hero" :min-height="120" />

```tsx
import { PlOverlay } from 'plass-ui';

<PlOverlay open={saving} label="Saving your changes">
  <Spinner />
</PlOverlay>;
```

## Props

<PropsTable name="PlOverlay" />

네이티브 `<div>` 속성은 popup에 그대로 전달됩니다. `color`와 `children`은 둘 다 여기서는 Plass의 prop이라 전달 대상에서 제외됩니다.

`variant`는 없습니다 — 세 가지 재질은 "이 표면이 페이지에 대해 얼마나 자기를 주장하는가"에 답하는데, 오버레이는 이미 페이지를 가져갔습니다. 실제로 답해야 하는 질문은 `tone`입니다. `elevation`도 없습니다. 오버레이는 나머지 전부가 그 위에 떠 있는 **평면 자체**이고, 그림자를 드리우는 scrim은 가장자리가 있는 scrim입니다.

라이브러리 전체에서 공유 축(`size` `color` `align`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### tone

네 단계는 하나의 축입니다 — 뒤에 있는 것이 얼마나 읽히는가. 알파만큼이나 흐림 반경으로 조율되어 있는데, 16px쯤을 넘기면 배경이 평평한 색으로 뭉개져서 알파를 아무리 낮춰도 scrim이 불투명하게 읽히기 때문입니다.

`scrim`은 `PlModal`의 뒤판과 정확히 같습니다. 같아야만 합니다. 그러지 않으면 오버레이 위에 열린 모달에서 이음매가 보입니다.

`clear`는 아무것도 그리지 않으면서 화면을 덮습니다. 그것이 이 값을 고르는 이유 전부입니다 — 클릭을 받아 내는 보이지 않는 판.

<Demo src="overlay/tones" :min-height="180">

<<< @/.vitepress/demos/overlay/tones.tsx

</Demo>

### dismissible

기본은 꺼짐이고, 이것은 `PlModal`과 반대이며 여기서 두 번 읽어 볼 만한 유일한 prop입니다. 모달은 질문을 하고 Escape는 보편적인 "아니오"입니다. 오버레이는 아무것도 묻지 않고 *기다리라*고 말하고 있으며, 스쳐 지나간 클릭 하나로 사라지는 저장은 사용자가 끝났다고 생각하게 될 저장입니다.

무언가의 바깥 클릭을 받아 내는 것이 일인 오버레이에서 켜세요.

<Demo src="overlay/dismissible" :min-height="120">

<<< @/.vitepress/demos/overlay/dismissible.tsx

</Demo>

### align

<Demo src="overlay/align" :min-height="120">

<<< @/.vitepress/demos/overlay/align.tsx

</Demo>

## Accessibility

- 어려운 부분은 Base UI의 Dialog가 가집니다. portal, 스크롤 잠금, 안에 붙들린 focus, 뒤 페이지가 inert가 되는 것, 그리고 닫힐 때 focus가 원래 있던 곳으로 돌아가는 것.
- `label`을 비워 두지 않고 기본값을 둔 이유는, 읽을 것이 아무것도 없는 오버레이 — 맨 spinner, `clear` 판 — 도 자기가 무엇인지는 말해야 하기 때문입니다.
- `modal="trap-focus"`는 스크롤과 클릭은 남기고 focus만 안에 붙듭니다. `clear` 오버레이가 대개 원하는 것이 그것입니다.
- 오버레이는 불투명도만 애니메이션합니다. 확대되거나 미끄러지는 오버레이는 그 위에 적힌 것을 화면 너머로 끌고 다니게 되는데, 컨트롤과 달리 이쪽은 대개 문장을 싣고 있습니다.
- 답해야 할 질문이 있으면 `PlModal`을 쓰세요. 오버레이에는 제목도, 설명도, 액션도 없어서 스크린리더가 `label` 말고는 다룰 것이 없습니다.
