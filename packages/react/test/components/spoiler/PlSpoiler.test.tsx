import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlSpoiler, PlTextLink } from 'plass-ui';

describe('PlSpoiler', () => {
  describe('the cover', () => {
    it('blurs the content rather than removing it', async () => {
      const screen = await render(<PlSpoiler>He was the killer all along.</PlSpoiler>);

      // A reader can see that there is something there, and roughly how much of
      // it. What they cannot do is read it by accident.
      const body = screen.getByText('He was the killer all along.').element() as HTMLElement;

      expect(body.style.filter).toBe('blur(10px)');
    });

    it('takes a blur of its own', async () => {
      const screen = await render(<PlSpoiler blur={4}>He was the killer all along.</PlSpoiler>);
      const body = screen.getByText('He was the killer all along.').element() as HTMLElement;

      expect(body.style.filter).toBe('blur(4px)');
    });

    it('says why the content is covered, and can be told to say nothing', async () => {
      const screen = await render(<PlSpoiler>He was the killer all along.</PlSpoiler>);

      await expect.element(screen.getByText('This may contain spoilers')).toBeInTheDocument();

      await screen.rerender(
        <PlSpoiler description={false}>He was the killer all along.</PlSpoiler>
      );

      expect(screen.getByText('This may contain spoilers').query()).toBeNull();
    });

    it('clamps a long cover and lets go on the way out', async () => {
      const screen = await render(
        <PlSpoiler maxHeight={80}>He was the killer all along.</PlSpoiler>
      );
      const body = screen.getByText('He was the killer all along.').element() as HTMLElement;

      expect(body.style.maxHeight).toBe('80px');

      await screen.rerender(
        <PlSpoiler revealed maxHeight={80}>
          He was the killer all along.
        </PlSpoiler>
      );

      // Revealing something and leaving it in a box with a scrollbar is
      // answering the wrong question.
      expect(
        (screen.getByText('He was the killer all along.').element() as HTMLElement).style.maxHeight
      ).toBe('');
    });
  });

  describe('revealing', () => {
    it('uncovers on the button and reports it', async () => {
      const onRevealedChange = vi.fn();
      const screen = await render(
        <PlSpoiler onRevealedChange={onRevealedChange}>He was the killer all along.</PlSpoiler>
      );

      await screen.getByRole('button', { name: 'Reveal' }).click();

      expect(onRevealedChange).toHaveBeenCalledWith(true);
      expect(
        (screen.getByText('He was the killer all along.').element() as HTMLElement).style.filter
      ).toBe('');
    });

    it('stays where a controlled revealed put it', async () => {
      const onRevealedChange = vi.fn();
      const screen = await render(
        <PlSpoiler revealed={false} onRevealedChange={onRevealedChange}>
          He was the killer all along.
        </PlSpoiler>
      );

      await screen.getByRole('button', { name: 'Reveal' }).click();

      expect(onRevealedChange).toHaveBeenCalledWith(true);
      await expect.element(screen.getByRole('button', { name: 'Reveal' })).toBeInTheDocument();
    });

    it('starts uncovered on defaultRevealed', async () => {
      const screen = await render(
        <PlSpoiler defaultRevealed>He was the killer all along.</PlSpoiler>
      );

      expect(screen.getByRole('button', { name: 'Reveal' }).query()).toBeNull();
    });

    it('offers a way back when it is reversible', async () => {
      const screen = await render(
        <PlSpoiler reversible defaultRevealed>
          He was the killer all along.
        </PlSpoiler>
      );

      await screen.getByRole('button', { name: 'Hide' }).click();

      await expect.element(screen.getByRole('button', { name: 'Reveal' })).toBeInTheDocument();
    });

    it('takes a control of its own in place of the button', async () => {
      const screen = await render(
        <PlSpoiler action={<PlButton variant="ghost">Show me</PlButton>}>
          He was the killer all along.
        </PlSpoiler>
      );

      await expect.element(screen.getByRole('button', { name: 'Show me' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Reveal' }).query()).toBeNull();
    });
  });

  describe('while it is covered', () => {
    it('is inert, so it cannot be tabbed into or selected', async () => {
      const screen = await render(
        <PlSpoiler>
          <PlTextLink href="/twist">The twist</PlTextLink>
        </PlSpoiler>
      );

      const body = screen.getByText('The twist').element().parentElement;

      // A spoiler that could be defeated by Ctrl-A is not a spoiler, and one
      // whose link is still tabbable is worse than that.
      expect(body).toHaveAttribute('inert');
      expect(body).toHaveClass('select-none');
    });

    it('lets go of all three the moment it is revealed', async () => {
      const screen = await render(
        <PlSpoiler revealed>
          <PlTextLink href="/twist">The twist</PlTextLink>
        </PlSpoiler>
      );

      const body = screen.getByText('The twist').element().parentElement;

      expect(body).not.toHaveAttribute('inert');
      expect(body).not.toHaveClass('select-none');
    });
  });

  describe('the sheet', () => {
    it('is never dyed, whatever colour it is given', async () => {
      await render(
        <PlSpoiler className="spoiler-under-test" color="danger">
          He was the killer all along.
        </PlSpoiler>
      );

      const element = document.querySelector<HTMLElement>('.spoiler-under-test');

      // What a spoiler holds arrives with its own colours; the family shows up
      // on the button and in the hairline and stops.
      expect(element?.style.getPropertyValue('--p-fill')).toBe('');
      expect(element?.style.getPropertyValue('--p-line')).toBe('var(--plass-danger-line)');
    });

    it('draws no box at all on ghost', async () => {
      await render(
        <PlSpoiler className="spoiler-under-test" variant="ghost">
          He was the killer all along.
        </PlSpoiler>
      );

      expect(document.querySelector('.spoiler-under-test')).toHaveClass('bg-transparent');
    });
  });
});
