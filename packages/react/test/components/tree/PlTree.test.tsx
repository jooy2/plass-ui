import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlTree, type PlTreeNode } from 'plass-ui';

const items: PlTreeNode[] = [
  {
    id: 'src',
    label: 'src',
    children: [
      { id: 'index', label: 'index.ts' },
      {
        id: 'components',
        label: 'components',
        children: [
          { id: 'button', label: 'PlButton.tsx' },
          { id: 'card', label: 'PlCard.tsx' }
        ]
      }
    ]
  },
  { id: 'readme', label: 'README.md' },
  { id: 'lock', label: 'package-lock.json', disabled: true }
];

const rows = () =>
  Array.from(document.querySelectorAll<HTMLElement>('[role="treeitem"]')).map((n) =>
    n.textContent?.trim()
  );

const row = (label: string) =>
  Array.from(document.querySelectorAll<HTMLElement>('[role="treeitem"]')).find(
    (n) => n.textContent?.trim() === label
  )!;

async function press(key: string): Promise<void> {
  (document.activeElement as HTMLElement | null)?.dispatchEvent(
    new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true })
  );

  await new Promise((resolve) => setTimeout(resolve, 0));
}

describe('PlTree', () => {
  describe('rendering', () => {
    it('is a tree of treeitems', async () => {
      const screen = await render(<PlTree items={items} />);

      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
      expect(rows()).toEqual(['src', 'README.md', 'package-lock.json']);
    });

    it('keeps a branch closed until it is asked', async () => {
      await render(<PlTree items={items} />);

      expect(rows()).not.toContain('index.ts');
    });

    it('opens the branches it was told start open', async () => {
      await render(<PlTree items={items} defaultExpanded={['src']} />);

      expect(rows()).toContain('index.ts');
    });

    it('says how deep each row is', async () => {
      await render(<PlTree items={items} defaultExpanded={['src']} />);

      expect(row('src').getAttribute('aria-level')).toBe('1');
      expect(row('index.ts').getAttribute('aria-level')).toBe('2');
    });

    it('marks a branch open or closed and a leaf neither', async () => {
      await render(<PlTree items={items} defaultExpanded={['src']} />);

      expect(row('src').getAttribute('aria-expanded')).toBe('true');
      expect(row('README.md').getAttribute('aria-expanded')).toBeNull();
    });

    it('groups the children of an open branch', async () => {
      await render(<PlTree items={items} defaultExpanded={['src']} />);

      expect(document.querySelector('[role="group"]')).toBeTruthy();
    });
  });

  describe('opening and closing', () => {
    it('opens a branch when it is clicked', async () => {
      const screen = await render(<PlTree items={items} />);

      await screen.getByRole('treeitem', { name: 'src' }).click();

      expect(rows()).toContain('index.ts');
    });

    it('closes it again', async () => {
      const screen = await render(<PlTree items={items} defaultExpanded={['src']} />);

      await screen.getByRole('treeitem', { name: 'src' }).click();

      expect(rows()).not.toContain('index.ts');
    });

    it('reports what is open', async () => {
      const onExpandedChange = vi.fn();

      const screen = await render(<PlTree items={items} onExpandedChange={onExpandedChange} />);

      await screen.getByRole('treeitem', { name: 'src' }).click();

      expect(onExpandedChange).toHaveBeenCalledWith(['src']);
    });

    it('turns the twisty rather than jumping it between two angles', async () => {
      const screen = await render(<PlTree items={items} />);

      const twisty = () =>
        screen.getByRole('treeitem', { name: 'src' }).element().querySelector('span')!;

      expect(twisty().className).toContain('transition:rotate');
      expect(twisty()).toHaveClass('-rotate-90');

      await screen.getByRole('treeitem', { name: 'src' }).click();

      expect(twisty()).toHaveClass('rotate-0');
    });

    it('travels the branch open rather than dropping it in', async () => {
      const screen = await render(<PlTree items={items} defaultExpanded={['src']} />);

      const group = document.querySelector<HTMLElement>('[role="group"]')!;

      expect(group.className).toContain('--collapsible-panel-height');
      expect(group.className).toContain('transition:height');
      expect(group).toHaveClass('overflow-hidden');

      // Closed, the rows are not merely hidden: Base UI takes them out of the
      // document once the fold has finished shutting, so nothing inside a shut
      // branch is in the tab order or on the accessibility tree.
      await screen.getByRole('treeitem', { name: 'src' }).click();

      expect(document.querySelector('[role="group"]')).toBeNull();
    });

    it('does not open a controlled tree on its own', async () => {
      const screen = await render(
        <PlTree items={items} expanded={[]} onExpandedChange={() => {}} />
      );

      await screen.getByRole('treeitem', { name: 'src' }).click();

      expect(rows()).not.toContain('index.ts');
    });
  });

  describe('selection', () => {
    it('lights one row at a time', async () => {
      const screen = await render(<PlTree items={items} />);

      await screen.getByRole('treeitem', { name: 'README.md' }).click();

      expect(row('README.md').getAttribute('aria-selected')).toBe('true');
      expect(row('src').getAttribute('aria-selected')).toBe('false');
    });

    it('replaces the selection rather than adding to it', async () => {
      const onSelectedChange = vi.fn();

      const screen = await render(
        <PlTree items={items} defaultSelected={['src']} onSelectedChange={onSelectedChange} />
      );

      await screen.getByRole('treeitem', { name: 'README.md' }).click();

      expect(onSelectedChange).toHaveBeenCalledWith(['readme']);
    });

    it('adds to it when there can be more than one', async () => {
      const onSelectedChange = vi.fn();

      const screen = await render(
        <PlTree
          items={items}
          selection="multiple"
          defaultSelected={['src']}
          onSelectedChange={onSelectedChange}
        />
      );

      await screen.getByRole('treeitem', { name: 'README.md' }).click();

      expect(onSelectedChange).toHaveBeenCalledWith(['src', 'readme']);
    });

    it('says the tree takes more than one', async () => {
      const screen = await render(<PlTree items={items} selection="multiple" />);

      expect(screen.getByRole('tree').element()).toHaveAttribute('aria-multiselectable', 'true');
    });

    it('lights nothing when there is no selection to make', async () => {
      const screen = await render(<PlTree items={items} selection="none" />);

      await screen.getByRole('treeitem', { name: 'README.md' }).click();

      // A browser rather than a chooser: rows still expand, and a click still
      // reports, but nothing stays lit.
      expect(row('README.md').getAttribute('aria-selected')).toBeNull();
    });

    it('reports a click either way', async () => {
      const onItemClick = vi.fn();

      const screen = await render(
        <PlTree items={items} selection="none" onItemClick={onItemClick} />
      );

      await screen.getByRole('treeitem', { name: 'README.md' }).click();

      expect(onItemClick.mock.calls[0][0].id).toBe('readme');
    });
  });

  describe('the keyboard', () => {
    it('hands Tab exactly one row', async () => {
      await render(<PlTree items={items} defaultExpanded={['src']} />);

      const stops = Array.from(
        document.querySelectorAll<HTMLElement>('[role="treeitem"][tabindex="0"]')
      );

      // A tree where Tab walked four hundred rows is one nobody reaches the end
      // of.
      expect(stops).toHaveLength(1);
    });

    it('walks down the rows that are visible', async () => {
      await render(<PlTree items={items} defaultExpanded={['src']} />);

      row('src').focus();
      await press('ArrowDown');

      expect(document.activeElement?.textContent?.trim()).toBe('index.ts');
    });

    it('walks back up', async () => {
      await render(<PlTree items={items} defaultExpanded={['src']} />);

      row('index.ts').focus();
      await press('ArrowUp');

      expect(document.activeElement?.textContent?.trim()).toBe('src');
    });

    it('opens a closed branch with the right arrow, and steps in with the next', async () => {
      await render(<PlTree items={items} />);

      row('src').focus();
      await press('ArrowRight');

      expect(rows()).toContain('index.ts');
      // Still on the branch — one press opens, the next enters.
      expect(document.activeElement?.textContent?.trim()).toBe('src');

      await press('ArrowRight');

      expect(document.activeElement?.textContent?.trim()).toBe('index.ts');
    });

    it('closes an open branch with the left arrow', async () => {
      await render(<PlTree items={items} defaultExpanded={['src']} />);

      row('src').focus();
      await press('ArrowLeft');

      expect(rows()).not.toContain('index.ts');
    });

    it('steps out to the parent from a leaf', async () => {
      await render(<PlTree items={items} defaultExpanded={['src']} />);

      row('index.ts').focus();
      await press('ArrowLeft');

      expect(document.activeElement?.textContent?.trim()).toBe('src');
    });

    it('jumps to the ends', async () => {
      await render(<PlTree items={items} defaultExpanded={['src']} />);

      row('index.ts').focus();
      await press('End');

      // The last row a reader can get to, which is not the disabled one.
      expect(document.activeElement?.textContent?.trim()).toBe('README.md');

      await press('Home');

      expect(document.activeElement?.textContent?.trim()).toBe('src');
    });

    it('selects with Enter', async () => {
      const onSelectedChange = vi.fn();

      await render(<PlTree items={items} onSelectedChange={onSelectedChange} />);

      row('README.md').focus();
      await press('Enter');

      expect(onSelectedChange).toHaveBeenCalledWith(['readme']);
    });
  });

  describe('a disabled row', () => {
    it('says so', async () => {
      await render(<PlTree items={items} />);

      expect(row('package-lock.json').getAttribute('aria-disabled')).toBe('true');
    });

    it('is not a stop for the arrow keys', async () => {
      await render(<PlTree items={items} />);

      row('README.md').focus();
      await press('ArrowDown');

      expect(document.activeElement?.textContent?.trim()).toBe('README.md');
    });

    it('does not select when it is clicked', async () => {
      const onSelectedChange = vi.fn();

      await render(<PlTree items={items} onSelectedChange={onSelectedChange} />);

      // A plain DOM click rather than the locator's: Playwright refuses to
      // click an `aria-disabled` element, which is the right refusal and is
      // also not what is being asserted — this is about the component's own
      // guard, for the click that arrives anyway.
      row('package-lock.json').click();

      expect(onSelectedChange).not.toHaveBeenCalled();
    });
  });

  describe('an empty branch', () => {
    it('is a branch rather than a leaf', async () => {
      await render(<PlTree items={[{ id: 'empty', label: 'empty', children: [] }]} />);

      // `children: []` opens and shows nothing; `undefined` has no twisty at
      // all. The two are different things.
      expect(row('empty').getAttribute('aria-expanded')).toBe('false');
    });
  });
});
