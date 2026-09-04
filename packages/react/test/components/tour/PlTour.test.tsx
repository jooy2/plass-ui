import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlTour, PlassProvider, type PlTourStep } from 'plass-ui';

/**
 * A page with three things on it, and a tour over them.
 *
 * `scrollIntoView` is off throughout: a smooth scroll moves the *runner's* own
 * window, and a test file that leaves the page scrolled hands the next one a
 * viewport it did not ask for.
 */
function Page({
  steps,
  ...props
}: { steps?: PlTourStep[] } & Omit<React.ComponentProps<typeof PlTour>, 'steps'>) {
  const filter = React.useRef<HTMLButtonElement>(null);

  return (
    <div>
      <button type="button" ref={filter}>
        Filter
      </button>
      <button type="button" id="export">
        Export
      </button>

      <PlTour
        scrollIntoView={false}
        steps={
          steps ?? [
            { target: filter, title: 'Narrow the list', content: 'Type here to filter.' },
            { target: '#export', title: 'Take it with you' },
            { title: 'That is everything' }
          ]
        }
        {...props}
      />
    </div>
  );
}

function mask(): HTMLElement | null {
  return document.querySelector('[data-testid="plass-tour-mask"]');
}

describe('PlTour', () => {
  describe('running', () => {
    it('draws nothing until it is opened', async () => {
      const screen = await render(<Page />);

      expect(screen.getByText('Narrow the list').elements()).toHaveLength(0);
      expect(mask()).toBeNull();
    });

    it('shows the first step when it starts open', async () => {
      const screen = await render(<Page defaultOpen />);

      await expect.element(screen.getByText('Narrow the list')).toBeInTheDocument();
      await expect.element(screen.getByText('Type here to filter.')).toBeInTheDocument();
    });

    it('renders nothing at all when it has no steps', async () => {
      const screen = await render(<Page defaultOpen steps={[]} />);

      expect(mask()).toBeNull();
      expect(screen.getByRole('dialog').elements()).toHaveLength(0);
    });
  });

  describe('stepping', () => {
    it('walks forward and back', async () => {
      const screen = await render(<Page defaultOpen />);

      await screen.getByRole('button', { name: 'Next' }).click();
      await expect.element(screen.getByText('Take it with you')).toBeInTheDocument();

      await screen.getByRole('button', { name: 'Previous' }).click();
      await expect.element(screen.getByText('Narrow the list')).toBeInTheDocument();
    });

    it('counts the steps rather than spelling them', async () => {
      // Two numbers, because "3 of 7" is a word order that differs by language
      // and the count itself does not.
      const screen = await render(<Page defaultOpen />);

      await expect.element(screen.getByText('1 / 3')).toBeInTheDocument();
    });

    it('offers no Previous on the first step', async () => {
      const screen = await render(<Page defaultOpen />);

      expect(screen.getByRole('button', { name: 'Previous' }).elements()).toHaveLength(0);
    });

    it('turns Next into Done on the last step, and finishes there', async () => {
      const onFinish = vi.fn();
      const screen = await render(<Page defaultOpen defaultStep={2} onFinish={onFinish} />);

      await screen.getByRole('button', { name: 'Done' }).click();

      expect(onFinish).toHaveBeenCalledOnce();
      expect(mask()).toBeNull();
    });

    it('reports the step and draws what it is told when it is controlled', async () => {
      const onStepChange = vi.fn();
      const screen = await render(<Page defaultOpen step={0} onStepChange={onStepChange} />);

      await screen.getByRole('button', { name: 'Next' }).click();

      expect(onStepChange).toHaveBeenCalledWith(1);
      // Still the first step: the position belongs to whoever passed it.
      await expect.element(screen.getByText('Narrow the list')).toBeInTheDocument();
    });

    it('clamps a step past the end onto the last one', async () => {
      const screen = await render(<Page defaultOpen defaultStep={9} />);

      await expect.element(screen.getByText('That is everything')).toBeInTheDocument();
    });
  });

  describe('leaving', () => {
    it('skips out of the tour', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(<Page defaultOpen onOpenChange={onOpenChange} />);

      await screen.getByRole('button', { name: 'Skip' }).click();

      expect(onOpenChange).toHaveBeenCalledWith(false);
      expect(mask()).toBeNull();
    });

    it('offers no Skip on the last step, where Done is the way out', async () => {
      const screen = await render(<Page defaultOpen defaultStep={2} />);

      expect(screen.getByRole('button', { name: 'Skip' }).elements()).toHaveLength(0);
    });

    it('leaves the Skip button out entirely when it was not asked for', async () => {
      const screen = await render(<Page defaultOpen skippable={false} />);

      expect(screen.getByRole('button', { name: 'Skip' }).elements()).toHaveLength(0);
    });

    it('closes on the × in the corner', async () => {
      const screen = await render(<Page defaultOpen />);

      await screen.getByRole('button', { name: 'Close' }).click();

      expect(mask()).toBeNull();
    });

    it('draws no × and ignores Escape when it cannot be dismissed', async () => {
      const screen = await render(<Page defaultOpen dismissible={false} />);

      expect(screen.getByRole('button', { name: 'Close' }).elements()).toHaveLength(0);

      await screen.getByRole('button', { name: 'Next' }).click();
      document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));

      await expect.element(screen.getByText('Take it with you')).toBeInTheDocument();
    });
  });

  describe('the mask', () => {
    it('dims the page and cuts the target out of the dimming', async () => {
      await render(<Page defaultOpen />);

      // Read back with the whitespace out: a browser normalises `M0,0H1000`
      // into `M 0 0 H 1000` on the way through the style property.
      const clip = mask()!.style.clipPath.replace(/[\s,]/g, '');

      // The viewport, and a second shape inside it. Even-odd is what turns the
      // second one into a hole rather than another filled rectangle.
      expect(clip).toContain('evenodd');
      expect(clip).toContain('M00H100000V100000H0Z');
      expect(clip.match(/M/g)!.length).toBeGreaterThan(1);
    });

    it('cuts nothing out of a step that is about the page rather than a control', async () => {
      await render(<Page defaultOpen defaultStep={2} />);

      // One shape: the viewport. A welcome step dims everything.
      expect(mask()!.style.clipPath.match(/M/g)).toHaveLength(1);
    });

    it('re-measures when the step changes', async () => {
      const screen = await render(<Page defaultOpen />);

      const before = mask()!.style.clipPath;

      await screen.getByRole('button', { name: 'Next' }).click();
      await expect.element(screen.getByText('Take it with you')).toBeInTheDocument();

      await expect.poll(() => mask()!.style.clipPath).not.toBe(before);
    });

    it('is the layer that takes the pointer, with the light clipped out of it', async () => {
      await render(<Page defaultOpen />);

      // Nothing loads Tailwind into the test run, so the classes are asserted
      // rather than the layout they produce. What they produce is the whole
      // claim of the component: a scrim over the viewport with the target
      // clipped out, and a clipped-away region is not hit tested — so the
      // control being pointed at answers and the dimmed page does not. The
      // shape itself is covered in `test/internal/tour.test.ts`.
      expect(mask()).toHaveClass('fixed');
      expect(mask()).toHaveClass('inset-0');
      expect(mask()!.style.clipPath).toContain('evenodd');
    });

    it('is portalled rather than left where the tour was written', async () => {
      await render(<Page defaultOpen />);

      // `position: fixed` is relative to the nearest ancestor with a transform,
      // a filter or a `backdrop-filter` — and a backdrop filter is what every
      // glass surface in this library is made of. A mask left in place would be
      // contained by whichever card the tour was written inside.
      const page = document.querySelector('button')!.parentElement!;

      expect(page.contains(mask())).toBe(false);
    });

    it('draws no dimming at all when it was not asked for', async () => {
      await render(<Page defaultOpen mask={false} />);

      expect(mask()).toBeNull();
    });

    it('is hidden from a screen reader, which the card is not', async () => {
      const screen = await render(<Page defaultOpen />);

      expect(mask()!.getAttribute('aria-hidden')).toBe('true');
      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });
  });

  describe('the card', () => {
    it('is named and described by the step it is showing', async () => {
      const screen = await render(<Page defaultOpen />);

      await expect
        .element(screen.getByRole('dialog', { name: 'Narrow the list' }))
        .toBeInTheDocument();
      // The description is the card's own `aria-describedby` target, so it is
      // read out after the name rather than being part of it.
      const card = document.querySelector('[role="dialog"]')!;
      const describedBy = card.getAttribute('aria-describedby');

      expect(document.getElementById(describedBy!)!.textContent).toBe('Type here to filter.');
    });

    it('takes its words from the labels in scope', async () => {
      const screen = await render(
        <PlassProvider labels={{ skip: '건너뛰기', next: '다음' }}>
          <Page defaultOpen />
        </PlassProvider>
      );

      await expect.element(screen.getByRole('button', { name: '다음' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: '건너뛰기' })).toBeInTheDocument();
    });

    it('still loses to a label written on the tour itself', async () => {
      const screen = await render(<Page defaultOpen nextLabel="Show me" />);

      await expect.element(screen.getByRole('button', { name: 'Show me' })).toBeInTheDocument();
    });
  });

  describe('the target', () => {
    it('finds one by selector', async () => {
      const screen = await render(<Page defaultOpen defaultStep={1} />);

      await expect.element(screen.getByText('Take it with you')).toBeInTheDocument();
      expect(mask()!.style.clipPath.match(/M/g)!.length).toBeGreaterThan(1);
    });

    it('finds one from a getter', async () => {
      const screen = await render(
        <Page
          defaultOpen
          steps={[
            {
              target: () => document.querySelector('#export'),
              title: 'Found by hand'
            }
          ]}
        />
      );

      await expect.element(screen.getByText('Found by hand')).toBeInTheDocument();
      expect(mask()!.style.clipPath.match(/M/g)!.length).toBeGreaterThan(1);
    });

    it('dims the whole page rather than breaking when the target is not there', async () => {
      const screen = await render(
        <Page defaultOpen steps={[{ target: '#nothing-here', title: 'Gone' }]} />
      );

      await expect.element(screen.getByText('Gone')).toBeInTheDocument();
      expect(mask()!.style.clipPath.match(/M/g)).toHaveLength(1);
    });
  });
});
