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
import { renderToString } from 'react-dom/server';
import { describe, expect, it, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlButton, PlConfirmProvider, PlassProvider, usePlConfirm } from 'plass-ui';

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

/**
 * A button inside the open dialog. See the note at the top of the file.
 *
 * Waited for rather than read at once: the dialog is a chunk of its own, and a
 * question asked before it has arrived opens the dialog as soon as it does.
 */
async function pressInDialog(name: string): Promise<void> {
  const find = () =>
    Array.from(document.querySelectorAll<HTMLButtonElement>('[role="alertdialog"] button')).find(
      (candidate) => candidate.textContent?.trim() === name
    );

  await expect.poll(find, { message: `no button named ${name} in the dialog` }).toBeDefined();

  find()!.click();
}

describe('PlConfirmProvider', () => {
  describe('asking', () => {
    it('draws nothing until something asks', async () => {
      const screen = await render(
        <PlConfirmProvider>
          <Asker answer={() => {}} />
        </PlConfirmProvider>
      );

      expect(screen.getByRole('alertdialog').query()).toBeNull();
    });

    it('opens on the first question and takes the focus into the dialog', async () => {
      const screen = await render(
        <PlConfirmProvider>
          <Asker answer={() => {}} cancelLabel="Keep it" />
        </PlConfirmProvider>
      );

      // Nothing of the dialog is mounted before anything asks.
      expect(document.querySelector('.plass-portal')).toBeNull();

      await screen.getByRole('button', { name: 'Delete' }).click();

      await expect.element(screen.getByRole('alertdialog')).toBeInTheDocument();
      await expect.poll(() => document.activeElement?.textContent).toBe('Keep it');
    });

    it('fades the first question in, as it does every later one', async () => {
      let started = false;

      // `data-starting-style` is what the fade starts from. A dialog mounted
      // already open never carries it, so it would appear at full strength.
      const observer = new MutationObserver(() => {
        started ||= document.querySelector('[role="alertdialog"][data-starting-style]') !== null;
      });

      observer.observe(document.body, {
        subtree: true,
        childList: true,
        attributes: true,
        attributeFilter: ['data-starting-style']
      });

      try {
        const screen = await render(
          <PlConfirmProvider>
            <Asker answer={() => {}} />
          </PlConfirmProvider>
        );

        await screen.getByRole('button', { name: 'Delete' }).click();
        await expect.element(screen.getByRole('alertdialog')).toBeInTheDocument();

        expect(started).toBe(true);
      } finally {
        observer.disconnect();
      }
    });

    it('opens with the question it was given', async () => {
      const screen = await render(
        <PlConfirmProvider>
          <Asker answer={() => {}} description="Ten members lose access." />
        </PlConfirmProvider>
      );

      await screen.getByRole('button', { name: 'Delete' }).click();

      await expect.element(screen.getByRole('alertdialog')).toBeInTheDocument();
      await expect.element(screen.getByText('Delete this project?')).toBeInTheDocument();
      await expect.element(screen.getByText('Ten members lose access.')).toBeInTheDocument();
    });

    it('asks in an alert dialog named by its title and described by its description', async () => {
      // A dialog that breaks in and waits for an answer, which a screen reader
      // announces as an alert rather than as a plain dialog.
      const screen = await render(
        <PlConfirmProvider>
          <Asker answer={() => {}} description="Ten members lose access." />
        </PlConfirmProvider>
      );

      await screen.getByRole('button', { name: 'Delete' }).click();

      const question = screen.getByRole('alertdialog', { name: 'Delete this project?' });

      await expect.element(question).toBeInTheDocument();
      await expect.element(question).toHaveAccessibleDescription('Ten members lose access.');
      expect(screen.getByRole('dialog').query()).toBeNull();
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

    it('draws no close button beside its own two', async () => {
      const screen = await render(
        <PlConfirmProvider>
          <Asker answer={() => {}} confirmLabel="Delete it" cancelLabel="Keep it" />
        </PlConfirmProvider>
      );

      await screen.getByRole('button', { name: 'Delete' }).click();
      await expect.element(screen.getByRole('button', { name: 'Delete it' })).toBeInTheDocument();

      expect(screen.getByRole('button', { name: 'Close' }).query()).toBeNull();
      expect(
        Array.from(document.querySelectorAll('[role="alertdialog"] button'), (button) =>
          button.textContent?.trim()
        )
      ).toEqual(['Keep it', 'Delete it']);
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

  describe('the words', () => {
    it('takes cancel and confirm from the label pack', async () => {
      const screen = await render(
        <PlassProvider labels={{ cancel: '취소', confirm: '확인' }}>
          <PlConfirmProvider>
            <Asker answer={() => {}} />
          </PlConfirmProvider>
        </PlassProvider>
      );

      await screen.getByRole('button', { name: 'Delete' }).click();

      await expect.element(screen.getByRole('button', { name: '확인' })).toBeInTheDocument();
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
      await pressInDialog('Delete it');

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
      await pressInDialog('Keep it');

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
      await expect.element(screen.getByRole('alertdialog')).toBeInTheDocument();

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
      await pressInDialog('Delete it');

      await expect.poll(() => screen.getByRole('alertdialog').query()).toBeNull();
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

      await pressInDialog('Yes');

      await expect.element(screen.getByText('Second?')).toBeInTheDocument();

      await pressInDialog('Yes');

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

      await expect
        .element(screen.getByRole('alertdialog', { name: 'Your session expired.' }))
        .toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Cancel' }).query()).toBeNull();

      await pressInDialog('OK');

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

    it('lands again for the next question in the queue', async () => {
      function Two() {
        const { confirm } = usePlConfirm();

        return (
          <PlButton
            onClick={() => {
              void confirm({ title: 'Save first?', confirmLabel: 'Save', initialFocus: 'confirm' });
              void confirm({ title: 'Delete it?', confirmLabel: 'Delete', cancelLabel: 'Keep it' });
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
      await expect.poll(() => document.activeElement?.textContent).toBe('Save');

      // Answered from the keyboard, where the focus is. The dialog stays open
      // for the second question, and an Enter pressed twice must not approve a
      // delete the reader never saw the focus reach.
      (document.activeElement as HTMLButtonElement).click();

      await expect.element(screen.getByText('Delete it?')).toBeInTheDocument();
      await expect.poll(() => document.activeElement?.textContent).toBe('Keep it');
    });

    it.each(['confirm', 'cancel', 'Escape'] as const)(
      'goes back to the button that asked once it is answered by %s, every time',
      async (way) => {
        const answer = vi.fn();

        const screen = await render(
          <PlConfirmProvider>
            <Asker answer={answer} confirmLabel="Delete it" cancelLabel="Keep it" />
          </PlConfirmProvider>
        );
        const asker = screen.getByRole('button', { name: 'Delete' }).element() as HTMLElement;

        // Twice: the first question mounts the dialog, and the second finds it
        // already there.
        for (const round of [1, 2]) {
          // `click()` leaves the focus where `focus()` put it, as a press would.
          asker.focus();
          asker.click();

          await expect.poll(() => document.activeElement?.textContent).toBe('Keep it');

          if (way === 'Escape') {
            await userEvent.keyboard('{Escape}');
          } else {
            await pressInDialog(way === 'confirm' ? 'Delete it' : 'Keep it');
          }

          await expect.poll(() => answer.mock.calls.length).toBe(round);
          await expect.poll(() => screen.getByRole('alertdialog').query()).toBeNull();
          await expect.poll(() => document.activeElement).toBe(asker);
        }
      }
    );

    it('goes back to the button that asked once the last question in the queue is answered', async () => {
      function Two() {
        const { confirm } = usePlConfirm();

        return (
          <PlButton
            onClick={() => {
              void confirm({ title: 'Save first?', confirmLabel: 'Save', initialFocus: 'confirm' });
              void confirm({ title: 'Delete it?', confirmLabel: 'Delete', cancelLabel: 'Keep it' });
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
      const asker = screen.getByRole('button', { name: 'Ask twice' }).element() as HTMLElement;

      asker.focus();
      asker.click();

      await expect.poll(() => document.activeElement?.textContent).toBe('Save');
      (document.activeElement as HTMLButtonElement).click();

      await expect.element(screen.getByText('Delete it?')).toBeInTheDocument();
      await expect.poll(() => document.activeElement?.textContent).toBe('Keep it');
      (document.activeElement as HTMLButtonElement).click();

      await expect.poll(() => screen.getByRole('alertdialog').query()).toBeNull();
      await expect.poll(() => document.activeElement).toBe(asker);
    });

    it('lands on a question asked as soon as the last one is answered, and goes back after it', async () => {
      function Chain() {
        const { confirm } = usePlConfirm();

        return (
          <PlButton
            onClick={async () => {
              if (
                await confirm({
                  title: 'Save first?',
                  confirmLabel: 'Save',
                  initialFocus: 'confirm'
                })
              ) {
                await confirm({
                  title: 'Delete it?',
                  confirmLabel: 'Delete',
                  cancelLabel: 'Keep it'
                });
              }
            }}
          >
            Save and delete
          </PlButton>
        );
      }

      const screen = await render(
        <PlConfirmProvider>
          <Chain />
        </PlConfirmProvider>
      );
      const asker = screen
        .getByRole('button', { name: 'Save and delete' })
        .element() as HTMLElement;

      asker.focus();
      asker.click();

      await expect.poll(() => document.activeElement?.textContent).toBe('Save');
      (document.activeElement as HTMLButtonElement).click();

      // Asked before the dialog had closed, so it takes the place of the first
      // question in a dialog that stays open, as a queued one does.
      await expect.element(screen.getByText('Delete it?')).toBeInTheDocument();
      await expect.poll(() => document.activeElement?.textContent).toBe('Keep it');
      (document.activeElement as HTMLButtonElement).click();

      await expect.poll(() => screen.getByRole('alertdialog').query()).toBeNull();
      await expect.poll(() => document.activeElement).toBe(asker);
    });
  });

  describe('rendered on a server', () => {
    it('sends its children and nothing of the dialog', () => {
      const html = renderToString(
        <PlConfirmProvider>
          <p>The page</p>
        </PlConfirmProvider>
      );

      // No boundary for the dialog's chunk either: one that suspended on the
      // server would be `<!--$!-->` and rendered again in the browser.
      expect(html).toBe('<p>The page</p>');
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
