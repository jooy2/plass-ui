/**
 * A button *inside* the dialog is pressed with a plain DOM `click()` rather
 * than through the locator, for the reason `CLAUDE.md` records: a fully modal
 * Base UI dialog paints an inert overlay with inline `position: fixed; inset:
 * 0`, the `z-50` that would beat it is a class nothing loads in the test run,
 * and Playwright's actionability check therefore reports every one of those
 * buttons as covered. The dialog is genuinely modal here on purpose — that is
 * what a confirm dialog is — so the escape is on this side.
 *
 * The dialog itself is not what is under test; those tests are next door. What
 * is asserted here is the promise: that it resolves, with what, and when.
 */
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlConfirmProvider, usePlConfirm } from 'plass-ui';

/** A button that asks, and writes the answer where a test can read it. */
function Asker({
  answer,
  ...options
}: { answer: (value: unknown) => void } & Record<string, unknown>) {
  const { confirm } = usePlConfirm();

  return (
    <PlButton
      onClick={async () => {
        answer(await confirm({ title: 'Delete this project?', ...options }));
      }}
    >
      Delete
    </PlButton>
  );
}

/** A button inside the open dialog. See the note at the top of the file. */
function pressInDialog(name: string): void {
  const button = Array.from(
    document.querySelectorAll<HTMLButtonElement>('[role="dialog"] button')
  ).find((candidate) => candidate.textContent?.trim() === name);

  if (!button) {
    throw new Error(`no button named ${name} in the dialog`);
  }

  button.click();
}

