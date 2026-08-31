/**
 * That a `PlassProvider` is exactly the same as writing the prop.
 *
 * A test of a *contract* rather than of a component, which is why it is here
 * rather than under `test/components/`. It deliberately asserts no design value
 * — no class, no radius, no height — because those move with the design
 * language and a test that pinned them would turn every deliberate change into
 * a failure. What it compares is **one component against itself**: the markup a
 * `size="xs"` prop produces, against the markup the same component produces
 * under a provider that said `xs`. If those two ever differ, one of the paths
 * has stopped working, whatever the classes happen to be that week.
 *
 * The second half is the one that catches the next component rather than this
 * week's: it reads every component's source and fails if it takes a `size`,
 * `color` or `density` without reading the defaults.
 */
import type * as React from 'react';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlAlert,
  PlAvatar,
  PlBadge,
  PlButton,
  PlCalendar,
  PlCard,
  PlCheckbox,
  PlChip,
  PlPagination,
  PlassProvider,
  PlSelect,
  PlSlider,
  PlSwitch,
  PlTextField,
  PlToggle,
  type PlassSize
} from 'plass-ui';

const items = [
  { value: 'seoul', label: 'Seoul' },
  { value: 'busan', label: 'Busan' }
];

/**
 * One rendering per component, taking whichever style props it is being asked
 * about. Every one is uncontrolled and static: what is compared is markup, so
 * anything that animates or measures would compare against itself unfairly.
 */
const cases: Array<[string, (props: { size?: PlassSize }) => React.ReactElement]> = [
  ['PlButton', (props) => <PlButton {...props}>Save</PlButton>],
  ['PlTextField', (props) => <PlTextField {...props} label="Email" description="Work address" />],
  ['PlCheckbox', (props) => <PlCheckbox {...props} label="Remember me" />],
  ['PlSwitch', (props) => <PlSwitch {...props} label="Notify" />],
  ['PlChip', (props) => <PlChip {...props}>Draft</PlChip>],
  [
    'PlAlert',
    (props) => (
      <PlAlert {...props} title="Saved">
        Your changes are live.
      </PlAlert>
    )
  ],
  [
    'PlBadge',
    (props) => (
      <PlBadge {...props} content={3}>
        <span>Inbox</span>
      </PlBadge>
    )
  ],
  [
    'PlCard',
    (props) => (
      <PlCard {...props} title="Plan">
        Ten seats.
      </PlCard>
    )
  ],
  ['PlAvatar', (props) => <PlAvatar {...props} name="Ada Lovelace" />],
  ['PlToggle', (props) => <PlToggle {...props}>Bold</PlToggle>],
  ['PlSelect', (props) => <PlSelect {...props} items={items} label="City" />],
  ['PlSlider', (props) => <PlSlider {...props} defaultValue={40} label="Volume" />],
  ['PlPagination', (props) => <PlPagination {...props} count={9} defaultPage={3} />],
  [
    'PlCalendar',
    (props) => <PlCalendar {...props} locale="en-GB" defaultMonth={new Date(2026, 6, 1)} />
  ]
];

/**
 * The generated ids, and only those. React's counter and Base UI's both move
 * between two renders of the same tree, and they are the only thing that
 * legitimately differs — everything else is the failure this is looking for.
 *
 * The patterns are anchored rather than general, because a loose one eats real
 * markup: `[transition:rotate_var(…)]` is a class name that looks exactly like
 * a delimited id if the delimiters are not spelled out.
 */
const stable = (html: string) =>
  html
    .replace(/base-ui-_r_[0-9a-z]+_/g, 'ID')
    .replace(/«r[0-9a-z]+»/g, 'ID')
    .replace(/:r[0-9a-z]+:/g, 'ID')
    .replace(/\b_r_[0-9a-z]+_/g, 'ID');

async function markup(element: React.ReactElement): Promise<string> {
  const screen = await render(element);
  const html = stable(screen.container.innerHTML);

  await screen.unmount();

  return html;
}

