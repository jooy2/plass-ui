import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlButton,
  PlContextMenu,
  PlMenu,
  PlMenuCheckboxItem,
  PlMenuGroup,
  PlMenuItem,
  PlMenuRadioGroup,
  PlMenuRadioItem,
  PlMenuSeparator,
  PlMenuSubmenu
} from 'plass-ui';

const trigger = <PlButton>Open</PlButton>;

describe('PlMenu', () => {
  describe('opening', () => {
    it('is shut until the trigger is pressed', async () => {
      const screen = await render(
        <PlMenu trigger={trigger}>
          <PlMenuItem>Cut</PlMenuItem>
        </PlMenu>
      );

      expect(screen.getByRole('menu').query()).toBeNull();
    });

    it('opens on the trigger', async () => {
      const screen = await render(
        <PlMenu trigger={trigger}>
          <PlMenuItem>Cut</PlMenuItem>
        </PlMenu>
      );

      await screen.getByRole('button', { name: 'Open' }).click();

      await expect.element(screen.getByRole('menu')).toBeInTheDocument();
      await expect.element(screen.getByRole('menuitem', { name: 'Cut' })).toBeInTheDocument();
    });

    it('reports the open state', async () => {
      const change = vi.fn();
      const screen = await render(
        <PlMenu trigger={trigger} onOpenChange={change}>
          <PlMenuItem>Cut</PlMenuItem>
        </PlMenu>
      );

      await screen.getByRole('button', { name: 'Open' }).click();

      await vi.waitFor(() => expect(change).toHaveBeenCalledWith(true));
    });

    it('opens where it was told to', async () => {
      const screen = await render(
        <PlMenu open>
          <PlMenuItem>Cut</PlMenuItem>
        </PlMenu>
      );

      await expect.element(screen.getByRole('menu')).toBeInTheDocument();
    });

    it('does not open while it is disabled', async () => {
      const screen = await render(
        <PlMenu trigger={trigger} disabled>
          <PlMenuItem>Cut</PlMenuItem>
        </PlMenu>
      );

      await screen.getByRole('button', { name: 'Open' }).click({ force: true });

      expect(screen.getByRole('menu').query()).toBeNull();
    });
  });

  describe('a row', () => {
    it('fires when it is picked', async () => {
      const pick = vi.fn();
      const screen = await render(
        <PlMenu open>
          <PlMenuItem onClick={pick}>Cut</PlMenuItem>
        </PlMenu>
      );

      await screen.getByRole('menuitem', { name: 'Cut' }).click();

      await vi.waitFor(() => expect(pick).toHaveBeenCalledOnce());
    });

    it('is a real link when it has somewhere to go', async () => {
      const screen = await render(
        <PlMenu open>
          <PlMenuItem href="/docs">Documentation</PlMenuItem>
        </PlMenu>
      );

      const element = screen.getByRole('menuitem', { name: 'Documentation' }).element();

      expect(element.tagName).toBe('A');
      expect(element).toHaveAttribute('href', '/docs');
    });

    it('does not fire while it is unavailable', async () => {
      const pick = vi.fn();
      const screen = await render(
        <PlMenu open>
          <PlMenuItem disabled onClick={pick}>
            Cut
          </PlMenuItem>
        </PlMenu>
      );

      await screen.getByRole('menuitem', { name: 'Cut' }).click({ force: true });

      expect(pick).not.toHaveBeenCalled();
    });

    it('carries a shortcut and a description', async () => {
      const screen = await render(
        <PlMenu open>
          <PlMenuItem shortcut="⌘X" description="Takes it out">
            Cut
          </PlMenuItem>
        </PlMenu>
      );

      await expect.element(screen.getByText('⌘X')).toBeInTheDocument();
      await expect.element(screen.getByText('Takes it out')).toBeInTheDocument();
    });

    it('takes a family of its own for the row that deletes', async () => {
      await render(
        <PlMenu open>
          <PlMenuItem className="row-under-test" color="danger">
            Delete
          </PlMenuItem>
        </PlMenu>
      );

      const element = document.querySelector<HTMLElement>('.row-under-test');

      expect(element?.style.getPropertyValue('--p-accent')).toBe('var(--plass-danger-accent)');
      // Branched rather than appended: only one text colour exists on the row.
      expect(element).toHaveClass('text-(--p-accent)');
      expect(element).not.toHaveClass('text-(--plass-fg)');
    });
  });

  describe('ticking and choosing', () => {
    it('reports a tick', async () => {
      const change = vi.fn();
      const screen = await render(
        <PlMenu open>
          <PlMenuCheckboxItem onCheckedChange={change}>Word wrap</PlMenuCheckboxItem>
        </PlMenu>
      );

      await screen.getByRole('menuitemcheckbox', { name: 'Word wrap' }).click();

      await vi.waitFor(() => expect(change).toHaveBeenCalledWith(true));
    });

    it('stays open when a row is ticked', async () => {
      const screen = await render(
        <PlMenu open>
          <PlMenuCheckboxItem>Word wrap</PlMenuCheckboxItem>
        </PlMenu>
      );

      await screen.getByRole('menuitemcheckbox', { name: 'Word wrap' }).click();

      await expect.element(screen.getByRole('menu')).toBeInTheDocument();
    });

    it('reports a choice out of a set', async () => {
      const change = vi.fn();
      const screen = await render(
        <PlMenu open>
          <PlMenuRadioGroup defaultValue="list" onValueChange={change}>
            <PlMenuRadioItem value="list">List</PlMenuRadioItem>
            <PlMenuRadioItem value="grid">Grid</PlMenuRadioItem>
          </PlMenuRadioGroup>
        </PlMenu>
      );

      await screen.getByRole('menuitemradio', { name: 'Grid' }).click();

      await vi.waitFor(() => expect(change).toHaveBeenCalledWith('grid'));
    });
  });

  describe('the structure', () => {
    it('names a group without making it pickable', async () => {
      const screen = await render(
        <PlMenu open>
          <PlMenuGroup label="Edit">
            <PlMenuItem>Cut</PlMenuItem>
          </PlMenuGroup>
        </PlMenu>
      );

      await expect.element(screen.getByText('Edit')).toBeInTheDocument();
      expect(screen.getByRole('menuitem', { name: 'Edit' }).query()).toBeNull();
    });

    it('draws a hairline between two runs of rows', async () => {
      await render(
        <PlMenu open>
          <PlMenuItem>Cut</PlMenuItem>
          <PlMenuSeparator className="rule-under-test" />
          <PlMenuItem>Paste</PlMenuItem>
        </PlMenu>
      );

      expect(document.querySelector('.rule-under-test')).toHaveClass('h-px');
    });

    it('opens a submenu from a row that is still a row', async () => {
      const screen = await render(
        <PlMenu open>
          <PlMenuSubmenu label="Share">
            <PlMenuItem>By email</PlMenuItem>
          </PlMenuSubmenu>
        </PlMenu>
      );

      const opener = screen.getByRole('menuitem', { name: 'Share' });

      await expect.element(opener).toBeInTheDocument();

      await opener.click();

      await expect.element(screen.getByRole('menuitem', { name: 'By email' })).toBeInTheDocument();
    });
  });

  describe('the set', () => {
    it('hands its size and density down to every row', async () => {
      await render(
        <PlMenu open size="lg" density="compact">
          <PlMenuItem className="row-under-test">Cut</PlMenuItem>
        </PlMenu>
      );

      const element = document.querySelector('.row-under-test');

      expect(element).toHaveClass('px-2.5');
      expect(element).toHaveClass('gap-2.5');
    });

    it('floats at the top of the elevation ladder', async () => {
      await render(
        <PlMenu open className="menu-under-test">
          <PlMenuItem>Cut</PlMenuItem>
        </PlMenu>
      );

      const element = document.querySelector<HTMLElement>('.menu-under-test');

      expect(element?.style.getPropertyValue('--p-elev')).toBe('var(--plass-shadow-3)');
    });
  });
});

