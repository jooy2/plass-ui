---
title: PlIconButton
order: 2
---

# PlIconButton

<p class="plass-lede">글리프 하나만 든 둥근 버튼입니다. 모양과, 필수인 prop 하나 — 그림이 말하지 못하는 단어 — 를 빼면 전부 <code>PlButton</code>의 것입니다.</p>

<Demo src="icon-button/hero" :min-height="120" />

::: fw react

```tsx
import { PlIconButton } from 'plass-ui';

<PlIconButton icon={<TrashIcon />} label="Delete" variant="glass" color="danger" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlIconButton(
  icon: const Icon(Icons.delete_outline),
  label: 'Delete',
  variant: PlassVariant.glass,
  color: PlassColor.danger,
  onPressed: remove,
);
```

:::

## Props

<PropsTable name="PlIconButton" />

::: fw react

`PlButton`이 받는 모든 prop이 그대로 전달됩니다. 글리프가 넘겨받은 `children` · `startIcon` · `endIcon`만 예외입니다. 네이티브 `<button>` 속성도 그대로 전달됩니다.

:::

::: fw flutter

`PlButton`이 받는 모든 매개변수가 그대로 전달됩니다. `child` · `startIcon` · `endIcon` · `fullWidth`만 예외입니다 — 앞의 셋은 글리프가 가져갔고, 늘어나는 원반은 원반이 아닙니다. `density`도 없습니다. 좌우 여백을 바꾸는 값인데, 아이콘만 있는 버튼에는 좌우 여백이 없습니다.

:::

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### label

필수이고, 여기서 필수인 유일한 prop입니다.

라벨 전체가 그림인 버튼에는 접근 가능한 이름이 아예 없습니다. 그리고 "<Fw react="aria-label" flutter="시맨틱 라벨" code />이 없는 아이콘 버튼"은 컴포넌트 라이브러리가 내보내는 접근성 결함 중 가장 흔한 하나입니다. 필수로 만드는 것이 리뷰를 견디는 유일한 해법입니다 — 린트 규칙은 프로젝트가 설치해야 하는 것이고, 기본값 `''`은 아무도 알아채지 못하는 것입니다.

절대 화면에 그려지지 않습니다. 독자가 보는 것은 글리프이고, 나머지 전부가 읽는 것은 문장입니다.

### 모양

아이콘만 있고 라벨이 없는 `PlButton`은 이미 정사각형이 됩니다. 같은 높이, 같은 너비, 하우스 필렛이 깎인 채로. 이것은 그 다음 모양입니다 — 원반.

그 원반은 반경 규칙에 대한 의도된 예외입니다. 그 규칙은 모든 모서리를 컨트롤을 알약으로 만들 50%에서 한참 못 미치게 붙들어 둡니다. 규칙이 말하는 대상은 _라벨이 있는_ 컨트롤입니다. 위아래 가장자리의 평평한 구간은 글자 한 줄이 앉는 자리이고, 글리프에는 글자 줄이 없습니다. 가운데 표식 하나가 찍힌 원은 성형된 키가 아니라 찍어낸 토큰이고, 그래서 규칙이 지키려는 것을 다른 길로 말합니다.

<Demo src="icon-button/variants" :min-height="120">

::: fw react

<<< @/.vitepress/demos/icon-button/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon_button/variants.dart

:::

</Demo>

### size

`PlButton`과 같은 높이 사다리입니다. 원반과 라벨 버튼을 한 줄에 놓아도 기준선이 유지됩니다. 안쪽 글리프는 독립 아이콘 사다리가 아니라 버튼에 대한 `em`으로 크기가 정해집니다. 그래서 모든 단계에서 비례가 유지됩니다.

<Demo src="icon-button/sizes" :min-height="300">

::: fw react

<<< @/.vitepress/demos/icon-button/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon_button/sizes.dart

:::

</Demo>

### color

<Demo src="icon-button/colors" :min-height="120">

::: fw react

<<< @/.vitepress/demos/icon-button/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon_button/colors.dart

:::

</Demo>

### loading, readOnly, disabled

셋 다 `PlButton`의 것 그대로입니다. `loading`은 글리프 자리에 스피너를 놓고 버튼이 실행되지 않게 하되 포커스는 유지합니다. `readOnly`는 색을 지키고 채도를 뺍니다. `disabled`는 빛을 끄고 포커스 순서에서 빠집니다.

<Demo src="icon-button/states" :min-height="120">

::: fw react

<<< @/.vitepress/demos/icon-button/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon_button/states.dart

:::

</Demo>

## Accessibility

- `label`이 접근 가능한 이름이고 필수입니다. 여기서 이름을 대신 줄 수 있는 것은 없습니다.
- 글리프는 장식입니다. 이미 이름이 있는 컨트롤 안에 있으므로, 그림에서 나온 두 번째 이름은 같은 이름을 두 번 읽는 일이 됩니다.
- 나머지는 전부 `PlButton`의 것입니다 — 포커스 링, 키보드 실행, 로딩 중의 `aria-busy`, 그리고 disabled일 때만 포커스 순서에서 빠지는 것.

::: fw react

- 원반은 여전히 진짜 `<button>`입니다. `render={<a href="…" />}`는 그것을 진짜 링크로 만들고, 링크로 안내되며 크롤러가 따라갑니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `onClick` | `onPressed` | Flutter의 이름이고, 비워 두는 것이 버튼을 비활성화하는 방법입니다. |
| `render` | — | 바꿔 끼울 요소도, 주장할 링크 시맨틱도 없습니다. |
| `density`, `fullWidth` | — | density는 좌우 여백을 바꾸는데 아이콘만 있는 버튼에는 그 여백이 없고, 늘어나는 원반은 원반이 아닙니다. |
| 반경을 위한 인라인 `style` | `PlButton.borderRadius` | Flutter에는 인라인 style이 없어서 `PlButton`이 탈출구를 하나 들고 있고, 그것이 존재하는 이유가 이 위젯입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

반경은 넉넉히 큰 수가 아니라 컨트롤 높이의 절반입니다. 상자보다 큰 반경은 그리는 쪽에서 비례로 줄여 버리고, 그렇게 줄여진 원반은 양 끝에서 원반이 아니게 됩니다.

:::
