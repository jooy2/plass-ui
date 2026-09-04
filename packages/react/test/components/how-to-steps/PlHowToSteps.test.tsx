import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlHowToStep, PlHowToSteps } from 'plass-ui';

function guide(): HTMLElement {
  return document.querySelector<HTMLElement>('.guide-under-test')!;
}

function steps(): HTMLElement[] {
  return Array.from(guide().querySelectorAll<HTMLElement>(':scope > li'));
}

/** What each step's disc says. */
function bullets(): string[] {
  return steps().map((step) => step.querySelector('span')!.textContent ?? '');
}

function Guide(props: React.ComponentProps<typeof PlHowToSteps> = {}) {
  return (
    <PlHowToSteps className="guide-under-test" {...props}>
      <PlHowToStep title="Install the CLI">Run npm install.</PlHowToStep>
      <PlHowToStep title="Sign in">Run plass login.</PlHowToStep>
      <PlHowToStep title="Deploy">Run plass deploy.</PlHowToStep>
    </PlHowToSteps>
  );
}

describe('PlHowToSteps', () => {
  describe('the list', () => {
    it('is a real ordered list of items', async () => {
      await render(<Guide />);

      // The numbers a reader sees are the ones the list carries, so a screen
      // reader announces the position without a heading per step.
      expect(guide().tagName).toBe('OL');
      expect(steps().length).toBe(3);
    });

    it('numbers the steps as it walks them', async () => {
      await render(<Guide />);

      expect(bullets()).toEqual(['1', '2', '3']);
    });

    it('does not number a step that rendered nothing', async () => {
      const missing = false;

      await render(
        <PlHowToSteps className="guide-under-test">
          <PlHowToStep title="One">First</PlHowToStep>
          {missing ? <PlHowToStep title="Skipped">Never</PlHowToStep> : null}
          <PlHowToStep title="Two">Second</PlHowToStep>
        </PlHowToSteps>
      );

      // A conditional step that drew nothing must not take a number with it.
      expect(bullets()).toEqual(['1', '2']);
    });

    it('stops numbering when it was told to', async () => {
      await render(<Guide numbered={false} />);

      expect(bullets()).toEqual(['', '', '']);
    });

    it('takes a glyph in place of a number, keeping the place in the order', async () => {
      await render(
        <PlHowToSteps className="guide-under-test">
          <PlHowToStep title="One">First</PlHowToStep>
          <PlHowToStep title="Two" icon={<svg viewBox="0 0 16 16" />}>
            Second
          </PlHowToStep>
          <PlHowToStep title="Three">Third</PlHowToStep>
        </PlHowToSteps>
      );

      expect(bullets()[0]).toBe('1');
      expect(steps()[1].querySelector('svg')).not.toBeNull();
      expect(bullets()[2]).toBe('3');
    });
  });

  describe('the body', () => {
    it('is open on every step at once', async () => {
      const screen = await render(<Guide />);

      // Somebody following instructions reads ahead and goes back a step, which
      // is the whole difference from a stepper.
      await expect.element(screen.getByText('Run npm install.')).toBeInTheDocument();
      await expect.element(screen.getByText('Run plass login.')).toBeInTheDocument();
      await expect.element(screen.getByText('Run plass deploy.')).toBeInTheDocument();
    });
  });

  describe('active', () => {
    it('marks nothing current when it was not given one', async () => {
      await render(<Guide />);

      // A guide that claimed to know how far a reader had got would be guessing.
      expect(guide().querySelector('[aria-current]')).toBeNull();
    });

    it('marks the step it names and nothing else', async () => {
      await render(<Guide active={1} />);

      expect(steps().map((step) => step.getAttribute('aria-current'))).toEqual([
        null,
        'step',
        null
      ]);
    });

    it('lets a step say for itself', async () => {
      await render(
        <PlHowToSteps className="guide-under-test">
          <PlHowToStep title="One" status="complete">
            First
          </PlHowToStep>
          <PlHowToStep title="Two">Second</PlHowToStep>
        </PlHowToSteps>
      );

      expect(steps()[0].querySelector('span')!.className).toContain(
        '[background-image:var(--p-fill)]'
      );
    });
  });

  describe('the connector', () => {
    it('draws a line after every step but the last', async () => {
      await render(<Guide />);

      // A connector belongs to the step it leaves, and the last one has nothing
      // to leave for.
      expect(steps().map((step) => step.querySelectorAll('span.border-s-2').length)).toEqual([
        1, 1, 0
      ]);
    });

    it('draws none at all when it was asked for none', async () => {
      await render(<Guide connector="none" />);

      expect(steps().map((step) => step.querySelectorAll('span.border-s-2').length)).toEqual([
        0, 0, 0
      ]);
    });
  });

  it('refuses a step outside a guide, rather than drawing a broken one', async () => {
    // The number is the guide's, so a step on its own has nothing to be.
    await expect(render(<PlHowToStep title="Alone">Nothing</PlHowToStep>)).rejects.toThrow();
  });
});
