---
title: PlCodeBlock
order: 22
---

# PlCodeBlock

<p class="plass-lede">한 줄짜리 코드부터 천 줄짜리까지 보여 주는 뷰어입니다. 위에는 바, 옆에는 줄 번호, 각 줄 앞에는 프롬프트, 그리고 읽을 팔레트 열두 벌이 있습니다.</p>

<Demo src="code-block/hero" :min-height="300" />

::: fw react

```tsx
import { PlCodeBlock } from 'plass-ui';

<PlCodeBlock code={source} language="tsx" title="src/Save.tsx" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlCodeBlock(
  code: source,
  language: 'dart',
  title: const Text('lib/save.dart'),
);
```

:::

코드 위에 그려지는 것은 전부 선택이고 각각 prop 하나로 켜고 끕니다. 같은 컴포넌트가 문장 안에 끼는 짧은 조각(바도, 번호도, 장식도 없는) 이면서 동시에 README 맨 위의 전체 기록이어야 하기 때문입니다.

## Props

<PropsTable name="PlCodeBlock" />

::: fw react

native `<div>` 속성은 그대로 전달됩니다. `color`는 위 표의 `color`와 충돌해서, `title`과 `prefix`는 컴포넌트가 직접 쓰기 때문에, `children`은 코드가 `code`이기 때문에, `onCopy`는 이 컴포넌트의 것이 event가 아니라 텍스트와 함께 발화하기 때문에 제외됩니다.

:::

::: fw flutter

### PlCodeToken

<PropsTable name="PlCodeToken" />

`PlCodeTokenKind`는 테마가 선언하는 열두 슬롯입니다. `comment`, `keyword`, `string`, `number`, `function`, `type`, `variable`, `tag`, `attribute`, `meta`, `addition`, `deletion`. `PlCodeTheme`은 그 열둘에 배경과 전경을 더한 것이고, 블록이 쓰는 나머지 다섯 색은 그 둘에서 **파생**되므로 직접 만드는 팔레트는 열아홉이 아니라 열네 값입니다.

:::

라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규약](../../design/prop-conventions)에 있습니다.

## Examples

### theme

팔레트는 `auto`를 빼면 페이지의 명암과 무관합니다. 기본은 `dark`이고, 이것만은 취향이 아닙니다. 코드는 터미널 이래로 어두운 바탕에서 읽혀 왔고, 페이지를 따라 하얘지는 블록은 그 페이지에서 색을 코드가 아닌 다른 것이 정한 유일한 요소가 됩니다.

<Demo src="code-block/themes" :min-height="360">

::: fw react

<<< @/.vitepress/demos/code-block/themes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/themes.dart

:::

</Demo>

넷은 이 라이브러리의 것입니다. `dark`, `light`, `auto`, 그리고 색상이 아예 없이 구조를 굵기로만 나르는 `mono`. 나머지 여덟은 발표된 hex 그대로 옮겨 온 것입니다. `one-dark`, `dracula`, `monokai`, `nord`, `night-owl`, `gruvbox`, `github`, `solarized-light`. 코드 블록은 읽는 사람이 이미 색에 대한 의견을 있는 유일한 컴포넌트입니다.

::: fw react

`theme`은 **아무 문자열이나** 받습니다. 프로젝트가 자기 것을 가져오는 방법입니다.

```css
[data-code-theme='ours'] {
  --p-code-bg: #101820;
  --p-code-fg: #e8e8e8;
  --p-code-keyword: #ff6b6b;
  /* …열한 개 더 */
}
```

슬롯은 열여섯이고 그중 다섯은 나머지 둘에서 파생되므로 선언할 필요가 없습니다. 등록할 것도, import할 것도 없습니다.

:::

::: fw flutter

여기에는 스타일시트가 없으므로, 직접 만드는 팔레트는 CSS 블록이 아니라 `customTheme`에 넘기는 `PlCodeTheme`입니다.

```dart
PlCodeBlock(
  code: source,
  customTheme: const PlCodeTheme(
    background: Color(0xFF101820),
    foreground: Color(0xFFE8E8E8),
    keyword: Color(0xFFFF6B6B),
    // …열한 개 더
  ),
);
```

:::

### lineNumbers

옆에 줄 번호가 붙고, `startLine`이 지정하는 번호부터 셉니다. `highlightLines`는 줄을 표시합니다. 옅은 바탕과 앞쪽 모서리의 선. gutter가 세는 방식으로 세므로, 551부터 시작하는 블록은 `'553-555'`로 표시합니다.

<Demo src="code-block/lines" :min-height="300">

::: fw react

<<< @/.vitepress/demos/code-block/lines.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/lines.dart

:::

</Demo>

표시의 색은 페이지의 색 계열이 아니라 그 테마 자신의 잉크에서 섞어 냅니다. 그래야 열두 팔레트 모두에서 읽히고, Dracula 블록 위에 아무도 고르지 않은 색 하나가 얹히는 일이 없습니다.

### prompt

