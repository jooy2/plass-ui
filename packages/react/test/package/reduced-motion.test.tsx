/**
 * That nothing the library draws eases under reduced motion.
 *
 * A test of a *contract* rather than of a component, which is why it is here
 * and not under `test/components/`. The house transition ends at once under
 * `prefers-reduced-motion`, and `test/styles/house-transition.test.tsx` says
 * so. But a popup's fade, a fold's height, a chevron's turn, a tab's
 * indicator, a switch's thumb and a close button's wash are each written by the
 * component that draws them, in a list of its own, and one that leaves out the
 * reduced-motion line still passes every other test in the suite, because no
 * other test loads the stylesheet with the preference set.
 *
 * So there are two halves. The first renders every component that writes a
 * transition of its own, in the state that puts the element on the page, with
 * `src/standalone.css` loaded, and reads the duration every element and its two
 * pseudo-elements resolve: under reduced motion every one of them is zero. The
 * two layers of the interaction light are the exception the stylesheet makes on
 * purpose, and are not read. Without the preference, each scene must ease
 * something of its own, or it has stopped reaching what it is there for.
 *
 * The second half reads every source module and fails on one that writes a
 * transition of its own and is not rendered by the first — the half that
 * catches the next component.
 */
import * as React from 'react';
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { page } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import {
  PlAccordion,
  PlAccordionItem,
  PlAlert,
  PlCalendar,
  PlCard,
  PlCarousel,
  PlChatBubble,
  PlCheckbox,
  PlChip,
  PlCollapsible,
  PlColorPicker,
  PlCombobox,
  PlCommandPalette,
  PlDataTable,
  PlDatePicker,
  PlDrawer,
  PlFilePicker,
  PlFloatingBottomNavigation,
  PlFloatingBottomNavigationItem,
  PlGallery,
  PlGaugeChart,
  PlHoverCard,
  PlLineChart,
  PlMenu,
  PlMenuItem,
  PlModal,
  PlNavigationMenu,
  PlNavigationMenuItem,
  PlNavigationMenuLink,
  PlNumberField,
  PlOverlay,
  PlPill,
  PlPopover,
  PlProgressCircular,
  PlProgressLinear,
  PlRadio,
  PlRadioGroup,
  PlScrollArea,
  PlSegment,
  PlSegmentedButton,
  PlSelect,
  PlSlider,
  PlSpoiler,
  PlSwitch,
  PlTab,
  PlTable,
  PlTabPanel,
  PlTabs,
  PlTextField,
  PlTextLink,
  PlToastProvider,
  PlTooltip,
  PlTour,
  PlTree,
  PlWindowPane,
  usePlToast
} from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

afterEach(async () => {
  // Back to the context's own default rather than to none at all: `null` hands
  // the question to the runner's system, which answers `reduce` on some CI
  // images and leaves every file after this one without motion.
  await emulateMedia({ reducedMotion: 'no-preference' });
});

/* ---------------------------------------------------------------------------
 * Reading what eases
 * ------------------------------------------------------------------------- */

/** The house transition's list, which its own test answers for. */
const HOUSE =
  'background-color, background-image, border-color, box-shadow, color, filter, opacity';

interface Easing {
  /** The element, named by its tag and its transition classes. */
  on: string;
  /** Its transition-property list, as the browser resolves it. */
  properties: string;
  /** The property that eases. */
  property: string;
  /** For how long, in seconds. */
  seconds: number;
}

/** A readable name for an element, out of the classes that write its transition. */
function describeElement(element: Element, pseudo: string | null): string {
  const classes = Array.from(element.classList).filter((one) => /transition|duration/.test(one));

  return `${element.tagName.toLowerCase()}${pseudo ?? ''} ${classes.join(' ')}`.trim();
}

/**
 * Every property that eases anywhere in the document, on an element or on its
 * `::before` or `::after`, with a duration longer than none. The duration list
 * pairs with the property list by position and repeats when it is shorter, as
 * CSS reads the two.
 */
