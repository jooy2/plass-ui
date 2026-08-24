---
title: PlHotKeys
order: 3
---

# PlHotKeys

<p class="plass-lede">A keyboard key, a combination of them, or the four movement keys as they sit on the keyboard. <code>Mod</code> resolves to ⌘ on a Mac and Ctrl everywhere else.</p>

<Demo src="hot-keys/hero" :min-height="140" />

```tsx
import { PlHotKeys } from 'plass-ui';

<PlHotKeys keys="Mod+K" />;
<PlHotKeys cluster={{ up: 'W', left: 'A', down: 'S', right: 'D' }} />;
```

## Props

<PropsTable name="PlHotKeys" />

Every native `<span>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above, and `children` because the keys are `keys`.

### PlKbd

<PropsTable name="PlKbd" />

`PlKbd` is one cap. It is exported so a caller can compose a layout this component does not draw — a numeric keypad, a row of function keys — out of the same object the shortcut strip is made of.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### Mod, and os

`Mod` is the token the rest exist for. It is the only one whose **meaning** changes with the platform rather than just its spelling: the modifier shortcuts are built on, which is Command on a Mac and Control everywhere else. A page that writes `Ctrl+K` is wrong for every Mac reader, and one that writes `⌘K` is wrong for everybody else.

`os` defaults to `auto`, which asks the browser. Name a platform explicitly only when the page has to — a support article about the Windows build, a table comparing the two.

Aliases are accepted throughout: `Cmd`, `Command`, `Meta` and `Super` are names one key already has, and a component that took only one of them is a component every caller has to look up.

<Demo src="hot-keys/os" :min-height="220">

<<< @/.vitepress/demos/hot-keys/os.tsx

</Demo>

### variant

`glass` is the default: a hairline box, which is what a key cap has looked like in every printed manual. All three carry a two-pixel lip under them — the one place in the library a surface gets a hard-edged shadow directly beneath it, because that is the mark that means "this is a key you press". A _picture_ of a key is allowed to look like a key; a control is not allowed to look like a picture of one.

<Demo src="hot-keys/variants" :min-height="100">

<<< @/.vitepress/demos/hot-keys/variants.tsx

</Demo>

### cluster

The four movement keys drawn as an inverted T. It is its own prop rather than a layout option on `keys`, because the two are different objects: a combo is keys pressed _together_, and a cluster is four keys pressed one at a time whose arrangement on the keyboard is the point.

<Demo src="hot-keys/cluster" :min-height="160">

<<< @/.vitepress/demos/hot-keys/cluster.tsx

</Demo>

### size

A cap sits one step down the control ladder — `size="md"` draws a 32px cap, not a 40px one. It is a token inside a line of text, not a control the line lines up against.

<Demo src="hot-keys/sizes" :min-height="100">

<<< @/.vitepress/demos/hot-keys/sizes.tsx

</Demo>

### In a list

<Demo src="hot-keys/list" :min-height="280">

<<< @/.vitepress/demos/hot-keys/list.tsx

</Demo>

## Accessibility

- Each key is a real `<kbd>`. The wrapper is a `<span>` — nesting `<kbd>` inside `<kbd>` is legal and would also be defensible, but a second `kbd` box is one more thing for a host stylesheet to reach into, for no gain.
- `⌘` is not a word: a screen reader announces the character as "place of interest sign". Every key drawn as a glyph carries its real name beside it in a visually hidden box, so `Mod+K` on a Mac is announced as "Command K".
- The separator is `aria-hidden`, so a shortcut is read as its keys rather than as "Ctrl plus K".
- The platform is resolved through `useSyncExternalStore`, which is the one API that tells React the server's answer and the browser's are _meant_ to differ. A server-rendered page hydrates with `Ctrl` and re-renders to `⌘` on a Mac, rather than logging a hydration mismatch.
- This component **displays** a shortcut; it does not bind one. What happens when the keys are pressed is the caller's.
