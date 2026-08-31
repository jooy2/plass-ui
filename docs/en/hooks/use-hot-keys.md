---
title: usePlHotKeys
order: 4
---

# usePlHotKeys

<p class="plass-lede">Keyboard chords bound outside any one control. The same vocabulary <code>PlHotKeys</code> draws and a field's <code>hotKeys</code> prop binds, so a shortcut that is displayed and a shortcut that works are one string rather than two that drift.</p>

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

Hooks are React-only. Flutter binds a chord with the framework's own `Shortcuts` and `Actions`, or a `CallbackShortcuts` for the short version:

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

| Option        | Default  |                                                                     |
| ------------- | -------- | ------------------------------------------------------------------- |
| `enabled`     | `true`   | Whether the chords are bound at all                                 |
| `target`      | `window` | What the listener is attached to — an element, a ref, or `document` |
| `whileTyping` | `false`  | Whether a chord is answered while the focus is in a text field      |

Chords are written the way [`PlHotKeys`](../components/display/hot-keys) writes them, so `Mod` is Command on a Mac and Control everywhere else, and `Esc`, `Return`, `Cmd` and `Option` fold onto the same keys their caps do.

## The rules

Three of them, shared with the `hotKeys` prop on a field:

- **A modifier is checked in both directions.** `Enter` does not fire on `Shift+Enter`, and `Mod+K` does not fire on `Mod+Shift+K`. That is the difference between binding a shortcut and binding a key.
- **A chord that matches is consumed.** `preventDefault()`, so the browser's own `Mod+K` search bar does not also open. Read from the other end, an event that is **already** consumed is left alone — a field's own `hotKeys` map wins over a page's.
- **These are chords rather than letters.** A single unmodified key is allowed and is sometimes right, and that is what `whileTyping` is about.

### whileTyping

Off by default: a global <kbd>/</kbd> that jumps to search must not eat the slash out of a URL somebody is typing into a form.

It is narrower than it sounds, and only two kinds of chord are ever held back:

| Chord | In a field |
| --- | --- |
| `Mod+K`, `Ctrl+B`, `Alt+Enter` | **Answered.** None of those modifiers can appear in a field's value |
| `Escape`, `F2` | **Answered.** Neither does anything to what is being typed |
| `Shift+A` | Held back — that is how a capital A is typed |
| `/`, `Enter`, `Backspace`, an arrow | Held back |

So the ordinary case needs nothing set. Turn it on for a chord that belongs to the field the reader is in.

## Examples

### An application's shortcuts

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

The map may be written inline. The handlers are read fresh on every keystroke, so a handler closing over current state is never stale, and what re-attaches the listener is the **set of chords** changing rather than the map's identity.

### Displayed and bound from one string

```tsx
const SHORTCUTS = { 'Mod+S': save, 'Mod+Enter': submit };

usePlHotKeys(SHORTCUTS);

return Object.keys(SHORTCUTS).map((chord) => <PlHotKeys key={chord} keys={chord} />);
```

The cap on the screen cannot claim a key nothing is bound to, because there is only one place the key is written.

### Scoped to a region

```tsx
const panel = useRef<HTMLDivElement>(null);

usePlHotKeys({ Escape: close }, { target: panel });
```

> A `keydown` only reaches an element that contains the focus. Scoping to a panel nobody has tabbed into binds nothing — which is usually what "scoped" was meant to mean, but is worth knowing before it looks like a bug.

### Turned off with the screen it belongs to

```tsx
usePlHotKeys({ Escape: close }, { enabled: open });
```

`enabled: false` removes the listener rather than muting the handler, so a shortcut that is off does not consume the key from whatever else wanted it.

## Accessibility

- A shortcut is an accelerator, never the only way to do something. Everything bound here must also be reachable by tabbing to a control.
- Show the chord. `PlHotKeys` draws it, `PlMenuItem` and `PlCommandPalette` have a slot for it, and a shortcut nobody can see is one nobody uses.
- Single-key shortcuts are a documented hazard in [WCAG 2.1 SC 2.1.4](https://www.w3.org/WAI/WCAG21/Understanding/character-key-shortcuts.html) — speech input triggers them by accident. The default `whileTyping: false` covers the worst of it; offering a way to turn them off entirely is the rest, and `enabled` is how.
