import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlStep, PlStepper } from 'plass-ui';

/**
 * The three-step sign-up every test works against, as an **array** rather than
 * as a component that returns a fragment.
 *
 * That is not a stylistic choice: the stepper numbers its children by walking
 * them, so a component wrapping the steps is one child holding three, and every
 * step in it would be step one. An array is flattened by `Children.toArray` and
 * numbers correctly, which is also the rule a caller has to follow.
 */
const steps = [
  <PlStep key="account" label="Account" description="Email and password">
    Account panel
  </PlStep>,
  <PlStep key="verify" label="Verify">
    Verify panel
  </PlStep>,
  <PlStep key="profile" label="Profile" optional>
    Profile panel
  </PlStep>
];

const stepButtons = () =>
  Array.from(document.querySelectorAll<HTMLButtonElement>('li button')).map((b) =>
    b.textContent?.trim()
  );

/** Each step's label — the element the panel is named after. */
const labels = () =>
  Array.from(document.querySelectorAll<HTMLElement>('li [id]')).map((n) => n.textContent);

describe('PlStepper', () => {
  describe('rendering', () => {
    it('draws a list of steps', async () => {
      const screen = await render(<PlStepper>{steps}</PlStepper>);

      await expect.element(screen.getByRole('list')).toBeInTheDocument();
      expect(document.querySelectorAll('li')).toHaveLength(3);
    });

    it('names each step', async () => {
      await render(<PlStepper>{steps}</PlStepper>);

      // Read off the list rather than through a text locator: a step's bullet
      // is `aria-hidden` and sits in the same box as its label, so "Account" is
      // inside a button whose whole text is "1Account".
      expect(labels()).toEqual(['Account', 'Verify', 'Profile']);
    });

    it('draws a description under the label', async () => {
      const screen = await render(<PlStepper>{steps}</PlStepper>);

      await expect.element(screen.getByText('Email and password')).toBeInTheDocument();
    });

    it('numbers the steps it was not given bullets for', async () => {
      await render(<PlStepper active={0}>{steps}</PlStepper>);

      // The first is current and shows its number; the two ahead show theirs.
      expect(document.querySelectorAll('li')[1]!.textContent).toContain('2');
    });

    it('takes a bullet of its own', async () => {
      await render(
        <PlStepper>
          <PlStep label="Account" bullet="A" />
        </PlStepper>
      );

      // The bullet is `aria-hidden`, so it is read off the DOM rather than
      // through a locator that only sees the accessibility tree.
      expect(document.querySelector('li span[aria-hidden="true"]')!.textContent).toBe('A');
    });

    it('says which steps are optional', async () => {
      const screen = await render(<PlStepper>{steps}</PlStepper>);

      await expect.element(screen.getByText('Optional')).toBeInTheDocument();
    });

    it('takes its own word for optional', async () => {
      const screen = await render(
        <PlStepper>
          <PlStep label="Profile" optional="건너뛸 수 있음" />
        </PlStepper>
      );

      await expect.element(screen.getByText('건너뛸 수 있음')).toBeInTheDocument();
    });
  });

  describe('where the reader is', () => {
    it('marks the current step and only that one', async () => {
      await render(<PlStepper active={1}>{steps}</PlStepper>);

      const current = document.querySelectorAll('[aria-current="step"]');

      expect(current).toHaveLength(1);
      expect(current[0]!.textContent).toContain('Verify');
    });

    it('shows the current step’s panel', async () => {
      const screen = await render(<PlStepper active={1}>{steps}</PlStepper>);

      await expect.element(screen.getByText('Verify panel')).toBeInTheDocument();
      expect(screen.getByText('Account panel').query()).toBeNull();
    });

    it('names the panel after the step it belongs to', async () => {
      await render(<PlStepper active={1}>{steps}</PlStepper>);

      const panel = document.querySelector('[aria-labelledby]')!;
      const label = document.getElementById(panel.getAttribute('aria-labelledby')!)!;

      expect(label.textContent).toBe('Verify');
    });

    it('keeps its own place when nothing controls it', async () => {
      const screen = await render(<PlStepper defaultActive={0}>{steps}</PlStepper>);

      await screen.getByRole('button', { name: /Account/ }).click();

      await expect.element(screen.getByText('Account panel')).toBeInTheDocument();
    });

    it('does not move a controlled stepper on its own', async () => {
      const screen = await render(
        <PlStepper active={1} onActiveChange={() => {}} linear={false}>
          {steps}
        </PlStepper>
      );

      await screen.getByRole('button', { name: /Account/ }).click();

      await expect.element(screen.getByText('Verify panel')).toBeInTheDocument();
    });

    it('reports the step that was pressed', async () => {
      const onActiveChange = vi.fn();

      const screen = await render(
        <PlStepper active={2} onActiveChange={onActiveChange}>
          {steps}
        </PlStepper>
      );

      await screen.getByRole('button', { name: /Account/ }).click();

      expect(onActiveChange).toHaveBeenCalledWith(0);
    });
  });

  describe('linear', () => {
    it('leaves the steps ahead out of reach', async () => {
      await render(<PlStepper active={0}>{steps}</PlStepper>);

      // Only the current one is a button; a step nobody has reached yet is not
      // something to press.
      expect(stepButtons()).toHaveLength(1);
    });

    it('keeps the steps behind reachable', async () => {
      await render(<PlStepper active={2}>{steps}</PlStepper>);

      // Going back to correct an answer is the whole reason a stepper is not a
      // wizard with one door.
      expect(stepButtons()).toHaveLength(3);
    });

    it('opens every step when it is turned off', async () => {
      await render(
        <PlStepper active={0} linear={false}>
          {steps}
        </PlStepper>
      );

      expect(stepButtons()).toHaveLength(3);
    });

    it('never reaches a disabled step', async () => {
      await render(
        <PlStepper active={2} linear={false}>
          <PlStep label="Account" />
          <PlStep label="Verify" disabled />
          <PlStep label="Profile" />
        </PlStepper>
      );

      // The first step is complete, so its bullet is a tick and not a number.
      expect(stepButtons()).toEqual(['Account', '3Profile']);
    });
  });

  describe('status', () => {
    it('ticks a step the reader is past', async () => {
      await render(<PlStepper active={2}>{steps}</PlStepper>);

      // A number is replaced by a tick once the step is behind: two axes for
      // the same fact, so a reader who cannot tell the colours apart still has
      // one.
      expect(document.querySelectorAll('li')[0]!.querySelector('svg')).toBeTruthy();
      expect(document.querySelectorAll('li')[2]!.querySelector('svg')).toBeNull();
    });

    it('takes an overriding status', async () => {
      await render(
        <PlStepper active={2}>
          <PlStep label="Account" status="upcoming" />
          <PlStep label="Verify" />
          <PlStep label="Profile" />
        </PlStepper>
      );

      // The step that failed validation while the reader moved on.
      expect(document.querySelectorAll('li')[0]!.querySelector('svg')).toBeNull();
    });
  });

  describe('orientation', () => {
    it('puts a vertical step’s panel inside the step', async () => {
      await render(
        <PlStepper orientation="vertical" active={1}>
          {steps}
        </PlStepper>
      );

      const second = document.querySelectorAll('li')[1]!;

      // The answer sits under the question rather than under the whole rail,
      // which is the reason to lay one out vertically at all.
      expect(second.textContent).toContain('Verify panel');
    });

    it('puts a horizontal step’s panel under the rail', async () => {
      await render(
        <PlStepper orientation="horizontal" active={1}>
          {steps}
        </PlStepper>
      );

      expect(document.querySelectorAll('li')[1]!.textContent).not.toContain('Verify panel');
      expect(document.querySelector('[aria-labelledby]')!.textContent).toBe('Verify panel');
    });
  });

  describe('caller styling', () => {
    it('keeps a caller-supplied class alongside its own', async () => {
      await render(<PlStepper className="my-own-class">{steps}</PlStepper>);

      expect(document.querySelector('.my-own-class')).toHaveClass('flex');
    });
  });
});
