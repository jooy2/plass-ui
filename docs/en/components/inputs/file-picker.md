---
title: PlFilePicker
order: 9
---

# PlFilePicker

<p class="plass-lede">A box you drop files on, or click to open the file dialog. It checks what arrives against <code>accept</code>, <code>maxSize</code> and <code>maxFiles</code>, and tells you about everything it turned away.</p>

<Demo src="file-picker/hero" :min-height="260" />

```tsx
import { PlFilePicker } from 'plass-ui';

<PlFilePicker label="Attachments" multiple maxFiles={4} value={files} onFilesChange={setFiles} />;
```

## Props

<PropsTable name="PlFilePicker" />

Every native `<div>` attribute passes straight through to the wrapper. `color`, `defaultValue`, `title` and `children` are excluded because all four are Plass props here.

`formatFileSize` is exported alongside the component, so a caller writing their own list can print sizes in the same units.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

All three take a **dashed** edge, and it is the one place the library draws a line that is not solid. It is not decoration: a dashed rectangle is the established sign for "this area accepts a drop", and a dropzone that looks like a `PlCard` is a `PlCard` nobody tries to drop on.

The edge is neutral at rest and takes the colour family only once the pointer is on it — the same arrangement a `glass` `PlButton` has.

<Demo src="file-picker/variants" :min-height="200">

<<< @/.vitepress/demos/file-picker/variants.tsx

</Demo>

### accept · maxSize · maxFiles

`accept` is set on the input **and** applied to drops. The browser enforces the attribute on its own dialog and on nothing else, so a dropzone that only sets it accepts anything the moment a file arrives by drag.

`maxFiles` is counted against what is already held rather than against one drop — the difference between "you may drop five files" and "you may end up with five files", and only the second is what the prop means.

`onReject` is where a refusal goes. Without it a rejected file disappears silently, which is the single worst thing a dropzone does.

<Demo src="file-picker/rejections" :min-height="280">

<<< @/.vitepress/demos/file-picker/rejections.tsx

</Demo>

### One file at a time

Without `multiple` the box holds exactly one file, and a new one replaces it rather than being turned away for `count`. That is what an avatar picker wants.

<Demo src="file-picker/single" :min-height="240">

<<< @/.vitepress/demos/file-picker/single.tsx

</Demo>

### size

Moves the box's padding and the text inside it. The padding has its own ladder rather than the sheet's, because a dropzone is sized by the gesture it has to catch: a target the height of one line of text is a target you miss.

<Demo src="file-picker/sizes" :min-height="420">

<<< @/.vitepress/demos/file-picker/sizes.tsx

</Demo>

### disabled · error

<Demo src="file-picker/states" :min-height="220">

<<< @/.vitepress/demos/file-picker/states.tsx

</Demo>

## Accessibility

- The pressable area is a real `<button>`, so it is in the tab order and answers <kbd>Enter</kbd> and <kbd>Space</kbd>. Drag-and-drop is an addition to that, never the only way in.
- The `<input type="file">` stays in the DOM, clipped off-screen rather than `display: none` — the latter is unfocusable in some browsers and would take the input out of native form validation.
- `description` and `error` are wired to the button with `aria-describedby`; the error also sets `aria-invalid`.
- The file list is a real `<ul>` outside the browse button, because a remove button cannot be nested inside another button.
- Each remove button carries an accessible name that includes the file it removes, so a screen reader hears three different buttons rather than three called "Remove".
- The zone does not move under the pointer while a file is over it. Colour and edge change; nothing grows or lifts, because a target that moves while you are aiming at it is a target you miss.
