---
title: PlScrollZone
order: 5
---

# PlScrollZone

<p class="plass-lede">무엇이든 한 방향으로 늘어놓고 그 방향으로 스크롤하는 띠입니다. 카드든 칩이든 아바타든 썸네일이든 상자를 가로질러 혹은 아래로 흐르고, 줄 수는 원하는 만큼 지정할 수 있으며, 휠도 손가락도 없는 포인터를 위한 버튼 한 쌍이 붙습니다.</p>

<Demo src="scroll-zone/hero" :min-height="240" />

::: fw react

```tsx
import { PlCard, PlScrollZone } from 'plass-ui';

<PlScrollZone label="Continue watching" spacing={3}>
  {shows.map((show) => (
    <PlCard key={show.name} className="w-40" title={show.name} />
  ))}
</PlScrollZone>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlScrollZone(
  label: 'Continue watching',
  spacing: 12,
  children: <Widget>[
    for (final Show show in shows)
      SizedBox(width: 160, child: PlCard(title: Text(show.name))),
  ],
);
```

:::

## Props

<PropsTable name="PlScrollZone" />

::: fw react

나머지 `<div>` 속성은 모두 루트로 전달됩니다.

:::

라이브러리 전체에서 공유하는 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 무엇으로 만들어져 있는가

메커니즘은 **평범한 스크롤 컨테이너**이고, 이 컴포넌트가 제공하는 전부는 그것을 움직이는 방법입니다. 스와이프, 트랙패드의 두 손가락 드래그, 휠, 스크롤바는 전부 플랫폼 자신의 것이고 가로채지 않습니다. 그 위에 더한 것은 휠도 손가락도 없는 포인터를 위한 버튼 한 쌍과, 페이지를 넘기는 것이 아니라 잡아당기는 것으로 읽히는 띠를 위한 마우스 드래그뿐입니다.

아무것도 변형되지 않습니다. `translate`로 옮기는 트랙이었다면 [하우스 규칙](../../design/design-language)의 예외를 주장해야 했겠지만 스크롤 오프셋은 그럴 필요가 없습니다. 그리고 그 덕분에 따로 말해 주지 않아도 RTL에서 띠가 반대 방향으로 흐르고, 스크롤바가 정직해집니다.

시트는 **그리지 않습니다**. 그리게 할 `elevation`도 없습니다. 선반은 자식을 늘어놓는 방법이고, 자식들은 자기 표면을 가지고 옵니다. `variant`·`size`·`color`는 진짜 [`PlIconButton`](../inputs/icon-button)인 두 버튼까지만 닿습니다.

## Examples

### orientation과 lines

`orientation`은 띠가 어느 방향으로 흐를지, 따라서 어느 방향으로 스크롤할지를 정합니다. `lines`는 가로 방향 zone이 새 열을 시작하기 전에 채우는 행의 수입니다 — 두 줄이면 같은 너비에 두 배가 들어가고, 스크롤은 여전히 하나입니다.

`spacing`은 자식 사이의 간격입니다.

::: fw react

[`PlGrid`](./grid)의 `spacing`과 같은 사다리를 씁니다. `2`는 `0.5rem`입니다.

:::

::: fw flutter

논리 픽셀 단위의 길이입니다. Dart에는 `rem`이 없고, 이 패키지의 다른 모든 치수도 이미 저쪽이 `rem`으로 쓰는 것과 같은 숫자입니다.

:::

<Demo src="scroll-zone/lines" :min-height="240">

::: fw react

<<< @/.vitepress/demos/scroll-zone/lines.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scroll_zone/lines.dart

:::

</Demo>

### buttons와 snap

기본값 `auto`는 갈 곳이 있는 버튼만 그리고, 전부 들어맞을 때는 둘 다 그리지 않습니다. 아무것도 할 수 없는 컨트롤은 컨트롤이 없는 것보다 나쁘고, 넘치지 않는 줄은 스크롤러가 아닙니다. `always`는 첫 페인트부터 둘 다 그리고 움직일 수 없는 쪽을 disabled로 둡니다. 내용이 나중에 도착하는 띠가 원하는 것이 그것입니다. `none`은 둘 다 그리지 않고 띠를 휠과 방향키와 드래그에 맡깁니다.

`snap`은 어떻게 스크롤했든 스크롤이 멈출 때마다 가장 가까운 자식을 앞쪽 가장자리로 데려옵니다.

<Demo src="scroll-zone/buttons" :min-height="300">

::: fw react

<<< @/.vitepress/demos/scroll-zone/buttons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scroll_zone/buttons.dart

:::

</Demo>

### buttonPlacement

기본값 `overlay`는 버튼을 띠의 양 끝 위에 얹습니다. 상자의 모든 픽셀을 내용에 남겨 두고 항목이 버튼 아래로 지나가게 합니다. `inline`은 버튼을 띠 옆에 둡니다. 스크롤러가 버튼이 시작하는 자리에서 끝나므로 항목은 버튼 밑으로 미끄러지는 대신 그 가장자리에서 **잘리고**, 버튼은 무엇이 됐든 그 위에 얹힌 것이 아니라 페이지 위에서 읽힙니다.

inline 버튼은 갈 곳이 없을 때도 자기 자리를 지킵니다. 자리가 나타났다 사라지면 방금 끝에 다다른 포인터 아래에서 띠의 크기가 바뀌기 때문입니다.

<Demo src="scroll-zone/placement" :min-height="300">

::: fw react

<<< @/.vitepress/demos/scroll-zone/placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scroll_zone/placement.dart

:::

</Demo>

### mode

