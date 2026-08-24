import { useState, type ReactNode } from 'react';
import {
  PlAccordion,
  PlAccordionItem,
  PlAlert,
  PlAvatar,
  PlBadge,
  PlBlockquote,
  PlBreadcrumb,
  PlBreadcrumbItem,
  PlButton,
  PlCard,
  PlCheckbox,
  PlChip,
  PlDivider,
  PlFilePicker,
  PlHighlight,
  PlHotKeys,
  PlIcon,
  PlList,
  PlListItem,
  PlModal,
  PlModalClose,
  PlOverlay,
  PlPagination,
  PlRadio,
  PlRadioGroup,
  PlSegment,
  PlSegmentedButton,
  PlSelect,
  PlSkeleton,
  PlSlider,
  PlSwitch,
  PlTab,
  PlTabPanel,
  PlTable,
  PlTabs,
  PlTextField,
  PlTextLink,
  PlTimeline,
  PlTimelineItem,
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
type Group = 'display' | 'feedback' | 'inputs' | 'surfaces';

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

interface Entry {
  name: string;
  group: Group;
  href: string;
  blurb: Record<'en' | 'ko', string>;
  preview: ReactNode;
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
  { key: 'surfaces', label: { en: 'Surfaces', ko: 'Surfaces' } }
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
              .map((entry) => (
                <PlCard
                  key={entry.name}
                  interactive
                  size="sm"
                  className="no-underline"
                  title={entry.name}
                  subtitle={entry.blurb[locale]}
                  render={<a href={`${base}/${entry.href}`} />}
                >
                  <div className="flex min-h-10 items-center">{entry.preview}</div>
                </PlCard>
              ))}
          </div>
        </div>
      ))}
    </div>
  );
}
