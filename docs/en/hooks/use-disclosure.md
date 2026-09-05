---
title: usePlDisclosure
order: 6
---

# usePlDisclosure

<p class="plass-lede">One boolean and the four callbacks that change it. The smallest hook here and the one that saves the most typing, and the callbacks are stable, which is the reason it is a hook rather than a snippet.</p>

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

Hooks are React-only. In Flutter this is a `bool` field on a `State` and a `setState`, which is already the smallest it can be:

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

|           |                                                       |
| --------- | ----------------------------------------------------- |
| `initial` | Whether it starts open. `false` when it is not given. |
| returns   | The answer, and the four ways to change it.           |

It is also available from `plass-ui/hooks` for a project that wants the hooks without the barrel.

## Compared with `useState`

Because of what the alternative actually is. Written by hand this is a `useState` **plus three arrow functions that are new on every render**, and an inline `() => setOpen(false)` handed to a memoised trigger defeats the memo it was handed to.

Every callback here is stable for the life of the component, including `onToggle`, which uses the updater form rather than `!open`, so it does not have to change when the value does.

## The returned names

`onOpenChange` is the one shape every openable component in this library takes, and `setOpen` fits it exactly. So the ordinary use is not four handlers but two:

```tsx
const drawer = usePlDisclosure();

<PlIconButton icon={<MenuGlyph />} label="Menu" onClick={drawer.onToggle} />
<PlDrawer open={drawer.open} onOpenChange={drawer.setOpen}>…</PlDrawer>
```

## Notes

- It holds no DOM, watches nothing and has no effect in it, so it costs the same on a server as it does in a browser.
- Several of them in one component is the ordinary case, `usePlDisclosure()` per thing that opens, and they cost a `useState` each.