내용이 있는 모든 줄 앞의 셸 프롬프트입니다. 그려지지만 **복사되지는** 않습니다. 붙여 넣은 `$`는 셸이 삼키지 못하는 `$`이므로, 기록은 기록인 채로 남으면서도 그대로 붙습니다.

<Demo src="code-block/terminal" :min-height="220">

::: fw react

<<< @/.vitepress/demos/code-block/terminal.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/terminal.dart

:::

</Demo>

줄 번호도 마찬가지입니다. 둘 다 텍스트 노드가 아니고, 둘 다 클립보드에 닿지 않습니다.

### Colouring

::: fw react

highlight.js이고, **dynamic import**로 불러옵니다. 문법은 40킬로바이트씩이고 서른다섯 개가 있으므로, 자기 chunk로 한 언어씩, 색을 요청한 블록에 대해서만 도착합니다. `highlight={false}`면 아무것도 받아 오지 않습니다.

블록은 첫 프레임에 평문으로 그려지고 문법이 도착하면 스스로 색을 입힙니다. `language`는 흔한 표기와 확장자를 알아들으므로, fenced code block에서 복사한 값이 그대로 동작합니다. `ts`, `tsx`, `js`, `sh`, `yml`, `dart`, `py`, `rb`, `rs`, `md`.

아무것도 모르는 언어는 거절하지 않고 평문으로 그립니다. `registerLanguage`로 가르치세요.

```ts
import { registerLanguage } from 'plass-ui';
import elixir from 'highlight.js/lib/languages/elixir';

registerLanguage('elixir', elixir);
```

module scope에서 부르세요. 이미 그려진 블록을 다시 칠하지는 않지만, 그 뒤에 mount되는 블록은 전부 봅니다.

`rawToggle`은 색을 걷어 내고 문자 그대로 보여 주는 두 번째 버튼을 바에 올립니다.

:::

::: fw flutter

**이쪽은 코드에 색을 입히지 않고 React 쪽은 입힙니다.** 그쪽은 dynamic import로 highlight.js에 닿지만, 이 패키지에는 의존성이 없고, 서른다섯 개 언어의 문법을 손으로 쓰는 것은 지킬 수 없는 약속입니다.

그래서 하이라이터가 있는 호출자는 결과를 `lines`로 넘기고, 없는 호출자는 프레임과 열두 팔레트와 한 가지 잉크로 그려진 코드를 받습니다.

```dart
PlCodeBlock(
  code: source,
  language: 'dart',
  lines: const <PlCodeLine>[
    <PlCodeToken>[
      PlCodeToken('const', PlCodeTokenKind.keyword),
      PlCodeToken(' answer = '),
      PlCodeToken('42', PlCodeTokenKind.number),
      PlCodeToken(';'),
    ],
  ],
);
```

`rawToggle`은 그 runs를 다시 한 가지 잉크로 되돌리는 버튼을 바에 올립니다. `lines`가 없으면 되돌릴 것이 없으므로 버튼도 그리지 않습니다.

:::

### wrap과 maxHeight

`wrap`은 긴 줄을 옆으로 흘리는 대신 접고, `maxHeight`는 블록의 높이를 묶고 코드를 그 안에서 스크롤합니다. 같은 문제에 대한 서로 다른 답이고 둘 다 켤 수 있습니다.

```tsx
<PlCodeBlock code={source} language="ts" wrap maxHeight={280} />
```

옆으로 스크롤해도 gutter와 프롬프트는 제자리에 있습니다. 행은 창의 너비가 아니라 가장 긴 줄의 너비를 가지므로, 모든 줄의 번호가 같은 자리에서 시작합니다.

## Accessibility

- 코드는 이름이 붙은 **focus 가능한 영역**입니다. `title`, 없으면 language, 그것도 없으면 코드를 뜻하는 낱말. 스크롤되는 영역은 끌 포인터가 없는 키보드로도 닿을 수 있어야 하고, focus 가능한 영역에는 이름이 있어야 합니다.
- 블록 안에서 <kbd>Mod</kbd> + <kbd>A</kbd>는 **그 블록**을 선택합니다. 주변 페이지가 아닙니다. 코드 목록으로 tab해 들어온 사람이 원한 것은 브라우저의 기본 답이 아닙니다.
- 번호와 프롬프트가 선택에서 빠지는 이유는 클립보드에서 빠지는 이유와 같습니다. 거기에는 선택할 것이 없습니다.

::: fw react

- 복사 버튼은 자기 라벨을 바꾸는데, 버튼이 아니라 페이지를 읽고 있는 스크린 리더는 그것을 듣지 못합니다. 그래서 블록은 `aria-live` 영역으로도 알립니다. 언제나 한 낱말입니다.
- raw 토글은 `aria-pressed`를 답니다.

:::

::: fw flutter

- 바의 각 버튼은 `button: true`와 자기 이름이 붙은 `Semantics` 노드이고, 안에 있는 것을 **제외**합니다. 복사 버튼은 자기 낱말을 지니는 동시에 그리기도 하는데, "복사, 복사"라고 들은 사람은 한 번 더 들은 것입니다.

:::