describe('PlassProvider', () => {
  describe('is the same as writing the prop', () => {
    it.each(cases)('%s', async (_name, node) => {
      const written = await markup(node({ size: 'xs' }));
      const provided = await markup(<PlassProvider size="xs">{node({})}</PlassProvider>);

      expect(provided).toBe(written);
    });
  });

  describe('precedence', () => {
    it.each(cases)("%s's own prop wins over the provider", async (_name, node) => {
      const written = await markup(node({ size: 'xl' }));
      const provided = await markup(
        <PlassProvider size="xs">{node({ size: 'xl' })}</PlassProvider>
      );

      expect(provided).toBe(written);
    });

    it('a nested provider wins over the one around it', async () => {
      const written = await markup(<PlButton size="xl">Save</PlButton>);
      const provided = await markup(
        <PlassProvider size="xs">
          <PlassProvider size="xl">
            <PlButton>Save</PlButton>
          </PlassProvider>
        </PlassProvider>
      );

      expect(provided).toBe(written);
    });

    it('a nested provider keeps what it did not say', async () => {
      const written = await markup(<PlButton size="xl" color="danger" />);
      const provided = await markup(
        <PlassProvider size="xs" color="danger">
          <PlassProvider size="xl">
            <PlButton />
          </PlassProvider>
        </PlassProvider>
      );

      expect(provided).toBe(written);
    });
  });

  describe('the date vocabulary', () => {
    it('sets the locale a calendar formats in', async () => {
      const written = await markup(
        <PlCalendar locale="ko-KR" defaultMonth={new Date(2026, 6, 1)} />
      );
      const provided = await markup(
        <PlassProvider locale="ko-KR">
          <PlCalendar defaultMonth={new Date(2026, 6, 1)} />
        </PlassProvider>
      );

      expect(provided).toBe(written);
    });

    it('sets the day the week starts on', async () => {
      const written = await markup(
        <PlCalendar locale="en-GB" weekStartsOn={0} defaultMonth={new Date(2026, 6, 1)} />
      );
      const provided = await markup(
        <PlassProvider weekStartsOn={0}>
          <PlCalendar locale="en-GB" defaultMonth={new Date(2026, 6, 1)} />
        </PlassProvider>
      );

      expect(provided).toBe(written);
    });

    it('sets the labels Intl has no opinion about', async () => {
      const screen = await render(
        <PlassProvider labels={{ nextMonth: '다음 달' }}>
          <PlCalendar locale="ko-KR" defaultMonth={new Date(2026, 6, 1)} />
        </PlassProvider>
      );

      await expect.element(screen.getByRole('button', { name: '다음 달' })).toBeInTheDocument();
    });

    it("a component's own labels win over the provider's", async () => {
      const screen = await render(
        <PlassProvider labels={{ nextMonth: '다음 달' }}>
          <PlCalendar
            locale="ko-KR"
            defaultMonth={new Date(2026, 6, 1)}
            labels={{ nextMonth: '한 달 뒤' }}
          />
        </PlassProvider>
      );

      await expect.element(screen.getByRole('button', { name: '한 달 뒤' })).toBeInTheDocument();
    });
  });
});

/* ---------------------------------------------------------------------------
 * The half that catches the next component rather than this week's
 * ------------------------------------------------------------------------- */

const sources = import.meta.glob('../../src/components/*/Pl*.tsx', {
  query: '?raw',
  import: 'default',
  eager: true
});

const name = (path: string) => path.replace(/^.*\/src\//, 'src/');

/**
 * The components that take a style axis and deliberately do not read the
 * provider, with what each one buys by it.
 *
 * `PlTable` is the whole list and is likely to stay it. Reading a React context
 * requires a client component, and `PlTable` is kept out of the client graph on
 * purpose — every one of its columns is a `render` callback, and a server
 * component cannot hand a function across that boundary. The same trade
 * `test/package/use-client.test.ts` records.
 */
const exempt: Record<string, string> = {
  'src/components/table/PlTable.tsx':
    'stays server-renderable, and reading a context would make it a client component'
};

const AXES = ['size', 'color', 'density'] as const;

describe('every component reads the defaults', () => {
  it.each(Object.entries(sources))('%s', (path, source) => {
    const file = name(path);
    const text = source as string;

    for (const axis of AXES) {
      // A literal default left in the destructuring is an axis the provider can
      // never reach: the component resolved it before anybody could say
      // otherwise. A component that does not take the axis at all has neither,
      // and is fine.
      const decidedTooEarly = new RegExp(`^\\s*${axis} = '`, 'm').test(text) && !(file in exempt);

      expect({ file, axis, decidedTooEarly }).toEqual({ file, axis, decidedTooEarly: false });
    }
  });

  it.each(Object.entries(exempt))('%s is exempt on purpose', (file, why) => {
    const entry = Object.entries(sources).find(([path]) => name(path) === file);

    expect(entry, `${file} is listed as exempt and is not a component module`).toBeDefined();
    expect({ file, why, reads: (entry![1] as string).includes('useDefaults') }).toEqual({
      file,
      why,
      reads: false
    });
  });
});
