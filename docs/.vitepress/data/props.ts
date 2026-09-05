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
 * The two props a caller reaches a component's own surface with.
 *
 * Written once because they are one contract rather than two per-component
 * decisions: a `className` joins the component's own classes rather than
 * replacing them, and a `style` is applied over the custom properties the
 * component wrote. Only the name of *what they land on* differs, which is what
 * `where` says.
 *
 * A component whose props extend a DOM element's takes both without being told
 * to; these rows are for the ones whose prop types are closed, where a reader
 * cannot assume it.
 */
/**
 * The four parts of a labelled control a `className` does not reach.
 *
 * A field's `className` lands on the *stack* — the wrapper holding the label,
 * the control and the two lines of text under it — because that is the element
 * a caller positions and sizes. `control` is the one inside it that is acted
 * on, and it is the override most people are actually reaching for.
 */
/**
 * The chord map a field takes.
 *
 * One row rather than five, for the reason `pickerProps` is one function: a
 * reader who has learned what `hotKeys` does on a text field must not have to
 * read a subtly different sentence about it on a combobox.
 */
const hotKeysProp: PropRow = {
  name: 'hotKeys',
  type: 'Record<string, () => void>',
  description: {
    ko: "이 컨트롤이 답할 chord들. PlHotKeys가 그리는 것과 같은 철자입니다 — { 'Mod+Enter': save, Escape: cancel }. 맞는 chord는 **소비됩니다**",
    en: "Chords this control answers to, spelled the way PlHotKeys draws them — { 'Mod+Enter': save, Escape: cancel }. A chord that matches is **consumed**"
  }
};

const fieldClassNames: PropRow = {
  name: 'classNames',
  type: '{ label?, control?, description?, error?: string }',
  description: {
    ko: 'className이 닿지 않는 부분에 붙는 class. control은 실제로 조작하는 부분입니다',
    en: 'Classes on the parts a className does not reach. control is the part a reader acts on'
  }
};

/**
 * The one part of a portalled surface a `className` does not reach.
 *
 * `className` lands on the surface itself — the sheet, the panel, the popup —
 * because that is what a reader points at and calls the component. The scrim is
 * a second element behind it, drawn into the same portal, and this is the only
 * way to say anything about it.
 */
const portalClassNames: PropRow = {
  name: 'classNames',
  type: '{ backdrop?: string }',
  description: {
    ko: 'className이 닿지 않는 부분에 붙는 class. backdrop은 표면 뒤에 깔리는 scrim입니다',
    en: 'Classes on the parts a className does not reach. backdrop is the scrim drawn behind the surface'
  }
};

