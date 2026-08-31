/**
 * The chords are pressed as real bubbling `keydown`s, because that is what the
 * hook listens for — see `test/support/keys.ts` for why a dispatched event has
 * to bubble to reach anything at all.
 *
 * `Mod` is ⌘ on a Mac and Ctrl everywhere else and this suite runs on all
 * three platforms, so nothing here presses "the Mod key": each test presses ⌘
 * and Ctrl in turn and asserts that **exactly one** of them counted, which is
 * the real invariant and is true wherever it runs.
 */
import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { usePlHotKeys, type PlHotKeysOptions, type PlassHotKeys } from 'plass-ui';
import { press } from '../support/keys';

function Bound({ hotKeys, options }: { hotKeys?: PlassHotKeys; options?: PlHotKeysOptions }) {
  usePlHotKeys(hotKeys, options);

  return <input aria-label="Note" />;
}

/** The field the page has, for the "while typing" half of the rules. */
const field = () => document.querySelector<HTMLInputElement>('input[aria-label="Note"]')!;

describe('usePlHotKeys', () => {
  describe('binding', () => {
    it('answers the chord it was given', async () => {
      const run = vi.fn();

      await render(<Bound hotKeys={{ 'Mod+K': run }} />);

      press(document.body, 'k', { metaKey: true });
      press(document.body, 'k', { ctrlKey: true });

      expect(run).toHaveBeenCalledTimes(1);
    });

    it('checks every modifier in both directions', async () => {
      const run = vi.fn();

      await render(<Bound hotKeys={{ 'Mod+K': run }} />);

      press(document.body, 'k', { metaKey: true, shiftKey: true });
      press(document.body, 'k', { ctrlKey: true, shiftKey: true });
      press(document.body, 'k');

      expect(run).not.toHaveBeenCalled();
    });

    it('answers each chord in the map', async () => {
      const save = vi.fn();
      const cancel = vi.fn();

      await render(<Bound hotKeys={{ 'Mod+S': save, Escape: cancel }} />);

      press(document.body, 's', { metaKey: true });
      press(document.body, 's', { ctrlKey: true });
      press(document.body, 'Escape');

      expect(save).toHaveBeenCalledTimes(1);
      expect(cancel).toHaveBeenCalledTimes(1);
    });

    it('consumes the key it answered', async () => {
      await render(<Bound hotKeys={{ 'Mod+K': () => {} }} />);

      const meta = new KeyboardEvent('keydown', {
        key: 'k',
        metaKey: true,
        bubbles: true,
        cancelable: true
      });
      const ctrl = new KeyboardEvent('keydown', {
        key: 'k',
        ctrlKey: true,
        bubbles: true,
        cancelable: true
      });

      document.body.dispatchEvent(meta);
      document.body.dispatchEvent(ctrl);

      // Exactly one of the two is this platform's `Mod`, and that one is the
      // one the browser must not also act on.
      expect([meta.defaultPrevented, ctrl.defaultPrevented].filter(Boolean)).toHaveLength(1);
    });

    it('leaves a key something nearer has already answered', async () => {
      const run = vi.fn();

      await render(<Bound hotKeys={{ Escape: run }} />);

      const event = new KeyboardEvent('keydown', {
        key: 'Escape',
        bubbles: true,
        cancelable: true
      });

      // A field's own binding, consuming the key on its way past.
      event.preventDefault();
      document.body.dispatchEvent(event);

      expect(run).not.toHaveBeenCalled();
    });

    it('binds nothing when there is no map', async () => {
      await render(<Bound />);

      const event = new KeyboardEvent('keydown', {
        key: 'k',
        metaKey: true,
        bubbles: true,
        cancelable: true
      });

      document.body.dispatchEvent(event);

      expect(event.defaultPrevented).toBe(false);
    });
  });

  describe('enabled', () => {
    it('removes the listener rather than muting the handler', async () => {
      const run = vi.fn();

      await render(<Bound hotKeys={{ 'Mod+K': run }} options={{ enabled: false }} />);

      const event = new KeyboardEvent('keydown', {
        key: 'k',
        metaKey: true,
        bubbles: true,
        cancelable: true
      });

      document.body.dispatchEvent(event);

      expect(run).not.toHaveBeenCalled();
      // Not consumed either: a shortcut that is off must not take the key from
      // whatever else wanted it.
      expect(event.defaultPrevented).toBe(false);
    });

    it('binds again when it is turned back on', async () => {
      const run = vi.fn();

      const screen = await render(
        <Bound hotKeys={{ 'Mod+K': run }} options={{ enabled: false }} />
      );

      await screen.rerender(<Bound hotKeys={{ 'Mod+K': run }} options={{ enabled: true }} />);

      press(document.body, 'k', { metaKey: true });
      press(document.body, 'k', { ctrlKey: true });

      expect(run).toHaveBeenCalledTimes(1);
    });
  });

  describe('while the reader is typing', () => {
    it('leaves an unmodified chord alone in a field', async () => {
      const run = vi.fn();

      await render(<Bound hotKeys={{ '/': run }} />);

      field().focus();
      press(field(), '/');

      expect(run).not.toHaveBeenCalled();
    });

    it('answers it everywhere else', async () => {
      const run = vi.fn();

      await render(<Bound hotKeys={{ '/': run }} />);

      press(document.body, '/');

      expect(run).toHaveBeenCalledTimes(1);
    });

    it('answers a chord carrying a hard modifier in a field anyway', async () => {
      const run = vi.fn();

      await render(<Bound hotKeys={{ 'Mod+K': run }} />);

      field().focus();
      press(field(), 'k', { metaKey: true });
      press(field(), 'k', { ctrlKey: true });

      // `Mod` cannot appear in a field's value, so there is nothing to steal.
      expect(run).toHaveBeenCalledTimes(1);
    });

    it('does not count Shift as a hard modifier', async () => {
      const run = vi.fn();

      await render(<Bound hotKeys={{ 'Shift+A': run }} />);

      field().focus();
      press(field(), 'A', { shiftKey: true });

      // `Shift+A` is how a capital A is typed.
      expect(run).not.toHaveBeenCalled();
    });

    it('answers Escape in a field, because Escape types nothing', async () => {
      const run = vi.fn();

      await render(<Bound hotKeys={{ Escape: run }} />);

      field().focus();
      press(field(), 'Escape');

      expect(run).toHaveBeenCalledTimes(1);
    });

    it('leaves Enter alone in a field, because Enter does something there', async () => {
      const run = vi.fn();

      await render(<Bound hotKeys={{ Enter: run }} />);

      field().focus();
      press(field(), 'Enter');

      expect(run).not.toHaveBeenCalled();
    });

    it('answers everything when whileTyping is on', async () => {
      const run = vi.fn();

      await render(<Bound hotKeys={{ '/': run }} options={{ whileTyping: true }} />);

      field().focus();
      press(field(), '/');

      expect(run).toHaveBeenCalledTimes(1);
    });
  });

  describe('the map', () => {
    it('calls the handler the latest render gave it', async () => {
      const first = vi.fn();
      const second = vi.fn();

      const screen = await render(<Bound hotKeys={{ Escape: first }} />);

      await screen.rerender(<Bound hotKeys={{ Escape: second }} />);

      press(document.body, 'Escape');

      // An inline object literal is a new map every render; a hook that had
      // captured the first one would still be calling it.
      expect(first).not.toHaveBeenCalled();
      expect(second).toHaveBeenCalledTimes(1);
    });

    it('follows a chord being added', async () => {
      const run = vi.fn();

      const screen = await render(<Bound hotKeys={{}} />);

      await screen.rerender(<Bound hotKeys={{ Escape: run }} />);

      press(document.body, 'Escape');

      expect(run).toHaveBeenCalledTimes(1);
    });

    it('follows a chord being taken away', async () => {
      const run = vi.fn();

      const screen = await render(<Bound hotKeys={{ Escape: run }} />);

      await screen.rerender(<Bound hotKeys={{}} />);

      press(document.body, 'Escape');

      expect(run).not.toHaveBeenCalled();
    });

    it('stops answering once the component is gone', async () => {
      const run = vi.fn();

      const screen = await render(<Bound hotKeys={{ Escape: run }} />);

      screen.unmount();

      press(document.body, 'Escape');

      expect(run).not.toHaveBeenCalled();
    });
  });

  describe('target', () => {
    it('scopes the binding to an element', async () => {
      const run = vi.fn();

      function Scoped() {
        const ref = React.useRef<HTMLDivElement>(null);

        usePlHotKeys({ Escape: run }, { target: ref });

        return (
          <div ref={ref} data-testid="panel">
            <input aria-label="Inside" />
          </div>
        );
      }

      await render(<Scoped />);

      press(document.body, 'Escape');

      expect(run).not.toHaveBeenCalled();

      press(document.querySelector('[data-testid="panel"] input')!, 'Escape');

      expect(run).toHaveBeenCalledTimes(1);
    });
  });
});
