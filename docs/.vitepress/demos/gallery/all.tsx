import { useRef, useState, type ReactNode } from 'react';
import {
  PlAccordion,
  PlAccordionItem,
  PlAlert,
  PlAnimateFade,
  PlAnimateTyping,
  PlAnimateHeadline,
  PlAnimateMarquee,
  PlAnimateLighting,
  PlAnimateAppear,
  PlAnimateBlink,
  PlAnimateReveal,
  PlAnimateRotate,
  PlAnimateSlide,
  PlAnimateZoom,
  PlAnimateGrow,
  PlAnchor,
  PlAppLogo,
  PlAspectRatio,
  PlAvatar,
  PlBackTop,
  PlBadge,
  PlBlockquote,
  PlBottomNavigation,
  PlBottomNavigationItem,
  PlBox,
  PlBreadcrumb,
  PlBreadcrumbItem,
  PlButton,
  PlButtonGroup,
  PlCalendar,
  PlCard,
  PlCarousel,
  PlChatBubble,
  PlCheckbox,
  PlChip,
  PlCollapsible,
  PlConfirmProvider,
  PlColorPicker,
  PlCombobox,
  PlCommandPalette,
  PlContainer,
  PlDataList,
  PlDataListItem,
  PlDatePicker,
  PlDateRangePicker,
  PlDateTimePicker,
  PlDivider,
  PlDrawer,
  PlEmpty,
  PlFieldset,
  PlFilePicker,
  PlFloatingBottomNavigation,
  PlFloatingBottomNavigationItem,
  PlFlex,
  PlFooter,
  PlForm,
  PlGrid,
  PlGridItem,
  PlHeader,
  PlHighlight,
  PlHotKeys,
  PlHoverCard,
  PlIcon,
  PlIconButton,
  PlImage,
  PlList,
  PlListItem,
  PlMenu,
  PlMenuItem,
  PlMenuSeparator,
  PlMenubar,
  PlMeter,
  PlMenubarMenu,
  PlModal,
  PlModalClose,
  PlNavigationMenu,
  PlNavigationMenuItem,
  PlNavigationMenuLink,
  PlNumberField,
  PlOtpField,
  PlOverlay,
  PlPane,
  PlPanes,
  PlPageLayout,
  PlPagination,
  PlPill,
  PlPopconfirm,
  PlPopover,
  PlPortal,
  PlProgressBox,
  PlProgressCircular,
  PlProgressLinear,
  PlRadio,
  PlRadioGroup,
  PlRating,
  PlScrollArea,
  PlScrollZone,
  PlSegment,
  PlSegmentedButton,
  PlSelect,
  PlShow,
  PlSidebar,
  PlSkeleton,
  PlSlider,
  PlSpoiler,
  PlStack,
  PlStat,
  PlStep,
  PlStepper,
  PlSwitch,
  PlTab,
  PlTabPanel,
  PlTable,
  PlTabs,
  PlTextField,
  PlTextLink,
  PlTimePicker,
  PlTimeline,
  PlTimelineItem,
  PlToastProvider,
  PlToggle,
  PlToggleGroup,
  PlToolbar,
  PlTransfer,
  PlTree,
  PlTooltip,
  usePlConfirm,
  usePlToast,
  PlTypography,
  PlVisuallyHidden
} from 'plass-ui';

/**
 * The component index, as running previews rather than screenshots.
 *
 * One of the two demos in the repository that is documentation rather than
 * sample code, so it takes the `locale` and `base` that `Demo.vue` passes in
 * and localises itself. Everything else under `demos/` is written in English
 * and shared by every locale.
 */
interface GalleryProps {
  locale?: 'en' | 'ko';
  base?: string;
}

/** The sidebar's own groups, in the sidebar's own order. */
type Group =
  'display' | 'feedback' | 'inputs' | 'layout' | 'navigation' | 'surfaces' | 'transitions';

/**
 * `PlBackTop` is hidden until it is useful, so a preview of it needs something
 * to have scrolled. The panel is its own target and its own reason to exist.
 */
function BackTopPreview() {
  const panel = useRef<HTMLDivElement>(null);

  return (
    <div className="relative w-full">
      <div
        ref={panel}
        className="h-24 overflow-y-auto rounded-(--plass-radius-sm) bg-(--plass-glass-press) p-2 text-[0.625rem]"
      >
        {Array.from({ length: 20 }, (_, index) => (
          <div key={index} className="py-0.5 text-(--plass-muted-fg)">
            Line {index + 1}
          </div>
        ))}
      </div>
      <PlBackTop
        target={panel}
        visibilityHeight={40}
        floating={false}
        size="xs"
        className="absolute end-2 bottom-2"
      />
    </div>
  );
}

/**
 * The other preview that needs state of its own: a confirm dialog is a promise
 * rather than an element, so there is nothing to draw until something asks.
 */
function ConfirmPreview() {
  const { confirm } = usePlConfirm();
  const [answer, setAnswer] = useState<string | null>(null);

  return (
    <div className="flex flex-col items-center gap-2">
      <PlButton
        size="sm"
        color="danger"
        onClick={async () => {
          const ok = await confirm({
            title: 'Delete this project?',
            description: 'It cannot be undone.',
            confirmLabel: 'Delete',
            color: 'danger'
          });

          setAnswer(ok ? 'Deleted.' : 'Kept.');
        }}
      >
        Delete
      </PlButton>
      <span className="text-[0.625rem] text-(--plass-muted-fg)">
        {answer ?? 'await confirm(…)'}
      </span>
    </div>
  );
}

/**
 * An overlay has to be opened to be seen at all. Its words stay English like every other preview
 * here — the localised part of a card is its blurb.
 */
function OverlayPreview() {
  const [open, setOpen] = useState(false);

  return (
    <>
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setOpen(true)}>
        Open
      </PlButton>
      <PlOverlay
        dismissible
        tone="glass"
        open={open}
        onOpenChange={setOpen}
        label="Press anywhere to close"
      >
        <span className="text-sm font-medium text-(--p-accent)">Press anywhere</span>
      </PlOverlay>
    </>
  );
}

/** A drawer has to be opened to be seen at all, so its card carries state. */
function DrawerPreview() {
  const [open, setOpen] = useState(false);

  return (
    <PlDrawer
      side="right"
      size="sm"
      open={open}
      onOpenChange={setOpen}
      trigger={
        <PlButton size="sm" variant="glass" color="secondary">
          Open
        </PlButton>
      }
      title="Filters"
    >
      A panel attached to one edge of the window.
    </PlDrawer>
  );
}

/** A palette has to be opened to be seen at all, so its card carries state. */
function CommandPalettePreview() {
  const [open, setOpen] = useState(false);

  return (
    <>
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setOpen(true)}>
        Open
      </PlButton>
      <PlCommandPalette
        shortcut={false}
        open={open}
        onOpenChange={setOpen}
        size="sm"
        items={[
          { value: 'new', label: 'New document', group: 'File' },
          { value: 'copy', label: 'Copy', group: 'Edit' }
        ]}
      />
    </>
  );
}

/** Raising a toast needs a hook, so this card's preview is a component too. */
function ToastPreview() {
  const toast = usePlToast();

  return (
    <PlButton
      size="sm"
      variant="glass"
      color="secondary"
      onClick={() => toast.add({ color: 'success', title: 'Saved' })}
    >
      Raise a toast
    </PlButton>
  );
}

/** Three drawings for the icon-button card, which needs glyphs of its own. */
function HeartGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M12 20s-7-4.5-7-9a4 4 0 0 1 7-2.6A4 4 0 0 1 19 11c0 4.5-7 9-7 9Z" />
    </svg>
  );
}

function ShareGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M4 12v7a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1v-7M12 3v13M8 7l4-4 4 4" />
    </svg>
  );
}

function SearchGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
      <circle cx="11" cy="11" r="6" />
      <path d="m15.5 15.5 4 4" />
    </svg>
  );
}

function MoreGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="currentColor">
      <circle cx="5" cy="12" r="1.6" />
      <circle cx="12" cy="12" r="1.6" />
      <circle cx="19" cy="12" r="1.6" />
    </svg>
  );
}

/** Two more drawings, for the bottom-navigation card. */
function HomeGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
      <path d="M4 11 12 4l8 7v8a1 1 0 0 1-1 1h-4v-6H9v6H5a1 1 0 0 1-1-1z" />
    </svg>
  );
}

function AccountGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
      <circle cx="12" cy="9" r="3.4" />
      <path d="M5 20a7 7 0 0 1 14 0" />
    </svg>
  );
}

