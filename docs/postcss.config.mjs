/**
 * Tailwind, for the docs' own Vite pipeline.
 *
 * The site renders the real components, and their class names are Tailwind
 * utilities — so the pass that compiles the docs' CSS has to be a Tailwind
 * pass. Which files it scans is not decided here: `@source '.'` inside
 * `packages/react/src/styles.css` registers the components' own folder, relative
 * to itself.
 *
 * Vite looks for this file at its root, which for VitePress is this directory.
 */
const config = {
  plugins: {
    '@tailwindcss/postcss': {}
  }
};

export default config;
