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
 * `value` as a JavaScript string literal that is safe inside a `<script>`.
 *
 * `JSON.stringify` leaves `<` alone, so a storage key built from something the
 * page does not control — a tenant's slug, a path segment — could carry a
 * `</script>` that closes the element and puts whatever follows into the
 * document as markup. The three characters HTML reads and the two line
 * separators older engines reject in a string literal are written as escapes,
 * which JavaScript reads back as the same characters.
 */
function scriptString(value: string): string {
  return JSON.stringify(value).replace(
    /[<>&\u2028\u2029]/g,
    (character) => `\\u${character.charCodeAt(0).toString(16).padStart(4, '0')}`
  );
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
    `var k=${scriptString(storageKey)},d=${scriptString(defaultScheme)};` +
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
      // The content is assembled here from two string literals, escaped for a
      // `<script>`, and nothing else — no caller-supplied HTML reaches it.
      dangerouslySetInnerHTML={{ __html: inlineScript(storageKey, defaultScheme) }}
    />
  );
}
