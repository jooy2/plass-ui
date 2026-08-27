---
title: PlPopover
order: 8
---

# PlPopover

<p class="plass-lede">자기를 연 것 옆에 열리는 시트입니다. 툴팁과 달리 닿을 수 있고, 모달과 달리 페이지를 가져가지 않습니다.</p>

<Demo src="popover/hero" :flutter="false" :min-height="140" />

::: fw react

```tsx
import { PlButton, PlPopover } from 'plass-ui';

<PlPopover trigger={<PlButton>How is this worked out?</PlButton>} title="Effective rate">
  Your rate is the base rate plus whatever your plan adds to it.
</PlPopover>;
```

:::

## Props

<PropsTable name="PlPopover" />

::: fw react

나머지 `<div>` 속성은 모두 팝업으로 전달됩니다.

:::

라이브러리 전체에서 공유하는 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 툴팁도 아니고 모달도 아닙니다

떠 있는 표면 셋, 각자 다른 일. 그리고 그 셋을 가르는 것은 그것으로 무엇을 *할 수 있는가*입니다.

- [`PlTooltip`](./tooltip)은 다른 것에 대한 **주석**입니다. hover에 나타나고 벗어나면 사라지며, 그 안의 어떤 것에도 닿을 수 없습니다 — 툴팁 안의 링크는 아무도 클릭할 수 없는 링크입니다.
- **popover**는 닫힐 때까지 떠 있습니다. 포인터로도 키보드로도 들어갈 수 있고, 안의 것을 클릭하고 입력할 수 있습니다.
- [`PlModal`](./modal)은 답할 때까지 페이지를 가져갑니다.

popover는 그 가운데입니다. 컨트롤에 붙어 있고, 뒤의 페이지는 계속 동작합니다. `modal`의 기본이 `false`인 것이 그 말입니다.

## variant도 elevation도 없습니다

세 재질은 "이 표면이 페이지에 대해 얼마나 자기를 주장하는가"에 답하는데, **불려 나와야** 했던 팝업은 이미 답을 했습니다. 그리고 popover는 진짜로 떠 있습니다. elevation 사다리가 존재하는 바로 그 경우이므로, 평평하게 눕힐 수도 있는 선택지로 내놓는 대신 맨 위 칸에 고정되어 있습니다.

## Examples

### side와 align

트리거의 어느 가장자리에 나타날지, 그리고 그 가장자리를 따라 어디에 놓일지입니다. 자리가 없으면 반대편으로 **뒤집힙니다**. 그게 맞는 동작이고, 이 컴포넌트가 직접 쓴 것도 아닙니다.

<Demo src="popover/sides" :flutter="false" :min-height="220">

<<< @/.vitepress/demos/popover/sides.tsx

</Demo>

### arrow

[`PlTooltip`](./tooltip)과 달리 기본은 꺼져 있습니다. 툴팁은 꽉 찬 판이고 그 쐐기도 같은 단색입니다. 이 표면은 흐린 배경 위의 반투명이고, **팝업 자기 상자 밖으로 튀어나온 쐐기는 그 배경을 데리고 나갈 수 없습니다**.

트리거가 충분히 멀어서 팝업이 자기가 누구 것인지 말해야 할 때 켜세요.

### popover는 폼을 담을 수 있습니다

이것이 툴팁이 아닌 이유의 전부입니다. 안의 것이 포커스를 받을 수 있으므로, 이름 바꾸기·필터·기간 선택은 질문 하나를 하려고 페이지를 통째로 가져가는 모달이 아니라 여기에 놓입니다.

<Demo src="popover/form" :flutter="false" :min-height="140">

<<< @/.vitepress/demos/popover/form.tsx

</Demo>

### dismissible

기본은 켜져 있습니다. Escape와 바깥 클릭 둘 다 닫습니다. 자기만의 출구가 있는 팝업에서만 끄고, **그럴 때는 반드시 하나를 주세요** — 닫기 버튼이든, 그것에 답하는 액션이든. 다른 출구가 없습니다.

::: fw react

`dismissible`이 꺼져 있어도 `PlPopoverClose`는 동작합니다. 그것이 거절을 덫으로 만들지 않는 장치입니다.

:::

## Accessibility

- 팝업은 트리거에 붙은 dialog입니다. `title`이 이름을 붙이고, `description`이 설명하며, 나갈 때 포커스는 트리거로 돌아갑니다.
- `modal`이 그렇게 말하지 않는 한 뒤의 페이지를 **가져가지 않습니다**. 페이지를 숨기는 popover는 모양만 더 나쁜 모달입니다.
- Escape와 바깥 클릭은 둘 다 진짜 닫기이고, `dismissible={false}`로 함께 취소됩니다.

::: fw react

- 앵커링, 창 가장자리에서의 뒤집기, 바깥 누름과 Escape 처리, 포커스 복귀, `aria-labelledby` / `aria-describedby` 연결은 전부 Base UI의 것입니다.

:::
