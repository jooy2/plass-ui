---
title: PlCollapsible
order: 7
---

# PlCollapsible

<p class="plass-lede">혼자 서 있는, 접히는 섹션 하나입니다. <code>PlAccordion</code>이 묶음으로 있는 바로 그 접힘을 옆에 아무것도 없이 떼어 놓은 것이라, 남의 목록 속 자리가 아니라 자기 <code>open</code>이 필요합니다.</p>

<Demo src="collapsible/hero" :min-height="200" />

::: fw react

```tsx
import { PlCollapsible } from 'plass-ui';

<PlCollapsible title="Advanced" subtitle="Nine settings">
  Everything the form does not need to ask on the first pass.
</PlCollapsible>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlCollapsible(
  open: showing,
  onOpenChanged: (bool next) => setState(() => showing = next),
  title: const Text('Advanced'),
  subtitle: const Text('Nine settings'),
  child: const Text('Everything the form does not need to ask on the first pass.'),
);
```

:::

## Props

<PropsTable name="PlCollapsible" />

::: fw react

나머지 `<div>` 속성은 모두 시트로 전달됩니다.

:::

라이브러리 전체에서 공유하는 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## PlCollapsible과 PlAccordion

[`PlAccordion`](./accordion)은 **묶음**이고, 묶음이라는 것이 핵심입니다. 다음 섹션이 열릴 때 마지막 섹션이 닫히는 것이 독자 아래에서 페이지가 자라지 않게 하는 방법입니다. collapsible에는 맞출 상대가 없습니다.

폼의 "더 보기", 선택적인 설정 묶음, 행 아래의 상세에는 이것을 쓰세요. 그것이 둘이 되고 한 번에 하나만 열려야 하는 순간부터는 아코디언입니다.

## 패널이 열리는 방식

패널의 높이는 **정말로** 애니메이션됩니다. [무언가를 움직이지 않는다는 규칙](../../design/design-language)의 예외처럼 보이지만 아닙니다. 아무것도 변형되지 않고, 어떤 글자도 다시 샘플링되지 않으며, 내용은 자기가 들어 있는 패널에 대해 움직이지 않습니다. 패널이 그 위로 열리는 창입니다.

즉시 나타나는 내용은 튀는 페이지이고, 그 규칙이 막으려는 실패가 바로 그것입니다.

## Examples

### variant

세 재질을 *컨테이너*의 방식으로 씁니다. 시트에는 색이 들어가지 않습니다. 접힘은 남의 내용을 담기 때문입니다. `ghost`는 흐르는 산문 속이나 카드 안에서 쓰는 것입니다. 맨 "더 보기" 한 줄이 페이지에 사각형 하나를 빚질 이유는 없습니다.

<Demo src="collapsible/variants" :min-height="360">

::: fw react

<<< @/.vitepress/demos/collapsible/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/collapsible/variants.dart

:::

</Demo>

### 헤더의 슬롯

`title`·`subtitle`·`startIcon`이 헤더입니다. `action`은 그 끝에 고정되고 **트리거 바깥**에 놓이는데, 이것은 레이아웃 취향이 아닙니다. 접기도 하고 스위치도 든 헤더에는 누를 것이 둘이고, 그중 하나를 다른 하나 안에 넣을 수는 없습니다.

셰브런은 움직이는 것이 아니라 돌아갑니다. 그리고 헤더에서 움직임으로 상태를 알리는 유일한 것이기도 한데, 그래서 헤더 자신은 색만 바뀝니다.

<Demo src="collapsible/slots" :min-height="220">

::: fw react

<<< @/.vitepress/demos/collapsible/slots.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/collapsible/slots.dart

:::

</Demo>

### trigger

헤더를 통째로 자기 컨트롤로 바꿉니다.

`title`과 그 주변 슬롯은 이미 있는 헤더를 그대로 쓰고 싶은 훨씬 흔한 경우를 위한 것입니다.

::: fw react

