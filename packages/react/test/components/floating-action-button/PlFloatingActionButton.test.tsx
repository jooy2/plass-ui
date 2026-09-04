import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlFloatingActionButton } from 'plass-ui';

function Plus() {
  return <svg viewBox="0 0 16 16" />;
}

function fab(): HTMLButtonElement {
  const all = document.querySelectorAll<HTMLButtonElement>('.fab-under-test');

  // The last one: two of the tests below render twice to compare a default
  // with what overrides it.
  return all[all.length - 1];
}

describe('PlFloatingActionButton', () => {
  describe('the name', () => {
    it('is the label whether or not the words are drawn', async () => {
      await render(
        <PlFloatingActionButton className="fab-under-test" icon={<Plus />} label="New project" />
      );

      // A floating button is a disc with a mark in it nine times out of ten,
      // and an unnamed one is the defect this pattern ships with everywhere.
      expect(fab().getAttribute('aria-label')).toBe('New project');
      expect(fab().textContent).toBe('');
    });

    it('draws the same words when it is extended', async () => {
      const screen = await render(
        <PlFloatingActionButton
          className="fab-under-test"
          extended
          icon={<Plus />}
          label="New project"
        />
      );

      await expect.element(screen.getByRole('button', { name: 'New project' })).toBeInTheDocument();
      expect(fab().textContent).toContain('New project');
    });
  });

  describe('the shape', () => {
    it('is a disc while it is a glyph alone', async () => {
      await render(
        <PlFloatingActionButton className="fab-under-test" icon={<Plus />} label="New" />
      );

      // The flat run along a control's edge is there for a line of text to sit
      // on, and a glyph has no line of text.
      expect(fab().style.borderRadius).toBe('9999px');
    });

    it('takes the house fillet once it has words along its edge', async () => {
      await render(
        <PlFloatingActionButton className="fab-under-test" extended icon={<Plus />} label="New" />
      );

      expect(fab().style.borderRadius).toBe('');
      expect(fab().className).toContain('rounded-(--plass-radius-lg)');
    });
  });

  describe('the pinning', () => {
    it('sits in the bottom trailing corner by default', async () => {
      await render(
        <PlFloatingActionButton className="fab-under-test" icon={<Plus />} label="New" />
      );

      expect(fab().style.position).toBe('fixed');
      expect(fab().style.insetBlockEnd).toBe('1.5rem');
      expect(fab().style.insetInlineEnd).toBe('1.5rem');
    });

    it('takes any corner, as logical insets', async () => {
      await render(
        <PlFloatingActionButton
          className="fab-under-test"
          corner="top-start"
          icon={<Plus />}
          label="New"
        />
      );

      // `start` and not `left`: under RTL the corner is on the other side, and
      // the button has to go with it.
      expect(fab().style.insetBlockStart).toBe('1.5rem');
      expect(fab().style.insetInlineStart).toBe('1.5rem');
    });

    it('takes a number as pixels and a string as any length', async () => {
      await render(
        <PlFloatingActionButton className="fab-under-test" offset={8} icon={<Plus />} label="New" />
      );

      expect(fab().style.insetBlockEnd).toBe('8px');

      await render(
        <PlFloatingActionButton
          className="fab-under-test"
          offset="2vh"
          icon={<Plus />}
          label="New"
        />
      );

      expect(fab().style.insetBlockEnd).toBe('2vh');
    });

    it('pins nothing when it was told not to float', async () => {
      await render(
        <PlFloatingActionButton
          className="fab-under-test"
          floating={false}
          icon={<Plus />}
          label="New"
        />
      );

      expect(fab().style.position).toBe('');
      expect(fab().className).not.toContain('z-30');
    });
  });

  describe('it is a button', () => {
    it('does what it was given to do', async () => {
      const onClick = vi.fn();

      await render(
        <PlFloatingActionButton
          className="fab-under-test"
          icon={<Plus />}
          label="New"
          onClick={onClick}
        />
      );

      fab().click();

      expect(onClick).toHaveBeenCalledOnce();
    });

    it('floats at the top of the ladder unless it was told otherwise', async () => {
      await render(
        <PlFloatingActionButton className="fab-under-test" icon={<Plus />} label="New" />
      );

      // The one control in the library that genuinely floats over the content
      // rather than resting on it.
      expect(fab().style.getPropertyValue('--p-elev')).toBe('var(--plass-shadow-3)');
    });

    it('is a solid key by default, unlike a `PlBackTop`', async () => {
      await render(
        <PlFloatingActionButton className="fab-under-test" icon={<Plus />} label="New" />
      );

      expect(fab().className).toContain('[background-image:var(--p-fill)]');
    });
  });
});