interface Entry {
  name: string;
  group: Group;
  href: string;
  blurb: Record<'en' | 'ko', string>;
  preview: ReactNode;
  /**
   * Whether the preview is itself made of links.
   *
   * A card is normally an `<a>` wrapped around the whole tile, which is what
   * makes the grid one big set of targets. An `<a>` inside an `<a>` is markup
   * the browser un-nests on parse and React reports as a hydration error, so
   * the one card whose preview *is* links keeps its shell a plain sheet and
   * puts the link on its title instead.
   */
  previewHasLinks?: boolean;
}

const entries: Entry[] = [
  {
    name: 'PlButton',
    group: 'inputs',
    href: 'components/inputs/button',
    blurb: {
      en: 'A control that runs an action.',
      ko: '액션을 실행하는 컨트롤입니다.'
    },
    preview: (
      <div className="flex flex-wrap items-center gap-2">
        <PlButton size="sm">Save</PlButton>
        <PlButton size="sm" variant="glass">
          Cancel
        </PlButton>
        <PlButton size="sm" variant="ghost" color="danger">
          Delete
        </PlButton>
      </div>
    )
  },
  {
    name: 'PlButtonGroup',
    group: 'inputs',
    href: 'components/inputs/button-group',
    blurb: {
      en: 'A run of buttons that belong together, stated once for the set.',
      ko: '함께 묶이는 버튼 한 줄. 스타일을 묶음 단위로 한 번만 지정합니다.'
    },
    preview: (
      <PlButtonGroup size="sm" variant="glass" color="secondary">
        <PlButton>Day</PlButton>
        <PlButton>Week</PlButton>
        <PlButton>Month</PlButton>
      </PlButtonGroup>
    )
  },
  {
    name: 'PlTextField',
    group: 'inputs',
    href: 'components/inputs/text-field',
    blurb: {
      en: 'Single- or multi-line text input, with its label, description and error.',
      ko: '한 줄 또는 여러 줄 텍스트 입력. 라벨과 설명, 오류 메시지를 함께 담습니다.'
    },
    preview: <PlTextField fullWidth size="sm" placeholder="acme-inc" />
  },
  {
    name: 'PlCalendar',
    group: 'inputs',
    href: 'components/inputs/calendar',
    blurb: {
      en: 'A month, on the page rather than in a popup.',
      ko: 'popup 안이 아니라 페이지 위의 한 달입니다.'
    },
    preview: (
      <PlCalendar
        locale="en-GB"
        size="xs"
        variant="ghost"
        elevation={0}
        defaultMonth={new Date(2026, 6, 1)}
        defaultValue={new Date(2026, 6, 15)}
      />
    )
  },
  {
    name: 'PlDatePicker',
    group: 'inputs',
    href: 'components/inputs/date-picker',
    blurb: {
      en: 'One day, chosen from a calendar. No date library, no translation files.',
      ko: '달력에서 하루를 고릅니다. 날짜 라이브러리도, 번역 파일도 없습니다.'
    },
    preview: <PlDatePicker fullWidth size="sm" placeholder="Pick a day" />
  },
  {
    name: 'PlDateTimePicker',
    group: 'inputs',
    href: 'components/inputs/date-time-picker',
    blurb: {
      en: 'A day and a time, in one popup, at full precision.',
      ko: '한 팝업 안의 날짜와 시각. 경계는 전체 정밀도로 읽습니다.'
    },
    preview: <PlDateTimePicker fullWidth size="sm" placeholder="Pick a moment" minuteStep={15} />
  },
  {
    name: 'PlTimePicker',
    group: 'inputs',
    href: 'components/inputs/time-picker',
    blurb: {
      en: 'A time of day, chosen from columns rather than a dial.',
      ko: '다이얼이 아니라 열에서 시각을 고릅니다.'
    },
    preview: <PlTimePicker fullWidth size="sm" placeholder="Pick a time" minuteStep={15} />
  },
  {
    name: 'PlDateRangePicker',
    group: 'inputs',
    href: 'components/inputs/date-range-picker',
    blurb: {
      en: 'A span between two days, banded as the pointer moves.',
      ko: '두 날 사이의 구간. 포인터를 따라 띠가 그려집니다.'
    },
    preview: (
      <PlDateRangePicker
        fullWidth
        size="sm"
        monthCount={1}
        startPlaceholder="From"
        endPlaceholder="To"
      />
    )
  },
  {
    name: 'PlColorPicker',
    group: 'inputs',
    href: 'components/inputs/color-picker',
    blurb: {
      en: 'A colour, chosen by eye — a saturation square with a hue rail beside it.',
      ko: '눈으로 고르는 색입니다. 채도 사각형 옆에 색상 레일이 놓입니다.'
    },
    preview: <PlColorPicker size="sm" defaultValue="#1a58d1" />
  },
  {
    name: 'PlCombobox',
    group: 'inputs',
    href: 'components/inputs/combobox',
    blurb: {
      en: 'A field you can type into and also choose from.',
      ko: '입력할 수도 있고 고를 수도 있는 field입니다.'
    },
    preview: (
      <PlCombobox
        fullWidth
        size="sm"
        placeholder="Search…"
        items={[
          { value: 'react', label: 'React' },
          { value: 'vue', label: 'Vue' },
          { value: 'svelte', label: 'Svelte' }
        ]}
      />
    )
  },
  {
    name: 'PlCheckbox',
    group: 'inputs',
    href: 'components/inputs/checkbox',
    blurb: {
      en: 'A single yes/no, or one member of a set of them.',
      ko: '하나의 예/아니오, 또는 그런 항목 중 하나입니다.'
    },
    preview: (
      <div className="flex flex-col gap-2">
        <PlCheckbox size="sm" label="Email me" defaultChecked />
        <PlCheckbox size="sm" label="Call me" />
      </div>
    )
  },
  {
    name: 'PlFilePicker',
    group: 'inputs',
    href: 'components/inputs/file-picker',
    blurb: {
      en: 'A box you drop files on, or click to open the file dialog.',
      ko: '파일을 떨어뜨리거나 눌러서 대화상자를 여는 상자입니다.'
    },
    preview: <PlFilePicker size="xs" title="Drop a file" icon={null} />
  },
  {
    name: 'PlNumberField',
    group: 'inputs',
    href: 'components/inputs/number-field',
    blurb: {
      en: 'A field that only holds a number, with real steppers.',
      ko: '숫자만 담는 field. 진짜 스테퍼가 달려 있습니다.'
    },
    preview: <PlNumberField fullWidth size="sm" defaultValue={2} min={1} max={12} />
  },
  {
    name: 'PlPagination',
    group: 'inputs',
    href: 'components/inputs/pagination',
    blurb: {
      en: 'The strip of page numbers under a long list.',
      ko: '긴 목록 아래에 놓이는 페이지 번호 줄입니다.'
    },
    preview: <PlPagination size="xs" count={9} defaultPage={3} />
  },
  {
    name: 'PlRadioGroup',
    group: 'inputs',
    href: 'components/inputs/radio-group',
    blurb: {
      en: 'A set of options where exactly one is chosen.',
      ko: '여러 옵션 중 정확히 하나를 고르는 묶음입니다.'
    },
    preview: (
      <PlRadioGroup size="sm" orientation="horizontal" defaultValue="card">
        <PlRadio value="card" label="Card" />
        <PlRadio value="transfer" label="Transfer" />
      </PlRadioGroup>
    )
  },
  {
    name: 'PlSegmentedButton',
    group: 'inputs',
    href: 'components/inputs/segmented-button',
    blurb: {
      en: 'Two or more choices in one pill, exactly one of them taken.',
      ko: '알약 하나에 담긴 선택지 중 정확히 하나가 선택됩니다.'
    },
    preview: (
      <PlSegmentedButton size="xs" aria-label="Period" defaultValue="week">
        <PlSegment value="day">Day</PlSegment>
        <PlSegment value="week">Week</PlSegment>
        <PlSegment value="month">Month</PlSegment>
      </PlSegmentedButton>
    )
  },
  {
    name: 'PlSelect',
    group: 'inputs',
    href: 'components/inputs/select',
    blurb: {
      en: 'One value chosen from a list, on a text field\u2019s shell.',
      ko: '목록에서 값 하나를 고릅니다. text field와 같은 껍데기를 씁니다.'
    },
    preview: (
      <PlSelect
        size="sm"
        fullWidth
        items={[
          { value: 'seoul', label: 'Seoul' },
          { value: 'lisbon', label: 'Lisbon' }
        ]}
        defaultValue="seoul"
      />
    )
  },
  {
    name: 'PlSlider',
    group: 'inputs',
    href: 'components/inputs/slider',
    blurb: {
      en: 'A value chosen along a range.',
      ko: '범위 위에서 값 하나를 고릅니다.'
    },
    preview: <PlSlider size="sm" defaultValue={62} aria-label="Volume" />
  },
  {
    name: 'PlSwitch',
    group: 'inputs',
    href: 'components/inputs/switch',
    blurb: {
      en: 'An immediate on/off — it takes effect the moment it moves.',
      ko: '즉시 반영되는 켜짐/꺼짐. 움직이는 순간 적용됩니다.'
    },
    preview: (
      <div className="flex flex-col gap-2">
        <PlSwitch size="sm" label="Dark mode" defaultChecked />
        <PlSwitch size="sm" label="Beta features" />
      </div>
    )
  },
  {
    name: 'PlImage',
    group: 'display',
    href: 'components/display/image',
    blurb: {
      en: 'A picture, and the two states it spends most of its life in.',
      ko: '사진, 그리고 그것이 일생의 대부분을 보내는 두 상태입니다.'
    },
    preview: (
      <div className="grid w-full grid-cols-2 gap-2">
        <PlImage src="/portrait-1.svg" alt="A portrait" ratio="1" rounded size="sm" />
        <PlImage src="/does-not-exist.png" alt="Did not arrive" ratio="1" rounded size="sm" />
      </div>
    )
  },
  {
    name: 'PlList',
    group: 'display',
    href: 'components/display/list',
    blurb: {
      en: 'A stack of rows, on a sheet that holds them.',
      ko: '행이 쌓인 묶음. 그것을 담는 시트 위에 놓입니다.'
    },
    preview: (
      <PlList size="xs" className="w-full">
        <PlListItem selected description="Three unread" onClick={() => {}}>
          Inbox
        </PlListItem>
        <PlListItem description="One saved" onClick={() => {}}>
          Drafts
        </PlListItem>
      </PlList>
    )
  },
  {
    name: 'PlTable',
    group: 'display',
    href: 'components/display/table',
    blurb: {
      en: 'A grid of data, taken as columns and rows rather than as markup.',
      ko: '마크업이 아니라 column과 row로 받는 데이터 격자입니다.'
    },
    preview: (
      <PlTable
        size="xs"
        className="w-full"
        columns={[
          { key: 'metric', header: 'Metric' },
          { key: 'value', header: 'Value', align: 'end' }
        ]}
        rows={[
          { metric: 'Requests', value: '12.4k' },
          { metric: 'Errors', value: '18' }
        ]}
      />
    )
  },
  {
    name: 'PlAppLogo',
    group: 'display',
    href: 'components/display/app-logo',
    blurb: {
      en: "A product's mark, and its name beside it.",
      ko: '제품의 마크와 그 옆의 이름입니다.'
    },
    preview: (
      <PlAppLogo shape="plate" size="sm" name="Acme" description="Staging">
        <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
          <path
            d="M4 20 12 4l8 16"
            stroke="currentColor"
            strokeWidth="2.4"
            strokeLinejoin="round"
          />
        </svg>
      </PlAppLogo>
    )
  },
  {
    name: 'PlAvatar',
    group: 'display',
    href: 'components/display/avatar',
    blurb: {
      en: 'A picture of a person or a thing that is never an empty box.',
      ko: '사람이나 사물의 사진. 절대 빈 상자가 되지 않습니다.'
    },
    preview: (
      <div className="flex items-center gap-2">
        <PlAvatar size="sm" name="Ada Lovelace" src="/portrait-1.svg" />
        <PlAvatar size="sm" name="Grace Hopper" />
        <PlAvatar size="sm" variant="solid" color="info" name="홍길동" />
      </div>
    )
  },
  {
    name: 'PlBadge',
    group: 'display',
    href: 'components/display/badge',
    blurb: {
      en: 'A small mark in the corner of something else.',
      ko: '다른 무언가의 모서리에 놓이는 작은 표시입니다.'
    },
    preview: (
      <div className="flex flex-wrap items-center gap-6">
        <PlBadge size="sm" content={4} label="4 unread">
          <PlButton size="sm" variant="glass" color="secondary">
            Inbox
          </PlButton>
        </PlBadge>
        <PlBadge dot color="success" overlap="circle" label="Online">
          <PlAvatar size="sm" name="Ada Lovelace" />
        </PlBadge>
        <PlBadge size="sm" variant="ghost" color="info" content="Beta" />
      </div>
    )
  },
  {
    name: 'PlBlockquote',
    group: 'display',
    href: 'components/display/blockquote',
    blurb: {
      en: 'Somebody else’s words, set apart from your own.',
      ko: '남의 말을 자기 말과 떼어 놓습니다.'
    },
    preview: (
      <PlBlockquote size="xs" className="w-full" icon={false} author="Ada Lovelace">
        Simplicity is hard.
      </PlBlockquote>
    )
  },
  {
    name: 'PlBreadcrumb',
    group: 'display',
    href: 'components/display/breadcrumb',
    blurb: {
      en: 'The trail of pages above the one being read.',
      ko: '지금 읽고 있는 페이지 위쪽으로 이어지는 자취입니다.'
    },
    previewHasLinks: true,
    preview: (
      <PlBreadcrumb size="sm">
        <PlBreadcrumbItem href="#gallery">Home</PlBreadcrumbItem>
        <PlBreadcrumbItem href="#gallery">Settings</PlBreadcrumbItem>
        <PlBreadcrumbItem>Billing</PlBreadcrumbItem>
      </PlBreadcrumb>
    )
  },
  {
    name: 'PlChip',
    group: 'display',
    href: 'components/display/chip',
    blurb: {
      en: 'A compact token: a tag, a filter, a status, an entity.',
      ko: '작고 촘촘한 토큰. 태그, 필터, 상태, 개체 하나입니다.'
    },
    preview: (
      <div className="flex flex-wrap items-center gap-2">
        <PlChip size="sm" selected onClick={() => {}} count={12}>
          open
        </PlChip>
        <PlChip size="sm" variant="ghost" color="secondary" onDelete={() => {}}>
          design
        </PlChip>
      </div>
    )
  },
  {
    name: 'PlDivider',
    group: 'display',
    href: 'components/display/divider',
    blurb: {
      en: 'A rule between two things, with or without a label set into it.',
      ko: '두 가지 사이에 놓이는 선. 라벨을 안에 넣을 수도 있습니다.'
    },
    preview: (
      <div className="flex w-full flex-col gap-3">
        <PlDivider />
        <PlDivider size="xs">OR</PlDivider>
      </div>
    )
  },
  {
    name: 'PlHighlight',
    group: 'display',
    href: 'components/display/highlight',
    blurb: {
      en: 'Marks the words a reader is looking for, inside text they were reading.',
      ko: '읽고 있던 글 안에서 찾고 있던 단어를 표시합니다.'
    },
    preview: (
      <p className="text-sm/7 text-(--plass-fg)">
        <PlHighlight query="tinted glass">A key of tinted glass on a clear sheet.</PlHighlight>
      </p>
    )
  },
  {
    name: 'PlHotKeys',
    group: 'display',
    href: 'components/display/hot-keys',
    blurb: {
      en: 'A keyboard key, or a combination of them.',
      ko: '키보드 키 하나, 또는 그 조합입니다.'
    },
    preview: (
      <div className="flex flex-wrap items-center gap-3">
        <PlHotKeys size="sm" keys="Mod+K" />
        <PlHotKeys size="sm" keys="Shift+Enter" />
      </div>
    )
  },
  {
    name: 'PlIcon',
    group: 'display',
    href: 'components/display/icon',
    blurb: {
      en: 'A glyph at a known size, in a known colour.',
      ko: '정해진 크기와 색으로 놓이는 글리프입니다.'
    },
    preview: (
      <div className="flex flex-wrap items-center gap-4">
        {(['primary', 'success', 'warning', 'danger'] as const).map((color) => (
          <PlIcon
            key={color}
            color={color}
            icon={
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
                <path d="M13 2 4 14h7l-1 8 9-12h-7Z" strokeLinejoin="round" />
              </svg>
            }
          />
        ))}
      </div>
    )
  },
  {
    name: 'PlTextLink',
    group: 'display',
    href: 'components/display/text-link',
    blurb: {
      en: 'A link, in a sentence or on its own.',
      ko: '문장 안에, 또는 홀로 놓이는 링크입니다.'
    },
    previewHasLinks: true,
    preview: (
      <p className="text-sm text-(--plass-fg)">
        Read <PlTextLink href="#gallery">the reference</PlTextLink>, or the{' '}
        <PlTextLink href="https://base-ui.com" newTab>
          Base UI docs
        </PlTextLink>
        .
      </p>
    )
  },
  {
    name: 'PlDataList',
    group: 'display',
    href: 'components/display/data-list',
    blurb: {
      en: 'One thing and its fields, as a real description list.',
      ko: '하나와 그 필드들. 진짜 설명 목록으로 그립니다.'
    },
    preview: (
      <PlDataList className="w-full" size="sm" labelWidth="6rem">
        <PlDataListItem label="Owner" value="Ada Lovelace" />
        <PlDataListItem label="Plan" value="Team" />
      </PlDataList>
    )
  },
  {
    name: 'PlTimeline',
    group: 'display',
    href: 'components/display/timeline',
    blurb: {
      en: 'A sequence of steps, in the order they happen in.',
      ko: '일이 일어난 순서대로 늘어놓은 단계들입니다.'
    },
    preview: (
      <PlTimeline size="xs" density="compact" active={1} className="w-full">
        <PlTimelineItem title="Ordered" bullet="1" />
        <PlTimelineItem title="Packed" bullet="2" />
        <PlTimelineItem title="Shipped" bullet="3" />
      </PlTimeline>
    )
  },
  {
    name: 'PlShow',
    group: 'layout',
    href: 'components/layout/show',
    blurb: {
      en: 'Content at some widths and not others, decided in CSS.',
      ko: '어떤 너비에서는 보이고 어떤 너비에서는 보이지 않는 내용. CSS가 정합니다.'
    },
    preview: (
      <div className="flex flex-wrap items-center justify-center gap-2">
        <PlShow until="md">
          <PlChip size="sm" variant="solid" color="warning">
            Narrow
          </PlChip>
        </PlShow>
        <PlShow from="md">
          <PlChip size="sm" variant="solid" color="success">
            Wide
          </PlChip>
        </PlShow>
      </div>
    )
  },
  {
    name: 'PlPortal',
    group: 'layout',
    href: 'components/layout/portal',
    blurb: {
      en: 'Children, rendered somewhere else in the document.',
      ko: '문서의 다른 자리에 그려지는 자식들입니다.'
    },
    preview: (
      <div className="w-full rounded-(--plass-radius-sm) border border-dashed border-(--plass-border) p-3 text-center text-xs text-(--plass-muted-fg)">
        Written here
        <PlPortal disabled className="mt-2 text-(--plass-fg)">
          Drawn wherever it was sent
        </PlPortal>
      </div>
    )
  },
  {
    name: 'PlStack',
    group: 'layout',
    href: 'components/layout/stack',
    blurb: {
      en: 'Things piled up, overlapping — faces, cards, thumbnails.',
      ko: '겹쳐 쌓인 것들입니다 — 얼굴이든 카드든 썸네일이든.'
    },
    preview: (
      <PlStack ring max={3} total={9} overflow={(hidden) => <PlAvatar initials={`+${hidden}`} />}>
        <PlAvatar size="sm" name="Ada Lovelace" src="/portrait-1.svg" />
        <PlAvatar size="sm" name="Grace Hopper" src="/portrait-2.svg" />
        <PlAvatar size="sm" name="홍길동" />
        <PlAvatar size="sm" name="Katherine Johnson" />
      </PlStack>
    )
  },
  {
    name: 'PlStat',
    group: 'display',
    href: 'components/display/stat',
    blurb: {
      en: 'One figure, and what has happened to it.',
      ko: '숫자 하나, 그리고 그것에 무슨 일이 일어났는지.'
    },
    preview: (
      <div className="grid w-full grid-cols-2 gap-3">
        <PlStat size="xs" label="Revenue" value="£48,120" change={12.4} />
        <PlStat size="xs" label="Churn" value="4.2%" change={2.6} improvesWhen="down" />
      </div>
    )
  },
  {
    name: 'PlTree',
    group: 'display',
    href: 'components/display/tree',
    blurb: {
      en: 'A hierarchy, opened one branch at a time.',
      ko: '한 번에 한 가지씩 펼치는 계층입니다.'
    },
    preview: (
      <PlTree
        size="xs"
        className="w-full"
        defaultExpanded={['src']}
        defaultSelected={['button']}
        items={[
          {
            id: 'src',
            label: 'src',
            children: [
              { id: 'index', label: 'index.ts' },
              { id: 'button', label: 'PlButton.tsx' }
            ]
          },
          { id: 'readme', label: 'README.md' }
        ]}
      />
    )
  },
  {
    name: 'PlTypography',
    group: 'display',
    href: 'components/display/typography',
    blurb: {
      en: 'The library’s type scale on its own.',
      ko: '라이브러리의 타입 스케일 그 자체입니다.'
    },
    preview: (
      <div className="flex w-full flex-col">
        <PlTypography level="overline">Section</PlTypography>
        <PlTypography level="h4">A material rather than a theme</PlTypography>
        <PlTypography level="caption">Ten levels, one ladder.</PlTypography>
      </div>
    )
  },
  {
    name: 'PlVisuallyHidden',
    group: 'display',
    href: 'components/display/visually-hidden',
    blurb: {
      en: 'Content for a screen reader and for nobody else.',
      ko: '스크린 리더에게만 주는 내용입니다.'
    },
    preview: (
      <div className="flex w-full flex-col items-center gap-2">
        <div className="flex gap-2">
          {[
            { glyph: '★', name: 'Add to favourites' },
            { glyph: '⌫', name: 'Delete' },
            { glyph: '✕', name: 'Close' }
          ].map((action) => (
            <button
              key={action.name}
              type="button"
              className="inline-flex size-9 items-center justify-center rounded-(--plass-radius-md) border bg-(--plass-glass) [border-color:var(--plass-border)]"
            >
              <span aria-hidden="true">{action.glyph}</span>
              <PlVisuallyHidden>{action.name}</PlVisuallyHidden>
            </button>
          ))}
        </div>
        <span className="text-[0.625rem] text-(--plass-muted-fg)">
          Three glyphs drawn, three names announced.
        </span>
      </div>
    )
  },
  {
    name: 'PlAlert',
    group: 'feedback',
    href: 'components/feedback/alert',
    blurb: {
      en: 'A message about something that happened, set into the page.',
      ko: '일어난 일에 대한 메시지를 페이지 안에 놓습니다.'
    },
    preview: (
      <PlAlert size="xs" color="success" className="w-full">
        Your changes are live.
      </PlAlert>
    )
  },
  {
    name: 'PlConfirmProvider',
    group: 'feedback',
    href: 'components/feedback/confirm',
    blurb: {
      en: 'One dialog, asked for from anywhere and awaited.',
      ko: 'dialog 하나를 어디서든 불러 쓰고 기다립니다.'
    },
    preview: (
      <PlConfirmProvider>
        <ConfirmPreview />
      </PlConfirmProvider>
    )
  },
  {
    name: 'PlDrawer',
    group: 'feedback',
    href: 'components/feedback/drawer',
    blurb: {
      en: 'A panel attached to one edge of the window.',
      ko: '창의 한 가장자리에 붙은 판입니다.'
    },
    preview: <DrawerPreview />
  },
  {
    name: 'PlPopover',
    group: 'feedback',
    href: 'components/feedback/popover',
    blurb: {
      en: 'A sheet that opens beside the thing that opened it.',
      ko: '자기를 연 것 옆에 열리는 시트입니다.'
    },
    preview: (
      <PlPopover
        size="sm"
        trigger={
          <PlButton size="sm" variant="glass" color="secondary">
            Explain
          </PlButton>
        }
        title="Effective rate"
      >
        The base rate plus whatever your plan adds to it.
      </PlPopover>
    )
  },
  {
    name: 'PlModal',
    group: 'feedback',
    href: 'components/feedback/modal',
    blurb: {
      en: 'A sheet that takes the page away until it is answered.',
      ko: '답할 때까지 페이지를 가져가는 시트입니다.'
    },
    preview: (
      <PlModal
        size="sm"
        trigger={<PlButton size="sm">Open a modal</PlButton>}
        title="Delete “Aurora”?"
        description="Everything in it goes with it."
        actions={<PlModalClose render={<PlButton size="sm">Close</PlButton>} />}
      />
    )
  },
  {
    name: 'PlEmpty',
    group: 'feedback',
    href: 'components/feedback/empty',
    blurb: {
      en: 'The place where there is nothing, and the way out of it.',
      ko: '아무것도 없는 자리, 그리고 거기서 빠져나갈 길입니다.'
    },
    preview: (
      <PlEmpty
        size="xs"
        icon={<span>📭</span>}
        title="No projects yet"
        description="Start one and it will show up here."
        actions={<PlButton size="xs">New project</PlButton>}
      />
    )
  },
  {
    name: 'PlPopconfirm',
    group: 'feedback',
    href: 'components/feedback/popconfirm',
    blurb: {
      en: 'A question asked where it was raised.',
      ko: '물음이 일어난 자리에서 묻습니다.'
    },
    preview: (
      <PlPopconfirm
        title="Delete this row?"
        description="It cannot be undone."
        confirmLabel="Delete"
        trigger={
          <PlButton size="sm" variant="glass" color="danger">
            Delete
          </PlButton>
        }
      />
    )
  },
  {
    name: 'PlOverlay',
    group: 'feedback',
    href: 'components/feedback/overlay',
    blurb: {
      en: 'A sheet over the whole page that stops it being used.',
      ko: '페이지 전체를 덮어 쓸 수 없게 만드는 판입니다.'
    },
    preview: <OverlayPreview />
  },
  {
    name: 'PlProgressBox',
    group: 'feedback',
    href: 'components/feedback/progress-box',
    blurb: {
      en: 'A row of small glass plates that light up, in order or in sequence.',
      ko: '불이 들어오는 작은 유리판들의 줄입니다. 차례대로, 또는 순환하며.'
    },
    preview: <PlProgressBox size="sm" label="Step 3 of 5" value={3} max={5} count={5} showValue />
  },
  {
    name: 'PlProgressCircular',
    group: 'feedback',
    href: 'components/feedback/progress-circular',
    blurb: {
      en: 'A ring that fills, for where there is no room for a bar.',
      ko: '차오르는 링입니다. 바를 놓을 자리가 없는 곳에 씁니다.'
    },
    preview: <PlProgressCircular size="sm" label="Syncing" value={68} showValue />
  },
  {
    name: 'PlMeter',
    group: 'feedback',
    href: 'components/feedback/meter',
    blurb: {
      en: 'A quantity inside a range — already known, not advancing.',
      ko: '범위 안의 양입니다. 진행 중인 것이 아니라 이미 알고 있는 것입니다.'
    },
    preview: (
      <div className="flex w-full flex-col gap-3">
        <PlMeter size="sm" value={62} label="Seats taken" showValue />
        <PlMeter
          size="sm"
          value={94}
          label="Disk used"
          showValue
          thresholds={[
            { from: 75, color: 'warning' },
            { from: 90, color: 'danger' }
          ]}
        />
      </div>
    )
  },
  {
    name: 'PlProgressLinear',
    group: 'feedback',
    href: 'components/feedback/progress-linear',
    blurb: {
      en: 'A bar that fills, or sweeps when nobody knows how far along it is.',
      ko: '차오르는 바입니다. 얼마나 남았는지 모를 때는 훑고 지나갑니다.'
    },
    preview: (
      <PlProgressLinear className="w-full" size="sm" label="Uploading" value={62} showValue />
    )
  },
  {
    name: 'PlSkeleton',
    group: 'feedback',
    href: 'components/feedback/skeleton',
    blurb: {
      en: 'The shape of something that has not loaded yet.',
      ko: '아직 로드되지 않은 것의 모양입니다.'
    },
    preview: (
      <div className="flex w-full items-center gap-3">
        <PlSkeleton shape="circle" size="sm" />
        <PlSkeleton size="sm" lines={2} />
      </div>
    )
  },
  {
    name: 'PlToast',
    group: 'feedback',
    href: 'components/feedback/toast',
    blurb: {
      en: 'A message that appears on its own, says what happened, and leaves.',
      ko: '스스로 나타나 무슨 일이 있었는지 말하고 사라지는 메시지입니다.'
    },
    preview: (
      <PlToastProvider timeout={3000}>
        <ToastPreview />
      </PlToastProvider>
    )
  },
  {
    name: 'PlTooltip',
    group: 'feedback',
    href: 'components/feedback/tooltip',
    blurb: {
      en: 'A short label that appears when the pointer rests on something.',
      ko: '포인터가 무언가에 머무를 때 나타나는 짧은 라벨입니다.'
    },
    preview: (
      <PlTooltip content="Copy to clipboard" side="right">
        <PlButton size="sm" variant="glass" color="secondary">
          Rest here
        </PlButton>
      </PlTooltip>
    )
  },
  {
    name: 'PlBox',
    group: 'surfaces',
    href: 'components/surfaces/box',
    blurb: {
      en: 'A sheet of glass with content on it, and nothing else claimed.',
      ko: '내용을 얹은 유리 한 장, 그 이상은 주장하지 않습니다.'
    },
    preview: (
      <PlBox size="sm" className="w-full text-xs">
        It groups things, and that is all it does.
      </PlBox>
    )
  },
  {
    name: 'PlCard',
    group: 'surfaces',
    href: 'components/surfaces/card',
    blurb: {
      en: 'The sheet everything else on a screen is grouped onto.',
      ko: '화면의 나머지를 묶어 놓는 시트입니다.'
    },
    preview: (
      <PlCard size="xs" className="w-full" title="Team plan" subtitle="Billed yearly">
        Shared projects and audit logs.
      </PlCard>
    )
  },
  {
    name: 'PlCarousel',
    group: 'surfaces',
    href: 'components/surfaces/carousel',
    blurb: {
      en: 'A strip of slides, one of which is in view.',
      ko: '슬라이드가 늘어선 띠이고, 그중 하나가 보입니다.'
    },
    preview: (
      <PlCarousel className="w-full" size="sm" label="Places" arrows={false}>
        {['Harbour', 'Dunes', 'Pines'].map((place) => (
          <div
            key={place}
            className="flex h-16 items-center justify-center bg-(--plass-primary-soft) text-xs"
          >
            {place}
          </div>
        ))}
      </PlCarousel>
    )
  },
  {
    name: 'PlChatBubble',
    group: 'surfaces',
    href: 'components/surfaces/chat-bubble',
    blurb: {
      en: 'One message in a conversation.',
      ko: '대화 속 메시지 하나입니다.'
    },
    preview: (
      <div className="flex w-full flex-col gap-2">
        <PlChatBubble size="xs" avatar={<PlAvatar size="xs" name="Ada Lovelace" />}>
          The gradient turns rather than shades.
        </PlChatBubble>
        <PlChatBubble size="xs" side="end" variant="solid" status="read">
          Already did.
        </PlChatBubble>
      </div>
    )
  },
  {
    name: 'PlCollapsible',
    group: 'surfaces',
    href: 'components/surfaces/collapsible',
    blurb: {
      en: 'One section that folds, standing on its own.',
      ko: '혼자 서 있는, 접히는 섹션 하나입니다.'
    },
    preview: (
      <PlCollapsible className="w-full" size="sm" title="Advanced" subtitle="Nine settings">
        Nothing grows until somebody asks for it.
      </PlCollapsible>
    )
  },
  {
    name: 'PlHoverCard',
    group: 'surfaces',
    href: 'components/surfaces/hover-card',
    blurb: {
      en: 'A preview of what is behind a link, shown when the pointer rests on it.',
      ko: '포인터가 머물면 링크 뒤에 무엇이 있는지 미리 보여 줍니다.'
    },
    previewHasLinks: true,
    preview: (
      <p className="text-sm">
        Written by{' '}
        <PlHoverCard
          size="sm"
          title="Ada Lovelace"
          description="Mathematician"
          trigger={<PlTextLink href="#ada">Ada Lovelace</PlTextLink>}
        >
          Wrote the first algorithm intended for a machine.
        </PlHoverCard>
      </p>
    )
  },
  {
    name: 'PlPill',
    group: 'surfaces',
    href: 'components/surfaces/pill',
    blurb: {
      en: 'A floating lozenge holding a small amount of live information.',
      ko: '살아 있는 정보를 조금 담고 떠 있는 알약입니다.'
    },
    preview: <PlPill size="sm" color="danger" title="Recording" description="00:41" />
  },
  {
    name: 'PlSpoiler',
    group: 'surfaces',
    href: 'components/surfaces/spoiler',
    blurb: {
      en: 'Content that is covered until somebody asks for it.',
      ko: '누군가 요청할 때까지 덮여 있는 내용입니다.'
    },
    preview: (
      <PlSpoiler className="w-full" size="sm">
        <span className="text-xs">He was the killer all along.</span>
      </PlSpoiler>
    )
  },
  {
    name: 'PlToggle',
    group: 'inputs',
    href: 'components/inputs/toggle',
    blurb: {
      en: 'A button that stays down, and a set of them that share one state.',
      ko: '눌린 채로 남는 버튼, 그리고 하나의 상태를 나누는 그 묶음입니다.'
    },
    preview: (
      <PlToggleGroup size="sm" defaultValue={['left']}>
        <PlToggle value="left">Left</PlToggle>
        <PlToggle value="center">Center</PlToggle>
        <PlToggle value="right">Right</PlToggle>
      </PlToggleGroup>
    )
  },
  {
    name: 'PlTransfer',
    group: 'inputs',
    href: 'components/inputs/transfer',
    blurb: {
      en: 'Two lists and the arrows between them, for a choice that is long.',
      ko: '두 목록과 그 사이의 화살표. 선택지가 길 때를 위한 것입니다.'
    },
    preview: (
      <PlTransfer
        className="w-full"
        size="xs"
        height={72}
        items={[
          { value: 'a', label: 'Name' },
          { value: 'b', label: 'Email' },
          { value: 'c', label: 'Role' }
        ]}
        defaultValue={['b']}
      />
    )
  },
  {
    name: 'PlToolbar',
    group: 'surfaces',
    href: 'components/surfaces/toolbar',
    blurb: {
      en: 'A bar of controls: a header, an action row, an editor strip.',
      ko: '컨트롤이 늘어선 바입니다 — 헤더, 액션 줄, 에디터의 띠.'
    },
    preview: (
      <PlToolbar
        className="w-full"
        size="sm"
        start={<span className="text-xs font-semibold">Reports</span>}
        end={
          <PlButton size="sm" variant="glass" color="secondary">
            New
          </PlButton>
        }
      />
    )
  },
  {
    name: 'PlTabs',
    group: 'surfaces',
    href: 'components/surfaces/tabs',
    blurb: {
      en: 'One set of panels, one of which is shown.',
      ko: '여러 패널 중 하나를 보여 주는 묶음입니다.'
    },
    preview: (
      <PlTabs size="xs" defaultValue="a" className="w-full">
        <PlTab value="a">Account</PlTab>
        <PlTab value="b">Billing</PlTab>
        <PlTabPanel value="a">Your name and your avatar.</PlTabPanel>
        <PlTabPanel value="b">Cards and invoices.</PlTabPanel>
      </PlTabs>
    )
  },
  {
    name: 'PlAspectRatio',
    group: 'layout',
    href: 'components/layout/aspect-ratio',
    blurb: {
      en: 'A box that keeps a proportion whatever width it is given.',
      ko: '어떤 너비를 받든 비율을 지키는 상자입니다.'
    },
    preview: (
      <div className="grid w-full grid-cols-3 gap-2">
        {['1 / 1', '4 / 3', '16 / 9'].map((ratio) => (
          <PlAspectRatio key={ratio} ratio={ratio} rounded size="sm">
            <div className="flex size-full items-center justify-center bg-(--plass-glass-press) text-[0.625rem]">
              {ratio}
            </div>
          </PlAspectRatio>
        ))}
      </div>
    )
  },
  {
    name: 'PlContainer',
    group: 'layout',
    href: 'components/layout/container',
    blurb: {
      en: 'Horizontal breathing room, and optionally a measure.',
      ko: '양옆으로 숨 쉴 자리, 그리고 원한다면 최대 너비까지.'
    },
    preview: (
      <div className="w-full rounded-(--plass-radius-md) bg-(--plass-glass-press) py-2">
        <PlContainer maxWidth="xs" size="sm">
          <div className="rounded-(--plass-radius-sm) bg-(--plass-glass) py-1.5 text-center text-xs">
            the page, held to a measure
          </div>
        </PlContainer>
      </div>
    )
  },
  {
    name: 'PlGrid',
    group: 'layout',
    href: 'components/layout/grid',
    blurb: {
      en: 'A twelve-column row and the cells in it.',
      ko: '12칸짜리 한 줄과 그 안의 칸들입니다.'
    },
    preview: (
      <PlGrid className="w-full" spacing={2}>
        {[6, 3, 3, 4, 8].map((span, index) => (
          <PlGridItem key={index} span={span}>
            <div className="rounded-(--plass-radius-sm) bg-(--plass-glass-press) py-1.5 text-center text-xs">
              {span}
            </div>
          </PlGridItem>
        ))}
      </PlGrid>
    )
  },
  {
    name: 'PlFlex',
    group: 'layout',
    href: 'components/layout/flex',
    blurb: {
      en: 'A row or a column, and the gap between the things in it.',
      ko: '가로 한 줄 또는 세로 한 칸, 그리고 그 사이의 간격입니다.'
    },
    preview: (
      <PlFlex className="w-full" spacing={2} alignItems="center" justify="space-between">
        {['one', 'two', 'three'].map((label) => (
          <div
            key={label}
            className="rounded-(--plass-radius-sm) bg-(--plass-glass-press) px-3 py-1.5 text-center text-xs"
          >
            {label}
          </div>
        ))}
      </PlFlex>
    )
  },
  {
    name: 'PlFieldset',
    group: 'inputs',
    href: 'components/inputs/fieldset',
    blurb: {
      en: 'A group of controls that answer one question together, with a name on it.',
      ko: '한 질문에 함께 답하는 컨트롤 묶음이고, 그 위에 이름이 붙습니다.'
    },
    preview: (
      <PlFieldset size="sm" legend="Billing address" className="w-full">
        <PlTextField size="sm" label="Street" fullWidth />
      </PlFieldset>
    )
  },
  {
    name: 'PlForm',
    group: 'inputs',
    href: 'components/inputs/form',
    blurb: {
      en: 'A form that knows which of its fields is wrong.',
      ko: '자기 필드 중 무엇이 틀렸는지 아는 폼입니다.'
    },
    preview: (
      <PlForm size="sm" className="w-full">
        <PlTextField name="email" size="sm" label="Email" required />
        <PlButton type="submit" size="sm">
          Sign in
        </PlButton>
      </PlForm>
    )
  },
  {
    name: 'PlIconButton',
    group: 'inputs',
    href: 'components/inputs/icon-button',
    blurb: {
      en: 'A round button with a glyph in it and nothing else.',
      ko: '글리프 하나만 든 둥근 버튼입니다.'
    },
    preview: (
      <div className="flex flex-wrap items-center gap-2">
        <PlIconButton size="sm" label="Like" icon={<HeartGlyph />} />
        <PlIconButton size="sm" variant="glass" label="Share" icon={<ShareGlyph />} />
        <PlIconButton
          size="sm"
          variant="ghost"
          color="secondary"
          label="More"
          icon={<MoreGlyph />}
        />
      </div>
    )
  },
  {
    name: 'PlRating',
    group: 'inputs',
    href: 'components/inputs/rating',
    blurb: {
      en: 'A score out of five, as a row of stars.',
      ko: '별 한 줄로 표현한 5점 만점의 점수입니다.'
    },
    preview: <PlRating defaultValue={4} />
  },
  {
    name: 'PlOtpField',
    group: 'inputs',
    href: 'components/inputs/otp-field',
    blurb: {
      en: 'A row of one-character slots: a PIN, a texted code.',
      ko: '한 글자짜리 칸이 늘어선 줄입니다 — PIN, 문자로 받은 코드.'
    },
    preview: <PlOtpField size="sm" length={4} groupSize={2} defaultValue="12" />
  },
  {
    name: 'PlBottomNavigation',
    group: 'navigation',
    href: 'components/navigation/bottom-navigation',
    blurb: {
      en: 'A row of destinations held against the bottom edge of the window.',
      ko: '창의 아래 가장자리에 붙어 있는 목적지 한 줄입니다.'
    },
    preview: (
      <PlBottomNavigation
        className="w-full"
        size="sm"
        position="static"
        safeArea={false}
        defaultValue="home"
      >
        <PlBottomNavigationItem value="home" icon={<HomeGlyph />}>
          Home
        </PlBottomNavigationItem>
        <PlBottomNavigationItem value="search" icon={<SearchGlyph />}>
          Search
        </PlBottomNavigationItem>
        <PlBottomNavigationItem value="account" icon={<AccountGlyph />}>
          Account
        </PlBottomNavigationItem>
      </PlBottomNavigation>
    )
  },
  {
    name: 'PlFloatingBottomNavigation',
    group: 'navigation',
    href: 'components/navigation/floating-bottom-navigation',
    blurb: {
      en: 'Round destinations floating clear of the bottom edge.',
      ko: '아래 가장자리에서 떠 있는 둥근 목적지들입니다.'
    },
    preview: (
      <PlFloatingBottomNavigation size="sm" position="static" safeArea={false} defaultValue="home">
        <PlFloatingBottomNavigationItem value="home" icon={<HomeGlyph />}>
          Home
        </PlFloatingBottomNavigationItem>
        <PlFloatingBottomNavigationItem value="search" icon={<SearchGlyph />}>
          Search
        </PlFloatingBottomNavigationItem>
        <PlFloatingBottomNavigationItem value="account" icon={<AccountGlyph />}>
          Account
        </PlFloatingBottomNavigationItem>
      </PlFloatingBottomNavigation>
    )
  },
  {
    name: 'PlAnchor',
    group: 'navigation',
    href: 'components/navigation/anchor',
    blurb: {
      en: 'A table of contents that follows the reader down the page.',
      ko: '읽는 사람을 따라 페이지를 내려가는 목차입니다.'
    },
    previewHasLinks: true,
    preview: (
      <PlAnchor
        className="w-full"
        size="sm"
        active="#install"
        items={[
          { href: '#overview', label: 'Overview' },
          { href: '#install', label: 'Install' },
          { href: '#options', label: 'Options', depth: 1 }
        ]}
      />
    )
  },
  {
    name: 'PlBackTop',
    group: 'navigation',
    href: 'components/navigation/back-top',
    blurb: {
      en: 'The way back up, once there is a way back up to want.',
      ko: '올라갈 길이 생겼을 때의, 올라갈 길입니다.'
    },
    preview: <BackTopPreview />
  },
  {
    name: 'PlStepper',
    group: 'navigation',
    href: 'components/navigation/stepper',
    blurb: {
      en: 'A process the reader is moving through, and where they are in it.',
      ko: '사용자가 지나가고 있는 절차, 그리고 그 안의 지금 자리.'
    },
    preview: (
      <PlStepper size="xs" active={1} className="w-full">
        <PlStep label="Account" />
        <PlStep label="Verify" />
        <PlStep label="Profile" />
      </PlStepper>
    )
  },
  {
    name: 'PlMenubar',
    group: 'navigation',
    href: 'components/navigation/menubar',
    blurb: {
      en: 'The strip of words at the top of an application, each opening a menu.',
      ko: '애플리케이션 위쪽의 단어 띠이고, 각각이 메뉴를 엽니다.'
    },
    preview: (
      <PlMenubar size="sm">
        <PlMenubarMenu label="File">
          <PlMenuItem>New</PlMenuItem>
          <PlMenuSeparator />
          <PlMenuItem>Save</PlMenuItem>
        </PlMenubarMenu>
        <PlMenubarMenu label="Edit">
          <PlMenuItem>Copy</PlMenuItem>
        </PlMenubarMenu>
      </PlMenubar>
    )
  },
  {
    name: 'PlNavigationMenu',
    group: 'navigation',
    href: 'components/navigation/navigation-menu',
    previewHasLinks: true,
    blurb: {
      en: 'A row of destinations, some of which open a panel of more of them.',
      ko: '목적지의 행이고, 그중 일부는 더 많은 목적지가 든 패널을 엽니다.'
    },
    preview: (
      <PlNavigationMenu size="sm">
        <PlNavigationMenuItem label="Product">
          <PlNavigationMenuLink href="#" title="Analytics" />
          <PlNavigationMenuLink href="#" title="Billing" />
        </PlNavigationMenuItem>
        <PlNavigationMenuItem label="Pricing" href="#" />
      </PlNavigationMenu>
    )
  },
  {
    name: 'PlCommandPalette',
    group: 'navigation',
    href: 'components/navigation/command-palette',
    blurb: {
      en: 'Everything an application can do, behind one field.',
      ko: '애플리케이션이 할 수 있는 모든 것을, 필드 하나 뒤에.'
    },
    preview: <CommandPalettePreview />
  },
  {
    name: 'PlMenu',
    group: 'navigation',
    href: 'components/navigation/menu',
    blurb: {
      en: 'A list of actions that appears when something is pressed.',
      ko: '무언가를 눌렀을 때 나타나는 동작 목록입니다.'
    },
    preview: (
      <PlMenu
        size="sm"
        trigger={
          <PlButton size="sm" variant="glass">
            Actions
          </PlButton>
        }
      >
        <PlMenuItem shortcut="⌘X">Cut</PlMenuItem>
        <PlMenuItem shortcut="⌘C">Copy</PlMenuItem>
        <PlMenuSeparator />
        <PlMenuItem color="danger">Delete</PlMenuItem>
      </PlMenu>
    )
  },
  {
    name: 'PlSidebar',
    group: 'layout',
    href: 'components/layout/sidebar',
    blurb: {
      en: 'A column beside the content, and a drawer once the window is too narrow.',
      ko: '콘텐츠 옆의 열이고, 창이 좁아지면 drawer가 됩니다.'
    },
    preview: (
      <div className="h-20 w-full overflow-hidden rounded-(--plass-radius-sm)">
        <PlPageLayout
          height="auto"
          scroll="content"
          collapseBelow="none"
          skipLink={false}
          sidebar={
            <PlSidebar size="xs" width={72} label="Navigation">
              <span className="text-[0.625rem]">Nav</span>
            </PlSidebar>
          }
        >
          <div className="flex h-full items-center justify-center text-xs">Content</div>
        </PlPageLayout>
      </div>
    )
  },
  {
    name: 'PlFooter',
    group: 'layout',
    href: 'components/layout/footer',
    blurb: {
      en: "The sheet at the end of a page, and the site's own information.",
      ko: '페이지 끝의 시트이자, 사이트 자신의 정보입니다.'
    },
    preview: (
      <PlFooter size="xs" density="compact" className="w-full">
        <span className="text-xs text-(--plass-muted-fg)">© 2026 Acme</span>
      </PlFooter>
    )
  },
  {
    name: 'PlHeader',
    group: 'layout',
    href: 'components/layout/header',
    blurb: {
      en: "The bar across the top of a page, and the page's banner landmark.",
      ko: '페이지 위쪽을 가로지르는 바이자, 그 페이지의 banner landmark입니다.'
    },
    preview: (
      <PlHeader
        position="static"
        size="xs"
        className="w-full"
        brand={<span className="text-xs font-semibold">Acme</span>}
        actions={<span className="text-xs text-(--plass-muted-fg)">Account</span>}
      />
    )
  },
  {
    name: 'PlPageLayout',
    group: 'layout',
    href: 'components/layout/page-layout',
    blurb: {
      en: 'The skeleton a page is hung on, and the landmarks that come with it.',
      ko: '페이지를 걸어 두는 뼈대이고, 함께 따라오는 landmark입니다.'
    },
    preview: (
      <div className="h-20 w-full overflow-hidden rounded-(--plass-radius-sm)">
        <PlPageLayout
          height="auto"
          scroll="content"
          collapseBelow="none"
          skipLink={false}
          header={
            <div className="border-b [border-color:var(--plass-divider)] px-2 py-1 text-[0.625rem]">
              header
            </div>
          }
          sidebar={
            <div className="w-14 border-e [border-color:var(--plass-divider)] px-2 py-1 text-[0.625rem]">
              nav
            </div>
          }
          footer={
            <div className="border-t [border-color:var(--plass-divider)] px-2 py-1 text-[0.625rem]">
              footer
            </div>
          }
        >
          <div className="flex h-full items-center justify-center text-xs">main</div>
        </PlPageLayout>
      </div>
    )
  },
  {
    name: 'PlPanes',
    group: 'layout',
    href: 'components/layout/panes',
    blurb: {
      en: 'A set of regions with draggable handles between them.',
      ko: '사이에 끌 수 있는 손잡이가 놓인 영역 묶음입니다.'
    },
    preview: (
      <div className="h-20 w-full overflow-hidden rounded-(--plass-radius-sm)">
        <PlPanes size="sm">
          <PlPane defaultSize={35}>
            <div className="flex h-full items-center justify-center bg-(--plass-glass-press) text-xs">
              Sidebar
            </div>
          </PlPane>
          <PlPane>
            <div className="flex h-full items-center justify-center bg-(--plass-glass-press) text-xs">
              Body
            </div>
          </PlPane>
        </PlPanes>
      </div>
    )
  },
  {
    name: 'PlScrollArea',
    group: 'layout',
    href: 'components/layout/scroll-area',
    blurb: {
      en: "A bounded box that scrolls, with the library's own scrollbar in it.",
      ko: '스크롤되는, 크기가 정해진 상자입니다. 라이브러리 자신의 스크롤바가 들어 있습니다.'
    },
    preview: (
      <PlScrollArea className="w-full" height={96} size="sm" scrollbars="always" label="Preview">
        <div className="flex flex-col gap-2 pe-3 text-xs text-(--plass-muted-fg)">
          {['One', 'Two', 'Three', 'Four', 'Five', 'Six'].map((line) => (
            <span key={line}>{line}</span>
          ))}
        </div>
      </PlScrollArea>
    )
  },
  {
    name: 'PlScrollZone',
    group: 'layout',
    href: 'components/layout/scroll-zone',
    blurb: {
      en: 'A strip of anything, laid out in one direction and scrolled in it.',
      ko: '무엇이든 한 방향으로 늘어놓고 그 방향으로 스크롤하는 띠입니다.'
    },
    preview: (
      <PlScrollZone className="w-full" label="Teams" spacing={2} buttons="always" size="sm">
        {['Design', 'Engineering', 'Research', 'Support', 'Finance'].map((team) => (
          <PlChip key={team} size="sm">
            {team}
          </PlChip>
        ))}
      </PlScrollZone>
    )
  },
  {
    name: 'PlAccordion',
    group: 'surfaces',
    href: 'components/surfaces/accordion',
    blurb: {
      en: 'A stack of sections that fold open one at a time.',
      ko: '한 번에 하나씩 펼쳐지는 섹션 묶음입니다.'
    },
    preview: (
      <PlAccordion size="xs" className="w-full" defaultValue={['one']}>
        <PlAccordionItem value="one" title="Shipping">
          Three to five working days.
        </PlAccordionItem>
        <PlAccordionItem value="two" title="Returns">
          Thirty days from delivery.
        </PlAccordionItem>
      </PlAccordion>
    )
  },
  {
    name: 'PlAnimateFade',
    group: 'transitions',
    href: 'components/transitions/animate-fade',
    blurb: {
      en: 'Content arriving or leaving on opacity alone.',
      ko: '불투명도만으로 도착하거나 떠나는 내용입니다.'
    },
    preview: (
      <PlAnimateFade duration={1400} repeat="infinite" alternate>
        <PlChip color="primary">Fading</PlChip>
      </PlAnimateFade>
    )
  },
  {
    name: 'PlAnimateGrow',
    group: 'transitions',
    href: 'components/transitions/animate-grow',
    blurb: {
      en: 'Content unfolding from a point you choose.',
      ko: '고른 한 점에서 펼쳐지는 내용입니다.'
    },
    preview: (
      <PlAnimateGrow origin="top" from={0.5} duration={1400} repeat="infinite" alternate>
        <PlChip color="primary">Growing</PlChip>
      </PlAnimateGrow>
    )
  },
  {
    name: 'PlAnimateZoom',
    group: 'transitions',
    href: 'components/transitions/animate-zoom',
    blurb: {
      en: 'Content arriving from the middle of where it will end up.',
      ko: '끝날 자리의 한가운데에서 도착하는 내용입니다.'
    },
    preview: (
      <PlAnimateZoom from={0.3} duration={1300} repeat="infinite" alternate>
        <PlChip color="success">Zooming</PlChip>
      </PlAnimateZoom>
    )
  },
  {
    name: 'PlAnimateSlide',
    group: 'transitions',
    href: 'components/transitions/animate-slide',
    blurb: {
      en: 'Content travelling in from one edge.',
      ko: '한쪽 모서리에서 들어오는 내용입니다.'
    },
    preview: (
      <PlAnimateSlide from="left" distance={20} duration={1200} repeat="infinite" alternate>
        <PlChip color="info">Sliding</PlChip>
      </PlAnimateSlide>
    )
  },
  {
    name: 'PlAnimateReveal',
    group: 'transitions',
    href: 'components/transitions/animate-reveal',
    blurb: {
      en: 'Content uncovered behind a moving edge — nothing moves, no colour changes.',
      ko: '움직이는 가장자리 뒤로 드러나는 내용입니다. 아무것도 움직이지 않고 색도 바뀌지 않습니다.'
    },
    preview: (
      <PlAnimateReveal duration={1400} repeat="infinite" alternate>
        <PlChip color="warning">Revealing</PlChip>
      </PlAnimateReveal>
    )
  },
  {
    name: 'PlAnimateRotate',
    group: 'transitions',
    href: 'components/transitions/animate-rotate',
    blurb: {
      en: 'Content turning about a point — an arrival, or a spin that never lands.',
      ko: '한 점을 중심으로 도는 내용입니다. 도착일 수도, 끝나지 않는 회전일 수도 있습니다.'
    },
    preview: (
      <PlAnimateRotate
        from={0}
        to={360}
        duration={3000}
        easing="linear"
        repeat="infinite"
        fade={false}
      >
        <PlChip color="secondary">Turning</PlChip>
      </PlAnimateRotate>
    )
  },
  {
    name: 'PlAnimateBlink',
    group: 'transitions',
    href: 'components/transitions/animate-blink',
    blurb: {
      en: 'Content pulsing between full opacity and a floor.',
      ko: '완전한 불투명도와 바닥값 사이를 오가며 맥동하는 내용입니다.'
    },
    preview: (
      <PlAnimateBlink duration={1400} min={0.3}>
        <PlChip color="danger">Live</PlChip>
      </PlAnimateBlink>
    )
  },
  {
    name: 'PlAnimateAppear',
    group: 'transitions',
    href: 'components/transitions/animate-appear',
    blurb: {
      en: 'A list of things settling into place one after another.',
      ko: '여럿이 차례로 제자리에 내려앉습니다.'
    },
    preview: (
      <PlAnimateAppear duration={1400} className="flex flex-wrap items-center gap-2">
        {['one', 'two', 'three'].map((word) => (
          <PlChip key={word}>{word}</PlChip>
        ))}
      </PlAnimateAppear>
    )
  },
  {
    name: 'PlAnimateLighting',
    group: 'transitions',
    href: 'components/transitions/animate-lighting',
    blurb: {
      en: 'A light travelling around the outside of something.',
      ko: '무언가의 바깥을 도는 빛입니다.'
    },
    preview: (
      <PlAnimateLighting size="sm" color="primary">
        <PlChip variant="glass">Live</PlChip>
      </PlAnimateLighting>
    )
  },
  {
    name: 'PlAnimateMarquee',
    group: 'transitions',
    href: 'components/transitions/animate-marquee',
    blurb: {
      en: 'Content scrolling steadily past, forever.',
      ko: '끝없이 일정하게 흘러가는 내용입니다.'
    },
    preview: (
      <PlAnimateMarquee className="w-full" gap="1rem" speed={40}>
        {['Northwind', 'Contoso', 'Fabrikam'].map((name) => (
          <PlChip key={name} variant="glass" color="secondary">
            {name}
          </PlChip>
        ))}
      </PlAnimateMarquee>
    )
  },
  {
    name: 'PlAnimateHeadline',
    group: 'transitions',
    href: 'components/transitions/animate-headline',
    blurb: {
      en: 'One line replacing the one above it, on a timer.',
      ko: '한 줄이 위의 줄을 대신합니다, 타이머에 맞춰서.'
    },
    preview: (
      <PlAnimateHeadline interval={1800}>
        {['faster', 'simpler', 'lighter'].map((word) => (
          <PlChip key={word} color="primary">
            {word}
          </PlChip>
        ))}
      </PlAnimateHeadline>
    )
  },
  {
    name: 'PlAnimateTyping',
    group: 'transitions',
    href: 'components/transitions/animate-typing',
    blurb: {
      en: 'Text appearing one character at a time.',
      ko: '글자가 하나씩 나타납니다.'
    },
    preview: (
      <PlAnimateTyping
        className="font-mono"
        text="npm install plass-ui"
        speed={14}
        hold={1400}
        erase
        repeat="infinite"
      />
    )
  }
];

