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

/**
 * The same five axes for a widget a `PlButtonGroup` may answer for.
 *
 * Nullable, because `null` has to be distinguishable from a value: it means the
 * widget did not state the axis, so the run above it does, and the default
 * named in the `default` column is only what is left when neither did.
 */
function groupedAxes(component: string, options: { elevation: string }): PropRow[] {
  return [
    from(component, 'variant', { type: `${VARIANT}?`, default: 'PlassVariant.solid' }),
    from(component, 'size', { type: `${SIZE}?`, default: 'PlassSize.md' }),
    from(component, 'color', { type: `${COLOR}?`, default: 'PlassColor.primary' }),
    from(component, 'density', { type: `${DENSITY}?`, default: 'PlassDensity.standard' }),
    from(component, 'elevation', { type: 'int?', default: options.elevation })
  ];
}

/** What a key cap and the strip of them are both made of. */
const capProps: PropRow[] = [
  from('PlKbd', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
  from('PlKbd', 'size', { type: SIZE, default: 'PlassSize.md' }),
  {
    name: 'color',
    type: COLOR,
    default: 'PlassColor.secondary',
    shared: true,
    description: { ko: '의미론적 색 역할', en: 'Semantic colour role' }
  },
  from('PlKbd', 'density', { type: DENSITY, default: 'PlassDensity.compact' }),
  {
    name: 'elevation',
    type: 'int',
    default: '0',
    shared: true,
    description: {
      ko: '그림자 깊이. 0이 기본입니다 — 키캡에는 이미 립이 있고, 페이지에서 띄우기까지 하면 깊이 단서가 하나 많습니다',
      en: 'Drop shadow depth. 0 is the default: a key cap already has a lip under it, and raising it off the page as well is one depth cue too many'
    }
  }
];

/**
 * The one prop on the indicators that could not cross.
 *
 * React's `format` is an `Intl.NumberFormatOptions`; there is no
 * `Intl.NumberFormat` in the framework to hand options to, and a package that
 * pulled `package:intl` in to provide one would be making a dependency decision
 * on its consumer's behalf. So the Dart side takes the function instead — and it
 * is written out here rather than derived, because there is no React row to
 * derive it from.
 */
const formatValueProp: PropRow = {
  name: 'formatValue',
  type: 'String Function(double value)?',
  description: {
    ko: '값을 어떻게 쓸지. React의 format 옵션 객체 대신 함수를 받습니다 — 프레임워크에 Intl.NumberFormat이 없고, 그것 때문에 package:intl을 끌어오는 건 소비자 대신 의존성을 정하는 일이기 때문입니다',
    en: "How to write the value, as a function rather than React's options object: there is no Intl.NumberFormat in the framework, and pulling package:intl in to provide one would be a dependency decision made on the consumer's behalf"
  }
};

/**
 * The picker parameters with no React counterpart at all.
 *
 * `names` and `formatValue` are the localisation trade — there is no `Intl` in
 * the framework, so the words and the format arrive as an object and a callback
 * — and the last three are what every Flutter widget takes and no DOM element
 * needs. `from()` cannot derive a row that does not exist over there, so these
 * are written out once and shared by the pickers.
 */
const pickerWordProps: PropRow[] = [
  {
    name: 'names',
    type: 'PlDateNames',
    default: 'PlDateNames.english',
    description: {
      ko: '달력이 그리는 월과 요일 이름, 그리고 헤더가 그것들을 쓰는 순서. **React의 locale 문자열에 해당합니다** — 프레임워크에 Intl이 없으므로 단어를 객체로 받습니다',
      en: 'The month and weekday names the calendar draws, and the order the header writes them in. **This is what a locale string is in the React build**: there is no Intl in the framework, so the words arrive as an object'
    }
  },
  {
    name: 'formatValue',
    type: 'String Function(DateTime value)?',
    description: {
      ko: 'trigger가 값을 쓰는 방식. React의 Intl 옵션 대신 콜백입니다. 빼면 names의 medium 형식으로 씁니다',
      en: "How the trigger writes the value. A callback rather than React's Intl options; without it it is written out of names in its medium form"
    }
  }
];

/** What every Flutter widget takes and no DOM element needs. */
const pickerHandleProps: PropRow[] = [
  {
    name: 'semanticLabel',
    type: 'String?',
    description: {
      ko: '보이는 label이 없는 trigger를 스크린 리더가 부를 이름',
      en: 'The name a screen reader gives a trigger with no visible label'
    }
  },
  {
    name: 'focusNode',
    type: 'FocusNode?',
    description: { ko: '포커스를 밖에서 제어할 때 넘깁니다', en: 'Drive focus from outside' }
  },
  {
    name: 'autofocus',
    type: 'bool',
    default: 'false',
    description: {
      ko: '트리에 들어가면서 포커스를 가져갑니다',
      en: 'Takes focus as it is inserted into the tree'
    }
  }
];

/** The clock columns' parameters, shared by the two pickers that draw one. */
function timeColumnProps(component: string): PropRow[] {
  return [
    {
      name: 'hour12',
      type: 'bool',
      default: 'false',
      description: {
        ko: 'AM/PM 열이 붙은 12시간 다이얼. React가 locale에서 가져오는 자리에서 여기서는 그냥 false입니다 — 물어볼 Intl이 없고, 켰을 때 쓰는 말은 PlDateNames의 am/pm입니다',
        en: 'A 12-hour dial with an AM/PM column. A plain false where React takes it from the locale: there is no Intl here to ask, and the words it uses when on are PlDateNames.am and .pm'
      }
    },
    from(component, 'showSeconds', { type: 'bool', default: 'false' }),
    from(component, 'hourStep', { type: 'int', default: '1' }),
    from(component, 'minuteStep', { type: 'int', default: '1' }),
    from(component, 'secondStep', { type: 'int', default: '1' }),
    from(component, 'shouldDisableTime', {
      type: 'bool Function(DateTime value, PlassTimeUnit unit)?'
    })
  ];
}

/**
 * The nine settings every `PlAnimate*` widget takes, under Dart's names.
 *
 * Written once for the reason `animateProps` is on the React side, and it says
 * only what differs: `Duration` for the two times, `Curve` for the easing, and
 * an `int?` for the repeat, where `null` is what never stops.
 */
function animateFlutterProps(
  component: string,
  options: { duration: string; repeat?: string; omit?: string[] }
): PropRow[] {
  // Built from a list of names rather than filtered afterwards, because `from`
  // throws on a React prop that is not there — and a prop this widget genuinely
  // does not take is not there on the React side either.
  const patches: Record<string, Partial<PropRow>> = {
    duration: { type: 'Duration', default: options.duration },
    delay: { type: 'Duration', default: 'Duration.zero' },
    easing: { name: 'curve', type: 'Curve?', default: 'the house curve' },
    repeat: {
      type: 'int?',
      default: options.repeat ?? '1',
      description: {
        ko: "몇 번 반복할지. null이 멈추지 않음을 뜻합니다 — 적을 'infinite'가 없고, -1은 찾아봐야 하는 sentinel입니다",
        en: "How many times it runs. null is what never stops: there is no 'infinite' to write, and -1 would be a sentinel a caller has to look up"
      }
    },
    alternate: { type: 'bool', default: 'false' },
    paused: { type: 'bool', default: 'false' },
    trigger: { type: 'PlassAnimateTrigger', default: 'PlassAnimateTrigger.mount' },
    play: { type: 'bool', default: 'false' },
    once: { type: 'bool', default: 'true' },
    threshold: { type: 'double', default: '0.2' }
  };

  return Object.entries(patches)
    .filter(([name]) => !options.omit?.includes(name))
    .map(([name, patch]) => from(component, name, patch));
}

/**
 * The chord map a field takes.
 *
 * One row rather than five, for the reason the React table's is: a reader who
 * has learned what `hotKeys` does on a text field must not have to read a
 * subtly different sentence about it on a combobox.
 */
const hotKeysProp: PropRow = from('PlTextField', 'hotKeys', {
  type: 'PlassHotKeys?'
});

export const flutterPropTables: Record<string, PropRow[]> = {
  PlAccordion: [
    from('PlAccordion', 'children', {
      name: 'items',
      type: 'List<PlAccordionItem<T>>',
      required: true,
      description: {
        ko: '섹션들. children이 아니라 설명의 목록입니다 — accordion이 무엇이 열려 있고 사이의 선이 어디 가는지를 알아야 합니다',
        en: 'The sections, as a list of descriptions rather than children — the accordion has to know what is open and where the rules go'
      }
    }),
    from('PlAccordion', 'value', {
      type: 'Set<T>',
      required: true,
      description: {
        ko: '열려 있는 섹션. multiple이 꺼져 있어도 집합입니다 — 닫힌 상태는 빈 집합입니다',
        en: 'Which sections are open. A set even with multiple off — closed is the empty one'
      }
    }),
    from('PlAccordion', 'onValueChange', {
      name: 'onChanged',
      type: 'ValueChanged<Set<T>>?',
      description: {
        ko: '다음에 열려 있어야 할 집합으로 호출됩니다. 주지 않으면 열린 상태 그대로 굳습니다',
        en: 'Called with the set that should be open next. Leaving it out freezes the accordion'
      }
    }),
    from('PlAccordion', 'multiple', { type: 'bool', default: 'false' }),
    from('PlAccordion', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlAccordion', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlAccordion', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlAccordion', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlAccordion', 'elevation', { type: 'int', default: '0' }),
    from('PlAccordion', 'dividers', { type: 'bool', default: 'true' }),
    from('PlAccordion', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlAccordionItem: [
    from('PlAccordionItem', 'value', {
      type: 'T',
      required: true,
      description: {
        ko: 'PlAccordion.value가 이 섹션을 가리키는 이름',
        en: 'Identifies the section. What PlAccordion.value holds'
      }
    }),
    from('PlAccordionItem', 'title', { type: 'Widget?' }),
    from('PlAccordionItem', 'subtitle', { type: 'Widget?' }),
    from('PlAccordionItem', 'startIcon', { type: 'Widget?' }),
    from('PlAccordionItem', 'action', {
      type: 'Widget?',
      description: {
        ko: '헤더 끝, chevron 앞에 고정되는 컨트롤. 접히는 부분 바깥이라 버튼을 넣어도 됩니다',
        en: 'A control pinned to the end of the header, before the chevron. It sits outside the fold, so a button is safe there'
      }
    }),
    from('PlAccordionItem', 'truncate', { type: 'bool', default: 'false' }),
    from('PlAccordionItem', 'disabled', { type: 'bool', default: 'false' }),
    from('PlAccordionItem', 'children', { name: 'child', type: 'Widget?' })
  ],

  PlAnimateFloat: [
    from('PlAnimateFloat', 'distance', { type: 'double', default: '8' }),
    from('PlAnimateFloat', 'orientation', {
      type: 'PlassOrientation',
      default: 'PlassOrientation.vertical'
    }),
    ...animateFlutterProps('PlAnimateFloat', {
      duration: 'Duration(milliseconds: 3000)',
      repeat: 'null'
    }),
    {
      name: 'child',
      type: 'Widget',
      required: true,
      description: { ko: '무엇이 떠다니는지', en: 'What drifts' }
    }
  ],

  PlAnimateGrow: [
    from('PlAnimateGrow', 'mode', {
      type: 'PlassAnimateMode',
      default: 'PlassAnimateMode.enter',
      description: {
        ko: '내용이 펼쳐지는지 접히는지. in이 Dart의 예약어라 enter/exit입니다',
        en: 'Whether the content unfolds or folds away. enter/exit rather than in/out, because in is a reserved word in Dart'
      }
    }),
    from('PlAnimateGrow', 'from', { type: 'double', default: '0.8' }),
    from('PlAnimateGrow', 'origin', {
      type: 'Alignment',
      default: 'Alignment.center',
      description: {
        ko: '나머지가 움직이는 동안 제자리에 있는 점. CSS 문자열이 아니라 Alignment입니다 — topCenter는 아래로 펼치고, bottomLeft는 모서리에서 나옵니다',
        en: 'Which point stays put while the rest moves. An Alignment rather than a CSS string: topCenter unfolds downwards, bottomLeft out of a corner'
      }
    }),
    from('PlAnimateGrow', 'fade', { type: 'bool', default: 'true' }),
    ...animateFlutterProps('PlAnimateGrow', { duration: 'Duration(milliseconds: 320)' }),
    {
      name: 'child',
      type: 'Widget',
      required: true,
      description: { ko: '무엇이 펼쳐지는지', en: 'What unfolds' }
    }
  ],

  PlAnimateHeadline: [
    {
      name: 'children',
      type: 'List<Widget>',
      required: true,
      description: {
        ko: '읽어야 할 순서대로의 줄들',
        en: 'The lines, in the order they should be read'
      }
    },
    from('PlAnimateHeadline', 'interval', {
      type: 'Duration',
      default: 'Duration(milliseconds: 2600)'
    }),
    from('PlAnimateHeadline', 'index', { type: 'int?' }),
    from('PlAnimateHeadline', 'defaultIndex', { type: 'int', default: '0' }),
    from('PlAnimateHeadline', 'onIndexChange', { type: 'ValueChanged<int>?' }),
    from('PlAnimateHeadline', 'loop', { type: 'bool', default: 'true' }),
    from('PlAnimateHeadline', 'rise', {
      type: 'double?',
      default: "one line's own height",
      description: {
        ko: '줄이 올라오거나 나갈 때 이동하는 거리(논리 픽셀). null이면 줄 하나의 높이입니다',
        en: "How far a line travels as it comes up or leaves, in logical pixels. null is one line's own height"
      }
    }),
    ...animateFlutterProps('PlAnimateHeadline', {
      duration: 'Duration(milliseconds: 460)',
      repeat: 'null',
      omit: ['alternate']
    })
  ],

  PlAnimateLighting: [
    from('PlAnimateLighting', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlAnimateLighting', 'glow', { type: 'Color?' }),
    from('PlAnimateLighting', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlAnimateLighting', 'spread', { type: 'double', default: '3' }),
    from('PlAnimateLighting', 'arc', { type: 'double', default: '50' }),
    from('PlAnimateLighting', 'blur', { type: 'double', default: '5' }),
    from('PlAnimateLighting', 'reverse', { type: 'bool', default: 'false' }),
    ...animateFlutterProps('PlAnimateLighting', {
      duration: 'Duration(milliseconds: 3000)',
      repeat: 'null'
    }),
    {
      name: 'child',
      type: 'Widget',
      required: true,
      description: { ko: '무엇이 빛나는지', en: 'What is lit' }
    }
  ],

  PlAnimateMarquee: [
    {
      name: 'children',
      type: 'List<Widget>',
      required: true,
      description: { ko: '지나가는 것들', en: 'The things that scroll past' }
    },
    from('PlAnimateMarquee', 'orientation', {
      type: 'PlassOrientation',
      default: 'PlassOrientation.horizontal'
    }),
    from('PlAnimateMarquee', 'reverse', { type: 'bool', default: 'false' }),
    from('PlAnimateMarquee', 'speed', { type: 'double', default: '60' }),
    from('PlAnimateMarquee', 'gap', { type: 'double', default: '32' }),
    from('PlAnimateMarquee', 'copies', { type: 'int', default: '2' }),
    from('PlAnimateMarquee', 'pauseOnHover', { type: 'bool', default: 'true' }),
    ...animateFlutterProps('PlAnimateMarquee', {
      duration: 'measured from speed',
      repeat: 'null'
    }).map((row) => (row.name === 'duration' ? { ...row, type: 'Duration?' } : row))
  ],

  PlAnimateRotate: [
    from('PlAnimateRotate', 'mode', {
      type: 'PlassAnimateMode',
      default: 'PlassAnimateMode.enter',
      description: {
        ko: '제자리로 돌아 들어오는지 돌아 나가는지. in이 Dart의 예약어라 enter/exit입니다',
        en: 'Whether the content turns into place or out of it. enter/exit rather than in/out, because in is a reserved word in Dart'
      }
    }),
    from('PlAnimateRotate', 'from', {
      type: 'double',
      default: '-180',
      description: {
        ko: '시작하는 각도. radian이 아니라 도입니다 — 프레임워크는 radian으로 세지만 디자인 언어는 도로 셉니다',
        en: 'The angle it starts at, in degrees rather than radians: the framework counts in radians and the design language counts in degrees'
      }
    }),
    from('PlAnimateRotate', 'to', { type: 'double', default: '0' }),
    from('PlAnimateRotate', 'origin', { type: 'Alignment', default: 'Alignment.center' }),
    from('PlAnimateRotate', 'fade', { type: 'bool', default: 'true' }),
    ...animateFlutterProps('PlAnimateRotate', { duration: 'Duration(milliseconds: 440)' }),
    {
      name: 'child',
      type: 'Widget',
      required: true,
      description: { ko: '무엇이 도는지', en: 'What turns' }
    }
  ],

  PlAnimateReveal: [
    from('PlAnimateReveal', 'mode', {
      type: 'PlassAnimateMode',
      default: 'PlassAnimateMode.enter',
      description: {
        ko: '드러나는지 다시 덮이는지. exit는 같은 와이프를 거꾸로 돌린 것이라, 열린 쪽으로 닫힙니다. in이 Dart의 예약어라 enter/exit입니다',
        en: 'Whether the content is uncovered or covered again. exit is the same wipe run backwards, so it closes from the edge it opened towards. enter/exit rather than in/out, because in is a reserved word in Dart'
      }
    }),
    from('PlAnimateReveal', 'from', { type: 'PlassSide', default: 'PlassSide.left' }),
    from('PlAnimateReveal', 'fade', { type: 'bool', default: 'false' }),
    ...animateFlutterProps('PlAnimateReveal', { duration: 'Duration(milliseconds: 520)' }),
    {
      name: 'child',
      type: 'Widget',
      required: true,
      description: { ko: '무엇이 드러나는지', en: 'What is uncovered' }
    }
  ],

  PlAnimateScramble: [
    from('PlAnimateScramble', 'children', { name: 'text', type: 'String', required: true }),
    from('PlAnimateScramble', 'characters', { type: 'String?' }),
    {
      name: 'style',
      type: 'TextStyle?',
      description: {
        ko: '줄을 그리는 글자 스타일',
        en: 'The text style the line is drawn in'
      }
    },
    from('PlAnimateScramble', 'duration', {
      type: 'Duration',
      default: 'Duration(milliseconds: 1200)'
    }),
    from('PlAnimateScramble', 'delay', { type: 'Duration', default: 'Duration.zero' }),
    from('PlAnimateScramble', 'tick', { type: 'Duration', default: 'Duration(milliseconds: 45)' }),
    from('PlAnimateScramble', 'trigger', {
      type: 'PlassAnimateTrigger',
      default: 'PlassAnimateTrigger.visible'
    }),
    from('PlAnimateScramble', 'play · once · threshold · paused', {
      type: 'bool · bool · double · bool'
    })
  ],

  PlAnimateShake: [
    from('PlAnimateShake', 'replay', { type: 'Object?' }),
    from('PlAnimateShake', 'distance', { type: 'double', default: '6' }),
    ...animateFlutterProps('PlAnimateShake', { duration: 'Duration(milliseconds: 400)' }),
    {
      name: 'child',
      type: 'Widget',
      required: true,
      description: { ko: '무엇이 거절되는지', en: 'What is refused' }
    }
  ],

  PlAnimateSlide: [
    from('PlAnimateSlide', 'mode', {
      type: 'PlassAnimateMode',
      default: 'PlassAnimateMode.enter',
      description: {
        ko: '들어오는지 나가는지. exit는 들어왔을 그 모서리로 나갑니다. in이 Dart의 예약어라 enter/exit입니다',
        en: 'Whether the content slides in or slides away. exit leaves by the same edge it would have come from. enter/exit rather than in/out, because in is a reserved word in Dart'
      }
    }),
    from('PlAnimateSlide', 'from', { type: 'PlassSide', default: 'PlassSide.bottom' }),
    from('PlAnimateSlide', 'distance', {
      type: 'double?',
      default: 'its own size',
      description: {
        ko: '이동 거리(논리 픽셀). null이면 widget 자신의 너비나 높이라, 자기 모서리 뒤에서 나타나게 됩니다',
        en: "How far it travels, in logical pixels. null is the widget's own width or height, which is what makes it appear from behind its own edge"
      }
    }),
    from('PlAnimateSlide', 'fade', { type: 'bool', default: 'true' }),
    ...animateFlutterProps('PlAnimateSlide', { duration: 'Duration(milliseconds: 360)' }),
    {
      name: 'child',
      type: 'Widget',
      required: true,
      description: { ko: '무엇이 이동하는지', en: 'What travels' }
    }
  ],

  PlAnimateSplit: [
    from('PlAnimateSplit', 'children', { name: 'text', type: 'String', required: true }),
    from('PlAnimateSplit', 'by', {
      type: 'PlAnimateSplitBy',
      default: 'PlAnimateSplitBy.word'
    }),
    {
      name: 'style · textAlign',
      type: 'TextStyle? · TextAlign?',
      description: {
        ko: '줄을 그리는 글자 스타일과, 줄이 넘어갔을 때의 정렬',
        en: 'The text style the line is drawn in, and how the parts align once they wrap'
      }
    },
    from('PlAnimateSplit', 'effect', {
      name: 'from · distance · fade',
      type: 'PlassSide · double · bool',
      default: 'bottom · 12 · true',
      description: {
        ko: '등장을 방향과 거리와 fade로 적습니다. React는 CSS keyframe의 이름을 적는데, 저쪽에서는 효과가 이름 붙은 것이고 여기서는 위젯으로 만들어지기 때문입니다',
        en: 'The entrance, spelled as a side, a distance and a fade. React names a CSS keyframe instead, because there an effect is a named thing and here every effect is built out of widgets'
      }
    }),
    {
      name: 'stagger · reverse',
      type: 'Duration · bool',
      default: '40ms · false',
      description: {
        ko: '한 조각 뒤 다음 조각이 얼마나 늦게 시작하는지, 그리고 줄의 끝에서부터 시작할지',
        en: 'How long after one part the next one starts, and whether it starts from the end of the line'
      }
    },
    ...animateFlutterProps('PlAnimateSplit', { duration: 'Duration(milliseconds: 400)' })
  ],

  PlAnimateTyping: [
    from('PlAnimateTyping', 'text', {
      type: 'String',
      required: true,
      description: {
        ko: '칠 텍스트. widget이 아니라 String입니다 — 타자기는 문자열을 grapheme 단위로 드러내고, 링크의 절반을 정직하게 드러낼 방법은 없습니다',
        en: 'The text to type. A String and not a widget: a typewriter reveals a string one grapheme at a time, and there is no honest way to reveal half of a link'
      }
    }),
    from('PlAnimateTyping', 'speed', { type: 'double', default: '24' }),
    from('PlAnimateTyping', 'hold', {
      type: 'Duration',
      default: 'Duration(milliseconds: 1400)'
    }),
    from('PlAnimateTyping', 'erase', { type: 'bool', default: 'false' }),
    from('PlAnimateTyping', 'eraseSpeed', { type: 'double?', default: 'twice speed' }),
    from('PlAnimateTyping', 'caret', { type: 'bool', default: 'true' }),
    from('PlAnimateTyping', 'caretChar', { type: 'String', default: "'|'" }),
    ...animateFlutterProps('PlAnimateTyping', {
      duration: 'speed decides',
      omit: ['easing', 'alternate']
    }).map((row) => (row.name === 'duration' ? { ...row, type: 'Duration?' } : row))
  ],

  PlAnimateZoom: [
    from('PlAnimateZoom', 'mode', {
      type: 'PlassAnimateMode',
      default: 'PlassAnimateMode.enter',
      description: {
        ko: '내용이 앞으로 나오는지 뒤로 물러나는지. in이 Dart의 예약어라 enter/exit입니다',
        en: 'Whether the content comes forward or falls away. enter/exit rather than in/out, because in is a reserved word in Dart'
      }
    }),
    from('PlAnimateZoom', 'from', { type: 'double', default: '0.4' }),
    from('PlAnimateZoom', 'fade', { type: 'bool', default: 'true' }),
    ...animateFlutterProps('PlAnimateZoom', { duration: 'Duration(milliseconds: 320)' }),
    {
      name: 'child',
      type: 'Widget',
      required: true,
      description: { ko: '무엇이 도착하는지', en: 'What arrives' }
    }
  ],

  PlAnimateAppear: [
    {
      name: 'children',
      type: 'List<Widget>',
      required: true,
      description: {
        ko: '차례로 나타나는 것들. 시차는 자식마다 세므로, 여덟 개를 담은 자식 하나는 한 단계입니다',
        en: 'The things that appear, one after another. The stagger counts children, so one child holding eight things is one step'
      }
    },
    {
      name: 'orientation',
      type: 'PlassOrientation',
      default: 'PlassOrientation.vertical',
      shared: true,
      description: {
        ko: '묶음이 흐르는 방향. React 쪽에서 className이 하던 일입니다 — 여기에는 컨테이너에 display를 걸어 줄 스타일시트가 없습니다',
        en: 'Which way the set runs. What a className does on the React side: there is no stylesheet here to put a display on the container'
      }
    },
    {
      name: 'spacing',
      type: 'double',
      default: '0',
      description: {
        ko: '자식 사이의 간격(논리 픽셀)',
        en: 'The gap between children, in logical pixels'
      }
    },
    from('PlAnimateAppear', 'stagger', {
      type: 'Duration',
      default: 'Duration(milliseconds: 70)'
    }),
    from('PlAnimateAppear', 'from', { type: 'PlassSide', default: 'PlassSide.bottom' }),
    from('PlAnimateAppear', 'distance', { type: 'double', default: '12' }),
    from('PlAnimateAppear', 'fade', { type: 'bool', default: 'true' }),
    from('PlAnimateAppear', 'reverse', { type: 'bool', default: 'false' }),
    ...animateFlutterProps('PlAnimateAppear', { duration: 'Duration(milliseconds: 380)' })
  ],

  PlAnimateBlink: [
    from('PlAnimateBlink', 'min', { type: 'double', default: '0' }),
    ...animateFlutterProps('PlAnimateBlink', {
      duration: 'Duration(milliseconds: 1000)',
      repeat: 'null'
    }),
    {
      name: 'child',
      type: 'Widget',
      required: true,
      description: { ko: '무엇이 맥동하는지', en: 'What pulses' }
    }
  ],

  PlAnimateCounter: [
    from('PlAnimateCounter', 'value', { type: 'double', required: true }),
    from('PlAnimateCounter', 'from', { type: 'double', default: '0' }),
    from('PlAnimateCounter', 'format', {
      name: 'formatValue',
      type: 'String Function(double value)?',
      description: {
        ko: '숫자를 어떻게 쓸지. 옵션 객체가 아니라 콜백입니다 — 프레임워크에 Intl이 없습니다',
        en: 'How the number is written, as a callback rather than an options object: there is no Intl in the framework'
      }
    }),
    {
      name: 'style',
      type: 'TextStyle?',
      description: {
        ko: '수치를 그리는 글자 스타일. 주지 않으면 주변의 것을 씁니다',
        en: 'The text style the figure is drawn in. The surrounding one when it is not given'
      }
    },
    from('PlAnimateCounter', 'duration', {
      type: 'Duration',
      default: 'Duration(milliseconds: 1200)'
    }),
    from('PlAnimateCounter', 'delay', { type: 'Duration', default: 'Duration.zero' }),
    from('PlAnimateCounter', 'easing', {
      name: 'curve',
      type: 'Curve',
      default: 'Curves.easeOutCubic'
    }),
    from('PlAnimateCounter', 'trigger', {
      type: 'PlassAnimateTrigger',
      default: 'PlassAnimateTrigger.visible'
    }),
    from('PlAnimateCounter', 'play · once · threshold · paused', {
      type: 'bool · bool · double · bool'
    })
  ],

  PlAnimateFade: [
    from('PlAnimateFade', 'mode', {
      type: 'PlassAnimateMode',
      default: 'PlassAnimateMode.enter',
      description: {
        ko: '내용이 도착하는지 떠나는지. exit는 같은 곡선을 거꾸로 돌린 것이고 끝난 자리에 붙들려 있습니다. in이 Dart의 예약어라 enter/exit입니다',
        en: 'Whether the content arrives or leaves. exit is the same curve run backwards and is held where it ends. enter/exit rather than in/out, because in is a reserved word in Dart'
      }
    }),
    from('PlAnimateFade', 'from', { type: 'double', default: '0' }),
    ...animateFlutterProps('PlAnimateFade', { duration: 'Duration(milliseconds: 300)' }),
    {
      name: 'child',
      type: 'Widget',
      required: true,
      description: { ko: '무엇이 나타나거나 사라지는지', en: 'What fades' }
    }
  ],

  PlAlert: [
    from('PlAlert', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlAlert', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlAlert', 'color', { type: COLOR, default: 'PlassColor.info' }),
    from('PlAlert', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlAlert', 'elevation', { type: 'int', default: '0' }),
    from('PlAlert', 'title', { type: 'Widget?' }),
    from('PlAlert', 'icon', { type: 'Widget?' }),
    {
      name: 'showIcon',
      type: 'bool',
      default: 'true',
      description: {
        ko: '글리프를 그릴지. React는 icon={false}로 말하는 것을, null도 위젯도 아닌 값이 없는 언어에서 이름을 따로 두어 말합니다',
        en: 'Whether a glyph is drawn at all. React says this with icon={false}; Dart has no value that is neither null nor a widget, so it gets its own name'
      }
    },
    from('PlAlert', 'action', { type: 'Widget?' }),
    from('PlAlert', 'onClose', { type: 'VoidCallback?' }),
    from('PlAlert', 'closeLabel', { type: 'String', default: "'Dismiss'" }),
    from('PlAlert', 'children', { name: 'child', type: 'Widget?' })
  ],

  PlAppLogo: [
    from('PlAppLogo', 'children', { name: 'child', type: 'Widget', required: true }),
    from('PlAppLogo', 'alt', {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '마크가 말하는 것. name이 있으면 빼십시오 — 옆의 워드마크가 이미 말합니다',
        en: 'What the mark says. Leave it out when name is set: the wordmark already says it'
      }
    }),
    from('PlAppLogo', 'name · description', { type: 'Widget?' }),
    from('PlAppLogo', 'shape', { type: 'PlAppLogoShape', default: 'PlAppLogoShape.bare' }),
    from('PlAppLogo', 'variant', { type: VARIANT, default: 'PlassVariant.solid' }),
    from('PlAppLogo', 'render', {
      name: 'onPressed',
      type: 'VoidCallback?',
      description: {
        ko: '로고를 첫 화면으로 돌아가는 길로 만듭니다. null이면 같은 로고를 그리고 아무것도 누르지 않습니다',
        en: 'Makes the logo the way back to the front screen. Null draws the same logo and presses nothing'
      }
    }),
    from('PlAppLogo', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlAppLogo', 'color', { type: COLOR, default: 'PlassColor.primary' })
  ],

  PlAnchor: [
    from('PlAnchor', 'items', { type: 'List<PlAnchorItem>', required: true }),
    {
      name: 'controller',
      type: 'ScrollController?',
      description: {
        ko: '목록이 따라가는 스크롤. 없으면 그리고 눌리기는 하되 아무것도 켜지지 않습니다 — 잴 대상이 없기 때문입니다',
        en: 'The scroll the list is following. Without one it still draws and still moves the screen, but lights nothing: there is nothing to measure against'
      }
    },
    from('PlAnchor', 'active', { type: 'PlAnchorItem?' }),
    from('PlAnchor', 'offset', { type: 'double', default: '0' }),
    from('PlAnchor', 'onSelect', { type: 'ValueChanged<PlAnchorItem>?' }),
    from('PlAnchor', 'label', { type: 'Widget?' }),
    from('PlAnchor', 'navLabel', {
      name: 'semanticLabel',
      type: 'String',
      default: "'On this page'"
    }),
    from('PlAnchor', 'size', { type: SIZE, default: 'PlassSize.sm' }),
    from('PlAnchor', 'color', { type: COLOR, default: 'PlassColor.primary' })
  ],

  PlAnchorItem: [
    from('PlAnchorItem', 'href', {
      name: 'target',
      type: 'GlobalKey',
      required: true,
      description: {
        ko: '제목 위젯의 key. Flutter 화면에는 가리킬 URL이 없고, render object의 위치를 잡는 손잡이가 key뿐입니다',
        en: "A GlobalKey on the heading itself: a Flutter screen has no URL to point into, and a key is the only handle on a render object's position"
      }
    }),
    from('PlAnchorItem', 'label', { type: 'Widget', required: true }),
    from('PlAnchorItem', 'depth', { type: 'int', default: '0' })
  ],

  PlAspectRatio: [
    from('PlAspectRatio', 'children', { name: 'child', type: 'Widget?' }),
    from('PlAspectRatio', 'ratio', {
      type: 'double',
      default: '1',
      description: {
        ko: '지킬 비율, 너비 나누기 높이. 16 / 9처럼 나눗셈으로 씁니다 — Flutter가 다른 곳에서도 종횡비를 말하는 방식입니다',
        en: 'The proportion, as width over height. Written as the division — 16 / 9 — which is how Flutter states an aspect ratio everywhere else'
      }
    }),
    from('PlAspectRatio', 'fit', {
      type: 'PlAspectFit?',
      default: 'null',
      description: {
        ko: 'child를 상자에 어떻게 맞출지. null이면 보통대로 배치합니다 — 브라우저와 달리 Flutter에는 "미디어만"이 없어서, 기본으로 걸리면 글 한 단까지 늘어납니다',
        en: 'How the child is fitted, or null to lay it out normally — Flutter has no "media only" the way a browser does, so a fit applied by default would scale a column of prose'
      }
    }),
    from('PlAspectRatio', 'rounded', { type: 'bool', default: 'false' }),
    from('PlAspectRatio', 'size', { type: SIZE, default: 'PlassSize.md' })
  ],

  PlAvatar: [
    from('PlAvatar', 'variant', { type: 'PlassVariant?', default: 'PlassVariant.ghost' }),
    from('PlAvatar', 'size', { type: 'PlassSize?', default: 'PlassSize.md' }),
    from('PlAvatar', 'color', { type: 'PlassColor?', default: 'PlassColor.primary' }),
    from('PlAvatar', 'elevation', { type: 'int?', default: '0' }),
    from('PlAvatar', 'src', {
      name: 'image',
      type: 'ImageProvider?',
      description: {
        ko: '사진. URL이 아니라 ImageProvider입니다 — NetworkImage든 AssetImage든 캐싱 패키지의 provider든 그대로 들어맞습니다. 로드되기 전까지, 그리고 실패하면 영영, 폴백이 그려집니다',
        en: 'The picture, as an ImageProvider rather than a URL — a NetworkImage, an AssetImage or a provider from a caching package all fit. Until it loads, and forever if it fails, the fallback is what is drawn'
      }
    }),
    from('PlAvatar', 'name', { type: 'String?' }),
    from('PlAvatar', 'initials', { type: 'String?' }),
    from('PlAvatar', 'alt', { name: 'semanticLabel', type: 'String?' }),
    from('PlAvatar', 'shape', { type: 'PlAvatarShape?', default: 'PlAvatarShape.circle' }),
    from('PlAvatar', 'children', { name: 'child', type: 'Widget?' })
  ],

  PlBadge: [
    from('PlBadge', 'variant', { type: VARIANT, default: 'PlassVariant.solid' }),
    from('PlBadge', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlBadge', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlBadge', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlBadge', 'elevation', { type: 'int', default: '0' }),
    from('PlBadge', 'content', {
      type: 'Widget?',
      description: {
        ko: '숫자가 아닐 때 배지가 하는 말. count와 함께 넘길 수 없습니다',
        en: 'What the badge says when it is not a number. Cannot be given alongside count'
      }
    }),
    {
      name: 'count',
      type: 'int?',
      description: {
        ko: '배지가 세는 것. max와 showZero가 숫자에만 뜻이 있어서 content와 나뉘어 있습니다 — 타입이 곧 그 질문입니다',
        en: 'What the badge counts. Separate from content because max and showZero only mean anything for a number — the type is the question'
      }
    },
    from('PlBadge', 'max', { type: 'int', default: '99' }),
    from('PlBadge', 'dot', { type: 'bool', default: 'false' }),
    from('PlBadge', 'showZero', { type: 'bool', default: 'false' }),
    from('PlBadge', 'invisible', { type: 'bool', default: 'false' }),
    from('PlBadge', 'placement', { type: 'PlassCorner', default: 'PlassCorner.topEnd' }),
    from('PlBadge', 'overlap', {
      type: 'PlBadgeOverlap',
      default: 'PlBadgeOverlap.square'
    }),
    from('PlBadge', 'label', { type: 'String?' }),
    from('PlBadge', 'children', { name: 'child', type: 'Widget?' })
  ],

  PlBottomNavigation: [
    from('PlBottomNavigation', 'children', {
      name: 'items',
      type: 'List<PlBottomNavigationItem<T>>',
      required: true,
      description: {
        ko: '목적지들. children이 아니라 설명의 목록입니다 — 바가 무엇이 현재이고 몇 개인지를 알아야 합니다',
        en: 'The destinations, as a list of descriptions rather than children — the bar has to know which is current and how many there are'
      }
    }),
    from('PlBottomNavigation', 'value', { type: 'T?', required: true }),
    from('PlBottomNavigation', 'onValueChange', {
      name: 'onChanged',
      type: 'ValueChanged<T>?',
      description: {
        ko: '고른 목적지로 호출됩니다. 주지 않으면 바가 그대로 굳습니다',
        en: 'Called with the destination that was chosen. Leaving it out freezes the bar'
      }
    }),
    from('PlBottomNavigation', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlBottomNavigation', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlBottomNavigation', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlBottomNavigation', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlBottomNavigation', 'elevation', { type: 'int', default: '0' }),
    from('PlBottomNavigation', 'labels', {
      type: 'PlBottomNavigationLabels',
      default: 'PlBottomNavigationLabels.all'
    }),
    from('PlBottomNavigation', 'divider', { type: 'bool', default: 'true' }),
    from('PlBottomNavigation', 'safeArea', { type: 'bool', default: 'true' }),
    from('PlBottomNavigation', 'disabled', { type: 'bool', default: 'false' }),
    from('PlBottomNavigation', 'label', { type: 'String?' })
  ],

  PlBottomNavigationItem: [
    from('PlBottomNavigationItem', 'value', { type: 'T', required: true }),
    from('PlBottomNavigationItem', 'children', {
      name: 'label',
      type: 'String',
      required: true,
      description: {
        ko: '목적지의 이름. 위젯이 아니라 String이고 필수입니다 — 그려지는 이름이자 언제나 읽히는 이름입니다',
        en: "The destination's name. A String rather than a widget, and required — it is both the name that is drawn and the one that is always announced"
      }
    }),
    from('PlBottomNavigationItem', 'icon', { type: 'Widget?' }),
    from('PlBottomNavigationItem', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlBreadcrumb: [
    {
      name: 'items',
      type: 'List<PlBreadcrumbItem>',
      required: true,
      description: {
        ko: '단계들. children이 아니라 설명의 목록입니다 — 자취가 어느 단계가 현재인지, 접기가 무엇을 덜어내는지 판단해야 하는데 Widget에는 그것을 물어볼 수 없습니다',
        en: 'The steps, as a list of descriptions rather than children — the trail has to reason about which step is current and what a fold removes, and a Widget cannot be asked'
      }
    },
    from('PlBreadcrumb', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlBreadcrumb', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlBreadcrumb', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlBreadcrumb', 'separator', {
      type: 'PlBreadcrumbSeparator',
      default: 'PlBreadcrumbSeparator.chevron',
      description: {
        ko: '두 단계 사이의 표시. 이름 붙은 네 가지 중 하나입니다',
        en: 'The mark between two steps, as one of the four names'
      }
    }),
    {
      name: 'separatorWidget',
      type: 'Widget?',
      description: {
        ko: '직접 만든 표시. separator를 이깁니다',
        en: 'A mark of your own, which wins over separator'
      }
    },
    from('PlBreadcrumb', 'maxItems', { type: 'int?' }),
    from('PlBreadcrumb', 'itemsBeforeCollapse', { type: 'int', default: '1' }),
    from('PlBreadcrumb', 'itemsAfterCollapse', { type: 'int', default: '1' }),
    from('PlBreadcrumb', 'expandable', { type: 'bool', default: 'true' }),
    from('PlBreadcrumb', 'label', { type: 'String', default: "'Breadcrumb'" }),
    from('PlBreadcrumb', 'expandLabel', {
      type: 'String',
      default: "'Show the hidden steps'"
    })
  ],

  PlBreadcrumbItem: [
    from('PlBreadcrumbItem', 'children', {
      name: 'label',
      type: 'Widget',
      required: true,
      description: { ko: '단계가 하는 말', en: 'What the step says' }
    }),
    from('PlBreadcrumbItem', 'onClick', { name: 'onPressed', type: 'VoidCallback?' }),
    from('PlBreadcrumbItem', 'startIcon', { type: 'Widget?' }),
    from('PlBreadcrumbItem', 'endIcon', { type: 'Widget?' }),
    from('PlBreadcrumbItem', 'current', { type: 'bool?' }),
    from('PlBreadcrumbItem', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlBlockquote: [
    from('PlBlockquote', 'variant', { type: VARIANT, default: 'PlassVariant.ghost' }),
    from('PlBlockquote', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlBlockquote', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlBlockquote', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlBlockquote', 'elevation', { type: 'int', default: '0' }),
    from('PlBlockquote', 'author', { type: 'Widget?' }),
    from('PlBlockquote', 'source', { type: 'Widget?' }),
    from('PlBlockquote', 'icon', { type: 'Widget?' }),
    {
      name: 'showIcon',
      type: 'bool',
      default: 'true',
      description: {
        ko: '따옴표 글리프를 그릴지. React는 icon={false}로 말하는 것을, null도 위젯도 아닌 값이 없는 언어에서 이름을 따로 두어 말합니다',
        en: 'Whether a mark is drawn at all. React says this with icon={false}; Dart has no value that is neither null nor a widget, so it gets its own name'
      }
    },
    from('PlBlockquote', 'children', { name: 'child', type: 'Widget?' })
  ],

  PlButtonGroup: [
    {
      name: 'children',
      type: 'List<Widget>',
      required: true,
      description: {
        ko: '버튼들, 순서대로. 하나의 child가 아니라 목록인 건 그룹이 양 끝이 누구인지 알아야 모서리를 정할 수 있기 때문입니다',
        en: 'The buttons, in order. A list rather than one child, because the group has to know which member is at each end to decide which corners to square'
      }
    },
    from('PlButtonGroup', 'variant', { type: `${VARIANT}?` }),
    from('PlButtonGroup', 'size', { type: `${SIZE}?` }),
    from('PlButtonGroup', 'color', { type: `${COLOR}?` }),
    from('PlButtonGroup', 'density', { type: `${DENSITY}?` }),
    from('PlButtonGroup', 'elevation', { type: 'int?' }),
    from('PlButtonGroup', 'orientation', {
      type: 'PlassOrientation',
      default: 'PlassOrientation.horizontal'
    }),
    from('PlButtonGroup', 'disabled', { type: 'bool?' }),
    from('PlButtonGroup', 'fullWidth', { type: 'bool', default: 'false' })
  ],

  PlCard: [
    from('PlCard', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlCard', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlCard', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlCard', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlCard', 'elevation', { type: 'int', default: '1' }),
    from('PlCard', 'title', { type: 'Widget?' }),
    from('PlCard', 'subtitle', { type: 'Widget?' }),
    from('PlCard', 'headerAction', { type: 'Widget?' }),
    from('PlCard', 'footer', {
      type: 'Widget?',
      description: {
        ko: '아래 영역. 위젯 하나이므로, 버튼이 둘 든 푸터는 자기 Row나 Wrap을 가져옵니다',
        en: 'The bottom area. One widget, so a footer with two buttons in it brings its own Row or Wrap'
      }
    }),
    from('PlCard', 'dividers', { type: 'bool', default: 'false' }),
    from('PlCard', 'padded', { type: 'bool', default: 'true' }),
    {
      name: 'onPressed',
      type: 'VoidCallback?',
      description: {
        ko: '눌렸을 때. 넘기면 카드가 진짜 focus stop이 되고 버튼으로 알려집니다 — 눌러 보이는 카드와 실제로 눌리는 카드의 차이입니다',
        en: 'Called when pressed. Passing it makes the card a real focus stop, announced as a button — the difference between a card that looks clickable and one that is'
      }
    },
    from('PlCard', 'interactive', { type: 'bool', default: 'false' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '누를 수 있는 카드를 스크린 리더가 부르는 이름. 없으면 안에 든 것으로 불립니다',
        en: 'The name a screen reader gives a pressable card. Left out, the card is named by what is in it'
      }
    },
    from('PlCard', 'children', { name: 'child', type: 'Widget?' })
  ],

  PlChatBubble: [
    from('PlChatBubble', 'side', {
      type: 'PlChatBubbleSide',
      default: 'PlChatBubbleSide.start'
    }),
    from('PlChatBubble', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlChatBubble', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlChatBubble', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlChatBubble', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlChatBubble', 'elevation', { type: 'int', default: '0' }),
    from('PlChatBubble', 'name', { type: 'Widget?' }),
    from('PlChatBubble', 'time', { type: 'Widget?' }),
    from('PlChatBubble', 'avatar', { type: 'Widget?' }),
    from('PlChatBubble', 'status', { type: 'PlChatBubbleStatus?' }),
    from('PlChatBubble', 'statusLabel', { type: 'String?' }),
    from('PlChatBubble', 'typing', {
      type: 'bool',
      default: 'false',
      description: {
        ko: '메시지 대신 점 세 개를 그립니다. child는 그대로 두므로, 메시지가 도착하면 같은 버블이 되돌아옵니다',
        en: 'Draws the three dots instead of the message. What child holds is left alone, so the same bubble can go back to it when the message arrives'
      }
    }),
    from('PlChatBubble', 'typingLabel', { type: 'String', default: "'Typing…'" }),
    from('PlChatBubble', 'media', { type: 'Widget?' }),
    from('PlChatBubble', 'preview', { type: 'PlChatBubbleLinkPreview?' }),
    from('PlChatBubble', 'actions', {
      type: 'Widget?',
      description: {
        ko: '메시지 자신의 액션. 버블 옆에 있고, 그대로 있습니다 — 포인터가 확실히 있는 화면이라는 것이 없기 때문입니다',
        en: "The message's own actions. Sits beside the bubble and stays there: there is no screen here that certainly has a pointer"
      }
    }),
    from('PlChatBubble', 'children', { name: 'child', type: 'Widget?' })
  ],

  PlChatBubbleLinkPreview: [
    from('PlChatBubbleLinkPreview', 'url', {
      name: 'onPressed',
      type: 'VoidCallback?',
      required: false,
      description: {
        ko: '카드를 눌렀을 때. url이 아닌 이유는 Flutter에 자기 내비게이션이 없기 때문입니다',
        en: 'Called when the card is pressed. Not a url, because Flutter has no navigation of its own'
      }
    }),
    from('PlChatBubbleLinkPreview', 'title', { type: 'Widget?' }),
    from('PlChatBubbleLinkPreview', 'description', { type: 'Widget?' }),
    from('PlChatBubbleLinkPreview', 'image', {
      type: 'ImageProvider?',
      description: {
        ko: '카드 위쪽에 걸치는 공유 이미지. Flutter에서 모든 이미지가 갖는 모양입니다',
        en: 'The share image, drawn across the top of the card — the shape every image in Flutter has'
      }
    }),
    from('PlChatBubbleLinkPreview', 'site', { type: 'Widget?' })
  ],

  PlCheckbox: [
    from('PlCheckbox', 'checked', {
      name: 'value',
      type: 'bool',
      required: true,
      description: {
        ko: '박스가 체크되어 있는지. controlled 전용입니다 — 상태의 사본을 들고 있는 위젯은 여러분의 상태와 어긋날 수 있는 위젯입니다',
        en: 'Whether the box is ticked. Controlled only: a widget that owned a copy of your state would be a widget your state could disagree with'
      }
    }),
    from('PlCheckbox', 'onCheckedChange', {
      name: 'onChanged',
      type: 'ValueChanged<bool>?',
      description: {
        ko: '값이 무엇이 되어야 하는지를 알립니다. null이면 Flutter 관례대로 비활성화됩니다',
        en: 'Called with what the value should become. Leaving it null disables the checkbox, as it does everywhere else in Flutter'
      }
    }),
    from('PlCheckbox', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlCheckbox', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlCheckbox', 'label', { type: 'Widget?' }),
    from('PlCheckbox', 'description', { type: 'Widget?' }),
    from('PlCheckbox', 'error', { type: 'Widget?' }),
    from('PlCheckbox', 'invalid', { type: 'bool?' }),
    from('PlCheckbox', 'indeterminate', { type: 'bool', default: 'false' }),
    from('PlCheckbox', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlCheckbox', 'disabled', { type: 'bool', default: 'false' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '보이는 label이 없는 checkbox를 스크린 리더가 부를 이름',
        en: 'The name a screen reader announces, for a checkbox with no visible label'
      }
    }
  ],

  PlChip: [
    from('PlChip', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlChip', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlChip', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlChip', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlChip', 'elevation', { type: 'int', default: '0' }),
    from('PlChip', 'startIcon', { type: 'Widget?' }),
    from('PlChip', 'endIcon', { type: 'Widget?' }),
    from('PlChip', 'count', { type: 'Widget?' }),
    from('PlChip', 'onClick', { name: 'onPressed', type: 'VoidCallback?' }),
    from('PlChip', 'onDelete', { name: 'onDeleted', type: 'VoidCallback?' }),
    from('PlChip', 'deleteLabel', { type: 'String', default: "'Remove'" }),
    from('PlChip', 'selected', { type: 'bool', default: 'false' }),
    from('PlChip', 'disabled', { type: 'bool', default: 'false' }),
    from('PlChip', 'children', { name: 'child', type: 'Widget?' })
  ],

  PlColorPicker: [
    from('PlColorPicker', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlColorPicker', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlColorPicker', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlColorPicker', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlColorPicker', 'elevation', { type: 'int', default: '0' }),
    from('PlColorPicker', 'value', {
      type: 'String?',
      description: {
        ko: '색, CSS 문자열로. null이면 피커 자신의 파랑에서 시작합니다',
        en: 'The colour, as a CSS string. null starts the picker on its own blue'
      }
    }),
    from('PlColorPicker', 'onValueChange', {
      name: 'onValueChanged',
      type: 'ValueChanged<String>?'
    }),
    from('PlColorPicker', 'format', {
      type: 'PlColorFormat',
      default: 'PlColorFormat.hex'
    }),
    from('PlColorPicker', 'alpha', { type: 'bool', default: 'false' }),
    from('PlColorPicker', 'swatches', {
      type: 'List<String>',
      default: 'defaultSwatches',
      description: {
        ko: '패널 아래의 기성 색들. 빈 리스트면 그리지 않습니다',
        en: 'The ready-made colours under the panel. An empty list draws none'
      }
    }),
    from('PlColorPicker', 'inline', { type: 'bool', default: 'false' }),
    from('PlColorPicker', 'editable', { type: 'bool', default: 'true' }),
    from('PlColorPicker', 'label', { type: 'Widget?' }),
    from('PlColorPicker', 'description', { type: 'Widget?' }),
    from('PlColorPicker', 'error', { type: 'Widget?' }),
    from('PlColorPicker', 'invalid', { type: 'bool?' }),
    from('PlColorPicker', 'disabled', { type: 'bool', default: 'false' }),
    from('PlColorPicker', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlColorPicker', 'fullWidth', { type: 'bool', default: 'false' }),
    from('PlColorPicker', 'clearable', { type: 'bool', default: 'false' }),
    from('PlColorPicker', 'labels', {
      type: 'PlColorPickerLabels',
      default: 'const PlColorPickerLabels()'
    })
  ],

  PlCombobox: [
    {
      name: 'options',
      type: 'List<PlComboboxOption<T>>',
      required: true,
      description: {
        ko: '선택지 목록. 필터가 이들의 label을 읽습니다',
        en: 'The choices, in order. The filter reads their labels'
      }
    },
    {
      name: 'value',
      type: 'T?',
      required: true,
      description: {
        ko: '선택된 값. 단일 폼에만 있습니다',
        en: 'The chosen value. Single form only'
      }
    },
    {
      name: 'onChanged',
      type: 'ValueChanged<T?>?',
      description: {
        ko: '값이 정해졌을 때 호출됩니다. multiple 폼에서는 ValueChanged<List<T>>입니다',
        en: 'Called with the value that was chosen. On the multiple form it is a ValueChanged<List<T>>'
      }
    },
    {
      name: 'values',
      type: 'List<T>',
      required: true,
      description: {
        ko: '선택된 값들. PlCombobox.multiple에만 있습니다',
        en: 'The chosen values. PlCombobox.multiple only'
      }
    },
    {
      name: 'onCreate',
      type: 'T Function(String query)?',
      description: {
        ko: '입력한 글자를 값으로 바꿉니다. **이걸 주는 것이 곧 allowCustom입니다** — React에서는 값이 언제나 string이나 number라 field가 스스로 만들 수 있지만, 여기서는 T이고 그걸 만드는 법은 호출자만 압니다',
        en: 'Turns what was typed into a value, and **passing it is what allows one**. React can default this to on because a value there is always a string or a number; here it is a T, and only the caller knows how to make one'
      }
    },
    {
      name: 'customLabel',
      type: 'Widget Function(String query)?',
      description: { ko: '그 행이 뭐라고 말할지', en: 'What that row says' }
    },
    from('PlCombobox', 'onInputValueChange', {
      name: 'onQueryChanged',
      type: 'ValueChanged<String>?'
    }),
    from('PlCombobox', 'placeholder', { type: 'String?' }),
    from('PlCombobox', 'emptyMessage', { type: 'String', default: "'No matches'" }),
    from('PlCombobox', 'limit', { type: 'int?', default: 'null' }),
    from('PlCombobox', 'clearable', { type: 'bool', default: 'false' }),
    from('PlCombobox', 'clearLabel', { type: 'String', default: "'Clear'" }),
    from('PlCombobox', 'openLabel', { type: 'String', default: "'Open'" }),
    from('PlCombobox', 'removeLabel', { type: 'String Function(String label)' }),
    from('PlCombobox', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlCombobox', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlCombobox', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlCombobox', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlCombobox', 'elevation', { type: 'int', default: '0' }),
    from('PlCombobox', 'label', { type: 'Widget?' }),
    from('PlCombobox', 'description', { type: 'Widget?' }),
    from('PlCombobox', 'error', { type: 'Widget?' }),
    from('PlCombobox', 'invalid', { type: 'bool?' }),
    from('PlCombobox', 'startIcon', { type: 'Widget?' }),
    from('PlCombobox', 'fullWidth', { type: 'bool', default: 'false' }),
    from('PlCombobox', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlCombobox', 'disabled', { type: 'bool', default: 'false' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '보이는 label이 없는 field를 스크린 리더가 부를 이름',
        en: 'The name a screen reader gives a field with no visible label'
      }
    },
    {
      name: 'focusNode',
      type: 'FocusNode?',
      description: {
        ko: '포커스를 밖에서 제어할 때 넘깁니다',
        en: 'Drive focus from outside'
      }
    },
    {
      name: 'autofocus',
      type: 'bool',
      default: 'false',
      description: {
        ko: '트리에 들어가면서 포커스를 가져갑니다',
        en: 'Takes focus as it is inserted into the tree'
      }
    },
    hotKeysProp
  ],

  PlComboboxOption: [
    from('PlComboboxOption', 'value', { type: 'T', required: true }),
    from('PlComboboxOption', 'label', { type: 'String', required: true }),
    from('PlComboboxOption', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlCommandPalette: [
    from('PlCommandPalette', 'items', { type: 'List<PlCommandItem>', required: true }),
    from('PlCommandPalette', 'open', {
      type: 'bool',
      required: true,
      description: {
        ko: '팔레트가 열려 있는지. uncontrolled 모드는 없습니다 — 팔레트를 여는 것은 앱 전체에 걸린 키이고, 그런 키를 거는 앱은 이미 상태를 쥐고 있습니다',
        en: 'Whether the palette is open. There is no uncontrolled mode: the thing that opens a palette is a key bound on the whole app, and an app that binds one already holds the state'
      }
    }),
    from('PlCommandPalette', 'onOpenChange', {
      name: 'onOpenChanged',
      type: 'ValueChanged<bool>?'
    }),
    from('PlCommandPalette', 'onSelect', { type: 'ValueChanged<PlCommandItem>?' }),
    from('PlCommandPalette', 'shortcut', {
      type: 'String?',
      default: "'Mod+K'",
      description: {
        ko: '팔레트를 여는 키. 키보드에 바인딩됩니다. PlHotKeys와 같은 표기라 Mod는 Mac에서 Command, 그 외에서 Control입니다. null이면 아무것도 바인딩하지 않습니다',
        en: 'The keystroke that opens the palette, bound on the keyboard. Written the way PlHotKeys writes them, so Mod is Command on a Mac and Control everywhere else. null binds nothing'
      }
    }),
    from('PlCommandPalette', 'width', { type: 'double?' }),
    from('PlCommandPalette', 'maxHeight', { type: 'double', default: '320' }),
    from('PlCommandPalette', 'placeholder', { type: 'String', default: "'Search commands'" }),
    from('PlCommandPalette', 'emptyMessage', {
      type: 'String',
      default: "'No commands found'"
    }),
    from('PlCommandPalette', 'label', { type: 'String', default: "'Command palette'" }),
    from('PlCommandPalette', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlCommandPalette', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlCommandPalette', 'density', { type: DENSITY, default: 'PlassDensity.standard' })
  ],

  PlCommandItem: [
    from('PlCommandItem', 'value', { type: 'String', required: true }),
    from('PlCommandItem', 'label', { type: 'String', required: true }),
    from('PlCommandItem', 'description', { type: 'String?' }),
    from('PlCommandItem', 'icon', { type: 'Widget?' }),
    from('PlCommandItem', 'shortcut', { type: 'String?' }),
    from('PlCommandItem', 'group', { type: 'String?' }),
    from('PlCommandItem', 'keywords', { type: 'List<String>', default: 'const []' }),
    from('PlCommandItem', 'disabled', { type: 'bool', default: 'false' }),
    from('PlCommandItem', 'onSelect', { type: 'VoidCallback?' })
  ],

  PlContainer: [
    from('PlContainer', 'children', { name: 'child', type: 'Widget?' }),
    from('PlContainer', 'maxWidth', {
      type: 'PlassResponsive<PlContainerWidth?>?',
      default: 'null',
      description: {
        ko: '내용이 넓어질 수 있는 한계. PlContainerWidth.rung(PlassSize)는 사다리 한 칸, PlContainerWidth.pixels(double)는 정확한 너비입니다. null은 제한 없음이고, 항목으로 써도 그렇습니다',
        en: 'How wide the content is allowed to get. PlContainerWidth.rung(PlassSize) is a rung of the ladder and PlContainerWidth.pixels(double) is an exact width. null means no limit, including as an entry'
      }
    }),
    from('PlContainer', 'padded', { type: 'bool', default: 'true' }),
    from('PlContainer', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlContainer', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlContainer', 'centered', { type: 'bool', default: 'true' })
  ],

  /*
   * The pickers, and the one place the two packages genuinely differ.
   *
   * React gets `Intl` from the platform, so a `locale` string is enough to
   * produce every month name and the order the header writes them in. The
   * framework ships nothing of the kind, so the words arrive as a `PlDateNames`
   * and the trigger's format as a callback — the same trade the indicators
   * already make with `formatValue`.
   */
  PlStepper: [
    {
      name: 'steps',
      type: 'List<PlStep>',
      required: true,
      description: { ko: '순서대로의 step들', en: 'The steps, in order' }
    },
    from('PlStepper', 'active', { type: 'int', required: true }),
    from('PlStepper', 'onActiveChange', {
      name: 'onActiveChanged',
      type: 'ValueChanged<int>?',
      description: {
        ko: '눌린 step과 함께 호출됩니다. null이면 모든 step이 비활성입니다 — 구동하지 않고 보여 주기만 하는 방법입니다',
        en: 'Called with the step that was pressed. A null handler makes every step inert, which is how a stepper is shown without being driven'
      }
    }),
    from('PlStepper', 'linear', { type: 'bool', default: 'true' }),
    from('PlStepper', 'orientation', {
      type: 'PlassResponsive<PlassOrientation>',
      default: 'PlassOrientation.horizontal'
    }),
    from('PlStepper', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlStepper', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlStepper', 'density', { type: DENSITY, default: 'PlassDensity.standard' })
  ],
  PlStep: [
    from('PlStep', 'label', { type: 'Widget?' }),
    from('PlStep', 'description', { type: 'Widget?' }),
    from('PlStep', 'bullet', { type: 'Widget?' }),
    from('PlStep', 'status', { type: 'PlStepStatus?' }),
    {
      name: 'optional',
      type: 'Widget?',
      description: {
        ko: '건너뛸 수 있음을 표시하고, 그 말로 말합니다. 기본 문자열이 없습니다 — 패키지는 번역을 싣지 않고, 지어낸 단어는 어느 한 언어의 것이기 때문입니다',
        en: 'Marks the step skippable, and says so in these words. There is no default string, because the package ships no translations and a word it invented would be in one language'
      }
    },
    from('PlStep', 'disabled', { type: 'bool', default: 'false' }),
    from('PlStep', 'color', { type: COLOR }),
    {
      name: 'connector',
      type: 'PlassStepConnector',
      default: 'PlassStepConnector.solid',
      description: {
        ko: '다음 step으로 가는 선. none은 간격을 비웁니다',
        en: 'How the line to the next step is drawn. none leaves the gap open'
      }
    },
    from('PlStep', 'children', {
      name: 'child',
      type: 'Widget?',
      description: {
        ko: '현재 step일 때 보여 줄 패널',
        en: 'The panel this step shows while it is the current one'
      }
    })
  ],
  PlTree: [
    from('PlTree', 'items', { type: 'List<PlTreeNode>', required: true }),
    from('PlTree', 'expanded', {
      type: 'Set<String>',
      default: '{}',
      description: {
        ko: '열려 있는 가지의 id들. controlled입니다',
        en: 'The ids of the branches that are open. Controlled'
      }
    }),
    from('PlTree', 'onExpandedChange', {
      name: 'onExpandedChanged',
      type: 'ValueChanged<Set<String>>?',
      description: {
        ko: '가지가 열리거나 닫힌 뒤 열린 집합 전체와 함께 호출됩니다',
        en: 'Called with the whole open set after a branch is opened or closed'
      }
    }),
    from('PlTree', 'selected', {
      type: 'Set<String>',
      default: '{}',
      description: {
        ko: '선택된 행의 id들. controlled입니다',
        en: 'The ids of the selected rows. Controlled'
      }
    }),
    from('PlTree', 'onSelectedChange', {
      name: 'onSelectedChanged',
      type: 'ValueChanged<Set<String>>?',
      description: {
        ko: '행을 누른 뒤 선택 집합 전체와 함께 호출됩니다',
        en: 'Called with the whole selection after a row is pressed'
      }
    }),
    from('PlTree', 'selection', { type: 'PlTreeSelection', default: 'PlTreeSelection.single' }),
    from('PlTree', 'onItemClick', {
      name: 'onItemPressed',
      type: 'ValueChanged<PlTreeNode>?',
      description: {
        ko: '행을 눌렀을 때. 고를 수 있든 아니든',
        en: 'Called when a row is pressed, selectable or not'
      }
    }),
    from('PlTree', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlTree', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlTree', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '스크린 리더가 트리 전체에 주는 이름',
        en: 'The name a screen reader gives the whole tree'
      }
    }
  ],
  PlTreeNode: [
    from('PlTreeNode', 'id', { type: 'String', required: true }),
    from('PlTreeNode', 'label', { type: 'Widget', required: true }),
    from('PlTreeNode', 'icon', { type: 'Widget?' }),
    from('PlTreeNode', 'children', {
      type: 'List<PlTreeNode>?',
      description: {
        ko: '자식들. 빈 리스트는 아무것도 없는 **가지**이고, null은 **잎**입니다 — 서로 다릅니다',
        en: 'Its own children. An empty list is a **branch** with nothing in it; null is a **leaf**. They are different things'
      }
    }),
    from('PlTreeNode', 'disabled', { type: 'bool', default: 'false' })
  ],
  PlTreeSelect: [
    from('PlTreeSelect', 'items', { type: 'List<PlTreeSelectNode>', required: true }),
    from('PlTreeSelect', 'value', {
      type: 'Set<String>',
      default: '{}',
      description: {
        ko: '고른 node의 id들. controlled입니다',
        en: 'The ids of the chosen nodes. Controlled'
      }
    }),
    from('PlTreeSelect', 'onValueChange', {
      name: 'onValueChanged',
      type: 'ValueChanged<Set<String>>?',
      description: {
        ko: 'node를 고르거나 뺀 뒤 선택 집합 전체와 함께 호출됩니다',
        en: 'Called with the whole selection after a node is chosen or dropped'
      }
    }),
    from('PlTreeSelect', 'multiple', { type: 'bool', default: 'false' }),
    from('PlTreeSelect', 'selectableBranches', { type: 'bool', default: 'false' }),
    from('PlTreeSelect', 'expanded', {
      type: 'Set<String>?',
      description: {
        ko: '열려 있는 가지의 id들. 두지 않으면 picker가 스스로 쥡니다',
        en: 'The ids of the branches that are open. Leave it out and the picker holds its own'
      }
    }),
    from('PlTreeSelect', 'onExpandedChange', {
      name: 'onExpandedChanged',
      type: 'ValueChanged<Set<String>>?',
      description: {
        ko: '가지가 열리거나 닫힌 뒤 열린 집합 전체와 함께 호출됩니다',
        en: 'Called with the whole open set after a branch is opened or closed'
      }
    }),
    from('PlTreeSelect', 'open', {
      type: 'bool?',
      description: {
        ko: '팝업이 떠 있는지. 두지 않으면 picker가 스스로 쥡니다',
        en: 'Whether the popup is up. Leave it out and the picker holds its own'
      }
    }),
    from('PlTreeSelect', 'onOpenChange', {
      name: 'onOpenChanged',
      type: 'ValueChanged<bool>?'
    }),
    from('PlTreeSelect', 'placeholder', { type: 'Widget?' }),
    from('PlTreeSelect', 'clearable', { type: 'bool', default: 'false' }),
    from('PlTreeSelect', 'closeOnSelect', { type: 'bool?', default: '!multiple' }),
    from('PlTreeSelect', 'searchable', { type: 'bool', default: 'false' }),
    from('PlTreeSelect', 'searchLabel', { type: 'String?', default: "'Search'" }),
    from('PlTreeSelect', 'emptyLabel', { type: 'String?', default: "'Nothing here'" }),
    from('PlTreeSelect', 'format', {
      type: 'String Function(List<PlTreeSelectNode>)?'
    }),
    ...sharedProps('PlTreeSelect').map((row) =>
      row.name === 'variant'
        ? { ...row, default: 'PlassVariant.glass' }
        : row.name === 'elevation'
          ? { ...row, default: '0' }
          : row
    ),
    from('PlTreeSelect', 'label', { type: 'Widget?' }),
    from('PlTreeSelect', 'description', { type: 'Widget?' }),
    from('PlTreeSelect', 'error', { type: 'Widget?' }),
    from('PlTreeSelect', 'invalid', { type: 'bool?' }),
    from('PlTreeSelect', 'startIcon', { type: 'Widget?' }),
    from('PlTreeSelect', 'fullWidth', { type: 'bool', default: 'false' }),
    from('PlTreeSelect', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlTreeSelect', 'disabled', { type: 'bool', default: 'false' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '스크린 리더가 trigger에 주는 이름',
        en: 'The name a screen reader gives the trigger'
      }
    },
    {
      name: 'focusNode',
      type: 'FocusNode?',
      description: { ko: '바깥에서 focus를 다룹니다', en: 'Drive focus from outside' }
    },
    {
      name: 'autofocus',
      type: 'bool',
      default: 'false',
      description: {
        ko: '트리에 들어가면서 focus를 가져갑니다',
        en: 'Takes focus as it is inserted into the tree'
      }
    }
  ],
  PlTreeSelectNode: [
    from('PlTreeSelectNode', 'id', { type: 'String', required: true }),
    from('PlTreeSelectNode', 'label', {
      type: 'String',
      required: true,
      description: {
        ko: '행이 말하는 것이자, 필터가 대조하는 것이자, trigger가 쓰는 것. React와 달리 위젯이 아니라 문자열입니다',
        en: 'What the row says, what the filter matches, and what the trigger writes. A String rather than a widget, unlike the React build'
      }
    }),
    from('PlTreeSelectNode', 'icon', { type: 'Widget?' }),
    from('PlTreeSelectNode', 'children', {
      type: 'List<PlTreeSelectNode>?',
      description: {
        ko: '자식들. 빈 리스트는 아무것도 없는 **가지**이고, null은 **잎**입니다',
        en: 'Its own children. An empty list is a **branch** with nothing in it; null is a **leaf**'
      }
    }),
    from('PlTreeSelectNode', 'selectable', { type: 'bool?' }),
    from('PlTreeSelectNode', 'disabled', { type: 'bool', default: 'false' })
  ],
  PlImage: [
    from('PlImage', 'src', {
      name: 'image',
      type: 'ImageProvider<Object>',
      required: true,
      description: {
        ko: '사진. URL이 아니라 ImageProvider입니다 — 네트워크 · 에셋 · 파일 · 메모리가 공유하는 모양이기 때문입니다',
        en: 'The picture. An ImageProvider rather than a URL, because that is the shape every source has in common'
      }
    }),
    from('PlImage', 'alt', {
      name: 'semanticLabel',
      type: 'String?',
      required: false,
      description: {
        ko: '스크린 리더가 읽는 설명. null은 장식이라는 진짜 답이고, fallback이 물러설 자리이기도 합니다',
        en: 'The description a screen reader reads. null marks the picture decorative, and is also what the fallback falls back to'
      }
    }),
    from('PlImage', 'ratio', { type: 'double?' }),
    from('PlImage', 'fit', { type: 'PlAspectFit', default: 'PlAspectFit.cover' }),
    from('PlImage', 'rounded', { type: 'bool', default: 'false' }),
    from('PlImage', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlImage', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlImage', 'placeholder', { type: 'Widget?' }),
    from('PlImage', 'fallback', { type: 'Widget?' }),
    from('PlImage', 'preview', { type: 'bool', default: 'false' }),
    from('PlImage', 'previewLabel', { type: 'String', default: "'Preview'" }),
    from('PlImage', 'onStatusChange', {
      name: 'onStatusChanged',
      type: 'ValueChanged<PlImageStatus>?'
    })
  ],
  PlEmpty: [
    from('PlEmpty', 'icon', { type: 'Widget?' }),
    from('PlEmpty', 'title', { type: 'Widget?' }),
    from('PlEmpty', 'description', { type: 'Widget?' }),
    from('PlEmpty', 'actions', { type: 'List<Widget>', default: '[]' }),
    {
      name: 'child',
      type: 'Widget?',
      description: {
        ko: 'description과 actions 사이에 들어갈 그 밖의 것',
        en: 'Anything else that belongs between the description and the actions'
      }
    },
    from('PlEmpty', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlEmpty', 'color', { type: COLOR, default: 'PlassColor.secondary' }),
    from('PlEmpty', 'density', { type: DENSITY, default: 'PlassDensity.standard' })
  ],
  PlStack: [
    from('PlStack', 'children', { type: 'List<Widget>', required: true }),
    from('PlStack', 'direction', {
      type: 'PlassResponsive<PlStackDirection>',
      default: 'PlStackDirection.horizontal'
    }),
    from('PlStack', 'overlap', {
      type: 'double?',
      default: 'a fraction of size',
      description: {
        ko: '흐르는 축에서 각 항목이 앞 항목 아래로 들어가는 거리(논리 픽셀)',
        en: 'How far each item sits under the one before it, in logical pixels, along the axis the pile flows on'
      }
    }),
    from('PlStack', 'drop', { type: 'double?', default: 'whatever overlap resolved to' }),
    from('PlStack', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlStack', 'max', { type: 'int?' }),
    from('PlStack', 'total', { type: 'int?' }),
    from('PlStack', 'overflow', {
      type: 'Widget Function(int hidden)?',
      description: {
        ko: '넘친 개수를 받아 맨 뒤 항목을 만듭니다. widget이 아니라 builder인 이유는 그 숫자가 곧 항목이기 때문입니다',
        en: 'Builds a last item standing for the ones that did not fit, given how many that is. A builder rather than a widget, because the number is the item'
      }
    }),
    from('PlStack', 'front', { type: 'PlStackFront', default: 'PlStackFront.last' }),
    from('PlStack', 'scaleStep', { type: 'double', default: '1' }),
    from('PlStack', 'opacityStep', { type: 'double', default: '1' }),
    from('PlStack', 'ring', {
      type: 'BorderRadius?',
      default: 'null',
      description: {
        ko: '각 항목 둘레에 그리는 페이지 표면색 실선의 모서리. bool이 아니라 반지름인 것이 React와 갈리는 한 곳입니다 — 거기서는 CSS가 요소 자신의 border-radius를 공짜로 주지만, 여기서는 자식의 모양을 읽을 방법이 없습니다',
        en: 'The corners of the hairline drawn around each item. A radius rather than a bool, which is the one place this diverges from React: there CSS gives a ring the element’s own border-radius for nothing, and here nothing can read a child’s shape'
      }
    }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '이 더미가 무엇의 집합인지. 다른 것이 그것을 말하고 있지 않을 때 이름을 주세요',
        en: 'What the pile is a pile *of*. Name it when nothing else is saying so'
      }
    }
  ],

  PlStat: [
    from('PlStat', 'label', { type: 'Widget?' }),
    from('PlStat', 'value', {
      type: 'Widget?',
      description: {
        ko: '이미 서식이 정해진 숫자 그 자체. 숫자 타입이 아닌 이유는 통화 · 자릿수 · 소수점 · 로케일이 화면의 결정이고, 이 패키지에는 짐작할 의존성이 없기 때문입니다',
        en: "The figure itself, already formatted. A widget rather than a number, because the currency, grouping, decimals and locale are the screen's decision and this package has no dependencies to guess with"
      }
    }),
    from('PlStat', 'description', { type: 'Widget?' }),
    from('PlStat', 'icon', { type: 'Widget?' }),
    from('PlStat', 'change', { type: 'double?' }),
    from('PlStat', 'changeLabel', { type: 'Widget?' }),
    from('PlStat', 'improvesWhen', {
      type: 'PlStatDirection',
      default: 'PlStatDirection.up'
    }),
    from('PlStat', 'loading', { type: 'bool', default: 'false' }),
    from('PlStat', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlStat', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlStat', 'density', { type: DENSITY, default: 'PlassDensity.standard' })
  ],
  PlBackTop: [
    from('PlBackTop', 'target', {
      name: 'controller',
      type: 'ScrollController?',
      default: 'PrimaryScrollController',
      description: {
        ko: '무엇을 스크롤하고 무엇을 지켜볼지. 생략하면 PrimaryScrollController — 자체 controller가 없는 ListView가 붙는 곳이고, 따라서 "창"에 해당합니다',
        en: 'What is scrolled, and what is watched. Left out, the PrimaryScrollController — which is what a ListView with no controller of its own is attached to, and is therefore the equivalent of "the window"'
      }
    }),
    from('PlBackTop', 'visibilityHeight', { type: 'double', default: '400' }),
    from('PlBackTop', 'label', { type: 'String', default: "'Back to top'" }),
    from('PlBackTop', 'icon', { type: 'Widget?' }),
    {
      name: 'onPressed',
      type: 'VoidCallback?',
      description: {
        ko: '스크롤 대신 실행됩니다. "위"가 offset 0이 아닌 화면 — 대화 기록, 중간에서 시작하는 목록 — 을 위한 것',
        en: 'Runs instead of the scroll. For the screen whose "up" is somewhere other than offset zero'
      }
    },
    from('PlBackTop', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlBackTop', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlBackTop', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlBackTop', 'elevation', { type: 'int', default: '2' })
  ],
  PlConfirmProvider: [
    {
      name: 'child',
      type: 'Widget',
      required: true,
      description: { ko: '애플리케이션', en: 'The application' }
    },
    from('PlConfirmProvider', 'confirmLabel', {
      type: 'Widget',
      default: "Text('Confirm')"
    }),
    from('PlConfirmProvider', 'cancelLabel', { type: 'Widget', default: "Text('Cancel')" }),
    from('PlConfirmProvider', 'acknowledgeLabel', { type: 'Widget', default: "Text('OK')" }),
    from('PlConfirmProvider', 'width', { type: 'double?' }),
    from('PlConfirmProvider', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlConfirmProvider', 'color', { type: COLOR, default: 'PlassColor.primary' })
  ],
  PlConfirmOptions: [
    from('PlConfirmOptions', 'title', { type: 'Widget?' }),
    from('PlConfirmOptions', 'description', { type: 'Widget?' }),
    from('PlConfirmOptions', 'children', { name: 'child', type: 'Widget?' }),
    from('PlConfirmOptions', 'confirmLabel', { type: 'Widget?' }),
    from('PlConfirmOptions', 'cancelLabel', { type: 'Widget?' }),
    from('PlConfirmOptions', 'color', { type: COLOR }),
    from('PlConfirmOptions', 'size', { type: SIZE }),
    from('PlConfirmOptions', 'initialFocus', {
      type: 'PlConfirmFocus',
      default: 'PlConfirmFocus.cancel'
    }),
    from('PlConfirmOptions', 'dismissible', { type: 'bool', default: 'true' }),
    from('PlConfirmOptions', 'width', { type: 'double?' })
  ],
  PlPopconfirm: [
    {
      name: 'open',
      type: 'bool',
      required: true,
      description: {
        ko: 'popup이 올라와 있는지. 여기의 다른 모든 상태와 마찬가지로 controlled입니다',
        en: 'Whether the popup is up. Controlled, like everything stateful here'
      }
    },
    from('PlPopconfirm', 'trigger', { type: 'Widget', required: true }),
    from('PlPopconfirm', 'onOpenChange', {
      name: 'onOpenChanged',
      type: 'ValueChanged<bool>?'
    }),
    from('PlPopconfirm', 'title', { type: 'Widget?' }),
    from('PlPopconfirm', 'description', { type: 'Widget?' }),
    from('PlPopconfirm', 'confirmLabel', { type: 'Widget', default: "Text('Confirm')" }),
    from('PlPopconfirm', 'cancelLabel', { type: 'Widget', default: "Text('Cancel')" }),
    from('PlPopconfirm', 'onConfirm', { type: 'FutureOr<void> Function()?' }),
    from('PlPopconfirm', 'onCancel', { type: 'VoidCallback?' }),
    from('PlPopconfirm', 'color', { type: COLOR, default: 'PlassColor.danger' }),
    from('PlPopconfirm', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlPopconfirm', 'side', { type: 'PlassSide', default: 'PlassSide.top' }),
    from('PlPopconfirm', 'align', { type: 'PlassAlign', default: 'PlassAlign.center' }),
    from('PlPopconfirm', 'width', { type: 'double', default: '280' })
  ],
  PlCalendar: [
    {
      name: 'value',
      type: 'DateTime?',
      required: true,
      description: {
        ko: '고른 날, 또는 없으면 null. 패키지의 다른 모든 입력과 마찬가지로 controlled입니다',
        en: 'The chosen day, or null for none. Controlled, like every other input in the package'
      }
    },
    {
      name: 'onChanged',
      type: 'ValueChanged<DateTime?>?',
      description: {
        ko: '고른 날과 함께 호출됩니다. null이면 calendar가 비활성입니다',
        en: 'Called with the day that was taken. A null onChanged makes it inert'
      }
    },
    from('PlCalendar', 'precision', {
      type: 'PlCalendarPrecision',
      default: 'PlCalendarPrecision.day'
    }),
    from('PlCalendar', 'month', { type: 'DateTime?' }),
    from('PlCalendar', 'defaultMonth', { type: 'DateTime?' }),
    from('PlCalendar', 'onMonthChange', {
      name: 'onMonthChanged',
      type: 'ValueChanged<DateTime>?'
    }),
    from('PlCalendar', 'minDate', { type: 'DateTime?' }),
    from('PlCalendar', 'maxDate', { type: 'DateTime?' }),
    from('PlCalendar', 'shouldDisableDate', { type: 'bool Function(DateTime)?' }),
    from('PlCalendar', 'weekStartsOn', { type: 'PlassWeekday?' }),
    {
      name: 'names',
      type: 'PlDateNames',
      default: 'PlDateNames.english',
      description: {
        ko: 'calendar가 그리는 말들 — 월, 요일. React의 locale 문자열에 해당합니다',
        en: 'The words the calendar draws — the months, the weekdays. This is what a locale string is in the React build'
      }
    },
    {
      name: 'labels',
      type: 'PlPickerLabels',
      default: 'PlPickerLabels.english',
      description: {
        ko: 'calendar가 자기 자신에 대해 말하는 것 — 스테퍼, 제목',
        en: 'The words it says about itself — the steppers, the headings'
      }
    },
    from('PlCalendar', 'showOutsideDays', { type: 'bool', default: 'true' }),
    from('PlCalendar', 'autoFocus', { name: 'autofocus', type: 'bool', default: 'false' }),
    from('PlCalendar', 'disabled', { type: 'bool', default: 'false' }),
    from('PlCalendar', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlCalendar', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlCalendar', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlCalendar', 'elevation', { type: 'int', default: '1' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '스크린 리더가 grid 전체에 주는 이름',
        en: 'The name a screen reader gives the whole grid'
      }
    }
  ],
  PlDataList: [
    from('PlDataList', 'children', { type: 'List<Widget>', required: true }),
    from('PlDataList', 'orientation', {
      type: 'PlassOrientation',
      default: 'PlassOrientation.horizontal'
    }),
    from('PlDataList', 'labelWidth', { type: 'double?', default: '160' }),
    from('PlDataList', 'divider', { type: 'bool', default: 'false' }),
    from('PlDataList', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlDataList', 'density', { type: DENSITY, default: 'PlassDensity.standard' })
  ],

  PlDataListItem: [
    from('PlDataListItem', 'label', { type: 'Widget?' }),
    from('PlDataListItem', 'value', { type: 'Widget?' }),
    from('PlDataListItem', 'icon', { type: 'Widget?' })
  ],

  PlDataTable: [
    from('PlDataTable', 'columns', {
      type: 'List<PlDataTableColumn<T>>',
      required: true
    }),
    from('PlDataTable', 'rows', { type: 'List<T>', required: true }),
    from('PlDataTable', 'getRowKey', {
      name: 'rowKey',
      type: 'Object Function(T row, int index)?',
      description: {
        ko: '행마다의 안정적인 key. 다른 무엇보다 먼저 정할 값입니다 — 없으면 위치로 식별되고, 정렬이 행을 옮기면 위치는 뒤에 남습니다',
        en: 'A stable key per row, and the one thing worth setting before anything else. Left out, a row is identified by its position, which stays behind when a sort moves the row'
      }
    }),
    from('PlDataTable', 'caption', {
      type: 'Widget?',
      description: {
        ko: '격자 위, 시트 안에 그려집니다',
        en: 'Drawn above the grid, inside the sheet'
      }
    }),
    from('PlDataTable', 'empty', { type: 'Widget?', default: 'Text(labels.empty)' }),
    from('PlDataTable', 'striped', { type: 'bool', default: 'false' }),
    from('PlDataTable', 'hoverable', { type: 'bool', default: 'false' }),
    from('PlDataTable', 'stickyHeader', { type: 'bool', default: 'true' }),
    from('PlDataTable', 'maxHeight', {
      type: 'double?',
      description: {
        ko: '격자 높이의 상한, 논리 픽셀. 넘으면 시트 안에서 행이 스크롤됩니다',
        en: 'A hard cap on the grid, in logical pixels. Past it the rows scroll inside the sheet'
      }
    }),
    from('PlDataTable', 'onRowClick', {
      name: 'onRowPressed',
      type: 'void Function(T row, int index)?'
    }),
    from('PlDataTable', 'sort', { type: 'PlDataTableSort?' }),
    from('PlDataTable', 'defaultSort', {
      name: 'initialSort',
      type: 'PlDataTableSort?',
      default: 'null'
    }),
    from('PlDataTable', 'onSortChange', {
      name: 'onSortChanged',
      type: 'ValueChanged<PlDataTableSort?>?'
    }),
    from('PlDataTable', 'searchable', { type: 'bool', default: 'false' }),
    from('PlDataTable', 'search', { type: 'String?' }),
    from('PlDataTable', 'defaultSearch', { name: 'initialSearch', type: 'String', default: "''" }),
    from('PlDataTable', 'onSearchChange', {
      name: 'onSearchChanged',
      type: 'ValueChanged<String>?'
    }),
    from('PlDataTable', 'searchPlaceholder', { type: 'String?', default: 'labels.search' }),
    from('PlDataTable', 'selection', {
      type: 'PlDataTableSelection',
      default: 'PlDataTableSelection.none'
    }),
    from('PlDataTable', 'selected', { type: 'List<Object>?' }),
    from('PlDataTable', 'defaultSelected', {
      name: 'initialSelected',
      type: 'List<Object>?',
      default: '[]'
    }),
    from('PlDataTable', 'onSelectedChange', {
      name: 'onSelectedChanged',
      type: 'void Function(List<Object> selected, List<T> rows)?'
    }),
    from('PlDataTable', 'isRowSelectable', { type: 'bool Function(T row, int index)?' }),
    from('PlDataTable', 'paging', {
      type: 'PlDataTablePaging',
      default: 'PlDataTablePaging.scroll'
    }),
    from('PlDataTable', 'pageSize', { type: 'int', default: '10' }),
    from('PlDataTable', 'page', { type: 'int?' }),
    from('PlDataTable', 'defaultPage', { name: 'initialPage', type: 'int', default: '1' }),
    from('PlDataTable', 'onPageChange', { name: 'onPageChanged', type: 'ValueChanged<int>?' }),
    from('PlDataTable', 'rowCount', { type: 'int?' }),
    from('PlDataTable', 'manual', { type: 'List<PlDataTableStage>', default: '[]' }),
    from('PlDataTable', 'loading', {
      type: 'bool',
      default: 'false',
      description: {
        ko: '행 대신 막대를 그립니다',
        en: 'Draws bars in place of the rows'
      }
    }),
    from('PlDataTable', 'toolbar', { type: 'Widget?' }),
    from('PlDataTable', 'footer', { type: 'Widget?' }),
    from('PlDataTable', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlDataTable', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlDataTable', 'color', {
      type: COLOR,
      default: 'PlassColor.primary',
      description: {
        ko: '의미론적 색 역할. hover 틴트와 선택 틴트, 체크박스, focus ring까지만 닿습니다 — 데이터는 자기 색을 가지고 옵니다',
        en: 'Semantic colour role. It reaches the hover tint, the selection tint, the ticks and the focus ring and nothing else: data arrives with its own colours'
      }
    }),
    from('PlDataTable', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlDataTable', 'elevation', { type: 'int', default: '0' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '표를 스크린 리더가 부를 이름',
        en: 'The name a screen reader gives the table'
      }
    },
    {
      name: 'selectAllLabel',
      type: 'String?',
      default: 'labels.selectAll',
      description: {
        ko: '체크 열 맨 위 상자의 이름',
        en: 'Names the box at the top of the tick column'
      }
    },
    {
      name: 'selectRowLabel',
      type: 'String?',
      default: 'labels.selectRow',
      description: { ko: '행 체크박스의 이름', en: "Names a row's own tick" }
    },
    {
      name: 'searchLabel',
      type: 'String?',
      default: 'labels.search',
      description: { ko: '검색 필드의 이름', en: 'Names the search field' }
    }
  ],

  PlDataTableColumn: [
    from('PlDataTableColumn', 'key', { type: 'String', required: true }),
    {
      name: 'cell',
      type: 'Widget Function(T row, int index)',
      required: true,
      description: {
        ko: '행에서 셀을 만듭니다. Dart에는 임의의 타입에 대한 row[key]가 없으니 필수입니다',
        en: 'Builds the cell for a row. Required, because Dart has no row[key] on an arbitrary type'
      }
    },
    from('PlDataTableColumn', 'header', { type: 'Widget?' }),
    from('PlDataTableColumn', 'width', {
      type: 'double?',
      description: {
        ko: '고정 너비, 논리 픽셀. 없으면 내용만큼 넓어진 뒤 남은 폭을 flex만큼 나눠 갖습니다',
        en: 'A fixed width in logical pixels. Left out, the column is as wide as its content and then takes a flex share of what is left'
      }
    }),
    {
      name: 'flex',
      type: 'double',
      default: '1',
      description: {
        ko: '남은 폭을 나눠 가질 때의 몫. width가 있으면 무시됩니다',
        en: 'How much of the leftover width this column takes. Ignored when width is set'
      }
    },
    from('PlDataTableColumn', 'align', { type: 'PlassAlign', default: 'PlassAlign.start' }),
    from('PlDataTableColumn', 'value', {
      type: 'Object? Function(T row)?',
      description: {
        ko: '정렬과 검색이 보는 값. 정렬하거나 검색되는 열에는 필요합니다 — cell은 위젯을 돌려주고, 위젯에는 순서도 읽을 글자도 없습니다',
        en: 'What the sort and the search see. A sortable or searchable column needs it: cell returns a widget, and a widget has no order and no text to look inside'
      }
    }),
    from('PlDataTableColumn', 'sortable', { type: 'bool', default: 'false' }),
    from('PlDataTableColumn', 'compare', { type: 'int Function(T a, T b)?' }),
    from('PlDataTableColumn', 'unsearchable', { type: 'bool', default: 'false' })
  ],

  PlDatePicker: [
    {
      name: 'value',
      type: 'DateTime?',
      required: true,
      description: {
        ko: '선택된 날, 또는 없으면 null. 패키지의 다른 모든 입력과 마찬가지로 controlled입니다',
        en: 'The chosen day, or null for none. Controlled, like every other input in the package'
      }
    },
    {
      name: 'onChanged',
      type: 'ValueChanged<DateTime?>?',
      description: {
        ko: '고른 날과 함께 호출됩니다. 비우면 null입니다',
        en: 'Called with the day that was chosen, or null when the picker is emptied'
      }
    },
    from('PlDatePicker', 'precision', {
      type: 'PlDatePickerPrecision',
      default: 'PlDatePickerPrecision.day'
    }),
    from('PlDatePicker', 'open', { type: 'bool?' }),
    {
      name: 'onOpenChanged',
      type: 'ValueChanged<bool>?',
      description: {
        ko: '달력이 열리거나 닫혀야 할 때 호출됩니다',
        en: 'Called when the calendar should open or close'
      }
    },
    from('PlDatePicker', 'defaultMonth', { type: 'DateTime?' }),
    from('PlDatePicker', 'minDate', { type: 'DateTime?' }),
    from('PlDatePicker', 'maxDate', { type: 'DateTime?' }),
    from('PlDatePicker', 'shouldDisableDate', { type: 'bool Function(DateTime date)?' }),
    from('PlDatePicker', 'weekStartsOn', {
      type: 'PlassWeekday?',
      description: {
        ko: '한 주가 시작하는 요일. 기본은 names가 말하는 대로입니다',
        en: 'Which day the week starts on. Defaults to what names says'
      }
    }),
    {
      name: 'names',
      type: 'PlDateNames',
      default: 'PlDateNames.english',
      description: {
        ko: '달력이 그리는 월과 요일 이름, 그리고 헤더가 그것들을 쓰는 순서. **React의 locale 문자열에 해당합니다** — 프레임워크에 Intl이 없으므로 단어를 객체로 받습니다',
        en: 'The month and weekday names the calendar draws, and the order the header writes them in. **This is what a locale string is in the React build**: there is no Intl in the framework, so the words arrive as an object'
      }
    },
    {
      name: 'labels',
      type: 'PlPickerLabels',
      default: 'PlPickerLabels.english',
      description: {
        ko: 'picker가 스스로 말하는 문자열들. 전부 영어 기본값이 있습니다',
        en: 'The words the picker says about itself. Every one has an English default'
      }
    },
    {
      name: 'formatValue',
      type: 'String Function(DateTime value)?',
      description: {
        ko: 'trigger가 날짜를 쓰는 방식. React의 Intl 옵션 대신 콜백입니다. 빼면 precision이 요구한 만큼 names로 씁니다 — medium 형식의 날, 월과 연, 또는 연도만',
        en: "How the trigger writes the day. A callback rather than React's Intl options; without it the value is written out of names at whatever precision asked for — the medium day, the month and year, or the bare year"
      }
    },
    from('PlDatePicker', 'placeholder', { type: 'Widget?' }),
    from('PlDatePicker', 'clearable', { type: 'bool', default: 'false' }),
    from('PlDatePicker', 'showTodayButton', { type: 'bool', default: 'true' }),
    from('PlDatePicker', 'closeOnSelect', { type: 'bool', default: 'true' }),
    from('PlDatePicker', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlDatePicker', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlDatePicker', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlDatePicker', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlDatePicker', 'elevation', { type: 'int', default: '0' }),
    from('PlDatePicker', 'label', { type: 'Widget?' }),
    from('PlDatePicker', 'description', { type: 'Widget?' }),
    from('PlDatePicker', 'error', { type: 'Widget?' }),
    from('PlDatePicker', 'invalid', { type: 'bool?' }),
    from('PlDatePicker', 'startIcon', { type: 'Widget?' }),
    from('PlDatePicker', 'fullWidth', { type: 'bool', default: 'false' }),
    from('PlDatePicker', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlDatePicker', 'disabled', { type: 'bool', default: 'false' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '보이는 label이 없는 trigger를 스크린 리더가 부를 이름',
        en: 'The name a screen reader gives a trigger with no visible label'
      }
    },
    {
      name: 'focusNode',
      type: 'FocusNode?',
      description: { ko: '포커스를 밖에서 제어할 때 넘깁니다', en: 'Drive focus from outside' }
    },
    {
      name: 'autofocus',
      type: 'bool',
      default: 'false',
      description: {
        ko: '트리에 들어가면서 포커스를 가져갑니다',
        en: 'Takes focus as it is inserted into the tree'
      }
    }
  ],

  PlDateNames: [
    {
      name: 'months',
      type: 'List<String>',
      default: 'English',
      description: {
        ko: '월 이름 열둘, 1월부터',
        en: 'The twelve month names in full, January first'
      }
    },
    {
      name: 'monthsShort',
      type: 'List<String>',
      default: 'English',
      description: {
        ko: '같은 열둘의 약칭. 월 그리드가 그립니다',
        en: 'The same twelve, abbreviated. What the month grid draws'
      }
    },
    {
      name: 'weekdays',
      type: 'List<String>',
      default: 'English',
      description: {
        ko: '요일 이름 일곱, **일요일부터**. 어느 요일로 시작해 그리든 회전은 달력의 몫입니다',
        en: 'The seven weekday names in full, **Sunday first**, whatever the week is drawn as starting on — rotating them is the calendar’s job'
      }
    },
    {
      name: 'weekdaysShort',
      type: 'List<String>',
      default: 'English',
      description: {
        ko: '같은 일곱의 약칭. 열 머리글이 그립니다 — narrow가 아니라 short인 건 영어의 narrow가 S M T W T F S이기 때문입니다',
        en: 'The same seven, abbreviated. What the column headers draw — abbreviated rather than narrow, because narrow gives S M T W T F S in English'
      }
    },
    {
      name: 'am',
      type: 'String',
      default: "'AM'",
      description: { ko: '12시간제의 오전', en: 'The first half of the day, for a 12-hour clock' }
    },
    {
      name: 'pm',
      type: 'String',
      default: "'PM'",
      description: { ko: '그리고 오후', en: 'And the second' }
    },
    {
      name: 'monthBeforeYear',
      type: 'bool',
      default: 'true',
      description: {
        ko: '헤더가 월을 연도보다 먼저 쓰는지. 헤더는 문자열 하나가 아니라 버튼 둘이라 formatter가 준 것을 그대로 찍을 수 없고, 어느 쪽이 먼저인지 들어야 합니다',
        en: 'Whether the header writes the month before the year. It is two buttons rather than one string, so it cannot print what a formatter gives it and has to be told which comes first'
      }
    },
    {
      name: 'firstDayOfWeek',
      type: 'PlassWeekday',
      default: 'PlassWeekday.sunday',
      description: {
        ko: '이 언어에서 한 주가 시작하는 요일. picker의 weekStartsOn이 우선합니다',
        en: 'Which day the week starts on in this language. A picker’s own weekStartsOn overrides it'
      }
    }
  ],

  PlDateRangePicker: [
    {
      name: 'value',
      type: 'PlDateRange',
      required: true,
      description: {
        ko: '선택된 구간. null이 아닙니다 — 비어 있는 것은 PlDateRange.empty입니다',
        en: 'The chosen range. Never null — an empty one is PlDateRange.empty'
      }
    },
    {
      name: 'onChanged',
      type: 'ValueChanged<PlDateRange>?',
      description: {
        ko: '새 구간과 함께 언제나 객체로 호출됩니다. 한 번의 선택에 두 번 울립니다 — 첫 누름에 start만, 둘째에 양 끝',
        en: 'Called with the new range, always as an object. It fires twice per selection: once with only a start, and once with both ends'
      }
    },
    from('PlDateRangePicker', 'open', { type: 'bool?' }),
    {
      name: 'onOpenChanged',
      type: 'ValueChanged<bool>?',
      description: {
        ko: '달력이 열리거나 닫혀야 할 때 호출됩니다',
        en: 'Called when the calendars should open or close'
      }
    },
    from('PlDateRangePicker', 'defaultMonth', { type: 'DateTime?' }),
    from('PlDateRangePicker', 'minDate', { type: 'DateTime?' }),
    from('PlDateRangePicker', 'maxDate', { type: 'DateTime?' }),
    from('PlDateRangePicker', 'shouldDisableDate', { type: 'bool Function(DateTime date)?' }),
    from('PlDateRangePicker', 'weekStartsOn', { type: 'PlassWeekday?' }),
    pickerWordProps[0],
    from('PlDateRangePicker', 'labels', {
      type: 'PlPickerLabels',
      default: 'PlPickerLabels.english'
    }),
    pickerWordProps[1],
    from('PlDateRangePicker', 'monthCount', { type: 'int', default: '2' }),
    from('PlDateRangePicker', 'startPlaceholder', { type: 'Widget?' }),
    from('PlDateRangePicker', 'endPlaceholder', { type: 'Widget?' }),
    from('PlDateRangePicker', 'presets', {
      type: 'List<PlDateRangePreset>',
      default: 'const []'
    }),
    from('PlDateRangePicker', 'clearable', { type: 'bool', default: 'false' }),
    from('PlDateRangePicker', 'closeOnSelect', { type: 'bool', default: 'true' }),
    from('PlDateRangePicker', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlDateRangePicker', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlDateRangePicker', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlDateRangePicker', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlDateRangePicker', 'elevation', { type: 'int', default: '0' }),
    from('PlDateRangePicker', 'label', { type: 'Widget?' }),
    from('PlDateRangePicker', 'description', { type: 'Widget?' }),
    from('PlDateRangePicker', 'error', { type: 'Widget?' }),
    from('PlDateRangePicker', 'invalid', { type: 'bool?' }),
    from('PlDateRangePicker', 'startIcon', { type: 'Widget?' }),
    from('PlDateRangePicker', 'fullWidth', { type: 'bool', default: 'false' }),
    from('PlDateRangePicker', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlDateRangePicker', 'disabled', { type: 'bool', default: 'false' }),
    ...pickerHandleProps
  ],

  PlDateRange: [
    from('PlDateRange', 'start', { type: 'DateTime?', required: false }),
    from('PlDateRange', 'end', { type: 'DateTime?', required: false })
  ],

  PlDateRangePreset: [
    from('PlDateRangePreset', 'label', { type: 'Widget', required: true }),
    {
      name: 'build',
      type: 'PlDateRange Function()',
      required: true,
      description: {
        ko: '그것이 뜻하는 구간. React가 값도 허용하는 자리에서 여기서는 언제나 콜백입니다 — preset은 거의 언제나 오늘에 달려 있고, 시작할 때 한 번 계산한 "지난 7일"은 앱을 밤새 열어 둔 사람에게 틀린 값입니다',
        en: 'The range it stands for. A callback rather than a value, and always: a preset almost always depends on today, and "the last 7 days" computed once at startup is wrong for anyone who left the app open overnight'
      }
    }
  ],

  PlDateTimePicker: [
    {
      name: 'value',
      type: 'DateTime?',
      required: true,
      description: {
        ko: '선택된 순간, 또는 없으면 null',
        en: 'The chosen moment, or null for none'
      }
    },
    {
      name: 'onChanged',
      type: 'ValueChanged<DateTime?>?',
      description: {
        ko: '고른 순간과 함께 호출됩니다. 비우면 null입니다',
        en: 'Called with the moment that was chosen, or null when it is emptied'
      }
    },
    from('PlDateTimePicker', 'open', { type: 'bool?' }),
    {
      name: 'onOpenChanged',
      type: 'ValueChanged<bool>?',
      description: {
        ko: '패널들이 열리거나 닫혀야 할 때 호출됩니다',
        en: 'Called when the panels should open or close'
      }
    },
    from('PlDateTimePicker', 'defaultMonth', { type: 'DateTime?' }),
    from('PlDateTimePicker', 'minDate', { type: 'DateTime?' }),
    from('PlDateTimePicker', 'maxDate', { type: 'DateTime?' }),
    from('PlDateTimePicker', 'shouldDisableDate', { type: 'bool Function(DateTime date)?' }),
    from('PlDateTimePicker', 'weekStartsOn', { type: 'PlassWeekday?' }),
    ...timeColumnProps('PlDateTimePicker'),
    pickerWordProps[0],
    from('PlDateTimePicker', 'labels', {
      type: 'PlPickerLabels',
      default: 'PlPickerLabels.english'
    }),
    pickerWordProps[1],
    from('PlDateTimePicker', 'placeholder', { type: 'Widget?' }),
    from('PlDateTimePicker', 'clearable', { type: 'bool', default: 'false' }),
    from('PlDateTimePicker', 'showNowButton', { type: 'bool', default: 'true' }),
    from('PlDateTimePicker', 'closeOnSelect', { type: 'bool', default: 'false' }),
    from('PlDateTimePicker', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlDateTimePicker', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlDateTimePicker', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlDateTimePicker', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlDateTimePicker', 'elevation', { type: 'int', default: '0' }),
    from('PlDateTimePicker', 'label', { type: 'Widget?' }),
    from('PlDateTimePicker', 'description', { type: 'Widget?' }),
    from('PlDateTimePicker', 'error', { type: 'Widget?' }),
    from('PlDateTimePicker', 'invalid', { type: 'bool?' }),
    from('PlDateTimePicker', 'startIcon', { type: 'Widget?' }),
    from('PlDateTimePicker', 'fullWidth', { type: 'bool', default: 'false' }),
    from('PlDateTimePicker', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlDateTimePicker', 'disabled', { type: 'bool', default: 'false' }),
    ...pickerHandleProps
  ],

  PlDivider: [
    from('PlDivider', 'orientation', {
      type: 'PlassOrientation',
      default: 'PlassOrientation.horizontal'
    }),
    from('PlDivider', 'color', { type: `${COLOR}?`, default: 'null' }),
    from('PlDivider', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlDivider', 'length', {
      type: 'double?',
      description: {
        ko: '선이 뻗는 길이 — 가로면 너비, 세로면 높이. 논리 픽셀입니다. 생략하면 허락된 만큼 뻗습니다',
        en: 'How far the rule runs — the width of a horizontal divider, the height of a vertical one, in logical pixels. Left out, it runs as far as it is allowed to'
      }
    }),
    from('PlDivider', 'thickness', { type: 'double', default: '1' }),
    from('PlDivider', 'textAlign', { type: 'PlassAlign', default: 'PlassAlign.center' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '스크린 리더가 부를 이름. 없으면 divider는 semantics 트리에 들어가지 않습니다 — 두 가지 사이의 선은 대개 레이아웃이 하는 말입니다',
        en: 'What a screen reader calls the divider. Without it the divider stays out of the semantics tree — a rule between two things is usually the layout speaking'
      }
    },
    from('PlDivider', 'children', { name: 'child', type: 'Widget?' })
  ],

  PlFieldset: [
    {
      name: 'children',
      type: 'List<Widget>',
      required: true,
      description: {
        ko: '한 질문에 함께 답하는 컨트롤들',
        en: 'The controls that answer one question together'
      }
    },
    from('PlFieldset', 'legend', { type: 'Widget?' }),
    from('PlFieldset', 'description', { type: 'Widget?' }),
    from('PlFieldset', 'disabled', {
      type: 'bool',
      default: 'false',
      description: {
        ko: '안의 모든 것에서 포인터와 focus를 거두고 묶음을 비웁니다. 브라우저의 fieldset 같은 cascade가 여기에는 없습니다',
        en: 'Takes the pointer and the focus away from everything inside, and drains the group. There is no browser-style cascade here'
      }
    }),
    from('PlFieldset', 'size', { type: SIZE, default: 'PlassSize.md' })
  ],

  PlFilePicker: [
    from('PlFilePicker', 'value', { type: 'List<PlFile>', required: true }),
    from('PlFilePicker', 'onFilesChange', {
      name: 'onFilesChanged',
      type: 'ValueChanged<List<PlFile>>?',
      description: {
        ko: '다음에 쥐고 있어야 할 목록으로 불립니다 — 파일이 더해졌거나, 목록에서 하나가 지워졌거나',
        en: 'Called with the list that should be held next — a file added, or one removed from the list'
      }
    }),
    {
      name: 'onBrowse',
      type: 'Future<List<PlFile>> Function()?',
      description: {
        ko: '앱 자신의 file picker를 실행하고 찾은 것을 돌려줍니다. 돌아온 것이 규칙에 걸린 뒤 살아남은 것이 onFilesChanged로 보고됩니다',
        en: "Runs the app's own file picker and hands back what it found. What it returns is checked against the rules, and what survives is reported through onFilesChanged"
      }
    },
    from('PlFilePicker', 'onReject', {
      name: 'onRejected',
      type: 'ValueChanged<List<PlFileRejection>>?'
    }),
    from('PlFilePicker', 'accept', {
      type: 'String?',
      description: {
        ko: "어떤 파일을 받을지 ('image/*,.pdf'). onBrowse가 돌려준 것에 적용됩니다 — 말해 놓고 강제하지 않는 규칙은 규칙이 아닙니다",
        en: "Which files are kept ('image/*,.pdf'). Applied to whatever onBrowse hands back: a rule the component states and does not enforce is not a rule"
      }
    }),
    from('PlFilePicker', 'multiple', { type: 'bool', default: 'false' }),
    from('PlFilePicker', 'maxSize', { type: 'int?' }),
    from('PlFilePicker', 'maxFiles', { type: 'int?' }),
    {
      name: 'dragging',
      type: 'bool',
      default: 'false',
      description: {
        ko: '파일이 상자 위에 있는지. 플러그인 없이는 Flutter에 OS 수준의 드래그가 없으므로 앱이 알려 주고, 상자는 그에 맞게 밝아집니다',
        en: 'Whether a file is over the box. There is no OS-level drag in Flutter without a plugin, so an app that has one tells it and the box lights the way it should'
      }
    },
    from('PlFilePicker', 'label · description · error · invalid', {
      name: 'label · description · error · invalid',
      type: 'Widget? · Widget? · Widget? · bool?'
    }),
    from('PlFilePicker', 'title', { type: 'Widget?', default: "Text('Choose files')" }),
    from('PlFilePicker', 'hint', { type: 'Widget?' }),
    from('PlFilePicker', 'icon', {
      type: 'Widget?',
      description: {
        ko: '제목 위의 글리프. 생략하면 업로드 표식이 쓰입니다',
        en: 'The glyph above the title. The upload mark if it is left out'
      }
    }),
    {
      name: 'showIcon',
      type: 'bool',
      default: 'true',
      description: {
        ko: '글리프를 그릴지. Dart에는 null도 위젯도 아닌 값이 없으니 "치워라"가 자기 이름을 가집니다',
        en: 'Draws a glyph at all. Dart has no value that is neither null nor a widget, so "take it away" gets its own name'
      }
    },
    from('PlFilePicker', 'showList', { type: 'bool', default: 'true' }),
    from('PlFilePicker', 'removeLabel', {
      type: 'String Function(String name)',
      default: "'Remove {name}'"
    }),
    from('PlFilePicker', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlFilePicker', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlFilePicker', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlFilePicker', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlFilePicker', 'elevation', { type: 'int', default: '0' }),
    from('PlFilePicker', 'fullWidth', { type: 'bool', default: 'true' }),
    from('PlFilePicker', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlFilePicker', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlFile: [
    {
      name: 'name',
      type: 'String',
      required: true,
      description: { ko: '파일 이름, 확장자까지', en: 'What it is called, extension and all' }
    },
    {
      name: 'size',
      type: 'int',
      required: true,
      description: { ko: '몇 바이트인지', en: 'How many bytes it is' }
    },
    {
      name: 'mimeType',
      type: 'String?',
      description: {
        ko: '종류 — image/png. 생략하면 accept는 확장자만 봅니다',
        en: 'Its kind — image/png. Left out, only the extension is checked against accept'
      }
    },
    {
      name: 'source',
      type: 'Object?',
      description: {
        ko: '앱 자신의 picker가 건넨 것. picker는 들여다보지 않습니다',
        en: "Whatever the app's own picker handed over. The picker never looks at it"
      }
    },
    {
      name: 'readableSize',
      type: 'String',
      description: {
        ko: '파일 목록을 읽는 사람이 기대하는 단위의 1.4 MB. 1024가 아니라 1000 기준입니다',
        en: '1.4 MB, in the units a person reading a file list expects. Base 1000 rather than 1024'
      }
    },
    {
      name: 'matches',
      type: 'bool Function(String accept)',
      description: {
        ko: 'accept 문자열과 맞는지. .ext, type/subtype, type/* 세 형태 모두',
        en: 'Whether it matches an accept string — all three forms: .ext, type/subtype, type/*'
      }
    }
  ],

  PlFloatingBottomNavigation: [
    from('PlFloatingBottomNavigation', 'children', {
      name: 'items',
      type: 'List<PlFloatingBottomNavigationItem<T>>',
      required: true,
      description: {
        ko: '목적지들. children이 아니라 설명의 목록입니다',
        en: 'The destinations, as a list of descriptions rather than children'
      }
    }),
    from('PlFloatingBottomNavigation', 'value', { type: 'T?', required: true }),
    from('PlFloatingBottomNavigation', 'onValueChange', {
      name: 'onChanged',
      type: 'ValueChanged<T>?'
    }),
    from('PlFloatingBottomNavigation', 'variant', {
      type: VARIANT,
      default: 'PlassVariant.glass'
    }),
    from('PlFloatingBottomNavigation', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlFloatingBottomNavigation', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlFloatingBottomNavigation', 'density', {
      type: DENSITY,
      default: 'PlassDensity.standard'
    }),
    from('PlFloatingBottomNavigation', 'elevation', { type: 'int', default: '2' }),
    from('PlFloatingBottomNavigation', 'safeArea', { type: 'bool', default: 'true' }),
    from('PlFloatingBottomNavigation', 'disabled', { type: 'bool', default: 'false' }),
    from('PlFloatingBottomNavigation', 'label', { type: 'String?' })
  ],

  PlFloatingBottomNavigationItem: [
    from('PlFloatingBottomNavigationItem', 'value', { type: 'T', required: true }),
    from('PlFloatingBottomNavigationItem', 'children', {
      name: 'label',
      type: 'String',
      required: true,
      description: {
        ko: '목적지의 이름. 필수이고 절대 그려지지 않습니다 — 언제나 읽히기만 합니다',
        en: "The destination's name. Required and never drawn — only ever read"
      }
    }),
    from('PlFloatingBottomNavigationItem', 'icon', { type: 'Widget?' }),
    from('PlFloatingBottomNavigationItem', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlForm: [
    {
      name: 'children',
      type: 'List<Widget>',
      required: true,
      description: { ko: '필드들과 제출 버튼', en: 'The fields, and the button that submits them' }
    },
    from('PlForm', 'errors', {
      type: 'Map<String, String>',
      default: 'const {}',
      description: {
        ko: '앱 자신의 검증 바깥에서 온 오류를 필드 이름으로 묶은 것. PlFormScope.errorFor로 읽어 필드의 error에 넘깁니다',
        en: "Errors from outside the app's own validation, keyed by the name of the field each belongs to. Read with PlFormScope.errorFor and handed to a field's error"
      }
    }),
    from('PlForm', 'onSubmit', {
      type: 'VoidCallback?',
      description: {
        ko: '유효한 제출에서 호출됩니다. 값은 함께 오지 않습니다 — 여기서 필드는 호출자가 만든 controller를 쥐고 있으므로 값은 이미 호출자의 것입니다',
        en: 'Called on a valid submit — with no values, because a field here holds a controller the caller made, so the caller already has them'
      }
    }),
    from('PlForm', 'validationMode', {
      type: 'PlFormValidationMode',
      default: 'PlFormValidationMode.onSubmit',
      description: {
        ko: '안의 FormField가 언제 유효성을 판단하는지. Flutter의 AutovalidateMode로 옮겨집니다',
        en: 'When a FormField inside decides whether it is valid. It maps onto a Flutter AutovalidateMode'
      }
    }),
    from('PlForm', 'size', { type: SIZE, default: 'PlassSize.md' })
  ],

  PlFormScope: [
    {
      name: 'errors',
      type: 'Map<String, String>',
      description: { ko: '폼이 지닌 오류들', en: 'The errors the form is holding' }
    },
    {
      name: 'errorFor',
      type: 'String? Function(String name)',
      description: {
        ko: '해당 이름의 필드에 대한 메시지, 없으면 null',
        en: 'The message for the field called name, or null when there is none'
      }
    },
    {
      name: 'submit',
      type: 'bool Function()',
      description: {
        ko: '폼의 모든 FormField를 검증하고, 전부 통과하면 onSubmit을 부릅니다',
        en: "Validates every FormField in the form and, if they all pass, calls the form's onSubmit"
      }
    },
    {
      name: 'maybeOf',
      type: 'static PlFormScope? Function(BuildContext)',
      description: {
        ko: 'context 위의 폼, 없으면 null',
        en: 'The form above a context, or null when there is not one'
      }
    }
  ],

  PlGrid: [
    from('PlGrid', 'children', {
      name: 'items',
      type: 'List<PlGridItem>',
      required: true,
      description: {
        ko: '칸들. children이 아니라 설명의 목록입니다 — 그리드가 각 칸이 몇 칸을 쓰는지 알아야 줄로 묶을 수 있습니다',
        en: 'The cells, as a list of descriptions rather than children — the grid has to know what each one takes to pack them into rows'
      }
    }),
    from('PlGrid', 'columns', {
      type: 'PlassResponsive<int>',
      default: 'PlassResponsive(12)'
    }),
    from('PlGrid', 'spacing', {
      type: 'PlassResponsive<double>',
      default: 'PlassResponsive(2)',
      description: {
        ko: '칸 사이 간격. Tailwind spacing 스케일이라 4는 논리 픽셀 16이고, 분수도 됩니다',
        en: "The gutter between cells, on Tailwind's spacing scale — 4 is 16 logical pixels, and fractions are allowed"
      }
    }),
    from('PlGrid', 'rowSpacing · columnSpacing', { type: 'PlassResponsive<double>?' }),
    from('PlGrid', 'justify', { type: 'PlassJustify', default: 'PlassJustify.start' }),
    from('PlGrid', 'alignItems', {
      type: 'PlassAlignItems',
      default: 'PlassAlignItems.stretch'
    }),
    from('PlGrid', 'alignContent', { type: 'PlassJustify?' }),
    from('PlGrid', 'wrap', {
      type: 'bool',
      default: 'true',
      description: {
        ko: '칸이 모자란 줄이 다음 줄로 이어질지. 끄면 한 줄이 되고, 그 줄은 옆으로 스크롤합니다',
        en: 'Whether a row that runs out of columns continues on the next one. Off gives one row, and that row scrolls sideways'
      }
    })
  ],

  PlGridItem: [
    from('PlGridItem', 'children', { name: 'child', type: 'Widget', required: true }),
    from('PlGridItem', 'span', { type: 'PlassResponsive<int>?' }),
    from('PlGridItem', 'offset', { type: 'PlassResponsive<int>?' }),
    from('PlGridItem', 'alignSelf', {
      type: 'PlassAlignSelf?',
      description: {
        ko: '이 칸 하나만 줄의 alignItems를 덮어씁니다. baseline은 없습니다 — Flutter의 줄은 하나의 기준선으로 정렬되거나 아예 아닙니다',
        en: "Overrides the row's alignItems for this cell alone. There is no baseline here — a Flutter row is aligned on one baseline or on none"
      }
    })
  ],

  PlFloatingActionButton: [
    from('PlFloatingActionButton', 'icon', { type: 'Widget', required: true }),
    from('PlFloatingActionButton', 'label', { type: 'String', required: true }),
    {
      name: 'onPressed',
      type: 'VoidCallback?',
      description: {
        ko: '누르면 하는 일. null이면 버튼이 비활성화됩니다',
        en: 'What pressing it does. Leaving it null disables the button'
      }
    },
    from('PlFloatingActionButton', 'extended', { type: 'bool', default: 'false' }),
    from('PlFloatingActionButton', 'corner', {
      type: 'PlassCorner',
      default: 'PlassCorner.bottomEnd'
    }),
    from('PlFloatingActionButton', 'offset', { type: 'double', default: '24' }),
    from('PlFloatingActionButton', 'floating', { type: 'bool', default: 'true' }),
    from('PlFloatingActionButton', 'variant', { type: VARIANT, default: 'PlassVariant.solid' }),
    from('PlFloatingActionButton', 'size', { type: SIZE, default: 'PlassSize.lg' }),
    from('PlFloatingActionButton', 'elevation', { type: 'int', default: '3' })
  ],

  PlFooter: [
    from('PlFooter', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlFooter', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlFooter', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlFooter', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlFooter', 'elevation', { type: 'int', default: '0' }),
    from('PlFooter', 'divider', { type: 'bool', default: 'true' }),
    from('PlFooter', 'maxWidth', {
      type: 'PlassResponsive<PlContainerWidth?>?',
      default: 'null',
      description: {
        ko: '내용이 넓어질 수 있는 한계. PlContainerWidth.rung(PlassSize)는 사다리 한 칸, PlContainerWidth.pixels(double)는 정확한 너비입니다. null은 제한 없음이고, 항목으로 써도 그렇습니다',
        en: 'How wide the content is allowed to get. PlContainerWidth.rung(PlassSize) is a rung of the ladder and PlContainerWidth.pixels(double) is an exact width. null means no limit, including as an entry'
      }
    }),
    from('PlFooter', 'padded', { type: 'bool', default: 'true' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '스크린 리더가 이 영역을 부르는 이름. 화면에 footer가 둘일 때 써 둘 값어치가 있습니다',
        en: 'The name a screen reader gives the region. Worth writing when a screen has two footers in it'
      }
    },
    from('PlFooter', 'children', { name: 'child', type: 'Widget?' })
  ],

  PlHeader: [
    from('PlHeader', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlHeader', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlHeader', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlHeader', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlHeader', 'elevation', { type: 'int', default: '0' }),
    from('PlHeader', 'brand', {
      type: 'List<Widget>?',
      description: {
        ko: '앞쪽 슬롯 — 로고, 제품 이름. 슬롯은 행이므로 리스트입니다. 로고와 그 옆 이름 사이의 간격은 바가 정합니다',
        en: "The leading slot: the logo, the product's name. A list because a slot is a row — the gap between a logo and the name beside it is the bar's to decide"
      }
    }),
    from('PlHeader', 'actions', { type: 'List<Widget>?' }),
    from('PlHeader', 'align', { type: 'PlassAlign', default: 'PlassAlign.start' }),
    from('PlHeader', 'divider', { type: 'bool', default: 'true' }),
    from('PlHeader', 'maxWidth', {
      type: 'PlassResponsive<PlContainerWidth?>?',
      default: 'null',
      description: {
        ko: '내용이 넓어질 수 있는 한계. PlContainerWidth.rung(PlassSize)는 사다리 한 칸, PlContainerWidth.pixels(double)는 정확한 너비입니다. null은 제한 없음이고, 항목으로 써도 그렇습니다',
        en: 'How wide the content is allowed to get. PlContainerWidth.rung(PlassSize) is a rung of the ladder and PlContainerWidth.pixels(double) is an exact width. null means no limit, including as an entry'
      }
    }),
    from('PlHeader', 'padded', { type: 'bool', default: 'true' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '스크린 리더가 바를 부르는 이름. 이름을 주면 landmark(region)가 되고, 없으면 아무것도 주장하지 않습니다 — 라벨 없는 region은 아무것도 설명하지 못한다는 프레임워크의 규칙입니다',
        en: "The name a screen reader gives the bar. Naming it also makes it a region landmark; without a name it claims nothing, which is the framework's rule rather than this package's"
      }
    },
    from('PlHeader', 'children', { name: 'child', type: 'Widget?' })
  ],

  PlHighlight: [
    from('PlHighlight', 'children', {
      name: 'text',
      type: 'String',
      required: true,
      description: {
        ko: '검색할 텍스트, 첫 번째 위치 인자. React와 달리 위젯 트리가 아닙니다 — Widget은 불투명해서 안의 텍스트에 닿을 수 없습니다',
        en: 'The text to search, as the first positional argument. Not a widget tree as in React: a Widget is opaque, and there is no reaching the text inside one'
      }
    }),
    from('PlHighlight', 'query', {
      type: 'Object',
      required: true,
      description: {
        ko: '찾을 것: String, RegExp, 또는 둘 중 하나의 List. Dart에 union이 없어 Object이고, 생성자가 단언합니다. 여러 개면 긴 것부터 시도합니다',
        en: 'What to find: a String, a RegExp, or a List of either. Object because Dart has no union; the constructor asserts it. Several terms are tried longest first'
      }
    }),
    from('PlHighlight', 'variant', { type: VARIANT, default: 'PlassVariant.solid' }),
    from('PlHighlight', 'color', { type: COLOR, default: 'PlassColor.warning' }),
    from('PlHighlight', 'caseSensitive', { type: 'bool', default: 'false' }),
    from('PlHighlight', 'wholeWord', { type: 'bool', default: 'false' }),
    from('PlHighlight', 'underline', { type: 'bool', default: 'false' }),
    from('PlHighlight', 'weight', { type: 'PlTypographyWeight?' }),
    {
      name: 'style',
      type: 'TextStyle?',
      description: {
        ko: '표시되지 않은 글의 스타일. 주변 DefaultTextStyle 위에 병합됩니다',
        en: 'The style the unmarked text is set in. Merged onto whatever the surrounding DefaultTextStyle asked for'
      }
    },
    {
      name: 'align',
      type: 'TextAlign?',
      description: { ko: '텍스트 정렬', en: 'Text alignment' }
    },
    {
      name: 'lines',
      type: 'int?',
      description: {
        ko: '이 줄 수로 잘라 말줄임합니다',
        en: 'Clamps the text to this many lines with an ellipsis'
      }
    }
  ],

  PlHotKeys: [
    from('PlHotKeys', 'keys', {
      type: 'Object?',
      description: {
        ko: '키들. + 로 나뉘는 String이거나, 키 자체가 +인 단축키를 위한 List<String>입니다. Dart에 union이 없어 Object입니다',
        en: 'The keys: a String split on +, or a List<String> for the shortcut whose key is a plus. Object because Dart has no union type'
      }
    }),
    from('PlHotKeys', 'cluster', { type: 'PlHotKeysCluster?' }),
    from('PlHotKeys', 'os', { type: 'PlHotKeysOS', default: 'PlHotKeysOS.auto' }),
    from('PlHotKeys', 'separator', { type: 'Widget?' }),
    ...capProps
  ],

  PlKbd: [
    {
      name: 'child',
      type: 'Widget',
      required: true,
      description: { ko: '캡에 인쇄된 것', en: 'What is printed on the cap' }
    },
    ...capProps,
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '인쇄된 글자 대신 스크린 리더가 읽을 이름. ⌘는 "place of interest sign"으로 읽히는데, 그것은 아무도 가지고 있지 않은 키입니다',
        en: 'What a screen reader says instead of what is printed. ⌘ read out is "place of interest sign", which is not a key anybody has'
      }
    }
  ],

  PlIconButton: [
    from('PlIconButton', 'icon', { type: 'Widget', required: true }),
    from('PlIconButton', 'label', { type: 'String', required: true }),
    {
      name: 'onPressed',
      type: 'VoidCallback?',
      description: {
        ko: '눌렸을 때 호출됩니다. 주지 않으면 버튼이 비활성화됩니다',
        en: 'Called when the button is activated. Leaving it null disables the button'
      }
    },
    {
      name: 'onLongPress',
      type: 'VoidCallback?',
      description: { ko: '길게 눌렀을 때', en: 'Called on a long press' }
    },
    // Nullable for the same reason `PlButton`'s are: a disc in a run inherits.
    from('PlIconButton', 'variant', { type: `${VARIANT}?`, default: 'PlassVariant.solid' }),
    from('PlIconButton', 'size', { type: `${SIZE}?`, default: 'PlassSize.md' }),
    from('PlIconButton', 'color', { type: `${COLOR}?`, default: 'PlassColor.primary' }),
    from('PlIconButton', 'elevation', { type: 'int?', default: '1' }),
    from('PlIconButton', 'loading', { type: 'bool', default: 'false' }),
    from('PlIconButton', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlIconButton', 'disabled', { type: 'bool?', default: 'false' }),
    {
      name: 'focusNode · autofocus',
      type: 'FocusNode? · bool',
      description: {
        ko: '포커스를 밖에서 제어하거나, 트리에 들어가면서 포커스를 가져갑니다',
        en: 'Drive focus from outside, or take it on insertion'
      }
    }
  ],

  PlHoverCard: [
    from('PlHoverCard', 'trigger', { type: 'Widget', required: true }),
    from('PlHoverCard', 'title · description', { type: 'Widget?' }),
    from('PlHoverCard', 'children', { name: 'child', type: 'Widget?' }),
    from('PlHoverCard', 'side', { type: 'PlassSide', default: 'PlassSide.bottom' }),
    from('PlHoverCard', 'align', { type: 'PlassAlign', default: 'PlassAlign.center' }),
    from('PlHoverCard', 'sideOffset · alignOffset', {
      name: 'offset',
      type: 'double',
      default: '8'
    }),
    from('PlHoverCard', 'delay', { type: 'Duration', default: '600ms' }),
    from('PlHoverCard', 'closeDelay', { type: 'Duration', default: '300ms' }),
    from('PlHoverCard', 'arrow', { type: 'bool', default: 'false' }),
    from('PlHoverCard', 'open · defaultOpen · onOpenChange', {
      name: 'open · onOpenChanged',
      type: 'bool? · ValueChanged<bool>?'
    }),
    {
      name: 'disabled',
      type: 'bool',
      default: 'false',
      description: {
        ko: '트리거를 비활성화하지 않으면서 카드만 열리지 않게 합니다',
        en: 'Stops the card opening at all, without disabling the trigger'
      }
    },
    from('PlHoverCard', 'width', { type: 'double?' }),
    from('PlHoverCard', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlHoverCard', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlHoverCard', 'density', { type: DENSITY, default: 'PlassDensity.standard' })
  ],

  PlHowToSteps: [
    {
      name: 'steps',
      type: 'List<PlHowToStep>',
      required: true,
      description: {
        ko: '따라야 할 순서대로의 지시들',
        en: 'The instructions, in the order they are to be followed'
      }
    },
    from('PlHowToSteps', 'active', { type: 'int?' }),
    from('PlHowToSteps', 'numbered', { type: 'bool', default: 'true' }),
    from('PlHowToSteps', 'connector', {
      type: 'PlHowToStepsConnector',
      default: 'PlassStepConnector.solid'
    }),
    {
      name: 'semanticStepLabel',
      type: 'String Function(int step, int total)?',
      default: "'Step 2 of 5'",
      description: {
        ko: '스크린 리더가 각 단계 앞에 듣는 말. React는 진짜 <ol>에서 공짜로 얻지만 Flutter에는 물려받을 순서 목록이 없습니다',
        en: 'What a screen reader hears before each step. React gets it free from a real <ol>; Flutter has no ordered list to inherit it from'
      }
    },
    from('PlHowToSteps', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlHowToSteps', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlHowToSteps', 'density', { type: DENSITY, default: 'PlassDensity.standard' })
  ],

  PlHowToStep: [
    from('PlHowToStep', 'title', { type: 'Widget?' }),
    from('PlHowToStep', 'children', { name: 'child', type: 'Widget?' }),
    from('PlHowToStep', 'icon', { type: 'Widget?' }),
    from('PlHowToStep', 'status', { type: 'PlHowToStepStatus?' })
  ],

  PlIcon: [
    from('PlIcon', 'icon', { type: 'Widget', required: true }),
    from('PlIcon', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlIcon', 'color', {
      // Dart has no `inherit` keyword, and a nullable enum says the same thing
      // with one less name in it.
      type: `${COLOR}?`,
      default: 'null',
      description: {
        ko: '의미론적 색 역할. null이면 놓인 자리의 색을 그대로 씁니다. 이 prop이 primary가 아닌 유일한 컴포넌트입니다 — 아이콘은 콘텐츠라, 색은 대개 이미 정해져 있습니다',
        en: 'Semantic colour role. null takes the colour of whatever it sits in. The one component where this is not primary — an icon is content, and its colour has usually been decided already'
      }
    }),
    from('PlIcon', 'label', { type: 'String?' })
  ],

  PlList: [
    from('PlList', 'children', {
      type: 'List<Widget>',
      required: true,
      description: { ko: '행들', en: 'The rows' }
    }),
    from('PlList', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlList', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlList', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlList', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlList', 'elevation', { type: 'int', default: '0' }),
    from('PlList', 'dividers', { type: 'bool', default: 'false' })
  ],

  PlListItem: [
    from('PlListItem', 'children', { name: 'child', type: 'Widget?' }),
    from('PlListItem', 'onClick', { name: 'onPressed', type: 'VoidCallback?' }),
    from('PlListItem', 'startIcon', { type: 'Widget?' }),
    from('PlListItem', 'endIcon', { type: 'Widget?' }),
    from('PlListItem', 'description', { type: 'Widget?' }),
    from('PlListItem', 'action', { type: 'Widget?' }),
    from('PlListItem', 'selected', { type: 'bool', default: 'false' }),
    from('PlListItem', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlMenu: [
    from('PlMenu', 'children', {
      name: 'items',
      type: 'List<PlMenuEntry>',
      required: true,
      description: {
        ko: '행들. children이 아니라 설명의 목록입니다 — 메뉴가 강조 이동과 타이프어헤드를 직접 소유해야 합니다',
        en: 'The rows, as a list of descriptions rather than children — the menu owns the highlight and the typeahead itself'
      }
    }),
    from('PlMenu', 'trigger', {
      type: 'Widget Function(BuildContext, VoidCallback open, bool isOpen)',
      required: true,
      description: {
        ko: '메뉴를 여는 것. 위젯이 아니라 빌더입니다 — 트리거는 거의 언제나 자기가 열려 있는지 알고 싶어 합니다',
        en: 'What opens the menu. A builder rather than a widget, because a trigger almost always wants to know whether it is open'
      }
    }),
    from('PlMenu', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlMenu', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlMenu', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlMenu', 'side', { type: 'PlassSide', default: 'PlassSide.bottom' }),
    from('PlMenu', 'align', { type: 'PlassAlign', default: 'PlassAlign.start' }),
    from('PlMenu', 'sideOffset', { type: 'double', default: '6' }),
    from('PlMenu', 'loopFocus', { type: 'bool', default: 'true' }),
    from('PlMenu', 'disabled', { type: 'bool', default: 'false' }),
    {
      name: 'onOpenChange',
      type: 'ValueChanged<bool>?',
      description: {
        ko: '메뉴가 열리거나 닫힐 때마다 호출됩니다',
        en: 'Told whenever the menu opens or closes'
      }
    },
    {
      name: 'label',
      type: 'String?',
      description: {
        ko: '스크린 리더가 팝업을 부르는 이름',
        en: 'The name a screen reader gives the popup'
      }
    }
  ],

  PlMenuItem: [
    from('PlMenuItem', 'children', {
      name: 'label',
      type: 'String',
      required: true,
      description: {
        ko: '라벨. 위젯이 아니라 String입니다 — 그려지고, 안내되고, 타이프어헤드가 맞춰 보는 대상입니다',
        en: 'The label. A String rather than a widget: it is what is drawn, what is announced, and what typeahead matches against'
      }
    }),
    from('PlMenuItem', 'onClick', { name: 'onPressed', type: 'VoidCallback?' }),
    from('PlMenuItem', 'startIcon · endIcon', { type: 'Widget?' }),
    from('PlMenuItem', 'shortcut', { type: 'String?' }),
    from('PlMenuItem', 'description', { type: 'String?' }),
    from('PlMenuItem', 'color', { type: COLOR + '?' }),
    from('PlMenuItem', 'closeOnClick', { name: 'closeOnPress', type: 'bool', default: 'true' }),
    from('PlMenuItem', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlMenuCheckboxItem: [
    from('PlMenuCheckboxItem', 'checked · defaultChecked · onCheckedChange', {
      name: 'checked · onChanged',
      type: 'bool · ValueChanged<bool>?',
      description: {
        ko: '체크 상태. controlled입니다 — defaultChecked는 없습니다',
        en: 'The checked state. Controlled: there is no defaultChecked'
      }
    }),
    {
      name: 'selected · onPressed',
      type: 'bool · VoidCallback?',
      description: {
        ko: 'PlMenuRadioItem에만: 이 행이 고른 것인지, 그리고 고르면 무엇을 하는지. 값을 쥔 그룹이 아니라 행이 듣습니다',
        en: 'PlMenuRadioItem only: whether this is the chosen one, and what choosing it does. The row is told, rather than a group holding a value'
      }
    },
    from('PlMenuCheckboxItem', 'closeOnClick', {
      name: 'closeOnPress',
      type: 'bool',
      default: 'false'
    }),
    {
      name: 'label · endIcon · shortcut · description · color · disabled',
      type: '—',
      description: { ko: 'PlMenuItem과 같습니다', en: 'As on PlMenuItem' }
    }
  ],

  PlMenuSubmenu: [
    from('PlMenuSubmenu', 'label', { type: 'String', required: true }),
    from('PlMenuSubmenu', 'children', {
      name: 'items',
      type: 'List<PlMenuEntry>',
      required: true
    }),
    from('PlMenuSubmenu', 'startIcon', { type: 'Widget?' }),
    from('PlMenuSubmenu', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlMenubar: [
    from('PlMenubar', 'children', {
      name: 'menus',
      type: 'List<PlMenubarMenu>',
      required: true,
      description: {
        ko: '메뉴들. 여기서는 조합된 자식이 아니라 데이터입니다',
        en: 'The menus — data here rather than composed children'
      }
    }),
    from('PlMenubar', 'orientation', {
      type: 'PlassOrientation',
      default: 'PlassOrientation.horizontal',
      description: { ko: '바가 늘어서는 방향', en: 'Which way the bar runs' }
    }),
    from('PlMenubar', 'disabled', { type: 'bool', default: 'false' }),
    from('PlMenubar', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlMenubar', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlMenubar', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '스크린 리더가 바를 부르는 이름',
        en: 'The name a screen reader gives the bar'
      }
    }
  ],

  PlMenubarMenu: [
    from('PlMenubarMenu', 'label', { type: 'String', required: true }),
    from('PlMenubarMenu', 'children', {
      name: 'items',
      type: 'List<PlMenuEntry>',
      required: true
    }),
    from('PlMenubarMenu', 'startIcon', { type: 'Widget?' }),
    from('PlMenubarMenu', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlModal: [
    from('PlModal', 'open', { type: 'bool', required: true }),
    from('PlModal', 'onOpenChange', {
      name: 'onOpenChanged',
      type: 'ValueChanged<bool>?',
      description: {
        ko: '열림 상태가 무엇이 되어야 하는지와 함께 불립니다. ×도 바깥 누름도 스스로 닫지 않고 이것을 부릅니다',
        en: 'Called with what the open state should become. The × and a press outside both report rather than act'
      }
    }),
    from('PlModal', 'title', { type: 'Widget?' }),
    from('PlModal', 'description', { type: 'Widget?' }),
    from('PlModal', 'actions', {
      type: 'List<Widget>?',
      description: {
        ko: '아래쪽 줄. 끝 정렬로 감기므로 버튼 두 개에 따로 Row가 필요 없습니다',
        en: 'The bottom row, end-aligned and wrapping, so a pair of buttons needs no row of its own'
      }
    }),
    from('PlModal', 'children', { name: 'child', type: 'Widget?' }),
    from('PlModal', 'dividers', { type: 'bool', default: 'true' }),
    from('PlModal', 'showClose', { type: 'bool', default: 'true' }),
    from('PlModal', 'closeLabel', { type: 'String', default: "'Close'" }),
    from('PlModal', 'width', {
      type: 'double?',
      description: {
        ko: 'size가 정하는 최대 너비를 덮어씁니다. 논리 픽셀입니다',
        en: 'A hard cap on the width, overriding the one size implies. In logical pixels'
      }
    }),
    from('PlModal', 'fullWidth', { type: 'bool', default: 'true' }),
    from('PlModal', 'fullScreen', { type: 'bool', default: 'false' }),
    from('PlModal', 'modal', {
      type: 'bool',
      default: 'true',
      description: {
        ko: '뒤 페이지를 포인터에게서도 가져갈지. false는 누를 수 있게 두면서 focus만 가둡니다',
        en: 'Whether the page behind is taken away for the pointer as well as the keyboard. false leaves it clickable while still holding focus inside'
      }
    }),
    from('PlModal', 'dismissible', { type: 'bool', default: 'true' }),
    from('PlModal', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlModal', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlModal', 'density', { type: DENSITY, default: 'PlassDensity.standard' })
  ],

  PlNavigationMenu: [
    from('PlNavigationMenu', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlNavigationMenu', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlNavigationMenu', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    {
      name: 'items',
      type: 'List<PlNavigationMenuItem>',
      required: true,
      description: {
        ko: '항목들. 여기서는 조합된 자식이 아니라 데이터입니다 — 어느 항목이 양 끝인지, 어느 것이 열려 있는지를 행이 알아야 하기 때문입니다',
        en: 'The items — data here rather than composed children, because the row has to know which item is which to open one panel at a time'
      }
    },
    from('PlNavigationMenu', 'value', {
      name: 'initialValue',
      type: 'String?',
      description: {
        ko: '어느 항목의 패널이 열린 채로 시작할지. controlled 모드는 없습니다 — 어느 패널이 열려 있는지는 앱의 데이터가 아니라 포인터와 키보드의 것입니다',
        en: "Which item's panel starts open. There is no controlled mode: which panel is open is the pointer's and the keyboard's, not the app's data"
      }
    }),
    from('PlNavigationMenu', 'onValueChange', {
      name: 'onValueChanged',
      type: 'ValueChanged<String?>?'
    }),
    from('PlNavigationMenu', 'orientation', {
      type: 'PlassOrientation',
      default: 'PlassOrientation.horizontal'
    }),
    from('PlNavigationMenu', 'delay', {
      type: 'Duration',
      default: 'Duration(milliseconds: 50)'
    }),
    from('PlNavigationMenu', 'closeDelay', {
      type: 'Duration',
      default: 'Duration(milliseconds: 100)'
    }),
    from('PlNavigationMenu', 'sideOffset', { type: 'double', default: '8' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '내비게이션 영역이 불리는 이름. 화면에 둘 이상 있을 때 반드시 써야 합니다',
        en: 'The name the navigation region is announced by. Required when a screen has more than one'
      }
    }
  ],

  PlNavigationMenuItem: [
    from('PlNavigationMenuItem', 'label', { type: 'String', required: true }),
    from('PlNavigationMenuItem', 'value', {
      type: 'String?',
      description: {
        ko: '메뉴의 값 안에서 항목을 식별합니다. 없으면 label이 쓰입니다',
        en: "Identifies the item in the menu's value. Left out, the label is used"
      }
    }),
    from('PlNavigationMenuItem', 'href', {
      name: 'onPressed',
      type: 'VoidCallback?',
      description: {
        ko: '패널을 여는 대신 목적지로 만듭니다. 여기에는 href가 없습니다 — 목적지가 어디인지는 앱의 라우터가 정합니다',
        en: "Makes the item a destination rather than something that opens a panel. There is no href here: where a destination is belongs to the app's own router"
      }
    }),
    from('PlNavigationMenuItem', 'startIcon', { type: 'Widget?' }),
    from('PlNavigationMenuItem', 'disabled', { type: 'bool', default: 'false' }),
    from('PlNavigationMenuItem', 'columns', { type: 'int', default: '1' }),
    from('PlNavigationMenuItem', 'children', {
      name: 'links',
      type: 'List<PlNavigationMenuLink>',
      default: 'const []'
    })
  ],

  PlNavigationMenuLink: [
    from('PlNavigationMenuLink', 'title', { type: 'String', required: true }),
    from('PlNavigationMenuLink', 'description', { type: 'String?' }),
    from('PlNavigationMenuLink', 'startIcon', { type: 'Widget?' }),
    from('PlNavigationMenuLink', 'href', {
      name: 'onPressed',
      type: 'VoidCallback?',
      description: {
        ko: '어디로 가는지. 이 패키지에는 navigator가 없으므로 그것을 정하는 자리가 여기입니다',
        en: 'Where it goes. There is no navigator in this package, so this is where that is decided'
      }
    })
  ],

  PlNumberField: [
    from('PlNumberField', 'value', { type: 'double?', required: true }),
    from('PlNumberField', 'onValueChange', {
      name: 'onChanged',
      type: 'ValueChanged<double?>?',
      description: {
        ko: '키를 누를 때마다, 걸음마다, 휠마다. 정착한 값이 아니라 입력된 값을 보고합니다',
        en: 'Called on every change — a keystroke, a step, the wheel. It reports what has been typed, not what it will settle to'
      }
    }),
    from('PlNumberField', 'onValueCommitted', {
      name: 'onCommitted',
      type: 'ValueChanged<double?>?'
    }),
    from('PlNumberField', 'min', { type: 'double?' }),
    from('PlNumberField', 'max', { type: 'double?' }),
    from('PlNumberField', 'step', { type: 'double', default: '1' }),
    from('PlNumberField', 'largeStep', { type: 'double', default: '10' }),
    from('PlNumberField', 'smallStep', { type: 'double', default: '0.1' }),
    from('PlNumberField', 'snapOnStep', { type: 'bool', default: 'false' }),
    from('PlNumberField', 'allowWheelScrub', { type: 'bool', default: 'false' }),
    from('PlNumberField', 'format', {
      type: 'String Function(double value)?',
      description: {
        ko: '정착한 값을 어떻게 쓸지. Dart SDK에는 Intl.NumberFormat이 없으니 서식은 함수입니다',
        en: 'How a settled value is written. There is no Intl.NumberFormat in the Dart SDK, so the format is a function'
      }
    }),
    {
      name: 'parse',
      type: 'double? Function(String text)?',
      description: {
        ko: '입력된 글자를 어떻게 되읽을지. 생략하면 숫자와 부호, 소수점을 뺀 나머지를 버립니다',
        en: 'How typed text is read back. Left out, everything but digits, a sign and a decimal point is thrown away'
      }
    },
    from('PlNumberField', 'steppers', {
      type: 'PlNumberFieldSteppers',
      default: 'PlNumberFieldSteppers.end'
    }),
    from('PlNumberField', 'incrementLabel', { type: 'String', default: "'Increase'" }),
    from('PlNumberField', 'decrementLabel', { type: 'String', default: "'Decrease'" }),
    from('PlNumberField', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlNumberField', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlNumberField', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlNumberField', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlNumberField', 'elevation', { type: 'int', default: '0' }),
    from('PlNumberField', 'label', {
      type: 'Widget?',
      description: {
        ko: '컨트롤 위의 라벨. floating 형태는 일부러 없습니다 — floating label은 움직이는 글자입니다',
        en: 'Label above the control. There is no floating variant on purpose: a floating label is text that moves'
      }
    }),
    from('PlNumberField', 'description', { type: 'Widget?' }),
    from('PlNumberField', 'error', { type: 'Widget?' }),
    from('PlNumberField', 'invalid', { type: 'bool?' }),
    {
      name: 'placeholder',
      type: 'String?',
      description: {
        ko: '비어 있는 동안 보이는 글자',
        en: 'Shown while the field is empty'
      }
    },
    from('PlNumberField', 'startIcon', { type: 'Widget?' }),
    from('PlNumberField', 'endIcon', { type: 'Widget?' }),
    from('PlNumberField', 'fullWidth', { type: 'bool', default: 'false' }),
    from('PlNumberField', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlNumberField', 'disabled', { type: 'bool', default: 'false' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: 'field를 스크린 리더가 부를 이름',
        en: 'The name a screen reader gives the field'
      }
    },
    {
      name: 'focusNode',
      type: 'FocusNode?',
      description: { ko: '바깥에서 focus를 몹니다', en: 'Drive focus from outside' }
    },
    {
      name: 'autofocus',
      type: 'bool',
      default: 'false',
      description: {
        ko: '트리에 들어가는 순간 focus를 가져갑니다',
        en: 'Takes focus as it is inserted into the tree'
      }
    },
    hotKeysProp
  ],

  PlOtpField: [
    {
      name: 'controller',
      type: 'TextEditingController?',
      description: {
        ko: '입력 중인 코드. 주지 않으면 필드가 자기 것을 하나 듭니다',
        en: 'The code being typed. Left out, the field owns a controller of its own'
      }
    },
    from('PlOtpField', 'onValueChange', {
      name: 'onChanged',
      type: 'ValueChanged<String>?'
    }),
    from('PlOtpField', 'onComplete', {
      name: 'onCompleted',
      type: 'ValueChanged<String>?'
    }),
    from('PlOtpField', 'onValueInvalid', {
      name: 'onRejected',
      type: 'ValueChanged<String>?',
      description: {
        ko: 'charset이 거부한 글자들로 호출됩니다',
        en: 'Fires with the characters the charset rejected'
      }
    }),
    from('PlOtpField', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlOtpField', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlOtpField', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlOtpField', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlOtpField', 'elevation', { type: 'int', default: '0' }),
    from('PlOtpField', 'length', { type: 'int', default: '6' }),
    from('PlOtpField', 'charset', { type: 'PlOtpCharset', default: 'PlOtpCharset.numeric' }),
    from('PlOtpField', 'mask', { type: 'bool', default: 'false' }),
    from('PlOtpField', 'groupSize', { type: 'int?' }),
    from('PlOtpField', 'separator', { type: 'String', default: "'–'" }),
    from('PlOtpField', 'label · description · error', { type: 'Widget?' }),
    from('PlOtpField', 'invalid', { type: 'bool?' }),
    from('PlOtpField', 'disabled', { type: 'bool', default: 'false' }),
    from('PlOtpField', 'readOnly', { type: 'bool', default: 'false' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '스크린 리더가 줄을 부르는 이름',
        en: 'The name a screen reader announces for the row'
      }
    },
    {
      name: 'focusNode · autofocus',
      type: 'FocusNode? · bool',
      description: {
        ko: '포커스를 밖에서 제어하거나, 트리에 들어가면서 캐럿을 놓습니다',
        en: 'Drive focus from outside, or put the caret in the row on insertion'
      }
    },
    hotKeysProp
  ],

  PlOverlay: [
    from('PlOverlay', 'open', { type: 'bool', required: true }),
    from('PlOverlay', 'onOpenChange', {
      name: 'onOpenChanged',
      type: 'ValueChanged<bool>?',
      description: {
        ko: '오버레이가 닫히기를 청할 때 false와 함께 불립니다. dismissible이 켜져 있을 때만입니다',
        en: 'Called with false when the overlay asks to be closed — only ever when dismissible is on'
      }
    }),
    from('PlOverlay', 'children', { name: 'child', type: 'Widget?' }),
    from('PlOverlay', 'tone', { type: 'PlOverlayTone', default: 'PlOverlayTone.scrim' }),
    from('PlOverlay', 'dismissible', { type: 'bool', default: 'false' }),
    from('PlOverlay', 'modal', {
      type: 'bool',
      default: 'true',
      description: {
        ko: '뒤 페이지를 포인터에게서도 가져갈지. false는 누를 수 있게 두면서 focus만 가둡니다',
        en: 'Whether the page behind is taken away for the pointer as well as the keyboard. false leaves it clickable while still holding focus inside'
      }
    }),
    from('PlOverlay', 'align', { type: 'PlassAlign', default: 'PlassAlign.center' }),
    from('PlOverlay', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlOverlay', 'label', { type: 'String', default: "'Overlay'" })
  ],

  PlPageLayout: [
    from('PlPageLayout', 'header', { type: 'Widget?' }),
    from('PlPageLayout', 'footer', { type: 'Widget?' }),
    from('PlPageLayout', 'sidebar', { type: 'Widget?' }),
    from('PlPageLayout', 'endSidebar', { type: 'Widget?' }),
    from('PlPageLayout', 'headerSpan', {
      type: 'PlPageLayoutSpan',
      default: 'PlPageLayoutSpan.full'
    }),
    from('PlPageLayout', 'footerSpan', {
      type: 'PlPageLayoutSpan',
      default: 'PlPageLayoutSpan.full'
    }),
    from('PlPageLayout', 'collapseBelow', {
      type: 'PlassBreakpoint?',
      default: 'PlassBreakpoint.md',
      description: {
        ko: 'sidebar가 열이기를 그만두고 drawer가 되는 너비. null이면 어떤 너비에서도 열로 남습니다. 창이 아니라 이 레이아웃이 받은 공간과 비교합니다',
        en: 'The width below which the sidebars become drawers instead of columns. null keeps them columns at every width, and the comparison is against the space this layout was given rather than the window'
      }
    }),
    from('PlPageLayout', 'sidebarOpen', {
      type: 'bool?',
      description: {
        ko: '앞쪽 sidebar의 drawer가 열려 있는지. 넘기면 controlled가 되어 레이아웃은 상태를 쥐지 않습니다',
        en: "Whether the leading sidebar's drawer is open. Passing it makes the drawer controlled and the layout stops holding the state"
      }
    }),
    from('PlPageLayout', 'onSidebarOpenChange', {
      name: 'onSidebarOpenChanged',
      type: 'ValueChanged<bool>?'
    }),
    from('PlPageLayout', 'endSidebarOpen', {
      type: 'bool?',
      description: {
        ko: '뒤쪽 sidebar에 대한 같은 둘',
        en: 'The same two for the trailing sidebar'
      }
    }),
    from('PlPageLayout', 'onEndSidebarOpenChange', {
      name: 'onEndSidebarOpenChanged',
      type: 'ValueChanged<bool>?'
    }),
    {
      name: 'mainSemanticLabel',
      type: 'String?',
      description: {
        ko: '스크린 리더가 main 영역을 부르는 이름. 없으면 안에 든 것으로 불립니다',
        en: 'The name a screen reader gives the main region. Left out, it is announced by what is in it'
      }
    },
    from('PlPageLayout', 'children', { name: 'child', type: 'Widget?' })
  ],

  PlPagination: [
    from('PlPagination', 'count', { type: 'int', required: true }),
    from('PlPagination', 'page', { type: 'int', required: true }),
    from('PlPagination', 'onPageChange', {
      name: 'onPageChanged',
      type: 'ValueChanged<int>?'
    }),
    from('PlPagination', 'variant', { type: VARIANT, default: 'PlassVariant.ghost' }),
    from('PlPagination', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlPagination', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlPagination', 'density', { type: DENSITY, default: 'PlassDensity.compact' }),
    from('PlPagination', 'elevation', { type: 'int', default: '0' }),
    from('PlPagination', 'siblingCount', { type: 'int', default: '1' }),
    from('PlPagination', 'boundaryCount', { type: 'int', default: '1' }),
    from('PlPagination', 'showEdges', { type: 'bool', default: 'false' }),
    from('PlPagination', 'showArrows', { type: 'bool', default: 'true' }),
    from('PlPagination', 'disabled', { type: 'bool', default: 'false' }),
    from('PlPagination', 'label', { type: 'String', default: "'Pagination'" }),
    from('PlPagination', 'pageLabel', {
      type: 'String Function(int)',
      default: "(page) => 'Page $page'"
    }),
    {
      name: 'previousLabel · nextLabel · firstLabel · lastLabel',
      type: 'String',
      description: {
        ko: '이동 버튼들의 이름. 그려지지 않습니다',
        en: 'The names of the steppers. Never drawn'
      }
    }
  ],

  PlPanes: [
    from('PlPanes', 'children', {
      name: 'panes',
      type: 'List<PlPane>',
      required: true,
      description: {
        ko: '영역들. children이 아니라 설명의 목록입니다 — 세 크기 값을 읽는 것은 pane이 아니라 분할입니다',
        en: 'The regions, as a list of descriptions rather than children — the three sizing values are read by the split, not the pane'
      }
    }),
    from('PlPanes', 'orientation', {
      type: 'PlassResponsive<PlassOrientation>',
      default: 'PlassOrientation.horizontal'
    }),
    from('PlPanes', 'resizable', { type: 'bool', default: 'true' }),
    from('PlPanes', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlPanes', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlPanes', 'onResize', { type: 'ValueChanged<List<double>>?' }),
    from('PlPanes', 'onResizeEnd', { type: 'ValueChanged<List<double>>?' }),
    {
      name: 'label',
      type: 'String?',
      description: {
        ko: '스크린 리더가 손잡이를 부르는 이름. 그 뒤에 지금 몫이 값으로 붙습니다',
        en: 'What a screen reader calls a handle, before the share it is at'
      }
    }
  ],

  PlPane: [
    from('PlPane', 'children', { name: 'child', type: 'Widget', required: true }),
    from('PlPane', 'defaultSize', {
      type: 'PlPaneSize?',
      description: {
        ko: '시작 몫. PlPaneSize.percent 또는 PlPaneSize.pixels입니다 — Dart에는 number | string 유니온이 없습니다',
        en: 'The share it starts with, as PlPaneSize.percent or PlPaneSize.pixels — Dart has no number | string union'
      }
    }),
    from('PlPane', 'minSize', { type: 'PlPaneSize?' }),
    from('PlPane', 'maxSize', { type: 'PlPaneSize?' })
  ],

  /**
   * The bar, and the shared half of the indicators that follow it.
   *
   * `format` is the one prop that could not cross: there is no
   * `Intl.NumberFormat` in the framework to hand options to, and a package that
   * pulled `package:intl` in to provide one would be making a dependency
   * decision on its consumer's behalf. So the Dart side takes the function
   * instead of the options.
   */
  /** The ring takes the bar's table unchanged except for what `size` means. */
  PlProgressBox: [
    from('PlProgressBox', 'value', { type: 'double?', default: 'null' }),
    from('PlProgressBox', 'min', { type: 'double', default: '0' }),
    from('PlProgressBox', 'max', { type: 'double', default: '100' }),
    from('PlProgressBox', 'count', { type: 'int', default: '4' }),
    from('PlProgressBox', 'label', { type: 'Widget?' }),
    from('PlProgressBox', 'showValue', { type: 'bool', default: 'false' }),
    formatValueProp,
    from('PlProgressBox', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlProgressBox', 'color', { type: COLOR, default: 'PlassColor.primary' })
  ],

  PlProgressCircular: [
    from('PlProgressCircular', 'value', { type: 'double?', default: 'null' }),
    from('PlProgressCircular', 'min', { type: 'double', default: '0' }),
    from('PlProgressCircular', 'max', { type: 'double', default: '100' }),
    from('PlProgressCircular', 'label', { type: 'Widget?' }),
    from('PlProgressCircular', 'showValue', { type: 'bool', default: 'false' }),
    formatValueProp,
    from('PlProgressCircular', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlProgressCircular', 'color', { type: COLOR, default: 'PlassColor.primary' })
  ],

  PlMeter: [
    from('PlMeter', 'value', { type: 'double', required: true }),
    from('PlMeter', 'min', { type: 'double', default: '0' }),
    from('PlMeter', 'max', { type: 'double', default: '100' }),
    from('PlMeter', 'label', { type: 'Widget?' }),
    from('PlMeter', 'showValue', { type: 'bool', default: 'false' }),
    formatValueProp,
    from('PlMeter', 'thresholds', { type: 'List<PlMeterThreshold>?' }),
    from('PlMeter', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlMeter', 'color', { type: COLOR, default: 'PlassColor.primary' })
  ],

  PlMeterThreshold: [
    from('PlMeterThreshold', 'from', { type: 'double', required: true }),
    from('PlMeterThreshold', 'color', { type: COLOR, required: true })
  ],

  PlProgressLinear: [
    from('PlProgressLinear', 'value', { type: 'double?', default: 'null' }),
    from('PlProgressLinear', 'min', { type: 'double', default: '0' }),
    from('PlProgressLinear', 'max', { type: 'double', default: '100' }),
    from('PlProgressLinear', 'label', { type: 'Widget?' }),
    from('PlProgressLinear', 'showValue', { type: 'bool', default: 'false' }),
    formatValueProp,
    from('PlProgressLinear', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlProgressLinear', 'color', { type: COLOR, default: 'PlassColor.primary' })
  ],

  PlRadioGroup: [
    {
      name: 'options',
      type: 'List<PlRadioOption<T>>',
      required: true,
      description: {
        ko: '옵션들. children이 아니라 설명의 목록입니다 — 그룹이 roving focus와 화살표 키를 소유하므로 어느 것이 선택됐고 그다음이 무엇인지 알아야 합니다',
        en: 'The options, as a list of descriptions rather than children — the group owns the roving focus and the arrow keys, so it has to know which is chosen and what comes next'
      }
    },
    from('PlRadioGroup', 'value', {
      type: 'T?',
      required: true,
      description: {
        ko: '선택된 옵션, 또는 아무것도 선택되지 않았으면 null',
        en: 'Which option is chosen, or null for none'
      }
    }),
    from('PlRadioGroup', 'onValueChange', {
      name: 'onChanged',
      type: 'ValueChanged<T>?',
      description: {
        ko: '선택된 옵션을 알립니다. null이면 그룹이 비활성화됩니다',
        en: 'Called with the option that was chosen. Leaving it null disables the group'
      }
    }),
    from('PlRadioGroup', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlRadioGroup', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlRadioGroup', 'orientation', {
      type: 'PlassOrientation',
      default: 'PlassOrientation.vertical'
    }),
    from('PlRadioGroup', 'label', { type: 'Widget?' }),
    from('PlRadioGroup', 'description', { type: 'Widget?' }),
    from('PlRadioGroup', 'error', { type: 'Widget?' }),
    from('PlRadioGroup', 'invalid', { type: 'bool?' }),
    from('PlRadioGroup', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlRadioGroup', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlRadioOption: [
    from('PlRadio', 'value', { type: 'T', required: true }),
    from('PlRadio', 'label', { type: 'Widget?' }),
    from('PlRadio', 'description', { type: 'Widget?' }),
    from('PlRadio', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlSegment: [
    from('PlSegment', 'value', { type: 'T', required: true }),
    from('PlSegment', 'children', { name: 'label', type: 'Widget?' }),
    from('PlSegment', 'startIcon', { type: 'Widget?' }),
    from('PlSegment', 'endIcon', { type: 'Widget?' }),
    from('PlSegment', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlRating: [
    from('PlRating', 'value', {
      type: 'double',
      required: true,
      description: {
        ko: '점수. 0은 평가 없음입니다. controlled입니다 — defaultValue는 없습니다',
        en: 'The score. 0 is no rating at all. Controlled: there is no defaultValue'
      }
    }),
    from('PlRating', 'onValueChange', {
      name: 'onChanged',
      type: 'ValueChanged<double>?',
      description: {
        ko: '새 점수로 호출됩니다. 주지 않으면 점수가 그대로 굳습니다',
        en: 'Called with the new score. Leaving it out freezes the rating where it is'
      }
    }),
    from('PlRating', 'count', { type: 'int', default: '5' }),
    from('PlRating', 'precision', { type: 'double', default: '1' }),
    from('PlRating', 'icon · emptyIcon', { type: 'Widget?' }),
    from('PlRating', 'clearable', { type: 'bool', default: 'true' }),
    from('PlRating', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlRating', 'disabled', { type: 'bool', default: 'false' }),
    from('PlRating', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlRating', 'color', { type: COLOR, default: 'PlassColor.warning' }),
    from('PlRating', 'label', { type: 'String', default: "'Rating'" }),
    from('PlRating', 'valueLabel', {
      type: 'PlRatingValueLabel',
      default: 'PlRating.defaultValueLabel'
    }),
    {
      name: 'focusNode · autofocus',
      type: 'FocusNode? · bool',
      description: {
        ko: '포커스를 밖에서 제어하거나, 트리에 들어가면서 포커스를 가져갑니다',
        en: 'Drive focus from outside, or take it on insertion'
      }
    }
  ],

  PlSegmentedButton: [
    from('PlSegmentedButton', 'children', {
      name: 'segments',
      type: 'List<PlSegment<T>>',
      required: true,
      description: {
        ko: '선택지들. children이 아니라 설명의 목록입니다 — 묶음이 roving focus와 화살표 키, 미끄러지는 타일을 소유합니다',
        en: 'The choices, as a list of descriptions rather than children — the set owns the roving focus, the arrow keys and the sliding tile'
      }
    }),
    from('PlSegmentedButton', 'value', { type: 'T?', required: true }),
    from('PlSegmentedButton', 'onValueChange', {
      name: 'onChanged',
      type: 'ValueChanged<T>?'
    }),
    from('PlSegmentedButton', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlSegmentedButton', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlSegmentedButton', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlSegmentedButton', 'density', {
      type: DENSITY,
      default: 'PlassDensity.standard'
    }),
    from('PlSegmentedButton', 'elevation', { type: 'int', default: '0' }),
    from('PlSegmentedButton', 'fullWidth', { type: 'bool', default: 'false' }),
    from('PlSegmentedButton', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlSegmentedButton', 'disabled', { type: 'bool', default: 'false' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '묶음을 스크린 리더가 부를 이름. 눈에 보이는 자기 라벨이 없습니다',
        en: 'The name a screen reader gives the set. It has no visible label of its own'
      }
    }
  ],

  PlSelect: [
    from('PlSelect', 'items', {
      name: 'options',
      type: 'List<PlSelectOption<T>>',
      required: true,
      description: {
        ko: '선택지들. children이 아니라 설명의 목록입니다 — 팝업을 한 번도 열지 않은 trigger도 라벨을 알아야 합니다',
        en: 'The choices, as a list of descriptions rather than children — the trigger has to know the labels before the list has ever been opened'
      }
    }),
    from('PlSelect', 'value', { type: 'T?', required: true }),
    from('PlSelect', 'onValueChange', { name: 'onChanged', type: 'ValueChanged<T?>?' }),
    from('PlSelect', 'placeholder', { type: 'Widget?' }),
    from('PlSelect', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlSelect', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlSelect', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlSelect', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlSelect', 'elevation', {
      type: 'int',
      default: '0',
      description: {
        ko: 'trigger의 그림자 깊이. 목록은 사다리 꼭대기로 고정입니다 — 목록은 정말로 페이지 위에 떠 있습니다',
        en: 'Drop shadow depth of the trigger. The list has its own, fixed at the top of the ladder — it genuinely floats'
      }
    }),
    from('PlSelect', 'label', { type: 'Widget?' }),
    from('PlSelect', 'description', { type: 'Widget?' }),
    from('PlSelect', 'error', { type: 'Widget?' }),
    from('PlSelect', 'invalid', { type: 'bool?' }),
    from('PlSelect', 'startIcon', {
      type: 'Widget?',
      description: {
        ko: '값 앞에 놓이는 내용. 값의 1.2배로 그려져 글자 크기를 따라갑니다',
        en: 'Content before the value, drawn at 1.2× it so it tracks the text'
      }
    }),
    from('PlSelect', 'fullWidth', { type: 'bool', default: 'false' }),
    from('PlSelect', 'readOnly', {
      type: 'bool',
      default: 'false',
      description: {
        ko: '값은 보이지만 바꿀 수 없고, 목록도 열리지 않습니다',
        en: 'The value is shown but cannot be changed, and the list does not open'
      }
    }),
    from('PlSelect', 'disabled', { type: 'bool', default: 'false' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: 'select를 스크린 리더가 부를 이름',
        en: 'The name a screen reader gives the select'
      }
    },
    {
      name: 'focusNode',
      type: 'FocusNode?',
      description: { ko: '바깥에서 focus를 몹니다', en: 'Drive focus from outside' }
    },
    {
      name: 'autofocus',
      type: 'bool',
      default: 'false',
      description: {
        ko: '트리에 들어가는 순간 focus를 가져갑니다',
        en: 'Takes focus as it is inserted into the tree'
      }
    },
    {
      ...hotKeysProp,
      description: {
        ko: "trigger가 답할 chord들. PlHotKeys가 그리는 것과 같은 철자입니다 — { 'Mod+Enter': save, 'Escape': cancel }. 맞는 chord는 **소비됩니다**. 맨 Enter를 묶으면 목록을 열고 확정하던 trigger에게서 그 키를 가져옵니다",
        en: "Chords the trigger answers to, spelled the way PlHotKeys draws them — { 'Mod+Enter': save, 'Escape': cancel }. A chord that matches is **consumed** — binding a bare Enter takes it from the trigger, which otherwise uses it to open and commit the list"
      }
    }
  ],

  PlSelectOption: [
    from('PlSelectOption', 'value', {
      type: 'T',
      required: true,
      description: {
        ko: 'PlSelect.value가 담는 값이자 onChanged가 보고하는 값',
        en: 'What PlSelect.value holds, and what onChanged reports'
      }
    }),
    from('PlSelectOption', 'label', {
      type: 'Widget?',
      description: {
        ko: '목록과 trigger에 보이는 내용. 생략하면 값의 toString이 쓰입니다',
        en: "Shown in the list and in the trigger. The value's own toString if it is left out"
      }
    }),
    from('PlSelectOption', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlShow: [
    from('PlShow', 'from', { type: 'PlassBreakpointFloor?' }),
    from('PlShow', 'until', { type: 'PlassBreakpointFloor?' }),
    {
      name: 'child',
      type: 'Widget',
      required: true,
      description: {
        ko: '보이는 너비에서 보이는 것',
        en: 'What is shown, at the widths it is shown at'
      }
    }
  ],

  PlSidebar: [
    from('PlSidebar', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlSidebar', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlSidebar', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlSidebar', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlSidebar', 'elevation', { type: 'int', default: '0' }),
    from('PlSidebar', 'side', { type: 'PlassSidebarSide?', default: 'PlassSidebarSide.start' }),
    from('PlSidebar', 'width', { type: 'double?' }),
    from('PlSidebar', 'minWidth', { type: 'double', default: '160' }),
    from('PlSidebar', 'maxWidth', { type: 'double', default: '480' }),
    from('PlSidebar', 'resizable', { type: 'bool', default: 'false' }),
    from('PlSidebar', 'onResize', { type: 'ValueChanged<double>?' }),
    from('PlSidebar', 'onResizeEnd', { type: 'ValueChanged<double>?' }),
    from('PlSidebar', 'collapseBelow', {
      type: 'PlassBreakpoint?',
      description: {
        ko: '열이 drawer가 되는 창 너비. 없으면 위의 PlPageLayout이 정하고, 레이아웃 밖에서는 접히지 않습니다',
        en: 'The width below which the column becomes a drawer, measured against the window. Left out, the PlPageLayout above decides — and outside a layout it never collapses'
      }
    }),
    from('PlSidebar', 'open', { type: 'bool?' }),
    from('PlSidebar', 'onOpenChange', {
      name: 'onOpenChanged',
      type: 'ValueChanged<bool>?'
    }),
    from('PlSidebar', 'title', {
      type: 'Widget?',
      description: {
        ko: 'drawer일 때만 그려지는 제목. 없으면 semanticLabel이 제목이 됩니다 — 화면을 덮은 패널은 자기가 그리는 것으로 불립니다',
        en: 'The heading, drawn only while the sidebar is a drawer. Left out, semanticLabel is drawn as the heading instead: a panel that has covered the screen is named by what it draws'
      }
    }),
    from('PlSidebar', 'divider', { type: 'bool', default: 'true' }),
    from('PlSidebar', 'padded', { type: 'bool', default: 'true' }),
    from('PlSidebar', 'label', {
      name: 'semanticLabel',
      type: 'String',
      default: "'Sidebar'"
    }),
    from('PlSidebar', 'closeLabel', { type: 'String', default: "'Close sidebar'" }),
    from('PlSidebar', 'resizeLabel', { type: 'String', default: "'Resize sidebar'" }),
    from('PlSidebar', 'children', { name: 'child', type: 'Widget?' })
  ],

  PlSidebarTrigger: [
    from('PlSidebarTrigger', 'side', {
      type: 'PlassSidebarSide',
      default: 'PlassSidebarSide.start'
    }),
    from('PlSidebarTrigger', 'icon', { type: 'Widget?' }),
    from('PlSidebarTrigger', 'label', {
      type: 'String?',
      default: "'Open sidebar' / 'Close sidebar'"
    }),
    {
      name: 'variant',
      type: VARIANT,
      default: 'PlassVariant.ghost',
      shared: true,
      description: {
        ko: '키의 재질. 이미 시트인 바 위에 앉으므로 기본이 ghost입니다',
        en: 'What the key is made of. ghost by default: it sits on a bar that is already a sheet'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: 'PlassSize.md',
      shared: true,
      description: { ko: '키의 크기', en: "The key's size" }
    },
    {
      name: 'color',
      type: COLOR,
      default: 'PlassColor.primary',
      shared: true,
      description: { ko: '의미론적 색 역할', en: 'Semantic colour role' }
    }
  ],

  PlSkeleton: [
    from('PlSkeleton', 'shape', {
      type: 'PlSkeletonShape',
      default: 'PlSkeletonShape.line'
    }),
    from('PlSkeleton', 'lines', { type: 'int', default: '1' }),
    from('PlSkeleton', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlSkeleton', 'color', { type: COLOR, default: 'PlassColor.secondary' }),
    from('PlSkeleton', 'width', { type: 'double?' }),
    from('PlSkeleton', 'height', { type: 'double?' }),
    from('PlSkeleton', 'animated', { type: 'bool', default: 'true' }),
    from('PlSkeleton', 'label', {
      type: 'String?',
      description: {
        ko: '스크린 리더에 알릴 말. 없으면 semantics 트리에서 제외됩니다. 영역 전체를 대표하는 하나에만 주면 그 이름을 가진 live region이 됩니다',
        en: 'What a screen reader is told. Without it the placeholder stays out of the semantics tree; give the one that stands for the whole region a label and it becomes a live region with that name'
      }
    })
  ],

  PlSlider: [
    from('PlSlider', 'value', {
      name: 'values',
      type: 'List<double>',
      required: true,
      description: {
        ko: '고른 값, 또는 고른 구간의 양 끝. 값이 하나여도 목록입니다 — range로 만드는 것은 길이입니다',
        en: 'The chosen value, or the ends of the chosen range. Always a list: the length is what makes it a range'
      }
    }),
    from('PlSlider', 'onValueChange', {
      name: 'onChanged',
      type: 'ValueChanged<List<double>>?'
    }),
    {
      name: 'onChangeEnd',
      type: 'ValueChanged<List<double>>?',
      description: {
        ko: 'thumb을 놓았을 때 한 번',
        en: 'Called once, when the thumb is let go'
      }
    },
    from('PlSlider', 'min · max · step', { name: 'min · max · step', type: 'double' }),
    from('PlSlider', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlSlider', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlSlider', 'elevation', { type: 'int', default: '1' }),
    from('PlSlider', 'orientation', {
      type: 'PlassOrientation',
      default: 'PlassOrientation.horizontal'
    }),
    {
      name: 'length',
      type: 'double?',
      description: {
        ko: '구간의 길이. 세로 슬라이더는 자기 길이가 없으므로 여기서 받습니다 — 기본은 160',
        en: 'How long the run is. A vertical slider has no length of its own, so this is where one comes from — 160 by default'
      }
    },
    from('PlSlider', 'label', { type: 'Widget?' }),
    from('PlSlider', 'description', { type: 'Widget?' }),
    from('PlSlider', 'showValue', { type: 'bool', default: 'false' }),
    {
      name: 'formatValue',
      type: 'String Function(List<double>)?',
      description: {
        ko: '그 값을 어떻게 쓸지. 빼면 소수점 없이 찍고 en dash로 잇습니다',
        en: 'Formats that value. Left out, it is printed with no decimals and joined with an en dash'
      }
    },
    from('PlSlider', 'disabled', { type: 'bool', default: 'false' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '보이는 label이 없는 슬라이더를 스크린 리더가 부를 이름',
        en: 'The name a screen reader announces, for a slider with no visible label'
      }
    }
  ],

  PlSwitch: [
    from('PlSwitch', 'checked', {
      name: 'value',
      type: 'bool',
      required: true,
      description: {
        ko: '스위치가 켜져 있는지. controlled 전용입니다',
        en: 'Whether the switch is on. Controlled only'
      }
    }),
    from('PlSwitch', 'onCheckedChange', {
      name: 'onChanged',
      type: 'ValueChanged<bool>?',
      description: {
        ko: '값이 무엇이 되어야 하는지를 알립니다. null이면 비활성화됩니다',
        en: 'Called with what the value should become. Leaving it null disables the switch'
      }
    }),
    from('PlSwitch', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlSwitch', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlSwitch', 'label', { type: 'Widget?' }),
    from('PlSwitch', 'description', { type: 'Widget?' }),
    from('PlSwitch', 'error', { type: 'Widget?' }),
    from('PlSwitch', 'invalid', { type: 'bool?' }),
    from('PlSwitch', 'labelPlacement', {
      type: 'PlassAlign',
      default: 'PlassAlign.end',
      description: {
        ko: '라벨이 놓이는 쪽. center는 단언으로 막습니다 — switch의 라벨은 행의 한쪽 끝에 놓입니다',
        en: 'Which side the label sits on. PlassAlign.center asserts: a switch label sits at one end of a row or the other'
      }
    }),
    from('PlSwitch', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlSwitch', 'disabled', { type: 'bool', default: 'false' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '보이는 label이 없는 switch를 스크린 리더가 부를 이름',
        en: 'The name a screen reader announces, for a switch with no visible label'
      }
    }
  ],

  PlBox: [
    {
      name: 'child',
      type: 'Widget?',
      description: { ko: '시트 위에 놓이는 것', en: 'What is on the sheet' }
    },
    from('PlBox', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlBox', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlBox', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlBox', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlBox', 'elevation', { type: 'int', default: '0' }),
    from('PlBox', 'padded', { type: 'bool', default: 'true' }),
    {
      name: 'clipped',
      type: 'bool',
      default: 'false',
      description: {
        ko: '내용을 시트 자신의 모서리에서 잘라 냅니다. 클립은 자식이 바깥에 그리는 것까지 자르므로 기본은 꺼져 있습니다',
        en: "Clips the content to the sheet's own corners. Off by default: a clip also cuts anything a child draws outside itself"
      }
    }
  ],

  PlCarousel: [
    {
      name: 'children',
      type: 'List<Widget>',
      required: true,
      description: {
        ko: '슬라이드들. 자식 하나가 슬라이드 하나입니다',
        en: 'The slides. Every child becomes one'
      }
    },
    from('PlCarousel', 'value', { type: 'int', required: true }),
    {
      name: 'onChanged',
      type: 'ValueChanged<int>?',
      description: {
        ko: '보이게 되어야 할 슬라이드로 호출됩니다. 없으면 캐러셀은 그 자리에 얼어붙습니다',
        en: 'Called with the slide that should come into view. Left out, the carousel is frozen where it is'
      }
    },
    from('PlCarousel', 'loop', { type: 'bool', default: 'true' }),
    from('PlCarousel', 'autoPlay', { type: 'bool', default: 'false' }),
    from('PlCarousel', 'interval', {
      type: 'Duration',
      default: 'Duration(seconds: 5)'
    }),
    from('PlCarousel', 'arrows', { type: 'bool', default: 'true' }),
    from('PlCarousel', 'indicators', { type: 'bool', default: 'true' }),
    {
      name: 'aspectRatio',
      type: 'double?',
      description: {
        ko: '프레임의 가로:세로 비율. PageView는 모든 페이지를 뷰포트 크기로 배치하므로 높이를 받아야 합니다. 비워 두면 바깥 레이아웃이 주는 높이를 씁니다',
        en: 'How tall the frame is, as a width-to-height ratio. A PageView has to be given a height; left out, the carousel takes what the layout hands down'
      }
    },
    from('PlCarousel', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlCarousel', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlCarousel', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlCarousel', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlCarousel', 'elevation', { type: 'int', default: '0' }),
    from('PlCarousel', 'label', { type: 'String', default: "'Carousel'" }),
    from('PlCarousel', 'previousLabel', { type: 'String', default: "'Previous slide'" }),
    from('PlCarousel', 'nextLabel', { type: 'String', default: "'Next slide'" }),
    from('PlCarousel', 'slideLabel', { type: 'String Function(int index, int count)?' })
  ],

  PlCollapsible: [
    from('PlCollapsible', 'open', { type: 'bool', required: true }),
    {
      name: 'onOpenChanged',
      type: 'ValueChanged<bool>?',
      description: {
        ko: '열림 상태가 무엇이 되어야 하는지로 호출됩니다',
        en: 'Called with what the open state should become'
      }
    },
    { name: 'child', type: 'Widget?', description: { ko: '본문', en: 'The body' } },
    from('PlCollapsible', 'title', { type: 'Widget?' }),
    from('PlCollapsible', 'subtitle', { type: 'Widget?' }),
    from('PlCollapsible', 'startIcon', { type: 'Widget?' }),
    from('PlCollapsible', 'action', { type: 'Widget?' }),
    from('PlCollapsible', 'trigger', {
      name: 'triggerBuilder',
      type: 'Widget Function(BuildContext, bool open, VoidCallback toggle)?',
      description: {
        ko: '헤더를 통째로 바꿉니다. 위젯이 아니라 빌더입니다 — Dart 위젯은 만들어진 뒤에 탭 핸들러를 받을 수 없습니다',
        en: 'Replaces the header entirely. A builder rather than a widget: a Dart widget cannot be handed a tap handler after it was made'
      }
    }),
    from('PlCollapsible', 'indicator', { type: 'bool', default: 'true' }),
    from('PlCollapsible', 'disabled', { type: 'bool', default: 'false' }),
    from('PlCollapsible', 'padded', { type: 'bool', default: 'true' }),
    from('PlCollapsible', 'keepMounted', {
      type: 'bool',
      default: 'false',
      description: {
        ko: '닫힌 패널을 트리에 남깁니다 — State는 위젯과 함께 사라지므로, 접혀 사라진 필드는 입력을 잊습니다. 그동안 포커스 순서와 semantics에서는 빠집니다',
        en: 'Keeps a closed panel in the tree: a State goes with its widget, so a folded-away field forgets what was typed. It leaves the focus order and the semantics tree while it is closed'
      }
    }),
    from('PlCollapsible', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlCollapsible', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlCollapsible', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlCollapsible', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlCollapsible', 'elevation', { type: 'int', default: '0' })
  ],

  PlDrawer: [
    from('PlDrawer', 'open', { type: 'bool', required: true }),
    {
      name: 'onOpenChanged',
      type: 'ValueChanged<bool>?',
      description: {
        ko: '열림 상태가 무엇이 되어야 하는지로 호출됩니다. ×와 바깥 누름은 행동하는 대신 보고합니다',
        en: 'Called with what the open state should become. The × and a press outside report rather than act'
      }
    },
    {
      name: 'child',
      type: 'Widget?',
      description: {
        ko: '본문 — 스크롤되는 유일한 부분',
        en: 'The body — the only part that scrolls'
      }
    },
    from('PlDrawer', 'side', { type: 'PlassSide', default: 'PlassSide.left' }),
    from('PlDrawer', 'mode', { type: 'PlDrawerMode', default: 'PlDrawerMode.overlay' }),
    from('PlDrawer', 'title', { type: 'Widget?' }),
    from('PlDrawer', 'description', { type: 'Widget?' }),
    from('PlDrawer', 'actions', { type: 'List<Widget>?' }),
    from('PlDrawer', 'dividers', { type: 'bool', default: 'false' }),
    from('PlDrawer', 'showClose', { type: 'bool?' }),
    from('PlDrawer', 'closeLabel', { type: 'String', default: "'Close'" }),
    from('PlDrawer', 'extent', {
      type: 'double?',
      description: {
        ko: '판이 가장자리에서 얼마나 들어오는지, 논리 픽셀 — 좌우는 너비, 상하는 높이',
        en: 'How far the panel reaches in from its edge, in logical pixels: a width for left/right, a height for top/bottom'
      }
    }),
    from('PlDrawer', 'rounded', { type: 'bool', default: 'true' }),
    from('PlDrawer', 'modal', {
      type: 'bool',
      default: 'true',
      description: {
        ko: '뒤의 화면을 키보드뿐 아니라 포인터에서도 가져가는지',
        en: 'Whether the screen behind is taken away for the pointer as well as the keyboard'
      }
    }),
    from('PlDrawer', 'dismissible', { type: 'bool', default: 'true' }),
    from('PlDrawer', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlDrawer', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlDrawer', 'density', { type: DENSITY, default: 'PlassDensity.standard' })
  ],

  PlPill: [
    from('PlPill', 'title', { type: 'Widget?' }),
    from('PlPill', 'description', { type: 'Widget?' }),
    from('PlPill', 'startIcon', { type: 'Widget?' }),
    from('PlPill', 'endIcon', { type: 'Widget?' }),
    from('PlPill', 'details', { type: 'Widget?' }),
    from('PlPill', 'expanded', { type: 'bool', default: 'false' }),
    from('PlPill', 'onClick', {
      name: 'onPressed',
      type: 'VoidCallback?',
      description: {
        ko: '주면 가운데가 진짜 버튼이 됩니다',
        en: 'Passing it makes the middle a real button'
      }
    }),
    {
      name: 'child',
      type: 'Widget?',
      description: {
        ko: 'title과 description이 말할 수 없는 것. 그 아래 같은 열에 그려집니다',
        en: 'Anything the middle needs that title and description cannot say. Drawn under them, in the same column'
      }
    },
    from('PlPill', 'variant', { type: VARIANT, default: 'PlassVariant.solid' }),
    from('PlPill', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlPill', 'color', { type: COLOR, default: 'PlassColor.secondary' }),
    from('PlPill', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlPill', 'elevation', { type: 'int', default: '2' })
  ],

  PlPopover: [
    from('PlPopover', 'open', { type: 'bool', required: true }),
    from('PlPopover', 'trigger', {
      type: 'Widget',
      required: true,
      description: {
        ko: '팝업이 매달리는 요소. 여기서는 필수입니다 — LayerLink는 앵커가 없으면 따라갈 것이 없습니다',
        en: 'The element the popup hangs off. Required here: a LayerLink has nothing to follow without one'
      }
    }),
    {
      name: 'onOpenChanged',
      type: 'ValueChanged<bool>?',
      description: {
        ko: '열림 상태가 무엇이 되어야 하는지로 호출됩니다',
        en: 'Called with what the open state should become'
      }
    },
    { name: 'child', type: 'Widget?', description: { ko: '본문', en: 'The body' } },
    from('PlPopover', 'title', { type: 'Widget?' }),
    from('PlPopover', 'description', { type: 'Widget?' }),
    from('PlPopover', 'side', { type: 'PlassSide', default: 'PlassSide.bottom' }),
    from('PlPopover', 'align', { type: 'PlassAlign', default: 'PlassAlign.center' }),
    from('PlPopover', 'sideOffset', {
      name: 'offset',
      type: 'double',
      default: '6',
      description: {
        ko: '트리거에서 떨어진 거리, 논리 픽셀',
        en: 'How far it stands off the trigger, in logical pixels'
      }
    }),
    from('PlPopover', 'arrow', { type: 'bool', default: 'false' }),
    from('PlPopover', 'dismissible', {
      type: 'bool',
      default: 'true',
      description: {
        ko: '바깥을 누르면 닫히는지',
        en: 'Whether a press outside closes the popup'
      }
    }),
    from('PlPopover', 'showClose', { type: 'bool', default: 'false' }),
    from('PlPopover', 'closeLabel', { type: 'String', default: "'Close'" }),
    from('PlPopover', 'width', { type: 'double?' }),
    from('PlPopover', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlPopover', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlPopover', 'density', { type: DENSITY, default: 'PlassDensity.standard' })
  ],

  PlSpoiler: [
    {
      name: 'child',
      type: 'Widget?',
      description: { ko: '덮이는 것', en: 'What is being covered' }
    },
    from('PlSpoiler', 'revealed', {
      type: 'bool?',
      description: {
        ko: '내용이 드러나 있는지. 비워 두면 스포일러가 스스로 기억합니다 — 패키지에서 uncontrolled로 두어도 좋은 유일한 위젯입니다',
        en: 'Whether the content is uncovered. Left out, the spoiler keeps its own: the one widget in the package that is happy uncontrolled'
      }
    }),
    from('PlSpoiler', 'onRevealedChange', {
      name: 'onRevealedChanged',
      type: 'ValueChanged<bool>?'
    }),
    from('PlSpoiler', 'label', {
      type: 'String',
      default: "'Reveal'",
      description: {
        ko: '드러내기 버튼의 문구이자 그 접근 가능한 이름',
        en: "The reveal button's words, and its accessible name"
      }
    }),
    from('PlSpoiler', 'hideLabel', { type: 'String', default: "'Hide'" }),
    from('PlSpoiler', 'description', {
      type: 'Widget?',
      default: "Text('This may contain spoilers')",
      description: {
        ko: '버튼 위의 한 줄. null이면 아무것도 쓰이지 않은 덮개가 됩니다',
        en: 'The line above the button. null is a cover with nothing written on it'
      }
    }),
    from('PlSpoiler', 'action', { type: 'Widget?' }),
    from('PlSpoiler', 'reversible', { type: 'bool', default: 'false' }),
    from('PlSpoiler', 'maxHeight', { type: 'double?' }),
    from('PlSpoiler', 'blur', { type: 'double', default: '10' }),
    from('PlSpoiler', 'padded', { type: 'bool', default: 'true' }),
    from('PlSpoiler', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlSpoiler', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlSpoiler', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlSpoiler', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlSpoiler', 'elevation', { type: 'int', default: '0' })
  ],

  PlScrollArea: [
    from('PlScrollArea', 'children', { name: 'child', type: 'Widget', required: true }),
    from('PlScrollArea', 'orientation', {
      type: 'PlScrollAreaAxis',
      default: 'PlScrollAreaAxis.vertical'
    }),
    from('PlScrollArea', 'height · maxHeight', { type: 'double?' }),
    from('PlScrollArea', 'width · maxWidth', { type: 'double?' }),
    from('PlScrollArea', 'scrollbars', { type: 'PlScrollbars', default: 'PlScrollbars.auto' }),
    from('PlScrollArea', 'label', { type: 'String?' }),
    from('PlScrollArea', 'size', { type: SIZE, default: 'PlassSize.md' })
  ],

  PlScrollZone: [
    {
      name: 'children',
      type: 'List<Widget>',
      required: true,
      description: {
        ko: '늘어놓을 것들. 자식 하나가 띠의 항목 하나입니다',
        en: 'What is being laid out. Every child is one item of the strip'
      }
    },
    from('PlScrollZone', 'orientation', { type: 'PlassResponsive<PlassOrientation>' }),
    from('PlScrollZone', 'lines', { type: 'int', default: '1' }),
    from('PlScrollZone', 'spacing', {
      type: 'double',
      default: '8',
      description: {
        ko: '자식 사이의 간격, 논리 픽셀. Dart에는 rem이 없습니다',
        en: 'The gap between children, in logical pixels. Dart has no rem'
      }
    }),
    from('PlScrollZone', 'buttons', {
      type: 'PlScrollZoneButtons',
      default: 'PlScrollZoneButtons.auto'
    }),
    from('PlScrollZone', 'buttonPlacement', {
      type: 'PlScrollZoneButtonPlacement',
      default: 'PlScrollZoneButtonPlacement.inline'
    }),
    from('PlScrollZone', 'mode', {
      type: 'PlScrollZoneMode',
      default: 'PlScrollZoneMode.item'
    }),
    from('PlScrollZone', 'step', { type: 'int', default: '1' }),
    from('PlScrollZone', 'speed', { type: 'double', default: '900' }),
    from('PlScrollZone', 'snap', { type: 'bool', default: 'false' }),
    from('PlScrollZone', 'drag', {
      type: 'bool',
      default: 'true',
      description: {
        ko: '마우스로도 띠를 끌 수 있게 합니다. 터치와 트랙패드는 이미 스크롤합니다',
        en: 'Lets a mouse drag the strip along. Touch and a trackpad already scroll'
      }
    }),
    from('PlScrollZone', 'wheel', {
      type: 'bool',
      default: 'true',
      description: {
        ko: '가로 zone 위에서 세로로 굴린 휠이 띠를 따라 스크롤하게 합니다. 끝에 닿으면 휠은 뒤에 있는 것에게 돌아갑니다',
        en: 'Turns a vertical wheel over a horizontal zone into scrolling along the strip. At either end it goes back to whatever is behind it'
      }
    }),
    from('PlScrollZone', 'scrollbar', { type: 'bool', default: 'false' }),
    {
      name: 'controller',
      type: 'ScrollController?',
      description: {
        ko: '스크롤을 바깥에서 움직입니다. 없으면 zone이 자기 것을 하나 갖습니다',
        en: 'Drive the scroll from outside. Left out, the zone owns one of its own'
      }
    },
    from('PlScrollZone', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlScrollZone', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlScrollZone', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlScrollZone', 'label', { type: 'String?' }),
    from('PlScrollZone', 'previousLabel', { type: 'String', default: "'Previous'" }),
    from('PlScrollZone', 'nextLabel', { type: 'String', default: "'Next'" })
  ],

  PlTable: [
    from('PlTable', 'columns', {
      type: 'List<PlTableColumn<T>>',
      required: true
    }),
    from('PlTable', 'rows', { type: 'List<T>', required: true }),
    from('PlTable', 'getRowKey', {
      name: 'rowKey',
      type: 'LocalKey Function(T row, int index)?',
      description: {
        ko: '행마다의 안정적인 key. 없으면 위치로 식별되고, 정렬이나 필터가 있는 표에는 맞지 않습니다',
        en: 'A stable key per row. Left out, a row is identified by its position, which is wrong for a table that sorts or filters'
      }
    }),
    from('PlTable', 'caption', {
      type: 'Widget?',
      description: {
        ko: '격자 위, 시트 안에 그려집니다',
        en: 'Drawn above the grid, inside the sheet'
      }
    }),
    from('PlTable', 'empty', { type: 'Widget?', default: "Text('No data')" }),
    from('PlTable', 'striped', { type: 'bool', default: 'false' }),
    from('PlTable', 'hoverable', { type: 'bool', default: 'false' }),
    from('PlTable', 'stickyHeader', { type: 'bool', default: 'false' }),
    from('PlTable', 'maxHeight', {
      type: 'double?',
      description: {
        ko: '격자 높이의 상한, 논리 픽셀. 넘으면 시트 안에서 행이 스크롤됩니다. caption은 그 위에 남습니다',
        en: 'A hard cap on the grid, in logical pixels. Past it the rows scroll inside the sheet; the caption stays above it'
      }
    }),
    from('PlTable', 'onRowClick', {
      name: 'onRowPressed',
      type: 'void Function(T row, int index)?'
    }),
    from('PlTable', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlTable', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlTable', 'color', {
      type: COLOR,
      default: 'PlassColor.primary',
      description: {
        ko: '의미론적 색 역할. hover 틴트와 focus ring까지만 닿습니다 — 데이터는 자기 색을 가지고 옵니다',
        en: 'Semantic colour role. It reaches the hover tint and the focus ring and nothing else: data arrives with its own colours'
      }
    }),
    from('PlTable', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlTable', 'elevation', { type: 'int', default: '0' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '표를 스크린 리더가 부를 이름. caption은 그려지면서 읽히므로, 둘이 달라야 할 때만 씁니다',
        en: 'The name a screen reader gives the table. caption is drawn and read, so this is for when the two have to differ'
      }
    }
  ],

  PlTableColumn: [
    {
      name: 'cell',
      type: 'Widget Function(T row, int index)',
      required: true,
      description: {
        ko: '행에서 셀을 만듭니다. Dart에는 임의의 타입에 대한 row[key]가 없으니 필수입니다',
        en: 'Builds the cell for a row. Required, because Dart has no row[key] on an arbitrary type'
      }
    },
    from('PlTableColumn', 'header', {
      type: 'Widget?',
      description: {
        ko: '열 제목. 생략하면 제목 없는 열이 됩니다 — 액션 열이 원하는 것이고, 나머지 열은 원하지 않는 것입니다',
        en: 'The heading. Left out, the column is headed by nothing, which is what an actions column wants and every other column does not'
      }
    }),
    from('PlTableColumn', 'width', {
      type: 'double?',
      description: {
        ko: '고정 너비, 논리 픽셀. 없으면 내용만큼 넓어진 뒤 남은 폭을 flex만큼 나눠 갖습니다',
        en: 'A fixed width in logical pixels. Left out, the column is as wide as its content and then takes a flex share of what is left'
      }
    }),
    {
      name: 'flex',
      type: 'double',
      default: '1',
      description: {
        ko: '모든 열이 내용만큼 자리를 잡은 뒤 남은 폭에서 이 열이 가져가는 몫. React의 width: 30%에 해당합니다',
        en: "How much of the leftover width this column takes once every column has room for its content — the React build's width: '30%'"
      }
    },
    from('PlTableColumn', 'align', { type: 'PlassAlign', default: 'PlassAlign.start' })
  ],

  PlTabs: [
    from('PlTabs', 'children', {
      name: 'tabs',
      type: 'List<PlTab<T>>',
      required: true,
      description: {
        ko: '탭들. children이 아니라 설명의 목록이고, 각자 자기 panel을 들고 있습니다',
        en: 'The tabs, as a list of descriptions rather than children, each carrying its own panel'
      }
    }),
    from('PlTabs', 'value', {
      type: 'T?',
      required: true,
      description: {
        ko: '선택된 탭. null은 아무것도 고르지 않은 바입니다',
        en: 'The chosen tab. null is a bar with nothing chosen'
      }
    }),
    from('PlTabs', 'onValueChange', {
      name: 'onChanged',
      type: 'ValueChanged<T>?'
    }),
    from('PlTabs', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlTabs', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlTabs', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlTabs', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlTabs', 'orientation', {
      type: 'PlassResponsive<PlassOrientation>',
      default: 'PlassOrientation.horizontal'
    }),
    from('PlTabs', 'fullWidth', { type: 'bool', default: 'false' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '바를 스크린 리더가 부를 이름. 눈에 보이는 자기 라벨이 없습니다',
        en: 'The name a screen reader gives the bar. It has no visible label of its own'
      }
    },
    {
      name: 'focusNode',
      type: 'FocusNode?',
      description: {
        ko: '바의 단 하나뿐인 focus stop을 바깥에서 몹니다',
        en: "Drives the bar's one focus stop from outside"
      }
    },
    {
      name: 'autofocus',
      type: 'bool',
      default: 'false',
      description: {
        ko: '트리에 들어가는 순간 focus를 가져갑니다',
        en: 'Takes focus as it is inserted into the tree'
      }
    }
  ],

  PlTab: [
    from('PlTab', 'value', { type: 'T', required: true }),
    from('PlTab', 'children', { name: 'label', type: 'Widget?' }),
    from('PlTab', 'startIcon', {
      type: 'Widget?',
      description: {
        ko: '라벨 앞에 놓이는 내용. 라벨의 1.2배로 그려져 크기를 따라갑니다',
        en: "Content before the label, drawn at 1.2× it so it tracks the label's size"
      }
    }),
    from('PlTab', 'endIcon', { type: 'Widget?' }),
    from('PlTab', 'disabled', { type: 'bool', default: 'false' }),
    {
      name: 'panel',
      type: 'Widget?',
      description: {
        ko: '이 탭이 골라졌을 때 바 아래에 보이는 것. 고른 패널만 만들어집니다',
        en: 'What is shown under the bar when this tab is chosen. Only the chosen panel is built'
      }
    }
  ],

  PlTextField: [
    {
      name: 'controller',
      type: 'TextEditingController?',
      description: {
        ko: '편집 중인 텍스트. Flutter가 텍스트를 두는 자리입니다. 빼면 필드가 하나를 스스로 만듭니다',
        en: 'The text being edited — where Flutter keeps text. Left out, the field owns one of its own'
      }
    },
    {
      name: 'onChanged',
      type: 'ValueChanged<String>?',
      description: { ko: '모든 변화를 알립니다', en: 'Called on every change' }
    },
    {
      name: 'onSubmitted',
      type: 'ValueChanged<String>?',
      description: {
        ko: '키보드에서 제출했을 때',
        en: 'Called when the field is submitted from the keyboard'
      }
    },
    ...sharedProps('PlTextField').map((row) =>
      row.name === 'elevation' ? { ...row, default: '0' } : row
    ),
    from('PlTextField', 'multiline', { type: 'bool', default: 'false' }),
    from('PlTextField', 'rows', { type: 'int', default: '3' }),
    from('PlTextField', 'label', { type: 'Widget?' }),
    from('PlTextField', 'description', { type: 'Widget?' }),
    from('PlTextField', 'error', { type: 'Widget?' }),
    from('PlTextField', 'invalid', { type: 'bool?' }),
    {
      name: 'placeholder',
      type: 'String?',
      description: {
        ko: '비어 있는 동안 보이는 것. React에서는 네이티브 속성이라 표에 없습니다',
        en: 'What is shown while the field is empty. A native attribute in React, so it has no row there'
      }
    },
    from('PlTextField', 'startIcon', { type: 'Widget?' }),
    from('PlTextField', 'endIcon', { type: 'Widget?' }),
    from('PlTextField', 'loading', { type: 'bool', default: 'false' }),
    from('PlTextField', 'fullWidth', { type: 'bool', default: 'false' }),
    from('PlTextField', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlTextField', 'disabled', { type: 'bool', default: 'false' }),
    {
      name: 'obscureText',
      type: 'bool',
      default: 'false',
      description: {
        ko: '입력한 것을 가립니다. 비밀번호용',
        en: 'Hides what is typed, for a password'
      }
    },
    {
      name: 'keyboardType',
      type: 'TextInputType?',
      description: {
        ko: '터치 기기에서 올릴 키보드',
        en: 'Which keyboard to raise on a touch device'
      }
    },
    {
      name: 'maxLength',
      type: 'int?',
      description: {
        ko: '받을 글자 수. 카운터가 아니라 formatter입니다 — 아래에 아무것도 그려지지 않습니다',
        en: 'How many characters the field will take. A formatter rather than a counter: nothing is drawn under the field'
      }
    },
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '보이는 label이 없는 필드를 스크린 리더가 부를 이름. placeholder는 이름이 아닙니다',
        en: 'The name a screen reader announces, for a field with no visible label. A placeholder is not a name'
      }
    },
    hotKeysProp
  ],

  PlTextLink: [
    from('PlTextLink', 'children', { name: 'child', type: 'Widget', required: true }),
    {
      name: 'onPressed',
      type: 'VoidCallback?',
      description: {
        ko: '링크를 따라갈 때. Flutter에는 자체 내비게이션이 없으므로 어디로 가는지는 여기서 정합니다. 빼면 링크는 아무 일도 하지 않습니다',
        en: 'Called when the link is followed. Flutter has no navigation of its own, so where it goes is decided here. Leaving it out makes the link inert'
      }
    },
    from('PlTextLink', 'underline', {
      type: 'PlTextLinkUnderline',
      default: 'PlTextLinkUnderline.always'
    }),
    from('PlTextLink', 'color', { type: `${COLOR}?`, default: 'null' }),
    from('PlTextLink', 'size', { type: `${SIZE}?`, default: 'null' }),
    from('PlTextLink', 'newTab', {
      name: 'external',
      type: 'bool',
      default: 'false',
      description: {
        ko: '링크가 앱을 떠나는지. 화살표를 그리고, 스크린 리더가 읽는 힌트를 붙입니다',
        en: 'Whether the link leaves the app. Draws the arrow, and adds a hint a screen reader reads'
      }
    }),
    from('PlTextLink', 'icon', { type: 'Widget?' }),
    from('PlTextLink', 'startIcon', { type: 'Widget?' }),
    {
      name: 'showIcon',
      type: 'bool?',
      description: {
        ko: '표시를 그릴지. 생략하면 external을 따릅니다 — bool이 아니라 bool?인 이유입니다',
        en: 'Whether a mark is drawn. Left out, it follows external — which is why it is a bool? rather than a bool'
      }
    },
    from('PlTextLink', 'newTabLabel', {
      name: 'externalLabel',
      type: 'String',
      default: "'(opens elsewhere)'"
    })
  ],

  PlTimePicker: [
    {
      name: 'value',
      type: 'DateTime?',
      required: true,
      description: {
        ko: '선택된 시각. DateTime이므로 날짜도 함께 지닙니다',
        en: 'The chosen time. A DateTime, so it carries a day as well'
      }
    },
    {
      name: 'onChanged',
      type: 'ValueChanged<DateTime?>?',
      description: {
        ko: '고른 시각과 함께 호출됩니다. 비우면 null입니다',
        en: 'Called with the time that was chosen, or null when the picker is emptied'
      }
    },
    from('PlTimePicker', 'open', { type: 'bool?' }),
    {
      name: 'onOpenChanged',
      type: 'ValueChanged<bool>?',
      description: {
        ko: '열들이 열리거나 닫혀야 할 때 호출됩니다',
        en: 'Called when the columns should open or close'
      }
    },
    from('PlTimePicker', 'referenceDate', { type: 'DateTime?', default: 'now' }),
    from('PlTimePicker', 'minTime', { type: 'DateTime?' }),
    from('PlTimePicker', 'maxTime', { type: 'DateTime?' }),
    ...timeColumnProps('PlTimePicker'),
    {
      name: 'names',
      type: 'PlDateNames',
      default: 'PlDateNames.english',
      description: {
        ko: 'AM과 PM이 나오는 곳',
        en: 'Where AM and PM come from'
      }
    },
    from('PlTimePicker', 'labels', {
      type: 'PlPickerLabels',
      default: 'PlPickerLabels.english'
    }),
    {
      name: 'formatValue',
      type: 'String Function(DateTime value)?',
      description: {
        ko: 'trigger가 시각을 쓰는 방식. 빼면 H:MM이고, 초와 오전/오후가 켜져 있으면 함께 붙습니다',
        en: 'How the trigger writes the chosen time. Without it, H:MM — with seconds and a meridiem when those are on'
      }
    },
    from('PlTimePicker', 'placeholder', { type: 'Widget?' }),
    from('PlTimePicker', 'clearable', { type: 'bool', default: 'false' }),
    from('PlTimePicker', 'showNowButton', { type: 'bool', default: 'true' }),
    from('PlTimePicker', 'closeOnSelect', { type: 'bool', default: 'false' }),
    from('PlTimePicker', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlTimePicker', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlTimePicker', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlTimePicker', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlTimePicker', 'elevation', { type: 'int', default: '0' }),
    from('PlTimePicker', 'label', { type: 'Widget?' }),
    from('PlTimePicker', 'description', { type: 'Widget?' }),
    from('PlTimePicker', 'error', { type: 'Widget?' }),
    from('PlTimePicker', 'invalid', { type: 'bool?' }),
    from('PlTimePicker', 'startIcon', { type: 'Widget?' }),
    from('PlTimePicker', 'fullWidth', { type: 'bool', default: 'false' }),
    from('PlTimePicker', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlTimePicker', 'disabled', { type: 'bool', default: 'false' }),
    ...pickerHandleProps
  ],

  PlTimeline: [
    {
      name: 'items',
      type: 'List<PlTimelineItem>',
      required: true,
      description: {
        ko: '단계들. children이 아니라 설명의 목록입니다 — 어느 단계가 끝났는지는 인덱스 계산이고, 마지막 연결선은 자기가 마지막임을 알아야 합니다',
        en: 'The steps, as a list of descriptions rather than children — which step is complete is arithmetic on an index, and the last connector has to know it is the last'
      }
    },
    from('PlTimeline', 'active', { type: 'int?' }),
    from('PlTimeline', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlTimeline', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlTimeline', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlTimeline', 'orientation', {
      type: 'PlassResponsive<PlassOrientation>',
      default: 'PlassOrientation.vertical'
    })
  ],

  PlTimelineItem: [
    from('PlTimelineItem', 'title', { type: 'Widget?' }),
    from('PlTimelineItem', 'meta', { type: 'Widget?' }),
    from('PlTimelineItem', 'bullet', { type: 'Widget?' }),
    from('PlTimelineItem', 'status', { type: 'PlTimelineStatus?' }),
    from('PlTimelineItem', 'color', { type: `${COLOR}?` }),
    from('PlTimelineItem', 'connector', {
      type: 'PlTimelineConnector',
      default: 'PlTimelineConnector.solid'
    }),
    from('PlTimelineItem', 'children', { name: 'child', type: 'Widget?' })
  ],

  PlToastProvider: [
    from('PlToastProvider', 'children', {
      name: 'child',
      type: 'Widget',
      required: true
    }),
    from('PlToastProvider', 'position', {
      type: 'PlToastPosition',
      default: 'PlToastPosition.bottomEnd'
    }),
    from('PlToastProvider', 'timeout', {
      type: 'Duration',
      default: 'Duration(seconds: 5)',
      description: {
        ko: '기본 지속 시간. Duration.zero는 닫을 때까지 남습니다 — 독자가 무언가 해야 하는 토스트에는 그쪽이 맞습니다',
        en: 'How long a toast lasts by default. Duration.zero keeps it up until it is closed, which is right for anything the reader has to act on'
      }
    }),
    from('PlToastProvider', 'limit', { type: 'int', default: '3' }),
    from('PlToastProvider', 'width', {
      type: 'double',
      default: '380',
      description: {
        ko: '토스트의 최대 너비, 논리 픽셀',
        en: 'How wide a toast is allowed to get, in logical pixels'
      }
    }),
    from('PlToastProvider', 'closeLabel', { type: 'String', default: "'Close'" }),
    from('PlToastProvider', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlToastProvider', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlToastProvider', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlToastProvider', 'density', { type: DENSITY, default: 'PlassDensity.standard' })
  ],

  PlToast: [
    from('PlToastOptions', 'title', { type: 'Widget?' }),
    from('PlToastOptions', 'description', { type: 'Widget?' }),
    from('PlToastOptions', 'id', { type: 'String?' }),
    from('PlToastOptions', 'timeout', {
      type: 'Duration?',
      description: {
        ko: '이 토스트만의 지속 시간. Duration.zero는 닫을 때까지',
        en: "This toast's own lifetime. Duration.zero keeps it up until it is closed"
      }
    }),
    from('PlToastOptions', 'priority', {
      type: 'PlToastPriority',
      default: 'PlToastPriority.low',
      description: {
        ko: 'high는 도착하는 순간 알려지고 low는 읽는 사람이 닿을 때까지 기다립니다',
        en: 'high is announced the moment it arrives; low waits until the reader reaches it'
      }
    }),
    from('PlToastOptions', 'color', { type: 'PlassColor?' }),
    from('PlToastOptions', 'variant', { type: 'PlassVariant?' }),
    from('PlToastOptions', 'icon', {
      type: 'Widget?',
      description: {
        ko: '메시지 앞의 글리프. 생략하면 심각도의 표식이 쓰입니다',
        en: "The glyph before the message. The severity's own mark if it is left out"
      }
    }),
    {
      name: 'showIcon',
      type: 'bool',
      default: 'true',
      description: {
        ko: '글리프를 그릴지. Dart에는 null도 위젯도 아닌 값이 없으니 "치워라"가 자기 이름을 가집니다',
        en: 'Draws a glyph at all. Dart has no value that is neither null nor a widget, so "take it away" gets its own name'
      }
    },
    from('PlToastOptions', 'actionLabel', { type: 'Widget?' }),
    from('PlToastOptions', 'onAction', { type: 'VoidCallback?' }),
    from('PlToastOptions', 'onClose', { type: 'VoidCallback?' })
  ],

  PlToastController: [
    from('usePlToast', 'add', {
      name: 'show',
      type: 'String Function(PlToast toast)',
      description: {
        ko: '토스트를 올리고 id를 돌려줍니다. 이미 화면에 있는 id면 그 자리에서 갱신됩니다',
        en: 'Raises a toast and hands back its id. An id already on screen is updated in place'
      }
    }),
    from('usePlToast', 'update', {
      type: 'void Function(String id, PlToast toast)'
    }),
    from('usePlToast', 'close', { type: 'void Function([String? id])' }),
    from('usePlToast', 'promise', {
      name: 'showFuture',
      type: 'Future<T> Function(Future<T>, {loading, success, failure})',
      description: {
        ko: 'future를 따라가는 토스트 하나. 로딩 상태는 열린 채로 붙들리므로 느린 요청이 자기 토스트를 지워 버리지 못합니다',
        en: 'One toast that follows a future. The loading state is held open, so a slow request cannot dismiss its own toast'
      }
    })
  ],

  PlToggle: [
    from('PlToggle', 'variant', { type: `${VARIANT}?`, default: 'PlassVariant.glass' }),
    from('PlToggle', 'size', { type: `${SIZE}?`, default: 'PlassSize.md' }),
    from('PlToggle', 'color', { type: `${COLOR}?`, default: 'PlassColor.primary' }),
    from('PlToggle', 'density', { type: `${DENSITY}?`, default: 'PlassDensity.standard' }),
    from('PlToggle', 'elevation', { type: 'int?', default: '0' }),
    from('PlToggle', 'pressed', { type: 'bool?' }),
    from('PlToggle', 'defaultPressed', { type: 'bool', default: 'false' }),
    from('PlToggle', 'onPressedChange', {
      name: 'onPressedChanged',
      type: 'ValueChanged<bool>?'
    }),
    from('PlToggle', 'value', { type: 'String?' }),
    from('PlToggle', 'startIcon', { type: 'Widget?' }),
    from('PlToggle', 'endIcon', { type: 'Widget?' }),
    from('PlToggle', 'fullWidth', { type: 'bool', default: 'false' }),
    from('PlToggle', 'disabled', { type: 'bool?', default: 'false' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '스크린 리더가 부르는 이름. 라벨 없이 아이콘만 있는 토글에는 사실상 필수입니다',
        en: 'The name a screen reader gives it. Required in practice on a toggle with an icon and no label'
      }
    },
    {
      name: 'focusNode',
      type: 'FocusNode?',
      description: {
        ko: '바깥에서 focus를 옮겨야 하는 호출자를 위한 focus node',
        en: 'An external focus node, for a caller that has to move focus here itself'
      }
    },
    {
      name: 'autofocus',
      type: 'bool',
      default: 'false',
      description: {
        ko: '처음 지어질 때 focus를 가져갈지',
        en: 'Whether it takes focus when it is first built'
      }
    },
    from('PlToggle', 'children', { name: 'child', type: 'Widget?' })
  ],

  PlToggleGroup: [
    from('PlToggleGroup', 'children', {
      type: 'List<Widget>',
      required: true,
      description: {
        ko: '세트를 이루는 토글들. 세트에 속하려면 각자 value가 있어야 합니다',
        en: 'The toggles that make up the set. Each needs a value to be part of it'
      }
    }),
    from('PlToggleGroup', 'value', { type: 'List<String>?' }),
    from('PlToggleGroup', 'defaultValue', { type: 'List<String>', default: '<String>[]' }),
    from('PlToggleGroup', 'onValueChange', {
      name: 'onValueChanged',
      type: 'ValueChanged<List<String>>?'
    }),
    from('PlToggleGroup', 'multiple', { type: 'bool', default: 'false' }),
    from('PlToggleGroup', 'orientation', {
      type: 'PlassOrientation',
      default: 'PlassOrientation.horizontal'
    }),
    from('PlToggleGroup', 'variant', { type: `${VARIANT}?` }),
    from('PlToggleGroup', 'size', { type: `${SIZE}?` }),
    from('PlToggleGroup', 'color', { type: `${COLOR}?` }),
    from('PlToggleGroup', 'density', { type: `${DENSITY}?` }),
    from('PlToggleGroup', 'elevation', { type: 'int?' }),
    from('PlToggleGroup', 'disabled', { type: 'bool?' }),
    from('PlToggleGroup', 'fullWidth', { type: 'bool', default: 'false' })
  ],

  PlToolbar: [
    {
      name: 'child',
      type: 'Widget?',
      description: {
        ko: '가운데. start와 end가 남긴 너비를 차지합니다',
        en: 'The middle. Takes whatever width start and end leave'
      }
    },
    from('PlToolbar', 'start', {
      type: 'List<Widget>?',
      description: {
        ko: '바의 시작에 고정되는 것 — 로고, 제목, 뒤로 가기. Dart에는 fragment가 없으니 목록을 받고 간격도 줍니다',
        en: 'Pinned to the start of the bar: a logo, a title, a back button. Dart has no fragment, so the slot takes a list and spaces it'
      }
    }),
    from('PlToolbar', 'end', { type: 'List<Widget>?' }),
    from('PlToolbar', 'divider', { type: 'bool', default: 'false' }),
    from('PlToolbar', 'side', {
      type: 'PlassSide',
      default: 'PlassSide.top',
      description: {
        ko: '바가 향한 쪽. 그것에 달린 것은 하나뿐입니다 — divider를 어느 가장자리에 긋는지',
        en: 'Which way the bar is facing, and the one thing that depends on it: which edge the divider is drawn along'
      }
    }),
    {
      name: 'rounded',
      type: 'bool',
      default: 'true',
      description: {
        ko: '바가 모서리를 가진 시트인지. 화면 가장자리에 붙잡아 둘 때 끕니다 — 맞닿은 둥근 모서리는 뒤에 아무것도 없는 틈입니다',
        en: 'Whether the bar is a sheet with corners. Turn it off for one held against an edge of the screen: a rounded corner there is a gap with nothing behind it'
      }
    },
    from('PlToolbar', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlToolbar', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlToolbar', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlToolbar', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlToolbar', 'elevation', { type: 'int', default: '0' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '바 자신에게 이름이 필요할 때 스크린 리더가 읽을 이름',
        en: 'The name a screen reader gives the bar, if it needs one of its own'
      }
    }
  ],

  PlTooltip: [
    from('PlTooltip', 'content', {
      type: 'Widget',
      required: true,
      description: {
        ko: 'tooltip이 하는 말. 짧은 구절이어야 합니다 — tooltip은 컨테이너가 아닙니다. 터치 화면에서는 머무를 포인터가 없고, 주의가 옮겨가는 순간 사라지며, 그 안의 무엇도 누를 수 없습니다',
        en: 'What the tooltip says. A short phrase: a tooltip is not a container — there is no pointer to rest on a touch screen, it goes the moment attention moves, and nothing inside it can be pressed'
      }
    }),
    from('PlTooltip', 'children', {
      name: 'child',
      type: 'Widget',
      required: true,
      description: {
        ko: 'tooltip이 매달리는 것. 감싸개는 레이아웃에 상자를 더하지 않습니다',
        en: 'What the tooltip hangs off. The wrapper adds no box to the layout'
      }
    }),
    from('PlTooltip', 'side', {
      type: 'PlassSide',
      default: 'PlassSide.top',
      description: {
        ko: '트리거의 어느 변에 나타날지. 자리가 없으면 반대편으로 뒤집힙니다 — 뒤집을 뿐 옆으로 미끄러지지는 않습니다',
        en: 'Which edge of the trigger it appears on. It flips to the opposite side when there is no room — a flip, never a slide along the edge'
      }
    }),
    from('PlTooltip', 'align', { type: 'PlassAlign', default: 'PlassAlign.center' }),
    from('PlTooltip', 'sideOffset', {
      name: 'offset',
      type: 'double',
      default: '6',
      description: {
        ko: '트리거에서 떨어진 거리, 논리 픽셀',
        en: 'How far it stands off the trigger, in logical pixels'
      }
    }),
    from('PlTooltip', 'delay', {
      type: 'Duration',
      default: 'Duration(milliseconds: 600)'
    }),
    from('PlTooltip', 'closeDelay', { type: 'Duration', default: 'Duration.zero' }),
    from('PlTooltip', 'arrow', { type: 'bool', default: 'true' }),
    from('PlTooltip', 'open', {
      type: 'bool?',
      description: {
        ko: '바깥에서 tooltip을 움직입니다. null이면 포인터와 길게 누르기, focus에 맡깁니다 — 패키지에서 컴포넌트가 자기 상태를 쥐는 유일한 자리입니다',
        en: 'Drives the tooltip from outside. null leaves it to the pointer, a long press and focus — the one place in the package where a component owns its own state'
      }
    }),
    from('PlTooltip', 'onOpenChange', {
      name: 'onOpenChanged',
      type: 'ValueChanged<bool>?',
      description: {
        ko: '열리거나 닫힐 때마다, 무엇이 청했든 불립니다',
        en: 'Called whenever the tooltip opens or closes, however it was asked'
      }
    }),
    from('PlTooltip', 'disabled', { type: 'bool', default: 'false' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '스크린 리더가 트리거의 tooltip으로 읽는 말. content가 Text면 그 글자가 기본값입니다',
        en: "What a screen reader says the trigger's tooltip is. With a Text in content it defaults to that text"
      }
    },
    from('PlTooltip', 'size', { type: SIZE, default: 'PlassSize.sm' }),
    from('PlTooltip', 'density', { type: DENSITY, default: 'PlassDensity.standard' })
  ],

  PlTooltipProvider: [
    {
      name: 'child',
      type: 'Widget',
      required: true,
      description: { ko: '그룹 안에 있는 것', en: 'What is inside the group' }
    },
    {
      name: 'timeout',
      type: 'Duration',
      default: 'Duration(milliseconds: 300)',
      description: {
        ko: '하나가 닫힌 뒤 이웃들이 얼마 동안 즉시 열리는지',
        en: 'How long after one tooltip closes its neighbours still open at once'
      }
    }
  ],

  PlTour: [
    from('PlTour', 'steps', { type: 'List<PlTourStep>', required: true }),
    from('PlTour', 'open', { type: 'bool', default: 'false' }),
    from('PlTour', 'onOpenChange', { name: 'onOpenChanged', type: 'ValueChanged<bool>?' }),
    from('PlTour', 'step', { type: 'int?' }),
    from('PlTour', 'defaultStep', { name: 'initialStep', type: 'int', default: '0' }),
    from('PlTour', 'onStepChange', { name: 'onStepChanged', type: 'ValueChanged<int>?' }),
    from('PlTour', 'onFinish', { type: 'VoidCallback?' }),
    {
      name: 'controller',
      type: 'ScrollController?',
      description: {
        ko: '대상이 들어 있는 스크롤. 빛이 대상을 따라가게 합니다 — PlAnchor가 받는 그것이고, 이유도 같습니다',
        en: 'The scroll the targets live in, so the light follows them. The same parameter PlAnchor takes and for the same reason'
      }
    },
    from('PlTour', 'mask', {
      type: 'bool',
      default: 'true',
      description: {
        ko: '화면을 어둡게 하고 대상만 그 어둠에서 오려 냅니다',
        en: 'Dims the screen and cuts the target out of the dimming'
      }
    }),
    from('PlTour', 'skippable', { type: 'bool', default: 'true' }),
    from('PlTour', 'dismissible', { type: 'bool', default: 'true' }),
    from('PlTour', 'scrollIntoView', { type: 'bool', default: 'true' }),
    from('PlTour', 'previousLabel', { type: 'Widget?', default: 'Text(labels.previous)' }),
    from('PlTour', 'nextLabel', { type: 'Widget?', default: 'Text(labels.next)' }),
    from('PlTour', 'doneLabel', { type: 'Widget?', default: 'Text(labels.done)' }),
    from('PlTour', 'skipLabel', { type: 'Widget?', default: 'Text(labels.skip)' }),
    {
      name: 'closeLabel',
      type: 'String?',
      default: 'labels.close',
      description: { ko: '×를 스크린 리더가 부를 이름', en: 'The name a screen reader gives the ×' }
    },
    from('PlTour', 'size', { type: `${SIZE}?`, default: 'PlassSize.md' }),
    from('PlTour', 'color', { type: `${COLOR}?`, default: 'PlassColor.primary' }),
    from('PlTour', 'density', { type: `${DENSITY}?`, default: 'PlassDensity.standard' })
  ],

  PlTourStep: [
    from('PlTourStep', 'target', {
      type: 'GlobalKey?',
      description: {
        ko: '이 단계가 가리키는 것, 위젯 자신에 붙인 GlobalKey로. 없으면 카드가 화면 가운데에 놓이고 아무것도 오려 내지 않습니다',
        en: 'What this step is about, as a GlobalKey on the widget itself. Left out, the card is centred over the screen and nothing is cut out'
      }
    }),
    from('PlTourStep', 'title', { type: 'Widget?' }),
    from('PlTourStep', 'content', { type: 'Widget?' }),
    from('PlTourStep', 'side', { type: 'PlassSide', default: 'PlassSide.bottom' }),
    from('PlTourStep', 'align', { type: 'PlassAlign', default: 'PlassAlign.center' }),
    from('PlTourStep', 'padding', {
      type: 'double',
      default: '6',
      description: {
        ko: '오려 낸 구멍이 대상보다 얼마나 큰지, 논리 픽셀',
        en: 'How far the cut-out is grown past the target, in logical pixels'
      }
    }),
    from('PlTourStep', 'radius', {
      type: 'double?',
      description: {
        ko: '구멍의 모서리 반지름. 없으면 size의 값',
        en: "The cut-out's corner radius. Defaults to the size's own"
      }
    })
  ],

  PlTransfer: [
    from('PlTransfer', 'variant', { type: VARIANT, default: 'PlassVariant.glass' }),
    from('PlTransfer', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlTransfer', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlTransfer', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlTransfer', 'items', { type: 'List<PlTransferItem>', required: true }),
    from('PlTransfer', 'value', { type: 'List<String>?' }),
    from('PlTransfer', 'defaultValue', { type: 'List<String>', default: '<String>[]' }),
    from('PlTransfer', 'onValueChange', {
      name: 'onValueChanged',
      type: 'ValueChanged<List<String>>?'
    }),
    from('PlTransfer', 'sourceLabel', { type: 'String', default: "'Available'" }),
    from('PlTransfer', 'targetLabel', { type: 'String', default: "'Selected'" }),
    from('PlTransfer', 'searchable', { type: 'bool', default: 'false' }),
    from('PlTransfer', 'searchLabel', { type: 'String', default: "'Search'" }),
    from('PlTransfer', 'emptyLabel', { type: 'String', default: "'Nothing here'" }),
    from('PlTransfer', 'selectAllLabel', { type: 'String', default: "'Select all'" }),
    from('PlTransfer', 'toTargetLabel', { type: 'String', default: "'Move to selected'" }),
    from('PlTransfer', 'toSourceLabel', { type: 'String', default: "'Move to available'" }),
    from('PlTransfer', 'height', { type: 'double', default: '220' }),
    from('PlTransfer', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlTransferItem: [
    from('PlTransferItem', 'value', { type: 'String', required: true }),
    from('PlTransferItem', 'label', {
      type: 'String',
      required: true,
      description: {
        ko: '행이 말하는 내용. 위젯이 아니라 String이라, 필터가 읽을 수 없는 행이 생기지 않습니다',
        en: 'What the row says. A String rather than a widget, so there is no row the filter cannot read'
      }
    }),
    from('PlTransferItem', 'disabled', { type: 'bool', default: 'false' })
  ],

  PlTypography: [
    from('PlTypography', 'level', {
      type: 'PlTypographyLevel',
      default: 'PlTypographyLevel.body',
      description: {
        ko: '타입 스케일과, 이 줄이 heading으로 알려지는지 여부. variant가 아닌 이유는, 이 라이브러리에서 variant는 표면의 재질을 뜻하기 때문입니다',
        en: 'The type scale, and whether the line is announced as a heading. Not called variant, because in this library variant names what a surface is made of'
      }
    }),
    from('PlTypography', 'color', { type: `${COLOR}?`, default: 'null' }),
    from('PlTypography', 'weight', {
      type: 'PlTypographyWeight?',
      description: {
        ko: 'level이 정했을 굵기를 덮어씁니다',
        en: 'Overrides the weight the level would otherwise pick'
      }
    }),
    from('PlTypography', 'align', { type: 'TextAlign?' }),
    from('PlTypography', 'lines', { type: 'int?' }),
    from('PlTypography', 'gutter', { type: 'bool', default: 'false' }),
    {
      name: 'semanticsLabel',
      type: 'String?',
      description: {
        ko: '스크린 리더가 글자 대신 읽을 이름. lines가 잘라낸 글자는 실제로 사라지므로, 문장 전체가 중요한 줄에 넘깁니다',
        en: 'What a screen reader reads instead of the characters. lines really does drop what it clips, so pass this when the whole string matters'
      }
    },
    from('PlTypography', 'children', {
      name: 'data',
      type: 'String',
      required: true,
      description: {
        ko: '텍스트. 첫 번째 위치 인자입니다. span으로 이루어진 줄에는 InlineSpan을 받는 PlTypography.rich를 씁니다',
        en: 'The text, as the first positional argument. PlTypography.rich takes an InlineSpan instead, for a line built out of spans'
      }
    })
  ],

  /*
   * The one table where the five axes are nullable.
   *
   * `null` is not a value here, it is *this button did not say* — which is what
   * lets a `PlButtonGroup` answer for a whole run. The React build reaches the
   * same place by leaving a prop off; Dart needs the type to say so.
   */
  PlButton: [
    ...groupedAxes('PlButton', { elevation: '1' }),
    from('PlButton', 'startIcon', { type: 'Widget?' }),
    from('PlButton', 'endIcon', { type: 'Widget?' }),
    from('PlButton', 'loading', { type: 'bool', default: 'false' }),
    from('PlButton', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlButton', 'disabled', { type: 'bool?', default: 'false' }),
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
