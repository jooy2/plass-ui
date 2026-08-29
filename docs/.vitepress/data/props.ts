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

/**
 * Every prop an indicator takes, with one sentence swapped.
 *
 * Written once because the whole claim the three shapes make is that they are
 * one component: a `value` of `null` has to mean the same thing on a bar as on
 * a ring, and two tables would be two sentences by the third edit. Only `size`
 * differs, because only `size` measures a different thing.
 *
 * There is no `sharedProps` here on purpose: an indicator has no `variant` (it
 * is one material), no `density` (there is nothing to pad) and no `elevation`
 * (it is cut into the surface it sits on, and a groove does not float).
 */
function progressProps(sizeDescription: Text): PropRow[] {
  return [
    {
      name: 'value',
      type: 'number | null',
      default: 'null',
      description: {
        ko: 'min과 max 사이의 진행도. null은 indeterminate — 뭔가 진행 중이고 얼마나 남았는지는 아무도 모르는 경우입니다',
        en: 'How far along, between min and max. null is the indeterminate case: something is happening and nobody knows how much of it is left'
      }
    },
    {
      name: 'min',
      type: 'number',
      default: '0',
      description: { ko: '범위의 아래끝', en: 'The bottom of the range' }
    },
    {
      name: 'max',
      type: 'number',
      default: '100',
      description: { ko: '범위의 위끝', en: 'The top of the range' }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '무엇이 진행 중인지. 값과 함께 스크린리더가 읽습니다',
        en: 'A name for what is loading. Read out with the value by a screen reader'
      }
    },
    {
      name: 'showValue',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '값을 글자로 함께 보여 줍니다. format이 없으면 범위에 대한 백분율입니다',
        en: 'Shows the value as text beside the shape. A percentage of the range unless format says otherwise'
      }
    },
    {
      name: 'format',
      type: 'Intl.NumberFormatOptions',
      description: {
        ko: '값을 어떻게 쓸지. Intl.NumberFormat 옵션이라 바이트나 통화도 그대로 됩니다',
        en: 'How to format the value when it is shown — Intl.NumberFormat options, so bytes and currencies work as well as plain numbers'
      }
    },
    { name: 'size', type: SIZE, default: "'md'", shared: true, description: sizeDescription },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. 채워지는 쪽의 그러데이션이 됩니다',
        en: 'Semantic colour role. It becomes the gradient of the filled part'
      }
    }
  ];
}

/**
 * Everything the four pickers agree on.
 *
 * Written once because they are one control in four shapes, and a reader who
 * has learned what `shouldDisableDate` does on a date picker must not have to
 * read a subtly different sentence about it on a range picker. What each one
 * adds — a second calendar, a clock, a set of presets — is spelled out in its
 * own table under these.
 */
function pickerProps(options: {
  /** Its own `format` default, which is the one thing that always differs. */
  format: string;
  formatDescription: Text;
  /** Its own `closeOnSelect` default, and the sentence explaining it. */
  closeOnSelect: string;
  closeOnSelectDescription: Text;
  /** How the hidden input spells the value. */
  nameDescription: Text;
}): PropRow[] {
  return [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: 'trigger의 재질. PlTextField와 같은 껍데기를 씁니다. solid는 시트에 파인 우물',
        en: "The material of the trigger, drawn on PlTextField's shell. solid is the well cut into the sheet"
      },
      elevationDescription: {
        ko: 'trigger의 그림자 깊이. 팝업은 3으로 고정입니다 — 팝업은 정말로 페이지 위에 떠 있습니다',
        en: 'Drop shadow depth of the trigger. The popup has its own, fixed at 3 — it genuinely floats'
      }
    }),
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '팝업이 열려 있는지. onOpenChange와 함께 controlled로 씁니다',
        en: 'Whether the popup is open. Use with onOpenChange to control it'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: { ko: '팝업이 열린 채로 시작할지', en: 'Whether the popup starts open' }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: {
        ko: '팝업이 열리고 닫힐 때 호출됩니다',
        en: 'Called when the popup opens or closes'
      }
    },
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: 'BCP 47 태그. 월과 요일 이름, 헤더 두 버튼의 순서, trigger가 날짜를 쓰는 방식을 정합니다. 기본은 브라우저의 것',
        en: "BCP 47 tag deciding the month and weekday names, the order of the header's two buttons, and how the trigger writes the value. Defaults to the browser's"
      }
    },
    {
      name: 'format',
      type: 'Intl.DateTimeFormatOptions',
      default: options.format,
      description: options.formatDescription
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
      name: 'clearable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '값을 비우는 ×를 보여 줍니다',
        en: 'Offers the × that empties the control'
      }
    },
    {
      name: 'closeOnSelect',
      type: 'boolean',
      default: options.closeOnSelect,
      description: options.closeOnSelectDescription
    },
    {
      name: 'labels',
      type: 'Partial<PlPickerLabels>',
      description: {
        ko: 'picker가 스스로 말하는 문자열들. 전부 영어 기본값이 있습니다. 날짜 이름은 여기 없습니다 — 그건 Intl이 압니다',
        en: 'The strings the picker says on its own behalf. Every one has an English default. The dates are never in here: Intl knows those'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: { ko: 'trigger 위 라벨', en: 'Label above the trigger' }
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
        en: 'Error message below. Its presence also turns the control invalid'
      }
    },
    {
      name: 'invalid',
      type: 'boolean',
      description: {
        ko: '메시지 없이 invalid로 만듭니다',
        en: 'Forces the invalid state without a message'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '값 앞의 글리프. 기본은 달력(또는 시계)입니다',
        en: 'The glyph before the value. A calendar, or a clock, by default'
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
        ko: '값은 보이지만 바꿀 수 없고, 팝업도 열리지 않습니다',
        en: 'The value is shown but cannot be changed, and the popup does not open'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '사용 불가', en: 'Unavailable' }
    },
    {
      name: 'required',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '폼 제출 전에 값이 있어야 하는지',
        en: 'Whether a value must be chosen before the form is submitted'
      }
    },
    { name: 'name', type: 'string', description: options.nameDescription }
  ];
}

/** The three bounds every date-carrying picker takes. */
const dateBoundsProps: PropRow[] = [
  {
    name: 'minDate',
    type: 'Date | null',
    description: {
      ko: '고를 수 있는 가장 이른 날. 일 단위입니다 — 시각은 무시됩니다',
      en: 'The earliest day that may be chosen. Day-granular — the time is ignored'
    }
  },
  {
    name: 'maxDate',
    type: 'Date | null',
    description: { ko: '고를 수 있는 가장 늦은 날', en: 'The latest day that may be chosen' }
  },
  {
    name: 'shouldDisableDate',
    type: '(date: Date) => boolean',
    description: {
      ko: '범위 안이지만 그래도 쓸 수 없는 날을 막습니다 — 주말, 공휴일, 이미 예약된 방',
      en: 'Blocks individual days that are inside the range but still not available — weekends, holidays, a room that is already booked'
    }
  },
  {
    name: 'weekStartsOn',
    type: '0 | 1 | 2 | 3 | 4 | 5 | 6',
    description: {
      ko: '한 주가 시작하는 요일. 기본은 locale이 말하는 대로이고, 0이 일요일입니다',
      en: 'Which day the week starts on. Defaults to whatever the locale says; 0 is Sunday'
    }
  },
  {
    name: 'defaultMonth',
    type: 'Date',
    description: {
      ko: '값이 없을 때 달력이 열리는 달',
      en: 'Which month the calendar opens on when there is no value'
    }
  }
];

/** The four the clock columns take, shared by the two pickers that draw one. */
const timeColumnProps: PropRow[] = [
  {
    name: 'hour12',
    type: 'boolean',
    description: {
      ko: 'AM/PM 열이 붙은 12시간 다이얼. 기본은 locale이 하는 대로입니다',
      en: 'A 12-hour dial with an AM/PM column. Defaults to whatever the locale does'
    }
  },
  {
    name: 'showSeconds',
    type: 'boolean',
    default: 'false',
    description: { ko: '초 열을 더합니다', en: 'Adds the seconds column' }
  },
  {
    name: 'hourStep',
    type: 'number',
    default: '1',
    description: { ko: '각 열의 행 간격', en: 'How far apart the rows of each column are' }
  },
  {
    name: 'minuteStep',
    type: 'number',
    default: '1',
    description: { ko: 'hourStep를 보세요', en: 'See hourStep' }
  },
  {
    name: 'secondStep',
    type: 'number',
    default: '1',
    description: { ko: 'hourStep를 보세요', en: 'See hourStep' }
  },
  {
    name: 'shouldDisableTime',
    type: '(value: Date, unit: TimeUnit) => boolean',
    description: {
      ko: '개별 행을 막습니다. 열마다 행마다, 그 행이 만들어 낼 시각과 그 행이 속한 열을 받아 한 번씩 호출됩니다 — "오후는 안 됨"만큼 성길 수도, 1분만큼 촘촘할 수도 있습니다',
      en: 'Blocks individual rows. Called once per row per column with the instant that row would produce and the column it is in, so a rule may be as coarse as "no afternoons" or as fine as one minute'
    }
  }
];

/**
 * The settings every `PlAnimate*` component takes.
 *
 * Written once for the reason the shared style axes are: a `delay` of 200 has
 * to mean the same thing on a fade and on a marquee, and eleven hand-written
 * tables would be eleven subtly different sentences by the third edit. Only the
 * two numbers that genuinely differ per effect — how long one run takes, and
 * how many times it runs — are passed in.
 */
