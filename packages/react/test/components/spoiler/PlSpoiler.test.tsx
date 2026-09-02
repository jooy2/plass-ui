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
    it('is at least as tall as its own cover', async () => {
      const screen = await render(
        <PlSpoiler data-testid="spoiler" size="lg">
          .
        </PlSpoiler>
      );

      const sheet = screen.getByTestId('spoiler').element();
      const cover = screen.getByRole('button', { name: 'Reveal' }).element();

      // Content and cover share one grid cell, so a one-character spoiler is as
      // tall as the button it is asking somebody to press rather than clipping
      // it.
      expect(sheet).toHaveClass('grid');
      expect(cover.getBoundingClientRect().bottom).toBeLessThanOrEqual(
        sheet.getBoundingClientRect().bottom
      );
    });

    it('reserves the way back out from the start, so the box does not move', async () => {
      const screen = await render(<PlSpoiler reversible>He was the killer all along.</PlSpoiler>);

      const row = screen.getByRole('button', { name: 'Hide' }).element().parentElement;

      // Drawn while the spoiler is still covered, which is the whole point: a
      // Hide row that arrived with the reveal grew the sheet by a button on the
      // way in and shrank it back on the way out — the page moving twice around
      // the control somebody is pressing. It is held `invisible` under the
      // cover and `inert` with it, so the space is paid for once and there is
      // nothing to tab into while it cannot be seen.
      //
      // The rule is asserted rather than the pixels. The suite carries no
      // stylesheet, so `grid` does not apply and the cover stacks under the
      // content instead of sharing its cell — a height measured here would be
      // measuring the missing stylesheet. What holds without one is that the
      // row is in the document in both states.
      expect(row).toHaveClass('invisible');
      expect(row).toHaveAttribute('inert');

      await screen.getByRole('button', { name: 'Reveal' }).click();

      expect(row).not.toHaveClass('invisible');
      expect(row).not.toHaveAttribute('inert');
    });

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
