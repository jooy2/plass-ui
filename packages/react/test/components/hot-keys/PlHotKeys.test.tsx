import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlHotKeys, PlKbd } from 'plass-ui';

describe('PlHotKeys', () => {
  describe('rendering', () => {
    it('renders one `<kbd>` per key', async () => {
      await render(<PlHotKeys className="keys-under-test" keys="Ctrl+Shift+P" os="windows" />);

      expect(document.querySelectorAll('.keys-under-test kbd')).toHaveLength(3);
    });

    it('takes the array form for a shortcut whose key is a plus', async () => {
      await render(<PlHotKeys className="keys-under-test" keys={['Ctrl', '+']} os="windows" />);
      const caps = document.querySelectorAll('.keys-under-test kbd');

      expect(caps).toHaveLength(2);
      expect(caps[1].textContent).toBe('+');
    });

    it('reflects changed keys on re-render', async () => {
      const screen = await render(<PlHotKeys keys="Ctrl+K" os="windows" />);

      await screen.rerender(<PlHotKeys keys="Ctrl+J" os="windows" />);

      await expect.element(screen.getByText('J')).toBeInTheDocument();
      expect(screen.getByText('K').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlHotKeys className="my-own-class" keys="Ctrl+K" />);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });
  });

  describe('naming the keys', () => {
    it('draws Mod as Ctrl on Windows', async () => {
      const screen = await render(<PlHotKeys keys="Mod+K" os="windows" />);

      await expect.element(screen.getByText('Ctrl')).toBeInTheDocument();
    });

    it('draws Mod as ⌘ on a Mac, and announces it as Command', async () => {
      await render(<PlHotKeys className="keys-under-test" keys="Mod+K" os="mac" />);
      const first = document.querySelector('.keys-under-test kbd') as HTMLElement;

      expect(first.textContent).toContain('⌘');
      // `⌘` reads as "place of interest sign" on its own, so the name rides
      // beside it in a clipped box.
      expect(first.textContent).toContain('Command');
    });

    it('accepts the aliases one key already has', async () => {
      const screen = await render(<PlHotKeys keys="Command+Option+Escape" os="mac" />);

      expect(screen.getByText('Command').query()).not.toBeNull();
      expect(screen.getByText('Option').query()).not.toBeNull();
      expect(screen.getByText('Escape').query()).not.toBeNull();
    });

    it('draws the arrows as arrows on every platform', async () => {
      const screen = await render(<PlHotKeys keys="Up+Down" os="windows" />);

      await expect.element(screen.getByText('↑')).toBeInTheDocument();
      await expect.element(screen.getByText('↓')).toBeInTheDocument();
    });

    it('capitalises a single letter', async () => {
      const screen = await render(<PlHotKeys keys="mod+k" os="windows" />);

      await expect.element(screen.getByText('K')).toBeInTheDocument();
    });

    it('prints an unknown key exactly as it was written', async () => {
      const screen = await render(<PlHotKeys keys="Ctrl+F12" os="windows" />);

      await expect.element(screen.getByText('F12')).toBeInTheDocument();
    });
  });

  describe('the separator', () => {
    it('joins with a plus off a Mac', async () => {
      await render(<PlHotKeys className="keys-under-test" keys="Ctrl+K" os="windows" />);
      const strip = document.querySelector('.keys-under-test') as HTMLElement;

      expect(strip.textContent).toContain('+');
    });

    it('joins with nothing on a Mac', async () => {
      await render(<PlHotKeys className="keys-under-test" keys="Shift+Mod+P" os="mac" />);
      const strip = document.querySelector('.keys-under-test') as HTMLElement;

      expect(strip.textContent).not.toContain('+');
    });

    it("takes a caller's own separator", async () => {
      await render(
        <PlHotKeys className="keys-under-test" keys="Ctrl+K" os="mac" separator="then" />
      );
      const strip = document.querySelector('.keys-under-test') as HTMLElement;

      expect(strip.textContent).toContain('then');
    });
  });

  describe('cluster', () => {
    it('draws four caps in the inverted T', async () => {
      await render(
        <PlHotKeys
          className="keys-under-test"
          cluster={{ up: 'W', left: 'A', down: 'S', right: 'D' }}
        />
      );
      const caps = document.querySelectorAll('.keys-under-test kbd');

      expect(caps).toHaveLength(4);
      expect([...caps].map((cap) => cap.textContent)).toEqual(['W', 'A', 'S', 'D']);
    });

    it('wins over `keys`', async () => {
      await render(
        <PlHotKeys
          className="keys-under-test"
          keys="Ctrl+K"
          cluster={{ up: 'W', left: 'A', down: 'S', right: 'D' }}
        />
      );

      expect(document.querySelectorAll('.keys-under-test kbd')).toHaveLength(4);
    });
  });

  describe('PlKbd', () => {
    it('renders one cap on its own', async () => {
      await render(<PlKbd className="cap-under-test">Esc</PlKbd>);
      const cap = document.querySelector('.cap-under-test') as HTMLElement;

      expect(cap.tagName).toBe('KBD');
      expect(cap.textContent).toBe('Esc');
    });

    it('takes the size ladder a step down, like the strip does', async () => {
      await render(<PlKbd className="cap-under-test" size="lg" />);

      // `lg` on the strip is `md` on the cap: 40px, not 48px.
      expect(document.querySelector('.cap-under-test')).toHaveClass('h-10');
    });
  });
});