function easings(): Easing[] {
  const found: Easing[] = [];

  for (const element of Array.from(document.body.querySelectorAll('*'))) {
    for (const pseudo of [null, '::before', '::after']) {
      // The interaction light's two layers end after 1ms under reduced motion,
      // which the stylesheet does on purpose and says why.
      if (pseudo !== null && element.classList.contains('plass-glow')) {
        continue;
      }

      const style = getComputedStyle(element, pseudo);
      const properties = style.transitionProperty.split(',').map((one) => one.trim());
      const lengths = style.transitionDuration.split(',').map((one) => parseFloat(one));

      properties.forEach((property, index) => {
        const seconds = lengths[index % lengths.length];

        if (property !== 'none' && seconds > 0) {
          found.push({
            on: describeElement(element, pseudo),
            properties: style.transitionProperty,
            property,
            seconds
          });
        }
      });
    }
  }

  return found;
}

/** The easings that are a component's own rather than the house transition's. */
const own = (all: Easing[]) => all.filter((easing) => easing.properties !== HOUSE);

/* ---------------------------------------------------------------------------
 * The scenes
 * ------------------------------------------------------------------------- */

interface Scene {
  /** The source modules whose own transitions this puts on the page. */
  modules: string[];
  render: () => React.ReactElement;
  /** Waits for what only arrives after the first render, or opens it. */
  reach?: () => Promise<void>;
}

const cities = [
  { value: 'seoul', label: 'Seoul' },
  { value: 'lisbon', label: 'Lisbon' },
  { value: 'quito', label: 'Quito' }
];

/** A one-pixel PNG, so a picture loads with no network. */
const PIXEL =
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

const visible = async (role: Parameters<typeof page.getByRole>[0], name?: string | RegExp) => {
  await expect
    .element(page.getByRole(role, name === undefined ? {} : { name }).first())
    .toBeVisible();
};

/** Raises one toast that stays up, once. */
function RaiseToast() {
  const toast = usePlToast();
  const raised = React.useRef(false);

  React.useEffect(() => {
    if (!raised.current) {
      raised.current = true;
      toast.add({ title: 'Saved', timeout: 0 });
    }
  }, [toast]);

  return null;
}

