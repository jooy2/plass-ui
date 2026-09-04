---
title: PlStack
order: 7
---

# PlStack

<p class="plass-lede">겹쳐 쌓인 것들입니다 — 얼굴이든 카드든 썸네일이든, 넘긴 것이 무엇이든. 상자는 그린 것을 정확히 재므로, 더미가 문장 안이나 표 칸 안에 앉아도 자기 크기에 대해 거짓말하지 않습니다.</p>

<Demo src="stack/hero" :min-height="140" />

::: fw react

```tsx
import { PlAvatar, PlStack } from 'plass-ui';

<PlStack ring max={4} total={11} overflow={(hidden) => <PlAvatar initials={`+${hidden}`} />}>
  <PlAvatar name="Ada Lovelace" src="/ada.jpg" />
  <PlAvatar name="Grace Hopper" />
</PlStack>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlStack(
  max: 4,
  total: 11,
  ring: BorderRadius.circular(999),
  overflow: (int hidden) => PlAvatar(initials: '+$hidden'),
  children: const <Widget>[
    PlAvatar(name: 'Ada Lovelace'),
    PlAvatar(name: 'Grace Hopper'),
  ],
);
```

:::

## Props

<PropsTable name="PlStack" />

::: fw react

네이티브 `<div>` 속성은 `aria-label`을 포함해 그대로 통과합니다. 얼굴이 늘어선 줄은 어떤 집합의 그림이고, 그것이 무엇의 집합인지는 보통 옆에 있는 문장입니다.

:::

::: fw flutter

`semanticLabel`이 더미에 이름을 주고, 항목들은 그 아래에서 자기 semantics 노드를 그대로 유지합니다. 그래서 이름이 붙은 더미는 이름으로 먼저 읽히고 그다음에 안에 있는 것들로 읽힙니다.

:::

`size`는 기본 `overlap`이 사다리의 어느 칸에서 나오는지만 고르고 **그 외에는 아무것도 정하지 않습니다**. 더미는 자기 표면도 없고 안에 글자도 없으므로 정할 높이도 칠할 잉크도 없습니다. 항목들은 원래 그것들이던 그대로입니다.

## 오프셋이 아니라 레이아웃입니다

이 컴포넌트 전체가 딛고 선 결정이고, 틀리기 쉬운 바로 그 지점입니다.

겹쳐 쌓기는 각 항목을 앞의 것 위로 translate하는 방식으로 만들고 싶어집니다. 그렇게 하면 더미는 **항목 하나 너비로 배치됩니다**. 자기 상자 바깥에 그려지고, 페이지에서 그 뒤에 오는 모든 요소가 독자가 결코 보지 못하는 크기를 기준으로 놓입니다. 문단 안에도, 표 칸 안에도, 라벨 옆 flex 줄 안에도 무언가를 밀어내지 않고는 들어갈 수 없습니다.

그래서 겹침은 진짜 레이아웃입니다. React에서는 negative margin이고, Flutter에서는 자체 render object입니다 — 그쪽은 `EdgeInsets`도 `Flex.spacing`도 음수가 아님을 assert하기 때문입니다. 32px 항목 다섯 개에 overlap 10px이면 정확히 이렇게 잽니다.

| direction    | 상자     |
| ------------ | -------- |
| `horizontal` | 120 × 32 |
| `vertical`   | 32 × 120 |
| `diagonal`   | 120 × 72 |

마지막 줄이 두 번 읽을 값어치가 있습니다. **flow는 자기가 흐르는 축에서만 겹칩니다.** 그래서 `diagonal`은 `horizontal`처럼 가로로 흐르고, 세로 방향은 항목마다 한 칸씩 따로 내려갑니다. 줄 안에서 고정된 오프셋 하나를 주면 모든 항목이 같은 높이에 놓이고 부채꼴은 그냥 줄이 됩니다.

그리고 이것이 `diagonal`이 진짜 45°가 아니라 **부채꼴**인 이유이기도 합니다. 가로 전진량은 `항목 너비 − overlap`인데, 임의의 자식을 받는 컴포넌트는 그 너비를 알지 못합니다. `drop`이 세로 걸음이고, 둘은 의도적으로 독립입니다.

