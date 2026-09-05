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
import { PlButton, PlLineChart, PlScatterChart, PlStack, PlTextField } from 'plass-ui';
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
      expect(standaloneCss).toContain('.plass-glow');
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
      const screen = await render(<PlButton>Save</PlButton>);
      const element = screen.getByRole('button').element();

      expect(getComputedStyle(element).boxSizing).toBe('border-box');
    });

    it('leaves flow content to be spaced by the component around it', async () => {
      // Base UI renders a `<p>` for a field description, and a UA gives every
      // `<p>` a block margin the stack gap has already accounted for.
      const screen = await render(<PlTextField label="Email" description="We never share it." />);
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
        const screen = await render(<PlTextField label="Email" description="We never share it." />);
        const styles = getComputedStyle(screen.getByText('We never share it.').element());

        expect(styles.marginBlockStart).toBe('7px');
      } finally {
        page.remove();
      }
    });
  });

  describe('the utilities', () => {
    it('style a control that would otherwise be a bare button', async () => {
      const screen = await render(<PlButton>Save</PlButton>);
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
      const screen = await render(<PlButton>Save</PlButton>);
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
      const screen = await render(<PlButton color="primary">Save</PlButton>);
      const image = getComputedStyle(screen.getByRole('button').element()).backgroundImage;

      expect(image).toContain('gradient');
    });

    it('paints a sheet a field can be read on', async () => {
      const screen = await render(<PlTextField label="Email" />);
      const shell = screen.getByRole('textbox').element().parentElement as HTMLElement;
      const background = getComputedStyle(shell).backgroundColor;

      expect(background).not.toBe('transparent');
      expect(background).not.toBe('rgba(0, 0, 0, 0)');
    });

    it('put every portal on one stacking level a page can move', async () => {
      const screen = await render(<PlButton>Save</PlButton>);
      const element = screen.getByRole('button').element();

      expect(token(element, '--plass-z-portal')).toBe('50');
    });

    it('keep the portal level out of the theme blocks, so a page override survives one', async () => {
      // `.light` and `.dark` re-declare everything they carry. A token that
      // lived in them would reset a consumer's own value on any nested element
      // wearing a theme class — which is every themed preview on a docs page.
      const screen = await render(<PlButton>Save</PlButton>);
      const element = screen.getByRole('button').element();

      document.documentElement.style.setProperty('--plass-z-portal', '1200');
      document.documentElement.setAttribute('data-theme', 'dark');

      try {
        expect(token(element, '--plass-z-portal')).toBe('1200');
      } finally {
        document.documentElement.removeAttribute('data-theme');
        document.documentElement.style.removeProperty('--plass-z-portal');
      }
    });

    it('answer to a forced theme without any further setup', async () => {
      const screen = await render(<PlButton>Save</PlButton>);
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
      const screen = await render(<PlButton>Save</PlButton>);
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

  describe('an overlapping pile measures what it draws', () => {
    /*
     * Here rather than in `test/components/stack/`, for the reason at the top of
     * this file: the promise is the *stylesheet's*. `PlStack` overlaps with a
     * negative margin written as a Tailwind arbitrary variant, and with no
     * compiled utilities there is no `display: flex` and no negative margin to
     * measure — so the assertion would be about the missing stylesheet rather
     * than about the pile.
     *
     * What it is worth asserting at all is the whole argument for the component
     * being a layout instead of an offset: a translated pile is laid out one
     * item wide, draws outside its own box, and every element after it on the
     * page is placed against a width the reader never sees.
     */
    const five = Array.from({ length: 5 }, (_, index) => (
      <span key={index} style={{ display: 'block', width: 32, height: 32, background: '#888' }} />
    ));

    /** The union of the items' own boxes, in page coordinates. */
    function drawn(root: HTMLElement) {
      const boxes = [...root.querySelectorAll('span > span > span')].map((node) =>
        node.getBoundingClientRect()
      );

      return {
        width:
          Math.max(...boxes.map((box) => box.right)) - Math.min(...boxes.map((box) => box.left)),
        height:
          Math.max(...boxes.map((box) => box.bottom)) - Math.min(...boxes.map((box) => box.top))
      };
    }

    // Five 32px items at 10px of overlap: 5 x 32 - 4 x 10 across, and the
    // diagonal falls a further 4 x 10 down.
    const expected = {
      horizontal: { width: 120, height: 32 },
      vertical: { width: 32, height: 120 },
      diagonal: { width: 120, height: 72 }
    } as const;

    for (const direction of ['horizontal', 'vertical', 'diagonal'] as const) {
      it(`fits the pile exactly — ${direction}`, async () => {
        const screen = await render(
          <PlStack data-testid="pile" direction={direction} overlap={10}>
            {five}
          </PlStack>
        );

        const root = screen.getByTestId('pile').element() as HTMLElement;
        const box = root.getBoundingClientRect();

        expect({ width: box.width, height: box.height }).toEqual(expected[direction]);
        expect({ width: box.width, height: box.height }).toEqual(drawn(root));
      });
    }
  });

  describe('the breakpoint ladder', () => {
    it('resolves each rung to a width the JavaScript half can read', () => {
      // `usePlBreakpoint` builds its `matchMedia` queries from these, so a
      // token that resolved to nothing would put the hook on the built-in
      // fallback while the stylesheet around it had moved.
      for (const [rung, width] of [
        ['sm', '40rem'],
        ['md', '48rem'],
        ['lg', '64rem'],
        ['xl', '80rem']
      ]) {
        expect(token(document.documentElement, `--plass-breakpoint-${rung}`)).toBe(width);
      }
    });
  });

  describe('the token channel', () => {
    it('lets a token set on the component itself beat the class that reads it', async () => {
      const screen = await render(<PlButton>Save</PlButton>);
      const plain = getComputedStyle(screen.getByRole('button').element()).borderRadius;

      await screen.rerender(<PlButton style={{ '--plass-radius-md': '3px' }}>Save</PlButton>);
      const overridden = getComputedStyle(screen.getByRole('button').element()).borderRadius;

      // Not a claim about what the radius *is* — only that the token reached
      // the `rounded-(--plass-radius-md)` the component wrote, which is what no
      // appended utility can be relied on to do.
      expect(overridden).toBe('3px');
      expect(overridden).not.toBe(plain);
    });

    it('lets a token set on an ancestor reach every component under it', async () => {
      const screen = await render(
        <div style={{ '--plass-radius-md': '3px' }}>
          <PlButton>Save</PlButton>
        </div>
      );

      // The half a `className` cannot do at all: one declaration on a wrapper,
      // and everything inside it answers, because a custom property cascades.
      expect(getComputedStyle(screen.getByRole('button').element()).borderRadius).toBe('3px');
    });
  });

  /**
   * The one place a chart's colours are asked to resolve.
   *
   * A chart writes its tokens straight into `fill` and `stroke` rather than
   * through a utility class, and an unresolvable `var()` there does not error —
   * a `stroke` computes to `none` and the mark loses its ring, its gridline or
   * its axis without anything failing. Two rounds of that shipped.
   *
   * `test/package/tokens.test.ts` catches the name that was never declared.
   * This catches the other half: a name that *is* declared but resolves to
   * nothing, because its declaration sits under a selector no chart matches.
   * Neither asserts a shade — only that something arrived.
   */
  describe('a chart’s own colours', () => {
    const painted = (element: Element, selector: string, property: 'fill' | 'stroke') => [
      ...new Set(
        [...element.querySelectorAll(selector)].map((one) => getComputedStyle(one)[property])
      )
    ];

    it('resolves the marks, their rings and the frame it draws them in', async () => {
      const screen = await render(
        <PlScatterChart
          label="Spend"
          series={[
            {
              name: 'A',
              data: [
                { x: 1, y: 2 },
                { x: 3, y: 5 }
              ]
            },
            { name: 'B', data: [{ x: 2, y: 4 }] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      const marks = plot.element();

      for (const colour of painted(marks, 'svg path[fill]', 'fill')) {
        expect(colour).not.toBe('none');
      }

      // The ring is the sheet showing through between two overlapping dots.
      for (const colour of painted(marks, 'svg path[fill]', 'stroke')) {
        expect(colour).not.toBe('none');
      }

      // The grid, the axis rules and the baseline.
      const frame = painted(marks, 'svg line', 'stroke');

      expect(frame.length).toBeGreaterThan(0);

      for (const colour of frame) {
        expect(colour).not.toBe('none');
      }
    });

    it('resolves the ring around a line chart’s markers', async () => {
      const screen = await render(
        <PlLineChart label="Trend" series={[{ name: 'A', data: [1, 4, 2, 6] }]} />
      );

      const plot = screen.getByRole('img', { name: 'Trend' });

      await expect.element(plot).toBeInTheDocument();

      const rings = painted(plot.element(), 'svg circle', 'stroke');

      expect(rings.length).toBeGreaterThan(0);

      for (const colour of rings) {
        expect(colour).not.toBe('none');
      }
    });
  });
});
