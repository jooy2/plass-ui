---
title: PlCommandPalette
order: 5
---

# PlCommandPalette

<p class="plass-lede">애플리케이션이 할 수 있는 모든 것을 필드 하나 뒤에 둡니다. 메뉴 바가 담을 수 있는 것보다 액션이 많아진 키보드 중심 제품이 취하는 형태입니다. 어디에 뒀는지 기억하는 대신 원하는 것을 칩니다.</p>

<Demo src="command-palette/hero" :min-height="200" />

::: fw react

```tsx
import { PlCommandPalette } from 'plass-ui';

<PlCommandPalette
  items={[{ value: 'new', label: 'New document', group: 'File', shortcut: 'Mod+N' }]}
  onSelect={(item) => run(item.value)}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlCommandPalette(
  open: open,
  onOpenChanged: (bool next) => setState(() => open = next),
  onSelect: (PlCommandItem item) => run(item.value),
  items: const <PlCommandItem>[
    PlCommandItem(value: 'new', label: 'New document', group: 'File', shortcut: 'Mod+N'),
  ],
);
```

:::

## Props

<PropsTable name="PlCommandPalette" />

::: fw react

네이티브 속성은 전달되지 않습니다. 팔레트는 트리 안의 요소가 아니라 portal로 띄운 dialog를 그리므로, 지나가던 `id`나 `onClick`이 닿을 곳이 없습니다. 닿는 것은 `className`과 `style` 둘이고, 둘 다 시트에 붙습니다. 그 뒤의 scrim에 닿는 것이 `classNames.backdrop`입니다.

:::

### PlCommandItem

<PropsTable name="PlCommandItem" />

공용 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## Command palette와 menu

- [`PlMenu`](./menu)가 **아닙니다**. 메뉴는 한 자리에 있는 짧은 목록이고, 찾으러 가기 전에 모든 행이 이미 보입니다.
- [`PlCombobox`](../inputs/combobox)도 **아닙니다**. 돌아오는 것은 값이 아니라 일어나는 일입니다.

"그 명령 어디 있더라"의 답이 "기억 안 나"가 됐을 때 쓰세요.

## Examples

### 그룹, 설명, 키워드

명령은 주어진 순서대로 그려지고, `group`이 바뀔 때마다 제목이 나타납니다. 그래서 한 그룹의 명령은 붙여서 나열해야 합니다. 배치 규칙은 그것이 전부이고, 화면의 순서가 컴포넌트가 몰래 정렬한 것이 아니라 배열의 순서라는 뜻이기도 합니다.

`keywords`는 맞춰지지만 **그려지지 않습니다**. 다른 제품이 같은 명령에 붙인 이름, 약어, 사람들이 검색했을 단어입니다.

필터는 대소문자와 결합 문자를 접으므로 `cafe`가 `Café`를 찾습니다. 각 명령의 검색 대상 텍스트는 비교마다가 아니라 **목록당 한 번** 접힙니다. 글자를 칠 때마다 모든 명령에 `normalize`를 도는 것이 팔레트를 느리게 만드는 바로 그 비용입니다.

<Demo src="command-palette/groups" :min-height="160">

::: fw react

<<< @/.vitepress/demos/command-palette/groups.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/command_palette/groups.dart

:::

</Demo>

### shortcut

이름을 공유하는 서로 다른 둘이 있고, 그중 하나만 바인딩됩니다.

**행**의 `shortcut`은 행 끝에 [`PlHotKeys`](../display/hot-keys)로 표시됩니다. 팔레트는 그것을 바인딩하지 않습니다. 애플리케이션이 이미 했고, 컴포넌트까지 바인딩하면 아무도 요청하지 않은 두 번째 리스너가 됩니다.

**팔레트**의 `shortcut`은 window에 바인딩되고 기본값은 `Mod+K`입니다. `PlHotKeys`가 그리는 것과 같은 `Mod` 인식 표기로 읽으므로, 화면의 키 캡과 실제로 동작하는 키가 어긋날 수 없습니다. `false`면 아무것도 바인딩하지 않습니다.