const scenes: Record<string, Scene> = {
  PlAccordion: {
    modules: ['src/components/accordion/PlAccordion.tsx'],
    render: () => (
      <PlAccordion defaultValue={['shipping']}>
        <PlAccordionItem value="shipping" title="Shipping">
          Three to five working days.
        </PlAccordionItem>
      </PlAccordion>
    )
  },
  PlAlert: {
    modules: ['src/components/alert/PlAlert.tsx'],
    render: () => (
      <PlAlert title="Storage is nearly full" onClose={() => undefined}>
        92% of your quota is in use.
      </PlAlert>
    )
  },
  PlCalendar: {
    modules: ['src/internal/calendar.tsx'],
    render: () => <PlCalendar />
  },
  PlCard: {
    modules: ['src/components/card/PlCard.tsx'],
    render: () => <PlCard interactive>A card that answers the pointer.</PlCard>
  },
  PlCarousel: {
    modules: ['src/components/carousel/PlCarousel.tsx'],
    render: () => (
      <PlCarousel label="Places">
        <div>One</div>
        <div>Two</div>
        <div>Three</div>
      </PlCarousel>
    )
  },
  PlChatBubble: {
    modules: ['src/components/chat-bubble/PlChatBubble.tsx'],
    render: () => (
      <PlChatBubble
        name="Ada Lovelace"
        actions={<button type="button">More</button>}
        preview={{ url: '#preview', title: 'Design language' }}
      >
        Here is the page about it.
      </PlChatBubble>
    )
  },
  PlCheckbox: {
    modules: ['src/components/checkbox/PlCheckbox.tsx'],
    render: () => <PlCheckbox label="Remember me" defaultChecked />
  },
  PlChip: {
    modules: ['src/internal/styles.ts'],
    render: () => <PlChip onDelete={() => undefined}>design</PlChip>
  },
  PlCollapsible: {
    modules: ['src/components/collapsible/PlCollapsible.tsx'],
    render: () => (
      <PlCollapsible title="Advanced" defaultOpen>
        Nine settings.
      </PlCollapsible>
    )
  },
  PlColorPicker: {
    modules: ['src/components/color-picker/PlColorPicker.tsx', 'src/internal/picker.tsx'],
    render: () => <PlColorPicker label="Colour" defaultValue="#1a58d1" defaultOpen />,
    reach: () => visible('dialog')
  },
  PlCombobox: {
    modules: ['src/components/combobox/PlCombobox.tsx'],
    render: () => <PlCombobox label="City" items={cities} defaultOpen />,
    reach: () => visible('listbox')
  },
  PlCommandPalette: {
    modules: ['src/components/command-palette/PlCommandPalette.tsx'],
    render: () => <PlCommandPalette items={cities} shortcut={false} defaultOpen />,
    reach: () => visible('dialog')
  },
  PlDataTable: {
    modules: ['src/components/data-table/PlDataTable.tsx', 'src/internal/table.ts'],
    render: () => (
      <PlDataTable
        columns={[{ key: 'name', header: 'Name', sortable: true }]}
        rows={[{ name: 'Ada' }, { name: 'Grace' }]}
      />
    )
  },
  PlDatePicker: {
    modules: ['src/internal/picker.tsx', 'src/internal/calendar.tsx'],
    render: () => <PlDatePicker label="Departure" defaultOpen />,
    reach: () => visible('dialog')
  },
  PlDrawer: {
    modules: ['src/components/drawer/PlDrawer.tsx'],
    render: () => (
      <PlDrawer title="Filters" defaultOpen>
        Everything you can narrow by.
      </PlDrawer>
    ),
    reach: () => visible('dialog')
  },
  PlFilePicker: {
    modules: ['src/components/file-picker/PlFilePicker.tsx'],
    render: () => (
      <PlFilePicker
        label="Attachments"
        multiple
        value={[new File(['notes'], 'notes.txt', { type: 'text/plain' })]}
      />
    )
  },
  PlFloatingBottomNavigation: {
    modules: ['src/components/floating-bottom-navigation/PlFloatingBottomNavigation.tsx'],
    render: () => (
      <PlFloatingBottomNavigation
        position="static"
        safeArea={false}
        defaultValue="home"
        label="Main"
      >
        <PlFloatingBottomNavigationItem value="home" icon={<span>H</span>}>
          Home
        </PlFloatingBottomNavigationItem>
        <PlFloatingBottomNavigationItem value="saved" icon={<span>S</span>}>
          Saved
        </PlFloatingBottomNavigationItem>
      </PlFloatingBottomNavigation>
    )
  },
  PlGallery: {
    modules: ['src/components/gallery/PlGallery.tsx', 'src/components/image/PlImage.tsx'],
    render: () => (
      <PlGallery
        items={[
          { src: PIXEL, alt: 'A dot', title: 'One', ratio: 1 },
          { src: PIXEL, alt: 'Another dot', title: 'Two', ratio: 1 }
        ]}
        caption="hover"
        hover="zoom"
      />
    )
  },
  PlGaugeChart: {
    modules: ['src/components/gauge-chart/PlGaugeChart.tsx'],
    render: () => <PlGaugeChart label="Storage used" value={1.4} min={0} max={2} />
  },
  PlHoverCard: {
    modules: ['src/components/hover-card/PlHoverCard.tsx'],
    render: () => (
      <PlHoverCard trigger={<PlTextLink href="#ada">Ada</PlTextLink>} title="Ada Lovelace" open>
        Mathematician
      </PlHoverCard>
    ),
    reach: async () => {
      await expect.element(page.getByText('Mathematician')).toBeVisible();
    }
  },
  PlLineChart: {
    modules: ['src/internal/chart-frame.tsx'],
    render: () => (
      <PlLineChart
        label="Sessions"
        categories={['Jan', 'Feb']}
        series={[
          { name: 'Web', data: [1, 2] },
          { name: 'Mobile', data: [2, 3] },
          { name: 'Desktop', data: [3, 4] }
        ]}
        legend={{ maxEntries: 2 }}
      />
    )
  },
  PlMenu: {
    modules: ['src/components/menu/PlMenu.tsx'],
    render: () => (
      <PlMenu open>
        <PlMenuItem>Cut</PlMenuItem>
      </PlMenu>
    ),
    reach: () => visible('menu')
  },
  PlModal: {
    modules: ['src/components/modal/PlModal.tsx'],
    render: () => (
      <PlModal title="Delete project" defaultOpen>
        Are you sure?
      </PlModal>
    ),
    reach: () => visible('dialog')
  },
  PlNavigationMenu: {
    modules: ['src/components/navigation-menu/PlNavigationMenu.tsx'],
    render: () => (
      <PlNavigationMenu>
        <PlNavigationMenuItem label="Product">
          <PlNavigationMenuLink href="#analytics" title="Analytics" />
        </PlNavigationMenuItem>
      </PlNavigationMenu>
    ),
    reach: async () => {
      await page.getByRole('button', { name: 'Product' }).click();
      await expect.element(page.getByRole('link', { name: 'Analytics' })).toBeVisible();
    }
  },
  PlNumberField: {
    modules: ['src/components/number-field/PlNumberField.tsx'],
    render: () => <PlNumberField label="Guests" defaultValue={2} />
  },
  PlOverlay: {
    modules: ['src/components/overlay/PlOverlay.tsx'],
    render: () => (
      <PlOverlay open modal="trap-focus">
        Saving
      </PlOverlay>
    ),
    reach: async () => {
      await expect.element(page.getByText('Saving')).toBeVisible();
    }
  },
  PlPill: {
    modules: ['src/components/pill/PlPill.tsx'],
    render: () => <PlPill title="Recording" details="Forty-one seconds so far." />
  },
  PlPopover: {
    modules: ['src/components/popover/PlPopover.tsx'],
    render: () => (
      <PlPopover title="Rates" showClose defaultOpen>
        How the number is worked out.
      </PlPopover>
    ),
    reach: () => visible('dialog')
  },
  PlProgressCircular: {
    modules: ['src/components/progress-circular/PlProgressCircular.tsx'],
    render: () => <PlProgressCircular value={40} />
  },
  PlProgressLinear: {
    modules: ['src/internal/progress.ts'],
    render: () => <PlProgressLinear value={40} />
  },
  PlRadioGroup: {
    modules: ['src/components/radio-group/PlRadioGroup.tsx'],
    render: () => (
      <PlRadioGroup label="Plan" defaultValue="team">
        <PlRadio value="starter" label="Starter" />
        <PlRadio value="team" label="Team" />
      </PlRadioGroup>
    )
  },
  PlScrollArea: {
    modules: ['src/components/scroll-area/PlScrollArea.tsx'],
    render: () => (
      <PlScrollArea height={80}>
        <div style={{ height: 400 }}>Tall</div>
      </PlScrollArea>
    )
  },
  PlSegmentedButton: {
    modules: ['src/components/segmented-button/PlSegmentedButton.tsx'],
    render: () => (
      <PlSegmentedButton aria-label="Period" defaultValue="week">
        <PlSegment value="day">Day</PlSegment>
        <PlSegment value="week">Week</PlSegment>
      </PlSegmentedButton>
    )
  },
  PlSelect: {
    modules: ['src/components/select/PlSelect.tsx'],
    render: () => <PlSelect label="City" items={cities} />,
    reach: async () => {
      await page.getByRole('combobox').click();
      await visible('listbox');
    }
  },
  PlSlider: {
    modules: ['src/components/slider/PlSlider.tsx'],
    render: () => <PlSlider aria-label="Volume" defaultValue={40} />
  },
  PlSpoiler: {
    modules: ['src/components/spoiler/PlSpoiler.tsx'],
    render: () => <PlSpoiler>He was the killer all along.</PlSpoiler>
  },
  PlSwitch: {
    modules: ['src/components/switch/PlSwitch.tsx'],
    render: () => <PlSwitch label="Wi-Fi" />
  },
  PlTable: {
    modules: ['src/internal/table.ts'],
    render: () => (
      <PlTable
        columns={[{ key: 'name', header: 'Name' }]}
        rows={[{ name: 'Ada' }, { name: 'Grace' }]}
        hoverable
      />
    )
  },
  PlTabs: {
    modules: ['src/components/tabs/PlTabs.tsx'],
    render: () => (
      <PlTabs defaultValue="account">
        <PlTab value="account">Account</PlTab>
        <PlTab value="billing">Billing</PlTab>
        <PlTabPanel value="account">Your name.</PlTabPanel>
        <PlTabPanel value="billing">Your cards.</PlTabPanel>
      </PlTabs>
    )
  },
  PlTextField: {
    modules: ['src/components/text-field/PlTextField.tsx'],
    render: () => <PlTextField label="Search" startIcon={<span>S</span>} />
  },
  PlTextLink: {
    modules: ['src/components/text-link/PlTextLink.tsx'],
    render: () => <PlTextLink href="#somewhere">Somewhere</PlTextLink>
  },
  PlToast: {
    modules: ['src/components/toast/PlToast.tsx'],
    render: () => (
      <PlToastProvider>
        <RaiseToast />
      </PlToastProvider>
    ),
    reach: async () => {
      await expect.element(page.getByText('Saved')).toBeVisible();
    }
  },
  PlTooltip: {
    modules: ['src/components/tooltip/PlTooltip.tsx'],
    render: () => (
      <PlTooltip open content="Copy to clipboard">
        <button type="button">Copy</button>
      </PlTooltip>
    ),
    reach: () => visible('tooltip')
  },
  PlTour: {
    modules: ['src/components/tour/PlTour.tsx'],
    render: () => (
      <div>
        <button type="button" id="tour-target">
          Filter
        </button>
        <PlTour
          scrollIntoView={false}
          defaultOpen
          steps={[{ target: '#tour-target', title: 'Narrow the list' }]}
        />
      </div>
    ),
    reach: async () => {
      await expect.element(page.getByText('Narrow the list')).toBeVisible();
    }
  },
  PlTree: {
    modules: ['src/components/tree/PlTree.tsx'],
    render: () => (
      <PlTree
        items={[{ id: 'src', label: 'src', children: [{ id: 'index', label: 'index.ts' }] }]}
        defaultExpanded={['src']}
      />
    )
  },
  PlWindowPane: {
    modules: ['src/components/window-pane/PlWindowPane.tsx', 'src/internal/window.tsx'],
    render: () => (
      <PlWindowPane os="macos" title="Notes" width={320} height={200}>
        A window.
      </PlWindowPane>
    )
  }
};

