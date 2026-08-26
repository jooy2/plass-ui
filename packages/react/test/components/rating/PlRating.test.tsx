import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlRating } from 'plass-ui';

/**
 * How much of each star is filled, as the percentage width of the clipped
 * overlay. A direct-child selector, because the glyphs inside are `aria-hidden`
 * too and only the overlay is a span at this depth.
 */
function fills(): string[] {
  return Array.from(
    document.querySelectorAll<HTMLElement>('.rating-under-test > span > span[aria-hidden="true"]')
  ).map((element) => element.style.width);
}

describe('PlRating', () => {
  describe('the row', () => {
    it('is five stars unless it is told otherwise', async () => {
      const screen = await render(<PlRating />);

      expect(screen.getByRole('radio').all()).toHaveLength(5);
    });

    it('takes the count it was given', async () => {
      const screen = await render(<PlRating count={3} />);

      expect(screen.getByRole('radio').all()).toHaveLength(3);
    });

    it('is a radio group, because a score is exactly one of these', async () => {
      const screen = await render(<PlRating />);

      await expect.element(screen.getByRole('radiogroup', { name: 'Rating' })).toBeInTheDocument();
    });

    it('takes a name of its own', async () => {
      const screen = await render(<PlRating label="How was it?" />);

      await expect
        .element(screen.getByRole('radiogroup', { name: 'How was it?' }))
        .toBeInTheDocument();
    });
  });

  describe('the fraction', () => {
    it('fills whole stars and leaves the rest empty', async () => {
      await render(<PlRating className="rating-under-test" value={3} />);

      expect(fills()).toEqual(['100%', '100%', '100%', '0%', '0%']);
    });

    it('draws a fraction the reader could not have chosen', async () => {
      // `precision` bounds what can be picked; an average is not a choice, and
      // rounding it would report a different number from the one handed in.
      await render(<PlRating className="rating-under-test" value={4.3} />);

      // Four stars full and three tenths of the fifth.
      expect(fills().slice(0, 4)).toEqual(['100%', '100%', '100%', '100%']);
      expect(Number.parseFloat(fills()[4])).toBeCloseTo(30, 6);
    });

    it('never fills past the end of the row', async () => {
      await render(<PlRating className="rating-under-test" count={3} value={99} />);

      expect(fills()).toEqual(['100%', '100%', '100%']);
    });

    it('draws nothing at all below zero', async () => {
      await render(<PlRating className="rating-under-test" count={2} value={-4} />);

      expect(fills()).toEqual(['0%', '0%']);
    });
  });

  describe('precision', () => {
    it('offers one choice per star by default', async () => {
      const screen = await render(<PlRating count={4} />);

      expect(screen.getByRole('radio').all()).toHaveLength(4);
    });

    it('offers a choice per fraction when it is asked to', async () => {
      const screen = await render(<PlRating count={4} precision={0.5} />);

      expect(screen.getByRole('radio').all()).toHaveLength(8);
    });

    it('names each choice by the score it stands for', async () => {
      const screen = await render(<PlRating count={2} precision={0.5} />);

      await expect.element(screen.getByRole('radio', { name: '0.5 out of 2' })).toBeInTheDocument();
      await expect.element(screen.getByRole('radio', { name: '2 out of 2' })).toBeInTheDocument();
    });

    it('falls back to whole stars for a step that is not one', async () => {
      const screen = await render(<PlRating count={3} precision={0} />);

      expect(screen.getByRole('radio').all()).toHaveLength(3);
    });
  });

  describe('choosing', () => {
    it('reports the score that was picked', async () => {
      const change = vi.fn();
      const screen = await render(<PlRating onValueChange={change} />);

      await screen.getByRole('radio', { name: '4 out of 5' }).click();

      expect(change).toHaveBeenCalledWith(4);
    });

    it('keeps a controlled rating where it was told to be', async () => {
      const screen = await render(<PlRating value={2} />);

      await screen.getByRole('radio', { name: '5 out of 5' }).click();

      // The drawn row follows the pointer while it is over the stars — that is
      // what a hover preview is. The *value* does not move without a caller.
      expect(screen.getByRole('radio', { name: '2 out of 5' }).element()).toBeChecked();
    });

    it('clears when the score already chosen is chosen again', async () => {
      const change = vi.fn();
      const screen = await render(<PlRating value={3} onValueChange={change} />);

      await screen.getByRole('radio', { name: '3 out of 5' }).click();

      expect(change).toHaveBeenCalledWith(0);
    });

    it('does not clear when it was told not to', async () => {
      const change = vi.fn();
      const screen = await render(<PlRating value={3} clearable={false} onValueChange={change} />);

      await screen.getByRole('radio', { name: '3 out of 5' }).click();

      expect(change).not.toHaveBeenCalled();
    });
  });

  describe('readOnly', () => {
    it('has no inputs at all', async () => {
      const screen = await render(<PlRating readOnly value={4} />);

      expect(screen.getByRole('radio').all()).toHaveLength(0);
    });

    it('is one image carrying the score as a sentence', async () => {
      const screen = await render(<PlRating readOnly value={4} />);

      await expect.element(screen.getByRole('img', { name: '4 out of 5' })).toBeInTheDocument();
    });

    it('says so when there is no score yet', async () => {
      const screen = await render(<PlRating readOnly value={0} />);

      await expect.element(screen.getByRole('img', { name: 'No rating' })).toBeInTheDocument();
    });

    it('still draws the fraction', async () => {
      await render(<PlRating className="rating-under-test" readOnly value={2.5} />);

      expect(fills()).toEqual(['100%', '100%', '50%', '0%', '0%']);
    });
  });

  describe('disabled', () => {
    it('says so on the group and on every input', async () => {
      const screen = await render(<PlRating disabled />);

      expect(screen.getByRole('radiogroup').element()).toHaveAttribute('aria-disabled', 'true');
      expect(screen.getByRole('radio').first().element()).toBeDisabled();
    });

    it('takes the light out of the row rather than greying it', async () => {
      await render(<PlRating className="rating-under-test" disabled />);

      const element = document.querySelector('.rating-under-test');

      expect(element).toHaveClass('opacity-50');
      expect(element).toHaveClass('saturate-[0.35]');
    });
  });

  describe('the form', () => {
    it('submits under the name it was given', async () => {
      const screen = await render(<PlRating name="score" value={3} />);

      expect(screen.getByRole('radio', { name: '3 out of 5' }).element()).toHaveAttribute(
        'name',
        'score'
      );
    });

    it('marks the group required', async () => {
      const screen = await render(<PlRating required />);

      expect(screen.getByRole('radiogroup').element()).toHaveAttribute('aria-required', 'true');
    });
  });

  describe('colour', () => {
    it('is amber rather than the library default', async () => {
      await render(<PlRating className="rating-under-test" />);

      const element = document.querySelector<HTMLElement>('.rating-under-test');

      expect(element?.style.getPropertyValue('--p-accent')).toBe('var(--plass-warning-accent)');
    });

    it('takes another family when it is asked to', async () => {
      await render(<PlRating className="rating-under-test" color="danger" />);

      const element = document.querySelector<HTMLElement>('.rating-under-test');

      expect(element?.style.getPropertyValue('--p-accent')).toBe('var(--plass-danger-accent)');
    });
  });
});
