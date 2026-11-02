import { fileURLToPath } from 'node:url';
import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';

const installed = (path: string) =>
  fileURLToPath(new URL(`node_modules/plass-ui/dist/${path}`, import.meta.url));

export default defineConfig({
  // Relative, so the built page loads under `plass://` and from `file://` alike.
  base: './',
  plugins: [react(), tailwindcss()],
  resolve: {
    // The demos live in `docs/`, outside this package, so they resolve the
    // library and React from here rather than from wherever they sit.
    alias: [
      { find: /^plass-ui$/, replacement: installed('index.js') },
      { find: /^plass-ui\/locales$/, replacement: installed('locales/index.js') }
    ],
    dedupe: ['react', 'react-dom']
  },
  server: { port: 5280, strictPort: true, fs: { allow: ['../..'] } },
  build: { outDir: 'dist', emptyOutDir: true, chunkSizeWarningLimit: 2000 }
});
