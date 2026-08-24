import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlHighlight } from 'plass-ui';

/** The marks the component drew, in order, as plain strings. */
function marks(): string[] {
  return [...document.querySelectorAll('.highlight-under-test mark')].map(
    (mark) => mark.textContent ?? ''
  );
}

describe('PlHighlight', () => {
  describe('matching', () => {
    it('marks the term it is given', async () => {
      await render(
        <PlHighlight className="highlight-under-test" query="glass">
          A sheet of glass over a page.
        </PlHighlight>
      );

      expect(marks()).toEqual(['glass']);
    });

    it('ignores case by default', async () => {
      await render(
        <PlHighlight className="highlight-under-test" query="glass">
          Glass and glass.
        </PlHighlight>
      );

      expect(marks()).toEqual(['Glass', 'glass']);
    });

    it('respects case when asked', async () => {
      await render(
        <PlHighlight className="highlight-under-test" query="glass" caseSensitive>
          Glass and glass.
        </PlHighlight>
      );

      expect(marks()).toEqual(['glass']);
    });

    it('tries the longest term first', async () => {
      await render(
        <PlHighlight className="highlight-under-test" query={['data', 'database']}>
          One database here.
        </PlHighlight>
      );

      expect(marks()).toEqual(['database']);
    });

    it('marks only whole words when asked', async () => {
      await render(
        <PlHighlight className="highlight-under-test" query="cat" wholeWord>
          A cat that can concatenate.
        </PlHighlight>
      );

      expect(marks()).toEqual(['cat']);
    });

    it('takes a regular expression as written', async () => {
      await render(
        <PlHighlight className="highlight-under-test" query={/\d+/}>
          Ports 80 and 443.
        </PlHighlight>
      );

      expect(marks()).toEqual(['80', '443']);
    });

    it('leaves the text alone when there is nothing to look for', async () => {
      await render(
        <PlHighlight className="highlight-under-test" query="">
          Nothing to find.
        </PlHighlight>
      );

      expect(marks()).toEqual([]);
    });

    it('re-marks when the query changes', async () => {
      const screen = await render(
        <PlHighlight className="highlight-under-test" query="glass">
          Glass over a gradient.
        </PlHighlight>
      );

      await screen.rerender(
        <PlHighlight className="highlight-under-test" query="gradient">
          Glass over a gradient.
        </PlHighlight>
      );

      expect(marks()).toEqual(['gradient']);
    });
  });

  describe('walking the tree', () => {
    it('marks inside a nested element and keeps the element', async () => {
      await render(
        <PlHighlight className="highlight-under-test" query="glass">
          A sheet of <strong>glass</strong> over a page.
        </PlHighlight>
      );

      expect(marks()).toEqual(['glass']);
      expect(document.querySelector('.highlight-under-test strong mark')).not.toBeNull();
    });

    it('marks a number as readily as a string', async () => {
      await render(
        <PlHighlight className="highlight-under-test" query="4">
          {2024}
        </PlHighlight>
      );

      expect(marks()).toEqual(['4']);
    });
  });

  describe('rendering', () => {
    it('renders the whole text, marked or not', async () => {
      const screen = await render(<PlHighlight query="glass">A sheet of glass.</PlHighlight>);

      await expect.element(screen.getByText('A sheet of', { exact: false })).toBeInTheDocument();
    });

    it('forwards unknown props to the element', async () => {
      const screen = await render(
        <PlHighlight query="a" data-testid="marked">
          a
        </PlHighlight>
      );

      expect(screen.getByTestId('marked').element()).toBeInTheDocument();
    });
  });
});
