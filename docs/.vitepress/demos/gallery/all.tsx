import { useState, type ReactNode } from 'react';
import {
  PlAccordion,
  PlAccordionItem,
  PlAlert,
  PlAnimateFade,
  PlAspectRatio,
  PlAvatar,
  PlBadge,
  PlBlockquote,
  PlBottomNavigation,
  PlBottomNavigationItem,
  PlBox,
  PlBreadcrumb,
  PlBreadcrumbItem,
  PlButton,
  PlButtonGroup,
  PlCard,
  PlCarousel,
  PlChatBubble,
  PlCheckbox,
  PlChip,
  PlCollapsible,
  PlCombobox,
  PlContainer,
  PlDatePicker,
  PlDateRangePicker,
  PlDateTimePicker,
  PlDivider,
  PlDrawer,
  PlFilePicker,
  PlFloatingBottomNavigation,
  PlFloatingBottomNavigationItem,
  PlGrid,
  PlGridItem,
  PlHighlight,
  PlHotKeys,
  PlIcon,
  PlIconButton,
  PlList,
  PlListItem,
  PlMenu,
  PlMenuItem,
  PlMenuSeparator,
  PlModal,
  PlModalClose,
  PlNumberField,
  PlOtpField,
  PlOverlay,
  PlPane,
  PlPanes,
  PlPagination,
  PlPill,
  PlPopover,
  PlProgressBox,
  PlProgressCircular,
  PlProgressLinear,
  PlRadio,
  PlRadioGroup,
  PlRating,
  PlScrollZone,
  PlSegment,
  PlSegmentedButton,
  PlSelect,
  PlSkeleton,
  PlSlider,
  PlSpoiler,
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
  PlToolbar,
  PlTooltip,
  usePlToast,
  PlTypography
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
 * The one preview in the gallery that needs state of its own: an overlay has to
 * be opened to be seen at all. Its words stay English like every other preview
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
    name: 'PlAvatar',
    group: 'display',
    href: 'components/display/avatar',
    blurb: {
      en: 'A picture of a person or a thing that is never an empty box.',
      ko: '사람이나 사물의 사진. 절대 빈 상자가 되지 않습니다.'
    },
    preview: (
      <div className="flex items-center">
        <PlAvatar size="sm" name="Ada Lovelace" src="/portrait-1.svg" />
        <PlAvatar size="sm" name="Grace Hopper" className="-ms-2 ring-2 ring-(--plass-surface)" />
        <PlAvatar
          size="sm"
          variant="solid"
          color="info"
          name="홍길동"
          className="-ms-2 ring-2 ring-(--plass-surface)"
        />
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
