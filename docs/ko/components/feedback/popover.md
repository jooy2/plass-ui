---
title: PlPopover
order: 8
---

# PlPopover

<p class="plass-lede">자기를 연 것 옆에 열리는 시트입니다. 툴팁과 달리 닿을 수 있고, 모달과 달리 페이지를 가져가지 않습니다.</p>

<Demo src="popover/hero" :min-height="140" />

::: fw react

```tsx
import { PlButton, PlPopover } from 'plass-ui';

<PlPopover trigger={<PlButton>How is this worked out?</PlButton>} title="Effective rate">
  Your rate is the base rate plus whatever your plan adds to it.
</PlPopover>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlPopover(
  open: explaining,
  onOpenChanged: (bool next) => setState(() => explaining = next),
  title: const Text('Effective rate'),
  trigger: PlButton(
    onPressed: () => setState(() => explaining = true),
    child: const Text('How is this worked out?'),
  ),
  child: const Text('The base rate plus whatever your plan adds to it.'),
);
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

트리거의 어느 가장자리에 나타날지, 그리고 그 가장자리를 따라 어디에 놓일지입니다. 자리가 없으면 반대편으로 **뒤집히고**, 자기가 놓인 가장자리를 따라 _미끄러지지는_ 않습니다 — 그것이 화살표가 자기가 속한 것을 계속 가리키게 하는 장치입니다.

<Demo src="popover/sides" :min-height="220">

::: fw react

<<< @/.vitepress/demos/popover/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/popover/sides.dart

:::

</Demo>

### arrow

[`PlTooltip`](./tooltip)과 달리 기본은 꺼져 있습니다. 툴팁은 꽉 찬 판이고 그 쐐기도 같은 단색입니다. 이 표면은 흐린 배경 위의 반투명이고, **팝업 자기 상자 밖으로 튀어나온 쐐기는 그 배경을 데리고 나갈 수 없습니다**.

트리거가 충분히 멀어서 팝업이 자기가 누구 것인지 말해야 할 때 켜세요.

### popover는 폼을 담을 수 있습니다

이것이 툴팁이 아닌 이유의 전부입니다. 안의 것이 포커스를 받을 수 있으므로, 이름 바꾸기·필터·기간 선택은 질문 하나를 하려고 페이지를 통째로 가져가는 모달이 아니라 여기에 놓입니다.

<Demo src="popover/form" :min-height="140">

::: fw react

<<< @/.vitepress/demos/popover/form.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/popover/form.dart

:::

</Demo>

### dismissible

기본은 켜져 있습니다. 바깥을 누르면 닫힙니다. 자기만의 출구가 있는 팝업에서만 끄고, **그럴 때는 반드시 하나를 주세요** — 닫기 버튼이든, 그것에 답하는 액션이든. 다른 출구가 없습니다.

::: fw react

Escape로도 닫히고, `dismissible={false}`가 둘 다 취소합니다. 꺼져 있어도 `PlPopoverClose`는 동작하는데, 그것이 거절을 덫으로 만들지 않는 장치입니다.

:::

::: fw flutter

꺼져 있어도 `showClose`와 그 안의 액션은 동작하는데, 그것이 거절을 덫으로 만들지 않는 장치입니다.

:::

## Accessibility

- `title`이 팝업의 이름이고 heading으로 안내됩니다. `description`은 그 아래에 놓입니다.
- 뒤의 화면을 **가져가지 않습니다**. 화면을 숨기는 popover는 모양만 더 나쁜 모달입니다.
- 바깥 누름은 진짜 닫기이고, `dismissible`로 거절할 수 있습니다.

::: fw react

- 팝업은 트리거에 붙은 dialog이고, 나갈 때 포커스는 트리거로 돌아갑니다. 앵커링, 창 가장자리에서의 뒤집기, 바깥 누름과 Escape 처리, 포커스 복귀, `aria-labelledby` / `aria-describedby` 연결은 전부 Base UI의 것입니다.
- `modal="trap-focus"`는 페이지 스크롤을 잠그지 않으면서 포커스만 안에 붙잡아 둡니다.

:::

::: fw flutter

- 들어 올리기, 앵커링, 뒤집기, 바깥 누름은 전부 `PlassAnchoredPortal`의 것입니다. `PlTooltip`과 `PlSelect`의 목록이 서 있는 것과 같은 층이라, 셋 다 같은 이유로 스크롤 중에도 자기 앵커에 붙어 있습니다.

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `open` / `defaultOpen` / `onOpenChange` | `open` / `onOpenChanged` | Flutter의 컨트롤은 controlled이고, 이 패키지의 상태 있는 위젯도 전부 그렇습니다. |
| 선택적인 `trigger` | 필수인 `trigger` | 브라우저는 앵커 없이도 팝업을 뷰포트에 대해 배치할 수 있지만, `LayerLink`는 앵커가 없으면 따라갈 것이 없습니다. |
| `modal` | — | 잠글 페이지 스크롤도, 만들 inert 트리도 없습니다. popover가 답해야 할 것은 바깥 누름 하나입니다. |
| `alignOffset` | — | 앵커링이 뒤집기이지 미끄러짐이 아니므로, 가장자리를 따라 밀 거리가 없습니다. |
| `PlPopoverClose` | — | 저쪽에서는 _uncontrolled_ popover의 버튼이 부를 것이 필요해서 있습니다. 여기서는 모든 popover가 controlled입니다. |
| `width: number \| string` | `width: double` | 픽셀은 픽셀 그대로입니다. 받을 CSS 길이가 없습니다. |
| `className`, `style` | — | 전달할 class 목록도 style 속성도 없습니다. |

:::
