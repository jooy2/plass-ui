---
title: usePlHotKeys
order: 4
---

# usePlHotKeys

<p class="plass-lede">컨트롤 하나에 매이지 않은 키보드 chord를 바인딩합니다. <code>PlHotKeys</code>가 그리고 필드의 <code>hotKeys</code> prop이 바인딩하는 그 어휘라서, 화면에 보이는 단축키와 실제로 동작하는 단축키가 어긋날 수 있는 두 문자열이 아니라 하나입니다.</p>

<Demo src="hooks/hot-keys" :min-height="300" />

::: fw react

```tsx
import { usePlHotKeys } from 'plass-ui';

usePlHotKeys({
  'Mod+K': () => setPaletteOpen(true),
  'Mod+S': save
});
```

:::

::: fw flutter

hook은 React 전용입니다. Flutter는 프레임워크 자신의 `Shortcuts`와 `Actions`로, 짧게는 `CallbackShortcuts`로 chord를 바인딩합니다.

```dart
CallbackShortcuts(
  bindings: <ShortcutActivator, VoidCallback>{
    const SingleActivator(LogicalKeyboardKey.keyS, meta: true): save,
  },
  child: child,
);
```

:::

## Signature

```ts
function usePlHotKeys(hotKeys: PlassHotKeys | undefined, options?: PlHotKeysOptions): void;

type PlassHotKeys = Record<string, () => void>;
```

| Option        | 기본값   |                                                  |
| ------------- | -------- | ------------------------------------------------ |
| `enabled`     | `true`   | chord를 바인딩할지                               |
| `target`      | `window` | 리스너를 어디에 붙일지, element, ref, `document` |
| `whileTyping` | `false`  | 텍스트 필드에 focus가 있는 동안에도 답할지       |

chord는 [`PlHotKeys`](../components/display/hot-keys)가 쓰는 방식 그대로 씁니다. `Mod`는 Mac에서 Command, 그 밖에서는 Control이고, `Esc` · `Return` · `Cmd` · `Option`은 각자의 키 캡과 같은 키로 접힙니다.

## 규칙

필드의 `hotKeys` prop과 공유하는 세 가지입니다.

- **modifier는 양방향으로 검사합니다.** `Enter`는 `Shift+Enter`에서 발동하지 않고, `Mod+K`는 `Mod+Shift+K`에서 발동하지 않습니다. 단축키를 바인딩하는 것과 키를 바인딩하는 것의 차이입니다.
- **맞은 chord는 소비됩니다.** `preventDefault()`. 그래서 브라우저 자신의 `Mod+K` 검색창이 함께 열리지 않습니다. 반대편에서 읽으면, **이미** 소비된 이벤트는 건드리지 않습니다. 필드 자신의 `hotKeys` 맵이 페이지의 것을 이깁니다.
- **글자가 아니라 chord입니다.** modifier 없는 키 하나도 허용되고 때로는 그것이 맞습니다. `whileTyping`이 다루는 것이 바로 그 경우입니다.

### whileTyping

기본은 꺼짐입니다. 검색으로 뛰어가는 전역 <kbd>/</kbd>가, 누군가 폼에 입력 중인 URL에서 슬래시를 빼앗아서는 안 됩니다.

들리는 것보다 좁습니다. 붙잡히는 chord는 두 종류뿐입니다.

| chord                             | 필드 안에서                                                |
| --------------------------------- | ---------------------------------------------------------- |
| `Mod+K`, `Ctrl+B`, `Alt+Enter`    | **답합니다.** 그 modifier들은 필드 값에 나타날 수 없습니다 |
| `Escape`, `F2`                    | **답합니다.** 입력 중인 것에 아무 일도 하지 않습니다       |
| `Shift+A`                         | 붙잡힙니다. 대문자 A를 그렇게 칩니다                       |
| `/`, `Enter`, `Backspace`, 화살표 | 붙잡힙니다                                                 |

그래서 보통은 아무것도 설정할 필요가 없습니다. 사용자가 있는 그 필드에 속한 chord라면 켜세요.

## Examples

### 애플리케이션의 단축키

```tsx
export function App() {
  usePlHotKeys({
    'Mod+K': () => setPaletteOpen(true),
    'Mod+/': () => setHelpOpen(true),
    'Mod+Shift+D': toggleTheme
  });

  return …;
}
```

맵은 인라인으로 써도 됩니다. 핸들러는 키를 누를 때마다 새로 읽으므로 현재 state를 담은 핸들러가 낡을 일이 없고, 리스너를 다시 붙이게 하는 것은 맵의 identity가 아니라 **chord의 집합**이 바뀌는 것입니다.

### 한 문자열로 표시하고 바인딩하기

```tsx
const SHORTCUTS = { 'Mod+S': save, 'Mod+Enter': submit };

usePlHotKeys(SHORTCUTS);

return Object.keys(SHORTCUTS).map((chord) => <PlHotKeys key={chord} keys={chord} />);
```

키가 적힌 곳이 하나뿐이므로, 화면의 키 캡이 아무것도 바인딩되지 않은 키를 주장할 수 없습니다.

### 영역으로 좁히기

```tsx
const panel = useRef<HTMLDivElement>(null);

usePlHotKeys({ Escape: close }, { target: panel });
```

> `keydown`은 focus를 품고 있는 element에만 닿습니다. 아무도 Tab으로 들어가지 않은 패널로 좁히면 아무것도 바인딩되지 않습니다. 보통 "좁힌다"는 말이 뜻하던 바이긴 하지만, 버그처럼 보이기 전에 알아 둘 만합니다.

### 화면과 함께 꺼지게 하기

```tsx
usePlHotKeys({ Escape: close }, { enabled: open });
```

`enabled: false`는 핸들러를 벙어리로 만드는 대신 리스너를 뗍니다. 그래서 꺼진 단축키가 그 키를 원하던 다른 것에서 키를 빼앗지 않습니다.

## Accessibility

- 단축키는 가속기이지 유일한 방법이 아닙니다. 여기 바인딩된 모든 것은 Tab으로 닿는 컨트롤로도 할 수 있어야 합니다.
- chord를 보여 주세요. `PlHotKeys`가 그려 주고, `PlMenuItem`과 `PlCommandPalette`에 자리가 있습니다. 보이지 않는 단축키는 아무도 쓰지 않는 단축키입니다.
- 키 하나짜리 단축키는 [WCAG 2.1 SC 2.1.4](https://www.w3.org/WAI/WCAG21/Understanding/character-key-shortcuts.html)가 명시한 위험입니다. 음성 입력이 실수로 발동시킵니다. 기본값인 `whileTyping: false`가 최악은 막아 주고, 나머지는 아예 끌 수 있게 하는 것이며 `enabled`가 그 방법입니다.
