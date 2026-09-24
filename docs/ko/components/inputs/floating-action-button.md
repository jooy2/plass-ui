---
title: PlFloatingActionButton
order: 2
---

# PlFloatingActionButton

<p class="plass-lede">화면이 다루는 단 하나의 액션이 그 위에 떠 있습니다. 모서리에 놓인 <code>PlButton</code>에 고정, 모양, 그리고 규칙 하나가 더해진 것입니다. 라벨은 그려지든 아니든 언제나 존재합니다.</p>

<Demo src="floating-action-button/hero" :min-height="260" />

::: fw react

```tsx
import { PlFloatingActionButton } from 'plass-ui';

<PlFloatingActionButton icon={<PlusGlyph />} label="New project" onClick={create} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlFloatingActionButton(
  icon: const PlusGlyph(),
  label: 'New project',
  onPressed: create,
);
```

:::

## Props

<PropsTable name="PlFloatingActionButton" />

::: fw react

[`PlButton`](./button)이 받는 것은 전부 받습니다. 세 가지 재질, elevation 사다리, 포인터 빛, `loading`, `readOnly`, `disabled`.

:::

::: fw flutter

[`PlButton`](./button)이 받는 것 중 떠 있는 버튼이 쓰는 것을 받습니다. 세 가지 재질, elevation 사다리, 포인터 빛, `color`, `loading`, `readOnly`, `disabled`, 그리고 `onLongPress`, `focusNode`, `autofocus`입니다.

:::

`density`는 `extended`일 때만 여백을 바꿉니다. 원판에는 바꿀 가로 여백이 없습니다.

- `label`은 필수이고 언제나 접근성 이름입니다. `extended`가 정하는 것은 **글자도 그릴지**이지 글자가 존재하는지가 아닙니다.
- 아이콘만 있는 쪽은 **원판**입니다. 글자가 있는 쪽은 알약이 되지 않고 하우스 fillet을 씁니다.
- `elevation` 기본값은 사다리 꼭대기인 **3**이고, `size` 기본값은 `PlButton`보다 한 칸 위인 `lg`입니다. 떠 있는 버튼은 엄지가 겨누는 표적이기 때문입니다.
- 한 화면에 하나만, 달리 놓일 자리가 없는 액션에 쓰세요. 주요 액션이 이미 본문의 버튼으로 있는 화면은 그 사본을 모서리에 하나 더 두고 싶어 하지 않습니다.

::: fw react

- `position: fixed`에 **논리** inset을 인라인으로 씁니다. 그래서 `offset`이 어떤 utility class보다 우선합니다.
- [`PlBackTop`](../navigation/back-top)과 같은 `z-30`에 놓입니다. 페이지 위, portal된 것 아래입니다.

:::

::: fw flutter

- `floating`인 동안은 `PositionedDirectional`이므로 `Stack` 안에 놓입니다. 무언가 떠 있는 화면의 본문은 보통 이미 `Stack`입니다.

:::

모양과 elevation의 이유는 [디자인 언어](../../design/design-language#radius는-fillet)에, 공유 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## Examples

### extended

글리프 옆에 label을 그립니다. 처음 온 사람이 글리프만 보고 짐작하지 못할 액션이면 켜고, 짐작할 수 있게 되면 다시 끄십시오.

<Demo src="floating-action-button/extended" :min-height="180">

::: fw react

<<< @/.vitepress/demos/floating-action-button/extended.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_action_button/extended.dart

:::

</Demo>

### corner · offset

`corner`는 넷 중 하나이고 left/right가 아니라 `start`/`end`로 적습니다. 그래서 RTL에서 다른 모든 것과 함께 반대편으로 건너갑니다. `offset`은 맞닿은 두 모서리에서 얼마나 떨어져 서는지입니다.

::: fw react

```tsx
<PlFloatingActionButton corner="bottom-start" offset={16} icon={<PlusGlyph />} label="Add" />
```

:::

::: fw flutter

```dart
PlFloatingActionButton(
  corner: PlassCorner.bottomStart,
  offset: 16,
  icon: const PlusGlyph(),
  label: 'Add',
  onPressed: add,
);
```

:::

`offset` 위에는 그 두 모서리의 safe area가 더해집니다. 그래서 화면 끝까지 그리는 기기에서 버튼이 홈 인디케이터, 내비게이션 바, 카메라 컷아웃을 피해 앉습니다.

::: fw react

그 공간은 `env(safe-area-inset-*)`입니다. 브라우저는 viewport meta 태그에 `viewport-fit=cover`가 있는 페이지에만 그 inset 값을 줍니다. 없으면 아무것도 더해지지 않습니다.

```html
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
```

:::

::: fw flutter

그 공간은 `MediaQuery.paddingOf`입니다. 버튼 위에 `SafeArea`가 있으면 이 값은 이미 0이므로, 가장자리를 직접 비워 둔 화면에서도 두 번 더해지지 않습니다.

:::

### floating

<Fw react="floating={false}" flutter="floating: false" code />는 모양과 그림자를 남기고 위치 지정만 뺍니다. 카드 끝이나 툴바에 같은 버튼을 놓을 때 씁니다.

::: fw react

```tsx
<PlFloatingActionButton floating={false} extended icon={<PlusGlyph />} label="New project" />
```

:::

::: fw flutter

```dart
PlFloatingActionButton(
  floating: false,
  extended: true,
  icon: const PlusGlyph(),
  label: 'New project',
  onPressed: create,
);
```

:::

## Accessibility

- 이름은 언제나 `label`이고, `extended`가 그렸을 바로 그 글자입니다. 이름 없이 이 버튼을 만들 방법은 없습니다.
- 진짜 버튼일 뿐입니다. 문서 순서대로 포커스를 받고, <kbd>Enter</kbd>와 <kbd>Space</kbd>에 답하며, `loading`과 `disabled`를 `PlButton`과 똑같이 보고합니다.
- **내용을 가립니다.** 모서리에 고정된 버튼은 그 아래 있는 무엇이든 덮으므로, 스크롤되는 목록 끝에는 자리를 남겨 두십시오. 떠 있는 버튼 아래 깔린 마지막 줄은 아무도 누를 수 없는 줄입니다.
