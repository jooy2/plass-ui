import { DEFAULT_STORAGE_KEY, type PlColorScheme } from '../internal/color-scheme.js';

export interface PlColorSchemeScriptProps {
  /** Must match the hook's. @default 'plass-color-scheme' */
  storageKey?: string;
  /** What to apply when nothing has been stored. Must match the hook's. @default 'system' */
  defaultScheme?: PlColorScheme;
  /** The `nonce` a strict Content Security Policy requires on an inline script. */
  nonce?: string;
}

/**
 * The same three lines `applyColorScheme` runs, as text.
 *
 * It cannot import anything: this runs as an inline script in `<head>`, before
 * any bundle has been fetched, which is the entire point. Keeping it beside the
 * function it duplicates is the best that can be done — the two are checked
 * against each other in `test/hooks/usePlColorScheme.test.tsx`, which runs the
 * script's own text and then asserts the hook agrees with it.
 */
function inlineScript(storageKey: string, defaultScheme: PlColorScheme): string {
  return (
    `(function(){try{` +
    `var k=${JSON.stringify(storageKey)},d=${JSON.stringify(defaultScheme)};` +
    `var s=localStorage.getItem(k);` +
    `if(s!=="light"&&s!=="dark"&&s!=="system"){s=d}` +
    `var e=document.documentElement;` +
    `e.classList.remove("light","dark");` +
    `if(s==="system"){delete e.dataset.theme}else{e.dataset.theme=s;e.classList.add(s)}` +
    `}catch(_){}})()`
  );
}

/**
 * Paints the reader's chosen theme before the first frame.
 *
 * Put it in `<head>`, above everything. It reads the stored choice and writes
 * it onto `<html>` **synchronously**, while the parser is still in the head and
 * before any content has been laid out — which is the only moment at which the
 * white flash can be prevented. React runs long after that, so a theme applied
 * from an effect is applied one paint too late, and the reader has already seen
 * the wrong one.
 *
 * ```tsx
 * // app/layout.tsx
 * <html suppressHydrationWarning>
 *   <head>
 *     <PlColorSchemeScript />
 *   </head>
 *   <body>{children}</body>
 * </html>
 * ```
 *
 * `suppressHydrationWarning` on `<html>` is the other half, and it is not a
 * workaround: the script's whole job is to change that element before React
 * hydrates, so React finding an attribute the server did not send is the thing
 * working rather than failing.
 *
 * It renders nothing but a `<script>`, calls no hook and reads no context, so it
 * stays a server component — the one place in this library where that matters
 * most, since a client component here would arrive with the bundle and be too
 * late by definition.
 */
export function PlColorSchemeScript({
  storageKey = DEFAULT_STORAGE_KEY,
  defaultScheme = 'system',
  nonce
}: PlColorSchemeScriptProps) {
  return (
    <script
      nonce={nonce}
      // The content is assembled here from two JSON-encoded strings and nothing
      // else — there is no caller-supplied HTML anywhere in it.
      dangerouslySetInnerHTML={{ __html: inlineScript(storageKey, defaultScheme) }}
    />
  );
}