넘긴 요소가 **트리거가 됩니다**. 클릭 핸들러도, `aria-expanded`도, 패널을 가리키는 `aria-controls`도 전부 그것에 건네지므로 따로 연결할 것이 없습니다.

:::

::: fw flutter

`triggerBuilder`는 위젯이 아니라 **빌더**이고, 그것은 강제된 것입니다. React 요소는 새 prop과 함께 복제할 수 있지만 Dart 위젯은 만들어진 뒤에 탭 핸들러를 건네받을 수 없습니다. 그래서 빌더가 열림 상태와 콜백을 받아 원하는 대로 연결합니다.

:::

<Demo src="collapsible/trigger" :min-height="200">

::: fw react

<<< @/.vitepress/demos/collapsible/trigger.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/collapsible/trigger.dart

:::

</Demo>

::: fw react

### hiddenUntilFound와 keepMounted

닫힌 패널은 문서에 없습니다. 열리지 않은 접힘이 아무 비용도 들지 않는 이유가 그것입니다. 두 prop이 그것을 되돌리는데, 이유는 서로 다릅니다.

- `hiddenUntilFound`는 `hidden="until-found"`로 남겨 두어, 브라우저 자신의 페이지 검색이 닫힌 접힘 안의 글자를 찾고 **그것을 열 수** 있게 합니다. 문서 페이지에서 쓸 만한 쪽이 이것입니다.
- `keepMounted`는 그냥 남겨 둡니다. 만드는 데 비용이 큰 내용이나, 접혀 있는 동안에도 살아 있어야 하는 폼 상태가 붙은 내용을 위한 것입니다.

`hiddenUntilFound`가 `keepMounted`를 덮어씁니다. 같은 아이디어에 브라우저의 페이지 내 찾기를 붙인 것입니다.

:::

## Accessibility

- 헤더는 버튼으로 안내되고, 패널이 열려 있는지를 알리며, 포인터만큼이나 키보드의 누름에도 반응합니다.
- `action`은 트리거 바깥에 있으므로 다른 컨트롤 안에 중첩된 컨트롤이 아니라 자기 focus stop이 있습니다.
- 비활성 접힘의 트리거는 포커스 순서에서 빠지고, 패널은 있던 그대로 남습니다.

::: fw react

- 헤더는 진짜 `<button>`이고, 그것과 패널 사이의 `aria-expanded` / `aria-controls` 연결은 Base UI의 것입니다.
- `hiddenUntilFound`가 켜져 있으면 브라우저의 페이지 내 찾기가 아무것도 없는 곳으로 스크롤하는 대신 글자를 찾은 접힘을 엽니다.

:::

::: fw flutter

- `keepMounted`에서 닫힌 패널은 높이 0으로 잘릴 뿐 아니라 포커스 순서와 semantics 트리에서도 빠집니다. 아무도 볼 수 없는 패널은 키보드가 탭해 들어갈 수 있는 패널이 아닙니다.

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `open` / `defaultOpen` / `onOpenChange` | `open` / `onOpenChanged` | Flutter의 컨트롤은 controlled이고, 이 패키지의 상태 있는 위젯도 전부 그렇습니다. |
| 요소인 `trigger` | 빌더인 `triggerBuilder` | React 요소는 새 prop과 함께 복제할 수 있지만, Dart 위젯은 만들어진 뒤에 탭 핸들러를 건네받을 수 없습니다. 대신 빌더가 상태와 콜백을 받습니다. |
| `hiddenUntilFound` | — | 접힘을 열어 줄 브라우저의 페이지 내 찾기가 없습니다. |
| DOM에 숨겨 두는 `keepMounted` | 트리에 남겨 두는 `keepMounted` | 같은 아이디어에 더 날카로운 이유가 붙습니다. Flutter의 `State`는 위젯이 트리를 떠날 때 함께 사라지므로, 접혀 사라진 필드는 무엇을 입력했는지 잊어버립니다. |
| `className`, `style` | — | 전달할 class 목록도 style 속성도 없습니다. |

:::
