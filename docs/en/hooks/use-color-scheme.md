---
title: usePlColorScheme
order: 5
---

# usePlColorScheme

<p class="plass-lede">The dark mode toggle, and what it takes to make one that does not flash. A page that only ever follows the platform needs none of this. The tokens already do that on their own.</p>

<Demo src="hooks/color-scheme" :min-height="260" />

::: fw react

```tsx
import { usePlColorScheme } from 'plass-ui';

const { scheme, resolved, setScheme, toggle } = usePlColorScheme();
```

:::

::: fw flutter

Hooks are React-only. Flutter pins a subtree with `PlassTheme`, and keeping the choice is the app's own storage:

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

`scheme` is what the reader chose and **`system` is the absence of a choice**, not a third theme: it hands the question back to `prefers-color-scheme`, so the page follows the platform again rather than being pinned to the platform's current answer. `resolved` is what the page is actually painted in.

`toggle` flips from whatever is **painted**, so the first press on a system-dark page gives light, which is what a reader pressing a toggle means. It leaves `system` behind, deliberately: they have now expressed a preference of their own.

## Preventing the flash

React runs after the document has been parsed. A theme applied from an effect is applied one paint too late, and the reader has already seen the wrong one.

`PlColorSchemeScript` is the answer, and it belongs in `<head>`:

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

> `suppressHydrationWarning` on `<html>` is the other half, and it is not a workaround. The script's whole job is to change that element before React hydrates, so React finding an attribute the server did not send is the thing working rather than failing.

It renders nothing but a `<script>`, calls no hook and reads no context, so it stays a **server component**, the one place in this library where that matters most, since a client component here would arrive with the bundle and be too late by definition.

| Prop            | Default                |                                      |
| --------------- | ---------------------- | ------------------------------------ |
| `storageKey`    | `'plass-color-scheme'` | Must match the hook's                |
| `defaultScheme` | `'system'`             | Must match the hook's                |
| `nonce`         | —                      | For a strict Content Security Policy |

## Where the preference is stored

Both the `data-theme` attribute **and** the class, on `<html>`:

```html
<html data-theme="dark" class="dark"></html>
```

Not as belt and braces. The attribute is what this library's tokens read; the class is what a consumer's own Tailwind `dark:` utilities read when they are configured against a class rather than the media query. A toggle that moved one and not the other would leave a page half switched.

On `system` it removes both.

## Examples

### A three-way control

```tsx
const { scheme, setScheme } = usePlColorScheme();

<PlSegmentedButton value={scheme} onValueChange={setScheme} aria-label="Theme">
  <PlSegment value="light">Light</PlSegment>
  <PlSegment value="dark">Dark</PlSegment>
  <PlSegment value="system">System</PlSegment>
</PlSegmentedButton>;
```

Offer `system`. A two-way toggle takes away the reader's ability to say "whatever my computer says", which is the setting most people actually want.

### A one-button toggle

```tsx
const { resolved, toggle } = usePlColorScheme();

<PlIconButton
  label={resolved === 'dark' ? 'Switch to light' : 'Switch to dark'}
  icon={resolved === 'dark' ? <SunIcon /> : <MoonIcon />}
  onClick={toggle}
/>;
```

The label says what the press **will do**, not what the state is. A button called "Dark" is one nobody can guess the meaning of.

## Notes

- **`storageKey` and `defaultScheme` are read once**, when the first component using that key mounts, and are ignored afterwards. That is what makes two toggles on one page agree with each other, they share one store, and it means both are decisions to make where the app is set up rather than props to compute.
- A second tab that changes the scheme changes this one too. The choice is one the reader made about themselves rather than about this window.
- Storage that throws (a sandboxed frame, a browser with site data blocked) is caught. The choice simply does not survive a reload, which is the right failure.
- The stylesheet also sets `color-scheme`, so the browser's own furniture (scrollbars, the caret, a native `<select>` popup) switches with the page. A dark page with a white scrollbar down the side looks broken rather than themed.
- This is not a theme API. The colours themselves are CSS custom properties, and the place to change those is [Colour](../design/color#overriding-a-family).
