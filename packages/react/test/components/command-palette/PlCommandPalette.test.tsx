import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlCommandPalette, type PlCommandItem } from 'plass-ui';

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
      await expect.element(screen.getByText('⌘', { exact: false })).toBeVisible();
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
});
