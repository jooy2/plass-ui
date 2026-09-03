---
title: PlTree
order: 17
---

# PlTree

<p class="plass-lede">한 번에 한 가지씩 펼치는 계층입니다. node를 children이 아니라 데이터로 받는데, 트리는 재귀적이고 JSX로 쓴 재귀는 호출자마다 직접 써야 하는 컴포넌트이기 때문입니다.</p>

<Demo src="tree/hero" :min-height="380" />

::: fw react

```tsx
import { PlTree, type PlTreeNode } from 'plass-ui';

const items: PlTreeNode[] = [
  { id: 'src', label: 'src', children: [{ id: 'index', label: 'index.ts' }] },
  { id: 'readme', label: 'README.md' }
];

<PlTree items={items} defaultExpanded={['src']} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const List<PlTreeNode> items = <PlTreeNode>[
  PlTreeNode(id: 'src', label: Text('src'), children: <PlTreeNode>[
    PlTreeNode(id: 'index', label: Text('index.ts')),
  ]),
  PlTreeNode(id: 'readme', label: Text('README.md')),
];

PlTree(
  items: items,
  expanded: open,
  onExpandedChanged: (Set<String> next) => setState(() => open = next),
);
```

:::

## Props

<PropsTable name="PlTree" />

### PlTreeNode

<PropsTable name="PlTreeNode" />

네이티브 `<div>` 속성은 그대로 통과합니다. 공유 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

::: fw flutter

`expanded`와 `selected`는 **`Set<String>`**이고 둘 다 controlled입니다 — uncontrolled 형태가 없고, 그것이 이 패키지의 모든 입력에 대한 규칙입니다. 각 콜백은 바뀐 id 하나가 아니라 집합 전체를 돌려주므로, 호출자는 그것을 대입하면 끝입니다.

:::

## Examples

### selection

기본은 `single`입니다. `multiple`은 클릭이 더하는 행을 전부 남기고 `aria-multiselectable`로 그렇게 말합니다. `none`은 트리를 고르는 도구가 아니라 **둘러보는 도구**로 만듭니다 — 행은 여전히 펼쳐지고 클릭도 여전히 `onItemClick`으로 보고되지만, 아무것도 켜진 채 남지 않습니다.

<Demo src="tree/selection" :min-height="320">

::: fw react

<<< @/.vitepress/demos/tree/selection.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree/selection.dart

:::

</Demo>

### 제어하기

`expanded`와 `selected`는 따로입니다. 서로 다른 질문이기 때문입니다 — 폴더를 여는 것은 그것을 고르는 것이 아닙니다.

```tsx
<PlTree
  items={items}
  expanded={open}
  onExpandedChange={setOpen}
  selected={chosen}
  onSelectedChange={setChosen}
/>
```

둘 다 id 배열이고, 둘 다 `defaultExpanded` / `defaultSelected`로 제어하지 않을 수 있습니다.

삼각형은 두 각도 사이를 건너뛰지 않고 기본 duration 동안 **회전합니다**. 가지가 열렸는지를 알려주는 것은 행에서 이것 하나뿐이라, 두 프레임 사이에 각도가 바뀌면 상태 변화가 화면 밖에서 일어난 셈입니다. [accordion](../surfaces/accordion)의 chevron이 도는 것과 같은 회전이고, 두 컨트롤이 같은 종류임을 읽는 사람에게 알려주는 것도 그 점입니다.

### 아무것도 없는 가지

`children: []`과 `children: undefined`는 **서로 다른 것**이고, 그 차이가 눈에 보입니다. 앞의 것은 열리면 아무것도 없는 가지이고, 뒤의 것은 삼각형조차 없는 잎입니다.

```tsx
{ id: 'empty', label: 'Archive', children: [] }   // 가지
{ id: 'file',  label: 'README.md' }               // 잎
```

지연 로딩 트리가 가능한 이유가 그것입니다. 폴더에 빈 배열을 주고, `onExpandedChange`가 열렸다고 알려 주면 채우세요.

## Accessibility

- 진짜 `role="tree"`와 `role="treeitem"`이고, 열린 가지의 자식들 주위에는 `role="group"`이, 각 행에는 `aria-level` · `aria-expanded` · `aria-selected`가 붙습니다.
- **트리 전체에 tab stop 하나.** 그것은 focus를 이끄는 대신 따라가므로, 다시 Tab으로 들어오면 떠났던 행으로 돌아옵니다. <kbd>Tab</kbd>이 사백 개의 행을 걷는 트리는 아무도 끝에 닿지 못하는 트리입니다.
- <kbd>↓</kbd>와 <kbd>↑</kbd>는 실제로 **보이는** 행을 걷고, <kbd>→</kbd>는 가지를 열고 그다음에 안으로 들어갑니다 — 두 번 누름입니다. 그래야 그 가지가 있다고 알려 준 행을 떠나지 않고도 열 수 있습니다. <kbd>←</kbd>는 닫거나 부모로 나가고, <kbd>Home</kbd>과 <kbd>End</kbd>는 양끝으로 뛰고, <kbd>Enter</kbd>나 <kbd>Space</kbd>가 선택합니다.
- `disabled` 행은 `aria-disabled`이고 화살표 키의 정거장이 아닙니다. 지우는 대신 트리에 남깁니다 — 구멍 난 계층은 아무도 읽을 수 없는 계층이기 때문입니다.
- 삼각형은 `aria-hidden`입니다. 스크린 리더는 가지가 열렸다는 것을 `aria-expanded`로 듣고, 그러지 않으면 두 번 듣게 됩니다.

::: fw flutter

모든 행이 `Semantics` node이고, 가지에는 `expanded`가, 고를 수 있는 행에는 `selected`가 붙습니다. 트리 자체는 `explicitChildNodes` 컨테이너라서 행들이 하나로 합쳐지지 않습니다.

**tab stop 하나도 같은 방식입니다.** 현재 행을 뺀 모든 행의 `FocusNode`가 `skipTraversal`을 답니다 — Tab 순서에서는 빠지고 focus 트리에는 남으므로, 화살표 키는 여전히 닿을 수 있습니다. 그 하나의 정거장은 focus를 이끄는 대신 따라갑니다.

:::
