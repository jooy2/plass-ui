import type { ReactNode } from 'react';
import {
  PlAccordion,
  PlAccordionItem,
  PlAlert,
  PlButton,
  PlCard,
  PlCheckbox,
  PlFilePicker,
  PlHotKeys,
  PlModal,
  PlModalClose,
  PlPagination,
  PlRadio,
  PlRadioGroup,
  PlSegment,
  PlSegmentedButton,
  PlSelect,
  PlSlider,
  PlSwitch,
  PlTab,
  PlTabPanel,
  PlTable,
  PlTabs,
  PlTextField,
  PlTextLink
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
