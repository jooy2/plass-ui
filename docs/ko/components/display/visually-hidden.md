---
title: PlVisuallyHidden
order: 16
---

# PlVisuallyHidden

<p class="plass-lede">스크린 리더에게만 주는 내용입니다. accessibility tree에는 남고 화면에서는 자리를 차지하지 않으므로, 글리프 하나만 그리는 컨트롤에 이름을 붙이는 올바른 방법입니다.</p>

<Demo src="visually-hidden/hero" :min-height="200" />

::: fw react

```tsx
import { PlVisuallyHidden } from 'plass-ui';

<button type="button">
  <span aria-hidden="true">✕</span>
  <PlVisuallyHidden>Close</PlVisuallyHidden>
</button>;
```

:::

::: fw flutter

이것은 React 전용이고, 빠뜨린 것이 아닙니다. 이 컴포넌트가 우회하는 것은 DOM의 문제(텍스트가 accessibility tree에는 있으면서 화면에는 없어야 한다는 것) 인데, Flutter의 트리는 render tree가 아닙니다. Dart 쪽 답은 `Semantics`입니다.

```dart
Semantics(
  label: 'Close',
  child: ExcludeSemantics(child: Text('✕')),
);
```

:::

## Props

<PropsTable name="PlVisuallyHidden" />

::: fw react

네이티브 `<span>` 속성은 `aria-live`와 `id`를 포함해 그대로 통과합니다. `variant`도 `size`도 `color`도 없습니다. 그리는 것이 없으니 그것들이 정할 것도 없습니다.

:::

공유 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## Examples

### 글리프만 그리는 컨트롤에 이름 붙이기

가장 흔한 쓰임이자, 이것이 고치는 결함입니다. label이 전부 아이콘인 버튼은 accessible name이 아예 없습니다. 글리프에는 `aria-hidden`을 붙여 두 번째 이름으로 읽히지 않게 합니다.

<Demo src="visually-hidden/naming" :min-height="160">

::: fw react

<<< @/.vitepress/demos/visually-hidden/naming.tsx

:::

</Demo>

### focusable

안쪽 어딘가가 focus를 쥐고 있는 동안 내용을 페이지로 되돌립니다. 문서에서 그런 element는 하나(skip link) 뿐이고, 바깥에서는 만들 수 없습니다. clip이 `position: absolute`라서, 되돌린다는 것은 element를 flow에 다시 넣는다는 뜻이기 때문입니다.

`:focus`가 아니라 `:focus-within`에 답합니다. Tab이 닿는 것은 거의 언제나 상자 자신이 아니라 상자 **안의** 링크이기 때문입니다.

<Demo src="visually-hidden/focusable" :min-height="160">

::: fw react

<<< @/.vitepress/demos/visually-hidden/focusable.tsx

:::

</Demo>

> 드러난 상자는 `position: static`이 되어 자기 자리를 되찾습니다. 그것을 받아 줄 수 있는 곳에 두세요. positioned 조상, 아니면 페이지 맨 위. skip link가 원래 있어야 할 자리이기도 합니다.

### live region

그릴 것이 없는 알림입니다. 숨은 element 위의 `aria-live`는, 화면에서는 뻔한 변화(숫자가 올라가고, 필터가 목록을 좁히는 것)를 그것을 볼 수 없는 사람에게 전하는 방법입니다.

<Demo src="visually-hidden/live" :min-height="180">

::: fw react

<<< @/.vitepress/demos/visually-hidden/live.tsx

:::

</Demo>

### render

`<span>` 대신 다른 것을 렌더링합니다. 디자인에는 나타나지 않으면서 스크린 리더에게 페이지 구조를 만들어 주는 heading이나, live region이 원하는 `<div>` 같은 것입니다.

```tsx
<PlVisuallyHidden render={<h2 />}>Search results</PlVisuallyHidden>
```

## Accessibility

- 내용은 accessibility tree **안에** 있습니다. `hidden`, `display: none`, `visibility: hidden`은 모두 그것을 트리에서 빼 버리고, `opacity: 0`은 글자 크기만 한 클릭 가능한 유령을 남깁니다. 1px로 clip된 상자만이 보는 사람에게는 없고 다른 모든 종류의 독자에게는 있는 유일한 형태입니다.
- 자기 자신에게 `aria-hidden`을 붙이지 않으며, 거기에 하나 붙이면 컴포넌트가 통째로 무의미해집니다.
- 안의 텍스트는 페이지 내 찾기에 여전히 걸리고 전체 선택에도 여전히 복사됩니다. 플랫폼의 동작이고, 우회할 것이 아닙니다.
- 같은 컨트롤에 숨은 이름과 보이는 이름이 함께 있으면 이름이 **둘**이 됩니다. 옆의 글리프에 `aria-hidden="true"`를 붙이세요.