<Demo src="stack/directions" :min-height="220">

::: fw react

<<< @/.vitepress/demos/stack/directions.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/stack/directions.dart

:::

</Demo>

**`direction`은 반응형입니다.** 그래서 더미가 노트북에서는 가로로, 폰에서는 세로로 갈 수 있습니다. <Fw react="CSS가 아니라 JavaScript에서 풀립니다. 각 항목이 어느 축의 margin을 받고 drop이 어느 축에 곱해지는지를 정하는데, 그것은 슬롯 하나가 실어 나를 수 있는 값이 아니라 서로 다른 선언들입니다. 서버는 xs 항목을 렌더링하고, 맨값은 아무것도 구독하지 않습니다." flutter="build에서 창의 너비를 상대로 풀리므로 첫 프레임부터 정확합니다." /> [브레이크포인트](../../design/breakpoints) 참고.

## Examples

### max, total, overflow

`max`는 몇 개를 그릴지, `total`은 실제로 몇 개인지입니다. 앞의 몇 개만 넘겼을 때를 위한 것입니다. `overflow`는 그 차이를 받아 마지막 항목을 그립니다.

노드가 아니라 **함수**인 것이 핵심입니다. 그 숫자가 곧 항목이기 때문입니다. 노드였다면 스스로 알아낼 방법이 없는 개수를 받아야 하고, 목록이 바뀔 때마다 틀리게 됩니다.

<Demo src="stack/overflow" :min-height="220">

::: fw react

<<< @/.vitepress/demos/stack/overflow.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/stack/overflow.dart

:::

</Demo>

### front, scaleStep, opacityStep

`front`는 목록의 어느 쪽 끝이 맨 위인지 말합니다. `last`는 DOM이 스스로 하는 답이고 얼굴이 늘어선 줄이 원하는 것입니다 — 가장 최근에 온 사람이 앞에 있습니다. `first`는 카드 덱입니다. 맨 위 카드가 먼저 읽는 카드입니다.

`scaleStep`과 `opacityStep`은 **앞에 있는 쪽에서부터 멀어지며** 곱해집니다. 그래서 맨 앞 항목은 언제나 온전한 크기이고, `front`를 뒤집었다고 이쪽까지 뒤집을 필요가 없습니다. 그리는 시점에 적용되므로 뒤로 물러난 항목도 원래 차지하던 자리를 그대로 차지하고, 걸음 간격이 고르게 유지됩니다.

<Demo src="stack/deck" :min-height="260">

::: fw react

<<< @/.vitepress/demos/stack/deck.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/stack/deck.dart

:::

</Demo>

### ring

비슷한 톤의 두 도형을 겹쳐 놓으면 그 사이에 경계가 전혀 없어서 더미가 하나의 뭉개진 형태로 읽힙니다. 이 실선은 페이지 자신의 표면색이라, 무언가를 둘러싼 선이 아니라 가까운 항목이 오려내진 *구멍*으로 읽힙니다. 반투명한 선은 도움이 되지 않습니다. 그 뒤에 있는 것이 다른 항목이기 때문입니다.

::: fw react

**넘긴 요소 자신**에 걸리므로 그 요소의 모양을 따릅니다. avatar를 사각형인 무언가로 감싸면 실선도 사각형이 됩니다. 임의의 자식을 받는 컴포넌트가 그보다 더 잘 알 방법은 없습니다.

:::

::: fw flutter

`bool`이 아니라 `BorderRadius`를 받고, 이것이 React 빌드와 갈리는 유일한 지점입니다. 저쪽에서 ring은 box shadow이고 CSS가 요소 자신의 `border-radius`를 공짜로 줍니다. 여기서는 자식의 모양을 읽을 수 있는 것이 없으므로 모양을 말해 주어야 합니다.

:::

## PlAvatarGroup에서 옮겨 오기

