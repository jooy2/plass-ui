import { globalIgnores } from 'eslint/config';
import pluginJs from '@eslint/js';
import pluginTypeScriptESLint from 'typescript-eslint';
import parserTypeScript from '@typescript-eslint/parser';
import pluginNode from 'eslint-plugin-n';
import pluginReactHooks from 'eslint-plugin-react-hooks';
import pluginJsxA11y from 'eslint-plugin-jsx-a11y';
import configPrettier from 'eslint-config-prettier';

import globals from 'globals';

export default pluginTypeScriptESLint.config(
  pluginJs.configs.recommended,
  pluginTypeScriptESLint.configs.recommended,
  pluginNode.configs['flat/recommended-script'],
  globalIgnores([
    '**/.idea',
    '**/.vscode',
    '**/node_modules',
    // Vite's prebundled dependency cache, and the Flutter web build the demos
    // are served from — both generated, and neither ours to lint.
    '**/.vitepress/cache',
    'public/flutter',
    '**/*-lock.json',
    '**/*-lock.yaml'
  ]),
  // Every demo on this site is a React component, so the docs need the same
  // hook rules the library itself is held to.
  pluginReactHooks.configs.flat['recommended-latest'],
  // And the accessibility rules, because a demo is code a reader copies: an
  // empty heading or a link with nowhere to go in a sample is one in an app.
  {
    ...pluginJsxA11y.flatConfigs.recommended,
    files: ['**/*.tsx'],
    rules: {
      ...pluginJsxA11y.flatConfigs.recommended.rules,
      // The library's own exception, for the reason given in its config: a
      // list styled without bullets loses its list semantics in Safari.
      'jsx-a11y/no-redundant-roles': ['error', { nav: ['navigation'], ul: ['list'], ol: ['list'] }],
      // `render={<a href="…" />}` is how a demo turns a button or a logo into
      // a link, and the component fills the anchor with its own children,
      // which the rule cannot see.
      'jsx-a11y/anchor-has-content': 'off'
    }
  },
  {
    files: ['**/*.{js,mjs,cjs,ts,tsx}'],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.node,
        ...globals.browser
      },
      parserOptions: {
        parser: parserTypeScript,
        ecmaVersion: 2022,
        requireConfigFile: false
      }
    },
    rules: {
      eqeqeq: 'error',
      'no-unused-vars': 'off',
      'no-case-declarations': 'off',
      'no-trailing-spaces': 'error',
      'no-unsafe-optional-chaining': 'off',
      'no-control-regex': 'off',
      'n/no-missing-import': 'off',
      'n/no-unpublished-import': 'off',
      'n/no-unsupported-features/node-builtins': 'off',
      '@typescript-eslint/no-explicit-any': 'off'
    }
  },
  configPrettier
);