describe('PlContextMenu', () => {
  it('wraps the area rather than one trigger element', async () => {
    const screen = await render(
      <PlContextMenu content={<PlMenuItem>Rename</PlMenuItem>}>
        <div>Right-click here</div>
      </PlContextMenu>
    );

    await expect.element(screen.getByText('Right-click here')).toBeInTheDocument();
    expect(screen.getByRole('menu').query()).toBeNull();
  });

  it('opens where it was told to', async () => {
    const screen = await render(
      <PlContextMenu open content={<PlMenuItem>Rename</PlMenuItem>}>
        <div>Right-click here</div>
      </PlContextMenu>
    );

    await expect.element(screen.getByRole('menuitem', { name: 'Rename' })).toBeInTheDocument();
  });

  it('draws its rows on exactly the menu surface', async () => {
    await render(
      <PlContextMenu open className="menu-under-test" content={<PlMenuItem>Rename</PlMenuItem>}>
        <div>Right-click here</div>
      </PlContextMenu>
    );

    expect(document.querySelector('.menu-under-test')).toHaveClass('bg-(--plass-glass-press)');
  });
  describe('caller styling', () => {
    it("applies a group's style to the group", async () => {
      await render(
        <PlMenu open trigger={trigger}>
          <PlMenuGroup label="Recent" className="group-under-test" style={{ order: 3 }}>
            <PlMenuItem>Report.pdf</PlMenuItem>
          </PlMenuGroup>
        </PlMenu>
      );

      const group = document.querySelector<HTMLElement>('.group-under-test');

      expect(group).not.toBeNull();
      expect(group?.style.order).toBe('3');
    });

    it("applies a radio group's style to the radio group", async () => {
      await render(
        <PlMenu open trigger={trigger}>
          <PlMenuRadioGroup defaultValue="list" className="radios-under-test" style={{ order: 4 }}>
            <PlMenuRadioItem value="list">List</PlMenuRadioItem>
          </PlMenuRadioGroup>
        </PlMenu>
      );

      const group = document.querySelector<HTMLElement>('.radios-under-test');

      expect(group).not.toBeNull();
      expect(group?.style.order).toBe('4');
    });
  });
});
