---
title: PlShow
order: 9
---

# PlShow

<p class="plass-lede">어떤 너비에서는 보이고 어떤 너비에서는 보이지 않는 내용입니다. CSS에서 결정하므로 서버가 보내는 첫 페인트가 이미 맞는 쪽이고, 상자가 아니므로 놓인 레이아웃을 아무것도 바꾸지 않습니다.</p>

<Demo src="show/hero" :min-height="140" />

::: fw react

```tsx
import { PlShow } from 'plass-ui';

<PlShow from="md">
  <PlTable columns={columns} rows={rows} />
</PlShow>

<PlShow until="md">
  <PlList>…</PlList>
</PlShow>
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlShow(from: PlassBreakpointFloor.md, child: PlTable<Row>(columns: columns, rows: rows));
PlShow(until: PlassBreakpointFloor.md, child: PlList(children: rows));
```

:::

## Props

<PropsTable name="PlShow" />

`until`은 **미포함**이고, 그래야만 합니다. 그래야 한 요소의 `until="md"`와 다른 요소의 `from="md"`가 한 결정의 두 쪽이 되어, 둘 다 그려지는 너비도 둘 다 그려지지 않는 너비도 없습니다.

`xs`는 없습니다. 모든 것이 맨 아래 칸 이상에 있으므로 `from="xs"`는 "언제나"라는 뜻이 되는데 그것은 prop을 빼면 이미 되는 일이고, `until="xs"`는 "결코"라는 뜻이 됩니다.

## 미디어 쿼리와의 차이

::: fw react

`useMediaQuery`와 삼항 연산자는 같은 것처럼 보이지만 같지 않습니다. **JavaScript에서 답한 미디어 쿼리는 서버에서, 그리고 브라우저가 그리는 첫 프레임에서 `false`입니다.** 그래서 JavaScript로 만든 게이트는 반응형 레이아웃의 틀린 쪽을 그렸다가 버립니다. 예외적인 경우가 아니라 페이지를 열 때마다 생기는 깜빡임입니다. 스타일시트는 React에게 아무것도 묻기 전에 이미 너비를 알고 있습니다.

`plass-ui/styles.css`를 가져오고 자체 Tailwind가 없는 프로젝트에서는 이것이 유일한 방법이기도 합니다. 거기에는 손을 뻗을 `md:hidden`이 없습니다.

:::

::: fw flutter

`MediaQuery.sizeOf`는 첫 프레임부터 이미 정확하므로 게이트는 평범한 조건문입니다. 직접 조건문을 쓰는 것보다 얻는 것은 사다리입니다. 같은 다섯 이름, 같은 너비, 그리고 패키지의 다른 모든 것과 같은 미포함 `until`.

:::

## 레이아웃에 요소를 더하지 않음

::: fw react

보이는 동안 `PlShow`는 `display: contents`입니다. 자식들은 이것이 없었을 때와 정확히 똑같이 주변 레이아웃에 참여합니다. flex 줄 안의 게이트는 flex item이 되지 않고, 그리드 안의 게이트는 칸이 되지 않습니다.

그 말은 **margin이나 width를 실은 `className`이 여기서는 아무 일도 하지 않는다**는 뜻이기도 합니다. 그것이 앉을 상자가 없습니다. 자기 요소를 안에 넣으세요.

:::

## 비용

::: fw react

**양쪽 모두 문서 안에 있습니다.** 숨기는 것은 `display: none`이고, 이는 해당 서브트리를 접근성 트리와 레이아웃에서 빼내므로 두 번 읽히지도 그려지지도 않습니다. 다만 둘 다 렌더링되었고 둘 다 전송되었습니다.

같은 내용의 두 가지 배치에는 맞는 거래이고, 만드는 데 비용이 크거나 fetch를 하거나 아예 mount되면 안 되는 서브트리에는 틀린 거래입니다. 그런 경우에는 [`usePlBreakpointValue`](../../hooks/use-breakpoint)가 하나만 고르고 그 하나만 mount됩니다 — 서버가 `xs` 답을 렌더링하는 비용을 치르고서요.

:::

::: fw flutter

게이트가 닫힌 너비에서는 아무것도 빌드되지 않으므로, 비용이 큰 서브트리도 숨겨져 있는 동안에는 공짜입니다. 그 반대편에 있는 것이 상태입니다. 창이 경계를 넘을 때 버려지는 서브트리는 들고 있던 것을 전부 잃습니다. 그 상태는 게이트 위로 올리세요.

:::

<Demo src="show/layout" :min-height="320">

::: fw react

<<< @/.vitepress/demos/show/layout.tsx

:::

</Demo>

## Accessibility

::: fw react

- 숨겨진 쪽은 `display: none`이고, 이것이 접근성 트리와 tab 순서에서 그것을 빼내는 장치입니다. 내용을 화면 밖으로 옮기기만 하는 게이트였다면 스크린 리더가 같은 것의 두 가지 배치를 모두 읽게 됩니다.
- 게이트 자체에는 role도 label도 없습니다. 레이아웃에게도 접근성 트리에게도 이것은 요소가 아닙니다.

:::

::: fw flutter

- 숨겨진 쪽은 빌드되지 않으므로 semantics 트리에도 없고 focus할 것도 없습니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 왜 |
| --- | --- | --- |
| 양쪽 다 렌더링하고 한쪽을 `display: none` | 열린 쪽만 빌드 | 여기에는 `display: contents`도, 값싼 숨은 서브트리도 없습니다. 양쪽으로 작용합니다. 비용이 큰 서브트리는 닫혀 있는 동안 공짜이고, 창이 경계를 넘으면 그 상태를 잃습니다. |
| `'sm' \| 'md' \| 'lg' \| 'xl'`인 `from` / `until` | `PlassBreakpointFloor` | 같은 네 칸을 enum으로. |
| `className`, `style` | — | 통과시킬 class 목록도 style 속성도 없습니다. |

:::
