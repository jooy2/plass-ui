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
    from('PlAccordionItem', 'disabled', { type: 'bool', default: 'false' }),
    from('PlAccordionItem', 'children', { name: 'child', type: 'Widget?' })
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
    from('PlAvatar', 'variant', { type: VARIANT, default: 'PlassVariant.ghost' }),
    from('PlAvatar', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlAvatar', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlAvatar', 'elevation', { type: 'int', default: '0' }),
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
    from('PlAvatar', 'shape', { type: 'PlAvatarShape', default: 'PlAvatarShape.circle' }),
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

  PlContainer: [
    from('PlContainer', 'children', { name: 'child', type: 'Widget?' }),
    from('PlContainer', 'maxWidth', {
      type: 'PlassSize?',
      default: 'null',
      description: {
        ko: '내용이 넓어질 수 있는 한계. null이면 한계가 없습니다 — xs 480 · sm 640 · md 768 · lg 1024 · xl 1280 논리 픽셀',
        en: 'How wide the content is allowed to get, or null for no limit — xs 480, sm 640, md 768, lg 1024, xl 1280 logical pixels'
      }
    }),
    from('PlContainer', 'padded', { type: 'bool', default: 'true' }),
    from('PlContainer', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlContainer', 'density', { type: DENSITY, default: 'PlassDensity.standard' }),
    from('PlContainer', 'centered', { type: 'bool', default: 'true' })
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
    from('PlIconButton', 'variant', { type: VARIANT, default: 'PlassVariant.solid' }),
    from('PlIconButton', 'size', { type: SIZE, default: 'PlassSize.md' }),
    from('PlIconButton', 'color', { type: COLOR, default: 'PlassColor.primary' }),
    from('PlIconButton', 'elevation', { type: 'int', default: '1' }),
    from('PlIconButton', 'loading', { type: 'bool', default: 'false' }),
    from('PlIconButton', 'readOnly', { type: 'bool', default: 'false' }),
    from('PlIconButton', 'disabled', { type: 'bool', default: 'false' }),
    {
      name: 'focusNode · autofocus',
      type: 'FocusNode? · bool',
      description: {
        ko: '포커스를 밖에서 제어하거나, 트리에 들어가면서 포커스를 가져갑니다',
        en: 'Drive focus from outside, or take it on insertion'
      }
    }
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
    }
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
    }
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
      type: 'PlassOrientation',
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
      type: 'PlassOrientation',
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
    }
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
      type: 'PlassOrientation',
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