### size

시트의 너비, 필드의 높이, 행의 타입 스케일입니다. 필드는 컨트롤 사다리보다 한 단 위에 앉습니다. `md`가 48px입니다. 팔레트의 필드는 컨트롤 행 안의 컨트롤이 아니라 시트의 꼭대기이고, 화면에 있는 유일한 것이기 때문입니다.

`density`는 행 높이만 옮깁니다.

<Demo src="command-palette/sizes" :min-height="140">

::: fw react

<<< @/.vitepress/demos/command-palette/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/command_palette/sizes.dart

:::

</Demo>

### Controlled

`open`을 `onOpenChange`와 함께 넘기세요. 팔레트는 여전히 묻고(키를 누르면 `onOpenChange(true)`가 발생하고) 호출하는 쪽이 그렇다고 하기 전까지 열리지 않습니다. route guard나 "에디터가 바쁠 때는 안 됨" 같은 규칙에 필요한 것이 그것입니다.

질의는 들어올 때가 아니라 **나갈 때** 버려집니다. 그래야 시트가 사라지면서 마지막 검색어를 번쩍 보여 주지 않습니다.

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `open` / `defaultOpen` | 필수인 `open` | uncontrolled 모드가 없습니다. 팔레트를 여는 것은 앱 전체에 걸린 키이고, 그런 키를 거는 앱은 이미 상태를 쥐고 있습니다. |
| `shortcut: false` | `shortcut: null` | "아무것도 바인딩하지 않는다"를 Dart가 나타내는 방식입니다. |
| Base UI Autocomplete가 다루는 목록 키 | focus 시스템보다 먼저, 팔레트 자신의 키 핸들러에서 | 필드가 focus를 쥐고 있고 `EditableText`가 화살표 키와 Enter를 스스로 삼킵니다. 먼저 읽는 것만이 필드가 모든 글자를, 목록이 자기 네 키를 지키는 길입니다. |
| `aria-activedescendant`를 지닌 `combobox` | 필드 하나와 `button` 목록, 그중 하나가 selected | Flutter semantics에는 `activedescendant`가 없습니다. 남는 것은 중요한 쪽입니다. 하이라이트는 하나이고, 그것이 얹힌 행에서 알려집니다. |
| 대소문자 **와** 결합 문자를 접음 | 대소문자만 | Dart 코어에는 `String.normalize`가 없고, 이 패키지에는 의존성이 없습니다. |
| 숫자나 CSS 길이인 `width`, `maxHeight` | `double` | 이름 붙일 두 번째 단위가 없습니다. |
| `className`, `style` | — | 전달할 class 목록도 style 속성도 없습니다. |

:::

## Accessibility

- 시트는 focus trap과 scrim과 <kbd>Esc</kbd>를 갖춘 dialog이고, focus는 독자가 있던 자리로 돌아갑니다. 보이는 제목이 없으므로 `label`이 접근 가능한 이름입니다.
- 필드는 `combobox`이고 목록은 그 `listbox`이며, Base UI가 `aria-activedescendant`로 잇습니다. 화살표 키가 focus를 옮기지 않고 하이라이트만 옮기므로 필드가 모든 키 입력을 그대로 받습니다.
- 하이라이트는 **하나**입니다. 포인터와 화살표 키가 같은 표시를 움직이므로, 하이라이트된 행 둘을 보며 <kbd>Enter</kbd>가 어느 쪽을 실행할지 고민할 일이 없습니다.
- 그룹 제목은 `role="presentation"`입니다. 두 번째 목록이 아니라 같은 목록의 시각적 묶음입니다.
- `disabled` 명령은 목록에 남고 실행되지 않습니다. 고를 수 없다고 사라지는 항목은 독자가 계속 찾아 헤매게 되는 항목입니다.
- 전체가 `<body>` 끝으로 portal되고, backdrop과 viewport가 `.plass-portal`을 지닙니다. CSS reset을 범위 지정한 호스트가 같은 reset을 거는 자리가 그것입니다.