function stylingProps(where: Text): PropRow[] {
  return [
    {
      name: 'className',
      type: 'string',
      description: {
        ko: `${where.ko}에 붙는 class. 컴포넌트 자신의 class를 대체하지 않고 함께 적용됩니다`,
        en: `Classes on ${where.en}, alongside the component's own rather than in place of them`
      }
    },
    {
      name: 'style',
      type: 'CSSProperties',
      description: {
        ko: `${where.ko}에 붙는 inline style. 컴포넌트가 쓴 custom property 위에 적용됩니다`,
        en: `Inline styles on ${where.en}, applied over the custom properties it wrote`
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
  /**
   * The three per-child props, for the effects that can be told off across
   * their children. The four that already read their children cannot.
   */
  stagger?: boolean;
  /** The two scroll-linked props, on the same six and absent from the same four. */
  timeline?: boolean;
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

  if (options.timeline) {
    rows.push(
      {
        name: 'timeline',
        type: "'auto' | 'view'",
        default: "'auto'",
        shared: true,
        description: {
          ko: '무엇이 애니메이션을 진행시키는지 — 시계인지 독자의 스크롤 위치인지. view는 duration, delay, repeat, trigger를 무시하고 range로 달립니다',
          en: "What advances the animation: the clock, or the reader's scroll position. view ignores duration, delay, repeat and trigger, and runs against range instead"
        }
      },
      {
        name: 'range',
        type: 'string',
        default: "'entry 0% cover 45%'",
        shared: true,
        description: {
          ko: 'CSS가 animation-range를 쓰는 그대로. timeline이 view일 때만 읽힙니다',
          en: 'As CSS writes an animation-range. Only read when timeline is view'
        }
      }
    );
  }

  if (options.stagger) {
    rows.push(
      {
        name: 'stagger',
        type: 'number',
        default: '0',
        shared: true,
        description: {
          ko: '자식마다 delay에 더해지는 시간(ms). 0이면 상자 자체가 재생되고, 그 외에는 효과가 자식들로 옮겨 가면서 상자에서는 빠집니다',
          en: "Milliseconds added to each child's delay. 0 plays the box itself; anything else moves the effect onto the children and takes it off the box"
        }
      },
      {
        name: 'durationStep',
        type: 'number',
        default: '0',
        shared: true,
        description: {
          ko: '자식마다 duration에 더해지는 시간(ms). 음수도 되고, 0 아래로는 내려가지 않습니다',
          en: "Milliseconds added to each child's duration. Negative is allowed; floored at 0"
        }
      },
      {
        name: 'reverse',
        type: 'boolean',
        default: 'false',
        shared: true,
        description: {
          ko: '마지막 자식부터 첫 자식까지 순서를 뒤집습니다. 순서만 뒤집히고 각 자식은 그대로 앞으로 재생됩니다',
          en: 'Runs the set from the last child to the first. Only the order turns round; each child still plays forwards'
        }
      }
    );
  }

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
      name: 'truncate',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '제목과 부제를 각각 한 줄로 자르고 넘치면 말줄임합니다. 기본값이 false인 이유는 접힘 제목이 대개 한 문장이기 때문입니다',
        en: 'Holds the title and the subtitle to one line each, ellipsing what runs past. Off by default, because the heading on a fold is usually a whole sentence'
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
      name: 'durationStep',
      type: 'number',
      default: '0',
      shared: true,
      description: {
        ko: '자식마다 duration에 더해지는 시간(ms). 음수도 되고, 0 아래로는 내려가지 않습니다',
        en: "Milliseconds added to each child's duration. Negative is allowed; floored at 0"
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
    ...animateProps({ duration: '1000', repeat: "'infinite'", stagger: true, timeline: true }),
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <div>'
      }
    }
  ],
  PlAnimateCounter: [
    {
      name: 'value',
      type: 'number',
      required: true,
      description: {
        ko: '도착하는 숫자이자 스크린 리더가 듣는 숫자',
        en: 'The number it arrives at, and the one a screen reader is told'
      }
    },
    {
      name: 'from',
      type: 'number',
      default: '0',
      description: { ko: '세기 시작하는 숫자', en: 'The number it starts from' }
    },
    {
      name: 'duration',
      type: 'number',
      default: '1200',
      shared: true,
      description: {
        ko: '세는 데 걸리는 시간(ms)',
        en: 'How long the count takes, in milliseconds'
      }
    },
    {
      name: 'delay',
      type: 'number',
      default: '0',
      shared: true,
      description: { ko: '시작하기까지 기다리는 시간(ms)', en: 'How long it waits before starting' }
    },
    {
      name: 'format',
      type: 'Intl.NumberFormatOptions',
      description: {
        ko: '숫자를 어떻게 쓸지. 카운트가 keyframe이 아니라 JavaScript인 이유입니다 — CSS는 숫자를 셀 수는 있어도 천 단위 구분을 넣지는 못합니다',
        en: 'How the number is written. This is why the count is JavaScript rather than a keyframe: CSS can tick a number and cannot put a thousands separator in one'
      }
    },
    {
      name: 'easing',
      type: '(t: number) => number',
      description: {
        ko: '카운트의 모양. CSS 문자열이 아니라 함수입니다 — 건넬 CSS 애니메이션이 없습니다. 기본은 ease out입니다',
        en: 'The shape of the count, as a function. Not a CSS easing string: there is no CSS animation to hand one to. It eases out by default'
      }
    },
    {
      name: 'trigger',
      type: "'mount' | 'visible' | 'hover' | 'manual'",
      default: "'visible'",
      description: {
        ko: '무엇이 카운트를 시작하는지. 라이브러리에서 마운트에 시작하지 않는 유일한 컴포넌트입니다 — 화면 밖에서 돈 카운트는 이미 거기 있던 숫자를 전달한 것입니다',
        en: 'What starts the count. The one component in the library that does not start on mount: a count that ran off screen delivered a number that was already there'
      }
    },
    {
      name: 'play · once · threshold · paused',
      type: 'boolean · boolean · number · boolean',
      description: {
        ko: '다른 트랜지션과 같은 넷',
        en: 'The same four the other transitions take'
      }
    },
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<span> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <span>'
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
    ...animateProps({ duration: '300', stagger: true, timeline: true }),
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <div>'
      }
    }
  ],
  PlAnimateFloat: [
    {
      name: 'distance',
      type: 'number | string',
      default: '8',
      description: {
        ko: '시작한 자리에서 얼마나 멀어지는지. 작은 것이 의도입니다 — 열두 픽셀쯤을 넘으면 표류가 아니라 움직이는 무언가가 됩니다',
        en: 'How far it drifts from where it started. Small on purpose: past about a dozen pixels it stops being a drift'
      }
    },
    {
      name: 'orientation',
      type: "'vertical' | 'horizontal'",
      default: "'vertical'",
      description: { ko: '어느 쪽으로 떠다닐지', en: 'Which way it drifts' }
    },
    ...animateProps({
      duration: '3000',
      repeat: "'infinite'",
      omit: ['mode', 'stagger', 'durationStep', 'reverse', 'timeline', 'range']
    }),
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
    ...animateProps({ duration: '320', stagger: true, timeline: true }),
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
  PlAnimateReveal: [
    {
      name: 'mode',
      type: "'in' | 'out'",
      default: "'in'",
      description: {
        ko: '드러나는지 다시 덮이는지. out은 같은 와이프를 거꾸로 돌린 것이라, 열린 쪽으로 닫힙니다',
        en: 'Whether the content is uncovered or covered again. out is the same wipe run backwards, so it closes from the edge it opened towards'
      }
    },
    {
      name: 'from',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'left'",
      shared: true,
      description: {
        ko: '와이프가 시작하는 모서리. 라이브러리 전체가 그렇듯 물리적입니다 — 위에서 걷히는 제목은 어떤 쓰기 방향에서도 위에서 걷힙니다',
        en: 'Which edge the wipe starts at. Physical, as it is everywhere in the library: a heading uncovered from the top is uncovered from the top in every writing direction'
      }
    },
    {
      name: 'fade',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '와이프 뒤에서 함께 나타납니다. 다른 모든 효과와 반대로 기본이 꺼짐입니다 — reveal은 fade가 아니라는 것이 이 효과의 전부이기 때문입니다',
        en: 'Fades in behind the wipe. Off by default, the opposite of every other effect, because a reveal not being a fade is the whole point of it'
      }
    },
    ...animateProps({ duration: '520', stagger: true, timeline: true }),
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <div>'
      }
    }
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
    ...animateProps({ duration: '440', stagger: true, timeline: true }),
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <div>'
      }
    }
  ],
  PlAnimateScramble: [
    {
      name: 'children',
      type: 'string',
      required: true,
      description: {
        ko: '풀려 나오는 줄. 문자열이어야 합니다 — 효과가 글자 단위로 동작하고 <strong> 안에는 글자가 없습니다',
        en: 'The line that resolves. A string, and it has to be: the effect works on characters, and there is no character in a <strong>'
      }
    },
    {
      name: 'characters',
      type: 'string',
      description: {
        ko: '가라앉지 않은 글자를 뽑아 오는 글리프. 주지 않으면 그 줄 자신의 글자입니다 — 기본 알파벳을 가진 스크램블러는 예외 없이 영어 알파벳을 가집니다',
        en: "The glyphs the unsettled characters are drawn from. Left out, it is the line's own characters: every scrambler with a default alphabet ships an English one"
      }
    },
    {
      name: 'duration',
      type: 'number',
      default: '1200',
      shared: true,
      description: {
        ko: '줄이 가라앉는 데 걸리는 시간(ms)',
        en: 'How long the line takes to settle'
      }
    },
    {
      name: 'delay',
      type: 'number',
      default: '0',
      shared: true,
      description: { ko: '시작하기까지 기다리는 시간(ms)', en: 'How long it waits before starting' }
    },
    {
      name: 'tick',
      type: 'number',
      default: '45',
      description: {
        ko: '가라앉지 않은 글자를 얼마나 자주 다시 그릴지(ms). 매 프레임이 아닌 것은 의도입니다 — 초당 예순 번은 깜빡임입니다',
        en: 'How often the unsettled characters are redrawn. Not every frame, on purpose: sixty a second is a flicker'
      }
    },
    {
      name: 'trigger',
      type: "'mount' | 'visible' | 'hover' | 'manual'",
      default: "'visible'",
      description: {
        ko: '무엇이 시작하는지. 화면 밖에서 풀린 줄이 전달한 것은 이미 거기 있던 글입니다',
        en: 'What starts it. A line that resolved off screen delivered text that was simply already there'
      }
    },
    {
      name: 'play · once · threshold · paused',
      type: 'boolean · boolean · number · boolean',
      description: { ko: '다른 트랜지션과 같은 넷', en: 'The same four the other transitions take' }
    },
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<span> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <span>'
      }
    }
  ],

  PlAnimateShake: [
    {
      name: 'replay',
      type: 'unknown',
      description: {
        ko: '이 값이 바뀔 때마다 다시 흔듭니다. 첫 렌더링에서는 절대 재생하지 않습니다 — 거절은 두 번 일어날 수 있고 bool로는 "또"라고 말할 수 없습니다',
        en: 'Plays the shake again whenever this value changes, and never on the first render. A refusal can happen twice, and a boolean cannot say "again"'
      }
    },
    {
      name: 'distance',
      type: 'number | string',
      default: '6',
      description: {
        ko: '시작한 자리 양옆으로 얼마나 움직이는지',
        en: 'How far it travels either side of where it started'
      }
    },
    ...animateProps({
      duration: '400',
      omit: ['mode', 'stagger', 'durationStep', 'reverse', 'timeline', 'range']
    }),
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
    ...animateProps({ duration: '360', stagger: true, timeline: true }),
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <div>'
      }
    }
  ],
  PlAnimateSplit: [
    {
      name: 'children',
      type: 'string',
      required: true,
      description: {
        ko: '줄. 문자열이어야 합니다 — 컴포넌트가 그것을 자르고, <strong> 안에는 자를 것이 없습니다',
        en: 'The line. A string, and it has to be: the component cuts it up, and there is nothing to cut inside a <strong>'
      }
    },
    {
      name: 'by',
      type: "'word' | 'character'",
      default: "'word'",
      description: {
        ko: '무엇으로 자를지. character는 모든 문자 체계에서 안전하지 않습니다 — 아랍 문자가 이어지지 않고 이모지가 조각납니다',
        en: 'What it is cut into. character is not safe in every script: Arabic stops joining and an emoji is cut into its pieces'
      }
    },
    {
      name: 'effect',
      type: "'fade' | 'grow' | 'slide' | 'zoom' | 'rotate' | 'blink' | 'reveal'",
      default: "'fade'",
      description: {
        ko: '각 조각이 재생하는 등장',
        en: 'Which of the entrances each part plays'
      }
    },
    ...animateProps({ duration: '400', stagger: true, timeline: true }),
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<span> 대신 다른 요소로 렌더링합니다 (<h2 />)',
        en: 'Renders something other than a <span> (<h2 />)'
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
    ...animateProps({ duration: '320', stagger: true, timeline: true }),
    {
      name: 'render',
      type: 'ReactElement | (props, state) => ReactElement',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than a <div>'
      }
    }
  ],
  PlAppLogo: [
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '마크. 제품의 아트워크가 실제로 무엇이든',
        en: "The mark — whatever the product's artwork actually is"
      }
    },
    {
      name: 'src',
      type: 'string',
      description: {
        ko: 'children 대신 <img>로 그릴 그림',
        en: 'A picture to draw as the mark, instead of children'
      }
    },
    {
      name: 'alt',
      type: 'string',
      default: "''",
      description: {
        ko: '그림이 말하는 것. name이 있으면 비워 두십시오 — 옆의 워드마크가 이미 말합니다',
        en: 'What the picture says. Leave it empty when name is set: the wordmark already says it'
      }
    },
    {
      name: 'name · description',
      type: 'ReactNode',
      description: {
        ko: '마크 옆의 제품 이름과, 그 아래 한 줄(환경 · 테넌트 · 요금제)',
        en: "The product's name beside the mark, and a line under it — an environment, a tenant, a plan"
      }
    },
    {
      name: 'shape',
      type: "'bare' | 'plate' | 'circle'",
      default: "'bare'",
      description: {
        ko: '아트워크를 어떻게 두를지. bare가 기본인 이유는 대부분의 마크가 이미 자기 틀을 가지고 있기 때문입니다',
        en: 'How the artwork is framed. bare is the default because most marks already have a frame of their own'
      }
    },
    {
      name: 'variant',
      type: VARIANT,
      default: "'solid'",
      shared: true,
      description: {
        ko: '판이 무엇으로 만들어지는지. shape가 bare가 아닐 때만 읽습니다',
        en: 'What the plate is made of. Only read when shape is not bare'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '마크의 높이와 옆 이름의 타입 스케일',
        en: 'The height of the mark, and the type scale of the name beside it'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: { ko: '판이 쓰는 색 역할', en: 'The family the plate takes' }
    },
    {
      name: 'render',
      type: 'RenderProp',
      description: {
        ko: '<span> 대신 다른 요소로. 로고는 거의 언제나 첫 페이지로 가는 길입니다 (<a href="/" />)',
        en: 'Renders something other than a <span>. A logo is nearly always the way home (<a href="/" />)'
      }
    }
  ],

  PlAnchor: [
    {
      name: 'items',
      type: 'readonly PlAnchorItem[]',
      required: true,
      description: {
        ko: '제목들. 문서에 나오는 순서대로, 평평한 배열입니다',
        en: 'The headings, in the order they appear in the document, as a flat array'
      }
    },
    {
      name: 'active',
      type: 'string',
      description: {
        ko: '불이 켜질 줄의 href. 주면 추적을 대신합니다',
        en: 'The href of the row that is lit, taking the tracking over'
      }
    },
    {
      name: 'offset',
      type: 'number',
      default: '0',
      description: {
        ko: '읽는 선이 창 위에서 얼마나 내려와 있는지(px). 페이지 위에 고정된 것의 높이입니다',
        en: 'How far below the top of the window the reading line sits, in pixels — the height of whatever is pinned over the page'
      }
    },
    {
      name: 'onSelect',
      type: '(item, event) => void',
      description: {
        ko: '브라우저가 움직이기 전에 눌린 항목을 알립니다',
        en: 'Called with the item that was clicked, before the browser moves'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '목록 자신의 제목. 위에 그려집니다',
        en: 'A heading for the list itself, drawn above it'
      }
    },
    {
      name: 'navLabel',
      type: 'string',
      default: "'On this page'",
      description: {
        ko: '내비게이션 영역의 접근성 이름. 그려지지 않습니다',
        en: 'Accessible name of the navigation region. Never drawn'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'sm'",
      shared: true,
      description: { ko: '줄의 타입 스케일', en: 'The type scale of the rows' }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: { ko: '켜진 줄이 쓰는 색 역할', en: 'The family the lit row takes' }
    }
  ],

  PlAnchorItem: [
    {
      name: 'href',
      type: 'string',
      required: true,
      description: {
        ko: '가리키는 fragment. 거기 적힌 id가 목록이 재는 대상입니다',
        en: 'The fragment it points at. The id it names is what the list measures'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      required: true,
      description: { ko: '줄에 적히는 것', en: 'What the row says' }
    },
    {
      name: 'depth',
      type: 'number',
      default: '0',
      description: {
        ko: '제목이 얼마나 깊은지. 들여쓰기만 이 값을 씁니다',
        en: 'How deep the heading sits. Only the indent depends on it'
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
    },
    fieldClassNames
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

  PlColorPicker: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '트리거의 재질. 폼 안의 다른 필드와 같은 껍데기입니다',
        en: 'What the trigger is made of. The same shell every other field in a form wears'
      },
      sizeDescription: {
        ko: '트리거의 높이, 패널의 너비, 사각형과 레일의 크기',
        en: "The trigger's height, the panel's width, and the size of the square and the rails"
      }
    }),
    {
      name: 'value',
      type: 'string',
      description: {
        ko: '색, CSS 문자열로. 직접 몰고 싶으면 넘기세요',
        en: 'The colour, as a CSS string. Pass it to drive the picker yourself'
      }
    },
    {
      name: 'defaultValue',
      type: 'string',
      default: "'#1a58d1'",
      description: {
        ko: 'uncontrolled 피커가 시작하는 색',
        en: 'Where an uncontrolled picker starts'
      }
    },
    {
      name: 'onValueChange',
      type: '(value: string) => void',
      description: {
        ko: '새 색과 함께, format대로 쓰여서',
        en: 'Called with the new colour, written in format'
      }
    },
    {
      name: 'format',
      type: "'hex' | 'rgb' | 'hsl'",
      default: "'hex'",
      description: {
        ko: '나가는 값이 쓰이는 표기법',
        en: 'Which notation the value is written in on the way out'
      }
    },
    {
      name: 'alpha',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '불투명도 레일을 내주고, 값이 네 번째 채널을 갖게 합니다',
        en: 'Offers an opacity rail, and lets the value carry a fourth channel'
      }
    },
    {
      name: 'swatches',
      type: 'readonly string[] | false',
      description: {
        ko: '패널 아래의 기성 색들. false면 그리지 않고, 배열이면 기본 세트를 대체합니다',
        en: 'The ready-made colours under the panel. false draws none; an array replaces the built-in set'
      }
    },
    {
      name: 'inline',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '팝업 대신 페이지에 패널을 그립니다. 트리거는 없습니다',
        en: 'Draws the panel in the page instead of in a popup, with no trigger'
      }
    },
    {
      name: 'editable',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '값을 타이핑할 수 있는 패널 아래의 필드',
        en: 'The field under the panel that the value can be typed into'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: { ko: '컨트롤 위의 라벨', en: 'Label above the control' }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '아래의 도움말', en: 'Helper text below it' }
    },
    {
      name: 'error',
      type: 'ReactNode',
      description: {
        ko: '아래의 오류 메시지. 있으면 컨트롤이 invalid가 됩니다',
        en: 'Error message below. Its presence also turns the control invalid'
      }
    },
    {
      name: 'invalid',
      type: 'boolean',
      description: { ko: '메시지 없이 같은 상태로', en: 'The same state, without a message' }
    },
    {
      name: 'required',
      type: 'boolean',
      default: 'false',
      description: { ko: '라벨에 필수 표시를 붙입니다', en: 'Marks the label as required' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '쓸 수 없고 tab 순서에서 빠집니다',
        en: 'Unusable and out of the tab order'
      }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '색을 보여 주고 바꾸지 못하게 합니다',
        en: 'Shows the colour and forbids changing it'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '트리거를 컨테이너까지 늘립니다',
        en: 'Stretches the trigger to its container'
      }
    },
    {
      name: 'clearable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '컨트롤을 비우는 ×를 내줍니다',
        en: 'Offers the × that empties the control'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '이 이름으로 폼과 함께 제출됩니다',
        en: 'Submits with a form under this name'
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: { ko: '팝업이 열려 있는지', en: 'Whether the popup is open' }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'uncontrolled 팝업이 시작하는 상태',
        en: 'Where an uncontrolled popup starts'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '팝업이 열리거나 닫힐 때', en: 'Called when the popup opens or closes' }
    },
    {
      name: 'labels',
      type: 'Partial<PlColorPickerLabels>',
      description: {
        ko: '글자가 없는 부분들의 접근 가능한 이름을 하나씩 덮어씁니다',
        en: 'Overrides for the accessible names of the parts that have no text on them'
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
    },
    hotKeysProp,
    fieldClassNames
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

  PlCommandPalette: [
    {
      name: 'items',
      type: 'readonly PlCommandItem[]',
      required: true,
      description: { ko: '팔레트가 할 수 있는 모든 것', en: 'Everything the palette can do' }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '팔레트가 열려 있는지. onOpenChange와 함께 controlled로 씁니다',
        en: 'Whether the palette is open. Use with onOpenChange for a controlled one'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '열린 채로 시작할지',
        en: 'Whether it starts open, for an uncontrolled one'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫힐 때', en: 'Called when it opens or closes' }
    },
    {
      name: 'onSelect',
      type: '(item: PlCommandItem) => void',
      description: {
        ko: '명령이 실행됐을 때, 그 명령 자신의 onSelect 다음에. 어느 쪽이든 팔레트는 닫힙니다',
        en: 'Called when a command is run, after its own onSelect. The palette closes either way'
      }
    },
    {
      name: 'shortcut',
      type: 'string | false',
      default: "'Mod+K'",
      description: {
        ko: '팔레트를 여는 키. window에 바인딩됩니다. PlHotKeys와 같은 표기라 Mod는 Mac에서 Command, 그 외에서 Control입니다. false면 아무것도 바인딩하지 않습니다',
        en: 'The keystroke that opens the palette, bound on the window. Written the way PlHotKeys writes them, so Mod is Command on a Mac and Control everywhere else. false binds nothing'
      }
    },
    {
      name: 'width',
      type: 'number | string',
      description: {
        ko: '시트가 넓어질 수 있는 한계. 픽셀 수 또는 CSS 길이',
        en: 'How wide the sheet may get. A number of pixels or any CSS length'
      }
    },
    {
      name: 'maxHeight',
      type: 'number | string',
      default: '320',
      description: {
        ko: '목록이 스크롤되기 전까지 높아질 수 있는 한계',
        en: 'How tall the list may get before it scrolls'
      }
    },
    {
      name: 'placeholder',
      type: 'string',
      default: "'Search commands'",
      description: { ko: '필드의 placeholder', en: 'The placeholder in the field' }
    },
    {
      name: 'emptyMessage',
      type: 'ReactNode',
      default: "'No commands found'",
      description: {
        ko: '아무것도 맞지 않았을 때 행이 있었을 자리에 오는 줄',
        en: 'The line where the rows would be, when nothing matched'
      }
    },
    {
      name: 'label',
      type: 'string',
      default: "'Command palette'",
      description: {
        ko: '보이는 제목이 없는 이 dialog의 접근 가능한 이름',
        en: 'The accessible name of the dialog, which has no visible title'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '시트의 너비, 필드의 높이, 행의 타입 스케일',
        en: "The sheet's width, the field's height and the rows' type scale"
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. 하이라이트, caret, focus ring까지 갑니다 — 시트에는 색이 들어가지 않습니다',
        en: 'Semantic colour role. It reaches the highlight, the caret and the focus rings; the sheet is never dyed'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '행의 높이만 바꿉니다', en: 'The height of a row, and nothing else' }
    },
    ...stylingProps({ ko: '시트', en: 'the sheet' }),
    portalClassNames
  ],

  PlCommandItem: [
    {
      name: 'value',
      type: 'string',
      required: true,
      description: { ko: '이 명령을 식별하는 것', en: 'What identifies the command' }
    },
    {
      name: 'label',
      type: 'string',
      required: true,
      description: {
        ko: '행이 말하는 내용이자, 질의가 맞춰지는 대상',
        en: 'What the row says, and what the query is matched against'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '그 아래 한 줄 — 명령이 어디로 가는지, 무엇을 바꾸는지',
        en: 'A second line under it — where the command goes, or what it changes'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: { ko: '라벨 앞의 글리프', en: 'A glyph before the label' }
    },
    {
      name: 'shortcut',
      type: 'string',
      description: {
        ko: '같은 일을 하는 키. 행 끝에 놓입니다. 팔레트는 그것을 바인딩하지 않습니다 — 애플리케이션이 합니다',
        en: 'The keystroke that does the same thing, set at the end of the row. The palette does not bind it — the application does'
      }
    },
    {
      name: 'group',
      type: 'string',
      description: {
        ko: '이 명령이 속한 제목. 명령은 주어진 순서대로 그려지고 제목은 그룹이 바뀔 때마다 그려지므로, 한 그룹의 명령은 붙여서 나열해야 합니다',
        en: "The heading this command sits under. Commands are drawn in the order they are given and a heading is drawn each time the group changes, so a group's commands have to be listed together"
      }
    },
    {
      name: 'keywords',
      type: 'readonly string[]',
      description: {
        ko: '질의에는 맞춰지지만 그려지지는 않는 말들 — 다른 제품이 같은 명령에 붙인 이름, 약어, 사람들이 검색했을 단어',
        en: "Extra words the query is matched against but that are never drawn — the name somebody else's product gives the same command, an abbreviation, the word a reader would have searched for"
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '목록에는 있지만 실행할 수 없습니다', en: 'In the list but not runnable' }
    },
    {
      name: 'onSelect',
      type: '() => void',
      description: { ko: '실행하면 무엇을 하는지', en: 'What running it does' }
    }
  ],

  PlContainer: [
    {
      name: 'maxWidth',
      type: `PlassResponsive<${SIZE} | 'none' | number | string>`,
      default: "'none'",
      description: {
        ko: '내용이 넓어질 수 있는 한계. 다섯 칸은 브레이크포인트와 같은 사다리(xs 30rem · sm 40rem · md 48rem · lg 64rem · xl 80rem)이고, 그 외에는 길이로 읽습니다 — 숫자는 픽셀, 문자열은 아무 CSS 길이나. 반응형이며 CSS에서 풀립니다',
        en: 'How wide the content is allowed to get. The five rungs are the breakpoint widths (xs 30rem, sm 40rem, md 48rem, lg 64rem, xl 80rem); anything else is read as a length — a number is pixels, a string is any CSS length. Responsive, and resolved in CSS'
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

  PlDataList: [
    {
      name: 'orientation',
      type: "'horizontal' | 'vertical'",
      default: "'horizontal'",
      description: {
        ko: '라벨이 값 옆에 오는지 위에 오는지',
        en: 'Whether the label sits beside the value or above it'
      }
    },
    {
      name: 'labelWidth',
      type: 'number | string',
      default: "'10rem'",
      description: {
        ko: '라벨 열의 너비. 가장 긴 라벨이 아니라 고정 너비라, 한 화면의 두 패널이 서로 맞습니다',
        en: 'How wide the label column is. A fixed width rather than the longest label, so two panels on one screen line up'
      }
    },
    {
      name: 'divider',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '줄과 줄 사이에만 실선을 긋습니다',
        en: 'Draws a hairline between the rows, and only between them'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '라벨과 값의 타입 스케일',
        en: 'The type scale of the labels and the values'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '줄 사이의 간격', en: 'The space between the rows' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'PlDataListItem들', en: 'The PlDataListItems' }
    }
  ],

  PlDataListItem: [
    {
      name: 'label',
      type: 'ReactNode',
      description: { ko: '값이 무엇의 값인지', en: 'What the value is of' }
    },
    {
      name: 'value',
      type: 'ReactNode',
      description: {
        ko: '값. 마크업이 들어가는 값은 children으로 주십시오',
        en: 'The value. Use children for a value with markup in it'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: { ko: '라벨 앞의 글리프', en: 'A glyph before the label' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '문자열이 아닐 때의 값', en: 'The value, when it is more than a string' }
    }
  ],

  PlDataTable: [
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
      type: 'readonly PlDataTableColumn<Row>[]',
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
      description: {
        ko: '행 데이터. 도착한 순서 그대로',
        en: 'The rows, in the order they arrived in'
      }
    },
    {
      name: 'getRowKey',
      type: '(row: Row, index: number) => Key',
      description: {
        ko: '행마다의 안정적인 key. 다른 무엇보다 먼저 정할 값입니다 — 기본값인 index는 정렬이 행을 옮기면 뒤에 남습니다',
        en: 'A stable key per row, and the one prop worth setting before any other: the index it defaults to stays behind when a sort moves the row'
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
      default: 'labels.empty',
      description: {
        ko: '남은 행이 없을 때 대신 보여 줄 내용',
        en: 'What to show instead of rows when there are none left to show'
      }
    },
    {
      name: 'striped',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '한 행 걸러 하나씩 옅게 칠합니다',
        en: 'Tints every other row'
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
      default: 'true',
      description: {
        ko: '행이 밑으로 지나가는 동안 열 이름을 고정합니다. 정렬하는 표는 읽는 사람이 스크롤하는 표입니다',
        en: 'Pins the column names while the rows scroll under them. A table that sorts is a table a reader scrolls'
      }
    },
    {
      name: 'maxHeight',
      type: 'number | string',
      description: {
        ko: '격자 높이의 상한. 넘으면 시트 안에서 행이 스크롤됩니다',
        en: 'A hard cap on the grid. Past it the rows scroll inside the sheet'
      }
    },
    {
      name: 'onRowClick',
      type: '(row: Row, index: number) => void',
      description: {
        ko: '행을 활성화할 수 있게 만듭니다. hover 처리도 함께 켜집니다',
        en: 'Makes rows activatable. Also turns on the hover treatment'
      }
    },
    {
      name: 'sort',
      type: 'PlDataTableSort | null',
      description: {
        ko: '정렬된 열과 방향. 넘기면 정렬을 직접 제어합니다',
        en: 'The sorted column and its direction. Pass it to control the sort'
      }
    },
    {
      name: 'defaultSort',
      type: 'PlDataTableSort | null',
      default: 'null',
      description: {
        ko: '표가 정렬을 스스로 들고 있을 때의 출발점',
        en: 'Where the sort starts when the table keeps it itself'
      }
    },
    {
      name: 'onSortChange',
      type: '(sort: PlDataTableSort | null) => void',
      description: {
        ko: '제목을 누를 때마다 다음 정렬로 불립니다. 세 번째 누름은 null',
        en: 'Called with the sort a heading press asks for, null for the third press'
      }
    },
    {
      name: 'searchable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '격자 위에 입력한 것으로 행을 좁히는 필드를 그립니다',
        en: 'Draws a field above the grid that narrows the rows to what was typed'
      }
    },
    {
      name: 'search',
      type: 'string',
      description: {
        ko: '검색어. 넘기면 필드를 직접 제어합니다',
        en: 'The query. Pass it to control the field'
      }
    },
    {
      name: 'defaultSearch',
      type: 'string',
      default: "''",
      description: {
        ko: '표가 검색어를 스스로 들고 있을 때의 출발점',
        en: 'Where the query starts when the table keeps it itself'
      }
    },
    {
      name: 'onSearchChange',
      type: '(search: string) => void',
      description: {
        ko: '읽는 사람이 입력한 문자열로 불립니다',
        en: 'Called with what the reader typed'
      }
    },
    {
      name: 'searchPlaceholder',
      type: 'string',
      default: 'labels.search',
      description: { ko: '검색 필드의 placeholder', en: "The field's placeholder" }
    },
    {
      name: 'selection',
      type: "'none' | 'single' | 'multiple'",
      default: "'none'",
      description: {
        ko: '한 번에 고를 수 있는 행의 수',
        en: 'How many rows may be ticked at once'
      }
    },
    {
      name: 'selected',
      type: 'readonly Key[]',
      description: {
        ko: '체크된 행의 key. 넘기면 선택을 직접 제어합니다',
        en: 'The ticked rows, as their keys. Pass it to control the selection'
      }
    },
    {
      name: 'defaultSelected',
      type: 'readonly Key[]',
      default: '[]',
      description: {
        ko: '표가 선택을 스스로 들고 있을 때의 출발점',
        en: 'Where the selection starts when the table keeps it itself'
      }
    },
    {
      name: 'onSelectedChange',
      type: '(selected: Key[], rows: Row[]) => void',
      description: {
        ko: '체크된 모든 행의 key와 행 자체로 불립니다',
        en: 'Called with the keys of every ticked row, and with the rows themselves'
      }
    },
    {
      name: 'isRowSelectable',
      type: '(row: Row, index: number) => boolean',
      description: {
        ko: '선택에서 제외할 행을 정합니다 — 합계 줄, 이미 처리된 행',
        en: 'Keeps a row out of the selection — a total line, a row already spent'
      }
    },
    {
      name: 'paging',
      type: "'scroll' | 'pages'",
      default: "'scroll'",
      description: { ko: '행을 나눠 주는 방식', en: 'How the rows are handed out' }
    },
    {
      name: 'pageSize',
      type: 'number',
      default: '10',
      description: { ko: '한 페이지에 들어가는 행의 수', en: 'How many rows a page holds' }
    },
    {
      name: 'page',
      type: 'number',
      description: {
        ko: '읽고 있는 페이지, 1부터. 넘기면 페이저를 직접 제어합니다',
        en: 'The page being read, counted from 1. Pass it to control the pager'
      }
    },
    {
      name: 'defaultPage',
      type: 'number',
      default: '1',
      description: {
        ko: '표가 페이지를 스스로 들고 있을 때의 출발점',
        en: 'Where the pager starts when the table keeps it itself'
      }
    },
    {
      name: 'onPageChange',
      type: '(page: number) => void',
      description: {
        ko: '페이저를 누를 때마다 그 페이지로 불립니다',
        en: 'Called with the page a pager press asks for'
      }
    },
    {
      name: 'rowCount',
      type: 'number',
      description: {
        ko: '표가 한 페이지만 건네받을 때의 전체 행 수. manual 페이징에 필요하고, 그 밖에서는 무시됩니다',
        en: 'How many rows there are in total when the table is only handed one page. Required for manual paging and ignored without it'
      }
    },
    {
      name: 'manual',
      type: "readonly ('sort' | 'search' | 'pages')[]",
      description: {
        ko: '애플리케이션이 rows에 이미 적용해 둔 단계',
        en: 'The stages an application has already done to rows itself'
      }
    },
    {
      name: 'loading',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '행 대신 막대를 그리고 격자를 aria-busy로 표시합니다',
        en: 'Draws bars in place of the rows and marks the grid busy'
      }
    },
    {
      name: 'toolbar',
      type: 'ReactNode',
      description: {
        ko: '툴바 끝에 그려집니다 — 필터, 버튼, 자기만의 개수',
        en: 'Drawn in the toolbar, at the end. A filter, a button, a count of its own'
      }
    },
    {
      name: 'footer',
      type: 'ReactNode',
      description: {
        ko: '푸터 앞쪽에, 행 개수 대신 그려집니다',
        en: 'Drawn in the footer, at the start, in place of the row count'
      }
    }
  ],

  PlDataTableColumn: [
    {
      name: 'key',
      type: 'string',
      required: true,
      description: {
        ko: '열을 식별하고, value나 render가 없으면 각 행에서 읽을 속성 이름이 됩니다',
        en: 'Identifies the column, and — unless value or render says otherwise — names the property to read off each row'
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
        ko: '기본 너비. 숫자는 px, 문자열은 CSS 길이',
        en: 'The default width. A number is pixels, a string is any CSS length'
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
    },
    {
      name: 'value',
      type: '(row: Row) => unknown',
      description: {
        ko: '정렬과 검색이 보는 값. 기본값은 row[key]이고, 셀을 그리는 열이라면 필요합니다',
        en: 'What the sort and the search see. Defaults to row[key], and is needed whenever the cell is drawn rather than printed'
      }
    },
    {
      name: 'sortable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '제목을 정렬 순환에 넣습니다: 오름차순, 내림차순, 그리고 원래 순서',
        en: 'Puts the heading in the sort rotation: ascending, descending, then back to the order the rows arrived in'
      }
    },
    {
      name: 'compare',
      type: '(a: Row, b: Row) => number',
      description: {
        ko: '두 행의 순서를 직접 정합니다. 방향은 여기에 답한 결과에 적용됩니다',
        en: 'Orders two rows against each other. The direction is applied to whatever it says'
      }
    },
    {
      name: 'unsearchable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '이 열을 검색에서 제외합니다',
        en: 'Keeps this column out of the search'
      }
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
    {
      name: 'precision',
      type: "'day' | 'month' | 'year'",
      default: "'day'",
      description: {
        ko: '어디까지 내려가는지 — 일, 월, 연. 그 단위의 그리드에서 바로 확정되고, month picker에는 일 그리드가 아예 없습니다. 값은 언제나 그 단위의 시작(1일, 1월 1일)입니다',
        en: 'How far down the picker goes: a day, a month or a year. The grid for that unit is the last one, and a month picker has no day grid at all. The value is always the start of what was chosen — the 1st of the month, or the 1st of January'
      }
    },
    ...dateBoundsProps,
    {
      name: 'showTodayButton',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '푸터에 오늘로 가는 지름길을 둡니다. precision에 따라 "이번 달", "올해"가 됩니다',
        en: 'Offers the shortcut to today in the footer — to this month or this year, as precision says'
      }
    },
    ...pickerProps({
      format: "{ dateStyle: 'medium' }",
      formatDescription: {
        ko: 'trigger가 날짜를 쓰는 방식. Intl로 그대로 넘어갑니다. 기본값은 precision을 따릅니다',
        en: 'How the trigger writes the chosen date. Passed straight to Intl; the default follows precision'
      },
      closeOnSelect: 'true',
      closeOnSelectDescription: {
        ko: '날을 고르는 즉시 팝업을 닫습니다',
        en: 'Closes the popup as soon as a day is chosen'
      },
      nameDescription: {
        ko: '폼 제출 시 필드를 식별합니다. YYYY-MM-DD로, UTC가 아니라 로컬로 보냅니다. precision이 짧으면 YYYY-MM, YYYY입니다',
        en: 'Identifies the field when a form is submitted, as a local YYYY-MM-DD — never as UTC. YYYY-MM and YYYY at the two shorter precisions'
      }
    }),
    fieldClassNames
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
    }),
    fieldClassNames
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
    }),
    fieldClassNames
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
    },
    portalClassNames
  ],

  PlFieldset: [
    {
      name: 'legend',
      type: 'ReactNode',
      description: {
        ko: '이 묶음의 이름. 안에 든 모든 컨트롤의 접근 가능한 이름에 들어가므로, 각각 앞에 놓아도 말이 되는 구절이어야 합니다 — "받는 주소"이지 "어디로 보낼까요?"가 아닙니다',
        en: 'What the group is called. It becomes part of the accessible name of every control inside, so it has to read correctly in front of each of them — "Billing address", not "Where should we send it?"'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: 'legend 아래 한 줄', en: 'A line under the legend' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '안의 모든 컨트롤을 한 번에 끕니다. <fieldset>이 늘 해 온 그대로입니다',
        en: 'Disables every control inside at once, the way a <fieldset> always has'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: 'legend의 타입 스케일과 컨트롤 사이의 간격',
        en: 'The type scale of the legend and the gap between the controls'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '한 질문에 함께 답하는 컨트롤들',
        en: 'The controls that answer one question together'
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

  PlFlex: [
    {
      name: 'direction',
      type: "PlassResponsive<'horizontal' | 'vertical'>",
      default: "'horizontal'",
      description: {
        ko: '자식이 어느 쪽으로 흐를지. CSS에서 풀리므로 서버가 보내는 첫 페인트가 이미 맞습니다',
        en: 'Which way the children run. Resolved in CSS, so a server render is already right at every width'
      }
    },
    {
      name: 'reverse',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '축의 반대 방향으로 놓습니다. 그리는 순서만 바뀌고 DOM 순서는 그대로입니다',
        en: 'Runs the children the other way along the axis. A painting order only — the DOM order does not move'
      }
    },
    {
      name: 'spacing',
      type: 'PlassResponsive<number>',
      default: '2',
      description: {
        ko: '자식 사이 간격. Tailwind spacing 스케일이라 4는 1rem이고, 분수도 됩니다',
        en: "The gap between children, on Tailwind's spacing scale — 4 is 1rem, and fractions are allowed"
      }
    },
    {
      name: 'rowSpacing · columnSpacing',
      type: 'PlassResponsive<number>',
      description: {
        ko: '한 축만의 간격. 주지 않으면 spacing으로 떨어집니다',
        en: 'The gap on one axis only. Falls back to spacing'
      }
    },
    {
      name: 'justify',
      type: "'start' | 'center' | 'end' | 'space-between' | 'space-around' | 'space-evenly' | 'stretch'",
      description: {
        ko: '자식이 쓰지 않은 자리를 축을 따라 어떻게 나눠 가질지',
        en: 'How the box distributes the space its children did not use, along the axis'
      }
    },
    {
      name: 'alignItems',
      type: "'start' | 'center' | 'end' | 'stretch' | 'baseline'",
      default: "'stretch'",
      description: {
        ko: '축을 가로질러 자식들이 서로에 대해 어떻게 놓일지',
        en: 'How the children sit against each other across the axis'
      }
    },
    {
      name: 'alignContent',
      type: "'start' | 'center' | 'end' | 'space-between' | 'space-around' | 'space-evenly' | 'stretch'",
      description: {
        ko: '상자가 내용보다 넓을 때 줄들이 어디에 놓일지',
        en: 'Where the lines sit when the box is longer across than its content'
      }
    },
    {
      name: 'wrap',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '자리가 모자란 자식이 다음 줄로 이어질지',
        en: 'Whether children that run out of room continue on the next line'
      }
    },
    {
      name: 'inline',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '글줄 안에 놓고 자식만큼만 넓게 만듭니다',
        en: 'Lays the box out inline, only as wide as its children'
      }
    },
    {
      name: 'render',
      type: 'RenderProp',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다 (<ul />, <nav />)',
        en: 'Renders something other than a <div> (<ul />, <nav />)'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '배치할 내용', en: 'What is laid out' }
    }
  ],

  PlFloatingActionButton: [
    {
      name: 'icon',
      type: 'ReactNode',
      required: true,
      description: { ko: '글리프', en: 'The glyph' }
    },
    {
      name: 'label',
      type: 'string',
      required: true,
      description: {
        ko: '버튼이 하는 일. 글자가 그려지든 아니든 언제나 접근성 이름입니다',
        en: 'What the button does. The accessible name whether or not the words are drawn'
      }
    },
    {
      name: 'extended',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '글리프 옆에 라벨을 그립니다',
        en: 'Draws the label beside the glyph'
      }
    },
    {
      name: 'corner',
      type: "'top-start' | 'top-end' | 'bottom-start' | 'bottom-end'",
      default: "'bottom-end'",
      description: {
        ko: '창의 어느 모서리에 놓일지. left/right가 아니라 start/end입니다',
        en: 'Which corner of the window it sits in. start/end rather than left/right'
      }
    },
    {
      name: 'offset',
      type: 'number | string',
      default: "'1.5rem'",
      description: {
        ko: '맞닿은 두 모서리에서 떨어져 서는 거리',
        en: 'How far it stands off the two edges it is against'
      }
    },
    {
      name: 'floating',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '창에 스스로를 고정할지. 끄면 모양과 그림자는 남고 위치 지정만 빠집니다',
        en: 'Whether it pins itself to the window. Off keeps the shape and the shadow and drops the positioning'
      }
    },
    {
      name: 'variant',
      type: VARIANT,
      default: "'solid'",
      shared: true,
      description: { ko: '키가 무엇으로 만들어지는지', en: 'What the key is made of' }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'lg'",
      shared: true,
      description: {
        ko: 'PlButton보다 한 칸 위. 떠 있는 버튼은 엄지가 겨누는 표적입니다',
        en: "One step up from a PlButton's. A floating button is a target for a thumb"
      }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      default: '3',
      shared: true,
      description: {
        ko: '사다리 꼭대기. 내용 위에 얹힌 것이 아니라 정말로 떠 있는 유일한 컨트롤입니다',
        en: 'The top of the ladder. This is the one control that genuinely floats over the content rather than resting on it'
      }
    }
  ],

  PlFooter: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '시트의 재질. 바에는 색이 들어가지 않습니다 — 위에 얹힌 것들이 자기 색을 갖고 옵니다',
        en: 'What the sheet is made of. The bar is never dyed — what is on it arrives with colours of its own'
      },
      sizeDescription: {
        ko: 'gutter와 내용 위아래의 공기. PlBox처럼 여기서 size는 시트의 크기입니다',
        en: 'The gutter and the air above and below the content. As on PlBox, size here is the size of the sheet'
      }
    }),
    {
      name: 'position',
      type: "'static' | 'sticky' | 'fixed'",
      default: "'static'",
      shared: true,
      description: {
        ko: '바가 페이지 스크롤 안에서 어떻게 앉는지. static이 기본이고 PlHeader와 정반대입니다 — 푸터는 스크롤해서 닿는 문서의 끝입니다',
        en: "How the bar sits in the page's scroll. static is the default and the opposite of PlHeader's: a footer is the end of the document, reached by scrolling to it"
      }
    },
    {
      name: 'divider',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '위 가장자리에 헤어라인을 그립니다. 기본으로 켜져 있습니다 — 푸터는 바로 위에 내용이 있고 아래에는 아무것도 없는 유일한 시트라, 문서가 끝났다고 말하는 것이 그 선입니다',
        en: 'Draws a hairline along the top edge. On by default: a footer is the one sheet with content directly above it and nothing below, so the line is what says the document ended'
      }
    },
    {
      name: 'maxWidth',
      type: `PlassResponsive<${SIZE} | 'none' | number | string>`,
      default: "'none'",
      description: {
        ko: '시트는 창을 가로지른 채로, 내용만 measure에 맞춰 가운데 둡니다. PlContainer의 maxWidth와 같은 사다리입니다',
        en: "Holds the content to a measure and centres it while the sheet still spans the window. The same ladder PlContainer's maxWidth uses"
      }
    },
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: { ko: 'gutter와 위아래의 공기', en: 'The gutter and the air above and below' }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '바가 불리는 이름. 페이지에 <footer>가 둘 이상일 때 써 둘 값어치가 있습니다',
        en: 'The name the bar is announced by. Worth writing when a page has more than one <footer> in it'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: '<footer> 대신 다른 요소로 렌더링합니다. 대개 원하는 것이 아닙니다 — 문서 최상위의 그 태그는 contentinfo landmark입니다',
        en: 'Renders something other than a <footer>. Rarely what you want: at the top level of a document that tag is the contentinfo landmark'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '안에 든 전부. 푸터의 내용은 링크 열, 저작권 줄, 로고 — 전부 호출하는 쪽의 것이라 슬롯이 하나도 없습니다',
        en: "Everything in it. A footer's content is columns of links, a copyright line, a logo — all of it the caller's, which is why there are no slots"
      }
    }
  ],

  PlForm: [
    {
      name: 'validationMode',
      type: "'onSubmit' | 'onBlur' | 'onChange'",
      default: "'onSubmit'",
      description: {
        ko: '필드가 언제 유효성을 판단하는지. onSubmit은 제출할 때, 그리고 그 뒤로는 바뀔 때마다입니다',
        en: 'When a field validates. onSubmit is on submit, and on every change afterwards'
      }
    },
    {
      name: 'errors',
      type: 'Record<string, string | string[]>',
      description: {
        ko: '브라우저 자신의 검증 바깥에서 온 오류 — 서버, form action, 스키마 — 를 필드의 name으로 묶은 것. 해당 필드에 표시되고, 그 필드가 바뀌면 지워집니다',
        en: "Errors from outside the browser's own validation — a server, a form action, a schema — keyed by the name of the field each belongs to. Shown on that field, and cleared as soon as it changes"
      }
    },
    {
      name: 'onSubmit',
      type: '(values: Record<string, unknown>) => void',
      description: {
        ko: '유효한 제출에서 폼의 값과 함께 호출됩니다. 네이티브 submit은 막히므로 아무 데도 이동하지 않습니다',
        en: "Called on a valid submit, with the form's values. The native submit event is prevented, so nothing navigates"
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '자식들 사이의 간격. 폼은 스택이고, 이건 어느 칸에 쌓을지입니다',
        en: "The gap between the form's children. A form is a stack, and this is which rung it stacks on"
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '필드들과 제출 버튼', en: 'The fields, and the button that submits them' }
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

  PlHeader: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '시트의 재질. 바에는 색이 들어가지 않습니다 — 위에 얹힌 것들이 자기 색을 갖고 옵니다',
        en: 'What the sheet is made of. The bar is never dyed — what is on it arrives with colours of its own'
      },
      sizeDescription: {
        ko: '바의 높이 하한, gutter, 슬롯 사이의 공기. PlBox처럼 여기서 size는 시트의 크기입니다',
        en: "The bar's height floor, its gutter and the air around its slots. As on PlBox, size here is the size of the sheet"
      },
      elevationDescription: {
        ko: '그림자 깊이. 0이 기본이고 평평합니다 — 헤더는 창 위쪽에 붙어 있지 떠 있지 않습니다',
        en: 'Drop shadow depth. 0 is the default and it is flat: a header is attached to the top of the window rather than floating over it'
      }
    }),
    {
      name: 'brand',
      type: 'ReactNode',
      description: {
        ko: '앞쪽 슬롯 — 로고, 제품 이름, 모든 페이지에서 같은 것',
        en: "The leading slot: the logo, the product's name, the thing that is the same on every page"
      }
    },
    {
      name: 'actions',
      type: 'ReactNode',
      description: {
        ko: '뒤쪽 슬롯 — 계정 메뉴, 테마 스위치, 콜 투 액션. 끝 정렬로 배치되므로 버튼 여러 개에 wrapper가 필요 없습니다',
        en: 'The trailing slot: the account menu, the theme switch, the call to action. End-aligned, so a row of buttons needs no wrapper'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'start'",
      shared: true,
      description: {
        ko: '가운데 슬롯이 어디에 앉는지. center는 남은 공간이 아니라 바 자신의 중심선에 맞춥니다',
        en: "Where the middle slot sits. center is on the bar's own midline, not in the space left over"
      }
    },
    {
      name: 'position',
      type: "'static' | 'sticky' | 'fixed'",
      default: "'sticky'",
      shared: true,
      description: {
        ko: '바가 페이지 스크롤 안에서 어떻게 앉는지. CSS가 쓰는 그대로입니다',
        en: "How the bar sits in the page's scroll, spelled the way CSS spells it"
      }
    },
    {
      name: 'divider',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '아래 가장자리에 헤어라인을 그립니다. 스크롤되는 페이지 위에 고정된 바는 아래로 늘 내용이 지나가므로 기본으로 켜져 있습니다',
        en: 'Draws a hairline along the bottom edge. On by default: a pinned bar has content passing underneath it at every moment'
      }
    },
    {
      name: 'maxWidth',
      type: `PlassResponsive<${SIZE} | 'none' | number | string>`,
      default: "'none'",
      description: {
        ko: '시트는 창을 가로지른 채로, 슬롯의 행만 measure에 맞춰 가운데 둡니다. PlContainer의 maxWidth와 같은 사다리입니다',
        en: "Holds the row of slots to a measure and centres it while the sheet still spans the window. The same ladder PlContainer's maxWidth uses"
      }
    },
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: { ko: '행 양쪽의 gutter', en: 'The gutter down each side of the row' }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '바가 불리는 이름. 페이지에 <header>가 둘 이상일 때 써 둘 값어치가 있습니다',
        en: 'The name the bar is announced by. Worth writing when a page has more than one <header> in it'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: '<header> 대신 다른 요소로 렌더링합니다. 대개 원하는 것이 아닙니다 — 페이지 위쪽의 바는 banner이고, 그걸 말해 주는 것이 태그입니다',
        en: 'Renders something other than a <header>. Rarely what you want: the bar at the top of a page is a banner, and the tag is what says so'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '가운데 슬롯', en: 'The middle slot' }
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

  PlHoverCard: [
    {
      name: 'trigger',
      type: 'ReactElement',
      required: true,
      description: {
        ko: '카드가 미리 보여 주는 대상. 보통 링크이고, 감싸지 않고 그대로 렌더링됩니다',
        en: 'What the card previews. Usually a link, and it is rendered rather than wrapped'
      }
    },
    {
      name: 'title · description',
      type: 'ReactNode',
      description: { ko: '제목과 그 아래 한 줄', en: 'The heading and a line under it' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '본문', en: 'The body' }
    },
    {
      name: 'side',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'bottom'",
      description: {
        ko: '트리거의 어느 모서리에 나타날지. 자리가 없으면 반대쪽으로 뒤집힙니다',
        en: 'Which edge of the trigger it appears on. Flips to the opposite side when there is no room'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      description: { ko: '그 모서리를 따라 어디에 놓일지', en: 'Where it sits along that edge' }
    },
    {
      name: 'sideOffset · alignOffset',
      type: 'number',
      default: '8 · 0',
      description: {
        ko: '트리거에서 떨어진 거리와 모서리를 따라 밀린 거리, 픽셀',
        en: 'Distance from the trigger and shift along that edge, in pixels'
      }
    },
    {
      name: 'delay',
      type: 'number',
      default: '600',
      description: {
        ko: '열리기까지 포인터가 머물러야 하는 시간(ms). 지나가는 길의 모든 링크에서 열리지 않도록 깁니다',
        en: 'How long the pointer has to rest before it opens, in ms. Long, so it does not fire at every link a reader passes'
      }
    },
    {
      name: 'closeDelay',
      type: 'number',
      default: '300',
      description: {
        ko: '포인터가 떠난 뒤 기다리는 시간(ms). 0일 수 없습니다 — 트리거와 카드 사이의 틈에는 포인터가 없습니다',
        en: 'How long it waits after the pointer leaves, in ms. It cannot be zero: the gap between the trigger and the card has no pointer in it'
      }
    },
    {
      name: 'arrow',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '트리거를 가리키는 작은 쐐기를 그립니다',
        en: 'Draws the little wedge pointing at the trigger'
      }
    },
    {
      name: 'open · defaultOpen · onOpenChange',
      type: 'boolean · boolean · (open) => void',
      description: {
        ko: '바깥에서 여닫기. 주지 않으면 포인터와 키보드에 맡깁니다',
        en: 'Drives it from outside. Without them it is left to the pointer and the keyboard'
      }
    },
    {
      name: 'width',
      type: 'number | string',
      description: {
        ko: 'size가 정하는 최대 너비를 덮어씁니다',
        en: "A hard cap on the card's width, overriding the one size implies"
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '시트의 타입 스케일과 radius와 패딩',
        en: 'Type scale, radius and padding of the sheet'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: { ko: '안쪽이 쓰는 색 역할', en: 'The family anything inside takes' }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: '시트가 내용을 얼마나 촘촘히 담을지',
        en: 'How tightly the sheet packs its content'
      }
    }
  ],

  PlHowToSteps: [
    {
      name: 'active',
      type: 'number',
      description: {
        ko: '지금 하고 있는 단계의 인덱스. 선택입니다 — 어디까지 왔는지 안다고 주장하는 안내는 추측을 하는 것입니다',
        en: 'Which step is being worked on now, as an index. Optional: a guide that claimed to know how far a reader had got would be guessing'
      }
    },
    {
      name: 'numbered',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '단계에 번호를 매깁니다. 끄면 순서가 없는 체크리스트가 됩니다',
        en: 'Numbers the steps. Off makes it a checklist, which has no order'
      }
    },
    {
      name: 'connector',
      type: "'solid' | 'dashed' | 'dotted' | 'none'",
      default: "'solid'",
      description: {
        ko: '한 단계와 다음 단계 사이의 선',
        en: 'The line between one step and the next'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '제목과 본문의 타입 스케일',
        en: 'The type scale of the titles and the bodies'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: { ko: '불릿이 쓰는 색 역할', en: 'The family the bullets take' }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: '단계 사이의 간격. 타입 스케일도 불릿도 아닙니다',
        en: 'The space between steps. Never the type scale, never the bullet'
      }
    },
    {
      name: 'render',
      type: 'RenderProp',
      description: {
        ko: '<ol> 대신 다른 요소로 렌더링합니다',
        en: 'Renders something other than an <ol>'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'PlHowToStep들', en: 'The PlHowToSteps' }
    }
  ],

  PlHowToStep: [
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '단계가 무엇인지. 훑을 때 찾는 줄입니다',
        en: 'What the step is. The line the reader scans for'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '무엇을 할지', en: 'What to do' }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: {
        ko: '번호 대신 놓이는 글리프. 순서에서의 자리는 그대로입니다',
        en: 'A glyph in place of the number. The step keeps its place in the order'
      }
    },
    {
      name: 'status',
      type: "'complete' | 'current' | 'upcoming'",
      description: {
        ko: '안내가 active로 계산한 것을 덮어씁니다',
        en: 'Overrides what the guide worked out from active'
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

  PlMenubar: [
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '스트립의 높이와 타입 스케일. 매 단계에서 컨트롤 사다리보다 한 칸 아래입니다',
        en: "The strip's height and type scale — a rung below the control ladder at every step"
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. hover와 열린 메뉴와 focus ring까지 갑니다 — 바는 아무것도 그리지 않습니다',
        en: 'Semantic colour role. It reaches the hover, the open menu and the focus rings; the bar draws nothing'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: '단어의 좌우 여백. 기본값도 compact 트랙을 씁니다 — 스트립은 버튼 행이 아닙니다',
        en: 'The padding beside each word. Even the default uses the compact track: a strip is not a row of buttons'
      }
    },
    {
      name: 'orientation',
      type: "'horizontal' | 'vertical'",
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '바가 늘어서는 방향. 화살표 키가 그것을 따릅니다',
        en: 'Which way the bar runs. The arrow keys follow it'
      }
    },
    {
      name: 'modal',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '열린 메뉴가 페이지를 가져가는지. 켜져 있으면 포인터가 말을 거는 대상은 열린 메뉴입니다',
        en: 'Whether an open menu takes the page away. On, an open menu is what the pointer is talking to'
      }
    },
    {
      name: 'loopFocus',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '화살표 키가 바의 양 끝에서 돌아가는지',
        en: 'Whether the arrow keys wrap around at the ends of the bar'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '바의 모든 메뉴를 한 번에 끕니다',
        en: 'Disables every menu on the bar at once'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '메뉴들', en: 'The menus' }
    }
  ],

  PlMenubarMenu: [
    {
      name: 'label',
      type: 'ReactNode',
      required: true,
      description: { ko: '바에 쓰이는 단어', en: 'The word on the bar' }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '라벨 앞에 놓이는 내용', en: 'Content before the label' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '쓸 수 없습니다. 단어는 바에 남고 아무것도 열지 않습니다',
        en: 'Unavailable. The word stays on the bar and opens nothing'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: 'PlMenu 안에 쓰는 것과 정확히 같은 행들',
        en: 'The rows, written exactly as they are inside a PlMenu'
      }
    },
    ...stylingProps({ ko: '이 메뉴를 여는 단어', en: 'the word this menu is opened by' })
  ],

  PlMeter: [
    {
      name: 'value',
      type: 'number',
      required: true,
      description: {
        ko: '얼마나 있는지. 필수이고, 그것이 PlProgressLinear와의 차이 전부입니다 — meter는 이미 알고 있는 양을 보고하므로 미확정 상태가 없습니다',
        en: 'How much there is. Required, and that is the whole difference from a PlProgressLinear: a meter reports a quantity that is already known, so there is no indeterminate case'
      }
    },
    {
      name: 'min',
      type: 'number',
      default: '0',
      description: { ko: '범위의 아래', en: 'The bottom of the range' }
    },
    {
      name: 'max',
      type: 'number',
      default: '100',
      description: { ko: '범위의 위', en: 'The top of it' }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '무엇을 재는지에 대한 이름. 값과 함께 읽힙니다',
        en: 'A name for what is being measured. Read out with the value'
      }
    },
    {
      name: 'showValue',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '값을 막대 옆에 글자로 그립니다. format이 없으면 범위의 백분율입니다',
        en: 'Shows the value as text beside the bar. A percentage of the range unless format says otherwise'
      }
    },
    {
      name: 'format',
      type: 'Intl.NumberFormatOptions',
      description: {
        ko: '값을 어떻게 쓸지. 바이트도 통화도 됩니다',
        en: 'How the value is written — Intl.NumberFormat options, so bytes and currencies work too'
      }
    },
    {
      name: 'thresholds',
      type: 'readonly PlMeterThreshold[]',
      description: {
        ko: '값이 올라가면서 막대의 색 계열을 바꾸는 구간들. 값 이하의 from 중 가장 큰 것이 이기고, 순서는 상관없습니다',
        en: "Bands that change the bar's family as the value climbs. The highest from at or below the value wins, and order does not matter"
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '홈의 두께. meter에서 크기를 가지는 건 그것뿐입니다',
        en: 'Thickness of the groove. Nothing else on a meter has a size'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '어떤 구간에도 걸리지 않을 때 막대가 쓰는 색 계열',
        en: 'The family the bar takes where no threshold applies'
      }
    }
  ],

  PlMeterThreshold: [
    {
      name: 'from',
      type: 'number',
      required: true,
      description: {
        ko: '구간이 시작되는 값. 백분율이 아니라 meter 자신의 단위입니다',
        en: "The value the band begins at, in the meter's own units rather than a percentage"
      }
    },
    {
      name: 'color',
      type: COLOR,
      required: true,
      description: {
        ko: '값이 이 구간에 있는 동안 막대가 쓰는 색 계열',
        en: 'The family the bar takes while the value is in this band'
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
    },
    portalClassNames
  ],

  PlNavigationMenu: [
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '행의 높이와 타입 스케일. 패널의 반경과 여백도 함께 갑니다',
        en: "The row's height and type scale, and the panel's radius and padding with it"
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. hover와 열린 패널과 focus ring까지 갑니다 — 시트에는 색이 들어가지 않습니다',
        en: 'Semantic colour role. It reaches the hover, the open item and the focus rings; the sheet is never dyed'
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
      name: 'orientation',
      type: "'horizontal' | 'vertical'",
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '행이 늘어서는 방향. vertical은 패널이 옆으로 열리는 nav rail입니다',
        en: 'Which way the row runs. vertical is a nav rail whose panels open beside it'
      }
    },
    {
      name: 'value',
      type: 'string | null',
      description: {
        ko: '어느 항목의 패널이 열려 있는지, value로. nullish는 닫힘입니다',
        en: "Which item's panel is open, by its value. Nullish means closed"
      }
    },
    {
      name: 'defaultValue',
      type: 'string | null',
      description: {
        ko: '어느 것이 열린 채로 시작할지',
        en: 'Which starts open, for an uncontrolled menu'
      }
    },
    {
      name: 'onValueChange',
      type: '(value: string | null) => void',
      description: { ko: '열린 패널이 바뀔 때', en: 'Called when the open panel changes' }
    },
    {
      name: 'delay',
      type: 'number',
      description: {
        ko: '패널이 열리기까지 포인터가 머무는 시간, 밀리초',
        en: 'How long the pointer rests before a panel opens, in milliseconds'
      }
    },
    {
      name: 'closeDelay',
      type: 'number',
      description: {
        ko: '포인터가 떠난 뒤 패널이 남는 시간, 밀리초',
        en: 'How long a panel stays after the pointer leaves, in milliseconds'
      }
    },
    {
      name: 'sideOffset',
      type: 'number',
      default: '8',
      description: { ko: '행에서 떨어진 거리, 픽셀', en: 'Distance from the row, in pixels' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '항목들', en: 'The items' }
    }
  ],

  PlNavigationMenuItem: [
    {
      name: 'label',
      type: 'ReactNode',
      required: true,
      description: { ko: '행에 쓰이는 단어', en: 'The word in the row' }
    },
    {
      name: 'href',
      type: 'string',
      description: {
        ko: '패널을 여는 대신 그냥 링크로 만듭니다. href만 있고 children이 없는 항목은 목적지이고, 그렇게 알려집니다',
        en: 'Makes the item a plain link rather than something that opens a panel. An item with an href and no children is a destination, and it is announced as one'
      }
    },
    {
      name: 'target',
      type: 'string',
      description: {
        ko: '링크가 열리는 곳. 이 탭이 아니면 rel에 noopener noreferrer가 합쳐집니다',
        en: 'Where the link opens. Anything other than this tab also gets noopener noreferrer merged into its rel'
      }
    },
    {
      name: 'rel',
      type: 'string',
      description: { ko: '링크의 rel', en: "The link's rel" }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '라벨 앞에 놓이는 내용', en: 'Content before the label' }
    },
    {
      name: 'value',
      type: 'string',
      description: {
        ko: 'controlled 메뉴에서 항목을 식별합니다',
        en: 'Identifies the item, for a controlled menu'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '쓸 수 없습니다. 단어는 행에 남고 아무것도 열지 않습니다',
        en: 'Unavailable. The word stays in the row and opens nothing'
      }
    },
    {
      name: 'columns',
      type: 'number',
      default: '1',
      description: {
        ko: '패널이 링크를 몇 열로 배치할지',
        en: 'How many columns the panel lays its links out in'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '패널의 내용. 보통 PlNavigationMenuLink들입니다',
        en: "The panel's contents — usually PlNavigationMenuLinks"
      }
    },
    ...stylingProps({ ko: '행에 쓰인 단어', en: 'the word in the row' })
  ],

  PlNavigationMenuLink: [
    {
      name: 'href',
      type: 'string',
      required: true,
      description: { ko: '어디로 가는지', en: 'Where it goes' }
    },
    {
      name: 'title',
      type: 'ReactNode',
      required: true,
      description: { ko: '행의 이름', en: "The row's name" }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '그 아래 한 줄. 타입 스케일 한 단계 아래의 muted 텍스트',
        en: 'A second line under it, one step down the scale and muted'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '제목 앞의 글리프', en: 'A glyph before the title' }
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
    },
    hotKeysProp,
    fieldClassNames
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
    },
    hotKeysProp,
    fieldClassNames
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
    },
    portalClassNames
  ],

  PlPageLayout: [
    {
      name: 'header',
      type: 'ReactNode',
      description: {
        ko: '위쪽 바. 보통 PlHeader가 들어갑니다',
        en: 'The bar across the top. A PlHeader, usually'
      }
    },
    {
      name: 'footer',
      type: 'ReactNode',
      description: {
        ko: '맨 아래 시트. 보통 PlFooter가 들어갑니다',
        en: 'The sheet at the end. A PlFooter, usually'
      }
    },
    {
      name: 'sidebar',
      type: 'ReactNode',
      description: {
        ko: '앞쪽 열 — 영어 페이지의 왼쪽, 아랍어 페이지의 오른쪽. 안에 든 PlSidebar는 자기가 어느 끝인지 전달받으므로 side를 쓸 필요가 없습니다',
        en: 'The leading column — the left of an English page, the right of an Arabic one. A PlSidebar in here is told which end it is on and needs no side of its own'
      }
    },
    {
      name: 'endSidebar',
      type: 'ReactNode',
      description: {
        ko: '뒤쪽 열. 한쪽은 내비게이션, 다른 쪽은 목차나 인스펙터나 필터 패널인 레이아웃을 위한 것입니다',
        en: 'The trailing column, for the layouts that have two: navigation down one side and a table of contents, an inspector or a filter panel down the other'
      }
    },
    {
      name: 'headerSpan',
      type: "'full' | 'content'",
      default: "'full'",
      description: {
        ko: '헤더와 사이드바 중 어느 쪽이 위 모서리를 차지하는지. full은 웹사이트의 배치, content는 애플리케이션의 배치입니다',
        en: 'Which of the header and the sidebars takes the top corner. full is the arrangement of a website, content that of an application'
      }
    },
    {
      name: 'footerSpan',
      type: "'full' | 'content'",
      default: "'full'",
      description: {
        ko: '푸터에 대한 같은 질문. 따로 답할 값어치가 있습니다 — 전체 높이 내비게이션 레일이 있는 대시보드도 저작권 줄은 보통 콘텐츠 아래에 둡니다',
        en: 'The same question for the footer, and worth answering separately: a dashboard with a full-height rail still usually wants its copyright line under the content'
      }
    },
    {
      name: 'scroll',
      type: "'page' | 'content'",
      default: "'page'",
      description: {
        ko: '무엇이 스크롤되는지 — 문서 전체인지, 헤더와 푸터 사이만인지. page가 거의 모든 페이지가 원하는 값입니다',
        en: 'What scrolls: the document, or only the region between the header and the footer. page is what almost every page wants'
      }
    },
    {
      name: 'height',
      type: "'viewport' | 'auto' | number | string",
      default: "'viewport'",
      description: {
        ko: '레이아웃의 높이. 페이지가 스크롤될 때는 최소 높이, 콘텐츠만 스크롤될 때는 정확한 높이가 됩니다',
        en: 'How tall the layout is. A floor while the page scrolls and an exact height while only the content does'
      }
    },
    {
      name: 'collapseBelow',
      type: "'xs' | 'sm' | 'md' | 'lg' | 'xl' | 'none'",
      default: "'md'",
      description: {
        ko: '사이드바가 열이기를 그만두고 드로어가 되는 창 너비. none이면 어떤 너비에서도 열로 남습니다',
        en: 'The window width below which the sidebars become drawers instead of columns. none keeps them columns at every width'
      }
    },
    {
      name: 'sidebarOpen',
      type: 'boolean',
      description: {
        ko: '앞쪽 사이드바의 드로어가 열려 있는지. onSidebarOpenChange와 함께 controlled로 씁니다',
        en: "Whether the leading sidebar's drawer is open. Use with onSidebarOpenChange for a controlled layout"
      }
    },
    {
      name: 'defaultSidebarOpen',
      type: 'boolean',
      default: 'false',
      description: { ko: '어느 상태로 시작할지', en: 'Which state it starts in' }
    },
    {
      name: 'onSidebarOpenChange',
      type: '(open: boolean) => void',
      description: {
        ko: '앞쪽 드로어가 열리거나 닫힐 때',
        en: 'Called when the leading drawer opens or closes'
      }
    },
    {
      name: 'endSidebarOpen',
      type: 'boolean',
      description: {
        ko: '뒤쪽 사이드바에 대한 같은 세 가지',
        en: 'The same three for the trailing sidebar'
      }
    },
    {
      name: 'defaultEndSidebarOpen',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '뒤쪽 드로어가 시작하는 상태',
        en: 'Which state the trailing drawer starts in'
      }
    },
    {
      name: 'onEndSidebarOpenChange',
      type: '(open: boolean) => void',
      description: {
        ko: '뒤쪽 드로어가 열리거나 닫힐 때',
        en: 'Called when the trailing drawer opens or closes'
      }
    },
    {
      name: 'skipLink',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '문서 맨 앞에 본문으로 건너뛰는 링크를 둡니다. focus를 받을 때만 그려집니다',
        en: 'Puts a skip link first in the document, drawn only while it holds the focus'
      }
    },
    {
      name: 'skipLabel',
      type: 'ReactNode',
      default: "'Skip to content'",
      description: { ko: '그 링크가 말하는 내용', en: 'What that link says' }
    },
    {
      name: 'mainId',
      type: 'string',
      default: "'main'",
      description: {
        ko: '건너뛰기 링크가 향하는 id. <main>에 붙습니다',
        en: 'The id the skip link jumps to, put on the <main>'
      }
    },
    {
      name: 'mainProps',
      type: "Omit<ComponentPropsWithoutRef<'main'>, 'id' | 'children'>",
      description: {
        ko: '<main>에 필요한 나머지 — className, aria-label',
        en: 'Anything else the <main> needs — a className, an aria-label'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '건너뛰기 링크가 켜지는 색 계열. 레이아웃 자체는 아무 표면도 그리지 않습니다',
        en: 'The colour family the skip link lights up in. The layout itself draws no surface'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '페이지. <main> 안에 그려집니다',
        en: 'The page. Rendered inside the <main>'
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
      name: 'renderLink',
      type: '(page: number, href: string) => ReactElement',
      description: {
        ko: '각 페이지 링크를 <a> 대신 다른 것으로 그립니다 — 보통 라우터의 Link. 없으면 SPA에서 매 클릭이 전체 문서 로드가 됩니다',
        en: "Renders each page's link as something other than an <a> — a router's Link. Without it, every press in a single-page app is a full document load"
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
      type: "PlassResponsive<'horizontal' | 'vertical'>",
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
  PlPortal: [
    {
      name: 'container',
      type: 'Element | DocumentFragment | RefObject<Element | null> | (() => Element | DocumentFragment | null)',
      default: 'document.body',
      description: {
        ko: '자식이 갈 자리. 마운트 뒤에 풀리므로 ref나 조회 함수도 됩니다. 아무것도 아닌 것으로 풀리면 body로 떨어집니다',
        en: 'Where the children go. Resolved after mount, so a ref or a lookup works. Anything resolving to nothing falls back to the body'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '옮기지 않고 제자리에 그립니다. 마운트 시점에 한 번 정하십시오. 뒤집으면 안쪽이 다시 마운트됩니다',
        en: 'Renders in place instead of moving anything. Decide it once, at mount — flipping it remounts everything inside'
      }
    },
    {
      name: 'render',
      type: 'RenderProp',
      description: {
        ko: '<div> 대신 다른 요소로 렌더링합니다 (<li />, <tbody />)',
        en: 'Renders something other than a <div> (<li />, <tbody />)'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '옮겨질 내용', en: 'What is moved' }
    },
    {
      name: 'className',
      type: 'string',
      description: {
        ko: '컴포넌트 자신의 plass-portal 옆에 놓입니다',
        en: 'Sits alongside the component’s own plass-portal'
      }
    }
  ],

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
    },
    fieldClassNames
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

  PlScrollArea: [
    {
      name: 'orientation',
      type: "'vertical' | 'horizontal' | 'both'",
      default: "'vertical'",
      description: {
        ko: '어느 축이 스크롤될지. both는 모서리마다 레인 하나씩과 만나는 자리의 조각을 그립니다',
        en: 'Which axes may scroll. both draws a lane on each edge and a corner where they meet'
      }
    },
    {
      name: 'height · maxHeight',
      type: 'number | string',
      description: {
        ko: '고정 높이, 또는 넘칠 때까지는 줄어드는 천장. 세로 스크롤 영역은 무언가로 크기가 정해져야 합니다',
        en: 'A fixed height, or a ceiling it shrinks under. A vertical scroll area has to be bounded by something'
      }
    },
    {
      name: 'width · maxWidth',
      type: 'number | string',
      description: { ko: '가로 영역을 위한 같은 짝', en: 'The same pair for a horizontal area' }
    },
    {
      name: 'scrollbars',
      type: "'auto' | 'always'",
      default: "'auto'",
      description: {
        ko: '레인을 언제 그릴지. auto는 포인터가 위에 있거나 내용이 움직이는 동안만. 어느 쪽이든 내용의 폭은 줄지 않습니다',
        en: 'When the lanes are drawn. auto is while the pointer is over the box or the content is moving. Either way the content loses no width'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: 'region의 이름. 안에 포커스 가능한 것이 없어도 스크롤 상자는 tab 대상이 되므로, 이름 없는 도착점이 되지 않게 합니다',
        en: 'A name for the region. A scrollable box is a tab stop even when nothing inside it is focusable, and a landing point with no name is announced as nothing'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '스크롤바 두께와 상자가 잘리는 모서리',
        en: 'Thickness of the scrollbars and the corner the box is cut to'
      }
    },
    {
      name: 'classNames',
      type: '{ viewport, scrollbar, thumb }',
      description: {
        ko: 'className이 닿지 않는 부분의 클래스',
        en: 'Classes on the parts a className does not reach'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '스크롤되는 내용', en: 'What scrolls' }
    }
  ],

  PlScrollZone: [
    {
      name: 'orientation',
      type: "PlassResponsive<'horizontal' | 'vertical'>",
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
      type: "'inline' | 'overlay'",
      default: "'inline'",
      description: {
        ko: '버튼이 띠 옆에 서는지 위에 얹히는지',
        en: 'Whether the buttons sit beside the strip or over it'
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
      name: 'wheel',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '가로 zone 위에서 세로로 굴린 휠이 띠를 따라 스크롤하게 합니다. 끝에 닿으면 휠은 페이지로 돌아갑니다',
        en: 'Turns a vertical wheel over a horizontal zone into scrolling along the strip. At either end it goes back to the page'
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
    },
    hotKeysProp,
    fieldClassNames
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

  PlShow: [
    {
      name: 'from',
      type: "'sm' | 'md' | 'lg' | 'xl'",
      shared: true,
      description: {
        ko: '그려지는 가장 좁은 너비. 그 아래에서는 아무것도 그려지지 않습니다',
        en: 'The narrowest width this is drawn at. Below it, nothing'
      }
    },
    {
      name: 'until',
      type: "'sm' | 'md' | 'lg' | 'xl'",
      shared: true,
      description: {
        ko: '그려지기를 멈추는 너비. 미포함이라, 한쪽의 until="md"와 다른 쪽의 from="md"가 한 결정의 두 쪽이 됩니다',
        en: 'The width it stops being drawn at. Exclusive, so until="md" on one element and from="md" on another are the two halves of one decision'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '보이는 너비에서 보이는 것',
        en: 'What is shown, at the widths it is shown at'
      }
    }
  ],

  PlSidebar: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '패널의 재질. 색은 들어가지 않습니다 — 위에 얹힌 것들이 자기 색을 갖고 옵니다',
        en: 'What the panel is made of. Never dyed — what is on it arrives with colours of its own'
      },
      sizeDescription: {
        ko: '패널의 기본 너비와 내용 둘레의 공기',
        en: "The panel's default width and the air around its content"
      }
    }),
    {
      name: 'side',
      type: "'start' | 'end'",
      default: "'start'",
      description: {
        ko: '어느 끝을 차지하는지. 물리적이 아니라 논리적입니다. PlPageLayout 안에서는 어느 슬롯에 넘겼는지가 이미 정하므로 다시 쓸 필요가 없습니다',
        en: 'Which end of the band it takes. Logical rather than physical. Inside a PlPageLayout the slot it was handed to has already decided this'
      }
    },
    {
      name: 'width',
      type: 'number | string',
      description: {
        ko: '열의 너비 — 픽셀 수 또는 CSS 길이. 없으면 size가 함의하는 너비입니다',
        en: 'How wide the column is — a number in pixels or any CSS length. Left out, it is the width size implies'
      }
    },
    {
      name: 'minWidth',
      type: 'number | string',
      default: '160',
      description: { ko: '얼마나 좁게까지 끌 수 있는지', en: 'How narrow it may be dragged' }
    },
    {
      name: 'maxWidth',
      type: 'number | string',
      default: '480',
      description: { ko: '그리고 얼마나 넓게까지', en: 'And how wide' }
    },
    {
      name: 'resizable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '안쪽 가장자리를 끌어 열의 너비를 바꿀 수 있게 합니다',
        en: "Lets the reader drag the inner edge to change the column's width"
      }
    },
    {
      name: 'onResize',
      type: '(width: number) => void',
      description: {
        ko: '가장자리를 끄는 동안 픽셀 너비와 함께 발생합니다',
        en: 'Fires with the width in pixels while the edge is being dragged'
      }
    },
    {
      name: 'onResizeEnd',
      type: '(width: number) => void',
      description: {
        ko: '놓았을 때 같은 숫자와 함께 한 번 발생합니다',
        en: 'Fires once, with the same number, when it is let go'
      }
    },
    {
      name: 'collapseBelow',
      type: "'xs' | 'sm' | 'md' | 'lg' | 'xl' | 'none'",
      description: {
        ko: '열이기를 그만두고 drawer가 되는 창 너비. PlPageLayout의 값이 기본이고, 레이아웃 밖에서는 none입니다',
        en: "The window width below which it becomes a drawer instead of a column. Defaults to the PlPageLayout's own, and to none outside one"
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: 'drawer가 열려 있는지. 접힌 뒤에만 뜻이 있습니다. PlPageLayout 안에서는 레이아웃이 쥡니다',
        en: 'Whether the drawer is open. Only meaningful once collapsed; inside a PlPageLayout the layout owns it'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '레이아웃 밖의 uncontrolled sidebar가 시작하는 상태',
        en: 'Which state it starts in, for an uncontrolled standalone sidebar'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: 'drawer가 열리거나 닫힐 때', en: 'Called when the drawer opens or closes' }
    },
    {
      name: 'sticky',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '페이지가 지나갈 때 열이 자기 자리를 지키는지. 필요 없을 때는 아무 비용도 들지 않습니다',
        en: 'Whether the column holds its place while the page scrolls past it. It costs nothing when it is not needed'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: 'drawer일 때만 그려지는 제목. 열에는 자기가 무엇인지 말해 줄 페이지가 둘레에 있지만, 페이지를 덮은 패널에는 없습니다',
        en: 'The heading, drawn only while the sidebar is a drawer. A column has the page around it to say what it is; a panel that has covered the page does not'
      }
    },
    {
      name: 'divider',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '안쪽 가장자리 — 콘텐츠를 마주하는 쪽 — 에 헤어라인을 그립니다',
        en: 'Draws a hairline down the inner edge — the one facing the content'
      }
    },
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'gutter와 내용 위아래의 공기',
        en: 'The gutter and the air above and below the content'
      }
    },
    {
      name: 'label',
      type: 'string',
      default: "'Sidebar'",
      description: {
        ko: '영역이 불리는 이름. sidebar가 둘인 페이지는 반드시 써야 합니다',
        en: 'The name the region is announced by. A page with two sidebars must write one'
      }
    },
    {
      name: 'closeLabel',
      type: 'string',
      default: "'Close sidebar'",
      description: {
        ko: '접힌 뒤 drawer의 닫기 버튼이 말하는 내용',
        en: "What the drawer's close button says, once the sidebar has collapsed"
      }
    },
    {
      name: 'resizeLabel',
      type: 'string',
      default: "'Resize sidebar'",
      description: { ko: '드래그 손잡이가 불리는 이름', en: 'What the drag handle is announced as' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '안에 든 전부 — nav, 필터 패널, 목차',
        en: 'Everything in it: a nav, a filter panel, a table of contents'
      }
    }
  ],

  PlSidebarTrigger: [
    {
      name: 'side',
      type: "'start' | 'end'",
      default: "'start'",
      description: {
        ko: '레이아웃의 두 sidebar 중 어느 쪽을 여는지',
        en: "Which of the layout's two sidebars it opens"
      }
    },
    {
      name: 'collapseBelow',
      type: "'xs' | 'sm' | 'md' | 'lg' | 'xl' | 'none'",
      description: {
        ko: '버튼이 나타나는 너비. sidebar가 접히는 그 너비이고, PlPageLayout에서 물려받습니다',
        en: 'The width below which the button appears — the same one the sidebar collapses at. Inherited from the PlPageLayout'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: {
        ko: '글리프. 주지 않으면 여기서 그리는 햄버거입니다',
        en: 'The glyph. A hamburger, drawn here, unless something else is given'
      }
    },
    {
      name: 'label',
      type: 'string',
      default: "'Open sidebar' / 'Close sidebar'",
      description: { ko: '무엇을 하는지, 말로', en: 'What it does, in words' }
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
    },
    fieldClassNames
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
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 앞의 표시 — 파비콘, 파일 종류, 자물쇠. icon과 달리 넣지 않으면 아무것도 그리지 않습니다',
        en: 'A mark before the label — a favicon, a file type, a lock. Unlike icon it has no opinion: nothing is drawn unless something is put there'
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
      type: "PlassResponsive<'horizontal' | 'vertical'>",
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
    }),
    fieldClassNames
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
      type: "PlassResponsive<'horizontal' | 'vertical'>",
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
    },
    ...stylingProps({ ko: '이 토스트', en: 'this toast' })
  ],

  PlToggle: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '**꺼져 있을 때** 키가 무엇으로 만들어졌는지. 켜지면 어느 재질이든 색 계열이 나섭니다',
        en: 'What the key is made of while it is **off**. On is always the colour family asserting itself, whichever material was asked for'
      },
      elevationDescription: {
        ko: '그림자 깊이. 0이 기본이고 PlButton보다 한 단계 아래입니다 — 토글은 액션이 아니라 상태이고, 상태는 페이지 위에 떠서 기다리지 않습니다',
        en: "Drop shadow depth. 0 is the default and one below a PlButton's: a toggle is a state rather than an action, and a state does not float off the page waiting to be taken"
      }
    }),
    {
      name: 'pressed',
      type: 'boolean',
      description: {
        ko: '켜져 있는지. onPressedChange와 함께 controlled로 씁니다',
        en: 'Whether it is on. Use with onPressedChange for a controlled toggle'
      }
    },
    {
      name: 'defaultPressed',
      type: 'boolean',
      default: 'false',
      description: { ko: '켜진 채로 시작할지', en: 'Whether it starts on, for an uncontrolled one' }
    },
    {
      name: 'onPressedChange',
      type: '(pressed: boolean) => void',
      description: { ko: '켜지거나 꺼질 때', en: 'Called when it goes on or off' }
    },
    {
      name: 'value',
      type: 'string',
      description: {
        ko: 'PlToggleGroup 안에서 이 토글을 식별합니다',
        en: 'Identifies the toggle inside a PlToggleGroup'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 앞에 놓이는 내용. em으로 크기가 정해져 라벨을 따릅니다',
        en: 'Content placed before the label. Sized in em, so it tracks the label'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: { ko: '라벨 뒤에 놓이는 내용', en: 'Content placed after the label' }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '컨테이너 너비까지 늘어납니다',
        en: 'Stretches to the width of the container'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '눌 수 없게 하고 tab 순서에서 뺍니다',
        en: 'Makes it unpressable and takes it out of the tab order'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '라벨. 없으면 받은 아이콘 둘레로 정사각형이 됩니다 — 그래도 aria-label은 필요합니다',
        en: 'The label. Left out, the toggle goes square around whatever icon it was given — which still needs an aria-label'
      }
    }
  ],

  PlToggleGroup: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '세트의 모든 토글에 전달됩니다',
        en: 'Passed to every toggle in the set'
      },
      elevationDescription: {
        ko: '그림자 깊이. 세트의 모든 토글에 전달됩니다',
        en: 'Drop shadow depth, passed to every toggle in the set'
      }
    }),
    {
      name: 'value',
      type: 'readonly string[]',
      description: {
        ko: '어느 토글이 켜져 있는지, value로. 하나든 여럿이든 배열입니다 — multiple을 켜도 타입이 바뀌지 않는 모양입니다',
        en: 'Which toggles are on, by their value. An array in both cases — the shape that does not change type when multiple is turned on'
      }
    },
    {
      name: 'defaultValue',
      type: 'readonly string[]',
      description: {
        ko: '어느 것이 켜진 채로 시작할지',
        en: 'Which start on, for an uncontrolled set'
      }
    },
    {
      name: 'onValueChange',
      type: '(value: string[]) => void',
      description: { ko: '세트의 값이 바뀔 때', en: "Called when the set's value changes" }
    },
    {
      name: 'multiple',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '한 번에 둘 이상 켜질 수 있는지. 꺼져 있으면 하나를 켤 때 이전 것이 꺼집니다',
        en: 'Whether more than one can be on at a time. Off, turning one on turns the last one off'
      }
    },
    {
      name: 'orientation',
      type: "'horizontal' | 'vertical'",
      default: "'horizontal'",
      shared: true,
      description: { ko: '토글이 늘어서는 방향', en: 'Which way the toggles run' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      description: {
        ko: '세트의 모든 토글을 한 번에 끕니다',
        en: 'Disables every toggle in the set at once'
      }
    },
    {
      name: 'loopFocus',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '화살표 키가 양 끝에서 돌아가는지',
        en: 'Whether the arrow keys wrap around at the ends'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '컨테이너까지 늘어나고 너비를 토글들에 고르게 나눕니다',
        en: 'Stretches to the container and divides the width evenly between toggles'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '세트를 이루는 PlToggle들', en: 'The PlToggles that make up the set' }
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

  PlTour: [
    {
      name: 'steps',
      type: 'readonly PlTourStep[]',
      required: true,
      description: { ko: '들를 곳들, 순서대로', en: 'The stops, in order' }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '투어가 돌고 있는지. onOpenChange와 함께 넘기면 제어됩니다',
        en: 'Whether the tour is running. Pass it with onOpenChange to control one'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '투어가 스스로 들고 있을 때, 처음부터 돌고 있는지',
        en: 'Whether it starts running, when the tour keeps that itself'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: {
        ko: 'open이 되어야 할 값으로 불립니다',
        en: 'Called with what open should become'
      }
    },
    {
      name: 'step',
      type: 'number',
      description: {
        ko: '몇 번째 정거장인지, 0부터. onStepChange와 함께 넘기면 제어됩니다',
        en: 'Which stop, counted from 0. Pass it with onStepChange to control one'
      }
    },
    {
      name: 'defaultStep',
      type: 'number',
      default: '0',
      description: {
        ko: '투어가 스스로 들고 있을 때 시작하는 정거장',
        en: 'Which one it starts on, when the tour keeps that itself'
      }
    },
    {
      name: 'onStepChange',
      type: '(step: number) => void',
      description: {
        ko: 'Next나 Previous를 누를 때 그 정거장으로 불립니다',
        en: 'Called with the stop a Next or Previous press asks for'
      }
    },
    {
      name: 'onFinish',
      type: '() => void',
      description: {
        ko: '마지막 단계의 버튼을 누를 때, 투어가 닫히기 전에 불립니다',
        en: "Called when the last step's button is pressed, before the tour closes"
      }
    },
    {
      name: 'mask',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '페이지를 어둡게 하고 대상만 그 어둠에서 오려 냅니다',
        en: 'Dims the page and cuts the target out of the dimming'
      }
    },
    {
      name: 'skippable',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '카운터 옆에 Skip 버튼을 그립니다',
        en: 'Draws the Skip button beside the counter'
      }
    },
    {
      name: 'dismissible',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'Escape와 ×로 투어를 끝낼 수 있는지',
        en: 'Whether Escape and the × end the tour'
      }
    },
    {
      name: 'scrollIntoView',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '단계가 바뀔 때 대상을 화면 안으로 스크롤합니다',
        en: 'Scrolls each target into view as the tour reaches it'
      }
    },
    {
      name: 'previousLabel',
      type: 'ReactNode',
      default: 'labels.previous',
      description: { ko: 'Previous 버튼', en: 'The Previous button' }
    },
    {
      name: 'nextLabel',
      type: 'ReactNode',
      default: 'labels.next',
      description: { ko: 'Next 버튼', en: 'The Next button' }
    },
    {
      name: 'doneLabel',
      type: 'ReactNode',
      default: 'labels.done',
      description: {
        ko: '마지막 단계에서 Next가 되는 것',
        en: 'What Next becomes on the last step'
      }
    },
    {
      name: 'skipLabel',
      type: 'ReactNode',
      default: 'labels.skip',
      description: { ko: 'Skip 버튼', en: 'The Skip button' }
    },
    ...sharedProps({
      variant: '—',
      size: "'md'",
      sizeDescription: {
        ko: '타입 스케일과 카드의 너비',
        en: "Type scale and the card's width"
      },
      colorDescription: {
        ko: '의미론적 색 역할: 버튼과 focus ring',
        en: 'Semantic colour role: the buttons and the focus ring'
      },
      densityDescription: {
        ko: '카드의 여백만 바꿉니다. 타입 스케일은 그대로',
        en: "The card's padding. Never the type scale"
      }
    }).filter((row) => row.name !== 'variant' && row.name !== 'elevation'),
    {
      name: 'classNames',
      type: 'PlTourClassNames',
      description: {
        ko: '카드 바깥 부분들의 클래스 이름: mask · title · content · close · footer',
        en: 'Class names for the parts around the card: mask, title, content, close and footer'
      }
    }
  ],

  PlTourStep: [
    {
      name: 'target',
      type: 'string | RefObject<Element | null> | (() => Element | null)',
      description: {
        ko: '이 단계가 가리키는 것. 없으면 카드가 화면 가운데에 놓이고 아무것도 오려 내지 않습니다',
        en: 'What this step is about. Left out, the card is centred over the page and nothing is cut out'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '단계의 제목', en: "The step's heading" }
    },
    {
      name: 'content',
      type: 'ReactNode',
      description: { ko: '단계가 하는 말', en: 'What it says' }
    },
    {
      name: 'side',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'bottom'",
      shared: true,
      description: {
        ko: '대상의 어느 변에 카드가 붙는지',
        en: 'Which edge of the target the card sits on'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      shared: true,
      description: { ko: '그 변의 어디쯤에', en: 'Where along that edge' }
    },
    {
      name: 'padding',
      type: 'number',
      default: '6',
      description: {
        ko: '오려 낸 구멍이 대상보다 얼마나 큰지, px',
        en: 'How far the cut-out is grown past the target, in pixels'
      }
    },
    {
      name: 'radius',
      type: 'number',
      description: {
        ko: '구멍의 모서리 반지름, px. 없으면 size의 값',
        en: "The cut-out's corner radius in pixels. Defaults to the size's own"
      }
    }
  ],

  PlTransfer: [
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: '두 패널의 재질. 필드와 같은 껍데기입니다 — 목록은 값을 담지, 눌리지 않습니다',
        en: 'What the two panels are made of. The same shell a field wears: a list holds a value rather than being pressed'
      },
      sizeDescription: {
        ko: '체크박스, 화살표, 타입 스케일, 여백이 함께 움직입니다',
        en: 'The checkboxes, the arrows, the type scale and the padding, moving together'
      }
    }),
    {
      name: 'items',
      type: 'readonly PlTransferItem[]',
      required: true,
      description: {
        ko: '양쪽에 있을 수 있는 모든 것. 두 목록이 보여 주는 순서이기도 합니다',
        en: 'Everything that can be on either side, in the order both lists show it'
      }
    },
    {
      name: 'value',
      type: 'readonly string[]',
      description: {
        ko: '뒤쪽에 있는 것. onValueChange와 함께 controlled로 씁니다',
        en: 'What is on the trailing side. Use with onValueChange for a controlled pair'
      }
    },
    {
      name: 'defaultValue',
      type: 'readonly string[]',
      description: { ko: '뒤쪽에서 시작하는 것', en: 'What starts there, for an uncontrolled one' }
    },
    {
      name: 'onValueChange',
      type: '(value: string[]) => void',
      description: {
        ko: '뭔가 건너갔거나 돌아왔을 때',
        en: 'Called when something moves across or back'
      }
    },
    {
      name: 'sourceLabel',
      type: 'ReactNode',
      default: "'Available'",
      description: { ko: '앞쪽 목록 위의 제목', en: 'The heading over the leading list' }
    },
    {
      name: 'targetLabel',
      type: 'ReactNode',
      default: "'Selected'",
      description: { ko: '뒤쪽 목록 위의 제목', en: 'And over the trailing one' }
    },
    {
      name: 'searchable',
      type: 'boolean',
      default: 'false',
      description: { ko: '각 목록 위에 필터를 둡니다', en: 'Puts a filter above each list' }
    },
    {
      name: 'searchLabel',
      type: 'string',
      default: "'Search'",
      description: {
        ko: '그 필터가 비어 있을 때 말하는 내용',
        en: 'What that filter says while it is empty'
      }
    },
    {
      name: 'emptyLabel',
      type: 'string',
      default: "'Nothing here'",
      description: {
        ko: '아무것도 없는 목록이 말하는 내용',
        en: 'What a list with nothing in it says'
      }
    },
    {
      name: 'selectAllLabel',
      type: 'string',
      default: "'Select all'",
      description: {
        ko: '목록 제목의 체크박스가 불리는 이름',
        en: "What the tick in a list's heading is announced as"
      }
    },
    {
      name: 'toTargetLabel',
      type: 'string',
      default: "'Move to selected'",
      description: {
        ko: '건너가는 화살표가 불리는 이름',
        en: 'What the outward arrow is announced as'
      }
    },
    {
      name: 'toSourceLabel',
      type: 'string',
      default: "'Move to available'",
      description: {
        ko: '돌아오는 화살표가 불리는 이름',
        en: 'What the returning arrow is announced as'
      }
    },
    {
      name: 'height',
      type: 'number | string',
      default: '220',
      description: {
        ko: '각 목록의 높이. 픽셀 수 또는 CSS 길이',
        en: 'How tall each list is. A number of pixels or any CSS length'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '아무것도 체크하거나 옮길 수 없습니다',
        en: 'Nothing can be ticked or moved'
      }
    }
  ],

  PlTransferItem: [
    {
      name: 'value',
      type: 'string',
      required: true,
      description: {
        ko: '이 항목을 식별하는 것이자, value가 담는 것',
        en: 'What identifies it, and what value is a list of'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      required: true,
      description: { ko: '행이 말하는 내용', en: 'What the row says' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '목록에는 있지만 옮길 수 없습니다', en: 'In the list but not movable' }
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
    },
    hotKeysProp,
    fieldClassNames
  ],
  PlCalendar: [
    {
      name: 'variant',
      type: VARIANT,
      default: "'glass'",
      shared: true,
      description: {
        ko: '시트의 재질. 이미 시트를 그리는 것 안에 넣는다면 ghost',
        en: 'What the sheet is made of. ghost when it is already inside something that draws one'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '셀 · 반경 · 타입 스케일이 함께 움직입니다. density는 없습니다',
        en: 'Cell, radius and type scale together. There is no density'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '고른 날, 오늘 표시, focus ring이 쓰는 색 역할',
        en: 'The family the chosen day, the today marker and the focus ring take'
      }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      default: '1',
      shared: true,
      description: {
        ko: '그림자 깊이. 0은 그림자 없음',
        en: 'Drop shadow depth. 0 means no shadow at all'
      }
    },
    {
      name: 'value',
      type: 'Date | null',
      description: {
        ko: '고른 날. 제어하려면 onValueChange와 함께',
        en: 'The chosen day. Use with onValueChange for a controlled calendar'
      }
    },
    {
      name: 'defaultValue',
      type: 'Date | null',
      description: {
        ko: '제어하지 않을 때 시작하는 날',
        en: 'The day it starts on, for an uncontrolled one'
      }
    },
    {
      name: 'onValueChange',
      type: '(value: Date | null) => void',
      description: { ko: '날이 골렸을 때', en: 'Called when a day is chosen' }
    },
    {
      name: 'precision',
      type: "'day' | 'month' | 'year'",
      default: "'day'",
      description: {
        ko: '되돌려주는 가장 작은 단위. 시작 화면이 아니라 바닥이며, 값은 그 단위의 시작으로 정규화됩니다',
        en: 'The smallest unit it hands back. A floor rather than a starting view, and the value is normalised to the start of it'
      }
    },
    {
      name: 'month',
      type: 'Date',
      description: {
        ko: '화면에 있는 달. onMonthChange와 함께 쓰면 제어됩니다',
        en: 'The month on screen. Use with onMonthChange to control it'
      }
    },
    {
      name: 'defaultMonth',
      type: 'Date',
      description: {
        ko: '처음 보여 줄 달. 기본은 값의 달, 값이 없으면 이번 달',
        en: "The month it opens on. Defaults to the value's, or this month"
      }
    },
    {
      name: 'onMonthChange',
      type: '(month: Date) => void',
      description: { ko: '화면의 달이 바뀌었을 때', en: 'Called when the month on screen changes' }
    },
    {
      name: 'minDate',
      type: 'Date | null',
      description: {
        ko: '이 날 이전은 고를 수 없습니다. calendar의 precision으로 읽습니다',
        en: "Nothing before this day can be chosen. Read at the calendar's precision"
      }
    },
    {
      name: 'maxDate',
      type: 'Date | null',
      description: {
        ko: '이 날 이후는 고를 수 없습니다. calendar의 precision으로 읽습니다',
        en: "Nothing after it can be chosen. Read at the calendar's precision"
      }
    },
    {
      name: 'shouldDisableDate',
      type: '(date: Date) => boolean',
      description: {
        ko: '개별 날짜를 막습니다 — 주말, 공휴일, 이미 찬 날. 일 단위라 month/year에서는 참조하지 않습니다',
        en: 'Blocks individual days — weekends, holidays, a booked date. Day-granular, so month and year never consult it'
      }
    },
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: '월 이름 · 요일 머리글자 · 주의 첫날이 나오는 BCP 47 태그. 기본은 페이지의 로케일',
        en: "The BCP 47 tag the month names, weekday initials and first day of the week come from. The page's own by default"
      }
    },
    {
      name: 'weekStartsOn',
      type: '0 | 1 | 2 | 3 | 4 | 5 | 6',
      description: {
        ko: '주가 시작하는 요일. Date가 세는 방식이라 일요일이 0입니다. 없으면 locale에서 정합니다',
        en: 'Which day the week starts on, as Date counts them — Sunday is 0. Worked out from locale when absent'
      }
    },
    {
      name: 'showOutsideDays',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '이웃한 달에 속한 앞뒤 날들을 그립니다',
        en: 'Draws the leading and trailing days belonging to the neighbouring months'
      }
    },
    {
      name: 'autoFocus',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '마운트할 때 focus를 가져갑니다. 페이지 안의 calendar는 popup이 아니므로 기본은 꺼짐',
        en: 'Takes the focus on mount. Off, because a calendar in a page is not a popup'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '전체를 흐리게 하고 inert로 탭 순서에서 뺍니다. readOnly는 없습니다',
        en: 'Greys the whole calendar and takes it out of the tab order with inert. There is no readOnly'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼과 함께 제출합니다. 표기는 precision을 따릅니다 — YYYY-MM-DD, YYYY-MM, YYYY',
        en: 'Submits with a form. The spelling follows precision — YYYY-MM-DD, YYYY-MM, YYYY'
      }
    },
    {
      name: 'labels',
      type: 'Partial<PlPickerLabels>',
      description: {
        ko: 'Intl이 의견을 갖지 않는 문자열들 — 버튼과 제목',
        en: 'The strings Intl has no opinion about — the buttons and the headings'
      }
    }
  ],
  PlConfirmProvider: [
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '모든 질문의 기본 크기. 호출 하나가 덮어쓸 수 있습니다',
        en: 'The default size for every question. A single call can override it'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '확인 버튼이 기본으로 쓰는 색 역할',
        en: 'The family the confirming button takes by default'
      }
    },
    {
      name: 'confirmLabel',
      type: 'ReactNode',
      default: "'Confirm'",
      description: {
        ko: '예라고 답하는 버튼의 기본 문구',
        en: 'The default word on the button that answers yes'
      }
    },
    {
      name: 'cancelLabel',
      type: 'ReactNode',
      default: "'Cancel'",
      description: {
        ko: '아니오라고 답하는 버튼의 기본 문구',
        en: 'The default word on the button that answers no'
      }
    },
    {
      name: 'acknowledgeLabel',
      type: 'ReactNode',
      default: "'OK'",
      description: {
        ko: 'alert의 버튼 하나가 말하는 기본 문구',
        en: "The default word on an alert's single button"
      }
    },
    {
      name: 'width',
      type: 'number | string',
      description: { ko: '시트가 커질 수 있는 최대 너비', en: 'How wide the sheet may get' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '질문을 던질 수 있는 트리', en: 'The tree that can ask questions' }
    }
  ],
  PlConfirmOptions: [
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '질문. dialog에 이름을 주는 <h2>입니다',
        en: 'The question, as the <h2> that names the dialog'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '그 아래 한 줄이자 dialog의 accessible description. 무슨 일이 일어나는지 쓰세요',
        en: "A line under it, and the dialog's accessible description. Say what happens"
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '본문에 들어갈 그 밖의 것', en: 'Anything more that belongs in the body' }
    },
    {
      name: 'confirmLabel',
      type: 'ReactNode',
      description: {
        ko: '예라고 답하는 버튼의 문구',
        en: 'The word on the button that answers yes'
      }
    },
    {
      name: 'cancelLabel',
      type: 'ReactNode',
      description: {
        ko: '아니오라고 답하는 버튼의 문구. alert은 그리지 않습니다',
        en: 'The word on the button that answers no. Not drawn by alert'
      }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '확인 버튼의 색 역할. 무언가를 없애는 질문이면 danger',
        en: 'The family the confirming button takes. danger for anything that removes something'
      }
    },
    {
      name: 'size',
      type: SIZE,
      shared: true,
      description: { ko: '이 질문의 크기', en: 'The size of this one question' }
    },
    {
      name: 'initialFocus',
      type: "'confirm' | 'cancel'",
      default: "'cancel'",
      description: {
        ko: '열릴 때 어느 버튼이 focus를 쥘지. 기본이 cancel인 이유는, Enter가 파괴적인 동작에 떨어지면 confirm dialog가 무의미해지기 때문입니다',
        en: 'Which button holds the focus when it opens. cancel by default, because an Enter key landing on the destructive action defeats the dialog'
      }
    },
    {
      name: 'dismissible',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'Escape와 바깥 클릭이 아니오로 답할지. 빠져나갈 수 없는 질문은 덫입니다',
        en: 'Whether Escape and a click outside answer no. A question that cannot be escaped is a trap'
      }
    },
    {
      name: 'width',
      type: 'number | string',
      description: { ko: '시트가 커질 수 있는 최대 너비', en: 'How wide the sheet may get' }
    }
  ],
  PlStepper: [
    {
      name: 'active',
      type: 'number',
      description: {
        ko: '사용자가 있는 step의 인덱스. 제어하려면 onActiveChange와 함께',
        en: 'The index of the step the reader is on. Use with onActiveChange for a controlled stepper'
      }
    },
    {
      name: 'defaultActive',
      type: 'number',
      default: '0',
      description: {
        ko: '제어하지 않을 때 시작하는 step',
        en: 'The step it starts on, for an uncontrolled one'
      }
    },
    {
      name: 'onActiveChange',
      type: '(active: number) => void',
      description: { ko: 'step을 눌렀을 때', en: 'Called when a step is pressed' }
    },
    {
      name: 'linear',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '현재보다 앞선 step으로 건너뛸 수 있는지. 뒤의 step은 언제나 닿을 수 있습니다',
        en: 'Whether a step ahead of the current one can be jumped to. A step behind is always reachable'
      }
    },
    {
      name: 'orientation',
      type: "PlassResponsive<'horizontal' | 'vertical'>",
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '가로는 패널을 레일 아래에, 세로는 각 step 안에 놓습니다',
        en: 'Horizontal puts the panel under the rail; vertical puts each one inside its own step'
      }
    },
    {
      name: 'connector',
      type: "'solid' | 'dashed' | 'dotted' | 'none'",
      default: "'solid'",
      description: {
        ko: 'step 사이의 선. none은 간격을 비웁니다',
        en: 'The line between two steps. none leaves the gap open'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: { ko: 'bullet과 타입 스케일', en: 'Bullet and type scale' }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: { ko: '레일의 색 역할', en: 'The family the rail takes' }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: 'step 사이의 간격만 바꿉니다',
        en: 'The space between steps, and nothing else'
      }
    }
  ],
  PlStep: [
    {
      name: 'label',
      type: 'ReactNode',
      description: { ko: 'step의 이름', en: 'What the step is called' }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '아래 한 줄 — 이 step이 무엇을 묻는지',
        en: 'A second line under it — what the step asks for'
      }
    },
    {
      name: 'bullet',
      type: 'ReactNode',
      description: {
        ko: 'bullet 안에 그릴 것. 기본은 step의 번호이고, 지나가면 체크입니다',
        en: "What is drawn in the bullet. The step's own number by default, and a tick once it is complete"
      }
    },
    {
      name: 'status',
      type: "'complete' | 'current' | 'upcoming'",
      description: {
        ko: '시퀀스가 말하는 위치를 덮어씁니다. 사용자가 더 간 사이 유효성 검사에 걸린 step을 위한 것',
        en: 'Overrides where the sequence says this step is. For the one that failed validation while the reader moved on'
      }
    },
    {
      name: 'optional',
      type: 'boolean | ReactNode',
      description: {
        ko: '건너뛸 수 있음을 표시합니다. true는 "Optional"을, node는 그 node를 그립니다',
        en: 'Marks the step skippable. true draws the word "Optional"; a node draws that node'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'linear가 무엇이든 닿을 수 없습니다',
        en: 'Cannot be reached, whatever linear says'
      }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '이 step만 stepper의 family를 덮어씁니다',
        en: "Overrides the stepper's family for this one step"
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '현재 step일 때 보여 줄 패널',
        en: 'The panel this step shows while it is the current one'
      }
    }
  ],
  PlTree: [
    {
      name: 'items',
      type: 'readonly PlTreeNode[]',
      required: true,
      description: { ko: '트리 전체를 데이터로', en: 'The whole tree, as data' }
    },
    {
      name: 'expanded',
      type: 'readonly string[]',
      description: {
        ko: '열려 있는 가지의 id들. 제어하려면 onExpandedChange와 함께',
        en: 'The ids of the branches that are open. Use with onExpandedChange to control them'
      }
    },
    {
      name: 'defaultExpanded',
      type: 'readonly string[]',
      description: { ko: '처음부터 열려 있을 가지들', en: 'The branches that start open' }
    },
    {
      name: 'onExpandedChange',
      type: '(expanded: string[]) => void',
      description: { ko: '가지가 열리거나 닫혔을 때', en: 'Called when a branch opens or closes' }
    },
    {
      name: 'selected',
      type: 'readonly string[]',
      description: {
        ko: '선택된 행의 id들. 제어하려면 onSelectedChange와 함께',
        en: 'The ids of the selected rows. Use with onSelectedChange to control them'
      }
    },
    {
      name: 'defaultSelected',
      type: 'readonly string[]',
      description: { ko: '처음부터 선택돼 있을 행들', en: 'What starts selected' }
    },
    {
      name: 'onSelectedChange',
      type: '(selected: string[]) => void',
      description: { ko: '선택이 바뀌었을 때', en: 'Called when the selection changes' }
    },
    {
      name: 'selection',
      type: "'none' | 'single' | 'multiple'",
      default: "'single'",
      description: {
        ko: '클릭 하나가 몇 행을 켠 채로 둘 수 있는지. none은 고르는 도구가 아니라 둘러보는 도구입니다',
        en: 'How many rows a click can leave selected. none makes it a browser rather than a chooser'
      }
    },
    {
      name: 'onItemClick',
      type: '(node: PlTreeNode) => void',
      description: {
        ko: '행을 눌렀을 때. 선택 가능하든 아니든',
        en: 'Called when a row is clicked, selectable or not'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '행 높이 · 들여쓰기 · 타입 스케일',
        en: 'Row height, indent and type scale'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: { ko: '선택된 행이 쓰는 색 역할', en: 'The family a selected row takes' }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: '행의 세로 여백만 바꿉니다',
        en: "A row's vertical padding, and nothing else"
      }
    }
  ],
  PlTreeNode: [
    {
      name: 'id',
      type: 'string',
      required: true,
      description: {
        ko: '트리 전체에서 유일한 식별자',
        en: 'What identifies it, unique across the whole tree'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      required: true,
      description: { ko: '행이 말하는 것', en: 'What the row says' }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: { ko: 'label 앞의 글리프', en: 'A glyph before the label' }
    },
    {
      name: 'children',
      type: 'readonly PlTreeNode[]',
      description: {
        ko: '자식들. 빈 배열은 아무것도 없는 **가지**이고, undefined는 **잎**입니다 — 서로 다릅니다',
        en: 'Its own children. An empty array is a **branch** with nothing in it; undefined is a **leaf**. They are different things'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      description: {
        ko: '트리에는 있지만 고를 수 없고, 화살표 키의 정거장도 아닙니다',
        en: 'In the tree but not selectable, and not a stop for the arrow keys'
      }
    }
  ],
  PlGallery: [
    {
      name: 'items',
      type: 'readonly PlGalleryItem[]',
      required: true,
      description: { ko: '그릴 순서대로의 사진들', en: 'The pictures, in the order they are drawn' }
    },
    {
      name: 'layout',
      type: "'grid' | 'masonry' | 'justified' | 'quilted'",
      default: "'grid'",
      description: {
        ko: '타일을 어떻게 배치할지. 네 가지 답이 아니라 네 가지 질문입니다',
        en: 'How the tiles are arranged. Four questions rather than four looks'
      }
    },
    {
      name: 'columns',
      type: 'PlassResponsive<number>',
      default: '{ xs: 2, sm: 3, lg: 4 }',
      description: {
        ko: '가로로 몇 장인지, breakpoint마다. justified는 줄마다 스스로 정합니다',
        en: 'How many tiles across, per breakpoint. justified decides for itself, row by row'
      }
    },
    {
      name: 'gap',
      type: `${SIZE} | number | string`,
      default: "'md'",
      description: {
        ko: '타일 사이의 간격. 사다리의 한 단, 픽셀 수, 또는 CSS 길이',
        en: 'The space between tiles — a step of the size ladder, a number in pixels, or a CSS length'
      }
    },
    {
      name: 'ratio',
      type: 'number | string',
      default: '1',
      description: {
        ko: 'grid에서 타일의 모양이자, 자기 ratio가 없는 item이 다른 곳에서 쓰는 값',
        en: 'The shape of a tile in grid, and what an item with no ratio of its own falls back to'
      }
    },
    {
      name: 'rowHeight',
      type: 'number',
      default: '220',
      description: {
        ko: 'justified에서 한 줄이 지향하는 높이, quilted에서 한 칸의 높이',
        en: 'How tall a row aims to be in justified, and how tall one cell is in quilted'
      }
    },
    {
      name: 'rounded',
      type: 'boolean',
      default: 'true',
      description: { ko: '타일의 모서리를 둥글립니다', en: 'Rounds the tiles' }
    },
    {
      name: 'caption',
      type: "'none' | 'below' | 'overlay' | 'hover'",
      default: "'none'",
      description: {
        ko: '타일의 title과 description이 어디에 갈지. hover는 포인터와 함께 오는 overlay입니다',
        en: "Where a tile's title and description go. hover is overlay that arrives with the pointer"
      }
    },
    {
      name: 'hover',
      type: "'none' | 'lift' | 'dim' | 'zoom'",
      default: "'lift'",
      description: {
        ko: '포인터 아래에서 타일이 하는 일. zoom은 그대로 있는 프레임 안에서 사진만 움직입니다',
        en: 'What a tile does under the pointer. zoom moves the photograph inside a frame that stays put'
      }
    },
    {
      name: 'preview',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '타일을 누르면 사진을 원본 크기로 엽니다. viewer는 필요할 때만 받아 옵니다',
        en: 'Opens the picture full size when a tile is chosen. The viewer is fetched on demand'
      }
    },
    {
      name: 'onItemSelect',
      type: '(item: PlGalleryItem, index: number) => void',
      description: {
        ko: '타일을 골랐을 때. viewer가 있든 없든',
        en: 'Called when a tile is chosen, whether or not there is a viewer'
      }
    },
    {
      name: 'label',
      type: 'string',
      default: "'Gallery'",
      description: { ko: '목록의 접근성 이름', en: "The list's accessible name" }
    },
    {
      name: 'itemLabel',
      type: '(index: number, total: number) => string',
      default: '(i, n) => `${i} of ${n}`',
      description: {
        ko: '타일과 viewer의 카운터가 세트 안의 위치를 말하는 방식',
        en: 'How a tile and the viewer counter say where in the set they are'
      }
    },
    {
      name: 'empty',
      type: 'ReactNode',
      description: {
        ko: 'items가 비었을 때 그릴 것. 기본은 아무것도 그리지 않습니다',
        en: 'What is drawn when items is empty. Nothing at all by default'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: { ko: '타입 스케일과 모서리 반경', en: 'Type scale and radius' }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. focus ring과 placeholder에 닿습니다',
        en: 'Semantic colour role. It reaches the focus ring and the placeholders'
      }
    }
  ],
  PlGalleryItem: [
    {
      name: 'src',
      type: 'string',
      required: true,
      description: { ko: '사진의 주소', en: 'Where the picture is' }
    },
    {
      name: 'alt',
      type: 'string',
      required: true,
      description: {
        ko: '사진이 말하는 것. PlImage가 요구하는 이유와 같습니다',
        en: 'What the picture says. Required, for the reason PlImage requires it'
      }
    },
    {
      name: 'id',
      type: 'string',
      description: {
        ko: '안정적인 식별자. 기본은 src입니다',
        en: 'A stable identity. Defaults to src'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '캡션의 첫 줄', en: 'The first line of the caption' }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '두 번째 줄. 한 단 작고 muted입니다',
        en: 'The second, one step down the scale and muted'
      }
    },
    {
      name: 'full',
      type: 'string',
      description: {
        ko: 'viewer가 쓸 더 큰 파일. 없으면 src로 떨어집니다',
        en: 'A larger file for the viewer. Falls back to src'
      }
    },
    {
      name: 'ratio',
      type: 'number | string',
      description: {
        ko: '사진 자신의 비율. masonry와 justified가 이것으로, 아무것도 불러오기 전에 배치됩니다',
        en: "The picture's own proportion. masonry and justified are laid out from it, before anything has loaded"
      }
    },
    {
      name: 'cols',
      type: 'number',
      default: '1',
      description: {
        ko: 'quilted에서 차지하는 열 수',
        en: 'How many columns the tile takes in quilted'
      }
    },
    {
      name: 'rows',
      type: 'number',
      default: '1',
      description: {
        ko: 'quilted에서 차지하는 행 수',
        en: 'How many rows the tile takes in quilted'
      }
    }
  ],
  PlLineChart: [
    {
      name: 'series',
      type: 'readonly PlassChartSeries[]',
      required: true,
      description: { ko: '데이터', en: 'The data' }
    },
    {
      name: 'categories',
      type: 'readonly PlassChartCategory[]',
      description: {
        ko: 'category 축이 말하는 것. point가 직접 x를 지니지 않을 때',
        en: 'What the category axis says, when the points do not carry it themselves'
      }
    },
    {
      name: 'curve',
      type: "'linear' | 'smooth' | 'step'",
      default: "'linear'",
      description: {
        ko: '선이 다음 점으로 가는 방법. smooth는 monotone cubic이라 이웃 둘보다 낮은 값으로 내려가지 않습니다',
        en: 'How the line gets from one point to the next. smooth is a monotone cubic and will not dip below a value both neighbours are above'
      }
    },
    {
      name: 'markers',
      type: "'none' | 'auto' | 'all'",
      default: "'auto'",
      description: {
        ko: '점 위의 dot. auto는 열넷까지. 무엇이든 포인터 아래의 점에는 늘 붙습니다',
        en: 'Dots on the points. auto stops at fourteen; whatever this says, the point under the pointer always gets one'
      }
    },
    {
      name: 'connectNulls',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '빈 곳에서 끊지 않고 선을 통과시킵니다. 이어 붙인 공백은 차트가 지어낸 숫자입니다',
        en: 'Draws the line straight through a gap. A bridged gap is a number the chart made up'
      }
    },
    {
      name: 'valueLabels',
      type: "'none' | 'last' | 'extremes' | 'all'",
      default: "'none'",
      description: {
        ko: '선 위에 어떤 값을 적을지. last가 손이 가는 것입니다 — 각 series가 어디서 끝났는지',
        en: 'Which values are written on the line. last is the one to reach for — where each series ended up'
      }
    },
    {
      name: 'stacked',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'series를 쌓습니다. 선 차트에서는 드물고 두 번 생각할 일입니다',
        en: 'Stacks the series. Rare on a line chart and worth thinking twice about'
      }
    },
    {
      name: 'gradient',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '선을 자기 색의 옅은 단계에서 온전한 색으로 흐리게 합니다',
        en: 'Fades the line from a paler step of its own hue at the start to the full colour at the end'
      }
    },
    {
      name: 'xAxis',
      type: 'PlassChartAxis',
      description: { ko: 'category 축', en: 'The category axis' }
    },
    {
      name: 'yAxis',
      type: 'PlassChartAxis',
      description: { ko: '값 축', en: 'The value axis' }
    },
    {
      name: 'legend',
      type: 'PlassChartLegend',
      description: { ko: '범례', en: 'The legend' }
    },
    {
      name: 'tooltip',
      type: 'PlassChartTooltip',
      description: { ko: '툴팁', en: 'The tooltip' }
    },
    {
      name: 'height',
      type: 'number | string',
      description: {
        ko: 'plot의 높이. size 사다리로 떨어집니다',
        en: 'How tall the plot is. Falls back to the size ladder'
      }
    },
    {
      name: 'format',
      type: 'Intl.NumberFormatOptions',
      description: {
        ko: '값을 쓰는 방식. Intl에 그대로 넘어갑니다',
        en: 'How a value is written. Passed straight to Intl'
      }
    },
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: 'BCP 47 태그. 숫자와 날짜의 형식을 정합니다',
        en: 'BCP 47 tag deciding how numbers and dates are formatted'
      }
    },
    {
      name: 'label',
      type: 'string',
      default: "'Chart'",
      description: { ko: '그림 전체의 접근성 이름', en: 'What the whole drawing is called' }
    },
    {
      name: 'empty',
      type: 'ReactNode',
      description: {
        ko: '그릴 것이 없을 때 그리는 것',
        en: 'What is drawn when there is nothing to draw'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '타입 스케일, plot 높이, 선 굵기, marker 반지름',
        en: 'Type scale, plot height, line weight and marker radius'
      }
    },
    {
      name: 'variant',
      type: VARIANT,
      default: "'ghost'",
      shared: true,
      description: {
        ko: '차트가 놓인 시트. 기본은 없음 — 차트는 시트가 아니라 그림입니다',
        en: 'The sheet the chart sits on. None by default: a chart is a drawing, not a sheet'
      }
    }
  ],
  PlassChartSeries: [
    {
      name: 'data',
      type: 'readonly PlassChartDatum[]',
      required: true,
      description: { ko: 'category 순서대로의 값들', en: 'The values, in category order' }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '범례·툴팁·표에서의 이름',
        en: 'Its name in the legend, the tooltip and the data table'
      }
    },
    {
      name: 'color',
      type: `${COLOR} | (string & {})`,
      description: {
        ko: '팔레트 자리를 덮어씁니다. 라이브러리에서 색이 의미 역할이 아닌 유일한 곳입니다',
        en: 'Overrides the palette slot. The one place in the library where a colour is not a semantic role'
      }
    },
    {
      name: 'hidden',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '꺼진 채로 시작합니다. 상호작용하는 범례가 다시 켭니다',
        en: 'Starts the series hidden. An interactive legend is what turns it back on'
      }
    }
  ],
  PlCodeBlock: [
    {
      name: 'code',
      type: 'string',
      required: true,
      description: {
        ko: '코드. 블록 끝의 공백은 잘라 냅니다',
        en: 'The code. Trailing whitespace is trimmed off the end of the block'
      }
    },
    {
      name: 'language',
      type: 'string',
      description: {
        ko: '무엇으로 쓰였는지 — ts, dart, bash, yml. 흔한 표기와 확장자를 알아듣습니다',
        en: 'What it is written in — ts, dart, bash, yml. The common spellings and file extensions are understood'
      }
    },
    {
      name: 'theme',
      type: "'dark' | 'light' | 'auto' | 'mono' | (string & {})",
      default: "'dark'",
      description: {
        ko: '팔레트. auto를 빼면 페이지의 명암과 무관합니다. 등록되지 않은 이름도 받습니다',
        en: "The palette. Independent of the page's light and dark, except on auto. Any other string works too"
      }
    },
    {
      name: 'highlight',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '코드에 색을 입힙니다. 끄면 문법 엔진을 아예 받아 오지 않습니다',
        en: 'Colours the code. Off, the grammar engine is not fetched at all'
      }
    },
    {
      name: 'toolbar',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '코드 위의 바. 끄면 showLanguage·copyable·rawToggle이 무엇을 말하든 아무것도 그리지 않습니다',
        en: 'The bar over the code, and the master switch for showLanguage, copyable and rawToggle'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '바 앞쪽의 이름. 보통 파일 경로입니다',
        en: 'A name at the start of the bar — a file path, usually'
      }
    },
    {
      name: 'showLanguage',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '바에 언어 이름을 적습니다',
        en: 'Names the language at the start of the bar'
      }
    },
    {
      name: 'copyable',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '코드를 클립보드에 올리는 버튼',
        en: 'The button that puts the code on the clipboard'
      }
    },
    {
      name: 'rawToggle',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '색을 걷어 내고 문자 그대로 보여 주는 토글',
        en: 'The toggle that drops the colouring and shows the characters as they are'
      }
    },
    {
      name: 'highlightLines',
      type: 'number | string | Array<number | string>',
      description: {
        ko: "표시할 줄. 4, '4-9', '1,4-9,12'. gutter가 세는 방식으로 셉니다",
        en: "Lines to mark: 4, '4-9', '1,4-9,12'. Counted the way the gutter counts"
      }
    },
    {
      name: 'lineNumbers',
      type: 'boolean',
      default: 'false',
      description: { ko: '옆에 줄 번호를 붙입니다', en: 'Numbers down the side' }
    },
    {
      name: 'startLine',
      type: 'number',
      default: '1',
      description: { ko: '첫 줄의 번호', en: 'What the first line is numbered' }
    },
    {
      name: 'prompt',
      type: 'string',
      description: {
        ko: '내용이 있는 모든 줄 앞의 셸 프롬프트 — $, #, >>>. 그려지지만 복사되지는 않습니다',
        en: 'A shell prompt in front of every line that has something on it. Drawn but never copied'
      }
    },
    {
      name: 'wrap',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '긴 줄을 옆으로 흘리는 대신 접습니다',
        en: 'Wraps long lines instead of scrolling them sideways'
      }
    },
    {
      name: 'maxHeight',
      type: 'number | string',
      description: {
        ko: '이 높이를 넘으면 안에서 스크롤합니다. 숫자는 픽셀',
        en: 'How tall the block may get before the code scrolls inside it. A number is pixels'
      }
    },
    {
      name: 'fontFamily',
      type: 'string',
      description: {
        ko: '서체. 기본은 페이지의 monospace',
        en: "The typeface. Defaults to the page's own monospace stack"
      }
    },
    {
      name: 'fontSize',
      type: 'number | string',
      description: {
        ko: 'size 사다리가 고른 크기를 덮어씁니다',
        en: 'Overrides the size the size ladder chose'
      }
    },
    {
      name: 'lineHeight',
      type: 'number | string',
      description: {
        ko: '행간. 맨 숫자는 CSS처럼 비율입니다',
        en: 'Overrides the leading. A bare number is a ratio, as in CSS'
      }
    },
    {
      name: 'letterSpacing',
      type: 'number | string',
      description: { ko: '자간', en: 'Tracking' }
    },
    {
      name: 'copyLabel',
      type: 'string',
      default: "'Copy'",
      description: { ko: '복사 버튼의 말', en: "The copy button's label" }
    },
    {
      name: 'copiedLabel',
      type: 'string',
      default: "'Copied'",
      description: {
        ko: '클립보드가 받은 뒤의 말',
        en: 'And what it says once the code is on the clipboard'
      }
    },
    {
      name: 'copyFailedLabel',
      type: 'string',
      default: "'Could not copy'",
      description: {
        ko: '클립보드가 거절했을 때의 말',
        en: 'And what it says when the clipboard refused'
      }
    },
    {
      name: 'rawLabel',
      type: 'string',
      default: "'Raw'",
      description: { ko: 'raw 토글의 말', en: "The raw toggle's label" }
    },
    {
      name: 'codeLabel',
      type: 'string',
      default: "'Code'",
      description: {
        ko: 'title도 language도 없을 때 영역의 이름',
        en: 'What the region is called when there is neither a title nor a language'
      }
    },
    {
      name: 'onCopy',
      type: '(code: string) => void',
      description: {
        ko: '클립보드가 코드를 받은 뒤 그 코드와 함께 호출됩니다',
        en: 'Fires with the copied text once the clipboard has taken it'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '타입 스케일과 코드 주변의 여백',
        en: 'The type scale and the air around the code'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. focus ring에만 닿습니다 — 블록 자체는 일부러 색 계열을 거부합니다',
        en: 'Semantic colour role. It reaches the focus ring and nothing else — the block itself refuses the family on purpose'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: '코드 주변의 여백. 타입 스케일은 아닙니다',
        en: 'The air around the code. Never the type scale'
      }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      default: '0',
      shared: true,
      description: { ko: '그림자 깊이. 0은 평평합니다', en: 'Drop shadow depth. 0 is flat' }
    }
  ],
  PlTreeSelect: [
    {
      name: 'items',
      type: 'readonly PlTreeSelectNode[]',
      required: true,
      description: { ko: '트리 전체를 데이터로', en: 'The whole tree, as data' }
    },
    {
      name: 'value',
      type: 'readonly string[]',
      description: {
        ko: '고른 node의 id들. 제어하려면 onValueChange와 함께',
        en: 'The ids of the chosen nodes. Use with onValueChange to control the picker'
      }
    },
    {
      name: 'defaultValue',
      type: 'readonly string[]',
      description: { ko: '처음부터 골라져 있을 것', en: 'What starts chosen' }
    },
    {
      name: 'onValueChange',
      type: '(value: string[]) => void',
      description: { ko: '고른 것이 바뀌었을 때', en: 'Called when the selection changes' }
    },
    {
      name: 'multiple',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '한 번에 둘 이상을 쥘 수 있는지',
        en: 'Whether more than one node may be held at once'
      }
    },
    {
      name: 'selectableBranches',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '자식이 있는 node도 고를 수 있는지. node의 selectable이 어느 쪽으로든 덮어씁니다',
        en: "Whether a node with children may itself be chosen. A node's own selectable overrides it either way"
      }
    },
    {
      name: 'expanded',
      type: 'readonly string[]',
      description: {
        ko: '열려 있는 가지의 id들. 제어하려면 onExpandedChange와 함께',
        en: 'The ids of the branches that are open. Use with onExpandedChange to control them'
      }
    },
    {
      name: 'defaultExpanded',
      type: 'readonly string[]',
      description: { ko: '처음부터 열려 있을 가지들', en: 'The branches that start open' }
    },
    {
      name: 'onExpandedChange',
      type: '(expanded: string[]) => void',
      description: { ko: '가지가 열리거나 닫혔을 때', en: 'Called when a branch opens or closes' }
    },
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
      default: '!multiple',
      description: {
        ko: 'node를 고르자마자 팝업을 닫을지',
        en: 'Closes the popup as soon as a node is chosen'
      }
    },
    {
      name: 'searchable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '트리 위에 걸러 내는 field를 둡니다. 맞은 node는 조상을 데리고 남습니다',
        en: 'Offers a field above the tree that filters it. A match keeps its ancestors'
      }
    },
    {
      name: 'searchLabel',
      type: 'string',
      default: "'Search'",
      description: { ko: '거르는 field에 적히는 말', en: 'The word in the filter field' }
    },
    {
      name: 'emptyLabel',
      type: 'string',
      default: "'Nothing here'",
      description: {
        ko: '아무것도 걸리지 않았을 때 팝업이 하는 말',
        en: 'What the popup says when the filter matched nothing'
      }
    },
    {
      name: 'format',
      type: '(chosen: PlTreeSelectNode[]) => ReactNode',
      description: {
        ko: 'trigger가 쥔 것을 쓰는 방식. 기본은 label을 쉼표로 이은 것',
        en: 'How the trigger writes what is held. Defaults to the labels, comma-joined'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 제출에서 field를 식별합니다. 값 하나당 hidden input 하나',
        en: 'Identifies the field when a form is submitted. One hidden input per value'
      }
    },
    ...sharedProps({
      variant: "'glass'",
      size: "'md'",
      variantDescription: {
        ko: 'trigger의 재질. PlTextField와 같은 껍데기를 씁니다',
        en: "The material of the trigger, drawn on PlTextField's shell"
      },
      elevationDescription: {
        ko: 'trigger의 그림자 깊이. 팝업은 3으로 고정입니다',
        en: 'Drop shadow depth of the trigger. The popup has its own, fixed at 3'
      }
    }),
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
      description: { ko: '값 앞의 글리프', en: 'The glyph before the value' }
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
    }
  ],
  PlTreeSelectNode: [
    {
      name: 'id',
      type: 'string',
      required: true,
      description: {
        ko: '트리 전체에서 유일한 식별자',
        en: 'What identifies it, unique across the whole tree'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      required: true,
      description: { ko: '행이 말하는 것', en: 'What the row says' }
    },
    {
      name: 'searchLabel',
      type: 'string',
      description: {
        ko: '검색이 대조하는 문자열. label이 문자열이면 그것으로, 아니면 id로 떨어집니다',
        en: 'What a search matches against. Falls back to the label when that is a string, and to the id when it is not'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: { ko: 'label 앞의 글리프', en: 'A glyph before the label' }
    },
    {
      name: 'children',
      type: 'readonly PlTreeSelectNode[]',
      description: {
        ko: '자식들. 빈 배열은 아무것도 없는 **가지**이고, undefined는 **잎**입니다',
        en: 'Its own children. An empty array is a **branch** with nothing in it; undefined is a **leaf**'
      }
    },
    {
      name: 'selectable',
      type: 'boolean',
      description: {
        ko: '이 node 자체를 고를 수 있는지. 잎은 true, 가지는 selectableBranches를 따릅니다',
        en: 'Whether this node may itself be chosen. Defaults to true for a leaf and to selectableBranches for a branch'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      description: {
        ko: '트리에는 있지만 고를 수 없고, 화살표 키의 정거장도 아닙니다',
        en: 'In the tree but not selectable, and not a stop for the arrow keys'
      }
    }
  ],
  PlImage: [
    { name: 'src', type: 'string', description: { ko: '사진의 주소', en: 'Where the picture is' } },
    {
      name: 'alt',
      type: 'string',
      required: true,
      description: {
        ko: '스크린 리더가 읽는 설명. ""는 장식이라는 진짜 답입니다',
        en: 'The description a screen reader reads. "" is a real answer — it marks the picture decorative'
      }
    },
    {
      name: 'ratio',
      type: 'number | string',
      description: {
        ko: '도착하기 전까지 지킬 비율. CSS가 쓰는 그대로. 이것이 자리를 잡아 둡니다',
        en: 'The proportion the box holds while the picture is on its way. This is what reserves the space'
      }
    },
    {
      name: 'fit',
      type: "'cover' | 'contain' | 'fill' | 'none'",
      default: "'cover'",
      description: { ko: '사진을 상자에 어떻게 맞출지', en: 'How the picture is fitted to the box' }
    },
    {
      name: 'rounded',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '모서리를 size 단계의 하우스 반경으로 깎습니다',
        en: 'Rounds the corners to the size step of the house ladder'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: { ko: 'rounded가 쓰는 반경 단계', en: 'Which radius step rounded uses' }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: 'skeleton과 focus ring의 색 역할',
        en: 'The family the skeleton and the focus ring take'
      }
    },
    {
      name: 'placeholder',
      type: 'ReactNode',
      description: {
        ko: '로딩 중에 그릴 것. 기본은 PlSkeleton이고 null은 아무것도 그리지 않습니다',
        en: 'What is drawn while loading. A PlSkeleton by default; null draws nothing'
      }
    },
    {
      name: 'fallback',
      type: 'ReactNode',
      description: {
        ko: '도착하지 않았을 때 그릴 것. 기본은 alt 텍스트입니다',
        en: 'What is drawn when the picture does not arrive. The alt text by default'
      }
    },
    {
      name: 'preview',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '누르면 사진을 페이지 위로 엽니다',
        en: 'Opens the picture over the page when it is pressed'
      }
    },
    {
      name: 'previewLabel',
      type: 'string',
      default: "'Preview'",
      description: {
        ko: '미리 보기 오버레이의 accessible name',
        en: 'The accessible name of the preview overlay'
      }
    },
    {
      name: 'onStatusChange',
      type: "(status: 'loading' | 'loaded' | 'error') => void",
      description: {
        ko: '도착했을 때, 그리고 실패했을 때',
        en: 'Called when the picture has loaded, and when it has failed'
      }
    }
  ],
  PlEmpty: [
    {
      name: 'icon',
      type: 'ReactNode',
      description: {
        ko: '글자 위의 글리프나 그림. size에 맞춰 크기가 정해집니다',
        en: 'The glyph or drawing above the words. Sized off size'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '무엇이 없는지 말하는 한 줄',
        en: 'The one line that says what is not here'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '그것에 대해 무엇을 할지. 한두 문장이지 문단이 아닙니다',
        en: 'What to do about it. One or two sentences, never a paragraph'
      }
    },
    {
      name: 'actions',
      type: 'ReactNode',
      description: {
        ko: '빠져나갈 길 — 보통 PlButton 하나',
        en: 'The way out — usually one PlButton'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '글리프 · 타입 스케일 · 주위 공간',
        en: 'Glyph, type scale and the space around it'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'secondary'",
      shared: true,
      description: {
        ko: '글리프의 색 역할. secondary는 아직 없음, danger는 잘못됨, success는 끝남',
        en: 'The family the glyph takes. secondary is nothing yet, danger is something went wrong, success is you are done'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '세로 여백만 바꿉니다', en: 'The vertical padding, and nothing else' }
    }
  ],
  PlPopconfirm: [
    {
      name: 'trigger',
      type: 'ReactElement',
      required: true,
      description: {
        ko: '이것을 여는 element. 원래 갖고 있던 것은 그대로 유지합니다',
        en: 'What opens it. The element keeps everything it already had'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '질문. popup에 이름을 주는 제목입니다',
        en: 'The question, as the heading that names the popup'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '아래 한 줄. 무슨 일이 일어나는지 쓰세요',
        en: 'A line under it. Say what happens'
      }
    },
    {
      name: 'confirmLabel',
      type: 'ReactNode',
      default: "'Confirm'",
      description: {
        ko: '예라고 답하는 버튼의 문구',
        en: 'The word on the button that answers yes'
      }
    },
    {
      name: 'cancelLabel',
      type: 'ReactNode',
      default: "'Cancel'",
      description: {
        ko: '아니오라고 답하는 버튼의 문구',
        en: 'The word on the button that answers no'
      }
    },
    {
      name: 'onConfirm',
      type: '() => void | Promise<unknown>',
      description: {
        ko: '확인이 하는 일. promise는 기다립니다 — resolve될 때만 popup이 닫히고, reject는 잡혀서 더 가지 않습니다',
        en: 'What confirming does. A promise is waited for — the popup closes only if it resolves, and a rejection is caught and goes no further'
      }
    },
    {
      name: 'onCancel',
      type: '() => void',
      description: { ko: '취소가 닫는 것 말고 하는 일', en: 'What cancelling does, beyond closing' }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'danger'",
      shared: true,
      description: { ko: '확인 버튼의 색 역할', en: 'The family the confirming button takes' }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: { ko: 'popup과 두 버튼의 크기', en: 'The size of the popup and its two buttons' }
    },
    {
      name: 'side',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'top'",
      shared: true,
      description: {
        ko: 'trigger의 어느 가장자리에 열릴지',
        en: 'Which edge of the trigger it opens against'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      shared: true,
      description: { ko: '그 가장자리 위 어디에 놓일지', en: 'Where it sits along that edge' }
    },
    {
      name: 'width',
      type: 'number | string',
      default: '280',
      description: { ko: '시트가 커질 수 있는 최대 너비', en: 'How wide the sheet may get' }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: 'popup이 열려 있는지. 제어하려면 onOpenChange와 함께',
        en: 'The popup is open. Use with onOpenChange for a controlled one'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      description: {
        ko: '제어하지 않을 때 열린 채 시작할지',
        en: 'Whether it starts open, for an uncontrolled one'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫혔을 때', en: 'Called when it opens or closes' }
    }
  ],
  PlBackTop: [
    {
      name: 'target',
      type: 'Window | HTMLElement | RefObject<HTMLElement | null> | (() => Window | HTMLElement | null)',
      default: 'window',
      description: {
        ko: '무엇을 스크롤할지. 페이지 안에서 스크롤되는 패널에는 ref를 주세요',
        en: 'What is scrolled. A ref for a panel that scrolls inside the page'
      }
    },
    {
      name: 'visibilityHeight',
      type: 'number',
      default: '400',
      description: {
        ko: '나타나기 전까지 얼마나 내려가야 하는지, 픽셀로. 노트북에서 대략 한 화면입니다',
        en: 'How far down the reader has to be before it appears, in pixels. Roughly one screen on a laptop'
      }
    },
    {
      name: 'label',
      type: 'string',
      default: "'Back to top'",
      description: {
        ko: '무엇을 하는지, 말로. accessible name입니다',
        en: 'What it does, in words, and its accessible name'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: {
        ko: '글리프. 기본은 위쪽 chevron입니다',
        en: 'The glyph. An upward chevron by default'
      }
    },
    {
      name: 'floating',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '창의 아래 구석에 스스로 고정할지',
        en: 'Whether it pins itself to the bottom corner of the window'
      }
    },
    {
      name: 'variant',
      type: VARIANT,
      default: "'glass'",
      shared: true,
      description: { ko: '표면의 재질', en: 'What the surface is made of' }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: { ko: '디스크의 크기', en: 'The size of the disc' }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: { ko: '의미론적 색 역할', en: 'Semantic colour role' }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      default: '2',
      shared: true,
      description: { ko: '그림자 깊이', en: 'Drop shadow depth' }
    }
  ],
  PlStack: [
    {
      name: 'direction',
      type: "PlassResponsive<'horizontal' | 'vertical' | 'diagonal'>",
      default: "'horizontal'",
      description: {
        ko: '더미가 자라는 방향. diagonal은 진짜 45°가 아니라 부채꼴입니다 — 가로 전진량은 항목 너비에서 overlap을 뺀 값인데, 임의의 자식을 받는 컴포넌트는 그 너비를 모릅니다',
        en: 'Which way the pile grows. diagonal is a fan rather than a true 45°: the horizontal advance is the item width less the overlap, and a component that takes arbitrary children does not know that width'
      }
    },
    {
      name: 'overlap',
      type: 'number | string',
      default: 'a fraction of size',
      description: {
        ko: '흐르는 축에서 각 항목이 앞 항목 아래로 들어가는 거리 — 픽셀 숫자 또는 CSS 길이',
        en: 'How far each item sits under the one before it, along the axis the pile flows on — a number of pixels or any CSS length'
      }
    },
    {
      name: 'drop',
      type: 'number | string',
      default: 'whatever overlap resolved to',
      description: {
        ko: 'diagonal에서만 쓰이는, 흐르지 않는 축의 낙차',
        en: 'The step on the other axis, for direction="diagonal" only'
      }
    },
    {
      name: 'size',
      type: "'xs' | 'sm' | 'md' | 'lg' | 'xl'",
      default: "'md'",
      shared: true,
      description: {
        ko: '기본 overlap이 어느 칸에서 나오는지. 그 외에는 아무것도 정하지 않습니다 — 더미는 자기 표면도 글자도 없습니다',
        en: 'Which rung the default overlap comes off. It decides nothing else: a pile draws no surface of its own and has no type in it'
      }
    },
    {
      name: 'max',
      type: 'number',
      description: {
        ko: '그리는 개수. 빼면 전부 그립니다',
        en: 'How many items are drawn. Left out, every one of them is'
      }
    },
    {
      name: 'total',
      type: 'number',
      description: {
        ko: '앞의 몇 개만 넘겼을 때의 전체 개수. 없으면 자식 수로 셉니다',
        en: 'How many there are altogether, when the pile was handed only the first few'
      }
    },
    {
      name: 'overflow',
      type: '(hidden: number) => ReactNode',
      description: {
        ko: '넘친 개수를 받아 맨 뒤 항목을 만듭니다. 노드가 아니라 함수인 이유는 그 숫자가 곧 항목이기 때문입니다',
        en: 'Draws a last item standing for the ones that did not fit, given how many that is. A function rather than a node, because the number is the item'
      }
    },
    {
      name: 'front',
      type: "'first' | 'last'",
      default: "'last'",
      description: {
        ko: '어느 쪽 끝이 맨 위인지. last는 DOM이 스스로 하는 답이고 얼굴 줄이 원하는 것, first는 카드 덱입니다',
        en: 'Which end of the list is on top. last is what the DOM does on its own and what a row of faces wants; first is what a deck of cards is'
      }
    },
    {
      name: 'scaleStep',
      type: 'number',
      default: '1',
      description: {
        ko: '뒤로 갈수록 곱해지는 배율. 독립 scale 속성에 실리므로 caller가 건 transform이 살아남습니다',
        en: 'What each item further back is multiplied by, compounding. On the standalone scale property, so a caller’s own transform survives'
      }
    },
    {
      name: 'opacityStep',
      type: 'number',
      default: '1',
      description: { ko: '투명도에 대한 같은 값', en: 'The same, for opacity' }
    },
    {
      name: 'ring',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '각 항목 둘레에 페이지 표면색 실선을 그립니다. 넘긴 요소 자신에 걸리므로 그 요소의 모양을 따릅니다',
        en: 'Draws a hairline of the page’s own surface colour around each item. It lands on the element you passed, so it takes that element’s shape'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '더미에 쌓이는 것들', en: 'The things in the pile' }
    }
  ],
  PlStat: [
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '무엇의 숫자인지. 위의 줄입니다',
        en: 'What the figure is of. The line above it'
      }
    },
    {
      name: 'value',
      type: 'ReactNode',
      description: {
        ko: '이미 서식이 정해진 숫자 그 자체. 숫자 타입이 아닌 이유는 통화 · 자릿수 · 소수점 · 로케일이 페이지의 결정이기 때문입니다',
        en: "The figure itself, already formatted. A node rather than a number, because the currency, grouping, decimals and locale are the page's decision"
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '숫자 아래 한 줄. 보통 무엇과 비교했는지',
        en: 'A line under the figure. What it is compared with, usually'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: { ko: 'label 옆의 글리프', en: 'A glyph beside the label' }
    },
    {
      name: 'change',
      type: 'number',
      description: {
        ko: '얼마나 움직였는지, 퍼센트로. 화살표와 함께 그려지고, 부호가 아니라 좋은 소식인지로 색이 정해집니다',
        en: 'How much it moved, as a percentage. Drawn with an arrow, and coloured by whether that is good news rather than by its sign'
      }
    },
    {
      name: 'changeLabel',
      type: 'ReactNode',
      description: {
        ko: '퍼센트 대신 변화가 말할 것. 비율이 아니라 개수로 움직인 숫자를 위한 것',
        en: 'What the change says instead of the formatted percentage. For a figure that moved by a count'
      }
    },
    {
      name: 'improvesWhen',
      type: "'up' | 'down'",
      default: "'up'",
      description: {
        ko: '어느 쪽이 좋은 소식인지. 이탈률 · 지연 시간 · 비용에는 down',
        en: 'Which way is good news. down for churn, latency and cost'
      }
    },
    {
      name: 'loading',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '숫자가 올 자리에 skeleton을 그립니다',
        en: 'Draws a skeleton where the figure will be'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '숫자와 그 주위 글자의 타입 스케일',
        en: 'The type scale of the figure and the words around it'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: { ko: '아이콘이 쓰는 색 역할', en: 'The family the icon takes' }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: '세 줄 사이의 간격만 바꿉니다',
        en: 'The space between the three lines, and nothing else'
      }
    }
  ],
  PlVisuallyHidden: [
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '읽히되 그려지지는 않을 내용',
        en: 'What is read out and drawn nowhere'
      }
    },
    {
      name: 'focusable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '안쪽 어딘가가 focus를 쥐고 있는 동안 내용을 flow로 되돌립니다. skip link를 위한 것입니다',
        en: 'Brings the content back into the flow while anything inside holds the focus. For a skip link'
      }
    },
    {
      name: 'render',
      type: 'RenderProp',
      description: {
        ko: '<span> 대신 다른 요소로 렌더링합니다 (<div />, <h2 />)',
        en: 'Renders something other than a <span> (<div />, <h2 />)'
      }
    },
    {
      name: 'className',
      type: 'string',
      description: {
        ko: '컴포넌트 자신의 클래스와 나란히 놓입니다',
        en: 'Sits alongside the component’s own classes'
      }
    }
  ]
};
