/**
 * The props tables, as data.
 *
 * They live here rather than as Markdown tables for three reasons: the shared
 * vocabulary (`variant`, `size`, `color`, `density`, `elevation`) is written
 * once and reused with per-component defaults, a union type like
 * `'solid' | 'glass' | 'ghost'` does not have to be escaped one pipe at a time,
 * and both locales come off one row — a Korean and an English table cannot
 * drift into listing different props.
 *
 * Rendered by `theme/components/PropsTable.vue`.
 */

import type { Locale } from './i18n';

/** Every human-readable string in here is written twice, once per locale. */
type Text = Record<Locale, string>;

export interface PropRow {
  name: string;
  type: string;
  /** Omitted when the prop has no default — rendered as `—`. */
  default?: string;
  required?: boolean;
  /** Part of the shared vocabulary in `src/types.ts`; tagged in the table. */
  shared?: boolean;
  description: Text;
}

const SIZE = "'xs' | 'sm' | 'md' | 'lg' | 'xl'";
const COLOR = "'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'info'";
const VARIANT = "'solid' | 'glass' | 'ghost'";
const DENSITY = "'default' | 'compact'";
const ELEVATION = '0 | 1 | 2 | 3';

interface SharedOptions {
  variant: string;
  size: string;
  color?: string;
  density?: string;
  elevation?: string;
  variantDescription?: Text;
  sizeDescription?: Text;
  colorDescription?: Text;
  densityDescription?: Text;
  elevationDescription?: Text;
}

/**
 * The five axes every styled component takes, with per-component defaults.
 *
 * Written once so that a reader who has learned what `density` means on a
 * PlButton does not have to read a second, subtly different sentence about it on
 * a PlTextField.
 */
