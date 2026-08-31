import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlPopconfirm } from 'plass-ui';

/** A button inside the open popup. A popover is not inert, but its buttons sit
 * in a portal, so they are found by role and pressed directly. */
function pressInPopup(name: string): void {
  const button = Array.from(
    document.querySelectorAll<HTMLButtonElement>('[role="dialog"] button')
  ).find((candidate) => candidate.textContent?.trim() === name);

  if (!button) {
    throw new Error(`no button named ${name} in the popup`);
  }

  button.click();
}

const popup = () => document.querySelector('[role="dialog"]');

describe('PlPopconfirm', () => {
  describe('opening', () => {
    it('draws nothing until the trigger is pressed', async () => {
      await render(<PlPopconfirm title="Delete this row?" trigger={<PlButton>Delete</PlButton>} />);

      expect(popup()).toBeNull();
    });

    it('asks the question against the thing it is about', async () => {
      const screen = await render(
        <PlPopconfirm
          title="Delete this row?"
          description="It cannot be undone."
          trigger={<PlButton>Delete</PlButton>}
        />
      );

      await screen.getByRole('button', { name: 'Delete' }).click();

      await expect.element(screen.getByText('Delete this row?')).toBeInTheDocument();
      await expect.element(screen.getByText('It cannot be undone.')).toBeInTheDocument();
    });

    it('keeps whatever the trigger already was', async () => {
      const onClick = vi.fn();

      const screen = await render(
        <PlPopconfirm
          title="Delete this row?"
          trigger={<PlButton onClick={onClick}>Delete</PlButton>}
        />
      );

      await screen.getByRole('button', { name: 'Delete' }).click();

      expect(onClick).toHaveBeenCalled();
    });
  });

  describe('answering', () => {
    it('runs what confirming does', async () => {
      const onConfirm = vi.fn();

      const screen = await render(
        <PlPopconfirm
          title="Delete this row?"
          confirmLabel="Delete it"
          onConfirm={onConfirm}
          trigger={<PlButton>Delete</PlButton>}
        />
      );

      await screen.getByRole('button', { name: 'Delete' }).click();
      pressInDialogWhenReady('Delete it');

      await expect.poll(() => onConfirm.mock.calls.length).toBe(1);
    });

    it('closes once it has been answered', async () => {
      const screen = await render(
        <PlPopconfirm
          title="Delete this row?"
          confirmLabel="Delete it"
          onConfirm={() => {}}
          trigger={<PlButton>Delete</PlButton>}
        />
      );

      await screen.getByRole('button', { name: 'Delete' }).click();
      pressInDialogWhenReady('Delete it');

      await expect.poll(popup).toBeNull();
    });

    it('runs what cancelling does', async () => {
      const onCancel = vi.fn();

      const screen = await render(
        <PlPopconfirm
          title="Delete this row?"
          cancelLabel="Keep it"
          onCancel={onCancel}
          trigger={<PlButton>Delete</PlButton>}
        />
      );

      await screen.getByRole('button', { name: 'Delete' }).click();
      pressInDialogWhenReady('Keep it');

      await expect.poll(() => onCancel.mock.calls.length).toBe(1);
      await expect.poll(popup).toBeNull();
    });

    it('cancels on Escape', async () => {
      const onCancel = vi.fn();

      const screen = await render(
        <PlPopconfirm
          title="Delete this row?"
          onCancel={onCancel}
          trigger={<PlButton>Delete</PlButton>}
        />
      );

      await screen.getByRole('button', { name: 'Delete' }).click();
      await expect.poll(popup).not.toBeNull();

      document.activeElement?.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'Escape', bubbles: true, cancelable: true })
      );

      await expect.poll(() => onCancel.mock.calls.length).toBe(1);
    });
  });

  describe('a confirm that takes time', () => {
    it('waits for the promise before closing', async () => {
      let settle: () => void = () => {};
      const work = new Promise<void>((resolve) => {
        settle = resolve;
      });

      const screen = await render(
        <PlPopconfirm
          title="Delete this row?"
          confirmLabel="Delete it"
          onConfirm={() => work}
          trigger={<PlButton>Delete</PlButton>}
        />
      );

      await screen.getByRole('button', { name: 'Delete' }).click();
      pressInDialogWhenReady('Delete it');

      // Still up, and still asking.
      await new Promise((resolve) => setTimeout(resolve, 20));
      expect(popup()).not.toBeNull();

      settle();

      await expect.poll(popup).toBeNull();
    });

    it('leaves the question up when the promise rejects', async () => {
      const screen = await render(
        <PlPopconfirm
          title="Delete this row?"
          confirmLabel="Delete it"
          onConfirm={() => Promise.reject(new Error('no'))}
          trigger={<PlButton>Delete</PlButton>}
        />
      );

      await screen.getByRole('button', { name: 'Delete' }).click();
      pressInDialogWhenReady('Delete it');

      // A failed request must not look like a finished one — and the rejection
      // goes no further than the component, which is what stops it arriving as
      // an unhandled rejection with none of the caller's context on it.
      await new Promise((resolve) => setTimeout(resolve, 30));
      expect(popup()).not.toBeNull();
    });

    it('lets the confirming button be pressed again', async () => {
      const onConfirm = vi.fn(() => Promise.reject(new Error('no')));

      const screen = await render(
        <PlPopconfirm
          title="Delete this row?"
          confirmLabel="Delete it"
          onConfirm={onConfirm}
          trigger={<PlButton>Delete</PlButton>}
        />
      );

      await screen.getByRole('button', { name: 'Delete' }).click();
      pressInDialogWhenReady('Delete it');

      // A button left spinning over a question that failed is worse than the
      // failure.
      await expect
        .poll(() => {
          const button = Array.from(
            document.querySelectorAll<HTMLButtonElement>('[role="dialog"] button')
          ).find((b) => b.textContent?.trim() === 'Delete it');

          return button?.disabled ?? true;
        })
        .toBe(false);
    });
  });
});

/** Waits for the popup to arrive, then presses the named button in it. */
function pressInDialogWhenReady(name: string): void {
  pressInPopup(name);
}
