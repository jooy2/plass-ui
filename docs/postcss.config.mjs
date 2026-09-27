/**
 * PostCSS for the docs' own Vite pipeline. Vite looks for this file at its
 * root, which for VitePress is this directory.
 *
 * Tailwind comes first. The site renders the real components, and their class
 * names are Tailwind utilities, so the pass that compiles the docs' CSS has to
 * be a Tailwind pass. Which files it scans is not decided here: `@source '.'`
 * inside `packages/react/src/styles.css` registers the components' own folder,
 * relative to itself.
 *
 * VitePress's `postcssIsolateStyles` keeps the article typography out of the
 * live previews. A preview is rendered inside the Markdown, so every rule in
 * `vp-doc.css` reaches the elements a demo draws: `.vp-doc h2` gives a demo's
 * heading the page's size, its rule and 24px of padding, `.vp-doc p` gives a
 * paragraph the page's margin, and each of them is a class and a type, which
 * outranks the one-class utilities the demo sets. The plugin rewrites every
 * selector in that one file to skip `.plass-scope`, the element each preview
 * mounts into, and everything inside it. The `:not(:where(…))` it appends has
 * no specificity, so the docs' own headings, paragraphs and lists match exactly
 * as they did.
 *
 * The prefix names `.plass-scope` rather than VitePress's own `vp-raw` class,
 * because `vp-raw` also takes the links inside it away from VitePress's router,
 * and that is not what this is for. `base.css`, the file the plugin isolates
 * when it is given none, is left alone: it is VitePress's global reset, the
 * Preflight a preview is drawn on, and `theme/styles/scope.css` finishes it.
 */
import tailwind from '@tailwindcss/postcss';
import { postcssIsolateStyles } from 'vitepress';

const config = {
  plugins: [
    tailwind(),
    postcssIsolateStyles({
      includeFiles: [/vp-doc\.css/],
      prefix: ':not(:where(.plass-scope, .plass-scope *))'
    })
  ]
};

export default config;