function sharedProps(options: SharedOptions): PropRow[] {
  return [
    {
      name: 'variant',
      type: VARIANT,
      default: options.variant,
      shared: true,
      description: options.variantDescription ?? {
        ko: '표면의 재질. 색이 들어간 유리 / 맑은 유리 시트 / 없음',
        en: 'What the surface is made of: tinted glass, a clear sheet, or nothing'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: options.size,
      shared: true,
      description: options.sizeDescription ?? {
        ko: '높이와 타입 스케일',
        en: 'Height and type scale'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: options.color ?? "'primary'",
      shared: true,
      description: options.colorDescription ?? {
        ko: '의미론적 색 역할. 임의 색상값은 받지 않습니다',
        en: 'Semantic colour role. Arbitrary colour values are not accepted'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: options.density ?? "'default'",
      shared: true,
      description: options.densityDescription ?? {
        ko: '여백만 바꿉니다. 높이와 글자 크기는 그대로',
        en: 'Padding only — never the height, never the type scale'
      }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      default: options.elevation ?? '0',
      shared: true,
      description: options.elevationDescription ?? {
        ko: '그림자 깊이. 0은 그림자 없음',
        en: 'Drop shadow depth. 0 means no shadow at all'
      }
    }
  ];
}

export const propTables: Record<string, PropRow[]> = {
  PlButton: [
    ...sharedProps({
      variant: "'solid'",
      size: "'md'",
      elevation: '1',
      sizeDescription: {
        ko: '높이와 타입 스케일. xs 24px · sm 32px · md 40px · lg 48px · xl 56px',
        en: 'Height and type scale. xs 24px · sm 32px · md 40px · lg 48px · xl 56px'
      },
      variantDescription: {
        ko: '표면의 재질. solid는 hue가 도는 그러데이션 유리판, glass는 맑은 시트, ghost는 표면 없음',
        en: 'What the surface is made of. solid is a pane of tinted glass whose gradient turns in hue, glass is a clear sheet, ghost has no surface at all'
      },
      elevationDescription: {
        ko: '그림자 깊이. 컨트롤은 시트 위에 놓이므로 기본값이 1입니다. 호버는 한 단계 올리고, 누르면 한 단계 내려 시트에 닿습니다',
        en: 'Drop shadow depth. A control rests on the sheet, so the default is 1. Hover adds a level and pressing removes one, putting it down on the sheet'
      }
    }),
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 앞에 놓이는 내용. 1.2em으로 그려져 라벨 크기를 따라갑니다',
        en: 'Content before the label. Sized in em, so it tracks the label'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: { ko: '라벨 뒤에 놓이는 내용', en: 'Content after the label' }
    },
    {
      name: 'loading',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'startIcon 자리에 스피너를 띄우고 활성화를 막습니다. 포커스는 유지됩니다',
        en: 'Spinner in place of startIcon; stops activation but keeps focus'
      }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '비활성이되 흐려지지 않음. 액션은 존재하지만 여기서는 쓸 수 없다는 뜻',
        en: 'Inert but not dimmed — the action exists, it just is not available here'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 빛과 그림자를 잃고 페이지가 비쳐 보이며, 포커스 순서에서 빠집니다',
        en: 'Unavailable. Loses its light and its shadow, lets the page through, and leaves the tab order'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'button 대신 다른 요소로 렌더링합니다 (<a href>, 라우터의 Link). 링크는 링크로 남아 크롤러와 스크린리더가 그대로 인식합니다',
        en: 'Renders something other than a button (an <a href>, a router Link). A link stays a link, so crawlers and screen readers still see one'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '라벨. 생략하면 정사각형 아이콘 버튼이 됩니다',
        en: 'The label. Omit it and the button goes square for an icon'
      }
    }
  ],

  PlTextField: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      sizeDescription: {
        ko: '높이와 타입 스케일. PlButton과 같은 높이라서 한 줄에 섞어 놓아도 기준선이 맞습니다',
        en: "Height and type scale. The same heights as PlButton, so a row's baseline holds"
      },
      variantDescription: {
        ko: '표면의 재질. 필드에서 solid는 색 유리판이 아니라 시트에 파인 우물입니다 — 필드가 담는 것은 사용자 데이터입니다',
        en: 'What the surface is made of. On a field solid is not a tinted pane but a well cut into the sheet — a field holds user data'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 유리는 물들이지 않으므로 가장자리와 포커스 링, 캐럿에만 나타납니다',
        en: 'Semantic colour role. The glass is never dyed, so it reaches the edge, the focus ring and the caret'
      },
      elevationDescription: {
        ko: '그림자 깊이. 필드는 떠 있는 표면이 아니라 파인 자리이므로 기본값이 0입니다',
        en: 'Drop shadow depth. A field is a well rather than a surface that floats, so the default is 0'
      }
    }),
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '컨트롤 위 라벨. Base UI Field로 연결됩니다',
        en: "Label above the control, wired to it by Base UI's Field"
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '컨트롤 아래 보조 설명', en: 'Helper text below the control' }
    },
    {
      name: 'error',
      type: 'ReactNode',
      description: {
        ko: '컨트롤 아래 오류 메시지. 값이 있으면 invalid 상태도 함께 켜집니다',
        en: 'Error message below the control. Its presence also turns the field invalid'
      }
    },
    {
      name: 'invalid',
      type: 'boolean',
      default: '!!error',
      description: {
        ko: '메시지 없이 invalid만 켭니다. 외부 폼 라이브러리가 유효성을 가질 때',
        en: 'Forces the invalid state without a message, for when a form library owns validity'
      }
    },
    {
      name: 'multiline',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'input 대신 textarea로 렌더링합니다. 나머지 축은 그대로',
        en: 'Renders a textarea instead of an input. Every other axis stays identical'
      }
    },
    {
      name: 'rows',
      type: 'number',
      default: '3',
      description: { ko: 'multiline일 때 보이는 줄 수', en: 'Visible rows in multiline mode' }
    },
    {
      name: 'resize',
      type: "'none' | 'vertical' | 'horizontal' | 'both'",
      default: "'vertical'",
      description: {
        ko: 'multiline을 사용자가 어느 방향으로 늘릴 수 있는지. 가로로 늘리면 폼의 열이 깨지므로 세로만 기본값입니다',
        en: "Which way the user may drag a multiline control. Horizontal resizing breaks a form's column, so only the vertical axis is on"
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '컨트롤 앞에 놓이는 내용. 1.2em으로 그려져 글자 크기를 따라갑니다',
        en: 'Content before the control. Sized in em, so it tracks the text'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: { ko: '컨트롤 뒤에 놓이는 내용', en: 'Content after the control' }
    },
    {
      name: 'loading',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'endIcon 자리에 스피너를 띄우고 busy로 표시합니다. 입력은 계속 가능합니다',
        en: 'Spinner in place of endIcon, and the field is marked busy. Typing is still allowed'
      }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '값은 읽고 복사할 수 있지만 고쳐 쓸 수는 없습니다. 채도가 빠지고 평평해집니다',
        en: 'The value can be read and copied but not rewritten. Goes flat and loses most of its saturation'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 시트 너머로 페이지가 비쳐 보이며, 포커스 순서에서 빠집니다',
        en: 'Unavailable. The page shows through the sheet, and it leaves the tab order'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    }
  ]
};
