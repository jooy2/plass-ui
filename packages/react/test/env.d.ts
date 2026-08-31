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
 * The same for `?raw`, which is the file's text before any transform at all.
 * `test/package` reads source files rather than importing them, because what
 * those tests assert is about the source rather than about what it evaluates
 * to — a directive at the top of a module, a union type with no runtime value.
 */
declare module '*?raw' {
  const source: string;
  export default source;
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

/**
 * The one custom browser command the suite registers, in `vitest.config.ts`.
 *
 * `prefers-reduced-motion` and `prefers-color-scheme` are the browser's answers
 * rather than the document's, so nothing inside the page can change them —
 * which would leave the hooks that read them testable only against whatever the
 * runner happened to be set to. Playwright can change them, and a command is
 * how a test reaches Playwright.
 */
declare module 'vitest/internal/browser' {
  interface BrowserCommands {
    emulateMedia: (options: {
      reducedMotion?: 'reduce' | 'no-preference' | null;
      colorScheme?: 'light' | 'dark' | 'no-preference' | null;
      forcedColors?: 'active' | 'none' | null;
    }) => Promise<void>;
  }
}
