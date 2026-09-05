---
title: PlTreeSelect
order: 22
---

# PlTreeSelect

<p class="plass-lede">리스트가 아니라 계층에서 고르는 값입니다. field 뒤에 놓인 <code>PlTree</code>이고, 카테고리·폴더·지역·조직도 node처럼 평평한 리스트가 뭉개 버리는 모양을 위한 것입니다.</p>

<Demo src="tree-select/hero" :min-height="220" />

::: fw react

```tsx
import { PlTreeSelect, type PlTreeSelectNode } from 'plass-ui';

const items: PlTreeSelectNode[] = [
  {
    id: 'europe',
    label: 'Europe',
    children: [{ id: 'france', label: 'France' }]
  },
  { id: 'antarctica', label: 'Antarctica' }
];

<PlTreeSelect items={items} label="Region" placeholder="Pick a region" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const List<PlTreeSelectNode> items = <PlTreeSelectNode>[
  PlTreeSelectNode(
    id: 'europe',
    label: 'Europe',
    children: <PlTreeSelectNode>[PlTreeSelectNode(id: 'france', label: 'France')],
  ),
  PlTreeSelectNode(id: 'antarctica', label: 'Antarctica'),
];

PlTreeSelect(
  items: items,
  label: const Text('Region'),
  value: chosen,
  onValueChanged: (Set<String> next) => setState(() => chosen = next),
);
```

팝업은 트리 밖으로 스스로 떠오르므로 위에 `Overlay`가 필요합니다. navigator가 있는 `WidgetsApp`과 `MaterialApp`이 모두 제공합니다.

:::

## Props

<PropsTable name="PlTreeSelect" />

### PlTreeSelectNode

<PropsTable name="PlTreeSelectNode" />

::: fw react

native `<div>` 속성은 field 래퍼로 그대로 전달됩니다. `color`는 위 표의 `color`와 충돌해서, `defaultValue`는 picker가 DOM 속성이 아니라 id 목록으로 쓰기 때문에, `children`은 트리가 `items`이기 때문에 제외됩니다.

`className`은 label과 control, 그 아래 두 줄을 담은 스택에 붙습니다. `classNames`는 그 안의 네 부분 — `label`, `control`, `description`, `error` — 에 닿습니다.

:::

::: fw flutter

`value`는 **`Set<String>`**이고 controlled입니다. uncontrolled 형태는 없으며, 이 패키지의 모든 입력이 그렇습니다. `expanded`와 `open`만 예외로, 넘기지 않으면 picker가 직접 쥡니다.

node의 `label`은 여기서 **`String`**이고 React에서는 `ReactNode`입니다. `PlTransferItem`이 이미 지고 있는 차이이고 이유도 같습니다. 필터가 label을 읽고, trigger가 그것을 쓰고, 스크린 리더가 그것을 받습니다. 텍스트라야 모든 node가 만들어질 때부터 검색 가능합니다. 이쪽에 `searchLabel`이 없는 것도 같은 이유입니다 — label이 이미 그 말입니다.

:::

라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규약](../../design/prop-conventions)에 있습니다.

## Examples

### searchable

트리 위에 걸러 내는 field를 둡니다. 맞은 node는 **조상을 데리고** 남습니다 — 아무것도 위에 없는 "Seoul"은 어느 분류에서 나온 것인지 말해 주지 않으니까요. 그리고 필터가 남긴 가지는 전부 열립니다. 닫힌 부모 안에 접힌 match는 아무에게도 보여 주지 않은 match입니다.

<Demo src="tree-select/searchable" :min-height="220">

::: fw react

<<< @/.vitepress/demos/tree-select/searchable.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_select/searchable.dart

:::

</Demo>

field를 비우면 접힘은 다시 읽는 사람의 것이 됩니다. 직접 열어 둔 가지는 그대로 열려 있고, 필터가 연 가지는 다시 닫힙니다.

::: fw react

대조는 악센트와 대소문자를 함께 접습니다. `jose`가 `José`를 찾습니다.

:::

::: fw flutter

대조는 대소문자만 접습니다. 악센트는 벗기지 **않는데**, Dart 코어에 `String.normalize`가 없고 이 패키지는 의존성을 두지 않기 때문입니다. React 쪽은 악센트까지 접습니다.

:::

### selectableBranches

기본은 꺼져 있고, 이런 트리는 대개 그런 모양입니다. 가지는 분류이고 잎이 답입니다. 고를 수 없는 가지도 여닫히기는 합니다 — 그것을 누르는 것이 아래에 있는 것에 닿는 방법이니까요.

<Demo src="tree-select/branches" :min-height="220">

::: fw react

<<< @/.vitepress/demos/tree-select/branches.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_select/branches.dart

:::

</Demo>

node 자신의 `selectable`이 어느 쪽으로든 덮어쓰므로, 진짜 카테고리인 "Home"은 고를 수 있게 두고 나머지 가지는 길로 남길 수 있습니다.

### multiple

누를 때마다 더해지고, trigger는 쉼표로 이어서 씁니다. 팝업은 열린 채로 있습니다. 여러 답 중 첫 번째에서 닫히는 picker는 나머지마다 다시 열어야 하니까요.

<Demo src="tree-select/multiple" :min-height="220">

::: fw react

<<< @/.vitepress/demos/tree-select/multiple.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_select/multiple.dart

:::

</Demo>

`format`은 고른 node들을 받아 원하는 대로 씁니다. 답과 함께 넓어지지 않는 trigger를 만들 때 씁니다.

```tsx
<PlTreeSelect items={items} multiple format={(chosen) => chosen.length + ' regions'} />
```

### Controlled

값, 접힘, 팝업은 각각 다른 질문이고 각자 짝이 있습니다.

```tsx
<PlTreeSelect
  items={items}
  value={chosen}
  onValueChange={setChosen}
  expanded={open}
  onExpandedChange={setOpen}
/>
```

폴더를 여는 것은 그것을 고르는 것이 아닙니다. 두 번째 짝이 따로 있는 이유입니다.

### In a form

`name`을 주면 쥔 id 하나당 `<input type="hidden">` 하나가 놓이므로, `multiple` picker는 반복 field로 제출됩니다.

```tsx
<PlTreeSelect items={items} multiple name="region" defaultValue={['france', 'spain']} />
```

## Accessibility

- trigger는 다른 모든 picker와 똑같이 button이고, label과 description, error, `aria-invalid`를 함께 답니다.
- 팝업 안은 진짜 [`PlTree`](../display/tree)입니다 — `role="tree"`와 `role="treeitem"`, `aria-level`, `aria-expanded`, `aria-selected`, 그리고 트리 전체에 **tab 정거장 하나**.
- <kbd>↓</kbd>와 <kbd>↑</kbd>는 실제로 보이는 행을 걷고, <kbd>→</kbd>는 가지를 연 뒤 안으로 들어가고, <kbd>←</kbd>는 닫거나 부모로 나가고, <kbd>Enter</kbd>나 <kbd>Space</kbd>가 고릅니다.
- 가지라서 고를 수 없을 뿐인 node에는 `aria-disabled`를 붙이지 않습니다. 아래 있는 것을 여는 조작 가능한 행이기 때문입니다. `disabled` node는 표시되고, 화살표 키의 정거장도 아닙니다.
- 거르는 field는 `searchLabel`로 스스로 이름을 붙이므로, 위에 보이는 label 없이도 읽힙니다.
