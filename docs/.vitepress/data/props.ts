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
  PlAccordion: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '시트의 재질. solid는 가장 불투명한 유리, glass는 하이라이너가 있는 기본 시트, ghost는 표면 없음',
        en: 'What the sheet is made of. solid is the densest glass, glass is the default sheet with a hairline, ghost has no surface at all'
      },
      sizeDescription: {
        ko: '제목과 본문의 타입 스케일, 그리고 그 둘을 감싸는 여백',
        en: 'The type scale of the title and the body, and the padding around both'
      }
    }),
    {
      name: 'multiple',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '여러 섹션을 동시에 열 수 있게 합니다',
        en: 'Lets more than one section stay open at once'
      }
    },
    {
      name: 'value',
      type: '(string | number)[]',
      description: {
        ko: '열려 있는 섹션. onValueChange와 함께 controlled로 씁니다',
        en: 'Which sections are open. Use with onValueChange for a controlled accordion'
      }
    },
    {
      name: 'defaultValue',
      type: '(string | number)[]',
      description: {
        ko: 'uncontrolled일 때 처음부터 열려 있는 섹션',
        en: 'Which sections start open, for an uncontrolled accordion'
      }
    },
    {
      name: 'onValueChange',
      type: '(value: (string | number)[]) => void',
      description: {
        ko: '열린 섹션 집합이 바뀔 때 호출됩니다',
        en: 'Called with the new open set whenever it changes'
      }
    },
    {
      name: 'dividers',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '섹션 사이를 헤어라인으로 나눕니다. 끄면 각 섹션이 타일이 됩니다',
        en: 'Scores the sheet between sections with a hairline. Off, each section becomes a tile'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '모든 섹션이 반응하지 않습니다', en: 'Every section stops answering' }
    },
    {
      name: 'hiddenUntilFound',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '닫힌 패널을 DOM에 남겨 브라우저의 페이지 검색이 찾아 열 수 있게 합니다. keepMounted보다 우선합니다',
        en: "Keeps closed panels in the DOM so the browser's own page search can find and open them. Overrides keepMounted"
      }
    },
    {
      name: 'keepMounted',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '닫힌 패널을 DOM에 남깁니다. 만드는 비용이 크거나 form 상태를 쥐고 있는 내용에',
        en: 'Keeps closed panels in the DOM. For content that is expensive to build, or that holds form state'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'PlAccordionItem 목록', en: 'The PlAccordionItem sections' }
    }
  ],

  PlAccordionItem: [
    {
      name: 'value',
      type: 'string | number',
      description: {
        ko: 'value / defaultValue가 이 섹션을 가리키는 이름. 생략하면 Base UI가 만들어 줍니다',
        en: 'Identifies the section to value / defaultValue. Base UI generates one when it is left out'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '접힘 헤더의 제목', en: 'The heading on the fold' }
    },
    {
      name: 'subtitle',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 한 줄. 타입 스케일 한 단계 아래의 muted 텍스트',
        en: 'A second line under the title, one step down the type scale and muted'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '제목 앞에 놓이는 내용 — 아이콘, 상태 점, 개수',
        en: 'Content before the title — an icon, a status dot, a count'
      }
    },
    {
      name: 'action',
      type: 'ReactNode',
      description: {
        ko: '헤더 끝, chevron 앞에 고정되는 컨트롤. trigger 바깥에 놓이므로 버튼을 넣어도 됩니다',
        en: 'A control pinned to the end of the header, before the chevron. It sits outside the trigger, so a button is safe there'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '이 섹션만 접히지 않습니다. 나머지는 그대로 동작합니다',
        en: 'This section stops folding; the rest keep working'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '패널의 내용', en: 'The body' }
    }
  ],

  PlAlert: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      color: "'info'",
      variantDescription: {
        ko: '표면의 재질. alert는 색을 입는 대상 자체라서, 컨테이너와 달리 시트가 틴트를 받습니다',
        en: 'What the surface is made of. An alert *is* the thing being coloured, so unlike a container its sheet takes the tint'
      },
      colorDescription: {
        ko: '심각도. 기본값이 primary가 아니라 info인 이유는, alert는 주요한 무언가가 아니라 알림이기 때문입니다',
        en: 'The severity. The default is info rather than primary, because an alert is not the primary anything — it is a note'
      },
      sizeDescription: {
        ko: '글리프와 제목, 메시지의 타입 스케일과 여백',
        en: 'The type scale and padding of the glyph, the title and the message'
      }
    }),
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '헤드라인. 주면 두 부분(헤드라인 + 아래의 상세)이 되고, 없으면 전체가 한 줄입니다',
        en: 'The heading line. With it the alert is two-part; without it the whole thing is one line'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode | false',
      description: {
        ko: '앞머리의 글리프. 기본값은 color에 맞는 모양이고, false면 없애고, 노드를 주면 대체합니다',
        en: 'The glyph at the start. Defaults to the one that goes with color; false drops it, a node replaces it'
      }
    },
    {
      name: 'action',
      type: 'ReactNode',
      description: {
        ko: '줄 끝에 고정되는 내용 — Retry 버튼, 링크. children 바깥이라 메시지가 줄바꿈돼도 첫 줄에 남습니다',
        en: 'Content pinned to the end of the row — a Retry button, a link. Kept out of children so it stays on the first line'
      }
    },
    {
      name: 'onClose',
      type: '(event) => void',
      description: {
        ko: '이것을 주는 것이 닫기 버튼을 나타나게 합니다',
        en: 'Passing it is what makes the dismiss button appear'
      }
    },
    {
      name: 'closeLabel',
      type: 'string',
      default: "'Dismiss'",
      description: {
        ko: '닫기 버튼의 접근 가능한 이름. 화면에는 그려지지 않습니다',
        en: 'Accessible name of the dismiss button. Never drawn'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '메시지', en: 'The message' }
    }
  ],

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

  PlCard: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      elevation: '1',
      variantDescription: {
        ko: '시트의 재질. solid는 가장 불투명한 유리, glass는 하이라인이 있는 기본 시트, ghost는 표면 없음',
        en: 'What the sheet is made of. solid is the densest glass, glass is the default sheet with a hairline, ghost has no surface at all'
      },
      sizeDescription: {
        ko: '모서리 반경, 타입 스케일, 안쪽 여백이 함께 움직입니다',
        en: 'The radius, the type scale and the inner padding, moving together'
      },
      elevationDescription: {
        ko: '그림자 깊이. 카드는 페이지 위에 놓인 시트이므로 기본값이 1입니다',
        en: 'Drop shadow depth. A card is a sheet lying on the page, so the default is 1'
      }
    }),
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '카드의 제목. 문서 개요에 들어가야 한다면 실제 heading을 넘기세요 (title={<h2>…</h2>})',
        en: "The card's heading. Pass a real heading element (title={<h2>…</h2>}) when it belongs in the document outline"
      }
    },
    {
      name: 'subtitle',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 한 줄. 타입 스케일 한 단계 아래의 muted 텍스트',
        en: 'A second line under the title, one step down the type scale and muted'
      }
    },
    {
      name: 'headerAction',
      type: 'ReactNode',
      description: {
        ko: '헤더 줄 끝에 고정되는 내용 — 메뉴 버튼, 상태 칩. 제목이 줄바꿈되어도 첫 줄에 남습니다',
        en: 'Content pinned to the end of the header row — a menu button, a status chip. Stays on the title line while the title wraps'
      }
    },
    {
      name: 'footer',
      type: 'ReactNode',
      description: {
        ko: '아래쪽 영역. 줄바꿈되는 row로 배치되므로 버튼 두 개에 별도 wrapper가 필요 없습니다',
        en: 'The bottom area. Laid out as a wrapping row, so a pair of buttons needs no wrapper'
      }
    },
    {
      name: 'dividers',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '섹션 사이를 여백 대신 헤어라인으로 나눕니다. 선이 양 끝까지 닿도록 여백이 카드에서 각 섹션으로 옮겨 갑니다',
        en: 'Scores the sheet between sections instead of spacing them. The padding moves from the card onto each section so the rules reach both edges'
      }
    },
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '안쪽 여백. 이미지나 표처럼 가장자리까지 채우는 내용에는 끄세요',
        en: 'Inner padding. Turn it off for full-bleed content — an image, a table'
      }
    },
    {
      name: 'interactive',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '포인터 아래에서 시트를 들어 올리고 그림자를 한 단계 더합니다. 실제로 누를 수 있는 카드라면 render로 진짜 요소를 주세요',
        en: 'Lifts the sheet under the pointer and adds a level of elevation. Give a genuinely clickable card a real element with render'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'div 대신 다른 요소로 렌더링합니다 — <section>, <li>, <a href>',
        en: 'Renders something other than a div — a <section>, an <li>, an <a href>'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '카드의 본문', en: "The card's body" }
    }
  ],

  PlCheckbox: [
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: 'tick 박스의 크기와 옆 글자의 타입 스케일',
        en: 'The size of the tick box and the type scale of the text beside it'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '체크됐을 때 박스를 채우는 그러데이션',
        en: 'The gradient the box fills with when it is ticked'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: 'tick 옆의 글자. Base UI의 Field가 엮어 주므로 눌러도 체크됩니다',
        en: "The text beside the tick. Wired to it by Base UI's Field, so pressing it ticks the box"
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '라벨 아래 보조 설명', en: 'Helper text under the label' }
    },
    {
      name: 'error',
      type: 'ReactNode',
      description: {
        ko: '오류 메시지. 존재 자체가 invalid 상태를 만듭니다',
        en: 'Error message below. Its presence also turns the checkbox invalid'
      }
    },
    {
      name: 'invalid',
      type: 'boolean',
      description: {
        ko: '메시지 없이 invalid로 만듭니다. 기본값은 error에 내용이 있는지 여부',
        en: 'Forces the invalid state without a message. Defaults to whether error has content'
      }
    },
    {
      name: 'checked',
      type: 'boolean',
      description: {
        ko: '체크 상태. onCheckedChange와 함께 controlled로 씁니다',
        en: 'The checked state. Use with onCheckedChange for a controlled checkbox'
      }
    },
    {
      name: 'defaultChecked',
      type: 'boolean',
      default: 'false',
      description: { ko: 'uncontrolled일 때의 시작 상태', en: 'The starting state, uncontrolled' }
    },
    {
      name: 'onCheckedChange',
      type: '(checked: boolean, details) => void',
      description: { ko: '상태가 바뀔 때 호출됩니다', en: 'Called with the new state' }
    },
    {
      name: 'indeterminate',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '부분 선택. 체크도 해제도 아닌 세 번째 상태로, aria-checked="mixed"가 됩니다',
        en: 'Neither ticked nor cleared — the third state, announced as aria-checked="mixed"'
      }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '상태는 보이지만 바꿀 수 없습니다',
        en: 'The state is shown but cannot be changed'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 채도가 빠지고 페이지가 비쳐 보이며, 포커스 순서에서 빠집니다',
        en: 'Unavailable. Loses its saturation, lets the page through, and leaves the tab order'
      }
    },
    {
      name: 'name · value · required',
      type: 'string · string · boolean',
      description: {
        ko: '네이티브 form 제출을 위한 것들. Base UI가 그대로 받습니다',
        en: 'For a native form submission. Passed straight to Base UI'
      }
    }
  ],

  PlFilePicker: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '상자의 재질. 셋 다 점선 테두리를 씁니다 — 드롭을 받는 영역이라는 뜻의 관습이기 때문입니다',
        en: 'What the box is made of. All three take a dashed edge, because that is the established sign for an area that accepts a drop'
      },
      sizeDescription: {
        ko: '상자의 여백과 안쪽 글자의 타입 스케일',
        en: "The box's padding and the type scale of the text inside it"
      }
    }),
    {
      name: 'accept',
      type: 'string',
      description: {
        ko: "브라우저 파일 대화상자가 제공할 형식 ('image/*,.pdf'). 드롭된 파일도 이 목록으로 검사합니다 — 속성만으로는 검사되지 않습니다",
        en: "Which files the browser's dialog offers ('image/*,.pdf'). Dropped files are checked against it too, which the attribute alone does not do"
      }
    },
    {
      name: 'multiple',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '파일을 여러 개 고를 수 있는지',
        en: 'Whether more than one file may be chosen'
      }
    },
    {
      name: 'maxSize',
      type: 'number',
      description: {
        ko: '파일 하나의 최대 크기 (바이트)',
        en: 'The largest a single file may be, in bytes'
      }
    },
    {
      name: 'maxFiles',
      type: 'number',
      description: {
        ko: '동시에 쥘 수 있는 파일 수. 한 번의 드롭이 아니라 이미 쥔 것과 합쳐 검사합니다',
        en: 'How many files may be held at once — checked against what is already chosen, not against one drop'
      }
    },
    {
      name: 'value',
      type: 'readonly File[]',
      description: {
        ko: '선택된 파일들. onFilesChange와 함께 controlled로 씁니다',
        en: 'The chosen files. Use with onFilesChange for a controlled picker'
      }
    },
    {
      name: 'defaultValue',
      type: 'readonly File[]',
      description: { ko: 'uncontrolled일 때 처음 선택된 파일들', en: 'The initially chosen files' }
    },
    {
      name: 'onFilesChange',
      type: '(files: File[]) => void',
      description: { ko: '목록이 바뀔 때 호출됩니다', en: 'Called with the new list' }
    },
    {
      name: 'onReject',
      type: '(rejections: PlFileRejection[]) => void',
      description: {
        ko: '거절된 파일과 그 이유를 받습니다. 없으면 거절된 파일이 조용히 사라집니다 — dropzone이 저지르는 최악의 일',
        en: 'Called with everything turned away and why. Without it a rejected file disappears silently, which is the worst thing a dropzone does'
      }
    },
    {
      name: 'label · description · error · invalid',
      type: 'ReactNode · ReactNode · ReactNode · boolean',
      description: {
        ko: '상자 위 라벨, 아래 보조 설명, 오류 메시지. error의 존재가 invalid 상태를 만듭니다',
        en: 'The label above the box, the helper text below it, and the error. The error also turns the picker invalid'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      default: "'Drop files here, or click to browse'",
      description: { ko: '상자 안의 문장', en: 'The line inside the box' }
    },
    {
      name: 'hint',
      type: 'ReactNode',
      description: {
        ko: '그 아래 한 줄 — 무엇을, 얼마나 크게, 몇 개까지',
        en: 'The line under it — what is accepted, how big, how many'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: {
        ko: '제목 위의 글리프. null을 주면 그림 없는 상자가 됩니다',
        en: 'The glyph above the title. Pass null for a box with no picture in it'
      }
    },
    {
      name: 'showList',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '상자 아래에 선택된 파일을 지우기 버튼과 함께 나열합니다',
        en: 'Lists the chosen files under the box, each with a way to remove it'
      }
    },
    {
      name: 'removeLabel',
      type: '(name: string) => string',
      default: '`Remove {name}`',
      description: {
        ko: '파일 지우기 버튼의 접근 가능한 이름',
        en: "Accessible name of a file's remove button"
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'true',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '파일은 보이지만 추가도 삭제도 할 수 없습니다',
        en: 'The files are shown but cannot be added to or removed'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '사용 불가', en: 'Unavailable' }
    },
    {
      name: 'name · required · id',
      type: 'string · boolean · string',
      description: {
        ko: '네이티브 form 제출과 라벨 연결을 위한 것들',
        en: 'For a native form submission and for wiring a label'
      }
    }
  ],

  PlModal: [
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '시트의 최대 너비와 타입 스케일. 컨트롤 사다리보다 단계가 넓은데, 답하는 질문이 다르기 때문입니다 — 얼마나 큰가가 아니라 안에서 한 줄이 얼마나 길어야 편한가',
        en: "The sheet's max width and type scale. Its steps are wider than the control ladder because it answers a different question: not how big, but how long a line of text is comfortable inside"
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: 'focus ring과 hover 틴트의 색 계열. 시트 자체에는 색이 들어가지 않습니다',
        en: 'The family behind the focus ring and the hover tint. The sheet itself is never dyed'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '각 영역의 여백', en: 'The padding of each section' }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '열림 상태. onOpenChange와 함께 controlled로 씁니다',
        en: 'Whether it is shown. Use with onOpenChange for a controlled modal'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: { ko: 'uncontrolled일 때 열린 채로 시작할지', en: 'Whether it starts open' }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열고 닫힐 때 호출됩니다', en: 'Called when it opens or closes' }
    },
    {
      name: 'trigger',
      type: 'ReactElement',
      description: {
        ko: 'modal을 여는 요소. Base UI가 엮어 줍니다. 선택 사항입니다',
        en: 'The element that opens the modal, wired up by Base UI. Optional'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '제목. modal의 이름이 되는 <h2>로 렌더링됩니다',
        en: 'The heading. Rendered as the <h2> that names the modal'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 한 줄이자 modal의 접근 가능한 설명',
        en: "A line under the title, and the modal's accessible description"
      }
    },
    {
      name: 'actions',
      type: 'ReactNode',
      description: {
        ko: '아래쪽 줄. 끝 정렬이라 버튼 두 개에 wrapper가 필요 없습니다. PlModalClose가 그중 하나를 닫기 버튼으로 만듭니다',
        en: 'The bottom row, end-aligned so a pair of buttons needs no wrapper. PlModalClose is what makes one of them dismiss'
      }
    },
    {
      name: 'dividers',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '헤더 · 본문 · 액션 사이를 헤어라인으로 나눕니다. 본문이 스크롤되기 시작하면 켤 만합니다',
        en: 'Scores the sheet between the header, the body and the actions. Worth turning on the moment the body scrolls'
      }
    },
    {
      name: 'showClose',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '모서리의 ×. 기본으로 켜져 있습니다 — modal은 답할 때까지 페이지를 가져가므로, 나가는 길이 눈에 보여야 합니다',
        en: 'The × in the corner. On by default — a modal takes the page away until it is answered, and the way out should be visible'
      }
    },
    {
      name: 'closeLabel',
      type: 'string',
      default: "'Close'",
      description: { ko: '× 버튼의 접근 가능한 이름', en: 'Accessible name of the × button' }
    },
    {
      name: 'width',
      type: 'number | string',
      description: {
        ko: 'size가 정하는 최대 너비를 덮어씁니다. 숫자는 px',
        en: 'A hard cap on the width, overriding the one size implies. Numbers are pixels'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'size가 허용하는 너비를 다 씁니다. 다른 컴포넌트와 반대로 기본이 켜짐입니다 — modal의 컨테이너는 뷰포트이고, 두 단어에 맞춰 줄어든 modal은 tooltip입니다',
        en: 'Takes the full width the size allows. On by default, the other way round from every other component: a modal that shrank to fit two words would be a tooltip'
      }
    },
    {
      name: 'fullScreen',
      type: 'boolean',
      default: 'false',
      description: { ko: '뷰포트를 가장자리까지 채웁니다', en: 'Fills the viewport edge to edge' }
    },
    {
      name: 'modal',
      type: "boolean | 'trap-focus'",
      default: 'true',
      description: {
        ko: "뒤의 페이지를 가져갈지. 'trap-focus'는 페이지를 스크롤·클릭 가능하게 두면서 focus만 가둡니다",
        en: "Whether the page behind is taken away. 'trap-focus' keeps it scrollable and clickable while still holding focus inside"
      }
    },
    {
      name: 'dismissible',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'Escape와 바깥 클릭으로 닫히는지. 끄면 반드시 답해야 하는 modal이 되므로, 답할 수 있는 actions를 함께 주세요',
        en: 'Whether Escape or a click outside closes it. Turn it off for the modal that has to be answered — and then give it actions that answer it'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '본문. 스크롤되는 유일한 부분',
        en: 'The body — the only part that scrolls'
      }
    }
  ],

  PlPagination: [
    ...sharedProps({
      variant: "'ghost'",
      size: "'md'",
      density: "'compact'",
      variantDescription: {
        ko: '쉬고 있는 페이지 버튼의 재질. 현재 페이지는 언제나 solid입니다',
        en: 'The material of a page at rest. The current page is always solid'
      },
      sizeDescription: {
        ko: '버튼 높이와 타입 스케일. PlButton과 같은 사다리라 옆에 놓으면 기준선이 맞습니다',
        en: 'Button height and type scale — the same ladder as PlButton, so a row lines up beside one'
      }
    }),
    {
      name: 'count',
      type: 'number',
      required: true,
      description: {
        ko: '전체 페이지 수. 2보다 작으면 컨트롤 전체가 아무것도 렌더링하지 않습니다',
        en: 'How many pages there are. Fewer than two and the whole control renders nothing'
      }
    },
    {
      name: 'page',
      type: 'number',
      description: {
        ko: '현재 페이지 (1부터). onPageChange와 함께 controlled로 씁니다',
        en: 'The current page, 1-based. Use with onPageChange for a controlled row'
      }
    },
    {
      name: 'defaultPage',
      type: 'number',
      default: '1',
      description: {
        ko: 'uncontrolled일 때 시작 페이지',
        en: 'Which page starts current, for an uncontrolled row'
      }
    },
    {
      name: 'onPageChange',
      type: '(page: number) => void',
      description: { ko: '페이지가 바뀔 때 호출됩니다', en: 'Called with the new page' }
    },
    {
      name: 'siblingCount',
      type: 'number',
      default: '1',
      description: {
        ko: '현재 페이지 양옆에 항상 보이는 페이지 수',
        en: 'How many pages are always shown on either side of the current one'
      }
    },
    {
      name: 'boundaryCount',
      type: 'number',
      default: '1',
      description: {
        ko: '양 끝에 항상 보이는 페이지 수. 0이면 첫 페이지와 마지막 페이지가 사라지고 창만 남습니다',
        en: 'How many pages are always shown at each end. 0 drops the first and last, leaving only the window'
      }
    },
    {
      name: 'showEdges',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '첫 페이지 / 마지막 페이지로 건너뛰는 버튼을 보여 줍니다',
        en: 'Shows the jump-to-first and jump-to-last steppers'
      }
    },
    {
      name: 'showArrows',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '이전 / 다음 버튼을 보여 줍니다',
        en: 'Shows the previous and next steppers'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '줄 안의 모든 버튼이 반응하지 않습니다',
        en: 'Every button in the row stops answering'
      }
    },
    {
      name: 'getPageHref',
      type: '(page: number) => string',
      description: {
        ko: '페이지 주소. 주면 모든 숫자가 진짜 <a href>가 되어 크롤러가 따라갈 수 있습니다',
        en: 'The address of a page. With it every number becomes a real <a href> that a crawler can follow'
      }
    },
    {
      name: 'label',
      type: 'string',
      default: "'Pagination'",
      description: { ko: '<nav>의 접근 가능한 이름', en: 'Accessible name of the <nav>' }
    },
    {
      name: 'pageLabel',
      type: '(page: number) => string',
      default: '`Page {n}`',
      description: {
        ko: '페이지 버튼의 접근 가능한 이름',
        en: 'Accessible name of a page button'
      }
    },
    {
      name: 'previousLabel · nextLabel · firstLabel · lastLabel',
      type: 'string',
      description: {
        ko: '각 이동 버튼의 접근 가능한 이름. 화면에 그려지지 않습니다',
        en: 'Accessible names of the steppers. None of them is ever drawn'
      }
    },
    {
      name: 'statusLabel',
      type: '(page: number, count: number) => string',
      default: '`Page {n} of {total}`',
      description: {
        ko: '페이지가 바뀔 때 스크린리더가 듣는 live region 문장',
        en: 'The live-region sentence a screen reader hears when the page changes'
      }
    }
  ],

  PlRadioGroup: [
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '모든 dot의 크기와 옆 글자의 타입 스케일. 그룹에 한 번 주면 전부가 물려받습니다',
        en: 'The size of every dot and the type scale beside it. Set once on the group and inherited by all of them'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '선택된 dot을 채우는 그러데이션',
        en: 'The gradient a chosen dot fills with'
      }
    },
    {
      name: 'orientation',
      type: "'horizontal' | 'vertical'",
      default: "'vertical'",
      shared: true,
      description: {
        ko: '옵션이 쌓이는 방향. 세로가 기본입니다 — 라벨 하나가 길어지는 순간 가로줄은 읽기 어려워집니다',
        en: 'Which way the options stack. Vertical by default — a row becomes unreadable the moment one label is long'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '옵션들이 대답하는 질문. 그룹의 라벨로 렌더링됩니다',
        en: "The question the options answer. Rendered as the group's label"
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '라벨 아래 보조 설명', en: 'Helper text under the label' }
    },
    {
      name: 'error',
      type: 'ReactNode',
      description: {
        ko: '옵션 아래의 오류 메시지. 존재 자체가 invalid 상태를 만듭니다',
        en: 'Error message below the options. Its presence also turns the group invalid'
      }
    },
    {
      name: 'invalid',
      type: 'boolean',
      description: {
        ko: '메시지 없이 invalid로 만듭니다. 기본값은 error에 내용이 있는지 여부',
        en: 'Forces the invalid state without a message. Defaults to whether error has content'
      }
    },
    {
      name: 'value',
      type: 'unknown',
      description: {
        ko: '선택된 옵션의 value. onValueChange와 함께 controlled로 씁니다',
        en: 'The chosen option value. Use with onValueChange for a controlled group'
      }
    },
    {
      name: 'defaultValue',
      type: 'unknown',
      description: { ko: 'uncontrolled일 때 처음 선택된 값', en: 'The initially chosen value' }
    },
    {
      name: 'onValueChange',
      type: '(value: unknown, details) => void',
      description: { ko: '선택이 바뀔 때 호출됩니다', en: 'Called with the new value' }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '선택은 보이지만 바꿀 수 없습니다. 모든 옵션이 물려받습니다',
        en: 'The choice is shown but cannot be changed. Every option inherits it'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '모든 옵션이 반응하지 않습니다', en: 'Every option stops answering' }
    },
    {
      name: 'name · required',
      type: 'string · boolean',
      description: {
        ko: '네이티브 form 제출을 위한 것들. Base UI가 그대로 받습니다',
        en: 'For a native form submission. Passed straight to Base UI'
      }
    }
  ],

  PlRadio: [
    {
      name: 'value',
      type: 'unknown',
      required: true,
      description: {
        ko: '이 옵션이 선택됐을 때 그룹이 갖는 값',
        en: "The group's value when this option is the chosen one"
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: 'dot 옆의 글자. Base UI의 Field가 엮어 주므로 눌러도 선택됩니다',
        en: "The text beside the dot. Wired to it by Base UI's Field, so pressing it chooses the option"
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '라벨 아래 보조 설명', en: 'Helper text under the label' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '이 옵션만 고를 수 없습니다. 나머지는 그대로 동작합니다',
        en: 'This option cannot be chosen; the rest keep working'
      }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      description: {
        ko: '그룹의 readOnly를 이 옵션에서만 덮어씁니다',
        en: "Overrides the group's readOnly for this option alone"
      }
    }
  ],

  PlSegmentedButton: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '홈과 그 위를 타는 타일의 재질. solid는 색 유리 키가 홈을 타고, glass는 맑은 타일, ghost는 홈 없음',
        en: 'What the groove and the tile riding in it are made of. solid rides a tinted-glass key, glass a clear tile, ghost has no groove at all'
      },
      sizeDescription: {
        ko: '세그먼트의 높이와 타입 스케일. PlButton과 같은 사다리',
        en: 'Segment height and type scale — the same ladder as PlButton'
      },
      elevationDescription: {
        ko: '홈의 그림자 깊이. 홈은 페이지에 파인 것이므로 기본값은 0입니다',
        en: 'Drop shadow depth of the groove. A groove is cut into the page, so the default is 0'
      }
    }),
    {
      name: 'value',
      type: 'string | number | null',
      description: {
        ko: '선택된 세그먼트. onValueChange와 함께 controlled로 씁니다',
        en: 'The chosen segment. Use with onValueChange for a controlled set'
      }
    },
    {
      name: 'defaultValue',
      type: 'string | number | null',
      default: 'null',
      description: { ko: 'uncontrolled일 때 처음 선택된 세그먼트', en: 'Which starts chosen' }
    },
    {
      name: 'onValueChange',
      type: '(value: string | number | null) => void',
      description: { ko: '선택이 바뀔 때 호출됩니다', en: 'Called with the new value' }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '세그먼트들이 전체 너비를 균등하게 나눠 가집니다',
        en: 'The segments share the full width, each taking an equal part of it'
      }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '선택은 보이지만 바꿀 수 없습니다',
        en: 'Shows which one is chosen but does not let it be changed'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '모든 세그먼트가 반응하지 않습니다', en: 'Disables every segment at once' }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: 'form 제출 시 이 값을 식별하는 이름',
        en: 'Identifies the value when a form is submitted'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'PlSegment 목록', en: 'The PlSegment children' }
    }
  ],

  PlSegment: [
    {
      name: 'value',
      type: 'string | number',
      required: true,
      description: {
        ko: '세그먼트를 식별하는 값. onValueChange가 보고하는 것',
        en: 'Identifies the segment. What onValueChange reports'
      }
    },
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
      description: {
        ko: '라벨 뒤 — 개수, 상태 점',
        en: 'Content after the label — a count, a status dot'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '고를 수 없지만 여전히 묶음의 일부입니다',
        en: 'Unavailable, but still part of the set'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '세그먼트의 라벨', en: "The segment's label" }
    }
  ],

  PlSelect: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: 'trigger의 재질. PlTextField와 같은 껍데기를 씁니다. solid는 시트에 파인 우물',
        en: "The material of the trigger, drawn on PlTextField's shell. solid is the well cut into the sheet"
      },
      sizeDescription: {
        ko: 'trigger의 높이와 타입 스케일. PlTextField와 같은 사다리',
        en: 'Height and type scale of the trigger — the same ladder as PlTextField'
      },
      elevationDescription: {
        ko: 'trigger의 그림자 깊이. 팝업은 3으로 고정입니다 — 팝업은 정말로 페이지 위에 떠 있습니다',
        en: 'Drop shadow depth of the trigger. The popup has its own, fixed at 3 — it genuinely floats'
      }
    }),
    {
      name: 'items',
      type: 'readonly PlSelectOption[]',
      required: true,
      description: {
        ko: '옵션 목록. 데이터로 받습니다 — 팝업을 한 번도 열지 않은 trigger도 라벨을 알아야 하기 때문입니다',
        en: 'The options, as data — the trigger has to know the labels before the popup has ever been opened'
      }
    },
    {
      name: 'value',
      type: 'string | number | null',
      description: {
        ko: '선택된 값. onValueChange와 함께 controlled로 씁니다',
        en: 'The chosen value. Use with onValueChange for a controlled select'
      }
    },
    {
      name: 'defaultValue',
      type: 'string | number | null',
      description: { ko: 'uncontrolled일 때 처음 선택된 값', en: 'The initially chosen value' }
    },
    {
      name: 'onValueChange',
      type: '(value: string | number | null) => void',
      description: { ko: '값이 바뀔 때 호출됩니다', en: 'Called with the new value' }
    },
    {
      name: 'placeholder',
      type: 'ReactNode',
      description: {
        ko: '아무것도 고르지 않았을 때 trigger에 보이는 내용',
        en: 'Shown in the trigger while nothing is chosen'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: 'trigger 위 라벨. Base UI의 Field가 서로 엮어 줍니다',
        en: "Label above the trigger, wired to it by Base UI's Field"
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: 'trigger 아래 보조 설명', en: 'Helper text below the trigger' }
    },
    {
      name: 'error',
      type: 'ReactNode',
      description: {
        ko: '오류 메시지. 존재 자체가 invalid 상태를 만듭니다',
        en: 'Error message below. Its presence also turns the select invalid'
      }
    },
    {
      name: 'invalid',
      type: 'boolean',
      description: {
        ko: '메시지 없이 invalid로 만듭니다. 기본값은 error에 내용이 있는지 여부',
        en: 'Forces the invalid state without a message. Defaults to whether error has content'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '값 앞에 놓이는 내용. 1.2em으로 그려져 글자 크기를 따라갑니다',
        en: 'Content before the value. Sized in em, so it tracks the text'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '값은 보이지만 바꿀 수 없습니다',
        en: 'The value is shown but cannot be changed'
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
      name: 'required',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'form 제출 전에 값을 골라야 하는지',
        en: 'Whether a value must be chosen before the form is submitted'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: 'form 제출 시 이 필드를 식별하는 이름',
        en: 'Identifies the field when a form is submitted'
      }
    }
  ],

  PlSelectOption: [
    {
      name: 'value',
      type: 'string | number',
      required: true,
      description: {
        ko: '제출되는 값이자 value / onValueChange가 말하는 값',
        en: 'Submitted, and what value / onValueChange speak in'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '목록과 trigger에 보이는 내용. 생략하면 value가 그대로 쓰입니다',
        en: 'Shown in the list and in the trigger. Defaults to the value itself'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '고를 수 없지만 목록에는 남습니다 — 존재하는 옵션인데 지금은 못 고르는 것',
        en: 'Unavailable, but still listed — the option exists, it just cannot be picked'
      }
    }
  ],

  PlSlider: [
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '홈 두께, thumb 지름, 그리고 라벨의 타입 스케일',
        en: 'Groove thickness, thumb diameter, and the label type scale'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '채워진 구간의 그러데이션과 thumb의 색',
        en: 'The gradient of the filled run, and the thumb on it'
      }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      default: '1',
      shared: true,
      description: {
        ko: 'thumb의 그림자 깊이. 누르는 부분이므로 컨트롤과 같은 기본값 1',
        en: 'Drop shadow depth of the thumb. It is the part you press, so it takes a control default of 1'
      }
    },
    {
      name: 'orientation',
      type: "'horizontal' | 'vertical'",
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '슬라이더가 놓이는 방향. 세로 슬라이더는 자기 길이가 없으므로 높이를 주세요',
        en: 'Which way the slider runs. A vertical slider has no length of its own, so give it a height'
      }
    },
    {
      name: 'value',
      type: 'number | number[]',
      description: {
        ko: '현재 값. 배열을 주면 그 개수만큼 thumb이 있는 range 슬라이더가 됩니다',
        en: 'The current value. An array makes it a range slider with one thumb per entry'
      }
    },
    {
      name: 'defaultValue',
      type: 'number | number[]',
      description: { ko: 'uncontrolled일 때의 시작 값', en: 'The starting value, uncontrolled' }
    },
    {
      name: 'onValueChange',
      type: '(value: number | number[]) => void',
      description: { ko: '값이 바뀔 때 호출됩니다', en: 'Called with the new value' }
    },
    {
      name: 'min · max · step',
      type: 'number',
      default: '0 · 100 · 1',
      description: {
        ko: '범위와 눈금. Base UI가 그대로 받습니다',
        en: 'The range and its increments, passed straight to Base UI'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: { ko: '트랙 위 라벨', en: 'The label above the track' }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '트랙 아래 보조 설명', en: 'Helper text below the track' }
    },
    {
      name: 'showValue',
      type: 'boolean | ((formatted, values) => ReactNode)',
      default: 'false',
      description: {
        ko: '라벨 옆에 현재 값을 보여 줍니다. 함수를 주면 서식을 직접 정합니다',
        en: 'Shows the current value beside the label. Pass a function to format it'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 채도가 빠지고 페이지가 비쳐 보이며, 포커스 순서에서 빠집니다',
        en: 'Unavailable. Loses its saturation, lets the page through, and leaves the tab order'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: 'form 제출 시 이 컨트롤을 식별하는 이름',
        en: 'Identifies the control when a form is submitted'
      }
    }
  ],

  PlSwitch: [
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '트랙의 크기와 옆 글자의 타입 스케일',
        en: 'The size of the track and the type scale beside it'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '켜졌을 때 트랙을 채우는 그러데이션',
        en: 'The gradient the track fills with when it is on'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '트랙 옆의 글자. Base UI의 Field가 엮어 주므로 눌러도 전환됩니다',
        en: "The text beside the track. Wired to it by Base UI's Field, so pressing it flips the switch"
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '라벨 아래 보조 설명', en: 'Helper text under the label' }
    },
    {
      name: 'error',
      type: 'ReactNode',
      description: {
        ko: '오류 메시지. 존재 자체가 invalid 상태를 만듭니다',
        en: 'Error message below. Its presence also turns the switch invalid'
      }
    },
    {
      name: 'invalid',
      type: 'boolean',
      description: {
        ko: '메시지 없이 invalid로 만듭니다. 기본값은 error에 내용이 있는지 여부',
        en: 'Forces the invalid state without a message. Defaults to whether error has content'
      }
    },
    {
      name: 'labelPlacement',
      type: "'start' | 'end'",
      default: "'end'",
      shared: true,
      description: {
        ko: '라벨이 놓이는 쪽. start는 설정 목록용으로, 라벨이 한 열을 이루고 스위치가 오른쪽에 정렬됩니다',
        en: 'Which side the label sits on. start is for a settings list, where the labels form a column and the switches line up'
      }
    },
    {
      name: 'checked',
      type: 'boolean',
      description: {
        ko: '켜짐 상태. onCheckedChange와 함께 controlled로 씁니다',
        en: 'The on state. Use with onCheckedChange for a controlled switch'
      }
    },
    {
      name: 'defaultChecked',
      type: 'boolean',
      default: 'false',
      description: { ko: 'uncontrolled일 때의 시작 상태', en: 'The starting state, uncontrolled' }
    },
    {
      name: 'onCheckedChange',
      type: '(checked: boolean, details) => void',
      description: { ko: '상태가 바뀔 때 호출됩니다', en: 'Called with the new state' }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '상태는 보이지만 바꿀 수 없습니다',
        en: 'The state is shown but cannot be changed'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 채도가 빠지고 페이지가 비쳐 보이며, 포커스 순서에서 빠집니다',
        en: 'Unavailable. Loses its saturation, lets the page through, and leaves the tab order'
      }
    },
    {
      name: 'name · value · required',
      type: 'string · string · boolean',
      description: {
        ko: '네이티브 form 제출을 위한 것들. Base UI가 그대로 받습니다',
        en: 'For a native form submission. Passed straight to Base UI'
      }
    }
  ],

  PlTable: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      sizeDescription: {
        ko: '셀의 타입 스케일과 행 높이',
        en: 'The type scale of a cell and the height of a row'
      },
      densityDescription: {
        ko: '셀 여백만 바꿉니다. 타입 스케일은 그대로',
        en: 'Cell padding only — never the type scale'
      }
    }),
    {
      name: 'columns',
      type: 'readonly PlTableColumn<Row>[]',
      required: true,
      description: {
        ko: '열 정의. 나타나는 순서대로',
        en: 'The columns, in the order they appear'
      }
    },
    {
      name: 'rows',
      type: 'readonly Row[]',
      required: true,
      description: { ko: '행 데이터', en: 'The rows' }
    },
    {
      name: 'getRowKey',
      type: '(row: Row, index: number) => Key',
      description: {
        ko: '행마다의 안정적인 key. 기본값은 index라서 정렬이나 필터가 있는 표에는 맞지 않습니다',
        en: 'A stable key per row. Defaults to the index, which is wrong for a table that sorts or filters'
      }
    },
    {
      name: 'caption',
      type: 'ReactNode',
      description: {
        ko: '표 위에 놓이며, 표의 접근 가능한 이름으로 읽힙니다',
        en: "Shown above the grid, and read out as the table's accessible name"
      }
    },
    {
      name: 'empty',
      type: 'ReactNode',
      default: "'No data'",
      description: {
        ko: 'rows가 비었을 때 행 대신 보여 줄 내용',
        en: 'What to show instead of rows when there are none'
      }
    },
    {
      name: 'striped',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '한 행 걸러 하나씩 옅게 칠합니다. 눈이 가로로 따라가야 하는 넓은 표에서 유용합니다',
        en: 'Tints every other row. Useful on a wide table where the eye has to track across'
      }
    },
    {
      name: 'hoverable',
      type: 'boolean',
      default: 'false',
      description: { ko: '포인터 아래 행에 불을 켭니다', en: 'Lights the row under the pointer' }
    },
    {
      name: 'stickyHeader',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '본문이 스크롤되는 동안 헤더를 고정합니다. 표의 높이를 제한하는 무언가가 있어야 의미가 있습니다',
        en: "Pins the header while the body scrolls. Only does anything if something constrains the table's height"
      }
    },
    {
      name: 'onRowClick',
      type: '(row: Row, index: number) => void',
      description: {
        ko: '행을 활성화할 수 있게 만듭니다. hover 처리도 함께 켜집니다',
        en: 'Makes rows activatable. Also turns on the hover treatment'
      }
    }
  ],

  PlTableColumn: [
    {
      name: 'key',
      type: 'string',
      required: true,
      description: {
        ko: '열을 식별하고, render가 없으면 각 행에서 읽을 속성 이름이 됩니다',
        en: 'Identifies the column, and — unless render says otherwise — names the property to read off each row'
      }
    },
    {
      name: 'header',
      type: 'ReactNode',
      description: {
        ko: '열 제목. 생략하면 key가 그대로 쓰입니다',
        en: 'The heading. Defaults to the key, which is usually not what you want'
      }
    },
    {
      name: 'width',
      type: 'number | string',
      description: {
        ko: '기본 너비. 숫자는 px, 문자열은 CSS 길이. 표는 여전히 폭을 채우도록 열을 조정하므로 보장이 아니라 출발 비율입니다',
        en: 'The default width. A number is pixels, a string is any CSS length. The table still balances columns to fill the sheet, so this is a starting proportion'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'start'",
      shared: true,
      description: {
        ko: '텍스트 정렬. 숫자는 자릿수가 맞도록 보통 end',
        en: 'Text alignment. Numbers usually want end so their digits line up'
      }
    },
    {
      name: 'render',
      type: '(row: Row, index: number) => ReactNode',
      description: {
        ko: '셀을 직접 그립니다. 없으면 row[key]를 그대로 렌더링합니다',
        en: 'Renders the cell. Without it the cell is row[key] rendered as-is'
      }
    }
  ],

  PlTextLink: [
    {
      name: 'href',
      type: 'string',
      required: true,
      description: { ko: '링크가 가리키는 곳', en: 'Where the link goes' }
    },
    {
      name: 'underline',
      type: "'always' | 'hover' | 'none'",
      default: "'always'",
      description: {
        ko: '밑줄을 언제 그릴지. boolean이 아닌 이유는, 밑줄 없음이 nav나 footer에서는 진짜 선택지이고 그런 선택은 명시적이어야 하기 때문입니다',
        en: 'When the underline is drawn. Not a boolean, because no underline is a real choice in a nav or a footer and should have to be spelled out'
      }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '의미론적 색 역할. 기본값이 **없습니다** — 문단 속 링크는 보통 문단의 색에 밑줄만 그은 것입니다',
        en: 'Semantic colour role. There is **no** default — a link in a paragraph is usually the paragraph colour with a line under it'
      }
    },
    {
      name: 'size',
      type: SIZE,
      shared: true,
      description: {
        ko: '타입 스케일. 역시 기본값이 없습니다 — 문장 속 링크는 그 문장의 크기입니다',
        en: 'The type scale. Also no default — a link inside a sentence is the size of the sentence'
      }
    },
    {
      name: 'newTab',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '새 탭에서 엽니다. rel로 opener를 보호하고, icon을 켜고, 스크린리더용 문구를 덧붙입니다',
        en: 'Opens in a new tab, with the protective rel, the icon on, and a line for a screen reader'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode | boolean',
      description: {
        ko: '라벨 뒤의 표시. true는 newTab이면 화살표, 아니면 체인. false는 아무것도. 생략하면 newTab을 따릅니다',
        en: 'The mark after the label. true draws the arrow when newTab is on and the chain otherwise; false draws nothing. Left out, it follows newTab'
      }
    },
    {
      name: 'newTabLabel',
      type: 'string',
      default: "'(opens in a new tab)'",
      description: {
        ko: 'newTab 링크에서 라벨 뒤에 읽히는 문구. 화면에는 그려지지 않습니다',
        en: 'What a screen reader hears after the label on a newTab link. Never drawn'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'a 대신 다른 요소로 렌더링합니다 — 보통은 라우터의 Link',
        en: 'Renders something other than an a — the Link a router brings, most of the time'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '라벨', en: 'The label' }
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
