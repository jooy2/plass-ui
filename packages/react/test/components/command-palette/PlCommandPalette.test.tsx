import { describe, expect, it, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlCommandPalette, PlassProvider, type PlCommandItem } from 'plass-ui';

const items: PlCommandItem[] = [
  { value: 'new', label: 'New document', group: 'File', shortcut: 'Mod+N' },
  { value: 'open', label: 'Open…', group: 'File', keywords: ['load'] },
  { value: 'copy', label: 'Copy', group: 'Edit', description: 'Put it on the clipboard' },
  { value: 'cafe', label: 'Café settings', group: 'Edit' },
  { value: 'gone', label: 'Unavailable', group: 'Edit', disabled: true }
];

describe('PlCommandPalette', () => {
  describe('the sheet', () => {
    it('is not in the document until it is opened', async () => {
      const screen = await render(<PlCommandPalette items={items} shortcut={false} />);

      expect(screen.getByRole('dialog').query()).toBeNull();
    });

    it('is a named dialog with a field in it', async () => {
      const screen = await render(<PlCommandPalette items={items} shortcut={false} defaultOpen />);

      await expect.element(screen.getByRole('dialog', { name: 'Command palette' })).toBeVisible();
      await expect.element(screen.getByRole('combobox')).toBeVisible();
    });

    it('takes a name and a placeholder of its own', async () => {
      const screen = await render(
        <PlCommandPalette
          items={items}
          shortcut={false}
          defaultOpen
          label="Actions"
          placeholder="What do you want to do?"
        />
      );

      await expect.element(screen.getByRole('dialog', { name: 'Actions' })).toBeVisible();
      await expect
        .element(screen.getByRole('combobox'))
        .toHaveAttribute('placeholder', 'What do you want to do?');
    });

    it('answers with what a controlled palette is given', async () => {
      const onOpenChange = vi.fn();

      const screen = await render(
        <PlCommandPalette
          open={false}
          onOpenChange={onOpenChange}
          items={[{ value: 'copy', label: 'Copy' }]}
        />
      );

      expect(screen.getByRole('dialog').query()).toBeNull();

      window.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'k', ctrlKey: true, bubbles: true })
      );
      window.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'k', metaKey: true, bubbles: true })
      );

      // The palette asked; the caller has not said yes.
      expect(onOpenChange).toHaveBeenCalledWith(true);
      expect(screen.getByRole('dialog').query()).toBeNull();
    });
  });

  describe('the list', () => {
    it('draws every command, in the order it was given', async () => {
      const screen = await render(<PlCommandPalette items={items} shortcut={false} defaultOpen />);

      const rows = screen.getByRole('option').elements();

      // The shortcut's cap carries its real name in a clipped box beside the
      // glyph, so a row's text is compared by what it starts with.
      expect(rows).toHaveLength(5);
      expect(rows[0].textContent).toMatch(/^New document/);
      expect(rows[1].textContent).toBe('Open…');
      expect(rows[2].textContent).toMatch(/^Copy/);
      expect(rows[3].textContent).toBe('Café settings');
      expect(rows[4].textContent).toBe('Unavailable');
    });

    it('draws a heading each time the group changes', async () => {
      const screen = await render(<PlCommandPalette items={items} shortcut={false} defaultOpen />);

      // Two groups, five commands: `File` once and `Edit` once.
      await expect.element(screen.getByText('File')).toBeVisible();
      expect(screen.getByText('Edit').elements()).toHaveLength(1);
    });

    it('draws a description and a shortcut when there is one', async () => {
      const screen = await render(<PlCommandPalette items={items} shortcut={false} defaultOpen />);

      await expect.element(screen.getByText('Put it on the clipboard')).toBeVisible();

      // `Mod` is a different cap on every platform — `⌘` on a Mac and `Ctrl`
      // everywhere else — so what is asserted on is the letter beside it, which
      // is the same wherever the suite runs.
      await expect
        .element(screen.getByRole('option').first().getByText('N', { exact: true }))
        .toBeVisible();
    });
  });

  describe('searching', () => {
    it('narrows the list to what was typed', async () => {
      const screen = await render(<PlCommandPalette items={items} shortcut={false} defaultOpen />);

      await screen.getByRole('combobox').fill('copy');

      await expect.poll(() => screen.getByRole('option').elements().length).toBe(1);
    });

    it('matches keywords that are never drawn', async () => {
      const screen = await render(<PlCommandPalette items={items} shortcut={false} defaultOpen />);

      await screen.getByRole('combobox').fill('load');

      await expect.poll(() => screen.getByRole('option').elements().length).toBe(1);
      await expect.element(screen.getByRole('option')).toHaveTextContent('Open…');
    });

    it('folds accents and case, so cafe finds Café', async () => {
      const screen = await render(<PlCommandPalette items={items} shortcut={false} defaultOpen />);

      await screen.getByRole('combobox').fill('CAFE');

      await expect.poll(() => screen.getByRole('option').elements().length).toBe(1);
    });

    describe('a large set', () => {
      /** `count` commands, every one of which matches `Command`. */
      const many = (count: number): PlCommandItem[] =>
        Array.from({ length: count }, (_, index) => ({
          value: `command-${index}`,
          label: `Command ${index + 1}`
        }));

      it('draws the first hundred matches and says how many more there are', async () => {
        const screen = await render(
          <PlCommandPalette items={many(250)} shortcut={false} defaultOpen />
        );

        await expect.element(screen.getByText('150 more')).toBeVisible();

        const rows = screen.getByRole('option').elements();

        expect(rows).toHaveLength(100);
        expect(rows[0].textContent).toBe('Command 1');
        expect(rows[99].textContent).toBe('Command 100');
      });

      it('finds a command past the hundredth once the query narrows to it', async () => {
        const screen = await render(
          <PlCommandPalette items={many(250)} shortcut={false} defaultOpen />
        );

        await screen.getByRole('combobox').fill('command 249');

        await expect.poll(() => screen.getByRole('option').elements().length).toBe(1);
        expect(screen.getByText(/ more$/).query()).toBeNull();
      });

      it('says nothing at exactly a hundred', async () => {
        const screen = await render(
          <PlCommandPalette items={many(100)} shortcut={false} defaultOpen />
        );

        await expect.poll(() => screen.getByRole('option').elements().length).toBe(100);
        expect(screen.getByText(/ more$/).query()).toBeNull();
      });

      it('says it in the words of the label pack', async () => {
        const screen = await render(
          <PlassProvider labels={{ chartMore: (count) => `${count}개 더` }}>
            <PlCommandPalette items={many(101)} shortcut={false} defaultOpen />
          </PlassProvider>
        );

        await expect.element(screen.getByText('1개 더')).toBeVisible();
      });
    });

    it('says so when nothing matched', async () => {
      const screen = await render(
        <PlCommandPalette
          items={items}
          shortcut={false}
          defaultOpen
          emptyMessage="Nothing like that"
        />
      );

      await screen.getByRole('combobox').fill('zzzzz');

      await expect.element(screen.getByText('Nothing like that')).toBeVisible();
    });
  });

  describe('running a command', () => {
    it('calls the command s own handler and then the palette s', async () => {
      const onSelect = vi.fn();
      const own = vi.fn();

      const screen = await render(
        <PlCommandPalette
          shortcut={false}
          defaultOpen
          onSelect={onSelect}
          items={[{ value: 'copy', label: 'Copy', onSelect: own }]}
        />
      );

      (screen.getByRole('option', { name: 'Copy' }).element() as HTMLElement).click();

      expect(own).toHaveBeenCalled();
      expect(onSelect).toHaveBeenCalledWith(expect.objectContaining({ value: 'copy' }));
    });

    it('closes afterwards', async () => {
      const onOpenChange = vi.fn();

      const screen = await render(
        <PlCommandPalette
          shortcut={false}
          defaultOpen
          onOpenChange={onOpenChange}
          items={[{ value: 'copy', label: 'Copy' }]}
        />
      );

      (screen.getByRole('option', { name: 'Copy' }).element() as HTMLElement).click();

      expect(onOpenChange).toHaveBeenLastCalledWith(false);
    });

    it('runs the command the arrow keys lit, on Enter, and closes', async () => {
      const onSelect = vi.fn();

      const screen = await render(
        <PlCommandPalette
          shortcut={false}
          defaultOpen
          onSelect={onSelect}
          items={[
            { value: 'copy', label: 'Copy' },
            { value: 'paste', label: 'Paste' }
          ]}
        />
      );

      // Focused through the DOM: nothing loads Tailwind into the test run, so the
      // field has no box for Playwright to click. The keys are real ones.
      (screen.getByRole('combobox').element() as HTMLElement).focus();
      await userEvent.keyboard('{ArrowDown}');

      // Whichever row the key lit is the one Enter has to run.
      await expect
        .poll(() => document.querySelector('[role="option"][data-highlighted]'))
        .not.toBeNull();
      const lit = document.querySelector('[role="option"][data-highlighted]')?.textContent;

      await userEvent.keyboard('{Enter}');

      expect(onSelect).toHaveBeenCalledTimes(1);
      expect(onSelect).toHaveBeenCalledWith(expect.objectContaining({ label: lit }));
      await expect.poll(() => screen.getByRole('dialog').query()).toBeNull();
    });

    it('opens again with an empty field, whatever closed it', async () => {
      const screen = await render(
        <PlCommandPalette items={items} shortcut={false} open onOpenChange={() => undefined} />
      );

      await screen.getByRole('combobox').fill('copy');
      await expect.poll(() => screen.getByRole('option').elements().length).toBe(1);

      // Closed by the parent, which Base UI does not report as a close of its
      // own, and opened again.
      await screen.rerender(
        <PlCommandPalette
          items={items}
          shortcut={false}
          open={false}
          onOpenChange={() => undefined}
        />
      );
      await expect.poll(() => screen.getByRole('dialog').query()).toBeNull();

      await screen.rerender(
        <PlCommandPalette items={items} shortcut={false} open onOpenChange={() => undefined} />
      );

      await expect.element(screen.getByRole('combobox')).toHaveValue('');
      await expect.poll(() => screen.getByRole('option').elements().length).toBe(items.length);
    });

    it('runs nothing for a disabled command', async () => {
      const own = vi.fn();

      const screen = await render(
        <PlCommandPalette
          shortcut={false}
          defaultOpen
          items={[{ value: 'gone', label: 'Unavailable', disabled: true, onSelect: own }]}
        />
      );

      (screen.getByRole('option', { name: 'Unavailable' }).element() as HTMLElement).click();

      expect(own).not.toHaveBeenCalled();
    });
  });

  describe('the shortcut', () => {
    it('opens on the keystroke it was given', async () => {
      const onOpenChange = vi.fn();

      await render(<PlCommandPalette items={items} onOpenChange={onOpenChange} />);

      window.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'k', ctrlKey: true, metaKey: false, bubbles: true })
      );
      window.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'k', metaKey: true, bubbles: true })
      );

      expect(onOpenChange).toHaveBeenCalledWith(true);
    });

    it('binds nothing when it is told not to', async () => {
      const onOpenChange = vi.fn();

      await render(<PlCommandPalette items={items} shortcut={false} onOpenChange={onOpenChange} />);

      window.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'k', ctrlKey: true, bubbles: true })
      );
      window.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'k', metaKey: true, bubbles: true })
      );

      expect(onOpenChange).not.toHaveBeenCalled();
    });
  });
  describe('caller styling', () => {
    it('keeps caller-supplied class names on the sheet alongside its own', async () => {
      const screen = await render(
        <PlCommandPalette items={items} shortcut={false} defaultOpen className="my-own-class" />
      );

      const sheet = screen.getByRole('dialog').element();

      expect(sheet).toHaveClass('my-own-class');
      // Still the palette's own surface, not a class list that replaced it.
      expect(sheet.className).toContain('bg-(--plass-glass-press)');
    });

    it('applies a caller-supplied style over the tokens the sheet sets', async () => {
      const screen = await render(
        <PlCommandPalette
          items={items}
          shortcut={false}
          defaultOpen
          width={480}
          style={{ maxWidth: '600px' }}
        />
      );

      const sheet = screen.getByRole('dialog').element() as HTMLElement;

      expect(sheet.style.maxWidth).toBe('600px');
      // The colour slots the sheet wrote are still under it.
      expect(sheet.getAttribute('style')).toContain('--p-accent');
    });
  });
  describe('the backdrop', () => {
    it('takes classes of its own without losing the scrim', async () => {
      await render(
        <PlCommandPalette
          items={items}
          shortcut={false}
          defaultOpen
          classNames={{ backdrop: 'my-own-backdrop' }}
        />
      );

      const backdrop = document.querySelector('.my-own-backdrop');

      expect(backdrop).not.toBeNull();
      expect(backdrop).toHaveClass('plass-portal');
      expect(backdrop?.className).toContain('bg-(--plass-scrim)');
    });

    it('fades with the sheet, at the slow duration', async () => {
      const screen = await render(
        <PlCommandPalette
          items={items}
          shortcut={false}
          defaultOpen
          classNames={{ backdrop: 'my-own-backdrop' }}
        />
      );

      // This one takes the page, so it opens on the duration a modal opens on
      // rather than the one a menu hanging off a control does.
      for (const element of [
        document.querySelector('.my-own-backdrop')!,
        screen.getByRole('dialog').element()
      ]) {
        expect(element.className).toContain('--plass-duration-slow');
      }
    });
  });
});
