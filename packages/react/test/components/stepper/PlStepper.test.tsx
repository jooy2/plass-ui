import { act, useState } from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { describe, expect, it, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlStep, PlStepper, type PlStepperProps } from 'plass-ui';

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
      const screen = await render(<PlStepper active={1}>{steps}</PlStepper>);

      // A group, because a name on an element with no role is never read.
      await expect
        .element(screen.getByRole('group', { name: 'Verify' }))
        .toHaveTextContent('Verify panel');
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

    for (const orientation of ['horizontal', 'vertical'] as const) {
      it(`builds the next step’s panel afresh (${orientation})`, async () => {
        const screen = await render(
          <PlStepper orientation={orientation} linear={false}>
            <PlStep label="Account">
              <input aria-label="Email" />
            </PlStep>
            <PlStep label="Verify">
              <input aria-label="Code" />
            </PlStep>
          </PlStepper>
        );

        await screen.getByRole('textbox', { name: 'Email' }).fill('abc');
        await screen.getByRole('button', { name: /Verify/ }).click();

        // A field of its own, not the last step's under a new name with what
        // was typed into it still there.
        await expect.element(screen.getByRole('textbox', { name: 'Code' })).toHaveValue('');
        await expect
          .element(screen.getByRole('group', { name: 'Verify' }))
          .toContainElement(screen.getByRole('textbox', { name: 'Code' }).element() as HTMLElement);
      });
    }
  });

  describe('the focus', () => {
    /**
     * A sign-up driven by a Next button inside each panel, which is where a
     * reader moving on from the keyboard is when the step changes.
     */
    function Driven(props: Omit<PlStepperProps, 'active' | 'onActiveChange'>) {
      const [active, setActive] = useState(0);
      const next = (
        <button type="button" onClick={() => setActive((step) => step + 1)}>
          Next
        </button>
      );

      return (
        <PlStepper active={active} onActiveChange={setActive} {...props}>
          <PlStep label="Account">
            <input aria-label="Email" />
            {next}
          </PlStep>
          <PlStep label="Verify">
            <input aria-label="Code" />
            {next}
          </PlStep>
          <PlStep label="Profile">Done</PlStep>
        </PlStepper>
      );
    }

    for (const orientation of ['horizontal', 'vertical'] as const) {
      for (const keepMounted of [false, true]) {
        const name = `${orientation}${keepMounted ? ', keepMounted' : ''}`;

        it(`follows the reader into the next step's panel from the last one (${name})`, async () => {
          const screen = await render(
            <Driven orientation={orientation} keepMounted={keepMounted} />
          );
          const next = screen.getByRole('button', { name: 'Next' });

          (next.element() as HTMLElement).focus();
          await expect.element(next).toHaveFocus();
          await userEvent.keyboard('{Enter}');

          // The panel itself, named by its step, rather than the page's body.
          await expect.element(screen.getByRole('group', { name: 'Verify' })).toHaveFocus();

          await userEvent.tab();

          await expect.element(screen.getByRole('textbox', { name: 'Code' })).toHaveFocus();
        });

        it(`puts the focus on the step it moved to when that step has no panel (${name})`, async () => {
          function ToReview() {
            const [active, setActive] = useState(0);

            return (
              <PlStepper
                active={active}
                onActiveChange={setActive}
                orientation={orientation}
                keepMounted={keepMounted}
              >
                <PlStep label="Account">
                  <input aria-label="Email" />
                  <button type="button" onClick={() => setActive(1)}>
                    Next
                  </button>
                </PlStep>
                <PlStep label="Review" />
                <PlStep label="Done">Done panel</PlStep>
              </PlStepper>
            );
          }

          const screen = await render(<ToReview />);
          const next = screen.getByRole('button', { name: 'Next' });

          (next.element() as HTMLElement).focus();
          await expect.element(next).toHaveFocus();
          await userEvent.keyboard('{Enter}');

          // The step a reader would Tab to for it, rather than the page's body.
          const review = screen.getByRole('button', { name: /Review/ });

          await expect.element(review).toHaveFocus();
          await expect.element(review).toHaveAttribute('aria-current', 'step');
        });

        it(`leaves the focus on a step that was pressed (${name})`, async () => {
          const screen = await render(
            <Driven orientation={orientation} keepMounted={keepMounted} linear={false} />
          );
          const verify = screen.getByRole('button', { name: /Verify/ });

          (verify.element() as HTMLElement).focus();
          await expect.element(verify).toHaveFocus();
          await userEvent.keyboard('{Enter}');

          await expect.element(screen.getByRole('group', { name: 'Verify' })).toBeVisible();
          await expect.element(verify).toHaveFocus();
        });
      }
    }

    it('keeps the panel out of the Tab order and draws no ring round it', async () => {
      const screen = await render(<Driven />);
      const panel = screen.getByRole('group', { name: 'Account' }).element();

      expect(panel).toHaveAttribute('tabindex', '-1');
      expect(panel).toHaveClass('outline-none');
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

    it('leaves a vertical panel to `active`, whatever `status` says', async () => {
      await render(
        <PlStepper orientation="vertical" active={2} linear={false}>
          <PlStep label="Account">Account panel</PlStep>
          <PlStep label="Verify" status="current">
            Verify panel
          </PlStep>
          <PlStep label="Profile" status="complete">
            Profile panel
          </PlStep>
        </PlStepper>
      );

      const items = document.querySelectorAll('li');

      // A step marked `current` again behind the reader opens no panel, and the
      // step the reader is on keeps its own, whatever it is marked.
      expect(items[1]!.textContent).not.toContain('Verify panel');
      expect(items[2]!.textContent).toContain('Profile panel');
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

    it('names a vertical panel after the step it sits in', async () => {
      const screen = await render(
        <PlStepper orientation="vertical" active={1}>
          {steps}
        </PlStepper>
      );

      await expect
        .element(screen.getByRole('group', { name: 'Verify' }))
        .toHaveTextContent('Verify panel');
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

  describe('keepMounted', () => {
    /** A sign-up whose every panel holds something a reader could focus. */
    const signUp = (props: PlStepperProps) => (
      <PlStepper linear={false} {...props}>
        <PlStep label="Account">
          <input aria-label="Email" />
        </PlStep>
        <PlStep label="Verify">
          <button type="button">Send the code</button>
        </PlStep>
        <PlStep label="Profile">
          <a href="/privacy">Privacy policy</a>
        </PlStep>
      </PlStepper>
    );

    /** Renders on a "server", puts the HTML in a host and hydrates it there. */
    async function hydrated(tree: React.ReactElement) {
      const html = renderToString(tree);
      const host = document.createElement('div');
      const onRecoverableError = vi.fn();

      host.innerHTML = html;
      document.body.append(host);

      const root = await act(async () => hydrateRoot(host, tree, { onRecoverableError }));

      return {
        html,
        onRecoverableError,
        async unmount() {
          await act(async () => root.unmount());
          host.remove();
        }
      };
    }

    for (const orientation of ['horizontal', 'vertical'] as const) {
      it(`sends only the panel of the step it is on without it (${orientation})`, () => {
        const html = renderToString(signUp({ orientation, active: 1 }));

        expect(html).toContain('Send the code');
        expect(html).not.toContain('Email');
        expect(html).not.toContain('Privacy policy');
      });

      it(`sends every step's panel with it, and hydrates them (${orientation})`, async () => {
        const { html, onRecoverableError, unmount } = await hydrated(
          signUp({ orientation, active: 1, keepMounted: true })
        );

        try {
          // What a search engine reads: every step's panel, not only this one.
          expect(html).toContain('Email');
          expect(html).toContain('Send the code');
          expect(html).toContain('Privacy policy');
          expect(onRecoverableError).not.toHaveBeenCalled();
        } finally {
          await unmount();
        }
      });

      it(`keeps the other panels out of reach (${orientation})`, async () => {
        const screen = await render(signUp({ orientation, active: 1, keepMounted: true }));

        const email = document.querySelector<HTMLInputElement>('input[aria-label="Email"]')!;
        const link = document.querySelector<HTMLAnchorElement>('a[href="/privacy"]')!;

        // In the document, and in nothing a reader reaches: not on screen, not
        // on the accessibility tree, and not something the focus can land on.
        expect(email.closest('[hidden]')).not.toBeNull();
        expect(link.closest('[hidden]')).not.toBeNull();
        expect(screen.getByRole('textbox', { name: 'Email' }).query()).toBeNull();
        expect(screen.getByRole('link', { name: 'Privacy policy' }).query()).toBeNull();
        expect(screen.getByRole('group').elements()).toHaveLength(1);

        email.focus();
        expect(document.activeElement).not.toBe(email);

        await expect
          .element(screen.getByRole('group', { name: 'Verify' }))
          .toHaveTextContent('Send the code');
        await expect.element(screen.getByRole('button', { name: 'Send the code' })).toBeVisible();
      });

      it(`names every kept panel after its own step (${orientation})`, async () => {
        await render(signUp({ orientation, active: 1, keepMounted: true }));

        const names = Array.from(
          document.querySelectorAll<HTMLElement>('[role="group"][aria-labelledby]')
        ).map(
          (group) => document.getElementById(group.getAttribute('aria-labelledby')!)?.textContent
        );

        expect(names).toEqual(['Account', 'Verify', 'Profile']);
      });

      it(`shows a kept panel when the reader reaches it, with what it held (${orientation})`, async () => {
        const screen = await render(signUp({ orientation, defaultActive: 0, keepMounted: true }));

        await screen.getByRole('textbox', { name: 'Email' }).fill('reader@example.com');
        await screen.getByRole('button', { name: /Verify/ }).click();

        await expect.element(screen.getByRole('button', { name: 'Send the code' })).toBeVisible();
        expect(screen.getByRole('textbox', { name: 'Email' }).query()).toBeNull();

        await screen.getByRole('button', { name: /Account/ }).click();

        // The same field, not a new one: what it held is still in it.
        await expect
          .element(screen.getByRole('textbox', { name: 'Email' }))
          .toHaveValue('reader@example.com');
      });
    }
  });

  describe('caller styling', () => {
    it('keeps a caller-supplied class alongside its own', async () => {
      await render(<PlStepper className="my-own-class">{steps}</PlStepper>);

      expect(document.querySelector('.my-own-class')).toHaveClass('flex');
    });
  });
});
