---
title: PlPill
order: 8
---

# PlPill

<p class="plass-lede">살아 있는 정보를 조금 담고 떠 있는 알약입니다. 돌아가고 있는 녹화, 올라가고 있는 업로드, 아직 읽지 않은 알림 두 개.</p>

<Demo src="pill/hero" :flutter="false" :min-height="140" />

::: fw react

```tsx
import { PlPill } from 'plass-ui';

<PlPill color="danger" title="Recording" description="00:41" startIcon={<Dot />} />;
```

:::

## Props

<PropsTable name="PlPill" />

::: fw react

나머지 `<div>` 속성은 모두 껍데기로 전달됩니다.

:::

라이브러리 전체에서 공유하는 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 라이브러리에 하나뿐인 스타디움

모양은 **스타디움**입니다 — 반경이 정확히 행 높이의 절반 — 그리고 하우스 반경 규칙은 원래 그것을 금지합니다. 모든 컨트롤은 알약이 되어 버릴 50%에서 조금 못 미치게 유지되는데, 위아래 가장자리를 따라 남는 평평한 구간이 여전히 "모서리를 깎은 시트"로 읽히게 하는 것이기 때문입니다.

여기가 그 규칙이 겨누고 있던 예외이고, 규칙이 성립하는 것과 같은 이유로 성립합니다. **이것은 페이지 위에 놓인 시트가 아닙니다.** 페이지 위에 떠 있는 물건이고, 페이지 위에 떠 있는 물건이 페이지와 같은 재료에서 잘려 나온 것처럼 보여서는 안 됩니다. 떠 있는 바도 자기 캡슐에 대해 같은 주장을 합니다.

반경은 `rounded-full`이 아니라 **행**에 고정되어 있고, 그 차이는 알약이 자라야 비로소 드러납니다. 두 번째 줄이 생긴 상자에서 높이의 절반짜리 모서리는 모든 줄의 앞 두 단어를 잡아먹습니다. 행에 고정해 두는 것이 알약을 원래 갖고 있던 그 모서리 그대로 둥근 사각형으로 자라게 합니다.

`elevation`의 기본이 `2`인 것도 같은 이유입니다 — 자기가 떠 있는 내용 위에 평평하게 누운 알약은 실수로 읽힙니다.

## Examples

### variant

세 재질을 **컨트롤**의 방식으로 말합니다. 표면이 색을 받습니다. [`PlButton`](../inputs/button)이나 [`PlChip`](../display/chip)과 같습니다 — 알약은 남의 내용을 담은 시트가 아니라, 색이 입혀지는 그 물건 자체이기 때문입니다.

<Demo src="pill/variants" :flutter="false" :min-height="280">

<<< @/.vitepress/demos/pill/variants.tsx

</Demo>

### 세 개의 슬롯

`startIcon`은 원으로 잘린 정사각형 상자입니다. 그래서 글리프만큼이나 이미지도 자연스럽게 들어갑니다 — 상자를 채우고 레터박스 대신 잘리는데, 20px짜리 인물 사진이 원하는 것이 그것입니다.

`title`과 `description`은 **가운데**입니다. 자기 열 안에서 중앙 정렬되고, 양옆 이웃에서 컨트롤 트랙의 약 두 배만큼 떨어져 있습니다. 글리프와 뒤쪽 슬롯은 알약의 가구이고, 알약이 *무엇에 대한 것인지*는 그 사이의 열입니다.

`endIcon`은 누를 수 있는 영역 **바깥**에 있어서 그 자체가 컨트롤일 수 있습니다 — 정지 버튼이나 닫기. 버튼 안의 버튼은 브라우저가 파싱하면서 다시 쓰는 마크업입니다.

### details

`expanded`일 때 드러나는 나머지 절반입니다. 알약은 다른 모양으로 바뀌는 대신 아래로 자랍니다. 한 물건이 더 말하는 것입니다.

높이는 하드코딩이 아니라 **잰 값**입니다 — `ResizeObserver`가 패널을 지켜보므로, 내용이 바뀌는 details 영역(살아 있는 정보가 하는 일이 그것입니다)도 함께 자랍니다. 그리고 아무것도 변형되지 않습니다. [`PlCollapsible`](./collapsible)의 패널이 그렇듯, 알약은 열리는 창입니다.

<Demo src="pill/details" :flutter="false" :min-height="220">

<<< @/.vitepress/demos/pill/details.tsx

</Demo>

### size

접힌 알약은 같은 `size`의 [`PlButton`](../inputs/button)과 나란히 놓았을 때 줄이 맞습니다 — 행의 바닥이 컨트롤 사다리입니다. 높이가 아니라 **최솟값**인데, description을 단 알약은 두 줄 높이이고 고정 높이였다면 두 번째 줄이 잘렸을 것이기 때문입니다.

<Demo src="pill/sizes" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/pill/sizes.tsx

</Demo>

### position

`static`은 흐름 안에 둡니다. `sticky`는 페이지가 거기까지 스크롤되면 가장자리에 붙잡아 둡니다. `fixed`는 뷰포트에 고정하고 가운데 놓는데, 이 모양이 존재하는 이유가 그 배치입니다.

가운데 놓기는 자기 너비의 절반만큼 translate하는 것이 아니라 전폭 상자 안의 `mx-auto`입니다. [표면을 변형하지 않는다는 규칙](../../design/design-language)이 여기서도 지켜지고, `auto` 마진은 방향에 무관하므로 RTL에서도 알약은 가운데 있습니다.

::: fw react

```tsx
<PlPill position="fixed" side="bottom" title="Recording" />
```

:::

## Accessibility

- `onClick`이 없는 알약은 컨트롤이 아니고 아무것도 주장하지 않습니다. 주면 가운데가 진짜 `<button>`이 되어 키보드로 닿을 수 있고 그것으로 안내됩니다.
- `endIcon`은 그 버튼 바깥에 있으므로 거기 놓인 컨트롤은 자기 focus stop을 가집니다.
- 접힌 `details` 패널은 `aria-hidden`만이 아니라 **`inert`**입니다. 높이 0인 상자 안에서도 내용은 여전히 완벽하게 포커스를 받고, `aria-hidden`만 있었다면 스크린 리더가 없다고 들은 자리로 키보드 독자가 탭해 들어갔을 것입니다.