/* ---------------------------------------------------------------------------
 * The half that reads what is drawn
 * ------------------------------------------------------------------------- */

async function show(scene: Scene) {
  await render(scene.render());
  await scene.reach?.();
}

describe('under reduced motion', () => {
  it.each(Object.entries(scenes))('%s eases nothing', async (_, scene) => {
    await emulateMedia({ reducedMotion: 'reduce' });
    await show(scene);

    expect(easings()).toEqual([]);
  });
});

describe('without the preference', () => {
  it.each(Object.entries(scenes))('%s eases something of its own', async (_, scene) => {
    await show(scene);

    expect(own(easings()).length).toBeGreaterThan(0);
  });
});

/* ---------------------------------------------------------------------------
 * The half that catches the next component
 * ------------------------------------------------------------------------- */

const sources = import.meta.glob('../../src/{components/*,internal}/*.{ts,tsx}', {
  query: '?raw',
  import: 'default',
  eager: true
});

const name = (path: string) => path.replace(/^.*\/src\//, 'src/');

/** Comments out, since the prose round a transition names one. */
const code = (source: string) =>
  source.replace(/\/\*[\s\S]*?\*\//g, '').replace(/(^|[^:])\/\/.*$/gm, '$1');

/**
 * A transition a module writes for itself: the Tailwind shorthand or a
 * duration read from a token, as an arbitrary property or as a utility, or an
 * inline `transition` in a style object. The house transition is a list in
 * `internal/styles.ts`, which is read here too, and is rendered through a chip.
 */
const WRITES =
  /\[transition:|\[transition-duration:var\(|\btransition-\[|\bduration-\(|\btransition:\s*['"`]/;

const rendered = new Set(Object.values(scenes).flatMap((scene) => scene.modules));

describe('every module that writes a transition of its own is rendered above', () => {
  const writers = Object.entries(sources)
    .filter(([, source]) => WRITES.test(code(source)))
    .map(([path]) => name(path));

  it('finds the ones it knows about', () => {
    // A pattern that stopped matching would pass the next test by finding
    // nothing at all.
    expect(writers).toContain('src/components/switch/PlSwitch.tsx');
    expect(writers).toContain('src/components/gauge-chart/PlGaugeChart.tsx');
  });

  it.each(writers)('%s', (file) => {
    expect({ file, rendered: rendered.has(file) }).toEqual({ file, rendered: true });
  });

  it.each([...rendered])('%s is a source module', (file) => {
    expect(Object.keys(sources).map(name)).toContain(file);
  });
});