function animateProps(options: {
  duration: string;
  repeat?: string;
  /** Names a component genuinely does not take — a reel has no direction. */
  omit?: string[];
}): PropRow[] {
  const rows: PropRow[] = [
    {
      name: 'duration',
      type: 'number',
      default: options.duration,
      shared: true,
      description: {
        ko: '한 번 도는 데 걸리는 시간(ms). CSS 문자열이 아니라 숫자입니다',
        en: 'How long one run takes, in milliseconds. A number, never a CSS string'
      }
    },
    {
      name: 'delay',
      type: 'number',
      default: '0',
      shared: true,
      description: {
        ko: '시작하기까지 기다리는 시간(ms)',
        en: 'How long before it starts, in milliseconds'
      }
    },
    {
      name: 'easing',
      type: 'string',
      default: 'the house curve',
      shared: true,
      description: {
        ko: 'CSS가 쓰는 그대로의 이징 곡선',
        en: 'The easing curve, written the way CSS writes it'
      }
    },
    {
      name: 'repeat',
      type: "number | 'infinite'",
      default: options.repeat ?? '1',
      shared: true,
      description: {
        ko: "몇 번 반복할지. 끝없이 돌리려면 Infinity가 아니라 'infinite' — CSS에 그 단어로 그대로 쓰이기 때문입니다",
        en: "How many times it runs. 'infinite' rather than Infinity, because that word is what reaches CSS"
      }
    },
    {
      name: 'alternate',
      type: 'boolean',
      default: 'false',
      shared: true,
      description: {
        ko: '한 번 걸러 거꾸로 돌립니다. 반복이 처음으로 튀어 돌아가는 대신 되돌아옵니다',
        en: 'Runs every other pass backwards, so a repeat returns instead of jumping'
      }
    },
    {
      name: 'paused',
      type: 'boolean',
      default: 'false',
      shared: true,
      description: { ko: '있는 자리에 멈춰 세웁니다', en: 'Holds the animation where it is' }
    },
    {
      name: 'trigger',
      type: "'mount' | 'visible' | 'hover' | 'manual'",
      default: "'mount'",
      shared: true,
      description: {
        ko: '무엇이 시작시키는지. mount는 화면에 올라오자마자, visible은 스크롤되어 보일 때, hover는 포인터나 focus가 닿을 때, manual은 play가 시킬 때만',
        en: 'What starts it: mount as soon as it is on the page, visible when it is scrolled into view, hover while the pointer or focus is on it, manual only when play says so'
      }
    },
    {
      name: 'play',
      type: 'boolean',
      shared: true,
      description: {
        ko: 'trigger가 manual일 때 실행합니다. false → true가 될 때마다 처음부터 다시 돕니다',
        en: 'Runs it when trigger is manual. Each false → true starts it over'
      }
    },
    {
      name: 'once',
      type: 'boolean',
      default: 'true',
      shared: true,
      description: {
        ko: 'trigger="visible"에서 처음 한 번만 돌릴지. 끄면 화면에 다시 들어올 때마다 다시 돕니다',
        en: 'With trigger="visible", whether it runs only the first time. Off, it runs again every time the element comes back into view'
      }
    },
    {
      name: 'threshold',
      type: 'number',
      default: '0.2',
      shared: true,
      description: {
        ko: 'trigger="visible"에서 얼마나 보여야 보이는 것으로 칠지, 0에서 1 사이',
        en: 'With trigger="visible", how much of the element has to be on screen before it counts as visible, from 0 to 1'
      }
    }
  ];

  return options.omit ? rows.filter((row) => !options.omit!.includes(row.name)) : rows;
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

  PlAnimateAppear: [
    {
      name: 'stagger',
      type: 'number',
      default: '70',
      description: {
        ko: '한 자식 뒤 다음 자식이 시작하기까지의 시간(ms). 이것이 효과의 전부이고, 나머지는 자식 하나가 하는 일입니다',
        en: 'How long after one child the next one starts, in milliseconds. This is the whole effect — everything else is what a single child does'
      }
    },
    {
      name: 'from',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'bottom'",
      shared: true,
      description: { ko: '각 자식이 들어오는 모서리', en: 'Which edge each child drifts in from' }
    },
    {
      name: 'distance',
      type: 'number | string',
      default: "'0.75rem'",
      description: {
        ko: '각 자식이 이동하는 거리. 짧은 것은 의도입니다 — 화면 밖에서의 등장이 아니라 내려앉음이고, 여덟 개짜리 목록 위의 긴 이동은 덩어리 전체를 움직이는 것으로 만듭니다',
        en: 'How far each child travels. Short on purpose: this is a settling, not an entrance from off screen, and a long travel over a list of eight turns the whole block into something moving'
      }
    },
    {
      name: 'fade',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '각 자식이 내려앉으면서 함께 나타납니다',
        en: 'Fades each child in as it settles'
      }
    },
    {
      name: 'reverse',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '마지막 자식부터 첫 자식까지 목록을 거꾸로 돌립니다',
        en: 'Runs the list from the last child to the first'
      }
    },
    ...animateProps({ duration: '380' }),
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <div>'
      }
    }
  ],
  PlAnimateBlink: [
    {
      name: 'min',
      type: 'number',
      default: '0',
      description: {
        ko: '주기의 바닥에서 얼마나 옅어지는지, 0과 1 사이. 맥동하는 동안에도 읽혀야 하는 것이라면 올려 잡으세요',
        en: 'How faint it gets at the bottom of the cycle, between 0 and 1. Raise it for something that has to stay readable while it pulses'
      }
    },
    ...animateProps({ duration: '1000', repeat: "'infinite'" }),
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <div>'
      }
    }
  ],
  PlAnimateFade: [
    {
      name: 'mode',
      type: "'in' | 'out'",
      default: "'in'",
      description: {
        ko: '내용이 도착하는지 떠나는지. out은 같은 키프레임을 거꾸로 돌린 것이고, 끝난 자리에 그대로 붙들려 있습니다',
        en: 'Whether the content arrives or leaves. out is the same keyframe run backwards, and it is held where it ends'
      }
    },
    {
      name: 'from',
      type: 'number',
      default: '0',
      description: {
        ko: '시작하는 불투명도, 0과 1 사이. 완전히 사라지면 안 되는 내용이라면 올려 잡으세요',
        en: 'The opacity it starts from, between 0 and 1. Raise it for content that should never be completely gone'
      }
    },
    ...animateProps({ duration: '300' }),
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <div>'
      }
    }
  ],
  PlAnimateGrow: [
    {
      name: 'mode',
      type: "'in' | 'out'",
      default: "'in'",
      description: {
        ko: '내용이 펼쳐지는지 접히는지. out은 같은 키프레임을 거꾸로 돌린 것입니다',
        en: 'Whether the content unfolds or folds away. out is the same keyframe run backwards'
      }
    },
    {
      name: 'from',
      type: 'number',
      default: '0.8',
      description: {
        ko: '최종 크기에 대한 배수로서, 시작하는 배율. 1보다 크면 페이지 위로 솟아오르는 대신 내려앉습니다',
        en: 'The scale it starts from, as a multiple of its final size. Above 1 it settles down onto the page instead of up out of it'
      }
    },
    {
      name: 'origin',
      type: 'string',
      default: "'center'",
      description: {
        ko: '나머지가 움직이는 동안 제자리에 있는 점 — CSS transform-origin 그대로. top은 아래로 펼치고, bottom left는 모서리에서 나옵니다',
        en: 'Which point stays put while the rest moves — any CSS transform-origin. top unfolds downwards, bottom left out of a corner'
      }
    },
    {
      name: 'fade',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '커지면서 함께 나타납니다. 이미 페이지에 있고 크기만 바뀌는 것이라면 끄세요',
        en: 'Fades in as it grows. Turn it off for something already on the page that is only changing size'
      }
    },
    ...animateProps({ duration: '320' }),
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <div>'
      }
    }
  ],
  PlAnimateHeadline: [
    {
      name: 'interval',
      type: 'number',
      default: '2600',
      description: {
        ko: '다음 줄이 올라오기까지 한 줄을 붙들어 두는 시간(ms). 줄이 도착한 순간부터 세므로 주기 길이가 아니라 읽는 시간입니다',
        en: 'How long each line is held before the next one comes up, in milliseconds. Counted from the moment a line arrives, so it is reading time rather than a cycle length'
      }
    },
    {
      name: 'index',
      type: 'number',
      description: {
        ko: '어느 줄이 떠 있는지. 넘기면 릴을 직접 몰 수 있고, 컴포넌트는 자기 타이머를 돌리지 않습니다',
        en: 'Which line is showing. Pass it to drive the reel yourself, and the component stops running a timer of its own'
      }
    },
    {
      name: 'defaultIndex',
      type: 'number',
      default: '0',
      description: {
        ko: 'uncontrolled 릴이 시작하는 자리',
        en: 'Where an uncontrolled reel starts'
      }
    },
    {
      name: 'onIndexChange',
      type: '(index: number) => void',
      description: {
        ko: '방금 올라온 줄과 함께 호출됩니다',
        en: 'Called with the line that has just come up'
      }
    },
    {
      name: 'loop',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '마지막 줄 다음에 다시 시작합니다. 끄면 마지막 줄에서 멈춰 그대로 있습니다',
        en: 'Starts again after the last line. Off, the reel stops on the last one and stays there'
      }
    },
    {
      name: 'rise',
      type: 'number | string',
      default: "'100%'",
      description: {
        ko: "줄이 올라오거나 나갈 때 이동하는 거리. '100%'는 줄 하나의 높이입니다",
        en: "How far a line travels as it comes up or leaves. '100%' is one line's own height"
      }
    },
    ...animateProps({ duration: '460', repeat: "'infinite'", omit: ['alternate'] })
  ],
  PlAnimateLighting: [
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '빛이 그려지는 계열. 호는 지나가면서 그 계열의 두 끝 사이를 돕니다 — solid 채움과 같은 규칙입니다',
        en: 'Which family the light is drawn in. The arc turns between that family two ends as it travels, exactly as a solid fill does'
      }
    },
    {
      name: 'glow',
      type: 'string',
      description: {
        ko: '의미론적 계열이 원하는 바가 아닐 때의 CSS 색. color를 덮어쓰고, 그러면 호는 도는 것을 멈춥니다 — 색 하나는 돌아갈 곳이 없습니다',
        en: 'A CSS colour, when a semantic family is not what is wanted. Overrides color, and the arc stops turning — one colour has nowhere to turn to'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '빛이 따라가는 radius. 안에 있는 것과 맞아야 합니다. 아니면 내용이 이미 둥글게 깎아 낸 모서리를 빛이 잘라 냅니다',
        en: 'The radius the light follows. It has to match what is inside, or the glow will cut a corner the content has rounded off'
      }
    },
    {
      name: 'spread',
      type: 'number',
      default: '3',
      description: {
        ko: '빛이 내용 바깥으로 뻗는 거리(px)',
        en: 'How far past the content the light reaches, in pixels'
      }
    },
    {
      name: 'arc',
      type: 'number',
      default: '50',
      description: {
        ko: '윤곽선 중 한 번에 밝아지는 각도. 작으면 달리는 불꽃, 크면 훑고 지나가는 빛입니다',
        en: 'How much of the outline is lit at once, in degrees. Small is a travelling spark; large is a sweep'
      }
    },
    {
      name: 'blur',
      type: 'number',
      default: '5',
      description: {
        ko: '빛의 부드러움(px). 0이면 가장자리가 딱 떨어지는 쐐기라 빛이 아니라 도형으로 읽힙니다',
        en: 'How soft the light is, in pixels. At 0 it is a hard-edged wedge, which reads as a graphic rather than as light'
      }
    },
    {
      name: 'reverse',
      type: 'boolean',
      default: 'false',
      description: { ko: '빛을 반대 방향으로 돌립니다', en: 'Runs the light the other way round' }
    },
    ...animateProps({ duration: '3000', repeat: "'infinite'" }),
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <div>'
      }
    }
  ],
  PlAnimateMarquee: [
    {
      name: 'orientation',
      type: "'horizontal' | 'vertical'",
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '띠가 흐르는 방향. 세로로 쓰려면 상자에 높이가 있어야 합니다',
        en: 'Which way the strip runs. Vertical needs a height on the box'
      }
    },
    {
      name: 'reverse',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '반대로 돌립니다 — 왼쪽에서 오른쪽으로, 또는 아래에서 위로',
        en: 'Runs it the other way — left to right, or bottom to top'
      }
    },
    {
      name: 'speed',
      type: 'number',
      default: '60',
      description: {
        ko: '내용이 흐르는 속도(초당 픽셀). duration이 아니라 speed라서, 로고 넷짜리 띠와 마흔짜리 띠가 같은 속도로 움직입니다',
        en: 'How fast the content travels, in pixels per second. A speed rather than a duration, so a strip of four logos and a strip of forty move at the same pace'
      }
    },
    {
      name: 'gap',
      type: 'number | string',
      default: "'2rem'",
      description: {
        ko: '항목 사이, 그리고 마지막 항목과 다음 회차의 첫 항목 사이의 간격',
        en: 'The gap between items, and between the last item and the first of the next pass'
      }
    },
    {
      name: 'copies',
      type: 'number',
      default: '2',
      description: {
        ko: '내용을 몇 벌 이어 붙일지. 컨테이너만큼 넓은 내용이라면 둘로 충분하고, 자기 뒤에 구멍을 남길 만큼 짧을 때 올리세요',
        en: 'How many copies of the content are laid end to end. Two is enough for anything at least as wide as its container; raise it when the content is short enough to leave a hole behind itself'
      }
    },
    {
      name: 'pauseOnHover',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '포인터가 올라가 있는 동안 멈춥니다. 지나가는 것을 실제로 읽거나 누를 수 있도록',
        en: 'Stops while the pointer is on it, so something scrolling past can actually be read or clicked'
      }
    },
    ...animateProps({ duration: 'measured from speed', repeat: "'infinite'" })
  ],
  PlAnimateRotate: [
    {
      name: 'mode',
      type: "'in' | 'out'",
      default: "'in'",
      description: {
        ko: '제자리로 돌아 들어오는지 돌아 나가는지',
        en: 'Whether the content turns into place or out of it'
      }
    },
    {
      name: 'from',
      type: 'number',
      default: '-180',
      description: {
        ko: '시작하는 각도(도). 음수는 반시계 방향입니다',
        en: 'The angle it starts at, in degrees. Negative is anticlockwise'
      }
    },
    {
      name: 'to',
      type: 'number',
      default: '0',
      description: {
        ko: '끝나는 각도(도). from과 함께라서 컴포넌트 하나가 제자리로 들어오는 회전과 끝나지 않는 회전을 모두 담습니다 — from={0} to={360} repeat="infinite"',
        en: 'The angle it ends at, in degrees. Together with from this is what makes one component cover both a turn into place and an endless spin: from={0} to={360} repeat="infinite"'
      }
    },
    {
      name: 'origin',
      type: 'string',
      default: "'center'",
      description: {
        ko: '무엇을 중심으로 도는지 — CSS transform-origin 그대로',
        en: 'Which point it turns about — any CSS transform-origin'
      }
    },
    {
      name: 'fade',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '돌면서 함께 나타납니다. 계속 도는 경우에는 끄세요 — 반복되는 fade는 깜빡임으로 읽힙니다',
        en: 'Fades in as it turns. Turn it off for a continuous spin, where a repeating fade would read as flickering'
      }
    },
    ...animateProps({ duration: '440' }),
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <div>'
      }
    }
  ],
  PlAnimateSlide: [
    {
      name: 'mode',
      type: "'in' | 'out'",
      default: "'in'",
      description: {
        ko: '들어오는지 나가는지. out은 들어왔을 그 모서리로 나갑니다',
        en: 'Whether the content slides in or slides away. out leaves by the same edge it would have come from'
      }
    },
    {
      name: 'from',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'bottom'",
      shared: true,
      description: {
        ko: '어느 모서리에서 오는지. 라이브러리 전체가 그렇듯 물리적입니다 — 위에서 내려오는 패널은 어떤 쓰기 방향에서도 위에서 내려옵니다',
        en: 'Which edge it travels from. Physical, as it is everywhere in the library: a panel coming down from the top comes from the top in every writing direction'
      }
    },
    {
      name: 'distance',
      type: 'number | string',
      default: "'100%'",
      description: {
        ko: "얼마나 이동할지 — CSS 길이 또는 픽셀 숫자. '100%'는 요소 자신의 너비나 높이라, 자기 모서리 뒤에서 나타나게 됩니다",
        en: "How far it travels — a CSS length, or a number in pixels. '100%' is the element's own width or height, which is what makes it appear from behind its own edge"
      }
    },
    {
      name: 'fade',
      type: 'boolean',
      default: 'true',
      description: { ko: '미끄러지면서 함께 나타납니다', en: 'Fades in as it slides' }
    },
    ...animateProps({ duration: '360' }),
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <div>'
      }
    }
  ],
  PlAnimateTyping: [
    {
      name: 'text',
      type: 'string',
      description: {
        ko: '텍스트. 중첩해 쓰는 것보다 넘기는 편이 쉬울 때. children을 덮어씁니다',
        en: 'The text, when it is easier to pass than to nest. Overrides children'
      }
    },
    {
      name: 'speed',
      type: 'number',
      default: '24',
      description: {
        ko: '치는 속도(초당 글자 수). 긴 문단과 짧은 문단이 같은 시간이 아니라 같은 속도로 쳐지도록',
        en: 'How fast it is typed, in characters per second, so a long paragraph and a short one are typed at the same pace rather than in the same time'
      }
    },
    {
      name: 'hold',
      type: 'number',
      default: '1400',
      description: {
        ko: '다 친 텍스트를 반복 전에 붙들어 두는 시간(ms)',
        en: 'How long the finished text is held before it repeats, in milliseconds'
      }
    },
    {
      name: 'erase',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '반복 전에 한 프레임에 지우는 대신 다시 지웁니다. repeat가 한 번을 넘을 때만 뜻이 있습니다',
        en: 'Deletes the text again before repeating, rather than clearing it in one frame. Only means anything when repeat is more than once'
      }
    },
    {
      name: 'eraseSpeed',
      type: 'number',
      default: 'twice speed',
      description: {
        ko: '지우는 속도(초당 글자 수). 지우는 것은 보통 치는 것의 두 배쯤 빠릅니다 — 사람이 실제로 그렇게 합니다',
        en: 'How fast it is deleted, in characters per second. Deleting is usually about twice as fast as typing, which is what a person actually does'
      }
    },
    {
      name: 'caret',
      type: 'boolean',
      default: 'true',
      description: { ko: '텍스트 뒤의 블록', en: 'The block after the text' }
    },
    {
      name: 'caretChar',
      type: 'ReactNode',
      default: "'|'",
      description: { ko: 'caret을 무엇으로 그릴지', en: 'What the caret is drawn as' }
    },
    ...animateProps({ duration: 'speed decides', omit: ['easing', 'alternate'] })
  ],
  PlAnimateZoom: [
    {
      name: 'mode',
      type: "'in' | 'out'",
      default: "'in'",
      description: {
        ko: '내용이 앞으로 나오는지 뒤로 물러나는지. out은 같은 키프레임을 거꾸로 돌린 것입니다',
        en: 'Whether the content comes forward or falls away. out is the same keyframe run backwards'
      }
    },
    {
      name: 'from',
      type: 'number',
      default: '0.4',
      description: {
        ko: '최종 크기에 대한 배수로서, 시작하는 배율. 1보다 크면 실제보다 크게 도착해 제자리로 내려앉고, 읽는 사람 쪽으로 오는 것처럼 읽힙니다',
        en: 'The scale it starts from, as a multiple of its final size. Above 1 it arrives oversized and settles back, which reads as coming towards the reader'
      }
    },
    {
      name: 'fade',
      type: 'boolean',
      default: 'true',
      description: { ko: 'zoom하면서 함께 나타납니다', en: 'Fades in as it zooms' }
    },
    ...animateProps({ duration: '320' }),
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <div>'
      }
    }
  ],
  PlAspectRatio: [
    {
      name: 'ratio',
      type: 'number | string',
      default: '1',
      description: {
        ko: '지킬 비율. CSS가 쓰는 그대로 — 숫자(1.5) 또는 비(‘16 / 9’)',
        en: "The proportion to hold, written the way CSS writes it — a number (1.5) or a ratio ('16 / 9')"
      }
    },
    {
      name: 'fit',
      type: "'cover' | 'contain' | 'fill' | 'none'",
      default: "'cover'",
      description: {
        ko: '안에 든 미디어 하나를 어떻게 맞출지. 직계 자식인 img · video · canvas · svg · iframe에만 닿습니다',
        en: 'How a single piece of media inside is fitted. Reaches a direct img, video, canvas, svg or iframe only'
      }
    },
    {
      name: 'rounded',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '모서리를 size 단계의 하우스 반경으로 깎습니다',
        en: 'Rounds the corners to the size step of the house radius ladder'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: 'rounded가 쓰는 반경 단계. 시트의 크기이지 높이나 타입 스케일이 아닙니다',
        en: 'Which radius step rounded uses — the size of the sheet, never a height or a type scale'
      }
    },
    {
      name: 'render',
      type: 'RenderProp',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다 (<figure />, <a href="…" />)',
        en: 'Renders something other than a <div> (<figure />, <a href="…" />)'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '비율 안에 들어갈 것', en: 'What the proportion holds' }
    }
  ],

  PlAvatar: [
    {
      name: 'variant',
      type: VARIANT,
      default: "'ghost'",
      shared: true,
      description: {
        ko: '폴백 뒤 시트의 재질. 사진이 로드되고 나면 가장자리를 빼고는 보이지 않습니다. 기본값이 ghost인 이유는, 채도 높은 원이 가득한 디렉터리에서는 아무 이름도 읽히지 않기 때문입니다',
        en: 'What the sheet behind the fallback is made of — invisible once a picture has loaded, apart from the edge it keeps. ghost by default, because a page of saturated circles is a page nobody can read a name off'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '사진이 그려지는 상자. 컨트롤 높이와 같은 사다리라, 툴바에서 avatar와 그 옆 버튼의 높이가 맞습니다',
        en: 'The box the picture is drawn in — the control heights, so an avatar and the button beside it in a toolbar are the same height'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. avatar는 색을 입는 대상 자체라, 시트가 틴트를 받습니다',
        en: 'Semantic colour role. An avatar is the thing being coloured, so its sheet takes the tint'
      }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      default: '0',
      shared: true,
      description: {
        ko: '그림자 깊이. avatar는 시트 위에 놓인 키가 아니라 페이지에 끼워 넣은 사진입니다',
        en: 'Drop shadow depth. An avatar is a picture set into the page rather than a key resting on it'
      }
    },
    {
      name: 'src',
      type: 'string',
      description: {
        ko: '사진. 로드되기 전까지 — 그리고 실패하면 영원히 — 폴백이 그려집니다',
        en: 'The picture. Until it loads, and forever if it fails, the fallback is what is drawn'
      }
    },
    {
      name: 'srcSet',
      type: 'string',
      description: {
        ko: '다른 해상도의 후보 이미지들. img에서와 같습니다',
        en: 'Candidate images at other resolutions, as on any img'
      }
    },
    {
      name: 'alt',
      type: 'string',
      description: {
        ko: '사진이 하는 말. 기본값은 name이고, name도 없으면 빈 문자열입니다',
        en: 'What the picture says. Defaults to name, and to an empty string when there is no name'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '누구 또는 무엇인지. 사진의 이름이 되고, 이니셜이 여기서 파생되며, 스크린리더가 이니셜 대신 듣는 문장이 됩니다',
        en: 'Who or what this is. It names the picture, the initials are derived from it, and it is what a screen reader hears instead of them'
      }
    },
    {
      name: 'initials',
      type: 'string',
      description: {
        ko: '이니셜을 직접 씁니다. 파생 규칙이 틀린 이름을 위한 것입니다',
        en: 'The initials, written out, for when the derivation rule got them wrong'
      }
    },
    {
      name: 'shape',
      type: "'circle' | 'square'",
      default: "'circle'",
      description: {
        ko: '크롭. circle은 초상, square는 라이브러리의 필렛 — 사각형 가장자리까지 그려진 로고나 아이콘을 위한 것입니다',
        en: 'The crop. circle for a portrait, square for the library’s own fillet — for a logo or an icon drawn to the edges of a rectangle'
      }
    },
    {
      name: 'delay',
      type: 'number',
      description: {
        ko: '폴백을 그리기까지 기다리는 시간(ms). 캐시된 이미지가 도착하는 시간 정도로 두면 이니셜이 깜빡이지 않습니다',
        en: 'How long to wait before drawing the fallback, in milliseconds. Set it to about the time a cached image takes and the initials stop flashing'
      }
    },
    {
      name: 'imageProps',
      type: "Omit<ComponentPropsWithoutRef<'img'>, 'src' | 'srcSet' | 'alt'>",
      description: {
        ko: 'img에 필요한 나머지 — loading, crossOrigin, referrerPolicy',
        en: 'Anything else the img needs — loading, crossOrigin, referrerPolicy'
      }
    },
    {
      name: 'onLoadingStatusChange',
      type: "(status: 'idle' | 'loading' | 'loaded' | 'error') => void",
      description: {
        ko: '사진이 상태를 옮길 때마다 호출됩니다',
        en: 'Called as the picture moves between the four loading states'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '이니셜 대신 그려지는 폴백 — 아이콘, 로고, 이모지 하나',
        en: 'The fallback, drawn instead of the initials — an icon, a logo, a single emoji'
      }
    }
  ],

  PlBadge: [
    ...sharedProps({
      variant: "'solid'",
      size: "'md'",
      variantDescription: {
        ko: '마커의 재질. 마커가 색을 입는 대상 자체라 시트가 틴트를 받습니다. 바쁜 표면에서는 ghost가 알맞습니다',
        en: 'What the marker is made of. The marker is the thing being coloured, so its sheet takes the tint. ghost is the one for a busy surface'
      },
      sizeDescription: {
        ko: '마커의 높이. 컨트롤 사다리보다 훨씬 아래에 있는 자기 사다리 — md는 18px로, 두 자리 숫자가 읽히는 가장 작은 크기입니다',
        en: 'The marker height. Its own ladder, well below the control one — md is 18px, the smallest a two-digit number stays legible at'
      },
      densityDescription: {
        ko: '숫자 양옆의 여백만 바꿉니다',
        en: 'The room around the digits, and nothing else'
      }
    }),
    {
      name: 'content',
      type: 'ReactNode',
      description: {
        ko: '배지가 하는 말. 보통 개수, 가끔 단어. 생략하면 점을 그립니다 — 알릴 것은 있지만 셀 것이 없을 때의 정직한 모양입니다',
        en: 'What the badge says — usually a count, sometimes a word. Omit it and it draws a dot, which is the honest thing when there is something to report but nothing to count'
      }
    },
    {
      name: 'max',
      type: 'number',
      default: '99',
      description: {
        ko: '숫자 content의 상한. 넘으면 +를 붙입니다. 단어는 어떻게 자를지 알 수 없으므로 숫자에만 적용됩니다',
        en: 'Caps a numeric content and adds a +. Numbers only: a badge cannot know how to truncate a word'
      }
    },
    {
      name: 'dot',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'content가 있어도 점으로 그리고, 내용은 스크린리더에만 남깁니다. 조용해야 하는 모서리를 위한 것입니다',
        en: 'Draws the marker as a dot even with content, keeping the content for screen readers only. For the corner that has to stay quiet'
      }
    },
    {
      name: 'showZero',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'content가 0일 때도 보일지. 읽지 않은 메시지 0개는 소식이 아니고, 사라지지 않는 배지는 아무 뜻도 갖지 못합니다',
        en: 'Whether a content of 0 is shown. Zero unread messages is not news, and a badge that never goes away stops meaning anything'
      }
    },
    {
      name: 'invisible',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '앵커를 언마운트하지 않고 마커만 숨깁니다. 자리를 지키므로 다시 보여도 아래가 다시 배치되지 않습니다',
        en: 'Hides the marker without unmounting the anchor. It keeps its box, so showing it again does not relayout what it sits on'
      }
    },
    {
      name: 'placement',
      type: "'top-start' | 'top-end' | 'bottom-start' | 'bottom-end'",
      default: "'top-end'",
      shared: true,
      description: {
        ko: '앵커의 어느 모서리에 놓일지. 논리 속성이라 쓰기 방향에 따라 뒤집힙니다',
        en: 'Which corner of the anchor it sits on. Logical properties, so it flips with the writing direction'
      }
    },
    {
      name: 'overlap',
      type: "'square' | 'circle'",
      default: "'square'",
      description: {
        ko: '아래에 놓인 것의 모양. 원의 모서리는 중심에서 더 멀어서, 아이콘 버튼에 맞춘 배지는 avatar에서 떠 보입니다',
        en: 'The shape of the thing underneath. A circle’s corner is further from its centre, so a badge tuned for an icon button hangs off an avatar'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '스크린리더가 원본 content 대신 듣는 문장. 종 옆의 3은 그냥 "3"이고, "읽지 않은 알림 3개"가 문장입니다',
        en: 'What a screen reader hears instead of the raw content. A 3 beside a bell is just "3"; "3 unread notifications" is the sentence'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '배지가 붙는 대상. 없으면 배지는 inline으로 놓이는 독립 마커가 됩니다',
        en: 'What the badge is pinned to. Without it the badge is a standalone marker that lays out inline'
      }
    }
  ],

  PlBlockquote: [
    ...sharedProps({
      variant: "'ghost'",
      size: "'md'",
      variantDescription: {
        ko: '시트의 재질. 컨테이너가 그렇듯 시트에는 색이 들어가지 않습니다 — 남의 말을 담기 때문입니다. 기본값 ghost는 여백의 선 하나뿐이고, 그것이 인용문이 오래도록 취해 온 모양입니다',
        en: 'What the sheet is made of. As on any container, the sheet is never dyed — a quote holds somebody else’s words. ghost, the default, is a rule in the margin and nothing else'
      },
      sizeDescription: {
        ko: '인용문의 타입 스케일. 제목의 크기에 문단의 행간을 씁니다',
        en: 'The quote’s type scale — a heading’s size with a paragraph’s leading'
      }
    }),
    {
      name: 'author',
      type: 'ReactNode',
      description: {
        ko: '말한 사람. 이것이 있으면 인용문이 figcaption을 가진 figure가 됩니다 — 출처는 인용문에 *대한* 것이지 말해진 내용의 일부가 아니라는 HTML 명세대로입니다',
        en: 'Who said it. Its presence is what turns the quote into a figure with a figcaption, which is the markup the HTML spec asks for'
      }
    },
    {
      name: 'source',
      type: 'ReactNode',
      description: {
        ko: '어디서 왔는지 — 책, 강연, 페이지. cite 안에 그려집니다. cite는 저작물의 제목을 위한 요소이고, 명세상 사람 이름에는 쓰지 않습니다',
        en: 'Where it is from — a book, a talk, a page. Rendered inside a cite, which is for the title of a work and, per the spec, never for a person’s name'
      }
    },
    {
      name: 'cite',
      type: 'string',
      description: {
        ko: '인용문을 가져온 문서의 URL. blockquote의 cite 속성에 놓이며 기계만 읽고 아무에게도 보이지 않습니다',
        en: 'URL of the document the quote came from. Lands on the blockquote’s own cite attribute — machine-readable and shown to nobody'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode | false',
      description: {
        ko: '인용문 앞의 표시. 생략하면 기본 글리프, 노드를 주면 교체, false면 없앱니다',
        en: 'The mark drawn before the quote. Omit it for the house glyph, pass a node to replace it, pass false to take it away'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '말해진 내용', en: 'What was said' }
    }
  ],

  PlBottomNavigation: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      elevation: '0',
      variantDescription: {
        ko: '시트의 재질. 절대 물들지 않습니다 — 색 가족을 나르는 것은 현재 항목입니다',
        en: 'What the sheet is made of. Never dyed — the family is carried by the current item'
      },
      sizeDescription: {
        ko: '줄의 최소 높이, 글리프의 크기, 그 아래 이름의 타입 스케일',
        en: "The row's floor, the glyph's size, and the type scale of the name under it"
      },
      elevationDescription: {
        ko: '드롭 섀도 깊이. 0이 기본이고 평평합니다 — 이 바는 창 가장자리에 붙어 있습니다',
        en: 'Drop shadow depth. 0 and flat: this bar is attached to the edge of the window'
      }
    }),
    {
      name: 'value',
      type: 'string | number | null',
      description: {
        ko: '독자가 있는 목적지. onValueChange와 함께 controlled로 씁니다',
        en: 'The destination the reader is on. Use with onValueChange for a controlled bar'
      }
    },
    {
      name: 'defaultValue',
      type: 'string | number | null',
      default: 'null',
      description: {
        ko: 'uncontrolled일 때 시작 목적지',
        en: 'Which starts current, for an uncontrolled bar'
      }
    },
    {
      name: 'onValueChange',
      type: '(value: string | number) => void',
      description: {
        ko: '고른 목적지로 호출됩니다',
        en: 'Called with the destination that was chosen'
      }
    },
    {
      name: 'position',
      type: "'static' | 'sticky' | 'fixed'",
      default: "'fixed'",
      description: {
        ko: '페이지 스크롤 안에서 바가 놓이는 방식',
        en: "How the bar sits in the page's scroll"
      }
    },
    {
      name: 'labels',
      type: "'all' | 'selected' | 'none'",
      default: "'all'",
      description: {
        ko: '어떤 이름을 그릴지. 그리지 않는 이름도 문서에는 남습니다',
        en: 'Which names are drawn. An undrawn name is still in the document'
      }
    },
    {
      name: 'divider',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '위쪽 가장자리에 얇은 선을 그립니다',
        en: 'Draws a hairline along the top edge'
      }
    },
    {
      name: 'safeArea',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '홈 인디케이터에서 줄을 떼어 놓습니다. 시트는 화면 바닥까지 그대로 닿습니다',
        en: 'Keeps the row clear of the home indicator. The sheet still reaches the bottom'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '모든 목적지가 반응하지 않습니다',
        en: 'Every destination stops answering'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: { ko: '바가 안내되는 이름', en: 'The name the bar is announced by' }
    },
    {
      name: 'render',
      type: 'RenderProp',
      description: {
        ko: '<nav> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <nav>'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'PlBottomNavigationItem들', en: 'The PlBottomNavigationItems' }
    }
  ],

  PlBottomNavigationItem: [
    {
      name: 'value',
      type: 'string | number',
      required: true,
      description: {
        ko: '목적지를 식별합니다. onValueChange가 보고하는 값입니다',
        en: 'Identifies the destination. What onValueChange reports'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: { ko: '이름 위의 글리프', en: 'The glyph above the name' }
    },
    {
      name: 'href',
      type: 'string',
      description: {
        ko: '항목을 버튼이 아니라 진짜 링크로 렌더링합니다',
        en: 'Renders the item as a real link rather than as a button'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '쓸 수 없지만 집합에는 남습니다',
        en: 'Unavailable, but still part of the set'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '목적지의 이름. labels가 그리지 않아도 읽힙니다',
        en: "The destination's name. Read out even when labels keeps it undrawn"
      }
    }
  ],

  PlBox: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '시트의 재질. 셋 다 색이 들어가지 않습니다 — box가 담는 것은 자기 색을 가지고 옵니다',
        en: 'What the sheet is made of. None of the three is dyed: what a box holds arrives with its own colours'
      },
      sizeDescription: {
        ko: '**시트**의 크기 — 반경과 여백. 높이도 타입 스케일도 아닙니다',
        en: 'The size of the **sheet**: its radius and its padding. Never a height, never the type scale'
      },
      elevationDescription: {
        ko: '드롭 섀도 깊이. 0이 기본이고 평평합니다 — box를 페이지에서 떼어 놓는 것은 유리 가장자리입니다',
        en: 'Drop shadow depth. 0 and flat: the glass edge is what separates the box from the page'
      }
    }),
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '안쪽 여백. 가장자리까지 닿아야 하는 내용에서는 끄세요',
        en: 'Inner padding. Turn it off for content that should reach the edges'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'div가 아닌 다른 요소로 렌더링합니다 — section, li, 무엇이든',
        en: 'Renders something other than a div — a section, an li, anything'
      }
    }
  ],

  PlBreadcrumb: [
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: { ko: '단계의 타입 스케일', en: 'Type scale of the steps' }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '링크가 hover될 때 입는 색 계열',
        en: 'The colour family a link picks up when it is hovered'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: '단계 사이의 간격만 바꿉니다',
        en: 'The gap between the steps, and nothing else'
      }
    },
    {
      name: 'separator',
      type: "'chevron' | 'arrow' | 'slash' | 'dot' | ReactNode",
      default: "'chevron'",
      description: {
        ko: '두 단계 사이의 표시. 이름 넷 중 하나이거나 임의의 노드. 넷인 이유는 구분자의 차이가 장식이 아니라 의미이기 때문입니다 — chevron과 arrow는 "그다음", slash는 "경로", dot은 "한 가지의 동렬"입니다',
        en: 'The mark between two steps. One of the four names, or any node. Four rather than a free-for-all because the difference is meaning, not decoration: chevron and arrow say "and then", slash says "path", dot says "peers of one thing"'
      }
    },
    {
      name: 'maxItems',
      type: 'number',
      description: {
        ko: '가운데를 …로 접기 전까지 보여 줄 단계 수. 생략하면 아무리 길어져도 전부 보여 줍니다',
        en: 'How many steps to show before the middle is folded away behind a …. Left out, the whole trail is shown however long it gets'
      }
    },
    {
      name: 'itemsBeforeCollapse',
      type: 'number',
      default: '1',
      description: {
        ko: '접힌 자취의 앞쪽에 남는 단계 수',
        en: 'How many steps stay at the front of a folded trail'
      }
    },
    {
      name: 'itemsAfterCollapse',
      type: 'number',
      default: '1',
      description: { ko: '뒤쪽에 남는 단계 수', en: 'How many stay at the end' }
    },
    {
      name: 'expandable',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '…를 누르면 그 자리에서 펼칠지. 끄면 접힌 표시가 그냥 표시로 남습니다',
        en: 'Whether pressing the … unfolds the trail in place. Turn it off to leave the fold as a plain mark'
      }
    },
    {
      name: 'label',
      type: 'string',
      default: "'Breadcrumb'",
      description: {
        ko: '자취가 불리는 이름. 화면에는 그려지지 않습니다',
        en: 'The name the trail is announced by. Never drawn'
      }
    },
    {
      name: 'expandLabel',
      type: 'string',
      default: "'Show the hidden steps'",
      description: {
        ko: '…가 불리는 이름. 화면에는 그려지지 않습니다',
        en: 'What the … is announced as. Never drawn'
      }
    },
    {
      name: 'structuredData',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '자취를 BreadcrumbList로 한 번 더, script type="application/ld+json"에 함께 냅니다. 페이지에 하나만 있을 수 있고 많은 앱이 이미 자기 SEO 계층에서 내보내므로 기본은 꺼짐입니다. 접혀서 안 보이는 단계까지 전부 들어갑니다',
        en: 'Emits the trail a second time as a BreadcrumbList in a script tag. Off by default — a page can only have one, and many apps already emit theirs. Every step goes in, including the ones a fold is hiding'
      }
    },
    {
      name: 'baseUrl',
      type: 'string',
      description: {
        ko: 'structuredData에서 상대 href를 무엇에 대고 풀지 — 사이트의 origin. 검색 엔진은 절대 URL을 원합니다',
        en: 'What relative hrefs are resolved against for structuredData — the site’s origin. Search engines want an absolute URL there'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'PlBreadcrumbItem들', en: 'The PlBreadcrumbItems' }
    }
  ],

  PlBreadcrumbItem: [
    {
      name: 'href',
      type: 'string',
      description: { ko: '단계를 링크로 그립니다', en: 'Renders the step as a link' }
    },
    {
      name: 'onClick',
      type: '(event: MouseEvent) => void',
      description: {
        ko: '단계를 눌렀을 때. href가 없으면 button으로 그려집니다',
        en: 'Fires when the step is pressed. Renders it as a button when there is no href'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 앞의 것 — 집 글리프, 저장소 avatar',
        en: 'Content before the label — a home glyph, a repository avatar'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: { ko: '라벨 뒤의 것', en: 'Content after the label' }
    },
    {
      name: 'current',
      type: 'boolean',
      description: {
        ko: '이 단계가 지금 보고 있는 페이지임을 표시하고, 그래서 링크이기를 그만둡니다. 마지막 단계는 그것만으로 현재이므로, 이 prop은 독자가 있지 않은 곳에서 끝나는 자취를 위한 것입니다 — 어디든 지정하면 마지막 단계에서 표시가 사라집니다',
        en: 'Marks this step as the page you are on, which stops it being a link. The last step is the current one on its own, so this is for a trail that ends somewhere the reader is not — and setting it anywhere takes the mark off the last step'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      shared: true,
      description: {
        ko: '사용할 수 없음. 응답을 멈추고 자리는 지킵니다',
        en: 'Unavailable. Stops answering, keeps its place in the trail'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '단계의 라벨', en: 'The step’s label' }
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

  /**
   * Every axis here is deliberately without a default.
   *
   * A group states the axes once for the set, and an axis it does not state is
   * one a button falls back to its *own* default on — so the table cannot use
   * `sharedProps`, which exists to print a default per component.
   */
  PlButtonGroup: [
    {
      name: 'variant',
      type: VARIANT,
      shared: true,
      description: {
        ko: '그룹 전체의 재질. 지정하지 않으면 각 버튼의 기본값(solid)을 씁니다',
        en: 'The material of the whole run. Unset, each button keeps its own default (solid)'
      }
    },
    {
      name: 'size',
      type: SIZE,
      shared: true,
      description: {
        ko: '그룹 전체의 높이와 타입 스케일. 한 버튼만 크기가 다른 그룹을 막는 것이 이 컴포넌트의 절반입니다',
        en: 'Height and type scale for the whole run. A group with one button a size out is the failure this prevents'
      }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '그룹 전체의 색 역할. 버튼이 스스로 정한 color가 우선합니다',
        en: "Semantic colour role for the run. A button's own color still wins"
      }
    },
    {
      name: 'density',
      type: DENSITY,
      shared: true,
      description: { ko: '그룹 전체의 가로 패딩', en: 'Horizontal padding for the run' }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      shared: true,
      description: {
        ko: '그룹 전체의 그림자 깊이',
        en: 'Drop shadow depth for the run'
      }
    },
    {
      name: 'orientation',
      type: "'horizontal' | 'vertical'",
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '버튼이 늘어서는 방향. vertical은 동등한 액션을 쌓은 메뉴입니다',
        en: 'Which way the buttons run. vertical is a stacked menu of equal actions'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      description: {
        ko: '그룹의 모든 버튼을 한 번에 비활성화합니다',
        en: 'Disables every button in the group at once'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '컨테이너 너비만큼 늘리고 버튼끼리 너비를 똑같이 나눠 갖습니다',
        en: 'Stretches to the container and divides the width evenly between buttons'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '버튼들. 진짜 PlButton으로 남습니다',
        en: 'The buttons. They stay real PlButtons'
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

  PlCarousel: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '프레임의 재질. 색은 들어가지 않습니다 — 캐러셀은 남의 사진을 담습니다. ghost에는 프레임이 아예 없습니다',
        en: "What the frame is made of. Never dyed — a carousel holds other people's pictures. ghost has no frame at all"
      },
      sizeDescription: {
        ko: '프레임의 반경, 화살표의 크기, 점의 크기',
        en: "The frame's radius, the size of the arrows and the size of the dots"
      },
      elevationDescription: {
        ko: '프레임의 드롭 섀도 깊이. 0이 기본이고 평평합니다',
        en: 'Drop shadow depth of the frame. 0 is the default and it is flat'
      }
    }),
    {
      name: 'value',
      type: 'number',
      description: {
        ko: '보이는 슬라이드, 0부터. onValueChange와 함께 controlled로 씁니다',
        en: 'Which slide is showing, counted from 0. Use with onValueChange'
      }
    },
    {
      name: 'defaultValue',
      type: 'number',
      default: '0',
      description: {
        ko: 'uncontrolled일 때 처음 보이는 슬라이드',
        en: 'Which starts showing, for an uncontrolled carousel'
      }
    },
    {
      name: 'onValueChange',
      type: '(index: number) => void',
      description: {
        ko: '보이게 된 슬라이드로 호출됩니다',
        en: 'Called with the slide now in view'
      }
    },
    {
      name: 'loop',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '화살표가 마지막에서 첫 슬라이드로 감깁니다. 끄면 양 끝에서 반응하지 않습니다',
        en: 'Whether the arrows wrap from the last slide back to the first. Off, they go inert at the ends'
      }
    },
    {
      name: 'autoPlay',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '스스로 넘어갑니다. hover·포커스·배경 탭·reduced motion에서 모두 멈춥니다',
        en: 'Advances on its own. Pauses on hover, on focus, in a background tab, and for reduced motion'
      }
    },
    {
      name: 'interval',
      type: 'number',
      default: '5000',
      description: {
        ko: '슬라이드 하나가 머무는 시간, ms',
        en: 'How long each slide is held, in milliseconds'
      }
    },
    {
      name: 'arrows',
      type: 'boolean',
      default: 'true',
      description: { ko: '이전/다음 버튼', en: 'The previous/next buttons' }
    },
    {
      name: 'indicators',
      type: 'boolean',
      default: 'true',
      description: { ko: '프레임 아래의 위치 점들', en: 'The row of position dots under the frame' }
    },
    {
      name: 'label',
      type: 'string',
      default: "'Carousel'",
      description: {
        ko: '캐러셀의 접근 가능한 이름. 절대 그려지지 않습니다',
        en: "The carousel's accessible name. Never drawn"
      }
    },
    {
      name: 'previousLabel',
      type: 'string',
      default: "'Previous slide'",
      description: { ko: '화살표의 이름', en: "The arrow's name" }
    },
    {
      name: 'nextLabel',
      type: 'string',
      default: "'Next slide'",
      description: { ko: '화살표의 이름', en: "The arrow's name" }
    },
    {
      name: 'slideLabel',
      type: '(index: number, count: number) => string',
      description: {
        ko: '슬라이드 하나와 그 점의 이름을 짓습니다',
        en: 'Names one slide, and the dot that goes to it'
      }
    }
  ],

  PlChatBubble: [
    {
      name: 'side',
      type: "'start' | 'end'",
      default: "'start'",
      shared: true,
      description: {
        ko: '누구의 메시지인지. them/me나 left/right가 아닌 이유는 대화가 언어가 흐르는 방향으로 흐르기 때문입니다. 행이 어느 쪽으로 놓이는지와 시트의 어느 모서리가 짧게 잘리는지를 정합니다',
        en: 'Whose message this is. Not them/me or left/right, because a thread runs the way the language does. It decides which way the row runs and which corner of the sheet is cut short'
      }
    },
    {
      name: 'variant',
      type: VARIANT,
      default: "'glass'",
      shared: true,
      description: {
        ko: '버블 표면의 재질. 버블은 색을 입는 대상 자체라 solid가 안을 채우고 글자가 --p-on-solid로 넘어갑니다. side와 묶여 있지 않은 것은 일부러입니다 — 어느 쪽을 채울지는 컴포넌트가 아니라 제품의 결정입니다',
        en: 'What the bubble’s surface is made of. A bubble is the thing being coloured, so solid floods it and the text switches to --p-on-solid. Deliberately not tied to side: which end is filled is a decision about the product, not about the component'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: { ko: '버블의 타입 스케일과 여백', en: 'Type scale and padding of the bubble' }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: { ko: '의미론적 색 역할', en: 'Semantic colour role' }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: '버블 안쪽 여백만 바꿉니다',
        en: 'Padding inside the bubble, and nothing else'
      }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      default: '0',
      shared: true,
      description: {
        ko: '그림자 깊이. 메시지는 대화 위에 떠 있기보다 그 안에 놓입니다',
        en: 'Drop shadow depth. A message lies in the thread rather than floating over it'
      }
    },
    {
      name: 'name',
      type: 'ReactNode',
      description: { ko: '보낸 사람. 버블 위에 놓입니다', en: 'Who sent it, above the bubble' }
    },
    {
      name: 'time',
      type: 'ReactNode',
      description: { ko: '보낸 시각. 이름 옆에 놓입니다', en: 'When it was sent, beside the name' }
    },
    {
      name: 'avatar',
      type: 'ReactNode',
      description: {
        ko: '보낸 사람의 사진 — 대화가 쓰는 크기의 PlAvatar. 없으면 버블이 행 전체를 씁니다',
        en: 'The sender’s picture — a PlAvatar at the size the thread uses. Left out, the bubble takes the whole row'
      }
    },
    {
      name: 'status',
      type: "'sending' | 'sent' | 'delivered' | 'read' | 'failed'",
      description: {
        ko: '메시지가 어디까지 갔는지. 버블 아래 표시로 그려집니다. 없으면 아무것도 그리지 않습니다 — 받은 메시지에는 보여 줄 전달 상태가 없습니다',
        en: 'How far the message has got, drawn as a mark under the bubble. Left out, nothing is drawn: a received message has no delivery state worth showing'
      }
    },
    {
      name: 'statusLabel',
      type: 'string',
      description: {
        ko: '표시가 읽히는 말. 화면에는 그려지지 않습니다',
        en: 'What the mark is read out as. Never drawn'
      }
    },
    {
      name: 'typing',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '메시지 대신 점 세 개를 그립니다. children은 그대로 두므로, 메시지가 도착하면 같은 버블이 되돌아옵니다',
        en: 'Draws the three dots instead of the message. What children holds is left alone, so the same bubble can go back to it when the message arrives'
      }
    },
    {
      name: 'typingLabel',
      type: 'string',
      default: "'Typing…'",
      description: {
        ko: '점이 읽히는 말. 화면에는 그려지지 않습니다',
        en: 'What the dots are read out as. Never drawn'
      }
    },
    {
      name: 'media',
      type: 'ReactNode',
      description: {
        ko: '사진, 영상, 지도 — 글 위에 가장자리까지 그려지고 버블의 모서리가 그것을 잘라 냅니다',
        en: 'A picture, a video, a map — drawn edge to edge above the text, so the bubble’s corners crop it'
      }
    },
    {
      name: 'preview',
      type: 'PlChatBubbleLinkPreview',
      description: {
        ko: '메시지 속 링크를 글 아래 카드로 펼칩니다',
        en: 'A link in the message, unfurled into a card under the text'
      }
    },
    {
      name: 'actions',
      type: 'ReactNode',
      description: {
        ko: '메시지 자신의 액션. 버블 옆에 놓이고, 행에 hover하거나 안의 무언가가 focus를 받기 전까지는 비켜서 있습니다',
        en: 'The message’s own actions. Sits beside the bubble and stays out of the way until the row is hovered or something in it takes focus'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '메시지', en: 'The message' }
    }
  ],

  PlChatBubbleLinkPreview: [
    {
      name: 'url',
      type: 'string',
      required: true,
      description: { ko: '카드가 가리키는 곳', en: 'Where the card goes' }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '페이지의 제목', en: 'The page’s title' }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '요약. 두 줄로 잘립니다', en: 'Its summary, clamped to two lines' }
    },
    {
      name: 'image',
      type: 'string',
      description: {
        ko: '카드 위쪽에 걸치는 공유 이미지',
        en: 'The share image, drawn across the top of the card'
      }
    },
    {
      name: 'site',
      type: 'ReactNode',
      description: {
        ko: '누가 낸 것인지 — 도메인, 사이트 이름',
        en: 'Who published it — a domain, a site name'
      }
    },
    {
      name: 'newTab',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '새 탭에서 엽니다. opener를 지키는 rel이 함께 붙습니다',
        en: 'Opens the card in a new tab, with the rel that protects the opener'
      }
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

  PlChip: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 재질. chip은 색을 입는 대상 자체라 시트가 틴트를 받습니다. 필터 바는 chip의 줄이고, 그러데이션 키가 늘어선 줄에서는 무엇도 주요 액션이 아닙니다',
        en: 'What the surface is made of. A chip is the thing being coloured, so its sheet takes the tint. glass by default: a row of gradient keys is a row in which nothing is the primary action'
      },
      sizeDescription: {
        ko: '컨트롤 사다리에서 한 칸 아래 — md chip은 sm 컨트롤(40px가 아니라 32px)입니다. chip은 행이 맞춰 서는 컨트롤이 아니라 행 *안*의 토큰이기 때문입니다',
        en: 'One step down the control ladder — a md chip is a sm control, 32px rather than 40px, because a chip is a token inside a row rather than a control the row lines up against'
      }
    }),
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 앞에 놓이는 것 — 아이콘, 상태 점, avatar',
        en: 'Content placed before the label — an icon, a status dot, an avatar'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 뒤, count 앞에 놓이는 것',
        en: 'Content after the label, before any count'
      }
    },
    {
      name: 'count',
      type: 'ReactNode',
      description: {
        ko: 'chip 끝에 놓이는 숫자. 자기 판 위에 그려져서 "Errors 12"가 두 단어가 아니라 개수를 가진 하나의 토큰으로 읽힙니다',
        en: 'A number set into the end of the chip, on its own small plate, so "Errors 12" reads as one token with a count rather than as two words'
      }
    },
    {
      name: 'onClick',
      type: '(event: MouseEvent) => void',
      description: {
        ko: '넘기면 라벨이 진짜 button이 됩니다. 껍데기는 span으로 남습니다 — button 안의 button은 브라우저가 파싱하며 풀어 버리는 잘못된 HTML입니다',
        en: 'Passing it turns the label into a real button. The shell stays a span: a button inside a button is invalid HTML that browsers un-nest on parse'
      }
    },
    {
      name: 'onDelete',
      type: '(event: MouseEvent) => void',
      description: {
        ko: '넘기는 것이 삭제 버튼을 나타나게 합니다. 라벨과는 별개의 tab stop을 가진 두 번째 진짜 button입니다',
        en: 'Passing it is what makes the delete button appear — a second real button with its own tab stop, separate from the label'
      }
    },
    {
      name: 'deleteLabel',
      type: 'string',
      default: "'Remove'",
      description: {
        ko: '삭제 버튼의 접근 가능한 이름. 화면에는 그려지지 않습니다',
        en: 'Accessible name of the delete button. Never drawn'
      }
    },
    {
      name: 'selected',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '켜진 필터. 색 계열을 바꾸는 대신 자기 variant가 이미 놓인 사다리에서 한 칸 올라갑니다 — 켜진 필터도 여전히 같은 필터입니다',
        en: 'A filter that is on. It moves one step up the ladder its own variant already sits on rather than changing the colour family — a filter that is on is still the same filter'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      shared: true,
      description: {
        ko: '사용할 수 없음. 다른 곳과 같이 빛이 꺼집니다',
        en: 'Unavailable. The light goes out, the same way it does everywhere else'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '라벨', en: 'The label' }
    }
  ],

  PlCollapsible: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '시트의 재질. 색이 들어가지 않습니다 — 접힘은 남의 내용을 담습니다. ghost는 산문 속이나 카드 안에서 쓰는 것입니다',
        en: "What the sheet is made of. Never dyed — a fold holds other people's content. ghost is the one for running prose or a card"
      },
      sizeDescription: {
        ko: '반경, 여백, 헤더의 타입 스케일',
        en: "The radius, the padding and the header's type scale"
      },
      elevationDescription: {
        ko: '드롭 섀도 깊이. 0이 기본입니다 — 접힘은 페이지에 끼워 넣은 것이지 그 위에 뜬 판이 아닙니다',
        en: 'Drop shadow depth. 0 is the default: a fold is set into the page, not floating over it'
      }
    }),
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '패널이 보이는지. onOpenChange와 함께 controlled로 씁니다',
        en: 'Whether the panel is showing. Use with onOpenChange for a controlled fold'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: { ko: 'uncontrolled일 때의 시작 상태', en: 'Where an uncontrolled fold starts' }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: {
        ko: '트리거가 열거나 닫을 때 호출됩니다',
        en: 'Called when the trigger opens or closes the panel'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '트리거에 쓰이는 제목', en: 'The heading on the trigger' }
    },
    {
      name: 'subtitle',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 한 줄. 한 단계 작고 muted입니다',
        en: 'A second line under the title, one step down the type scale and muted'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '제목 앞의 내용 — 아이콘, 상태 점, 개수',
        en: 'Content before the title — an icon, a status dot, a count'
      }
    },
    {
      name: 'action',
      type: 'ReactNode',
      description: {
        ko: '헤더 끝에 고정되는 컨트롤. 트리거 **바깥**입니다 — 버튼 안의 버튼은 브라우저가 다시 씁니다',
        en: 'A control pinned to the end of the header, **outside** the trigger: a button inside a button is markup the browser rewrites'
      }
    },
    {
      name: 'trigger',
      type: 'ReactElement',
      description: {
        ko: '헤더를 통째로 자기 컨트롤로 바꿉니다. 넘긴 요소가 트리거가 됩니다',
        en: 'Replaces the header entirely with a control of your own. The element you pass becomes the trigger'
      }
    },
    {
      name: 'indicator',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '상태를 알리려 돌아가는 셰브런',
        en: 'The chevron at the end of the header, turned to report the state'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '트리거가 반응하지 않고 패널은 그대로 남습니다',
        en: 'The trigger stops answering and the panel stays as it is'
      }
    },
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: { ko: '패널 내용의 안쪽 여백', en: "Inner padding around the panel's content" }
    },
    {
      name: 'hiddenUntilFound',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '닫힌 패널을 DOM에 남겨 브라우저의 페이지 검색이 찾고 열 수 있게 합니다. keepMounted를 덮어씁니다',
        en: "Keeps a closed panel in the DOM so the browser's own page search can find and open it. Overrides keepMounted"
      }
    },
    {
      name: 'keepMounted',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '닫힌 패널을 DOM에 남깁니다. 만드는 비용이 크거나 폼 상태를 가진 내용을 위한 것입니다',
        en: 'Keeps a closed panel in the DOM. For content that is expensive to build, or that holds form state'
      }
    }
  ],

  PlCombobox: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: 'field의 재질. PlTextField와 같은 껍데기를 씁니다. solid는 시트에 파인 우물',
        en: "The material of the field, drawn on PlTextField's shell. solid is the well cut into the sheet"
      },
      elevationDescription: {
        ko: 'field의 그림자 깊이. 팝업은 3으로 고정입니다 — 팝업은 정말로 페이지 위에 떠 있습니다',
        en: 'Drop shadow depth of the field. The popup has its own, fixed at 3 — it genuinely floats'
      }
    }),
    {
      name: 'items',
      type: 'readonly PlComboboxOption[]',
      required: true,
      description: {
        ko: '옵션 목록. PlSelect와 같은 모양입니다 — 호출자가 가진 건 거의 언제나 이미 배열입니다',
        en: 'The options, as data — the same shape PlSelect takes, because what a caller has is almost always an array already'
      }
    },
    {
      name: 'multiple',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '값을 여러 개 담을지. 고른 값들이 field 안의 chip이 되고 입력은 계속 필터링합니다',
        en: 'Whether more than one value may be held. The chosen ones become chips inside the field, and the input goes on filtering after each'
      }
    },
    {
      name: 'value',
      type: 'string | number | (string | number)[] | null',
      description: {
        ko: '선택된 값. onValueChange와 함께 controlled로 씁니다. multiple이면 배열입니다',
        en: 'The chosen value. Use with onValueChange for a controlled combobox; an array when multiple'
      }
    },
    {
      name: 'defaultValue',
      type: 'string | number | (string | number)[] | null',
      description: { ko: 'uncontrolled일 때 처음 선택된 값', en: 'The initially chosen value' }
    },
    {
      name: 'onValueChange',
      type: '(value: string | number | (string | number)[] | null) => void',
      description: { ko: '값이 바뀔 때 호출됩니다', en: 'Called with the new value' }
    },
    {
      name: 'onInputValueChange',
      type: '(inputValue: string) => void',
      description: {
        ko: '입력창의 글자가 바뀔 때 — 값이 아니라 필터 질의입니다',
        en: 'Called as the text in the input changes — the filter query, not the value'
      }
    },
    {
      name: 'allowCustom',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '목록에 없는 값을 확정할 수 있는지. 입력한 글자가 목록 끝의 행으로 제안됩니다 — blur에서 조용히 확정되는 게 아니라 사용자가 고르는 것입니다',
        en: 'Whether a value the list does not contain may be committed. The typed text is offered as its own row, so committing it is a choice rather than something that happens on blur'
      }
    },
    {
      name: 'customLabel',
      type: '(query: string) => ReactNode',
      default: 'Add “{query}”',
      description: { ko: '그 행이 뭐라고 말할지', en: 'What that row says' }
    },
    {
      name: 'clearable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'field를 비우는 ×를 보여 줍니다. 기본이 꺼짐인 건 한 번에 비울 수 있는 field는 실수로도 비워지기 때문입니다',
        en: 'Shows a × that empties the field. Off by default: a field that can be cleared in one click is a field that can be emptied by accident'
      }
    },
    {
      name: 'emptyMessage',
      type: 'ReactNode',
      default: "'No matches'",
      description: {
        ko: '일치하는 것도 없고 추가할 수도 없을 때 팝업이 하는 말',
        en: 'Shown in the popup when nothing matched and no value may be added'
      }
    },
    {
      name: 'limit',
      type: 'number',
      default: '-1',
      description: {
        ko: '한 번에 보여 줄 최대 행 수. -1은 전부',
        en: 'The most rows the list will show at once. -1 is all of them'
      }
    },
    {
      name: 'placeholder',
      type: 'string',
      description: {
        ko: '아무것도 입력하지 않았을 때 보이는 내용',
        en: 'Shown in the input while nothing is typed'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: 'field 위 라벨. Base UI의 Field가 서로 엮어 줍니다',
        en: "Label above the field, wired to it by Base UI's Field"
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: 'field 아래 보조 설명', en: 'Helper text below the field' }
    },
    {
      name: 'error',
      type: 'ReactNode',
      description: {
        ko: '오류 메시지. 존재 자체가 invalid 상태를 만듭니다',
        en: 'Error message below. Its presence also turns the combobox invalid'
      }
    },
    {
      name: 'invalid',
      type: 'boolean',
      description: {
        ko: '메시지 없이 invalid로 만듭니다',
        en: 'Forces the invalid state without a message'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '입력창 앞에 놓이는 내용. 1.2em으로 그려져 글자 크기를 따라갑니다',
        en: 'Content before the input. Sized in em, so it tracks the text'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '사용 불가', en: 'Unavailable' }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '값은 보이지만 바꿀 수 없음',
        en: 'The value is shown but cannot be changed'
      }
    },
    {
      name: 'required',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '폼 제출 전에 값이 있어야 하는지',
        en: 'Whether a value must be chosen before the form is submitted'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 제출 시 필드를 식별합니다',
        en: 'Identifies the field when a form is submitted'
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '팝업이 열려 있는지. onOpenChange와 함께 controlled로 씁니다',
        en: 'The popup is open. Use with onOpenChange for a controlled popup'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      description: { ko: '팝업이 열린 채로 시작할지', en: 'Whether the popup starts open' }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: {
        ko: '팝업이 열리고 닫힐 때 호출됩니다',
        en: 'Called when the popup opens or closes'
      }
    },
    {
      name: 'openLabel',
      type: 'string',
      default: "'Open'",
      description: {
        ko: '목록을 여는 버튼의 접근성 이름',
        en: 'Accessible name of the button that opens the list'
      }
    },
    {
      name: 'clearLabel',
      type: 'string',
      default: "'Clear'",
      description: { ko: '× 버튼의 접근성 이름', en: 'Accessible name of the clear button' }
    },
    {
      name: 'removeLabel',
      type: '(label: string) => string',
      default: 'Remove {label}',
      description: {
        ko: 'chip의 × 버튼 접근성 이름. chip의 라벨을 받습니다',
        en: "Accessible name of a chip's remove button. Receives the chip's label"
      }
    },
    {
      name: 'inputRef',
      type: 'Ref<HTMLInputElement>',
      description: {
        ko: '사용자가 입력하는 input에 대한 ref',
        en: 'A ref to the text input the user types into'
      }
    }
  ],

  PlComboboxOption: [
    {
      name: 'value',
      type: 'string | number',
      required: true,
      description: {
        ko: '제출되는 값이고, value / onValueChange가 말하는 언어입니다',
        en: 'Submitted, and what value / onValueChange speak in'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '목록과 입력창과 chip에 보이는 이름. 없으면 value 자체. ReactNode가 아니라 string인 건 필터가 이걸 대상으로 검색하고 text input에 써 넣기 때문입니다',
        en: 'Shown in the list, in the input and on the chip. Defaults to the value. A string rather than a ReactNode, because the filter types against it and it is written into a text input'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '고를 수 없지만 목록에는 남습니다',
        en: 'Unavailable, but still listed'
      }
    }
  ],

  PlContainer: [
    {
      name: 'maxWidth',
      type: SIZE + " | 'none'",
      default: "'none'",
      description: {
        ko: '내용이 넓어질 수 있는 한계. 브레이크포인트와 같은 사다리 — xs 30rem · sm 40rem · md 48rem · lg 64rem · xl 80rem',
        en: 'How wide the content is allowed to get, on the same ladder the breakpoints use — xs 30rem, sm 40rem, md 48rem, lg 64rem, xl 80rem'
      }
    },
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '양옆 여백. 끄면 가운데 정렬과 최대 너비만 남습니다',
        en: 'The gutter. Turn it off to keep the centring and the measure without the padding'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '여백의 스케일. 시트의 크기이지 높이나 타입 스케일이 아니고, maxWidth와도 무관합니다',
        en: "The gutter's scale — the size of the sheet, never a height or a type scale, and independent of maxWidth"
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '여백만 바꿉니다', en: 'Changes the gutter and nothing else' }
    },
    {
      name: 'centered',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'maxWidth가 화면보다 좁아진 뒤 남는 자리에 내용을 가운데로 놓습니다',
        en: 'Centres the content once maxWidth is narrower than the page'
      }
    },
    {
      name: 'render',
      type: 'RenderProp',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다 (<main />, <section />)',
        en: 'Renders something other than a <div> (<main />, <section />)'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '페이지', en: 'The page' }
    }
  ],

  PlDatePicker: [
    {
      name: 'value',
      type: 'Date | null',
      description: {
        ko: '선택된 날. onValueChange와 함께 controlled로 씁니다',
        en: 'The chosen day. Use with onValueChange for a controlled picker'
      }
    },
    {
      name: 'defaultValue',
      type: 'Date | null',
      description: { ko: 'uncontrolled일 때 시작하는 날', en: 'The day the picker starts on' }
    },
    {
      name: 'onValueChange',
      type: '(value: Date | null) => void',
      description: { ko: '값이 바뀔 때 호출됩니다', en: 'Called with the new value' }
    },
    ...dateBoundsProps,
    {
      name: 'showTodayButton',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '푸터에 오늘로 가는 지름길을 둡니다',
        en: 'Offers the shortcut to today in the footer'
      }
    },
    ...pickerProps({
      format: "{ dateStyle: 'medium' }",
      formatDescription: {
        ko: 'trigger가 날짜를 쓰는 방식. Intl로 그대로 넘어갑니다',
        en: 'How the trigger writes the chosen date. Passed straight to Intl'
      },
      closeOnSelect: 'true',
      closeOnSelectDescription: {
        ko: '날을 고르는 즉시 팝업을 닫습니다',
        en: 'Closes the popup as soon as a day is chosen'
      },
      nameDescription: {
        ko: '폼 제출 시 필드를 식별합니다. YYYY-MM-DD로, UTC가 아니라 로컬로 보냅니다',
        en: 'Identifies the field when a form is submitted, as a local YYYY-MM-DD — never as UTC'
      }
    })
  ],

  PlDateRangePicker: [
    {
      name: 'value',
      type: 'PlDateRange | null',
      description: {
        ko: '선택된 구간. onValueChange와 함께 controlled로 씁니다',
        en: 'The chosen range. Use with onValueChange for a controlled picker'
      }
    },
    {
      name: 'defaultValue',
      type: 'PlDateRange | null',
      description: { ko: 'uncontrolled일 때 시작하는 구간', en: 'The range the picker starts on' }
    },
    {
      name: 'onValueChange',
      type: '(value: PlDateRange) => void',
      description: {
        ko: '언제나 객체와 함께 호출됩니다. 비워진 구간은 { start: null, end: null }입니다',
        en: 'Always called with an object. A cleared range is { start: null, end: null }'
      }
    },
    ...dateBoundsProps,
    {
      name: 'monthCount',
      type: '1 | 2',
      default: '2',
      description: {
        ko: '한 번에 보여 줄 달의 수. 달을 넘나드는 구간이 예외가 아니라 보통이라 2가 기본입니다',
        en: 'How many months are on screen at once. Two by default, because a range that crosses a month boundary is the ordinary case'
      }
    },
    {
      name: 'startPlaceholder',
      type: 'ReactNode',
      description: {
        ko: '아직 정하지 않은 쪽에 보이는 내용. trigger의 각 반쪽마다 하나씩',
        en: 'Shown in each half of the trigger while that end is unchosen'
      }
    },
    {
      name: 'endPlaceholder',
      type: 'ReactNode',
      description: { ko: 'startPlaceholder를 보세요', en: 'See startPlaceholder' }
    },
    {
      name: 'presets',
      type: 'readonly PlDateRangePreset[]',
      description: {
        ko: '달력 옆에 놓이는 지름길 — "지난 7일", "이번 달"',
        en: 'Shortcuts listed beside the calendars — "Last 7 days", "This month"'
      }
    },
    ...pickerProps({
      format: "{ dateStyle: 'medium' }",
      formatDescription: {
        ko: 'trigger가 양 끝을 쓰는 방식. Intl로 그대로 넘어갑니다',
        en: 'How the trigger writes each end. Passed straight to Intl'
      },
      closeOnSelect: 'true',
      closeOnSelectDescription: {
        ko: '양 끝이 다 정해지면 팝업을 닫습니다',
        en: 'Closes the popup once both ends are chosen'
      },
      nameDescription: {
        ko: '폼 제출 시 필드를 식별합니다. 같은 이름의 hidden input 둘이라 양 끝이 FormData.getAll(name)으로 옵니다',
        en: 'Identifies the field when a form is submitted. Two hidden inputs of the same name, so the two ends arrive as FormData.getAll(name)'
      }
    })
  ],

  PlDateRange: [
    {
      name: 'start',
      type: 'Date | null',
      required: true,
      description: { ko: '구간의 시작', en: 'The first day of the span' }
    },
    {
      name: 'end',
      type: 'Date | null',
      required: true,
      description: {
        ko: '끝. 첫 클릭과 둘째 클릭 사이에는 null입니다 — 반쪽짜리 구간은 실제로 존재하는 상태입니다',
        en: 'The last. null between the first click and the second: half a range is a real state'
      }
    }
  ],

  PlDateRangePreset: [
    {
      name: 'label',
      type: 'ReactNode',
      required: true,
      description: { ko: '버튼에 적히는 이름', en: 'What the button says' }
    },
    {
      name: 'value',
      type: 'PlDateRange | (() => PlDateRange)',
      required: true,
      description: {
        ko: '그것이 뜻하는 구간. 오늘에 달려 있다면 함수로 주세요 — 대개 그렇습니다. 모듈 로드 시점에 계산한 "지난 7일"은 탭을 밤새 열어 둔 사람에게 틀린 값입니다',
        en: 'The range it stands for. A function when it depends on today, which is almost always: "the last 7 days" computed at module scope is wrong for anyone who left the tab open overnight'
      }
    }
  ],

  PlDateTimePicker: [
    {
      name: 'value',
      type: 'Date | null',
      description: {
        ko: '선택된 순간. onValueChange와 함께 controlled로 씁니다',
        en: 'The chosen moment. Use with onValueChange for a controlled picker'
      }
    },
    {
      name: 'defaultValue',
      type: 'Date | null',
      description: { ko: 'uncontrolled일 때 시작하는 순간', en: 'The moment the picker starts on' }
    },
    {
      name: 'onValueChange',
      type: '(value: Date | null) => void',
      description: { ko: '값이 바뀔 때 호출됩니다', en: 'Called with the new value' }
    },
    {
      name: 'minDate',
      type: 'Date | null',
      description: {
        ko: '고를 수 있는 가장 이른 순간. PlDatePicker와 달리 **전체 정밀도로** 읽습니다 — 그 경계가 놓인 날은 달력에서 그대로 고를 수 있고, 그 앞의 시각을 막는 건 시계 열입니다',
        en: 'The earliest moment that may be chosen. Unlike PlDatePicker, it is read at **full precision**: the day it falls on stays selectable in the calendar and the clock columns block the hours before it'
      }
    },
    {
      name: 'maxDate',
      type: 'Date | null',
      description: {
        ko: '고를 수 있는 가장 늦은 순간. 역시 전체 정밀도입니다',
        en: 'The latest moment that may be chosen, likewise at full precision'
      }
    },
    {
      name: 'shouldDisableDate',
      type: '(date: Date) => boolean',
      description: {
        ko: '범위 안이지만 그래도 쓸 수 없는 날을 막습니다',
        en: 'Blocks individual days that are inside the range but still not available'
      }
    },
    {
      name: 'weekStartsOn',
      type: '0 | 1 | 2 | 3 | 4 | 5 | 6',
      description: {
        ko: '한 주가 시작하는 요일. 기본은 locale이 말하는 대로이고, 0이 일요일입니다',
        en: 'Which day the week starts on. Defaults to whatever the locale says; 0 is Sunday'
      }
    },
    {
      name: 'defaultMonth',
      type: 'Date',
      description: {
        ko: '값이 없을 때 달력이 열리는 달',
        en: 'Which month the calendar opens on when there is no value'
      }
    },
    ...timeColumnProps,
    {
      name: 'showNowButton',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '푸터에 이 순간으로 가는 지름길을 둡니다',
        en: 'Offers the shortcut to this moment in the footer'
      }
    },
    ...pickerProps({
      format: "{ dateStyle: 'medium', timeStyle: 'short' }",
      formatDescription: {
        ko: 'trigger가 순간을 쓰는 방식. Intl로 그대로 넘어갑니다',
        en: 'How the trigger writes the chosen moment. Passed straight to Intl'
      },
      closeOnSelect: 'false',
      closeOnSelectDescription: {
        ko: '날을 고르는 즉시 팝업을 닫습니다. 여기서는 false, PlDatePicker에서는 true인 건 순간이 날 *그리고* 시각이고 둘 중 첫째에서 닫으면 둘째가 답 없이 남기 때문입니다',
        en: 'Closes the popup as soon as a day is chosen. false here and true on PlDatePicker, because a moment is a day *and* a time and closing on the first would leave the second unanswered'
      },
      nameDescription: {
        ko: '폼 제출 시 필드를 식별합니다. 로컬 YYYY-MM-DDTHH:MM으로 보냅니다',
        en: 'Identifies the field when a form is submitted, as a local YYYY-MM-DDTHH:MM'
      }
    })
  ],

  PlDivider: [
    {
      name: 'orientation',
      type: "'horizontal' | 'vertical'",
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '선이 달리는 방향. vertical은 자기 높이가 없고 flex 부모에 맞춰 늘어납니다',
        en: 'Which way the line runs. A vertical divider has no height of its own and stretches to its flex parent'
      }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '의미론적 색 역할. 기본값이 **없습니다** — 생략하면 어느 바탕에서나 보이는 중립 헤어라인입니다',
        en: 'Semantic colour role. There is **no** default — left out, the rule is the neutral hairline, which is visible on every ground'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '라벨의 타입 스케일. divider에서 크기를 가지는 것은 라벨뿐입니다',
        en: 'Type scale of the label. Nothing else on a divider has a size'
      }
    },
    {
      name: 'length',
      type: 'number | string',
      description: {
        ko: '선이 달리는 길이. 숫자는 px, 문자열은 임의의 CSS 길이. 생략하면 컨테이너를 채웁니다',
        en: 'How far the rule runs. A number is pixels, a string is any CSS length. Left out, it fills its container'
      }
    },
    {
      name: 'thickness',
      type: 'number | string',
      default: '1',
      description: {
        ko: '선의 두께. 숫자는 px, 문자열은 임의의 CSS 길이',
        en: 'How thick the rule is. A number is pixels, a string is any CSS length'
      }
    },
    {
      name: 'textAlign',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      shared: true,
      description: {
        ko: '라벨이 놓이는 자리. start와 end는 가까운 쪽에 짧은 선을 남겨 라벨이 선 *안에* 놓인 것으로 읽히게 합니다',
        en: 'Where the label sits. start and end leave a short stub on the near side, so the label still reads as set into the rule'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '선 안에 놓이는 라벨 — 두 로그인 방법 사이의 "OR"',
        en: 'A label set into the line — "OR" between two sign-in options'
      }
    }
  ],

  PlDrawer: [
    {
      name: 'side',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'left'",
      shared: true,
      description: {
        ko: '판이 붙는 가장자리. 논리적이 아니라 물리적입니다',
        en: 'Which edge the panel is attached to. Physical rather than logical'
      }
    },
    {
      name: 'mode',
      type: "'overlay' | 'inline'",
      default: "'overlay'",
      description: {
        ko: 'overlay는 여는 서랍 — 스크림·포커스 트랩·Escape. inline은 레이아웃 속의 판입니다',
        en: 'overlay is the drawer you open — a scrim, a focus trap, Escape. inline is a panel in the layout'
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '서랍이 보이는지. onOpenChange와 함께 controlled로 씁니다',
        en: 'The drawer is shown. Use with onOpenChange for a controlled drawer'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      description: {
        ko: 'uncontrolled일 때의 시작 상태. overlay는 false, inline은 true입니다',
        en: 'Whether it starts open, for an uncontrolled one. false in overlay, true in inline'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: {
        ko: '열림 상태가 바뀔 때 호출됩니다',
        en: 'Called when the open state changes'
      }
    },
    {
      name: 'trigger',
      type: 'ReactElement',
      description: {
        ko: '서랍을 여는 요소. overlay 전용입니다',
        en: 'The element that opens the drawer. overlay only'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '서랍의 이름이 되는 제목', en: 'The heading, and what names the drawer' }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 한 줄이자 서랍의 접근 가능한 설명',
        en: "A line under the title, and the drawer's accessible description"
      }
    },
    {
      name: 'actions',
      type: 'ReactNode',
      description: {
        ko: '판 아래에 고정되는 줄. 끝 정렬로 배치됩니다',
        en: 'The bottom row, held against the foot of the panel. Laid out end-aligned'
      }
    },
    {
      name: 'dividers',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '섹션 사이를 여백 대신 얇은 선으로 가릅니다',
        en: 'Scores the panel between its sections with a hairline instead of separating them with space'
      }
    },
    {
      name: 'showClose',
      type: 'boolean',
      description: {
        ko: '모서리의 ×. overlay에서는 켜지고 inline에서는 꺼집니다',
        en: 'Shows the × in the corner. On in overlay, off in inline'
      }
    },
    {
      name: 'closeLabel',
      type: 'string',
      default: "'Close'",
      description: { ko: '× 버튼의 접근 가능한 이름', en: 'Accessible name of the × button' }
    },
    {
      name: 'extent',
      type: 'number | string',
      description: {
        ko: '판이 가장자리에서 얼마나 들어오는지 — 좌우는 너비, 상하는 높이',
        en: 'How far the panel reaches in from its edge: a width for left/right, a height for top/bottom'
      }
    },
    {
      name: 'rounded',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '페이지를 향한 두 모서리만 깎습니다. 창 가장자리 쪽은 언제나 각집니다',
        en: 'Rounds the two corners that face the page. The ones against the window edge are always square'
      }
    },
    {
      name: 'modal',
      type: "boolean | 'trap-focus'",
      default: 'true',
      description: {
        ko: '뒤의 페이지를 가져가는지. trap-focus는 페이지를 살려 둔 채 포커스만 붙잡습니다',
        en: "Whether the page behind is taken away. 'trap-focus' keeps it usable while still holding focus inside"
      }
    },
    {
      name: 'dismissible',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'Escape와 스크림 누름으로 닫히는지. overlay 전용입니다',
        en: 'Whether Escape or a press on the scrim closes it. overlay only'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: { ko: '판의 너비, 반경, 여백', en: "The panel's width, radius and padding" }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. 안쪽의 focus ring까지만 닿습니다',
        en: 'Semantic colour role. It reaches the focus rings inside and nothing else'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '섹션이 얼마나 촘촘히 놓이는지', en: 'How tightly the sections pack' }
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

  PlFloatingBottomNavigation: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      elevation: '2',
      variantDescription: {
        ko: '캡슐의 재질. ghost는 캡슐이 아예 없고 원반만 떠 있습니다',
        en: 'What the capsule is made of. ghost has no capsule at all — the discs float on their own'
      },
      sizeDescription: {
        ko: '원반의 지름과 바 아래의 틈. 컨트롤 사다리를 씁니다',
        en: "The disc's diameter and the gap under the bar, on the control ladder"
      },
      elevationDescription: {
        ko: '드롭 섀도 깊이. 2가 기본입니다 — 이 바는 페이지의 일부가 아니라 그 위에 떠 있습니다',
        en: 'Drop shadow depth. 2, because this bar is not part of the page — it hovers over it'
      },
      densityDescription: {
        ko: '캡슐 안의 여백과 원반 사이 간격만 바꿉니다',
        en: 'Changes the air inside the capsule and the gap between discs'
      }
    }),
    {
      name: 'value',
      type: 'string | number | null',
      description: {
        ko: '독자가 있는 목적지. onValueChange와 함께 controlled로 씁니다',
        en: 'The destination the reader is on. Use with onValueChange for a controlled bar'
      }
    },
    {
      name: 'defaultValue',
      type: 'string | number | null',
      default: 'null',
      description: {
        ko: 'uncontrolled일 때 시작 목적지',
        en: 'Which starts current, for an uncontrolled bar'
      }
    },
    {
      name: 'onValueChange',
      type: '(value: string | number) => void',
      description: {
        ko: '고른 목적지로 호출됩니다',
        en: 'Called with the destination that was chosen'
      }
    },
    {
      name: 'position',
      type: "'static' | 'sticky' | 'fixed'",
      default: "'fixed'",
      description: {
        ko: '페이지 스크롤 안에서 바가 놓이는 방식',
        en: "How the bar sits in the page's scroll"
      }
    },
    {
      name: 'safeArea',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '바 아래 틈에 홈 인디케이터 높이를 더합니다',
        en: 'Adds the home indicator to the gap under the bar'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '모든 목적지가 반응하지 않습니다',
        en: 'Every destination stops answering'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: { ko: '바가 안내되는 이름', en: 'The name the bar is announced by' }
    },
    {
      name: 'render',
      type: 'RenderProp',
      description: {
        ko: '<nav> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <nav>'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: 'PlFloatingBottomNavigationItem들',
        en: 'The PlFloatingBottomNavigationItems'
      }
    }
  ],

  PlFloatingBottomNavigationItem: [
    {
      name: 'value',
      type: 'string | number',
      required: true,
      description: {
        ko: '목적지를 식별합니다. onValueChange가 보고하는 값입니다',
        en: 'Identifies the destination. What onValueChange reports'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: {
        ko: '글리프. 독자가 보는 것의 전부입니다',
        en: 'The glyph. It is the whole of what a reader sees'
      }
    },
    {
      name: 'href',
      type: 'string',
      description: {
        ko: '항목을 버튼이 아니라 진짜 링크로 렌더링합니다',
        en: 'Renders the item as a real link rather than as a button'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '쓸 수 없지만 집합에는 남습니다',
        en: 'Unavailable, but still part of the set'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '목적지의 이름. 절대 그려지지 않고 언제나 읽힙니다',
        en: "The destination's name. Never drawn, always read"
      }
    }
  ],

  PlGrid: [
    {
      name: 'columns',
      type: 'PlassResponsive<number>',
      default: '12',
      description: {
        ko: '한 줄을 몇 칸으로 나눌지. 안쪽의 모든 span과 offset이 이 수를 기준으로 읽힙니다',
        en: 'How many columns a row is divided into. Every span and offset inside is read against this number'
      }
    },
    {
      name: 'spacing',
      type: 'PlassResponsive<number>',
      default: '2',
      description: {
        ko: '아이템 사이 간격. Tailwind spacing 스케일이라 4는 1rem이고, 분수도 됩니다',
        en: "The gutter between items, on Tailwind's spacing scale — 4 is 1rem, and fractions are allowed"
      }
    },
    {
      name: 'rowSpacing · columnSpacing',
      type: 'PlassResponsive<number>',
      description: {
        ko: '한 축만의 간격. 주지 않으면 spacing으로 떨어집니다',
        en: 'The gutter on one axis only. Falls back to spacing'
      }
    },
    {
      name: 'justify',
      type: "'start' | 'center' | 'end' | 'space-between' | 'space-around' | 'space-evenly' | 'stretch'",
      description: {
        ko: '아이템이 쓰지 않은 자리를 한 줄이 어떻게 나눠 가질지',
        en: 'How a row distributes the space its items did not use'
      }
    },
    {
      name: 'alignItems',
      type: "'start' | 'center' | 'end' | 'stretch' | 'baseline'",
      default: "'stretch'",
      description: {
        ko: '한 줄 안에서 아이템들이 서로에 대해 어떻게 놓일지',
        en: 'How items sit against each other across the row'
      }
    },
    {
      name: 'alignContent',
      type: "'start' | 'center' | 'end' | 'space-between' | 'space-around' | 'space-evenly' | 'stretch'",
      description: {
        ko: '그리드가 담긴 상자보다 짧을 때 줄들이 어디에 놓일지',
        en: 'Where the rows sit when the grid is shorter than the box holding it'
      }
    },
    {
      name: 'wrap',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '칸이 모자란 줄이 다음 줄로 이어질지. 끄면 한 줄이 넘쳐 흐릅니다',
        en: 'Whether a row that runs out of columns continues on the next one. Off gives one row that overflows'
      }
    },
    {
      name: 'render',
      type: 'RenderProp',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다 (<section />, <ul />)',
        en: 'Renders something other than a <div> (<section />, <ul />)'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'PlGridItem들', en: 'The PlGridItems' }
    }
  ],

  PlGridItem: [
    {
      name: 'span',
      type: 'PlassResponsive<number>',
      description: {
        ko: '그리드의 칸 중 몇 칸을 차지할지. 줄보다 넓은 span은 넘치지 않고 줄에 맞춰 잘립니다',
        en: "How many of the grid's columns the item takes. A span wider than the row is clamped to it rather than overflowing"
      }
    },
    {
      name: 'offset',
      type: 'PlassResponsive<number>',
      default: '0',
      description: {
        ko: '아이템 *앞*에 비워 두는 칸 수. 줄 안의 절대 위치가 아니라 앞으로 밀어 넣는 자리입니다',
        en: 'Columns left empty before the item — space pushed in ahead of it, not an absolute position in the row'
      }
    },
    {
      name: 'alignSelf',
      type: "'auto' | 'start' | 'center' | 'end' | 'stretch' | 'baseline'",
      description: {
        ko: '이 아이템 하나만 줄의 alignItems를 덮어씁니다',
        en: "Overrides the row's alignItems for this item alone"
      }
    },
    {
      name: 'render',
      type: 'RenderProp',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다 (<li />, <article />)',
        en: 'Renders something other than a <div> (<li />, <article />)'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '칸에 들어갈 것', en: 'What the cell holds' }
    }
  ],

  PlHighlight: [
    {
      name: 'query',
      type: 'string | string[] | RegExp',
      required: true,
      description: {
        ko: '찾을 것. 문자열은 한 단어, 배열은 여러 개이며 긴 것부터 시도합니다. RegExp는 쓰인 그대로 쓰이되 global 플래그가 켜지고, caseSensitive와 wholeWord는 무시됩니다',
        en: 'What to find. A string is one term, an array several — longest first. A RegExp is used as written with the global flag forced on, and caseSensitive/wholeWord are ignored for it'
      }
    },
    {
      name: 'variant',
      type: VARIANT,
      default: "'solid'",
      shared: true,
      description: {
        ko: '표시의 재질. solid는 형광펜, glass는 헤어라인 상자, ghost는 강조색뿐입니다. 여기서 glass는 흐림 없이 쓰입니다 — 20px짜리 인라인 상자 뒤에는 문지를 만한 배경이 없습니다',
        en: 'What the mark is made of. solid is the highlighter pen, glass a hairline box, ghost the accent colour alone. glass is unblurred here: a 20px inline box has no backdrop worth smearing'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'warning'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. 기본값이 warning인 것은 임의가 아닙니다 — 그러데이션이 밝고 잉크가 어두운 유일한 계열이라, solid warning 표시가 검은 글자 위의 노란 형광펜이 됩니다',
        en: 'Semantic colour role. warning by default and not arbitrarily: it is the one family whose gradient is light with dark ink on it, so a solid mark is a yellow highlighter over black text'
      }
    },
    {
      name: 'caseSensitive',
      type: 'boolean',
      default: 'false',
      description: { ko: 'a와 A를 다른 글자로 볼지', en: 'Whether a and A are different letters' }
    },
    {
      name: 'wholeWord',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '단어 하나로 서 있을 때만 표시할지 — cat이 "cat"은 표시하고 "concatenate"는 표시하지 않게. 띄어쓰기로 구를 나누지 않는 한국어·일본어에서는 의미가 거의 없고, 그래서 기본값이 꺼짐입니다',
        en: 'Whether a term has to be a word on its own — cat marking "cat" but not "concatenate". It means very little for Korean or Japanese, where a phrase is not delimited by spaces, which is why it is off by default'
      }
    },
    {
      name: 'underline',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '표시에 밑줄도 긋습니다. 모든 variant와 겹칩니다',
        en: 'Underlines the mark as well. Combines with every variant'
      }
    },
    {
      name: 'weight',
      type: "'regular' | 'medium' | 'semibold' | 'bold'",
      description: {
        ko: '표시의 굵기. 생략하면 주변 글자의 굵기를 그대로 씁니다 — 표면이 이미 "이것"이라고 말하고 있고, 문장 속에서 굵어진 단어는 줄 전체의 리듬을 바꿉니다',
        en: 'The mark’s weight. Omit it and the mark is the weight of the text around it — the surface is already saying "this one", and a bolded word changes the rhythm of the whole line'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '검색할 텍스트. 요소는 안으로 걸어 들어가되 그대로 남으므로, strong 안의 일치도 표시되고 strong도 살아남습니다',
        en: 'The text to search. Elements are walked into and left otherwise untouched, so a match inside a strong is marked and the strong survives'
      }
    }
  ],

  PlHotKeys: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      color: "'secondary'",
      density: "'compact'",
      variantDescription: {
        ko: '키캡의 재질. glass는 인쇄된 매뉴얼의 그 헤어라인 상자이고, 기본값입니다',
        en: 'What the key cap is made of. glass is the hairline box of every printed manual, and the default'
      },
      sizeDescription: {
        ko: '캡의 크기. 컨트롤 사다리에서 한 단계 내려옵니다 — 캡은 문장 속 토큰이지 줄이 기준선을 맞추는 컨트롤이 아닙니다',
        en: 'The cap size, one step down the control ladder — a cap is a token inside a line of text, not a control the line lines up against'
      },
      elevationDescription: {
        ko: '그림자 깊이. 기본값 0 — 캡에는 이미 아래쪽 립이 있고, 페이지에서 띄우기까지 하면 깊이 신호가 하나 많습니다',
        en: 'Drop shadow depth. 0 by default — a cap already has a lip under it, and raising it off the page too is one depth cue too many'
      }
    }),
    {
      name: 'keys',
      type: 'string | string[]',
      description: {
        ko: "키 목록. 문자열은 `+`로 쪼갭니다 ('Mod+Shift+P'). 키 자체가 `+`인 단축키는 배열 형태로 주세요",
        en: "The keys. A string is split on `+` ('Mod+Shift+P'); for a shortcut whose key *is* a plus, pass the array form"
      }
    },
    {
      name: 'cluster',
      type: '{ up, left, down, right }',
      description: {
        ko: '네 개의 이동 키를 인라인 조합 대신 뒤집힌 T로 그립니다 — WASD나 방향키. keys보다 우선합니다',
        en: 'Draws the four movement keys as an inverted T instead of an inline combo — WASD, or the arrows. Takes precedence over keys'
      }
    },
    {
      name: 'os',
      type: "'auto' | 'mac' | 'windows' | 'linux'",
      default: "'auto'",
      description: {
        ko: '어느 키보드 기준으로 modifier 이름을 붙일지. auto는 브라우저에 묻습니다',
        en: 'Which keyboard to name the modifiers for. auto asks the browser'
      }
    },
    {
      name: 'separator',
      type: 'ReactNode',
      description: {
        ko: '키 사이에 놓이는 것. 생략하면 플랫폼 관례를 따릅니다 — Windows/Linux는 +, macOS는 아무것도 없음',
        en: "What goes between two keys. Omit it for the platform's own convention: a + on Windows and Linux, nothing on macOS"
      }
    }
  ],

  PlKbd: [
    {
      name: 'variant',
      type: VARIANT,
      default: "'glass'",
      shared: true,
      description: { ko: '캡의 재질', en: 'What the cap is made of' }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '캡의 크기. PlHotKeys와 같은 한 단계 아래 사다리를 씁니다',
        en: 'The cap size, on the same one-step-down ladder PlHotKeys uses'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'compact'",
      shared: true,
      description: { ko: '캡의 좌우 여백', en: "The cap's horizontal padding" }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '캡에 인쇄되는 것', en: 'What is printed on the cap' }
    }
  ],

  PlIconButton: [
    ...sharedProps({
      variant: "'solid'",
      size: "'md'",
      elevation: '1',
      sizeDescription: {
        ko: '원반의 지름과 안쪽 글리프의 크기. PlButton과 같은 사다리입니다',
        en: "The disc's diameter and the glyph inside it — the same ladder as PlButton"
      }
    }),
    {
      name: 'icon',
      type: 'ReactNode',
      required: true,
      description: {
        ko: '글리프. 그대로 넘기면 버튼에 대한 em으로 크기가 정해집니다',
        en: 'The glyph. Passed bare it is sized in em against the button'
      }
    },
    {
      name: 'label',
      type: 'string',
      required: true,
      description: {
        ko: '이 버튼이 하는 일을 말로. 접근 가능한 이름이 되며 화면에는 그려지지 않습니다',
        en: 'What the button does, in words. It becomes the accessible name and is never drawn'
      }
    },
    {
      name: 'loading',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '글리프 자리에 스피너를 놓고 실행을 막습니다. 포커스는 유지합니다',
        en: 'Shows a spinner in place of the glyph and stops the button activating, while keeping it focusable'
      }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '색은 지키고 평평해지며 채도를 뺍니다. 흐려지지는 않습니다',
        en: 'Keeps its colour, goes flat and drains most of its saturation — not dimmed'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용할 수 없습니다. 빛과 그림자를 잃고 포커스 순서에서 빠집니다',
        en: 'Unavailable. Loses its light and its shadow, and leaves the focus order'
      }
    },
    {
      name: 'render',
      type: 'RenderProp',
      description: {
        ko: '<button> 대신 다른 요소로 렌더링합니다 (<a href="…" />)',
        en: 'Renders something other than a <button> (<a href="…" />)'
      }
    }
  ],

  PlIcon: [
    {
      name: 'icon',
      type: 'ReactNode',
      required: true,
      description: {
        ko: '글리프. svg, img, 아이콘 세트의 컴포넌트, 또는 문자 하나. children이 아니라 prop인 이유는, 아이콘을 감싸는 것이 아니라 *크기를 정해 주는* 것이기 때문입니다',
        en: 'The glyph — an svg, an img, a component from an icon set, or a character. A prop rather than children, because the icon is content this component *sizes* rather than content it merely wraps'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '글리프가 그려지는 상자. 14, 16, 20, 24, 28px — 컨트롤 높이가 아니라 자기 사다리',
        en: 'The box the glyph is drawn in: 14, 16, 20, 24 and 28px. Its own ladder, not the control heights'
      }
    },
    {
      name: 'color',
      type: `${COLOR} | 'inherit'`,
      default: "'inherit'",
      shared: true,
      description: {
        ko: '의미론적 색 역할, 또는 놓인 자리의 색을 그대로 쓰는 inherit. 이 prop이 primary가 아닌 유일한 컴포넌트입니다 — 아이콘은 콘텐츠라, 색은 대개 이미 정해져 있습니다',
        en: 'Semantic colour role, or inherit to take the colour of whatever it sits in. The one component where this is not primary — an icon is content, and its colour has usually been decided already'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '아이콘이 하는 말. 없으면 접근성 트리에서 완전히 숨깁니다 — 대부분의 아이콘 옆에는 같은 말을 하는 단어가 이미 있습니다',
        en: 'What the icon says. Without it the icon is hidden from the accessibility tree entirely — most icons sit beside a word that already says the same thing'
      }
    }
  ],

  PlList: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '시트의 재질. 컨테이너가 그렇듯 시트에는 색이 들어가지 않습니다. card 안이라면 ghost — card가 이미 시트인데 그 안의 두 번째 테두리는 사각형이 하나 더 늘어난 것뿐입니다',
        en: 'What the sheet is made of. As on any container it is never dyed. ghost is the one to reach for inside a card: the card is already a sheet, and a second bordered rectangle in it is a second rectangle'
      },
      sizeDescription: {
        ko: '행의 타입 스케일과 여백. 행마다가 아니라 묶음 전체의 속성입니다',
        en: 'Type scale and padding of the rows. A property of the stack, not of any one row in it'
      }
    }),
    {
      name: 'dividers',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '행을 여백 대신 헤어라인으로 나눕니다. 들리는 것보다 많이 바뀝니다 — 선이 시트의 양 끝까지 닿아야 하므로 시트는 안쪽 여백을, 행은 둥근 모서리를 내놓습니다',
        en: 'Separates the rows with a hairline instead of with space. It changes more than it sounds like: the rules have to reach both edges, so the sheet gives up its padding and the rows give up their corners'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'ul이 아닌 다른 요소로 렌더링합니다 — 순서가 핵심인 목록이라면 render={<ol />}',
        en: 'Renders something other than a ul — render={<ol />} for a list where the order is the point'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'PlListItem들', en: 'The PlListItems' }
    }
  ],

  PlListItem: [
    {
      name: 'onClick',
      type: '(event: MouseEvent) => void',
      description: {
        ko: '넘기는 것이 행을 진짜 button으로 만듭니다. li가 아니라 그 button에 놓입니다',
        en: 'Passing it is what turns the row into a real button. It lands on that button rather than on the li'
      }
    },
    {
      name: 'href',
      type: 'string',
      description: { ko: '행을 링크로 그립니다', en: 'Renders the row as a link' }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 앞의 것 — 아이콘, avatar, 상태 점',
        en: 'Content before the label — an icon, an avatar, a status dot'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 뒤, 누를 수 있는 영역 안쪽의 것',
        en: 'Content after the label, inside the pressable area'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '라벨 아래 한 줄. 타입 스케일 한 칸 아래에 흐린 색',
        en: 'A second line under the label, one step down the type scale and muted'
      }
    },
    {
      name: 'action',
      type: 'ReactNode',
      description: {
        ko: '행 끝에 고정되는 컨트롤 — switch, 메뉴 버튼. 일부러 누를 수 있는 영역 **바깥**입니다. 이동도 하고 토글도 담는 행에는 누를 것이 둘이고, button 안의 button은 브라우저가 파싱하며 다시 쓰는 마크업입니다',
        en: 'A control pinned to the end of the row. Deliberately **outside** the pressable area: a row that both navigates and holds a toggle has two things to press, and a button inside a button is markup the browser rewrites on parse'
      }
    },
    {
      name: 'selected',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '선택된 행 — 열린 페이지, 현재 필터. 링크에는 aria-current="page", button에는 "true"가 붙습니다',
        en: 'Marks the row as the chosen one — the open page, the current filter. aria-current="page" on a link, "true" on a button'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      shared: true,
      description: {
        ko: '사용할 수 없음. 빛이 꺼지고 누를 수 없게 됩니다',
        en: 'Unavailable. The light goes out and it stops being pressable'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '라벨', en: 'The label' }
    }
  ],

  PlMenu: [
    {
      name: 'trigger',
      type: 'ReactElement',
      description: {
        ko: '메뉴를 여는 요소. 선택 사항입니다 — 밖에서 여는 controlled 메뉴에는 트리거가 필요 없습니다',
        en: 'The element that opens the menu. Optional — a controlled menu opened from elsewhere needs none'
      }
    },
    {
      name: 'open · defaultOpen · onOpenChange',
      type: 'boolean · boolean · (open: boolean) => void',
      description: {
        ko: '열림 상태. controlled와 uncontrolled 양쪽',
        en: 'The open state, controlled or uncontrolled'
      }
    },
    {
      name: 'side',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'bottom'",
      description: {
        ko: '트리거의 어느 가장자리에 매달릴지',
        en: 'Which edge of the trigger it hangs off'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'start'",
      description: { ko: '그 가장자리를 따라 어디에 놓일지', en: 'Where it sits along that edge' }
    },
    {
      name: 'sideOffset',
      type: 'number',
      default: '6',
      description: { ko: '트리거와의 거리(px)', en: 'Distance from the trigger, in pixels' }
    },
    {
      name: 'modal',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '열려 있는 동안 뒤 페이지를 가져갈지',
        en: 'Whether the page behind is taken away while the menu is open'
      }
    },
    {
      name: 'openOnHover',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '클릭뿐 아니라 호버로도 엽니다. 메뉴 바를 위한 것입니다',
        en: 'Opens on hover as well as on click. For a menu bar'
      }
    },
    {
      name: 'loopFocus',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '화살표 키가 마지막 행에서 첫 행으로 돌아갈지',
        en: 'Whether the arrow keys wrap from the last row back to the first'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '트리거가 아무것도 열지 않습니다',
        en: 'The trigger stops opening anything'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '팝업의 반경, 타입 스케일, 행 패딩',
        en: "The popup's radius, type scale and row padding"
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. 행마다 덮어쓸 수 있습니다',
        en: 'Semantic colour role. A row can override it'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '행의 패딩만 바꿉니다', en: "Changes a row's padding and nothing else" }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '행들', en: 'The rows' }
    }
  ],

  PlMenuItem: [
    {
      name: 'onClick',
      type: '(event: MouseEvent) => void',
      description: {
        ko: '행이 하는 일. 주지 않고 링크도 아니면 행은 라벨입니다',
        en: 'What the row does. Not given, and not a link, the row is a label'
      }
    },
    {
      name: 'href · target',
      type: 'string',
      description: {
        ko: '행을 진짜 <a>로 렌더링합니다. 링크들의 메뉴는 링크여야 합니다',
        en: 'Renders the row as a real <a>. A menu of links has to be links'
      }
    },
    {
      name: 'startIcon · endIcon',
      type: 'ReactNode',
      description: { ko: '라벨 앞뒤의 슬롯', en: 'The slots before and after the label' }
    },
    {
      name: 'shortcut',
      type: 'ReactNode',
      description: {
        ko: '같은 일을 하는 키 조합. 행 끝에 흐리게 놓입니다. 텍스트일 뿐이고 바인딩은 앱의 몫입니다',
        en: 'The keystroke that does the same thing, muted at the end of the row. Text only — the application binds it'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '라벨 아래 한 줄. 한 단계 작고 흐립니다',
        en: 'A second line under the label, one step down and muted'
      }
    },
    {
      name: 'color',
      type: COLOR,
      description: {
        ko: '행의 색 가족을 다시 겨눕니다 — 삭제하는 행에 danger',
        en: "Re-points the row's colour family — danger for the one that deletes"
      }
    },
    {
      name: 'closeOnClick',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '행을 고르면 메뉴가 닫힐지',
        en: 'Whether picking the row closes the menu'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '쓸 수 없습니다. 목록에는 남고 타이프어헤드에도 잡힙니다',
        en: 'Unavailable. Still listed, and still found by typeahead'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '라벨이 평범한 문자열이 아닐 때 타이프어헤드가 맞춰 볼 문자열',
        en: 'What typeahead matches against, when the label is not a plain string'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '라벨', en: 'The label' }
    }
  ],

  PlMenuCheckboxItem: [
    {
      name: 'checked · defaultChecked · onCheckedChange',
      type: 'boolean · boolean · (checked: boolean) => void',
      description: { ko: '체크 상태', en: 'The checked state' }
    },
    {
      name: 'value',
      type: 'string | number',
      required: true,
      description: {
        ko: 'PlMenuRadioItem에만: 이 행이 그룹을 무엇으로 설정할지',
        en: 'PlMenuRadioItem only: what this row sets the group to'
      }
    },
    {
      name: 'closeOnClick',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '체크했을 때 메뉴가 닫힐지. 평범한 행과 달리 기본이 false입니다',
        en: 'Whether ticking closes the menu. false here, against a plain row'
      }
    },
    {
      name: 'endIcon · shortcut · description · color · disabled · label',
      type: '—',
      description: { ko: 'PlMenuItem과 같습니다', en: 'As on PlMenuItem' }
    }
  ],

  PlMenuSubmenu: [
    {
      name: 'label',
      type: 'ReactNode',
      description: { ko: '서브메뉴를 여는 행의 라벨', en: 'The label on the row that opens it' }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '라벨 앞의 슬롯', en: 'The slot before the label' }
    },
    {
      name: 'side',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'right'",
      description: {
        ko: '부모 행의 어느 가장자리에서 열릴지',
        en: 'Which edge of the parent row it opens against'
      }
    },
    {
      name: 'sideOffset',
      type: 'number',
      default: '4',
      description: { ko: '부모 메뉴와의 거리(px)', en: 'Distance from the parent menu, in pixels' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '서브메뉴를 열 수 없습니다', en: 'The row stops opening anything' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '중첩된 행들', en: 'The nested rows' }
    }
  ],

  PlContextMenu: [
    {
      name: 'content',
      type: 'ReactNode',
      required: true,
      description: {
        ko: 'PlMenu 안에 쓰는 것과 똑같은 행들',
        en: 'The rows, exactly as they are written inside a PlMenu'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      required: true,
      description: {
        ko: '오른쪽 클릭이나 길게 누르기에 응답하는 영역',
        en: 'The area that answers a right-click or a long press'
      }
    },
    {
      name: 'open · defaultOpen · onOpenChange',
      type: 'boolean · boolean · (open: boolean) => void',
      description: { ko: '열림 상태', en: 'The open state' }
    },
    {
      name: 'loopFocus',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '화살표 키가 마지막 행에서 첫 행으로 돌아갈지',
        en: 'Whether the arrow keys wrap from the last row back to the first'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '영역이 아무것도 열지 않습니다', en: 'The area stops opening anything' }
    },
    {
      name: 'size · color · density',
      type: '—',
      shared: true,
      description: { ko: 'PlMenu와 같습니다', en: 'As on PlMenu' }
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

  PlNumberField: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '껍데기의 재질. PlTextField와 픽셀 단위로 같습니다 — solid는 시트에 파인 우물이지 색이 들어간 판이 아닙니다',
        en: 'What the shell is made of, identical to PlTextField to the pixel — solid is the well cut into the sheet, not a tinted pane'
      },
      sizeDescription: {
        ko: '컨트롤 높이와 타입 스케일. 같은 form의 다른 field와 같은 사다리',
        en: 'Control height and type scale — the same ladder as every other field in the form'
      }
    }),
    {
      name: 'value',
      type: 'number | null',
      description: {
        ko: '값. controlled로 쓰려면 onValueChange와 함께',
        en: 'The number. Use with onValueChange for a controlled field'
      }
    },
    {
      name: 'defaultValue',
      type: 'number',
      description: {
        ko: 'uncontrolled일 때의 처음 값',
        en: 'The initial number, for an uncontrolled field'
      }
    },
    {
      name: 'onValueChange',
      type: '(value: number | null) => void',
      description: {
        ko: '타이핑, 스테퍼, 휠 — 바뀔 때마다',
        en: 'Called on every change — typing, stepping, the wheel'
      }
    },
    {
      name: 'onValueCommitted',
      type: '(value: number | null) => void',
      description: {
        ko: '값이 가라앉을 때: 타이핑 후 blur, 누르고 뗐을 때, 키보드에서는 onValueChange와 함께',
        en: 'Called when the value settles: on blur after typing, on pointer release, and together with onValueChange for the keyboard'
      }
    },
    {
      name: 'min',
      type: 'number',
      description: {
        ko: '범위의 아래끝. 스테퍼가 여기서 멈춥니다',
        en: 'The bottom of the range. Stepping stops here'
      }
    },
    {
      name: 'max',
      type: 'number',
      description: { ko: '범위의 위끝', en: 'The top of the range' }
    },
    {
      name: 'step',
      type: "number | 'any'",
      default: '1',
      description: {
        ko: '한 걸음의 크기. any는 step 검증을 끕니다',
        en: 'How far one step goes. any turns step validation off'
      }
    },
    {
      name: 'largeStep',
      type: 'number',
      default: '10',
      description: { ko: 'Shift를 누른 채 밟는 걸음', en: 'The step taken while Shift is held' }
    },
    {
      name: 'smallStep',
      type: 'number',
      default: '0.1',
      description: { ko: 'Alt를 누른 채 밟는 걸음', en: 'The step taken while Alt is held' }
    },
    {
      name: 'snapOnStep',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '걸음이 step의 배수에 붙을지',
        en: 'Whether stepping snaps to multiples of the step'
      }
    },
    {
      name: 'allowWheelScrub',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'focus된 상태에서 hover 중일 때 휠이 값을 바꿀지. 기본은 꺼짐 — 포인터 아래에서 스크롤되는 페이지와 값이 바뀌는 field는 같은 동작이고, 의도된 것은 둘 중 하나뿐입니다',
        en: 'Whether the wheel changes the value while focused and hovered. Off by default: a page that scrolls under the pointer and a field that changes under it are the same gesture, and only one of them was meant'
      }
    },
    {
      name: 'format',
      type: 'Intl.NumberFormatOptions',
      description: {
        ko: '숫자를 어떻게 쓸지 — 통화, 퍼센트, 소수 자릿수. Intl.NumberFormat으로 그대로 넘어가므로 화면에는 $1,240.00이 보이고 값은 1240입니다',
        en: 'How the number is written — currency, percent, decimal places. Passed straight to Intl.NumberFormat, so the field shows $1,240.00 and still reports 1240'
      }
    },
    {
      name: 'locale',
      type: 'Intl.LocalesArgument',
      description: {
        ko: '숫자를 쓰고 읽는 locale. 기본값은 런타임의 것',
        en: 'Which locale the number is written and parsed in. Defaults to the runtime’s'
      }
    },
    {
      name: 'steppers',
      type: "'end' | 'split' | 'none'",
      default: "'end'",
      description: {
        ko: '스테퍼가 놓이는 자리. 반높이 chevron을 위아래로 쌓는 형태는 일부러 없습니다 — xs에서 화살표 하나가 3px도 안 되고, 그만한 표적은 아무도 맞히지 못합니다',
        en: 'Where the steppers sit. There is deliberately no stacked pair of half-height chevrons: at xs each arrow would be under three pixels tall, and a target that small is one nobody hits'
      }
    },
    {
      name: 'incrementLabel',
      type: 'string',
      default: "'Increase'",
      description: {
        ko: '증가 버튼의 접근 가능한 이름',
        en: 'Accessible name of the increment button'
      }
    },
    {
      name: 'decrementLabel',
      type: 'string',
      default: "'Decrease'",
      description: {
        ko: '감소 버튼의 접근 가능한 이름',
        en: 'Accessible name of the decrement button'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '컨트롤 위의 라벨. Base UI의 Field가 연결합니다. floating 형태는 일부러 없습니다 — floating label에는 transform이 필요합니다',
        en: 'Label above the control, wired to it by Base UI’s Field. There is no floating variant on purpose: floating labels need a transform'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '컨트롤 아래의 도움말', en: 'Helper text below the control' }
    },
    {
      name: 'error',
      type: 'ReactNode',
      description: {
        ko: '컨트롤 아래의 오류 메시지. 이것이 있으면 field 자체가 invalid가 되고, 색 계열 전체가 danger를 가리킵니다',
        en: 'Error message below the control. Its presence also turns the field invalid, which re-points the whole slot family at danger'
      }
    },
    {
      name: 'invalid',
      type: 'boolean',
      description: {
        ko: '메시지 없이 invalid 상태만 강제합니다. 기본값은 !!error',
        en: 'Forces the invalid state without a message. Defaults to !!error'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '숫자 앞에 놓이는 것 — 통화 기호, 단위, 아이콘',
        en: 'Content placed before the number — a currency mark, a unit, an icon'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '숫자 뒤, 스테퍼 앞에 놓이는 것',
        en: 'Content placed after the number, before the steppers'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      shared: true,
      description: {
        ko: '컨테이너 너비만큼 늘어납니다',
        en: 'Stretches to the width of the container'
      }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      shared: true,
      description: {
        ko: '값은 보이지만 바꿀 수 없습니다. 스테퍼도 그려지지 않습니다',
        en: 'The number is shown but cannot be changed, and the steppers are not drawn'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      shared: true,
      description: { ko: '사용할 수 없음', en: 'Unavailable' }
    }
  ],

  PlOtpField: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      elevation: '0',
      variantDescription: {
        ko: '칸의 재질. solid는 색이 든 판이 아니라 웰입니다 — PlTextField와 같은 이유입니다',
        en: 'What a slot is made of. solid is the well rather than a tinted pane, for the reason it is on PlTextField'
      },
      sizeDescription: {
        ko: '칸의 상자와 그 안의 타입 스케일. 컨트롤 사다리가 아니라 칸 자신의 사다리입니다',
        en: "The slot's box and the type inside it — the slot's own ladder rather than the control one"
      },
      densityDescription: {
        ko: '칸 사이 간격만 바꿉니다',
        en: 'Changes the gap between slots and nothing else'
      }
    }),
    {
      name: 'length',
      type: 'number',
      default: '6',
      description: {
        ko: '코드의 글자 수. 2–12로 잘립니다',
        en: 'How many characters the code has. Clamped to 2–12'
      }
    },
    {
      name: 'charset',
      type: "'numeric' | 'alpha' | 'alphanumeric' | 'any'",
      default: "'numeric'",
      description: {
        ko: '입력할 수 있는 문자. 거부된 것은 버리고 onValueInvalid로 보고합니다',
        en: 'What may be typed. Anything rejected is dropped and reported through onValueInvalid'
      }
    },
    {
      name: 'mask',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '비밀번호 필드처럼 글자를 가립니다',
        en: 'Hides the characters, the way a password field does'
      }
    },
    {
      name: 'groupSize',
      type: 'number',
      description: {
        ko: '이 칸 수마다 구분자로 줄을 나눕니다',
        en: 'Splits the row with a separator every this many slots'
      }
    },
    {
      name: 'separator',
      type: 'ReactNode',
      default: "'–'",
      description: { ko: '두 덩어리 사이에 그려지는 것', en: 'What is drawn between two groups' }
    },
    {
      name: 'value',
      type: 'string',
      description: {
        ko: '코드. onValueChange와 함께 controlled로 씁니다',
        en: 'The code. Use with onValueChange for a controlled field'
      }
    },
    {
      name: 'defaultValue',
      type: 'string',
      description: {
        ko: 'uncontrolled일 때 시작 값',
        en: 'What it starts as, for an uncontrolled one'
      }
    },
    {
      name: 'onValueChange',
      type: '(value: string) => void',
      description: { ko: '코드가 바뀔 때 호출됩니다', en: 'Called with the new code' }
    },
    {
      name: 'onComplete',
      type: '(value: string) => void',
      description: {
        ko: '모든 칸이 채워지는 순간 호출됩니다 — 코드를 확인할 때',
        en: 'Fires once every slot is filled — the moment to verify the code'
      }
    },
    {
      name: 'onValueInvalid',
      type: '(value: string) => void',
      description: {
        ko: '입력이나 붙여넣기에 charset이 거부하는 글자가 있었을 때',
        en: 'Fires when typed or pasted text held characters the charset rejects'
      }
    },
    {
      name: 'autoSubmit',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '코드가 완성되는 즉시 폼을 전송합니다',
        en: 'Submits the owning form as soon as the code is complete'
      }
    },
    {
      name: 'label · description · error',
      type: 'ReactNode',
      description: {
        ko: '줄 위의 라벨, 아래의 보조 문구와 오류 메시지',
        en: 'Label above the row, helper text and error message below it'
      }
    },
    {
      name: 'invalid',
      type: 'boolean',
      description: {
        ko: '메시지 없이 invalid 상태를 강제합니다. 기본값은 error가 있는지 여부입니다',
        en: 'Forces the invalid state without a message. Defaults to whether error has content'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 전송에서 필드를 식별합니다',
        en: 'Identifies the field when a form is submitted'
      }
    },
    {
      name: 'required',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '코드가 완성되기 전까지 폼이 전송되지 않습니다',
        en: 'The form must have a complete code before it submits'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '모든 칸이 반응하지 않습니다', en: 'Every slot stops answering' }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '읽고 복사할 수는 있지만 입력할 수는 없습니다',
        en: 'Readable and copyable, but not typeable'
      }
    },
    {
      name: 'autoFocus',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '마운트 시 첫 칸에 캐럿을 놓습니다',
        en: 'Puts the caret in the first slot on mount'
      }
    }
  ],

  PlOverlay: [
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '오버레이가 보입니다. controlled로 쓰려면 onOpenChange와 함께',
        en: 'The overlay is shown. Use with onOpenChange for a controlled overlay'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      description: {
        ko: 'uncontrolled일 때 처음부터 보일지',
        en: 'Whether it starts shown, for an uncontrolled one'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열림 상태가 바뀔 때', en: 'Called when the open state changes' }
    },
    {
      name: 'tone',
      type: "'scrim' | 'glass' | 'solid' | 'clear'",
      default: "'scrim'",
      description: {
        ko: '페이지를 얼마나 가져갈지. scrim은 PlModal의 뒤판과 같은 중립적인 어둡기, glass는 진짜 흐림 위의 옅은 어둡기, solid는 불투명, clear는 아무것도 그리지 않으면서 포인터만 막습니다',
        en: 'How much of the page is taken away. scrim is PlModal’s own backdrop, glass is a lighter dim over a real blur, solid is opaque, and clear draws nothing while still blocking the pointer'
      }
    },
    {
      name: 'dismissible',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '눌러서, 또는 Escape로 닫을 수 있을지. PlModal과 반대로 기본은 꺼짐입니다 — 모달은 질문을 하고 Escape는 보편적인 "아니오"이지만, 오버레이는 묻고 있지 않고 *기다리라*고 말하고 있습니다',
        en: 'Whether clicking the overlay or pressing Escape closes it. Off by default, the other way round from PlModal: a modal asks a question and Escape is the universal "no", while an overlay is saying *wait*'
      }
    },
    {
      name: 'modal',
      type: "boolean | 'trap-focus'",
      default: 'true',
      description: {
        ko: '뒤 페이지를 키보드에서도 가져갈지. trap-focus는 스크롤과 클릭은 남기고 focus만 안에 붙듭니다',
        en: 'Whether the page behind is taken away for the keyboard too. trap-focus leaves it scrollable and clickable while still holding focus inside'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      shared: true,
      description: {
        ko: '내용이 화면 세로 어디에 놓일지',
        en: 'Where the content sits down the viewport'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '내용과 화면 가장자리 사이 여백의 크기',
        en: 'Scale of the padding around the content'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: 'focus ring과 내용이 읽어 갈 색 계열',
        en: 'Semantic colour role. Reaches the focus ring and whatever the content reads'
      }
    },
    {
      name: 'label',
      type: 'string',
      default: "'Overlay'",
      description: {
        ko: '오버레이의 접근 가능한 이름. 화면에는 그려지지 않습니다. 읽을 것이 아무것도 없는 오버레이도 자기가 무엇인지는 말해야 하므로 기본값이 있습니다',
        en: 'The accessible name. Never drawn. An overlay that holds nothing readable still has to say what it is, which is why this has a default'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: 'scrim 위에 놓이는 것 — spinner, 한 줄의 글, 작은 card',
        en: 'What sits on top of the scrim — a spinner, a line of text, a small card'
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

  PlPanes: [
    {
      name: 'orientation',
      type: "'horizontal' | 'vertical'",
      default: "'horizontal'",
      shared: true,
      description: {
        ko: 'pane이 놓이는 방향. horizontal은 나란히, vertical은 쌓습니다',
        en: 'Which way the panes run — side by side, or stacked'
      }
    },
    {
      name: 'resizable',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '손잡이를 끌 수 있는지. 컨트롤이 아니라 레이아웃인 분할에서는 끕니다',
        en: 'Whether the handles can be dragged. Off for a split that is a layout rather than a control'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '손잡이의 두께이자 포인터가 맞혀야 할 표적의 두께',
        en: 'How thick a handle is, and how wide the target the pointer has to hit'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '손잡이가 켜지는 색. 시트가 없으므로 얇은 선과 색조와 포커스 링에만 닿습니다',
        en: 'The family the handles light up in. There is no sheet, so it reaches the hairline, the tint and the ring'
      }
    },
    {
      name: 'onResize',
      type: '(sizes: number[]) => void',
      description: {
        ko: '손잡이를 끄는 동안 모든 pane의 몫(퍼센트)으로 호출됩니다',
        en: "Fires with every pane's share, in percent, while a handle is dragged"
      }
    },
    {
      name: 'onResizeEnd',
      type: '(sizes: number[]) => void',
      description: {
        ko: '손을 놓았을 때 같은 모양으로 한 번 호출됩니다. 키 입력에서도 발생합니다',
        en: 'Fires once, with the same shape, when the handle is let go — and on a key press'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: 'PlPane들. PlPane이 아닌 것도 배치되지만 크기를 갖지 못합니다',
        en: 'The PlPanes. Anything that is not one is still laid out, but has no size'
      }
    }
  ],

  PlPane: [
    {
      name: 'defaultSize',
      type: 'number | string',
      description: {
        ko: '시작 몫. 숫자는 퍼센트, 문자열은 절대 길이입니다. 없으면 남은 자리를 똑같이 나눕니다',
        en: 'The share it starts with. A number is a percentage, a string an absolute length. Without one, panes split what is left evenly'
      }
    },
    {
      name: 'minSize',
      type: 'number | string',
      default: '0',
      description: { ko: '얼마나 작게까지 끌 수 있는지', en: 'How small it may be dragged' }
    },
    {
      name: 'maxSize',
      type: 'number | string',
      description: {
        ko: '얼마나 크게까지 끌 수 있는지. 없으면 제한이 없습니다',
        en: 'How large it may be dragged. Unbounded when left out'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'pane 안에 들어갈 것', en: 'What is inside the pane' }
    }
  ],

  PlPill: [
    ...sharedProps({
      variant: "'solid'",
      size: "'md'",
      color: "'secondary'",
      elevation: '2',
      variantDescription: {
        ko: '표면의 재질. 컨트롤처럼 표면이 색을 받습니다 — 알약은 색이 입혀지는 그 물건 자체입니다',
        en: 'What the surface is made of. The surface takes the tint, the way a control does: a pill is the thing being coloured'
      },
      sizeDescription: {
        ko: '행의 최소 높이와 타입 스케일. 같은 size의 PlButton과 줄이 맞습니다',
        en: "The row's minimum height and the type scale. A collapsed pill lines up with a PlButton of the same size"
      },
      elevationDescription: {
        ko: '드롭 섀도 깊이. 2가 기본입니다 — 알약은 페이지의 일부가 아니라 그 위에 떠 있습니다',
        en: 'Drop shadow depth. 2, because a pill is not part of the page — it hovers over it'
      },
      densityDescription: {
        ko: '가운데 열의 양옆 여백을 반으로 줄입니다',
        en: 'Halves the air either side of the middle'
      }
    }),
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '앞쪽 슬롯 — 글리프, 아바타, 상태 점, 사진. 원으로 잘린 정사각형 상자에 들어갑니다',
        en: 'The leading slot — a glyph, an avatar, a status dot, a photo. It goes in a square box clipped to a circle'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '뒤쪽 슬롯. 누를 수 있는 영역 바깥이라 그 자체가 컨트롤일 수 있습니다',
        en: 'The trailing slot. Outside the pressable area, so it can be a control of its own'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '가운데의 표제 — 알약이 지금 무엇에 대한 것인지',
        en: 'The headline in the middle — what the pill is currently about'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 둘째 줄. 한 단계 작고 조용합니다',
        en: 'The second line, under the title. One step down and quieter'
      }
    },
    {
      name: 'details',
      type: 'ReactNode',
      description: {
        ko: 'expanded일 때 드러나는 나머지 절반. 알약이 아래로 자랍니다',
        en: 'The second half, revealed when expanded. The pill grows downward into it'
      }
    },
    {
      name: 'expanded',
      type: 'boolean',
      default: 'false',
      description: { ko: 'details가 보이는지', en: 'Whether details is showing' }
    },
    {
      name: 'position',
      type: "'static' | 'sticky' | 'fixed'",
      default: "'static'",
      description: {
        ko: '페이지 스크롤 안에서 놓이는 방식. fixed는 뷰포트에 고정하고 가운데 놓습니다',
        en: "How it sits in the page's scroll. fixed pins it against the viewport and centres it"
      }
    },
    {
      name: 'side',
      type: "'top' | 'bottom'",
      default: "'top'",
      description: {
        ko: 'position이 static이 아닐 때 붙잡히는 가장자리',
        en: 'Which edge it is held against when position is not static'
      }
    },
    {
      name: 'onClick',
      type: 'MouseEventHandler<HTMLButtonElement>',
      description: {
        ko: '주면 가운데가 진짜 버튼이 됩니다',
        en: 'Passing it makes the middle a real button'
      }
    }
  ],

  PlPopover: [
    {
      name: 'trigger',
      type: 'ReactElement',
      description: {
        ko: '팝업이 매달리고 팝업을 여는 요소',
        en: 'The element the popup hangs off and that opens it'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '팝업의 이름이 되는 제목', en: 'The heading, and what names the popup' }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 한 줄이자 팝업의 접근 가능한 설명',
        en: "A line under the title, and the popup's accessible description"
      }
    },
    {
      name: 'side',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'bottom'",
      shared: true,
      description: {
        ko: '트리거의 어느 가장자리에 나타나는지. 자리가 없으면 반대편으로 뒤집힙니다',
        en: 'Which edge of the trigger it appears on. Flips to the opposite side when there is no room'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      shared: true,
      description: { ko: '그 가장자리를 따라 놓이는 자리', en: 'Where it sits along that edge' }
    },
    {
      name: 'sideOffset',
      type: 'number',
      default: '6',
      description: { ko: '트리거에서 떨어진 거리, px', en: 'Distance from the trigger, in pixels' }
    },
    {
      name: 'alignOffset',
      type: 'number',
      default: '0',
      description: {
        ko: '그 가장자리를 따라 밀리는 거리, px',
        en: 'Shift along that edge, in pixels'
      }
    },
    {
      name: 'arrow',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '트리거를 가리키는 작은 쐐기. 기본은 꺼짐 — 상자 밖으로 나간 쐐기는 흐린 배경을 데려가지 못합니다',
        en: 'The little wedge pointing at the trigger. Off by default: a wedge past the box cannot carry the blurred backdrop'
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '팝업이 열려 있는지. onOpenChange와 함께 controlled로 씁니다',
        en: 'Whether the popover is open. Use with onOpenChange for a controlled one'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      description: {
        ko: 'uncontrolled일 때의 시작 상태',
        en: 'Whether it starts open, for an uncontrolled one'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: {
        ko: '열림 상태가 바뀔 때 호출됩니다',
        en: 'Called when the open state changes'
      }
    },
    {
      name: 'modal',
      type: "boolean | 'trap-focus'",
      default: 'false',
      description: {
        ko: '뒤의 페이지를 가져가는지. false가 popover를 모달과 가르는 것입니다',
        en: 'Whether the page behind is taken away. false is what separates a popover from a modal'
      }
    },
    {
      name: 'dismissible',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'Escape와 바깥 클릭으로 닫히는지',
        en: 'Whether pressing Escape or clicking outside closes the popup'
      }
    },
    {
      name: 'showClose',
      type: 'boolean',
      default: 'false',
      description: { ko: '모서리의 ×', en: 'Shows the × in the corner' }
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
        ko: '팝업 너비의 상한. size가 정하는 값을 덮어씁니다',
        en: "A hard cap on the popup's width, overriding the one size implies"
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '반경, 여백, 팝업 너비의 상한',
        en: 'The radius, the padding and how wide the popup is allowed to get'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. 안쪽의 focus ring까지만 닿습니다',
        en: 'Semantic colour role. It reaches the focus rings inside and nothing else'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '팝업의 안쪽 여백', en: "The popup's inner padding" }
    }
  ],

  PlProgressLinear: [
    ...progressProps({
      ko: '홈의 두께. 바에서 크기를 갖는 건 이것뿐입니다',
      en: 'Thickness of the groove. Nothing else on a bar has a size'
    })
  ],

  /**
   * The ring takes the bar's table unchanged except for what `size` means. Two
   * shapes, one set of props: that is the claim the three indicators make.
   */
  PlProgressBox: [
    ...progressProps({
      ko: '플레이트 하나의 크기',
      en: 'Size of one plate'
    }),
    {
      name: 'count',
      type: 'number',
      default: '4',
      description: {
        ko: '플레이트 몇 장으로 만들지. 기다리는 대상에 진짜로 단계가 있다면 그 수를 주세요',
        en: 'How many plates the row is made of. Set it to the number of steps when the thing being waited on genuinely has steps'
      }
    }
  ],

  PlProgressCircular: [
    ...progressProps({
      ko: '링의 지름. 모든 단계에서 컨트롤 사다리 바로 아래에 앉습니다',
      en: 'Diameter of the ring. Sits just under the control ladder at every step'
    })
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

  PlRating: [
    {
      name: 'value',
      type: 'number',
      description: {
        ko: '점수. onValueChange와 함께 controlled로 씁니다',
        en: 'The score. Use with onValueChange for a controlled rating'
      }
    },
    {
      name: 'defaultValue',
      type: 'number',
      default: '0',
      description: {
        ko: 'uncontrolled일 때 시작 점수',
        en: 'Where an uncontrolled rating starts'
      }
    },
    {
      name: 'onValueChange',
      type: '(value: number) => void',
      description: {
        ko: '새 점수로 호출됩니다. 지워지면 0입니다',
        en: 'Called with the new score. 0 is what a cleared rating reports'
      }
    },
    {
      name: 'count',
      type: 'number',
      default: '5',
      description: {
        ko: '별의 개수, 곧 최고 점수',
        en: 'How many stars there are, and therefore the highest score'
      }
    },
    {
      name: 'precision',
      type: 'number',
      default: '1',
      description: {
        ko: '고를 수 있는 가장 작은 단위. 0.5는 반 별. 그려지는 값은 제한하지 않습니다',
        en: 'The smallest step that can be chosen — 0.5 gives half stars. It never bounds what is drawn'
      }
    },
    {
      name: 'icon · emptyIcon',
      type: 'ReactNode',
      description: {
        ko: '채워진 별과 빈 별의 글리프. 같은 모양이어야 합니다',
        en: 'The glyphs a filled and an empty star are drawn with. They have to be the same shape'
      }
    },
    {
      name: 'clearable',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '이미 고른 점수를 다시 고르면 0으로 지워집니다',
        en: 'Choosing the score that is already chosen clears it back to 0'
      }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '점수를 보여 주기만 합니다. input이 사라지고 이미지 하나가 됩니다',
        en: 'Shows the score without letting it be changed. The inputs go and it becomes one image'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용할 수 없습니다. 줄에서 빛이 꺼집니다',
        en: 'Unavailable. The light goes out of the whole row'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 전송에서 값을 식별합니다',
        en: 'Identifies the value when a form is submitted'
      }
    },
    {
      name: 'required',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '별을 고르기 전까지 폼이 전송되지 않습니다',
        en: 'A form will not submit until a star has been chosen'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '별 하나의 높이. 독립 글리프 사다리입니다',
        en: 'Height of one star, on the standalone-glyph ladder'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'warning'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. 기본이 warning인 것은 별에 기대되는 색이기 때문입니다',
        en: 'Semantic colour role. warning by default, because that is the amber a star is expected to be'
      }
    },
    {
      name: 'label',
      type: 'string',
      default: "'Rating'",
      description: { ko: '컨트롤 전체의 접근 가능한 이름', en: 'Names the whole control' }
    },
    {
      name: 'valueLabel',
      type: '(value: number, count: number) => string',
      default: '`{value} out of {count}`',
      description: {
        ko: '한 선택지의, 그리고 읽기 전용일 때 컨트롤 전체의 접근 가능한 이름',
        en: 'What one choice, and the whole control once it is read only, is called'
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

  PlScrollZone: [
    {
      name: 'orientation',
      type: "'horizontal' | 'vertical'",
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '자식이 흐르는 방향, 따라서 스크롤되는 방향',
        en: 'Which way the children run, and therefore which way the zone scrolls'
      }
    },
    {
      name: 'lines',
      type: 'number',
      default: '1',
      description: {
        ko: '가로 zone이 새 열을 시작하기 전에 채우는 행의 수. 세로 zone에서는 열의 수',
        en: 'How many rows a horizontal zone fills before it starts a new column — columns, for a vertical one'
      }
    },
    {
      name: 'spacing',
      type: 'number',
      default: '2',
      description: {
        ko: '자식 사이의 간격. PlGrid와 같은 사다리이고 2는 0.5rem입니다',
        en: "The gap between children, on PlGrid's own ladder: 2 is 0.5rem"
      }
    },
    {
      name: 'buttons',
      type: "'auto' | 'always' | 'none'",
      default: "'auto'",
      description: {
        ko: '스크롤 버튼을 언제 그릴지. auto는 갈 곳이 있는 쪽만 그립니다',
        en: 'When the scroll buttons are drawn. auto draws only the one that has somewhere to go'
      }
    },
    {
      name: 'buttonPlacement',
      type: "'overlay' | 'inline'",
      default: "'overlay'",
      description: {
        ko: '버튼이 띠 위에 얹히는지 옆에 서는지',
        en: 'Whether the buttons sit over the strip or beside it'
      }
    },
    {
      name: 'mode',
      type: "'item' | 'page' | 'hold'",
      default: "'item'",
      description: {
        ko: '버튼을 누르면 무슨 일이 일어나는지 — 다음 자식으로, 화면 하나만큼, 또는 누르고 있는 동안',
        en: 'What pressing one does: to the next child, by a screenful, or for as long as it is held'
      }
    },
    {
      name: 'step',
      type: 'number',
      default: '1',
      description: {
        ko: 'item 모드에서 한 번 누를 때 움직이는 자식의 수',
        en: 'How many children one press moves, in item mode'
      }
    },
    {
      name: 'speed',
      type: 'number',
      default: '900',
      description: {
        ko: 'hold 모드에서 초당 스크롤되는 픽셀',
        en: 'How fast a held button scrolls, in pixels a second'
      }
    },
    {
      name: 'snap',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '스크롤이 멈추면 가장 가까운 자식을 앞쪽 가장자리로 붙입니다',
        en: 'Snaps the nearest child to the leading edge when the scrolling stops'
      }
    },
    {
      name: 'drag',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '마우스와 펜으로도 띠를 끌 수 있게 합니다. 터치는 브라우저에 맡깁니다',
        en: 'Lets a mouse or a pen drag the strip along. Touch is left to the browser'
      }
    },
    {
      name: 'scrollbar',
      type: 'boolean',
      default: 'false',
      description: { ko: '네이티브 스크롤바를 보입니다', en: 'Shows the native scrollbar' }
    },
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '스크롤 버튼의 재질. zone 자신은 시트를 그리지 않습니다',
        en: 'What the scroll buttons are made of. The zone itself draws no sheet'
      },
      sizeDescription: {
        ko: '버튼의 크기와 버튼이 가장자리에서 떨어진 거리',
        en: 'The size of the buttons and how far in from the edge they sit'
      }
    }).filter((row) => row.name !== 'elevation'),
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '스크롤되는 영역의 이름 — "Categories", "Recent files"',
        en: 'What the scrollable region is called — "Categories", "Recent files"'
      }
    },
    {
      name: 'previousLabel',
      type: 'string',
      default: "'Previous'",
      description: {
        ko: '버튼의 이름. 절대 그려지지 않습니다',
        en: "The button's name. Never drawn"
      }
    },
    {
      name: 'nextLabel',
      type: 'string',
      default: "'Next'",
      description: {
        ko: '버튼의 이름. 절대 그려지지 않습니다',
        en: "The button's name. Never drawn"
      }
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

  PlSkeleton: [
    {
      name: 'shape',
      type: "'line' | 'rect' | 'circle'",
      default: "'line'",
      description: {
        ko: '무엇을 대신하고 있는지. line은 글줄, rect는 덩어리(이미지·차트·지도), circle은 avatar처럼 둥근 것. 셋 다 진짜 컴포넌트가 쓰는 사다리로 크기가 정해집니다',
        en: 'What the placeholder is standing in for. line is a run of text, rect a block, circle an avatar. Each is sized off the ladder the real component uses'
      }
    },
    {
      name: 'lines',
      type: 'number',
      default: '1',
      description: {
        ko: 'shape="line"에서 몇 줄을 그릴지. 마지막 줄은 문단의 마지막 줄처럼 짧게 그려져서, 여러 줄이 바코드가 아니라 산문으로 읽힙니다',
        en: 'How many lines to draw for shape="line". The last one is drawn short, the way the last line of a paragraph is, so a block of them reads as prose rather than as a barcode'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '대신하고 있는 것의 크기 — line에는 타입 스케일, circle에는 지름, rect에는 기본 높이',
        en: 'The scale of the thing being stood in for: the type scale for a line, the diameter for a circle, the default block height for a rect'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'secondary'",
      shared: true,
      description: {
        ko: '색 계열. secondary로 두는 편이 낫습니다 — 아직 도착하지도 않은 내용에 대해 의미론적 색을 입은 placeholder는 무언가를 주장하고 있는 것입니다',
        en: 'Colour family. Worth leaving at secondary: a placeholder that carries a semantic colour is saying something about content that has not arrived yet'
      }
    },
    {
      name: 'width',
      type: 'number | string',
      description: { ko: '명시적 너비. 숫자는 px', en: 'An explicit width. Numbers are pixels' }
    },
    {
      name: 'height',
      type: 'number | string',
      description: { ko: '명시적 높이. 숫자는 px', en: 'An explicit height. Numbers are pixels' }
    },
    {
      name: 'animated',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '지나가는 하이라이트. 수십 개가 놓인 페이지나, 기다림이 길어 움직임이 소음이 되는 곳에서 끄세요. reduced-motion 설정은 이미 알아서 색 맥동으로 바꾸므로, 이것은 접근성 스위치가 아닙니다',
        en: 'The travelling highlight. Turn it off for a page holding dozens, or where motion becomes noise. A reduced-motion preference already swaps the sweep for a colour pulse, so this is not the accessibility switch'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '스크린리더가 듣는 말. 없으면 aria-hidden입니다 — 상자 열두 개가 저마다 자기를 알리는 것은 침묵보다 나쁩니다. 영역 전체를 대표하는 **하나**에만 주면 그것이 live status가 됩니다',
        en: 'What a screen reader is told. Without it the placeholder is aria-hidden, because a dozen boxes each announcing themselves is worse than silence. Give the *one* that stands for the whole region a label and it becomes a live status'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'div가 아닌 다른 요소로 렌더링합니다',
        en: 'Renders something other than a div'
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

  PlSpoiler: [
    {
      name: 'revealed',
      type: 'boolean',
      description: {
        ko: '내용이 드러나 있는지. onRevealedChange와 함께 controlled로 씁니다',
        en: 'Whether the content is uncovered. Use with onRevealedChange for a controlled one'
      }
    },
    {
      name: 'defaultRevealed',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'uncontrolled일 때의 시작 상태',
        en: 'Where an uncontrolled spoiler starts'
      }
    },
    {
      name: 'onRevealedChange',
      type: '(revealed: boolean) => void',
      description: {
        ko: '드러남 상태가 바뀔 때 호출됩니다',
        en: 'Called when the revealed state changes'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      default: "'Reveal'",
      description: { ko: '드러내기 버튼의 문구', en: "The reveal button's label" }
    },
    {
      name: 'hideLabel',
      type: 'ReactNode',
      default: "'Hide'",
      description: {
        ko: 'reversible일 때 숨기기 버튼의 문구',
        en: "The hide button's label, when reversible is on"
      }
    },
    {
      name: 'description',
      type: 'ReactNode | false',
      default: "'This may contain spoilers'",
      description: {
        ko: '버튼 위의 한 줄. false면 아무것도 쓰이지 않은 덮개가 됩니다',
        en: 'The line above the button. false leaves a cover with nothing written on it'
      }
    },
    {
      name: 'action',
      type: 'ReactNode',
      description: {
        ko: '기본 버튼을 통째로 자기 컨트롤로 바꿉니다. 연결은 직접 해야 합니다',
        en: 'Replaces the default reveal button entirely. The replacement is yours to wire up'
      }
    },
    {
      name: 'reversible',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '드러난 뒤 아래에 숨기기 버튼이 나타납니다',
        en: 'Keeps the content coverable: once revealed, a hide button appears under it'
      }
    },
    {
      name: 'maxHeight',
      type: 'number | string',
      description: {
        ko: '덮여 있는 상자의 높이 제한. 드러나면 풀립니다',
        en: 'Clamps the covered box to this height. Revealing releases it'
      }
    },
    {
      name: 'blur',
      type: 'number',
      default: '10',
      description: {
        ko: '내용을 얼마나 흐리게 할지, px',
        en: 'How hard the content is blurred, in pixels'
      }
    },
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: { ko: '내용 주변의 안쪽 여백', en: 'Inner padding around the content' }
    },
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '시트의 재질. 색이 들어가지 않습니다. ghost는 상자를 아예 그리지 않습니다',
        en: 'What the sheet is made of. Never dyed. ghost draws no box at all'
      },
      sizeDescription: {
        ko: '시트의 반경과 그 위 버튼의 크기',
        en: "The sheet's radius, and the size of the button on it"
      },
      densityDescription: {
        ko: '덮개의 문구와 버튼 주변 여백',
        en: "Padding around the cover's own text and button"
      }
    })
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
        ko: '행이 밑으로 지나가는 동안 열 이름을 고정합니다. 스크롤될 상자가 있어야 의미가 있습니다 — 보통은 maxHeight',
        en: 'Pins the column names while the rows scroll under them. It needs something to scroll in — usually maxHeight'
      }
    },
    {
      name: 'maxHeight',
      type: 'number | string',
      description: {
        ko: '격자 높이의 상한. 넘으면 페이지가 늘어나는 대신 시트 안에서 행이 스크롤됩니다. caption은 그 위에 남습니다',
        en: 'A hard cap on the grid. Past it the rows scroll inside the sheet rather than the page growing; the caption stays above it'
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

  PlTabs: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '탭 **바**의 재질. solid는 홈에 맑은 판이 타고, glass는 가장자리의 선 위를 인디케이터가 달리고, ghost는 선이 없습니다',
        en: 'What the tab **bar** is made of. solid rides a clear pane in a groove, glass runs the indicator along a rule at the edge, ghost drops the rule'
      },
      sizeDescription: {
        ko: '탭의 높이와 타입 스케일. PlButton과 같은 사다리',
        en: 'Tab height and type scale — the same ladder as PlButton'
      }
    }),
    {
      name: 'orientation',
      type: "'horizontal' | 'vertical'",
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '바가 놓이는 방향. vertical은 탭을 옆으로 세우고 방향키를 다른 축으로 옮깁니다',
        en: 'Which way the bar runs. vertical puts the tabs down the side and moves the arrow keys onto the other axis'
      }
    },
    {
      name: 'value',
      type: 'string | number | null',
      description: {
        ko: '선택된 탭. onValueChange와 함께 controlled로 씁니다',
        en: 'The chosen tab. Use with onValueChange for a controlled set'
      }
    },
    {
      name: 'defaultValue',
      type: 'string | number | null',
      description: { ko: 'uncontrolled일 때 처음 선택된 탭', en: 'Which starts chosen' }
    },
    {
      name: 'onValueChange',
      type: '(value: string | number | null) => void',
      description: { ko: '선택이 바뀔 때 호출됩니다', en: 'Called with the new value' }
    },
    {
      name: 'activateOnFocus',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '방향키가 지나가는 탭을 곧바로 선택할지. 기본은 꺼짐 — 패널이 하나라도 fetch를 한다면 탭 네 개를 지나가는 동안 요청이 네 번 나갑니다',
        en: 'Whether the arrow keys also choose the tab they land on. Off by default — the moment one panel fetches, walking past four tabs fires four requests'
      }
    },
    {
      name: 'loopFocus',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '마지막 탭에서 첫 탭으로 방향키가 넘어가는지',
        en: 'Whether the arrow keys wrap from the last tab back to the first'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '탭들이 바의 전체 너비를 균등하게 나눠 가집니다',
        en: "The tabs share the bar's full width, each taking an equal part of it"
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: 'PlTab과 PlTabPanel. 컴포넌트가 알아서 둘을 갈라 놓습니다',
        en: 'The PlTab and PlTabPanel children. The component sorts the two apart itself'
      }
    }
  ],

  PlTab: [
    {
      name: 'value',
      type: 'string | number',
      required: true,
      description: {
        ko: '탭을 식별하고, 같은 값의 패널을 골라냅니다',
        en: 'Identifies the tab, and picks out the panel with the same value'
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
      description: { ko: '고를 수 없지만 목록에는 남습니다', en: 'Unavailable, but still listed' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '탭의 라벨', en: "The tab's label" }
    }
  ],

  PlTabPanel: [
    {
      name: 'value',
      type: 'string | number',
      required: true,
      description: { ko: '어느 탭이 이 패널을 보여 주는지', en: 'Which tab shows this panel' }
    },
    {
      name: 'keepMounted',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '숨겨진 동안에도 DOM에 남깁니다. 만드는 비용이 크거나 form 상태를 쥐고 있는 패널에',
        en: 'Keeps the panel in the DOM while it is hidden. For one that is expensive to build, or that holds form state'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '패널의 내용', en: "The panel's content" }
    }
  ],

  PlTimePicker: [
    {
      name: 'value',
      type: 'Date | null',
      description: {
        ko: '선택된 시각. Date이므로 날짜도 함께 지닙니다 — referenceDate를 보세요',
        en: 'The chosen time. A Date, so it carries a day as well — see referenceDate'
      }
    },
    {
      name: 'defaultValue',
      type: 'Date | null',
      description: { ko: 'uncontrolled일 때 시작하는 시각', en: 'The time the picker starts on' }
    },
    {
      name: 'onValueChange',
      type: '(value: Date | null) => void',
      description: { ko: '값이 바뀔 때 호출됩니다', en: 'Called with the new value' }
    },
    {
      name: 'referenceDate',
      type: 'Date',
      default: 'today',
      description: {
        ko: '아직 값이 없을 때 고른 시각이 얹히는 날. picker가 마운트되어 있는 동안 고정입니다 — 자정을 넘겨 열어 둔 팝업이 값을 다른 날로 옮기면 안 되니까요',
        en: 'The day a chosen time is written onto while there is no value yet. Held still for as long as the picker is mounted, so a popup left open across midnight does not move the value onto a new day'
      }
    },
    {
      name: 'minTime',
      type: 'Date | null',
      description: {
        ko: '고를 수 있는 가장 이른 시각. 시계만 읽습니다',
        en: 'The earliest time of day that may be chosen. Only the clock is read'
      }
    },
    {
      name: 'maxTime',
      type: 'Date | null',
      description: {
        ko: '고를 수 있는 가장 늦은 시각',
        en: 'The latest time of day that may be chosen'
      }
    },
    ...timeColumnProps,
    {
      name: 'showNowButton',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '푸터에 지금으로 가는 지름길을 둡니다',
        en: 'Offers the shortcut to the current time in the footer'
      }
    },
    ...pickerProps({
      format: "{ hour: 'numeric', minute: '2-digit' }",
      formatDescription: {
        ko: 'trigger가 시각을 쓰는 방식. Intl로 그대로 넘어갑니다. showSeconds면 초가 붙습니다',
        en: 'How the trigger writes the chosen time. Passed straight to Intl; seconds are added when showSeconds is on'
      },
      closeOnSelect: 'false',
      closeOnSelectDescription: {
        ko: '어느 열이든 건드리는 즉시 팝업을 닫습니다. PlDatePicker와 달리 기본이 false인 건 시각이 답 두 개이고, 첫 답에 닫으면 9:30을 고르는 데 팝업을 두 번 열어야 하기 때문입니다',
        en: 'Closes the popup as soon as any column is touched. false by default, unlike PlDatePicker, because a time is two answers and closing after the first would make choosing 9:30 a matter of opening the popup twice'
      },
      nameDescription: {
        ko: '폼 제출 시 필드를 식별합니다. HH:MM으로, showSeconds면 HH:MM:SS로 보냅니다',
        en: 'Identifies the field when a form is submitted, as HH:MM — HH:MM:SS when showSeconds is on'
      }
    })
  ],

  PlTimeline: [
    {
      name: 'active',
      type: 'number',
      description: {
        ko: '지금 진행 중인 항목의 인덱스. 그 앞은 전부 complete, 그 뒤는 전부 upcoming입니다. 값이 아니라 인덱스인 이유는 timeline에 선택이 없기 때문입니다 — 고르는 것은 없고, 현실이 목록의 어디까지 왔는지만 묻습니다',
        en: 'The index of the item being worked on now. Everything before it is complete, everything after still to come. An index rather than a value, because a timeline has no selection — nothing is chosen, and the only question is how far reality has got'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: { ko: 'bullet 지름과 타입 스케일', en: 'Bullet diameter and type scale' }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: 'bullet의 그러데이션과 이어진 선의 색 계열',
        en: 'The gradient in the bullets and the family the connectors take'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: '항목 사이의 간격만. 타입 스케일도 bullet도 건드리지 않습니다',
        en: 'Spacing between items only. Never the type scale, never the bullet'
      }
    },
    {
      name: 'orientation',
      type: "'horizontal' | 'vertical'",
      default: "'vertical'",
      shared: true,
      description: {
        ko: '순서가 흐르는 방향. vertical은 단계 수와 설명 길이에 제한이 없고, horizontal은 결제 화면 위쪽의 stepper라 라벨이 짧을 때만 정직합니다',
        en: 'Which way the sequence runs. vertical takes any number of steps with anything to say about each; horizontal is the stepper across the top of a checkout, honest only while every label is short'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'ol이 아닌 다른 요소로 렌더링합니다',
        en: 'Renders something other than an ol'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'PlTimelineItem들', en: 'The PlTimelineItems' }
    }
  ],

  PlTimelineItem: [
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '이 단계의 제목', en: 'The heading of this step' }
    },
    {
      name: 'meta',
      type: 'ReactNode',
      description: {
        ko: '언제였는지 — 날짜, 소요 시간, 이름. 넓으면 제목 옆에, 좁으면 그 아래에 놓입니다',
        en: 'When it happened — a date, a duration, a name. Beside the title on a wide item, under it on a narrow one'
      }
    },
    {
      name: 'bullet',
      type: 'ReactNode',
      description: {
        ko: 'bullet 안에 들어가는 것: 숫자, 아이콘, avatar. 생략하면 그냥 원이고, 자기에 대해 할 말이 없는 단계는 그래야 합니다',
        en: 'What goes inside the bullet: a number, an icon, an avatar. Omit it and the bullet is a plain disc, which is what a step with nothing to say about itself should be'
      }
    },
    {
      name: 'status',
      type: "'complete' | 'current' | 'upcoming'",
      description: {
        ko: 'timeline의 active가 계산했을 값을 이 항목에 한해 덮어씁니다 — 실패해서 멈춘 단계, 건너뛴 단계',
        en: 'Overrides what the timeline’s active would have computed for this item — a step that failed and stopped the sequence, a step that was skipped'
      }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '이 항목에 한해 timeline의 색 계열을 덮어씁니다',
        en: 'Overrides the timeline’s colour family for this item alone'
      }
    },
    {
      name: 'connector',
      type: "'solid' | 'dashed' | 'dotted' | 'none'",
      default: "'solid'",
      description: {
        ko: '다음 항목으로 이어지는 선을 어떻게 그릴지. 마지막 항목의 선은 어차피 그려지지 않습니다',
        en: 'How the line to the next item is drawn. The last item’s line is never drawn anyway'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '단계의 본문', en: 'The body of the step' }
    }
  ],

  PlToastProvider: [
    {
      name: 'variant',
      type: VARIANT,
      default: "'glass'",
      shared: true,
      description: {
        ko: '토스트의 재질. 색이 들어가지 않는 두 재질은 가장 불투명한 유리입니다 — 토스트 뒤에 무엇이 있을지 알 수 없기 때문입니다',
        en: 'What a toast is made of. The two undyed materials are the glass at its most opaque, because what is behind a toast is arbitrary'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: { ko: '토스트의 여백과 타입 스케일', en: 'Padding and type scale of a toast' }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '기본 색 계열. 개별 토스트는 add에서 덮어씁니다',
        en: 'The default colour family. A single toast overrides it in add'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '여백만 바꿉니다', en: 'Padding only' }
    },
    {
      name: 'position',
      type: "'top-start' | 'top-center' | 'top-end' | 'bottom-start' | 'bottom-center' | 'bottom-end'",
      default: "'bottom-end'",
      description: {
        ko: '스택이 놓이는 자리. side와 align 쌍이 아니라 한 단어인 이유는 둘이 독립적이지 않기 때문입니다 — 토스트 스택은 언제나 위나 아래에 고정되지, 옆에 붙지 않습니다',
        en: 'Where the stack sits. One word rather than a side plus an align pair, because they are not independent: a toast stack is always pinned to the top or the bottom, never to a side'
      }
    },
    {
      name: 'timeout',
      type: 'number',
      default: '5000',
      description: {
        ko: '기본 지속 시간(ms). 0은 닫을 때까지 남습니다 — 독자가 무언가 해야 하는 토스트에는 그쪽이 맞습니다. 읽히기 전에 사라진 토스트는 아무 말도 하지 않은 것입니다',
        en: 'How long a toast lasts by default, in milliseconds. 0 keeps it up until it is closed, which is right for anything the reader has to act on: a toast that leaves before it is read said nothing'
      }
    },
    {
      name: 'limit',
      type: 'number',
      default: '3',
      description: {
        ko: '한 번에 보이는 개수. 나머지는 버려지지 않고 스택이 비는 대로 드러납니다',
        en: 'How many are shown at once. The rest are kept and revealed as the stack drains rather than being thrown away'
      }
    },
    {
      name: 'width',
      type: 'number | string',
      default: '380',
      description: {
        ko: '토스트의 최대 너비. 숫자는 px',
        en: 'How wide a toast is allowed to get. Numbers are pixels'
      }
    },
    {
      name: 'closeLabel',
      type: 'string',
      default: "'Close'",
      description: {
        ko: '모든 토스트의 × 버튼 이름. 화면에는 그려지지 않습니다',
        en: 'Accessible name of every toast’s × button. Never drawn'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '앱. 한 번만 감싸세요', en: 'The application. Wrap it once' }
    }
  ],

  usePlToast: [
    {
      name: 'add',
      type: '(options: PlToastOptions) => string',
      description: {
        ko: '토스트를 올리고 id를 돌려줍니다',
        en: 'Raises a toast and returns its id'
      }
    },
    {
      name: 'update',
      type: '(id: string, options: PlToastOptions) => void',
      description: {
        ko: '이미 화면에 있는 토스트를 바꿉니다. id를 다시 쓰면 그 자리에서 갱신되고 타이머가 다시 시작됩니다',
        en: 'Changes a toast already on screen. Reusing an id updates it in place and restarts its timer'
      }
    },
    {
      name: 'close',
      type: '(id?: string) => void',
      description: {
        ko: '토스트 하나를, 인자 없이 부르면 전부를 닫습니다',
        en: 'Closes one toast, or every toast when called with nothing'
      }
    },
    {
      name: 'promise',
      type: 'promise(work, { loading, success, error })',
      description: {
        ko: 'promise를 따라가는 토스트 하나. loading 상태에는 Base UI가 timeout 0을 적용하므로 느린 요청이 자기 토스트를 지워 버리지 못합니다',
        en: 'One toast that follows a promise. Base UI applies timeout 0 to the loading state, so a slow request cannot dismiss its own toast'
      }
    },
    {
      name: 'toasts',
      type: 'ToastObject[]',
      description: {
        ko: '지금 스택에 있는 토스트 전부. 최신이 먼저',
        en: 'Every toast currently in the stack, newest first'
      }
    }
  ],

  PlToastOptions: [
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '헤드라인', en: 'The headline' }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '그 아래의 상세. 이것만 있으면 한 줄짜리 토스트입니다',
        en: 'The detail under it. A toast with only this is a one-line toast'
      }
    },
    {
      name: 'id',
      type: 'string',
      description: {
        ko: '다시 쓰면 그 토스트를 제자리에서 갱신합니다',
        en: 'Reusing one updates that toast in place'
      }
    },
    {
      name: 'timeout',
      type: 'number',
      description: {
        ko: '이 토스트만의 지속 시간. 0은 닫을 때까지',
        en: 'This toast’s own lifetime. 0 keeps it up until it is closed'
      }
    },
    {
      name: 'priority',
      type: "'low' | 'high'",
      default: "'low'",
      description: {
        ko: 'high는 스크린리더를 끊고, low는 쉬는 지점을 기다립니다. 오류는 끊을 만하고 저장 확인은 그렇지 않습니다',
        en: 'high interrupts a screen reader; low waits for a pause. An error is worth interrupting for and a save confirmation is not'
      }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '이 토스트만 provider의 색 계열을 덮어씁니다',
        en: 'Overrides the provider’s colour family for this toast alone'
      }
    },
    {
      name: 'variant',
      type: VARIANT,
      shared: true,
      description: {
        ko: '이 토스트만 provider의 재질을 덮어씁니다',
        en: 'Overrides the provider’s material for this toast alone'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode | false',
      description: {
        ko: '앞의 글리프. 생략하면 color에 맞는 것, false면 없음, 노드면 교체',
        en: 'The glyph at the start. Omitted it follows color, false drops it, a node replaces it'
      }
    },
    {
      name: 'actionLabel',
      type: 'ReactNode',
      description: {
        ko: '액션 버튼의 라벨. 넘기는 것이 버튼을 나타나게 합니다',
        en: 'The label of the action button. Passing it is what makes the button appear'
      }
    },
    {
      name: 'onAction',
      type: '(event: MouseEvent) => void',
      description: { ko: '액션 버튼을 눌렀을 때', en: 'Called when the action button is pressed' }
    },
    {
      name: 'onClose',
      type: '() => void',
      description: {
        ko: '어떻게 닫혔든 닫혔을 때',
        en: 'Called when the toast closes, however it closed'
      }
    },
    {
      name: 'onRemove',
      type: '() => void',
      description: {
        ko: '사라지는 애니메이션이 끝나고 DOM에서 나갔을 때',
        en: 'Called once it has finished animating out and left the DOM'
      }
    }
  ],

  PlToolbar: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '바의 재질. 색이 들어가지 않습니다 — 툴바는 남의 컨트롤을 담습니다',
        en: "What the bar is made of. Never dyed: a toolbar holds other people's controls"
      },
      sizeDescription: {
        ko: '바의 여백과 반경. 높이는 안에 든 컨트롤이 정합니다',
        en: "The bar's padding and radius. The height is whatever the controls in it need"
      },
      elevationDescription: {
        ko: '드롭 섀도 깊이. 고정되어도 0입니다 — 헤더 아래 그림자는 스크롤된 뒤에야 참이 됩니다',
        en: 'Drop shadow depth. 0 even when pinned: a shadow under a header is only true once the page has scrolled'
      },
      densityDescription: {
        ko: '여백만 바꿉니다. 타입 스케일은 그대로',
        en: 'Padding only — never the type scale'
      }
    }),
    {
      name: 'position',
      type: "'static' | 'sticky' | 'fixed'",
      default: "'static'",
      description: {
        ko: '페이지 스크롤 안에서 바가 놓이는 방식. sticky는 자기 자리를 차지하고, fixed는 흐름에서 빠집니다',
        en: "How the bar sits in the page's scroll. sticky takes up its own space; fixed leaves the flow"
      }
    },
    {
      name: 'side',
      type: "'top' | 'bottom'",
      default: "'top'",
      description: {
        ko: 'position이 static이 아닐 때 붙잡히는 가장자리',
        en: 'Which edge it is held against when position is not static'
      }
    },
    {
      name: 'divider',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '내용을 향한 가장자리에 얇은 선을 긋습니다',
        en: 'Draws a hairline along the edge that faces the content'
      }
    },
    {
      name: 'start',
      type: 'ReactNode',
      description: {
        ko: '바의 시작에 고정되는 것 — 로고, 제목, 뒤로 가기',
        en: 'Pinned to the start of the bar: a logo, a title, a back button'
      }
    },
    {
      name: 'end',
      type: 'ReactNode',
      description: { ko: '끝에 고정되는 것 — 액션들', en: 'Pinned to the end: the actions' }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'div가 아닌 다른 요소로 렌더링합니다 — header, nav',
        en: 'Renders something other than a div — a header, a nav'
      }
    }
  ],

  PlTooltip: [
    {
      name: 'content',
      type: 'ReactNode',
      required: true,
      description: {
        ko: 'tooltip이 하는 말. 짧은 구절이어야 합니다 — tooltip은 컨테이너가 아닙니다. 터치 화면에서는 포인터가 닿을 수 없고, 주의가 옮겨가는 순간 사라지며, 그 안의 무엇도 누를 수 없습니다',
        en: 'What the tooltip says. A short phrase: a tooltip is not a container — it cannot be reached by a pointer on a touch screen, it disappears the moment attention moves, and nothing inside it can be clicked'
      }
    },
    {
      name: 'children',
      type: 'ReactElement',
      required: true,
      description: {
        ko: 'tooltip이 매달리는 요소. 정확히 하나여야 하고, ref와 props를 받을 수 있어야 합니다 — 모든 Plass 컴포넌트가 그렇습니다',
        en: 'The element the tooltip hangs off. Exactly one element, which must accept a ref and spread props — every Plass component does'
      }
    },
    {
      name: 'side',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'top'",
      shared: true,
      description: {
        ko: '트리거의 어느 변에 나타날지. 자리가 없으면 반대편으로 뒤집힐 수 있고, 그것이 옳은 동작입니다',
        en: 'Which edge of the trigger it appears on. May flip to the opposite side when there is no room, which is the right behaviour'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      shared: true,
      description: { ko: '그 변을 따라 어디에 놓일지', en: 'Where it sits along that edge' }
    },
    {
      name: 'sideOffset',
      type: 'number',
      default: '6',
      description: { ko: '트리거와의 거리(px)', en: 'Distance from the trigger, in pixels' }
    },
    {
      name: 'delay',
      type: 'number',
      default: '600',
      description: {
        ko: '포인터가 얼마나 머물러야 열리는지(ms)',
        en: 'How long the pointer has to rest before it opens, in milliseconds'
      }
    },
    {
      name: 'closeDelay',
      type: 'number',
      default: '0',
      description: {
        ko: '포인터가 떠난 뒤 닫히기까지 기다리는 시간',
        en: 'How long it waits before closing once the pointer leaves'
      }
    },
    {
      name: 'arrow',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '트리거를 가리키는 작은 쐐기를 그릴지',
        en: 'Draws the little wedge pointing at the trigger'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'sm'",
      shared: true,
      description: { ko: '판의 타입 스케일과 여백', en: 'Type scale and padding of the plate' }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'secondary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. tooltip은 다른 무언가에 **대한** 메모이지 그 무언가 자체가 아니므로 중립 계열이 정직한 기본값입니다 — 삭제 버튼 위의 빨간 tooltip은 tooltip이 알지 못하는 것을 말하고 있는 셈입니다',
        en: 'Semantic colour role. A tooltip is a note *about* something rather than the thing itself, so the neutral family is the honest default — a red tooltip on a delete button is saying something the tooltip does not know'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: '판의 가로 여백만 바꿉니다',
        en: 'The plate’s horizontal padding, and nothing else'
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: 'tooltip이 열려 있는지. controlled로 쓰려면 onOpenChange와 함께',
        en: 'Whether the tooltip is open. Use with onOpenChange for a controlled one'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      description: {
        ko: 'uncontrolled일 때 처음부터 열려 있을지',
        en: 'Whether it starts open, for an uncontrolled one'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열림 상태가 바뀔 때', en: 'Called when the open state changes' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      shared: true,
      description: {
        ko: '트리거는 그대로 두고 tooltip만 열리지 않게 합니다. 라벨이 잘렸을 때만 존재하는 tooltip을 위한 것입니다',
        en: 'Stops the tooltip from opening at all, without disabling the trigger. For the tooltip that only exists while a label is truncated'
      }
    }
  ],

  PlTypography: [
    {
      name: 'level',
      type: "'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6' | 'body' | 'lead' | 'caption' | 'overline'",
      default: "'body'",
      description: {
        ko: '타입 스케일과 그것을 담는 요소. h1~h6는 같은 이름의 heading, lead와 body는 p, caption과 overline은 span으로 그려집니다. variant가 아닌 이유는, 이 라이브러리에서 variant는 표면의 재질을 뜻하기 때문입니다',
        en: 'The type scale, and the element that carries it. h1–h6 render the matching heading, lead/body a p, caption/overline a span. Not called variant, because in this library variant names what a surface is made of'
      }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '의미론적 색 역할. 기본값이 **없습니다** — 문단은 주변 문단과 같아 보이는 것이 보통이라, 색을 요청하지 않으면 페이지의 잉크를 그대로 씁니다',
        en: 'Semantic colour role. There is **no** default — text inherits the page’s own colour unless a role is asked for, because a paragraph normally looks like the paragraphs around it'
      }
    },
    {
      name: 'weight',
      type: "'regular' | 'medium' | 'semibold' | 'bold'",
      description: {
        ko: 'level이 정했을 굵기를 덮어씁니다. 요소에 font 클래스가 정확히 하나만 붙도록 JS에서 결정됩니다',
        en: 'Overrides the weight the level would otherwise pick. Resolved in JS so exactly one font class is ever emitted'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end' | 'justify'",
      shared: true,
      description: { ko: '텍스트 정렬', en: 'Text alignment' }
    },
    {
      name: 'lines',
      type: 'number',
      description: {
        ko: '이 줄 수로 말줄임합니다. 1은 한 줄 잘라내기이고, 그 이상은 line-clamp 상자입니다',
        en: 'Clamps the text to this many lines with an ellipsis. 1 is a single-line truncation; more uses the line-clamp box'
      }
    },
    {
      name: 'gutter',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '아래에 산문이 기대하는 여백을 더합니다. 기본은 꺼짐 — margin을 주입하는 라이브러리 컴포넌트는 레이아웃이 싸워야 하는 컴포넌트입니다',
        en: 'Adds the space below that a run of prose expects. Off by default: a library component that injects margins is one a layout has to fight'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: '타입 스케일은 그대로 두고 다른 요소로 렌더링합니다 — 문서 개요에 들어가면 안 되는 소제목, 또는 그 반대',
        en: 'Renders a different element without changing the type scale — a subheading that should not enter the document outline, or the other way round'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '텍스트', en: 'The text' }
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
