import type { ReactNode } from 'react';
import {
  PlAccordion,
  PlAccordionItem,
  PlButton,
  PlCard,
  PlCheckbox,
  PlPagination,
  PlSelect,
  PlSlider,
  PlTable,
  PlTextField
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
type Group = 'inputs' | 'display' | 'surfaces';

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
