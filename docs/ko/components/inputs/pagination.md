---
title: PlPagination
order: 3
---

# PlPagination

<p class="plass-lede">긴 목록 아래에 놓이는 페이지 번호 줄입니다. 줄 안의 모든 버튼이 진짜 <code>PlButton</code>이라, 같은 size의 다른 컨트롤과 나란히 놓아도 기준선이 맞습니다.</p>

<Demo src="pagination/hero" :min-height="120" />

::: fw react

```tsx
import { PlPagination } from 'plass-ui';

<PlPagination count={12} page={page} onPageChange={setPage} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlPagination(
  count: 12,
  page: page,
  onPageChanged: (int next) => setState(() => page = next),
);
```

:::

## Props

<PropsTable name="PlPagination" />

::: fw react

네이티브 `<nav>` 속성은 그대로 전달됩니다. `color`는 위 표의 `color`와 충돌해서, `onChange`는 이 줄이 `onPageChange`로 쓰기 때문에 제외됩니다.

:::

::: fw flutter

줄은 **controlled**입니다. 현재 `page`를 받고, 선택된 페이지를 알립니다.

:::

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### variant

쉬고 있는 페이지가 어떻게 보일지를 정합니다. 현재 페이지는 줄의 variant가 무엇이든 언제나 `solid`입니다 — 읽지 않고도 알아볼 수 있어야 하는 것이 여기서는 그것 하나뿐입니다.

기본값이 `PlButton` 혼자일 때의 `solid`가 아니라 `ghost`인 이유는 간단합니다. 색 유리판 아홉 개가 한 줄에 놓이면 아홉 개 전부가 주 액션이라고 말하는 셈입니다.

<Demo src="pagination/variants" :min-height="220">

::: fw react

<<< @/.vitepress/demos/pagination/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pagination/variants.dart

:::

</Demo>

### siblingCount과 boundaryCount

`boundaryCount`는 양 끝에 고정으로 남는 페이지 수, `siblingCount`는 현재 페이지 양옆에 놓이는 페이지 수입니다. 그 사이는 전부 ellipsis가 되는데, 딱 한 페이지만 가려지는 경우에는 대신 그 페이지를 그립니다. `1 … 3 … 9`는 숫자 하나를, 그 숫자보다 넓은 기호 뒤에 숨기는 일이기 때문입니다.

줄은 어느 페이지에 있든 슬롯 개수를 일정하게 유지합니다. 창이 끝에 잘리는 대신 가까운 쪽으로 미끄러집니다. 이렇게 하지 않으면 1페이지에서 2페이지로 넘어갈 때 줄 전체가 다시 배치되고, 방금 누른 버튼이 포인터 아래에서 빠져나가 버립니다.

<Demo src="pagination/window" :min-height="300">

::: fw react

<<< @/.vitepress/demos/pagination/window.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pagination/window.dart

:::

</Demo>

### showArrows와 showEdges

이동 버튼은 아이콘만 있는 버튼이라 정사각형이 되고, 한 자리 숫자 페이지와 정확히 같은 크기에 놓입니다 — 양 끝의 폭이 가운데와 다른 줄은 컨트롤 두 개를 붙여 놓은 것처럼 읽힙니다. 범위의 양 끝에서는 해당 버튼이 disabled가 되면서 자리를 지키므로, 줄이 옆으로 밀리는 일이 없습니다.

<Demo src="pagination/steppers" :min-height="200">

::: fw react

<<< @/.vitepress/demos/pagination/steppers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pagination/steppers.dart

:::

</Demo>

::: fw react

### getPageHref

모든 숫자를 진짜 `<a href>`로 만듭니다. 이것이 없으면 줄은 버튼이고, 크롤러는 버튼을 누를 수 없습니다 — 기사나 상품의 페이지 목록이 사람에게만 존재하고 나머지에게는 1페이지에서 끝나 버립니다.

`href`와 `onPageChange`가 **둘 다** 있으면 핸들러가 이기고 이동은 취소됩니다. 클라이언트 라우터가 이미 가진 페이지를 그대로 쥐고 있는 경우입니다. `href`만 있고 핸들러가 없으면 링크가 링크답게 동작하고, 그래서 JavaScript가 로드되기 전에도 줄이 작동합니다. <kbd>⌘</kbd>, <kbd>Ctrl</kbd>, <kbd>Shift</kbd>, <kbd>Alt</kbd>를 누른 채로 한 클릭은 절대 취소하지 않습니다 — 새 탭을 열어 달라는 요청이기 때문입니다.

