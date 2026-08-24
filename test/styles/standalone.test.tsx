/**
 * The standalone stylesheet — `plass-ui/styles.css`.
 *
 * Every other file in `test/` runs with no CSS at all, on purpose: the suite
 * tests the components' behaviour, and Base UI's own styling is not this
 * library's to verify. This file is the exception, because the thing under test
 * *is* a stylesheet — the promise that a project which installs `plass-ui` and
 * nothing else, and imports one file, gets styled components. That promise is
 * made of parts that can each break silently: the reset, the compiled
 * utilities, and the tokens the utilities read.
 *
 * What is loaded here is `src/standalone.css`, the same entry
 * `scripts/build-styles.mjs` compiles into `dist/styles.css`, through Vite and
 * the repository's own PostCSS config — so it is the same input and the same
 * compiler, without the test needing a build to have run first.
 *
 * The assertions stay off the design: no shade, no radius value, no height from
 * the size ladder. Those belong to the design language and move with it. What
 * is asserted is only that each layer arrived and that they compose — a
 * `border-radius` that is *not zero*, a background that is *not transparent*.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, TextField } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import pkg from '../../package.json';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

/** Resolved value of a custom property, from wherever it inherits. */
function token(element: Element, name: string): string {
  return getComputedStyle(element).getPropertyValue(name).trim();
}

describe('plass-ui/styles.css', () => {
  describe('the file is self-contained', () => {
    it('carries the compiled utilities, not just the tokens', () => {
      // A class the components spell out, in its resolved form. If the scan
      // ever stops finding `src/`, the tokens still ship and every assertion
      // about a custom property still passes — this is what would not.
      expect(standaloneCss).toContain('.inline-flex');
      expect(standaloneCss).toContain('--plass-radius-md');
      expect(standaloneCss).toContain('.plass-gloss');
    });

    it('leaves nothing for a consumer build to resolve', () => {
      // `@source` is an instruction to Tailwind. Reaching the output would mean
      // the file had not been compiled — and a browser would ignore it, so the
      // failure would show up as unstyled components rather than as an error.
      expect(standaloneCss).not.toContain('@source');
      expect(standaloneCss).not.toContain('@tailwind');
    });

    it('is exported under both names the package promises', () => {
      expect(pkg.exports['./styles.css']).toBe('./dist/styles.css');
      expect(pkg.exports['./tailwind.css']).toBe('./dist/tailwind.css');
    });
  });

  describe('the reset', () => {
    it('puts padding and border inside a control box', async () => {
      const screen = await render(<Button>Save</Button>);
      const element = screen.getByRole('button').element();

      expect(getComputedStyle(element).boxSizing).toBe('border-box');
    });

    it('leaves flow content to be spaced by the component around it', async () => {
      // Base UI renders a `<p>` for a field description, and a UA gives every
      // `<p>` a block margin the stack gap has already accounted for.
      const screen = await render(<TextField label="Email" description="We never share it." />);
      const styles = getComputedStyle(screen.getByText('We never share it.').element());

      expect(styles.marginBlockStart).toBe('0px');
      expect(styles.marginBlockEnd).toBe('0px');
    });

    it('loses to a single type selector from the page', async () => {
      // The whole reason every rule in `reset.css` is wrapped in `:where()`.
      // A consumer's own stylesheet outranks it without needing `!important`,
      // a layer, or a particular import order.
      const page = document.createElement('style');
      page.textContent = 'p { margin-block: 7px; }';
      document.head.append(page);

      try {
        const screen = await render(<TextField label="Email" description="We never share it." />);
        const styles = getComputedStyle(screen.getByText('We never share it.').element());

        expect(styles.marginBlockStart).toBe('7px');
      } finally {
        page.remove();
      }
    });
  });

  describe('the utilities', () => {
    it('style a control that would otherwise be a bare button', async () => {
      const screen = await render(<Button>Save</Button>);
      const styles = getComputedStyle(screen.getByRole('button').element());

      expect(styles.display).toBe('inline-flex');
      expect(styles.borderRadius).not.toBe('0px');
      expect(parseFloat(styles.paddingLeft)).toBeGreaterThan(0);
      expect(parseFloat(styles.height)).toBeGreaterThan(0);
    });

    it('outrank the reset where the two meet', async () => {
      // `reset.css` zeroes the border radius of every `<button>` so a UA cannot
      // round a corner the size ladder has already decided. A utility is one
      // class and the reset is none, so this only holds while the reset stays
      // inside `:where()`.
      const screen = await render(<Button>Save</Button>);
      const radius = getComputedStyle(screen.getByRole('button').element()).borderRadius;

      expect(parseFloat(radius)).toBeGreaterThan(0);
    });
  });

  describe('the tokens', () => {
    it('resolve through the utilities into a moulded surface', async () => {
      // The full chain: a `color` prop picks a family, the component writes it
      // into a `--p-*` slot, a utility reads the slot, and the slot resolves to
      // a gradient derived in the token sheet. Any link missing leaves this
      // `none`.
      const screen = await render(<Button color="primary">Save</Button>);
      const image = getComputedStyle(screen.getByRole('button').element()).backgroundImage;

      expect(image).toContain('gradient');
    });

    it('paints a sheet a field can be read on', async () => {
      const screen = await render(<TextField label="Email" />);
      const shell = screen.getByRole('textbox').element().parentElement as HTMLElement;
      const background = getComputedStyle(shell).backgroundColor;

      expect(background).not.toBe('transparent');
      expect(background).not.toBe('rgba(0, 0, 0, 0)');
    });

    it('answer to a forced theme without any further setup', async () => {
      const screen = await render(<Button>Save</Button>);
      const element = screen.getByRole('button').element();
      const light = token(element, '--plass-surface');

      document.documentElement.setAttribute('data-theme', 'dark');

      try {
        expect(token(element, '--plass-surface')).not.toBe(light);
      } finally {
        document.documentElement.removeAttribute('data-theme');
      }
    });

    it('keep the key its own colour in either theme', async () => {
      // The one place Plass deliberately does not re-pick per theme: a piece of
      // plastic is the same piece of plastic in a dark room. What moves is the
      // accent, which has to be *read* off a surface.
      const screen = await render(<Button>Save</Button>);
      const element = screen.getByRole('button').element();
      const solid = token(element, '--plass-primary-solid');
      const accent = token(element, '--plass-primary-accent');

      document.documentElement.setAttribute('data-theme', 'dark');

      try {
        expect(token(element, '--plass-primary-solid')).toBe(solid);
        expect(token(element, '--plass-primary-accent')).not.toBe(accent);
      } finally {
        document.documentElement.removeAttribute('data-theme');
      }
    });
  });
});
