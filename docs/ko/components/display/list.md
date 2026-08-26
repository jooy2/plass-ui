---
title: PlList
order: 12
---

# PlList

<p class="plass-lede">행이 쌓인 묶음입니다. 목록이 시트이고 행은 그 위에 놓인 것이므로, <code>size</code>와 <code>density</code>는 묶음의 속성이고 행은 그것을 물려받습니다.</p>

<Demo src="list/hero" :min-height="360" />

::: fw react

```tsx
import { PlList, PlListItem } from 'plass-ui';

<PlList>
  <PlListItem description="Three unread" onClick={open}>
    Inbox
  </PlListItem>
  <PlListItem description="One saved">Drafts</PlListItem>
</PlList>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlList(
  children: <Widget>[
    PlListItem(description: const Text('Three unread'), onPressed: open, child: const Text('Inbox')),
    const PlListItem(description: Text('One saved'), child: Text('Drafts')),
  ],
);
```

:::

## Props

<PropsTable name="PlList" />

::: fw react

네이티브 `<ul>` 속성은 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 전달 대상에서 제외됩니다.

:::

### PlListItem

<PropsTable name="PlListItem" />

::: fw react

네이티브 `<li>` 속성은 안쪽의 button이나 link가 아니라 `<li>`에 그대로 전달됩니다. `size`, `density`, `dividers`는 감싸는 `PlList`에서 상속됩니다 — 그중 하나를 두고 이웃과 의견이 다른 행은 구멍 난 목록입니다.

:::

::: fw flutter

`size`, `density`, `color`, `dividers`는 감싸는 `PlList`에서 `InheritedWidget`을 통해 상속됩니다 — 그중 하나를 두고 이웃과 의견이 다른 행은 구멍 난 목록입니다. `PlList` 밖의 `PlListItem`이 기본값을 고르는 대신 단언으로 막는 이유이기도 합니다. 행은 무언가**의** 행입니다.

:::

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### 행 하나

::: fw react

껍데기는 언제나 `<li>`입니다. 바뀌는 것은 그 안에 든 것입니다 — 그냥 내용이 놓이거나, `onClick`이나 `href`가 주어지면 그 내용을 감싸는 진짜 `<button>` 또는 `<a>`가 놓입니다.

`action`은 일부러 그 누를 수 있는 영역 바깥에 놓입니다. 이동도 하고 토글도 담는 행에는 누를 것이 둘이고, `<button>` 안의 `<button>`은 브라우저가 파싱하며 다시 쓰는 마크업입니다.

:::

::: fw flutter

`onPressed`가 있는 행은 버튼으로 알려지는 focus stop이고, 없는 행은 role도 focus stop도 더하지 않습니다.

`action`은 일부러 그 누를 수 있는 영역 바깥에 놓입니다. 이동도 하고 토글도 담는 행에는 누를 것이 둘이고, 중첩된 제스처 인식기는 탭 하나를 두 번 받습니다.

:::

<Demo src="list/rows" :min-height="380">

::: fw react

<<< @/.vitepress/demos/list/rows.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/list/rows.dart

:::

</Demo>

### dividers

dividers를 켜면 선이 시트의 양 끝까지 닿아야 하므로, 목록은 안쪽 여백을 내놓고 행은 둥근 모서리를 내놓습니다. 행이 떠 있는 타일이면서 동시에 그어진 줄일 수는 없습니다.

<Demo src="list/dividers" :min-height="260">

::: fw react

<<< @/.vitepress/demos/list/dividers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/list/dividers.dart

:::

</Demo>

### variant

`PlCard`가 그렇듯 시트에는 색이 들어가지 않습니다. 목록은 남의 내용을 담고, 그 내용은 자기 색을 가지고 도착합니다.

card 안이라면 `ghost`입니다. card가 이미 시트인데, 그 안의 두 번째 테두리 사각형은 사각형이 하나 더 늘어난 것뿐입니다.

<Demo src="list/variants" :min-height="380">

::: fw react

<<< @/.vitepress/demos/list/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/list/variants.dart

:::

</Demo>

### size

<Demo src="list/sizes" :min-height="380">

::: fw react

<<< @/.vitepress/demos/list/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/list/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- 아래에 Base UI 프리미티브가 없는 것은 의도입니다. 목록은 복합 위젯이 아닙니다 — roving focus도, 선택 모델도, 자기만의 키보드 규약도 없습니다. menu나 listbox 프리미티브를 끌어오면 그냥 링크 목록에 메뉴의 의미를 붙이게 됩니다.
- `role="list"`를 명시적으로 씁니다. Tailwind의 리셋이 모든 `<ul>`에서 불릿을 없애고, Safari는 그와 함께 목록 의미까지 없애기 때문입니다.
- 선택된 링크는 `aria-current="page"`를, 선택된 button은 `aria-current="true"`를 답니다. 앞의 것은 "지금 보고 있는 페이지", 뒤의 것은 "이것들 중 고른 하나"입니다. `aria-pressed`는 세 번째 것, 즉 토글이고, 선택된 행은 토글이 아닙니다.
- `onClick`도 `href`도 없는 행은 role도 tab stop도 더하지 않습니다. click 핸들러만 달린 죽은 `<div>`는 키보드에 보이지 않습니다.
- `action`에 든 컨트롤에는 자기 이름을 주세요. 행과는 별개의 tab stop이고, 거기 있는 이유가 그것입니다.

:::

::: fw flutter

- 목록은 복합 위젯이 아닙니다 — roving focus도, 선택 모델도, 자기만의 키보드 규약도 없습니다 — 그래서 행을 묶는 것 말고는 role을 더하지 않고, 각 행이 스스로 말합니다.
- 선택된 행은 선택되었다고 보고합니다. 토글이 아니고, 토글인 척하지도 않습니다.
- `onPressed`가 없는 행은 role도 focus stop도 더하지 않습니다.
- `action`에 든 위젯에는 자기 이름을 주세요. 행과는 별개의 focus stop이고, 거기 있는 이유가 그것입니다.
- 목록에 선이 그어져 있으면 행의 focus ring은 안쪽으로 돌아섭니다. 잘리는 시트 가장자리에서 잘려 나가지 않게 하기 위해서입니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `onClick` / `href` | `onPressed` | Flutter에는 링크 요소가 없습니다. 이동하는 행은 `onPressed`에서 라우터를 부릅니다. |
| `<ul>` / `<li>`와 `role="list"` | 묶인 semantics 노드 | 리셋할 불릿도, 리셋이 앗아 갈 목록 의미도 없습니다. |
| `aria-current="page"`와 `"true"` | `selected` | Flutter의 semantics 트리에는 선택 플래그 하나가 있을 뿐, 페이지와 선택지의 구분이 없습니다. |
| React 컨텍스트 | `InheritedWidget` | 같은 생각을 Flutter의 말로, 같은 이유로 한 것입니다. 자식을 복제하는 방식은 호출자가 행을 한 번 감싸는 순간 닿지 않게 됩니다. |
| `render` | — | Flutter에는 요소를 바꿔 끼우는 수단이 없습니다. |
| 행의 `children` | `child` | Flutter의 이름입니다. |

:::
