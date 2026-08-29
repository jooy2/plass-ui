/**
 * Vite serves a `?inline` import as the transformed stylesheet's text rather
 * than as a side effect that adds a `<style>` to the page. `test/` does not
 * pull in `vite/client`, so the one form the suite uses is declared here.
 */
declare module '*.css?inline' {
  const css: string;
  export default css;
}

/**
 * `import.meta.glob` is Vite's, and `vite/client` is not in `types` for the
 * same reason: one form is used, so one form is declared. Narrowed to the
 * options `test/package/use-client.test.ts` passes — the raw text of every
 * match — rather than to Vite's full signature.
 */
interface ImportMeta {
  glob(
    pattern: string,
    options: { query: '?raw'; import: 'default'; eager: true }
  ): Record<string, string>;
}
