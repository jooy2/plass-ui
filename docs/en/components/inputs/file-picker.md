---
title: PlFilePicker
order: 9
---

# PlFilePicker

<p class="plass-lede">A box files are chosen into. It checks what arrives against <code>accept</code>, <code>maxSize</code> and <code>maxFiles</code>, and tells you about everything it turned away.</p>

<Demo src="file-picker/hero" :min-height="260" />

::: fw react

```tsx
import { PlFilePicker } from 'plass-ui';

<PlFilePicker label="Attachments" multiple maxFiles={4} value={files} onFilesChange={setFiles} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlFilePicker(
  label: const Text('Attachments'),
  multiple: true,
  maxFiles: 4,
  value: files,
  onBrowse: () async => myPickerPlugin.pick(),
  onFilesChanged: (List<PlFile> next) => setState(() => files = next),
);
```

**The picker does not pick.** This package has no dependencies, and reaching the file system is a plugin's job in every Flutter app that does it, so `onBrowse` is where the app's own picker runs. What the component owns is everything after that: the rules, the list, the removal, and the box itself.

:::

## Props

<PropsTable name="PlFilePicker" />

::: fw react

Every native `<div>` attribute passes straight through to the wrapper. `color`, `defaultValue`, `title` and `children` are excluded because all four are Plass props here.

`formatFileSize` is exported alongside the component, so a caller writing their own list can print sizes in the same units.

:::

::: fw flutter

**Controlled**: `value` and `onFilesChanged` are how a picker is driven, always.

### PlFile

<PropsTable name="PlFile" />

A `PlFile` is deliberately **not** a `dart:io` `File` and not an abstraction over one. What the box draws is a name and a size, and what its rules read is a name, a size and a kind, so that is what it asks for; `source` carries the app's own object through untouched, so the caller gets it back on the other side.

`readableSize` prints `1.4 MB` in the units a person reading a file list expects, and `matches` is the `accept` check, so a caller writing their own list can use both.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

All three take a **dashed** edge, and it is the one place the library draws a line that is not solid. It is not decoration: a dashed rectangle is the established sign for "this area accepts a drop", and a dropzone that looks like a `PlCard` is a `PlCard` nobody tries to drop on.

The edge is neutral at rest and takes the colour family only once the pointer is on it. The same arrangement a `glass` `PlButton` has.

<Demo src="file-picker/variants" :min-height="200">

::: fw react

<<< @/.vitepress/demos/file-picker/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/file_picker/variants.dart

:::

</Demo>

### accept · maxSize · maxFiles

<Fw react="`accept` is set on the input **and** applied to drops. The browser enforces the attribute on its own dialog and on nothing else, so a dropzone that only sets it accepts anything the moment a file arrives by drag." flutter="`accept` is applied to whatever `onBrowse` hands back, whether or not the plugin that found it was told the same thing. A rule the component states and does not enforce is not a rule." />

`maxFiles` is counted against what is already held rather than against one drop. The difference between "you may drop five files" and "you may end up with five files", and only the second is what the prop means.

<Fw react="onReject" flutter="onRejected" code /> is where a refusal goes. Without it a rejected file disappears silently, which is the single worst thing a dropzone does.

<Demo src="file-picker/rejections" :min-height="280">

::: fw react

<<< @/.vitepress/demos/file-picker/rejections.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/file_picker/rejections.dart

:::

</Demo>

### One file at a time

Without `multiple` the box holds exactly one file, and a new one replaces it rather than being turned away for `count`. That is what an avatar picker wants.

<Demo src="file-picker/single" :min-height="240">

::: fw react

<<< @/.vitepress/demos/file-picker/single.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/file_picker/single.dart

:::

</Demo>

### size

Moves the box's padding and the text inside it. The padding has its own ladder rather than the sheet's, because a dropzone is sized by the gesture it has to catch: a target the height of one line of text is a target you miss.

<Demo src="file-picker/sizes" :min-height="420">

::: fw react

<<< @/.vitepress/demos/file-picker/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/file_picker/sizes.dart

:::

</Demo>

### disabled · error

<Demo src="file-picker/states" :min-height="220">

::: fw react

<<< @/.vitepress/demos/file-picker/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/file_picker/states.dart

:::

</Demo>

## Accessibility

::: fw react

- The pressable area is a real `<button>`, so it is in the tab order and answers <kbd>Enter</kbd> and <kbd>Space</kbd>. Drag-and-drop is an addition to that, never the only way in.
- The `<input type="file">` stays in the DOM, clipped off-screen rather than `display: none`. The latter is unfocusable in some browsers and would take the input out of native form validation.
- `description` and `error` are wired to the button with `aria-describedby`; the error also sets `aria-invalid`.
- The file list is a real `<ul>` outside the browse button, because a remove button cannot be nested inside another button.
- Each remove button carries an accessible name that includes the file it removes, so a screen reader hears three different buttons rather than three called "Remove".
- The zone does not move under the pointer while a file is over it. Colour and edge change; nothing grows or lifts, because a target that moves while you are aiming at it is a target you miss.

:::

::: fw flutter

- The box is announced as a button, so it is in the focus order and answers <kbd>Enter</kbd> and <kbd>Space</kbd>. Whatever drop handling an app adds is an addition to that, never the only way in.
- The file list is outside the box, because a remove button inside a button is a press that fires twice.
- Each remove button carries a name that includes the file it removes, so a screen reader hears three different buttons rather than three called "Remove".
- The box does not move while a file is over it. Colour and edge change; nothing grows or lifts, because a target that moves while you are aiming at it is a target you miss.
- `error` re-points the whole family at `danger`, so the edge, the ring and the message all turn over together.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| opens the file dialog itself | `onBrowse` runs the app's picker | There is no file dialog in Flutter without a plugin, and this package has no dependencies. The rules stay here; the picker is the app's. |
| drag and drop | `dragging`, which the app sets | There is no OS-level drag either. The look of the state is the component's; the detection is the app's. |
| `File` | `PlFile` | A name, a size, a kind and the app's own object carried through. The package opens nothing. |
| `formatFileSize`, exported | `PlFile.readableSize` | The same number, on the thing that has it. |
| `value` / `defaultValue` / `onFilesChange` | `value` / `onFilesChanged` | Flutter's own controls are controlled, and its name for the callback. |
| `icon={null}` | `showIcon: false` | Dart has no value that is neither `null` nor a widget, so "take it away" gets its own name. |
| the hidden input, `name`, `required` | — | There is no native form submission to be part of. |
| `id`, `aria-describedby`, `aria-invalid` | — | Nothing points at anything by id here; the label and the messages are part of the component. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

:::
