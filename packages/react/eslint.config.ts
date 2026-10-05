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
    '**/dist',
    '**/*-lock.json',
    '**/*-lock.yaml'
  ]),
  // Every component in this library is a hook consumer, and the two mistakes
  // this catches are both invisible until they are a bug in someone else's app:
  // a dependency left out of a `useMemo` freezes a value at whatever it was on
  // the first render, and a hook behind a condition desynchronises the whole
  // list for that component.
  pluginReactHooks.configs.flat['recommended-latest'],
  // The markup the library ships. A heading or a link written empty, a role
  // that contradicts its element, a handler on something a keyboard cannot
  // reach: each is invisible until a reader with a screen reader or a
  // keyboard meets it in someone else's app. The tests are left out, because
  // a test draws whatever markup its case needs, an empty heading included.
  {
    ...pluginJsxA11y.flatConfigs.recommended,
    files: ['src/**/*.tsx'],
    rules: {
      ...pluginJsxA11y.flatConfigs.recommended.rules,
      // A list styled without bullets loses its list semantics in Safari, so
      // the library says `role="list"` on purpose, and `nav` is the rule's own
      // default.
      'jsx-a11y/no-redundant-roles': ['error', { nav: ['navigation'], ul: ['list'], ol: ['list'] }],
      // A component forwards a caller's own `autoFocus`, and a popup it opens
      // moves the focus into itself, which is the point of opening it.
      'jsx-a11y/no-autofocus': 'off'
    }
  },
  {
    files: ['**/*.{js,mjs,cjs,ts,tsx}'],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.node
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