/**
 * Group headings, in the order the sidebar lists them. Written out rather than
 * derived from `entries` so a new group has to be given a name before it can
 * appear, instead of showing up as a raw folder slug.
 */
const groups: { key: Group; label: Record<'en' | 'ko', string> }[] = [
  { key: 'display', label: { en: 'Display', ko: 'Display' } },
  { key: 'feedback', label: { en: 'Feedback', ko: 'Feedback' } },
  { key: 'inputs', label: { en: 'Inputs', ko: 'Inputs' } },
  { key: 'layout', label: { en: 'Layout', ko: 'Layout' } },
  { key: 'navigation', label: { en: 'Navigation', ko: 'Navigation' } },
  { key: 'surfaces', label: { en: 'Surfaces', ko: 'Surfaces' } },
  { key: 'transitions', label: { en: 'Transitions', ko: 'Transitions' } }
];

export default function Gallery({ locale = 'en', base = '' }: GalleryProps) {
  return (
    <div className="flex flex-col gap-8">
      {groups.map((group) => (
        <div key={group.key} className="flex flex-col gap-4">
          <h3 className="text-sm font-bold tracking-wide text-(--plass-muted-fg) uppercase">
            {group.label[locale]}
          </h3>
          <div className="grid gap-4 sm:grid-cols-2">
            {entries
              .filter((entry) => entry.group === group.key)
              .map((entry) => {
                const href = `${base}/${entry.href}`;

                // The whole tile is the target, except on the card whose preview
                // is made of links — see `previewHasLinks`. That one is a plain
                // sheet with the link on its title, and it drops `interactive`
                // with the anchor: a card that lifts under the pointer and
                // cannot be pressed is a card telling the reader something
                // untrue.
                const shell = entry.previewHasLinks
                  ? { title: <PlTextLink href={href}>{entry.name}</PlTextLink> }
                  : {
                      interactive: true,
                      className: 'no-underline',
                      title: entry.name,
                      render: <a href={href} />
                    };

                return (
                  <PlCard key={entry.name} size="sm" subtitle={entry.blurb[locale]} {...shell}>
                    <div className="flex min-h-10 items-center">{entry.preview}</div>
                  </PlCard>
                );
              })}
          </div>
        </div>
      ))}
    </div>
  );
}
