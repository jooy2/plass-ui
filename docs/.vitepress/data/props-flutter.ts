/**
 * The Flutter package's constructor parameters, as data.
 *
 * These are **derived from `props.ts` rather than written again**, and the
 * reason is the shared vocabulary: `variant`, `size`, `color`, `density` and
 * `elevation` mean exactly the same thing in both packages, and the sentence
 * explaining what `density` does is the same sentence. Two independent tables
 * would be two sentences, and by the third edit they would be two different
 * sentences.
 *
 * So a Flutter row starts as its React row and states only what actually
 * differs — almost always just the Dart type. A parameter with no React
 * counterpart is written out in full; a React prop with no Flutter counterpart
 * is simply not listed, and the button page says why in prose.
 *
 * Rendered by `theme/components/PropsTable.vue`, alongside the React table.
 */

import { propTables, type PropRow } from './props';

const SIZE = 'PlassSize';
const COLOR = 'PlassColor';
const VARIANT = 'PlassVariant';
const DENSITY = 'PlassDensity';

/**
 * One React row, with the parts Dart spells differently replaced.
 *
 * Throws rather than falling back if the React row is gone: a prop that was
 * renamed or removed on the React side has to be a decision here too, and a row
 * that silently disappeared from a table is exactly the kind of drift this file
 * exists to prevent.
 */
function from(component: string, name: string, patch: Partial<PropRow> = {}): PropRow {
  const row = propTables[component]?.find((candidate) => candidate.name === name);

  if (!row) {
    throw new Error(`[plass-ui docs] no React prop named '${name}' on ${component}`);
  }

  return { ...row, ...patch };
}

/** The five shared axes, with the enum types Dart names them by. */
function sharedProps(component: string): PropRow[] {
  return [
    from(component, 'variant', { type: VARIANT, default: 'PlassVariant.solid' }),
    from(component, 'size', { type: SIZE, default: 'PlassSize.md' }),
    from(component, 'color', { type: COLOR, default: 'PlassColor.primary' }),
    // `default` is a reserved word in Dart, so the value that is called
    // `'default'` in React is `standard` here. The one renamed enum value in
    // the package.
    from(component, 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from(component, 'elevation', { type: 'int', default: '1' })
  ];
}

export const flutterPropTables: Record<string, PropRow[]> = {
  PlButton: [
    ...sharedProps('PlButton'),
    from('PlButton', 'startIcon', { type: 'Widget?' }),
    from('PlButton', 'endIcon', { type: 'Widget?' }),
    from('PlButton', 'loading', { type: 'bool', default: 'false' }),
    from('PlButton', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlButton', 'disabled', { type: 'bool', default: 'false' }),
    from('PlButton', 'fullWidth', { type: 'bool', default: 'false' }),
    {
      name: 'onPressed',
      type: 'VoidCallback?',
      description: {
        ko: '눌렸을 때. null이면 Flutter 관례대로 disabled와 같이 취급합니다',
        en: 'Called when pressed. Leaving it null disables the button, as it does everywhere else in Flutter'
      }
    },
    {
      name: 'onLongPress',
      type: 'VoidCallback?',
      description: {
        ko: '길게 눌렀을 때. 웹의 contextmenu에 대응하는 자리',
        en: 'Called on a long press — the touch equivalent of a context menu'
      }
    },
    {
      name: 'focusNode',
      type: 'FocusNode?',
      description: {
        ko: '포커스를 밖에서 제어할 때 넘깁니다. 없으면 버튼이 스스로 하나 만듭니다',
        en: 'Drive focus from outside. Left out, the button owns one of its own'
      }
    },
    {
      name: 'autofocus',
      type: 'bool',
      default: 'false',
      description: {
        ko: '화면에 올라오면서 포커스를 가져갑니다',
        en: 'Takes focus as it is inserted into the tree'
      }
    },
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '스크린 리더가 읽을 이름. 아이콘만 있는 버튼에는 반드시 넣어야 합니다',
        en: 'The name a screen reader announces. Required on an icon-only button'
      }
    },
    from('PlButton', 'children', { name: 'child', type: 'Widget?' })
  ]
};
