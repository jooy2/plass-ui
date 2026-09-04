---
title: PlHoverCard
order: 11
---

# PlHoverCard

<p class="plass-lede">링크 뒤에 무엇이 있는지 미리 보여 주는 카드입니다. 포인터가 그 위에 머물면 열립니다. 지나가는 길의 모든 링크에서 튀어나오지 않을 만큼 늦게 열리고, 손이 닿을 수 있을 만큼 천천히 닫힙니다.</p>

<Demo src="hover-card/hero" :min-height="240" />

::: fw react

```tsx
import { PlHoverCard, PlTextLink } from 'plass-ui';

<PlHoverCard
  title="Ada Lovelace"
  description="Mathematician, 1815–1852"
  trigger={<PlTextLink href="/ada">Ada Lovelace</PlTextLink>}
>
  Wrote the first algorithm intended to be carried out by a machine.
</PlHoverCard>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlHoverCard(
  title: const Text('Ada Lovelace'),
  description: const Text('Mathematician, 1815–1852'),
  trigger: PlTextLink(onPressed: open, child: const Text('Ada Lovelace')),
  child: const Text('Wrote the first algorithm intended to be carried out by a machine.'),
);
```

:::

## Props

<PropsTable name="PlHoverCard" />

라이브러리 전체에서 공유 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 어느 떠 있는 표면인가

셋이 있고, 구분하는 것은 **무엇이 여는가와 열린 뒤에 무엇을 할 수 있는가**입니다. 생김새가 아닙니다. 셋 다 같은 시트입니다.

|  | 여는 것 | 열린 뒤 |
| --- | --- | --- |
| [`PlTooltip`](../feedback/tooltip) | 위에 머무르기 | 한 구절뿐이고 안의 어떤 것에도 닿을 수 없습니다 |
| `PlHoverCard` | 위에 머무르기 | 포인터가 안으로 들어갈 수 있고, 제목·그림·수치가 들어갑니다 |
| [`PlPopover`](../feedback/popover) | 누르기 | 닫을 때까지 남고, 입력도 받습니다 |

## 여기에만 있는 것은 없어야 합니다

이 컴포넌트가 맞는 선택인지를 정하는 규칙입니다.

**hover로 열리는 카드는 손가락으로는 열리지 않습니다.** 페이지의 다른 어디에도 없는 링크나 버튼이나 사실은, 터치로 읽는 사람 모두가 놓치는 링크·버튼·사실입니다. 그래서 안에 있는 것은 전부 이미 닿을 수 있는 무언가의 미리 보기입니다. 트리거가 가는 페이지, 자기 화면을 가진 프로필, 아래 표에 다시 나오는 수치.

그래서 애초에 안전하고, 그래서 닫기 버튼도 포커스 가둠도 스크롤 잠금도 필요 없습니다. 끝까지 보지 못해도 잃는 것이 없습니다.

## 지연이 곧 컴포넌트입니다

`delay`는 **600ms**이고 일부러 깁니다. 포인터가 링크를 스치는 순간 열리는 카드는 다른 곳으로 가는 길에 지나치는 모든 링크에서 열립니다. 그러면 글이 있는 페이지가 움찔거리는 페이지가 됩니다.

`closeDelay`는 **300ms**이고 0일 수 없습니다. 트리거와 카드 사이의 틈에는 포인터가 없으므로, 트리거를 벗어나는 순간 닫히는 카드에는 영영 닿을 수 없습니다. 그리고 거기에 닿을 수 있다는 것이 tooltip과의 차이 전부입니다.

<Demo src="hover-card/delays" :min-height="220">

::: fw react

<<< @/.vitepress/demos/hover-card/delays.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/hover_card/delays.dart

:::

</Demo>

링크가 **전부** 미리 보기인 페이지 — 사람 목록, 이슈 목록 — 에서만 `delay`를 줄이고, 나머지에서는 그대로 두십시오.

## 예시

### 사람

흔한 경우이고, 이 컴포넌트가 그려진 모양입니다.

```tsx
<PlHoverCard
  title="Ada Lovelace"
  description="Mathematician"
  trigger={<PlTextLink href="/people/ada">Ada Lovelace</PlTextLink>}
>
  <div className="flex items-center gap-3">
    <PlAvatar name="Ada Lovelace" />
    <p>Wrote the first algorithm intended for a machine.</p>
  </div>
</PlHoverCard>
```

### 링크 아래가 아닌 자리

`side`, `align`과 두 offset은 [popover](../feedback/popover)가 받는 것과 같은 넷이고, 자리가 없으면 반대쪽으로 뒤집힙니다.

```tsx
<PlHoverCard side="right" align="start" arrow trigger={…}>…</PlHoverCard>
```

## 참고

- 트리거는 **감싸는 것이 아니라 그대로 렌더링됩니다.** 링크는 링크로 남아 `href`와 스타일과 tab 순서를 유지하고, 카드는 레이아웃에 상자를 더하지 않습니다.
- 시트는 [popover](../feedback/popover)가 그리는 것과 같은 서리 낀 패널이고, `size` 단계마다 한 칸씩 넓습니다. popover는 컨트롤 옆의 세부 사항이고, 힌트 폭으로 눌린 미리 보기는 아무도 읽지 않습니다.
- `arrow`는 popover와 마찬가지로 기본이 꺼짐입니다. 시트는 흐려진 배경 위의 반투명이고, 자기 상자 밖으로 튀어나온 쐐기는 그 배경을 함께 가져가지 못합니다.

::: fw react

- Base UI의 `PreviewCard`가 앵커링, 창 가장자리에서의 뒤집기, 두 지연, 닫기를 가집니다.

:::

::: fw flutter

- 포인터를 트리거와 카드 양쪽에서 따라가고, 플래그가 하나가 아니라 둘입니다. 그래서 둘 사이의 틈을 건널 수 있습니다.
- 위에 `Overlay`가 필요합니다. navigator가 있는 `WidgetsApp`과 `MaterialApp` 둘 다 제공합니다.

:::

## 접근성

- **hover뿐 아니라 키보드 포커스에서도 열립니다.** 링크가 이어진 문단을 tab으로 지나가는 사람도 포인터와 같은 미리 보기를 받습니다. hover만 받는 카드가 잃는 절반이고, 여기서는 공짜입니다.
- <kbd>Escape</kbd>로 닫힙니다.
- dialog가 아니고 포커스를 가져가지 않습니다. 안에 있는 것은 포인터로 닿을 수 있고, 위의 규칙대로 포인터 **없이도** 닿을 수 있어야 합니다.
- 트리거는 원래 가지고 있던 role을 그대로 유지합니다. 카드를 여는 링크도 여전히 링크이고, 말한 곳으로 갑니다.
