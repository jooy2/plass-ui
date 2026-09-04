import { userEvent } from 'vitest/browser';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlHoverCard, PlTextLink } from 'plass-ui';

/** The card, wherever in the document it was portalled to. */
function card(): HTMLElement | null {
  return document.querySelector<HTMLElement>('.card-under-test');
}

function Subject(props: Partial<React.ComponentProps<typeof PlHoverCard>> = {}) {
  return (
    <PlHoverCard
      className="card-under-test"
      trigger={<PlTextLink href="#ada">Ada Lovelace</PlTextLink>}
      title="Ada Lovelace"
      description="Mathematician"
      delay={0}
      closeDelay={0}
      {...props}
    >
      <p>Wrote the first algorithm intended for a machine.</p>
    </PlHoverCard>
  );
}

describe('PlHoverCard', () => {
  it('draws nothing until the pointer rests on the trigger', async () => {
    await render(<Subject />);

    expect(card()).toBeNull();
  });

  it('opens on the pointer and closes when it leaves', async () => {
    const screen = await render(<Subject />);

    await userEvent.hover(screen.getByRole('link'));

    await expect.poll(() => card()).not.toBeNull();
    expect(card()!.textContent).toContain('Mathematician');

    await userEvent.unhover(screen.getByRole('link'));

    await expect.poll(() => card()).toBeNull();
  });

  it('opens on keyboard focus too, which is the half a pointer cannot reach', async () => {
    const screen = await render(<Subject />);

    await userEvent.keyboard('{Tab}');

    await expect.poll(() => document.activeElement).toBe(screen.getByRole('link').element());
    await expect.poll(() => card()).not.toBeNull();
  });

  it('closes on Escape', async () => {
    const screen = await render(<Subject />);

    await userEvent.hover(screen.getByRole('link'));
    await expect.poll(() => card()).not.toBeNull();

    await userEvent.keyboard('{Escape}');

    await expect.poll(() => card()).toBeNull();
  });

  it('reports every change through `onOpenChange`', async () => {
    const onOpenChange = vi.fn();
    const screen = await render(<Subject onOpenChange={onOpenChange} />);

    await userEvent.hover(screen.getByRole('link'));

    await expect.poll(() => onOpenChange).toHaveBeenCalledWith(true);
  });

  it('takes an open state from outside', async () => {
    await render(<Subject open />);

    await expect.poll(() => card()).not.toBeNull();
  });

  it('leaves the trigger exactly as it was written', async () => {
    const screen = await render(<Subject />);

    // A link stays a link: the trigger is rendered rather than wrapped, so the
    // href, the styling and the tab order are the caller's.
    await expect.element(screen.getByRole('link')).toHaveAttribute('href', '#ada');
  });

  it('holds the card open while the pointer is inside it', async () => {
    const screen = await render(<Subject closeDelay={0} />);

    await userEvent.hover(screen.getByRole('link'));
    await expect.poll(() => card()).not.toBeNull();

    // The whole reason it is not a tooltip: what is inside can be reached, so
    // moving onto the card must not close it.
    await userEvent.hover(card()!);

    await expect.poll(() => card()).not.toBeNull();
  });

  it('draws no wedge unless it was asked for one', async () => {
    const screen = await render(<Subject />);

    await userEvent.hover(screen.getByRole('link'));

    await expect.poll(() => card()).not.toBeNull();
    expect(card()!.querySelector('svg')).toBeNull();
  });

  it('draws one when it was', async () => {
    const screen = await render(<Subject arrow />);

    await userEvent.hover(screen.getByRole('link'));

    await expect.poll(() => card()?.querySelector('svg')).not.toBeNull();
  });
});