`PlAvatarGroup`은 자식의 종류 하나가 안에 새겨진 이 컴포넌트였고, 이제 없습니다. 얼굴이 늘어선 줄은 더미의 한 가지 배치이지 별도의 컴포넌트가 아닙니다.

옮겨지는 것들:

| `PlAvatarGroup` | `PlStack` |
| --- | --- |
| `<PlAvatarGroup>` | `<PlStack>` |
| `max`, `total`, `overlap` | 그대로 |
| 알아서 그려 주던 `+n` avatar | `overflow={(n) => <PlAvatar initials={\`+${n}\`} />}` |
| 모든 avatar에 한 번에 걸던 `size`, `color` | 스택을 감싸는 `PlassProvider`, 또는 avatar마다의 prop |
| 한 번에 걸던 `shape`, `variant`, `elevation` | avatar마다의 prop |
| 언제나 그려지던 ring | `ring` |

**진짜로 잃는 것은 그룹 context**이고, 그것은 지킬 수 없었습니다. 임의의 자식을 받는 더미는 그중 하나가 avatar라는 것을 알 방법이 없습니다. `size`와 `color`는 애플리케이션이 이미 한 번에 정하는 축이니 스택을 `PlassProvider`(Flutter에서는 `PlassTheme`)로 감싸세요. 나머지 셋은 애초에 애플리케이션 전체의 축이었던 적이 없고, avatar에 있는 것이 맞습니다.

얻는 것은 그룹이 할 수 없던 전부입니다. 어떤 자식이든, 세 가지 방향, 직접 말할 수 있는 쌓기 순서, 깊이, 그리고 직접 그리는 넘침 항목.

## Accessibility

::: fw react

- 스택은 role도 label도 붙이지 않습니다. 이미 자기가 무엇인지 말하는 내용을 감싼 `<div>`입니다. 얼굴 줄이 옆의 어떤 것도 이름 붙여 주지 않는 집합을 대신하고 있다면 `aria-label`을 주세요.
- 항목들은 자기 요소, 자기 semantics, 자기 focus 순서를 그대로 유지합니다. 복제되는 것도 대체되는 것도 없습니다.
- 쌓기 순서는 `z-index`이므로 무엇이 위에 그려지는지와 포인터가 어디에 닿는지를 바꿉니다. **읽는** 순서는 바꾸지 않습니다. 작성한 순서 그대로이고, 그게 원하는 바입니다. 스크린 리더는 어느 얼굴이 앞에 있든 집합을 주어진 순서대로 읽어야 합니다.

:::

::: fw flutter

- `semanticLabel`이 더미에 이름을 주고, 항목들은 그 아래에서 자기 노드를 유지합니다.
- hit test는 앞에서 뒤로 진행하며, 이는 그리는 순서의 반대입니다. 어느 지점에서 독자가 보고 있는 항목이 손가락이 닿는 항목입니다.
- 쌓기 순서는 그리기와 hit test만 바꿉니다. semantics 순서는 작성한 순서 그대로입니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 왜 |
| --- | --- | --- |
| `bool`인 `ring` | `BorderRadius?`인 `ring` | CSS는 ring에 요소 자신의 `border-radius`를 공짜로 줍니다. 여기서는 자식의 모양을 읽을 수 있는 것이 없으므로 말해 주어야 합니다. |
| negative margin | 자체 render object | `EdgeInsets`도 `Flex.spacing`도 음수가 아님을 assert하므로, 자식 크기를 알 수 있는 유일한 자리는 우리 자신의 레이아웃입니다. 어느 쪽이든 같은 상자를 보고합니다. |
| `overflow: (n) => ReactNode` | `overflow: Widget Function(int)?` | 같은 함수를, 각 프레임워크의 철자로. |
| 길이나 숫자인 `overlap`, `drop` | 논리 픽셀 `double?` | 여기에는 쓸 CSS 길이가 없습니다. |
| `aria-label` | `semanticLabel` | Flutter의 이름입니다. |
| `className`, `style` | — | 통과시킬 class 목록도 style 속성도 없습니다. |

:::
