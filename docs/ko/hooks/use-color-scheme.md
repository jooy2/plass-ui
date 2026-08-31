---
title: usePlColorScheme
order: 5
---

# usePlColorScheme

<p class="plass-lede">다크 모드 토글, 그리고 깜빡이지 않는 토글을 만드는 데 필요한 것들. 플랫폼을 그냥 따라가기만 하는 페이지라면 이 중 아무것도 필요 없습니다 — 토큰이 이미 스스로 그렇게 합니다.</p>

<Demo src="hooks/color-scheme" :min-height="260" />

::: fw react

```tsx
import { usePlColorScheme } from 'plass-ui';

const { scheme, resolved, setScheme, toggle } = usePlColorScheme();
```

:::

::: fw flutter

hook은 React 전용입니다. Flutter는 `PlassTheme`으로 subtree를 고정하고, 선택을 보관하는 것은 앱 자신의 저장소입니다.

```dart
PlassTheme(brightness: Brightness.dark, child: child);
```

:::

## Signature

```ts
function usePlColorScheme(options?: {
  defaultScheme?: 'light' | 'dark' | 'system'; // 'system'
  storageKey?: string; // 'plass-color-scheme'
}): {
  scheme: 'light' | 'dark' | 'system';
  resolved: 'light' | 'dark';
  setScheme: (next: 'light' | 'dark' | 'system') => void;
  toggle: () => void;
};
```

`scheme`은 사용자가 고른 것이고, **`system`은 세 번째 테마가 아니라 고르지 않았다는 뜻**입니다. 질문을 `prefers-color-scheme`에게 되돌려주므로, 플랫폼의 현재 답에 고정되는 것이 아니라 플랫폼을 다시 따라갑니다. `resolved`는 페이지가 실제로 칠해진 쪽입니다.

`toggle`은 **칠해진 것**의 반대로 뒤집습니다. 그래서 시스템이 다크인 페이지에서 처음 누르면 라이트가 됩니다 — 토글을 누른 사람이 뜻한 바가 그것입니다. `system`은 일부러 떠납니다. 이제 사용자가 자기 선호를 표현했기 때문입니다.

## 깜빡임 막기

React는 문서가 파싱된 뒤에 돕니다. effect에서 적용하는 테마는 한 번의 paint만큼 늦고, 사용자는 이미 틀린 쪽을 본 뒤입니다.

[`PlColorSchemeScript`](#plcolorschemescript)가 그 답이고, `<head>`에 들어갑니다.

```tsx
// app/layout.tsx
import { PlColorSchemeScript } from 'plass-ui';

export default function RootLayout({ children }) {
  return (
    <html suppressHydrationWarning>
      <head>
        <PlColorSchemeScript />
      </head>
      <body>{children}</body>
    </html>
  );
}
```

> `<html>`의 `suppressHydrationWarning`이 나머지 절반이고, 우회책이 아닙니다. 이 script가 하는 일이 바로 React가 hydrate하기 **전에** 그 element를 바꾸는 것이므로, 서버가 보내지 않은 속성을 React가 발견하는 것은 실패가 아니라 제대로 동작하고 있다는 뜻입니다.

`<script>` 말고는 아무것도 렌더링하지 않고, hook을 부르지 않고, context를 읽지 않으므로 **server component**로 남습니다. 이 라이브러리에서 그것이 가장 중요한 자리입니다 — 여기서 client component였다면 번들과 함께 도착하고, 정의상 이미 늦습니다.

| Prop            | 기본값                 |                                  |
| --------------- | ---------------------- | -------------------------------- |
| `storageKey`    | `'plass-color-scheme'` | hook의 것과 같아야 합니다        |
| `defaultScheme` | `'system'`             | hook의 것과 같아야 합니다        |
| `nonce`         | —                      | 엄격한 Content Security Policy용 |

## 무엇을 쓰는가

`<html>`에 `data-theme` 속성 **과** 클래스 둘 다입니다.

```html
<html data-theme="dark" class="dark"></html>
```

이중 안전장치가 아닙니다. 속성은 이 라이브러리의 토큰이 읽는 것이고, 클래스는 media query가 아니라 class 전략으로 설정된 사용자 자신의 Tailwind `dark:` utility가 읽는 것입니다. 하나만 옮기는 토글은 페이지를 절반만 바꿔 놓습니다.

`system`에서는 둘 다 지웁니다.

## Examples

### 세 갈래 컨트롤

```tsx
const { scheme, setScheme } = usePlColorScheme();

<PlSegmentedButton value={scheme} onValueChange={setScheme} aria-label="Theme">
  <PlSegment value="light">Light</PlSegment>
  <PlSegment value="dark">Dark</PlSegment>
  <PlSegment value="system">System</PlSegment>
</PlSegmentedButton>;
```

`system`을 제공하세요. 두 갈래 토글은 "내 컴퓨터가 말하는 대로"라고 할 수 있는 능력을 빼앗는데, 실제로 대부분이 원하는 설정이 그것입니다.

### 버튼 하나짜리 토글

```tsx
const { resolved, toggle } = usePlColorScheme();

<PlIconButton
  label={resolved === 'dark' ? 'Switch to light' : 'Switch to dark'}
  icon={resolved === 'dark' ? <SunIcon /> : <MoonIcon />}
  onClick={toggle}
/>;
```

label은 상태가 아니라 누르면 **무슨 일이 일어나는지**를 말합니다. "Dark"라고 적힌 버튼은 아무도 뜻을 짐작할 수 없는 버튼입니다.

## Notes

- **`storageKey`와 `defaultScheme`은 한 번만 읽습니다.** 그 key를 쓰는 첫 컴포넌트가 마운트될 때 읽고 그 뒤로는 무시합니다. 한 페이지의 토글 두 개가 서로 맞는 이유가 그것이고 — 저장소를 하나 공유합니다 — 계산해서 넘기는 prop이 아니라 앱을 세우는 자리에서 내리는 결정이라는 뜻이기도 합니다.
- 다른 탭에서 scheme을 바꾸면 이 탭도 바뀝니다. 사용자가 이 창이 아니라 자기 자신에 대해 내린 결정이기 때문입니다.
- 던지는 저장소 — sandbox된 frame, 사이트 데이터를 막아 둔 브라우저 — 는 잡습니다. 선택이 새로 고침을 넘기지 못할 뿐이고, 그것이 올바른 실패입니다.
- 스타일시트가 `color-scheme`도 설정하므로 브라우저 자신의 가구 — 스크롤바, 캐럿, 네이티브 `<select>` 팝업 — 도 페이지와 함께 바뀝니다. 옆에 흰 스크롤바가 있는 어두운 페이지는 테마가 입혀진 것이 아니라 고장 난 것처럼 보입니다.
- 이것은 theme API가 아닙니다. 색 자체는 CSS custom property이고, 그것을 바꾸는 자리는 [Colour](../design/color#overriding-a-family)입니다.
