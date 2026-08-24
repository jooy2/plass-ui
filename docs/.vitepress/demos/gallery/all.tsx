import type { ReactNode } from 'react';
import { PlAccordion, PlAccordionItem, PlButton, PlTextField } from 'plass-ui';

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
type Group = 'inputs' | 'surfaces';

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
                <a
                  key={entry.name}
                  href={`${base}/${entry.href}`}
                  className="flex flex-col gap-3 rounded-2xl border p-5 no-underline transition-[box-shadow,border-color] duration-(--plass-duration) [backdrop-filter:var(--plass-blur)] [-webkit-backdrop-filter:var(--plass-blur)]"
                  style={{
                    background: 'var(--plass-glass)',
                    borderColor: 'var(--plass-glass-line)',
                    boxShadow: 'var(--plass-shadow-1), var(--plass-gloss-glass)'
                  }}
                >
                  <div>
                    <p className="text-sm font-bold text-(--plass-fg)">{entry.name}</p>
                    <p className="mt-1 text-xs text-(--plass-muted-fg)">{entry.blurb[locale]}</p>
                  </div>
                  <div className="flex min-h-10 items-center">{entry.preview}</div>
                </a>
              ))}
          </div>
        </div>
      ))}
    </div>
  );
}
