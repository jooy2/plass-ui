---
title: usePlDisclosure
order: 6
---

# usePlDisclosure

<p class="plass-lede">불리언 하나와 그것을 바꾸는 콜백 넷입니다. 여기서 가장 작은 훅이자 타이핑을 가장 많이 줄여 주는 훅이고, 콜백이 안정적이라는 것이 스니펫이 아니라 훅인 이유입니다.</p>

<Demo src="hooks/disclosure" :min-height="160" :flutter="false" />

::: fw react

```tsx
import { usePlDisclosure } from 'plass-ui';

const dialog = usePlDisclosure();

<PlButton onClick={dialog.onOpen}>Delete</PlButton>
<PlModal open={dialog.open} onOpenChange={dialog.setOpen} title="Delete this?" />
```

:::

::: fw flutter

훅은 React 전용입니다. Flutter에서는 `State`의 `bool` 필드와 `setState`이고, 이미 그보다 작아질 수 없습니다.

```dart
bool _open = false;

void _openDialog() => setState(() => _open = true);
```

:::

## Signature

```ts
function usePlDisclosure(initial?: boolean): {
  open: boolean;
  onOpen: () => void;
  onClose: () => void;
  onToggle: () => void;
  setOpen: (open: boolean) => void;
};
```

|           |                                                |
| --------- | ---------------------------------------------- |
| `initial` | 열린 채로 시작할지. 주지 않으면 `false`입니다. |
| returns   | 답과, 그것을 바꾸는 네 가지 방법.              |

barrel 없이 훅만 쓰고 싶은 프로젝트를 위해 `plass-ui/hooks`에서도 가져올 수 있습니다.

## `useState`와의 차이

대안이 실제로 무엇인지 때문입니다. 손으로 쓰면 `useState`에 **매 렌더링마다 새로 만들어지는 화살표 함수 셋**이 붙고, memo된 트리거에 건넨 인라인 `() => setOpen(false)`는 그 memo를 무력화합니다.

여기의 모든 콜백은 컴포넌트가 사는 동안 그대로입니다. `onToggle`도 그렇습니다. `!open`이 아니라 updater 형태를 쓰므로 값이 바뀌어도 콜백이 바뀌지 않습니다.

## 돌려주는 이름

`onOpenChange`는 이 라이브러리에서 열리는 모든 컴포넌트가 받는 하나의 모양이고, `setOpen`이 정확히 거기 들어맞습니다. 그래서 보통은 핸들러 넷이 아니라 둘입니다.

```tsx
const drawer = usePlDisclosure();

<PlIconButton icon={<MenuGlyph />} label="Menu" onClick={drawer.onToggle} />
<PlDrawer open={drawer.open} onOpenChange={drawer.setOpen}>…</PlDrawer>
```

## Notes

- DOM을 쥐지 않고 아무것도 지켜보지 않으며 effect도 없습니다. 그래서 서버에서도 브라우저와 같은 값만 듭니다.
- 한 컴포넌트에 여러 개를 두는 것이 보통입니다. 열리는 것마다 `usePlDisclosure()` 하나씩이고, 각각 `useState` 하나만큼 듭니다.