현재 페이지와 범위 끝의 이동 버튼은 `<button>`으로 남습니다. `disabled`는 `<a>`가 될 수 있는 상태가 아니기 때문입니다.

:::

<Demo src="pagination/links" :min-height="140">

<<< @/.vitepress/demos/pagination/links.tsx

</Demo>

### size

`PlButton`과 같은 높이 사다리를 씁니다. pagination과 button을 한 줄에 놓아도 기준선이 유지됩니다. 여기서 `density`의 기본값이 `compact`인 이유는, 숫자가 단어보다 옆에 필요한 자리가 적기 때문입니다.

<Demo src="pagination/sizes" :min-height="260">

::: fw react

<<< @/.vitepress/demos/pagination/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pagination/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- `<ul>`을 감싼 `<nav>`로 렌더링됩니다. 스크린리더가 건너뛸 수 있는 이름 붙은 landmark 안에, 길이로 페이지 범위를 말해 주는 목록이 들어 있습니다.
- 현재 페이지는 `aria-current="page"`를 갖고, 화면에 보이지 않는 `aria-live` 문장이 전체 몇 페이지 중 몇 페이지인지 말해 줍니다. ellipsis가 끼는 순간 목록 길이만으로는 알 수 없기 때문입니다.
- 모든 버튼에 접근 가능한 이름이 있습니다 (`Page 4`, `Next page`). 전부 prop이라 다른 언어의 페이지는 자기 문구를 넣으면 되고, 여기 있는 문자열은 화면에 그려지지 않습니다.
- ellipsis는 disabled 버튼이 아니라 `aria-hidden`인 `<span>`입니다. 쓸 수 없는 컨트롤이 아니라 문장 부호입니다.
- 페이지가 두 개 미만이면 아무것도 렌더링하지 않습니다. disabled된 `1` 하나만 있는 줄은 할 일이 없다고 광고하는 컨트롤입니다.
- 이동 버튼은 드로잉 네 개를 싣는 대신 chevron 글리프 하나를 돌려 씁니다. RTL에서는 방향이 뒤집힙니다.

:::

::: fw flutter

- 줄은 이름이 붙은 묶음이고, `label`이 그 이름입니다.
- 모든 버튼에 자기 이름이 있습니다 — "Page 4", "Next page". 전부 파라미터라 다른 언어의 화면은 자기 문구를 넣으면 되고, 여기 있는 문자열은 화면에 그려지지 않습니다.
- 페이지 버튼에 그려진 숫자는 읽히는 것에서 **제외**됩니다. `pageLabel`이 이미 그 숫자를 말하고 있고, 둘을 합친 라벨은 숫자를 두 번 읽게 됩니다.
- ellipsis는 semantics에서 통째로 제외됩니다. 쓸 수 없는 컨트롤이 아니라 문장 부호입니다.
- 페이지가 두 개 미만이면 아무것도 그리지 않습니다. disabled된 `1` 하나만 있는 줄은 할 일이 없다고 광고하는 컨트롤입니다.
- 범위 끝의 이동 버튼은 disabled가 되면서 자리를 지키므로, 줄이 옆으로 밀리는 일이 없습니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `getPageHref` | — | Flutter에는 링크 요소가 없고 Flutter 앱을 크롤링하는 것도 없으니, 줄은 버튼이고 라우터는 `onPageChanged`에서 부릅니다. |
| `defaultPage` / `onPageChange` | `page` / `onPageChanged` | Flutter 자신의 컨트롤이 controlled이고, 콜백 이름도 Flutter의 것입니다. |
| live region인 `statusLabel` | — | 현재 페이지는 focus가 닿을 때 그 버튼의 이름으로 알려지고, 페이지가 바뀔 때마다 울리는 live region은 방금 갈아 끼운 목록 위에 말을 겹쳐 놓게 됩니다. |
| `<ul>`을 감싼 `<nav>` | 이름이 붙은 semantics 묶음 | 건너뛸 landmark도, 리셋이 앗아 갈 목록 의미도 없습니다. |
| `aria-current="page"` | 채워진 variant와 버튼의 이름 | Flutter의 semantics 트리에는 `current`가 없습니다. |

:::
