---
title: PlDrawer
order: 7
---

# PlDrawer

<p class="plass-lede">창의 한 가장자리에 붙은 판입니다. 한 컴포넌트에 두 가지가 들어 있는데, 사실 같은 판이기 때문입니다 — 열어서 쓰는 서랍과, 그냥 페이지의 일부인 서랍.</p>

<Demo src="drawer/hero" :flutter="false" :min-height="140" />

::: fw react

```tsx
import { PlButton, PlDrawer, PlDrawerClose } from 'plass-ui';

<PlDrawer side="right" trigger={<PlButton>Filters</PlButton>} title="Filters">
  Everything you can narrow by.
</PlDrawer>;
```

:::

## Props

<PropsTable name="PlDrawer" />

::: fw react

나머지 `<div>` 속성은 모두 판으로 전달됩니다.

:::

라이브러리 전체에서 공유하는 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 두 가지 mode, 하나의 판

둘을 가르는 것은 `mode`이고, 이것은 `variant`와는 별개의 축입니다. `variant`는 이미 라이브러리 전체에서 표면의 무게를 뜻하므로, 여기 쓰면 아무것도 아닌 것에 이름을 두 번 붙이는 셈이 됩니다.

- **`overlay`** — 열리고, 스크림 위에서 페이지 위에 떠 있고, 포커스를 붙잡고, 닫힙니다. 햄버거 뒤의 내비게이션 서랍, 표 옆의 필터 판.
- **`inline`** — 레이아웃의 일부이고 페이지가 그 주위로 배치됩니다. 스크림도, 포커스 트랩도, 닫을 것도 없습니다. 그냥 거기 있는 사이드바.

그 외의 모든 것은 동일합니다. 그래서 사이드바가 브레이크포인트에서 햄버거가 될 때 호출하는 쪽이 컴포넌트를 갈아 끼우지 않아도 되는 것입니다.

`defaultOpen`도 그것을 따릅니다. `overlay`에서는 `false`, `inline`에서는 `true`입니다. 나타나기 전에 열어야 하는 고정 사이드바는 고정 사이드바가 아니기 때문입니다.

<Demo src="drawer/inline" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/drawer/inline.tsx

</Demo>

## variant도 elevation도 없습니다

세 재질은 "이 표면이 페이지에 대해 얼마나 자기를 주장하는가"에 답하는데, **창의 가장자리**를 차지한 판은 이미 답을 했습니다. `overlay` 서랍은 떠 있고 사다리 맨 위의 그림자를 답니다. `inline` 서랍은 레이아웃의 일부라 그림자가 없습니다. 어느 쪽도 선택지로 내놓을 값어치가 없습니다.

## Examples

### side

`PlassSide`가 어디서나 그렇듯 논리적이 아니라 물리적입니다. 창 위쪽을 따라 놓인 서랍은 어떤 쓰기 방향에서도 위쪽에 있습니다.

판은 **창 쪽은 각지고 자유로운 쪽은 깎여** 있습니다. 페이지를 향한 모서리는 하우스 필렛을 받고, 가장자리에 붙은 둘은 받지 않습니다. 보이는 끝이 없는 것에서 깎아 낸 모서리는 아무것도 깎지 않은 것이기 때문입니다. 얇은 선도 같은 규칙을 따라 자유로운 가장자리에만 그려집니다.

`left`나 `right` 판은 `size`가 뜻하는 너비를 가지고, `top`이나 `bottom` 판은 안에 든 것만큼 높되 창의 85%까지입니다 — 세 줄이 든 바텀 시트는 세 줄 높이여야 합니다. `extent`가 어느 쪽이든 덮어씁니다.

<Demo src="drawer/sides" :flutter="false" :min-height="140">

<<< @/.vitepress/demos/drawer/sides.tsx

</Demo>

### 아무것도 미끄러지지 않습니다

판은 페이드만 합니다. 미끄러져 들어오는 서랍은 전환이 이어지는 내내 자기 글자를 화면 위로 끌고 다니는 것이고, 판은 글자와 컨트롤 *뿐*입니다. 그러니 여기는 [무변형 규칙](../../design/design-language)의 예외가 아니라, 그 규칙이 쓰인 이유 그 자체입니다.

판이 가장자리에서 왔다고 말해 주는 것은 그것이 가장자리에 **붙어 있다**는 사실입니다.

### dividers

헤더와 본문과 액션 사이를 여백 대신 얇은 선으로 가릅니다. 본문이 스크롤되기 시작하는 순간부터 켤 만합니다. 헤더가 제자리에 있었다고 말해 주는 것이 그 선입니다.

어느 쪽이든 스크롤되는 것은 본문뿐입니다.

## Accessibility

- `overlay` 서랍은 진짜 dialog입니다. 포커스를 붙잡고, 나갈 때 트리거로 돌려주고, 뒤의 페이지를 접근성 트리에서 빼냅니다. `modal="trap-focus"`는 포커스는 안에 붙잡아 두면서 페이지는 스크롤하고 클릭할 수 있게 남겨 둡니다.
- `title`이 이름을 붙이고 `description`이 설명합니다. 둘 다 그냥 근처에 놓이는 것이 아니라 판에 연결됩니다.
- `inline` 서랍은 dialog가 **아니고** 그 어느 것도 주장하지 않습니다. 레이아웃 속의 판이고, 제목도 평범한 제목입니다.
- `dismissible={false}`는 Escape도 스크림 누름도 거절합니다. 그 둘을 거절하는 서랍에는 그것에 답할 액션을 주세요. 다른 출구가 없습니다.

::: fw react

- 포커스 트랩, 스크롤 잠금, `aria-labelledby` / `aria-describedby` 연결, 뒤 페이지의 inert 처리는 전부 Base UI의 것입니다.
- `PlDrawerClose`는 uncontrolled 서랍의 Cancel 버튼이 부를 것이 있도록 존재합니다. `render`가 그것을 진짜 Plass 버튼으로 만듭니다 — `<PlDrawerClose render={<PlButton variant="ghost">Cancel</PlButton>} />`.

:::
