---
title: PlHotKeys
order: 3
---

# PlHotKeys

<p class="plass-lede">A keyboard key, a combination of them, or the four movement keys as they sit on the keyboard. <code>Mod</code> resolves to ⌘ on a Mac and Ctrl everywhere else.</p>

<Demo src="hot-keys/hero" :min-height="140" />

::: fw react

```tsx
import { PlHotKeys } from 'plass-ui';

<PlHotKeys keys="Mod+K" />;
<PlHotKeys cluster={{ up: 'W', left: 'A', down: 'S', right: 'D' }} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlHotKeys(keys: 'Mod+K');
const PlHotKeys(cluster: PlHotKeysCluster(up: 'W', left: 'A', down: 'S', right: 'D'));
```

:::

## Props

<PropsTable name="PlHotKeys" />

::: fw react

Every native `<span>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above, and `children` because the keys are `keys`.

:::

::: fw flutter

`keys` is typed `Object?`, which is Dart's way of writing a union it does not have: a `String` split on `+`, or a `List<String>` for the shortcut whose key _is_ a plus.

:::

### PlKbd

<PropsTable name="PlKbd" />

`PlKbd` is one cap. It is exported so a caller can compose a layout this component does not draw — a numeric keypad, a row of function keys — out of the same object the shortcut strip is made of.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### Mod, and os

`Mod` is the token the rest exist for. It is the only one whose **meaning** changes with the platform rather than just its spelling: the modifier shortcuts are built on, which is Command on a Mac and Control everywhere else. A page that writes `Ctrl+K` is wrong for every Mac reader, and one that writes `⌘K` is wrong for everybody else.

`os` defaults to `auto`, which asks the platform. Name one explicitly only when the page has to — a support article about the Windows build, a table comparing the two.

::: fw flutter

`auto` reads `defaultTargetPlatform`, so a `debugDefaultTargetPlatformOverride` in a test or a preview moves it. Android and Fuchsia resolve to the Linux spelling, which is what a physical keyboard attached to either of them is printed with.

:::

Aliases are accepted throughout: `Cmd`, `Command`, `Meta` and `Super` are names one key already has, and a component that took only one of them is a component every caller has to look up.

<Demo src="hot-keys/os" :min-height="220">

::: fw react

<<< @/.vitepress/demos/hot-keys/os.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/hot_keys/os.dart

:::

</Demo>

### variant

`glass` is the default: a hairline box, which is what a key cap has looked like in every printed manual. All three carry a two-pixel lip under them — the one place in the library a surface gets a hard-edged shadow directly beneath it, because that is the mark that means "this is a key you press". A _picture_ of a key is allowed to look like a key; a control is not allowed to look like a picture of one.

<Demo src="hot-keys/variants" :min-height="100">

::: fw react

<<< @/.vitepress/demos/hot-keys/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/hot_keys/variants.dart

:::

</Demo>

### cluster

The four movement keys drawn as an inverted T. It is its own prop rather than a layout option on `keys`, because the two are different objects: a combo is keys pressed _together_, and a cluster is four keys pressed one at a time whose arrangement on the keyboard is the point.

<Demo src="hot-keys/cluster" :min-height="160">

::: fw react

<<< @/.vitepress/demos/hot-keys/cluster.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/hot_keys/cluster.dart

:::

</Demo>

### size

A cap sits one step down the control ladder — an `md` cap is 32px, not 40px. It is a token inside a line of text, not a control the line lines up against.

<Demo src="hot-keys/sizes" :min-height="100">

::: fw react

<<< @/.vitepress/demos/hot-keys/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/hot_keys/sizes.dart

:::

</Demo>

::: fw react

### In a list

:::

<Demo src="hot-keys/list" :min-height="280">

<<< @/.vitepress/demos/hot-keys/list.tsx

</Demo>

## Accessibility

::: fw react

- Each key is a real `<kbd>`. The wrapper is a `<span>` — nesting `<kbd>` inside `<kbd>` is legal and would also be defensible, but a second `kbd` box is one more thing for a host stylesheet to reach into, for no gain.
- `⌘` is not a word: a screen reader announces the character as "place of interest sign". Every key drawn as a glyph carries its real name beside it in a visually hidden box, so `Mod+K` on a Mac is announced as "Command K".
- The separator is `aria-hidden`, so a shortcut is read as its keys rather than as "Ctrl plus K".
- The platform is resolved through `useSyncExternalStore`, which is the one API that tells React the server's answer and the browser's are _meant_ to differ. A server-rendered page hydrates with `Ctrl` and re-renders to `⌘` on a Mac, rather than logging a hydration mismatch.
- This component **displays** a shortcut; it does not bind one. What happens when the keys are pressed is the caller's.

:::

::: fw flutter

- `⌘` is not a word: a screen reader announces the character as "place of interest sign". Every key drawn as a glyph is announced by its real name instead, so `Mod+K` on a Mac is read as "Command K".
- The separator is excluded from semantics, so a shortcut is read as its keys rather than as "Ctrl plus K".
- There is no hydration to get wrong: the platform is read at build time and the right cap is the only one ever drawn.
- This component **displays** a shortcut; it does not bind one. Binding is a `Shortcuts` widget of your own, and what happens when the keys are pressed is the caller's.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| a real `<kbd>` | a drawn cap | Flutter has no `kbd`. What the element bought — "these characters are keys" — is carried by the name each glyph key announces instead. |
| `useSyncExternalStore` | `defaultTargetPlatform` | There is no server render to reconcile with. The platform is known before the first frame. |
| `os="linux"` for everything else | Android and Fuchsia too | A physical keyboard attached to either is printed the way a Linux one is. |
| `keys` as `string \| string[]` | `Object?` | Dart has no union type; the split-on-`+` and the list form are both still there. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
