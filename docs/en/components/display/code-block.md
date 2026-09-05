---
title: PlCodeBlock
order: 22
---

# PlCodeBlock

<p class="plass-lede">A viewer for one line of code or a thousand — with a bar over it, numbers down the side, a prompt in front of every line, and twelve palettes to read it in.</p>

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

Everything it draws above the code is optional and off one prop each, because the same component has to be a snippet inside a sentence — no bar, no numbers, no chrome — and the full transcript at the top of a README.

## Props

<PropsTable name="PlCodeBlock" />

::: fw react

Every native `<div>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above, `title` and `prefix` because the component spells them itself, `children` because the code is `code`, and `onCopy` because the component's fires with the text rather than with an event.

:::

::: fw flutter

### PlCodeToken

<PropsTable name="PlCodeToken" />

`PlCodeTokenKind` is the twelve slots a theme declares: `comment`, `keyword`, `string`, `number`, `function`, `type`, `variable`, `tag`, `attribute`, `meta`, `addition` and `deletion`. A `PlCodeTheme` is those twelve plus a background and a foreground — the other five colours a block draws with are **derived** from those two, so a palette of your own is fourteen values rather than nineteen.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### theme

The palette is independent of the page's light and dark, except on `auto`. `dark` is the default and it is the one that is not a preference: code has been read on a dark ground since terminals, and a block that matched the page would be the one element on it whose colours were chosen by something other than the code.

<Demo src="code-block/themes" :min-height="360">

::: fw react

<<< @/.vitepress/demos/code-block/themes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/themes.dart

:::

</Demo>

Four are the house's — `dark`, `light`, `auto` and `mono`, which has no hue in it at all and carries the structure by weight instead. The other eight are ports kept at the hex they were published in: `one-dark`, `dracula`, `monokai`, `nord`, `night-owl`, `gruvbox`, `github` and `solarized-light`. A code block is the one component whose colours a reader already has an opinion about.

::: fw react

`theme` takes **any string**, which is how a project brings its own:

```css
[data-code-theme='ours'] {
  --p-code-bg: #101820;
  --p-code-fg: #e8e8e8;
  --p-code-keyword: #ff6b6b;
  /* …eleven more */
}
```

Sixteen slots, five of which are derived from the other two and need no declaration. Nothing to register and nothing to import.

:::

::: fw flutter

There is no stylesheet here, so a palette of your own is a `PlCodeTheme` handed to `customTheme` rather than a block of CSS:

```dart
PlCodeBlock(
  code: source,
  customTheme: const PlCodeTheme(
    background: Color(0xFF101820),
    foreground: Color(0xFFE8E8E8),
    keyword: Color(0xFFFF6B6B),
    // …eleven more
  ),
);
```

:::

### lineNumbers

Numbers down the side, starting wherever `startLine` says. `highlightLines` marks rows — a tint with a rule down the leading edge — and it counts the way the gutter counts, so a block that starts at 551 is marked with `'553-555'`.

<Demo src="code-block/lines" :min-height="300">

::: fw react

<<< @/.vitepress/demos/code-block/lines.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/lines.dart

:::

</Demo>

The mark's tint is mixed from the theme's own ink rather than from the page's colour family, so it is legible on all twelve palettes and is never the one colour on a Dracula block that nobody chose.

### prompt

A shell prompt in front of every line that has something on it. It is drawn but never **copied**: a `$` a reader pastes into their shell is a `$` their shell chokes on, so a transcript stays a transcript and still pastes.

<Demo src="code-block/terminal" :min-height="220">

::: fw react

<<< @/.vitepress/demos/code-block/terminal.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/terminal.dart

:::

</Demo>

Line numbers are the same: neither is a text node, and neither reaches the clipboard.

### Colouring

::: fw react

highlight.js, reached through a **dynamic import** — the grammars are forty kilobytes and there are thirty-five of them, so they arrive as their own chunk, one language at a time, and only for a block that asked to be coloured. With `highlight={false}` nothing is fetched at all.

The block draws plain on the first frame and colours itself when the grammar lands. `language` understands the common spellings and file extensions, so a value copied off a fenced code block works as-is: `ts`, `tsx`, `js`, `sh`, `yml`, `dart`, `py`, `rb`, `rs`, `md`.

A language nothing here knows is drawn plain rather than refused. Teach it one with `registerLanguage`:

```ts
import { registerLanguage } from 'plass-ui';
import elixir from 'highlight.js/lib/languages/elixir';

registerLanguage('elixir', elixir);
```

Call it at module scope. A language registered after a block has drawn does not repaint that block, but every block mounted after it sees it.

`rawToggle` puts a second button on the bar that drops the colouring and shows the characters as they are.

:::

::: fw flutter

**This build does not colour the code and the React one does.** That side reaches highlight.js through a dynamic import; this package has no dependencies, and a hand-written grammar for thirty-five languages is a promise it could not keep.

So a caller who has a highlighter hands the result in as `lines`, and a caller who does not gets the frame, the twelve palettes and the code drawn in one ink:

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

`rawToggle` then puts a second button on the bar that drops those runs back to one ink. With no `lines` there is nothing to drop and no button is drawn.

:::

### wrap and maxHeight

`wrap` folds long lines instead of scrolling them sideways; `maxHeight` bounds the block and scrolls the code inside it. They are separate answers to the same problem and both can be on.

```tsx
<PlCodeBlock code={source} language="ts" wrap maxHeight={280} />
```

Scrolled sideways, the gutter and the prompts stay put: the rows are as wide as the longest line rather than as wide as the window onto them, so every line's number starts at the same place.

## Accessibility

- The code is a **focusable region** with a name — the `title`, then the language, then the word for code. A scrollable region has to be reachable by a keyboard that has no pointer to drag with, and a focusable region has to have a name.
- <kbd>Mod</kbd> + <kbd>A</kbd> inside the block selects **the block**, not the page around it. The browser's own answer is never what a reader who tabbed to a code listing was after.
- The numbers and the prompts are outside the selection for the same reason they are outside the clipboard: there is nothing there to select.

::: fw react

- The copy button changes its own label, which a screen reader reading the page rather than the button would never hear, so the block also announces it through an `aria-live` region — one word long.
- The raw toggle carries `aria-pressed`.

:::

::: fw flutter

- Each bar button is a `Semantics` node with `button: true` and a name of its own, and it **excludes** what is inside it: the copy button draws its own word as well as carrying it, and a reader told "Copy, Copy" has been told once too often.

:::