describe('PlConfirmProvider', () => {
  describe('asking', () => {
    it('draws nothing until something asks', async () => {
      const screen = await render(
        <PlConfirmProvider>
          <Asker answer={() => {}} />
        </PlConfirmProvider>
      );

      expect(screen.getByRole('dialog').query()).toBeNull();
    });

    it('opens with the question it was given', async () => {
      const screen = await render(
        <PlConfirmProvider>
          <Asker answer={() => {}} description="Ten members lose access." />
        </PlConfirmProvider>
      );

      await screen.getByRole('button', { name: 'Delete' }).click();

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
      await expect.element(screen.getByText('Delete this project?')).toBeInTheDocument();
      await expect.element(screen.getByText('Ten members lose access.')).toBeInTheDocument();
    });

    it('draws two buttons, named', async () => {
      const screen = await render(
        <PlConfirmProvider>
          <Asker answer={() => {}} confirmLabel="Delete it" cancelLabel="Keep it" />
        </PlConfirmProvider>
      );

      await screen.getByRole('button', { name: 'Delete' }).click();

      await expect.element(screen.getByRole('button', { name: 'Delete it' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Keep it' })).toBeInTheDocument();
    });

    it('falls back to the provider’s labels', async () => {
      const screen = await render(
        <PlConfirmProvider confirmLabel="삭제" cancelLabel="취소">
          <Asker answer={() => {}} />
        </PlConfirmProvider>
      );

      await screen.getByRole('button', { name: 'Delete' }).click();

      await expect.element(screen.getByRole('button', { name: '삭제' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: '취소' })).toBeInTheDocument();
    });
  });

  describe('the answer', () => {
    it('resolves true when the question is confirmed', async () => {
      const answer = vi.fn();

      const screen = await render(
        <PlConfirmProvider>
          <Asker answer={answer} confirmLabel="Delete it" />
        </PlConfirmProvider>
      );

      await screen.getByRole('button', { name: 'Delete' }).click();
      pressInDialog('Delete it');

      await expect.poll(() => answer.mock.calls).toEqual([[true]]);
    });

    it('resolves false when it is cancelled', async () => {
      const answer = vi.fn();

      const screen = await render(
        <PlConfirmProvider>
          <Asker answer={answer} cancelLabel="Keep it" />
        </PlConfirmProvider>
      );

      await screen.getByRole('button', { name: 'Delete' }).click();
      pressInDialog('Keep it');

      await expect.poll(() => answer.mock.calls).toEqual([[false]]);
    });

    it('resolves false on Escape', async () => {
      const answer = vi.fn();

      const screen = await render(
        <PlConfirmProvider>
          <Asker answer={answer} />
        </PlConfirmProvider>
      );

      await screen.getByRole('button', { name: 'Delete' }).click();
      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();

      document.activeElement?.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'Escape', bubbles: true, cancelable: true })
      );

      await expect.poll(() => answer.mock.calls).toEqual([[false]]);
    });

    it('closes once it has been answered', async () => {
      const screen = await render(
        <PlConfirmProvider>
          <Asker answer={() => {}} confirmLabel="Delete it" />
        </PlConfirmProvider>
      );

      await screen.getByRole('button', { name: 'Delete' }).click();
      pressInDialog('Delete it');

      await expect.poll(() => screen.getByRole('dialog').query()).toBeNull();
    });
  });

  describe('a question asked while one is open', () => {
    it('is queued rather than dropped', async () => {
      const answers: unknown[] = [];

      function Two() {
        const { confirm } = usePlConfirm();

        return (
          <PlButton
            onClick={() => {
              // Both are asked in the same tick, so the second lands while the
              // first is up. A dropped promise here is a button that spins for
              // the rest of the session.
              void confirm({ title: 'First?', confirmLabel: 'Yes' }).then((v) => answers.push(v));
              void confirm({ title: 'Second?', confirmLabel: 'Yes' }).then((v) => answers.push(v));
            }}
          >
            Ask twice
          </PlButton>
        );
      }

      const screen = await render(
        <PlConfirmProvider>
          <Two />
        </PlConfirmProvider>
      );

      await screen.getByRole('button', { name: 'Ask twice' }).click();

      await expect.element(screen.getByText('First?')).toBeInTheDocument();

      pressInDialog('Yes');

      await expect.element(screen.getByText('Second?')).toBeInTheDocument();

      pressInDialog('Yes');

      await expect.poll(() => answers).toEqual([true, true]);
    });
  });

  describe('alert', () => {
    it('draws one button and resolves when it is pressed', async () => {
      const done = vi.fn();

      function Teller() {
        const { alert } = usePlConfirm();

        return (
          <PlButton
            onClick={async () => {
              await alert({ title: 'Your session expired.' });
              done();
            }}
          >
            Tell me
          </PlButton>
        );
      }

      const screen = await render(
        <PlConfirmProvider>
          <Teller />
        </PlConfirmProvider>
      );

      await screen.getByRole('button', { name: 'Tell me' }).click();

      await expect.element(screen.getByText('Your session expired.')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Cancel' }).query()).toBeNull();

      pressInDialog('OK');

      await expect.poll(() => done.mock.calls.length).toBe(1);
    });
  });

  describe('the focus', () => {
    it('lands on cancel by default', async () => {
      const screen = await render(
        <PlConfirmProvider>
          <Asker answer={() => {}} cancelLabel="Keep it" />
        </PlConfirmProvider>
      );

      await screen.getByRole('button', { name: 'Delete' }).click();

      // A confirm dialog exists to make somebody stop, and Enter landing on the
      // destructive action defeats it.
      await expect.poll(() => document.activeElement?.textContent).toBe('Keep it');
    });

    it('lands on confirm when it is asked to', async () => {
      const screen = await render(
        <PlConfirmProvider>
          <Asker answer={() => {}} confirmLabel="Save" initialFocus="confirm" />
        </PlConfirmProvider>
      );

      await screen.getByRole('button', { name: 'Delete' }).click();

      await expect.poll(() => document.activeElement?.textContent).toBe('Save');
    });
  });

  describe('outside a provider', () => {
    it('throws rather than quietly answering no', async () => {
      function Orphan() {
        usePlConfirm();

        return null;
      }

      // A silent `false` is a delete button that does nothing, which is worse
      // than a missing provider that says so on the first render.
      await expect(render(<Orphan />)).rejects.toThrow(/PlConfirmProvider/);
    });
  });
});