버튼을 누르면 무슨 일이 일어나는지입니다. `item`은 다음 자식으로 이동하고 `step`이 한 번에 몇 개인지를 말합니다. `page`는 지금 화면에 보이는 만큼 이동합니다. `hold`는 버튼을 누르고 있는 동안 초당 `speed` 픽셀로 스크롤합니다.

hold라기에 너무 짧은 누름은 대신 한 항목을 이동시킵니다. 빠르게 톡 치는 것이 죽은 누름이 되는 일은 없습니다.

::: fw react

```tsx
<PlScrollZone mode="hold" speed={1200} buttons="always">
  {items}
</PlScrollZone>
```

:::

::: fw flutter

```dart
PlScrollZone(
  mode: PlScrollZoneMode.hold,
  speed: 1200,
  buttons: PlScrollZoneButtons.always,
  children: items,
);
```

:::

한 항목의 크기는 가정하지 않고 **잽니다**. scroll zone의 자식은 호출하는 쪽이 넣은 무엇이든이므로, 두 자식이 반드시 같은 너비라는 보장이 없습니다. 그 측정이 `lines`가 동작하는 이유이기도 합니다 — 둘씩 쌓인 자식 넷은 두 열이고, 한 번 누르면 반 열이 아니라 한 열이 움직여야 합니다.

### drag

손가락은 이미 띠를 스크롤합니다. 메커니즘이 평범한 스크롤 컨테이너이고 터치 스크롤은 플랫폼 자신의 것이기 때문입니다 — 관성도, 고무줄 효과도, 어떤 핸들러도 재현하지 못하는 스크롤바까지 함께 옵니다. `drag`는 같은 제스처를 마우스에도 더해 줍니다.

::: fw react

```tsx
<PlScrollZone drag={false} scrollbar>
  {items}
</PlScrollZone>
```

진짜 드래그 뒤에 따라오는 클릭은 삼켜집니다. 카드를 지나 띠를 잡아당겼다고 그 카드가 열리는 일은 없습니다.

:::

::: fw flutter

```dart
PlScrollZone(drag: false, scrollbar: true, children: items);
```

Flutter는 기본적으로 `dragDevices`에서 마우스를 빼 둡니다. 브라우저의 스크롤 컨테이너가 내리는 것과 같은 판단이고, 여기서 뒤집는 것도 같은 판단입니다 — 마우스로 선반을 끄는 것은 따로 요청해야 할 만큼 흔치 않은 일이고, 선반은 바로 그 요청을 하는 자리입니다.

:::

## Accessibility

- `label`은 영역에 이름을 붙이고, 스크린 리더가 내용보다 먼저 읽는 것이 그것입니다. 이름이 없으면 띠에는 이름이 전혀 없습니다.
- 스크롤 버튼은 진짜 이름을 가진 진짜 버튼이고, 그 이름은 `previousLabel`과 `nextLabel`이 정합니다. 셰브런 하나가 든 원반에는 접근 가능한 이름이 전혀 없고, 그것이 [`PlIconButton`](../inputs/icon-button)의 `label`이 불가능하게 만들려는 결함입니다.
- 띠 안의 어떤 것도 화면 밖에 있다고 숨겨지지 않습니다. 스크롤로 진짜 닿을 수 있는 것들이고, 숨기는 것은 키보드 독자가 빠질 거짓말입니다.

::: fw react

- 띠는 포커스를 받고 방향키로 스크롤됩니다. 스크롤 컨테이너에 대한 브라우저 자신의 키 처리라서 RTL에서도 이미 올바릅니다.
- `hold` 모드에서 버튼은 누름과 똑같이 <kbd>Enter</kbd>와 <kbd>Space</kbd>에 반응해 키를 누르고 있는 동안 스크롤합니다. 포인터는 쓸 수 있고 키보드는 쓸 수 없는 스크롤 수단은 이것이 절대 되어서는 안 되는 하나입니다.

:::

::: fw flutter

- `hold` 모드에서 키 누름은 한 항목을 움직이고 그다음은 플랫폼 자신의 키 반복이 이어받습니다. 누르고 있는 포인터가 받는 프레임 루프와는 다릅니다. 어느 쪽이든 버튼에 키보드로 닿을 수 있고, 중요한 것은 그것입니다.

:::

::: fw flutter

## React 빌드와의 차이

| React | Flutter | 이유 |
| --- | --- | --- |
| JSX로 쓰는 `children` | `children: List<Widget>` | 패키지의 나머지가 쓰는 관용구입니다. |
| spacing 사다리 위의 `spacing` | 논리 픽셀 단위의 `spacing` | `rem`이 없습니다. 숫자는 어느 쪽이든 같습니다. |
| `grid-template-rows`를 쓰는 CSS grid | 열들의 행 | `lines`는 고정된 행 수와 필요한 만큼의 열이고, 저쪽에서 `grid-auto-flow: column`이 말하는 것이 그것입니다. 하나는 넘어오지 않습니다 — CSS grid는 모든 열에 같은 행 높이를 주지만, 열들의 행은 그러지 않습니다. |
| — | `controller` | Flutter는 `ScrollController`로 스크롤 뷰를 움직이고, 오프셋이 필요한 호출자에게는 그것을 가진 객체를 건네야 합니다. |
| 포인터로 누른 프레임 루프 **와** 키로 누른 프레임 루프 | 포인터로 누른 프레임 루프 | 여기서는 키가 스스로 반복하고, 반복 하나당 한 항목이 그 결과입니다. |
| `density` | — | 버튼은 `PlIconButton`이고 Flutter 쪽에는 `density`가 없습니다. |
| `className`, `style` | — | 전달할 class 목록도 style 속성도 없습니다. |

:::
