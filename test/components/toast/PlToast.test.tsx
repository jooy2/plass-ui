import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlToastProvider, usePlToast } from 'plass-ui';

/** A button that raises whatever it is handed, so a test can press it. */
function Raise({
  label = 'Raise',
  ...options
}: Parameters<ReturnType<typeof usePlToast>['add']>[0] & { label?: string }) {
  const toast = usePlToast();

  return (
    <button type="button" onClick={() => toast.add(options)}>
      {label}
    </button>
  );
}

/** The toast's × — see the note in "closing one" for why it is not a role query. */
function closeButton(): HTMLButtonElement {
  const button = document.querySelector<HTMLButtonElement>('[role="dialog"] [aria-label]');

  if (!button) {
    throw new Error('no close button on screen');
  }

  return button;
}

describe('PlToast', () => {
  describe('raising one', () => {
    it('shows nothing until something is raised', async () => {
      const screen = await render(
        <PlToastProvider>
          <Raise title="Saved" />
        </PlToastProvider>
      );

      expect(screen.getByText('Saved').query()).toBeNull();
    });

    it('shows the title and the description', async () => {
      const screen = await render(
        <PlToastProvider>
          <Raise title="Saved" description="Your changes are live." />
        </PlToastProvider>
      );

      await screen.getByRole('button', { name: 'Raise' }).click();

      await expect.element(screen.getByText('Saved')).toBeInTheDocument();
      await expect.element(screen.getByText('Your changes are live.')).toBeInTheDocument();
    });

    it('stacks two of them', async () => {
      const screen = await render(
        <PlToastProvider>
          <Raise label="First" title="One" />
          <Raise label="Second" title="Two" />
        </PlToastProvider>
      );

      await screen.getByRole('button', { name: 'First' }).click();
      await screen.getByRole('button', { name: 'Second' }).click();

      await expect.element(screen.getByText('One')).toBeInTheDocument();
      await expect.element(screen.getByText('Two')).toBeInTheDocument();
    });
  });

  describe('closing one', () => {
    it('draws a × that closes it', async () => {
      const screen = await render(
        <PlToastProvider>
          <Raise title="Saved" timeout={0} />
        </PlToastProvider>
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await expect.element(screen.getByText('Saved')).toBeInTheDocument();

      // Queried by attribute rather than by role: Base UI hides the × from the
      // accessibility tree, because a screen reader reaches a toast with F6 and
      // is given the close action there rather than as a stray button in the
      // page's tab order.
      closeButton().click();

      await expect.element(screen.getByText('Saved')).not.toBeInTheDocument();
    });

    it('takes a different name for that button', async () => {
      const screen = await render(
        <PlToastProvider closeLabel="닫기">
          <Raise title="Saved" timeout={0} />
        </PlToastProvider>
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await expect.element(screen.getByText('Saved')).toBeInTheDocument();

      expect(document.querySelector('[aria-label="닫기"]')).not.toBeNull();
    });

    it('dismisses itself once its timeout runs out', async () => {
      const screen = await render(
        <PlToastProvider timeout={80}>
          <Raise title="Saved" />
        </PlToastProvider>
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await expect.element(screen.getByText('Saved')).toBeInTheDocument();

      await expect.element(screen.getByText('Saved')).not.toBeInTheDocument();
    });
  });

  describe('the action', () => {
    it('is drawn only when a label is given, and calls back', async () => {
      const onAction = vi.fn();
      const screen = await render(
        <PlToastProvider>
          <Raise title="Deleted" timeout={0} actionLabel="Undo" onAction={onAction} />
        </PlToastProvider>
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await screen.getByRole('button', { name: 'Undo' }).click();

      expect(onAction).toHaveBeenCalledTimes(1);
    });

    it('is absent without one', async () => {
      const screen = await render(
        <PlToastProvider>
          <Raise title="Deleted" timeout={0} />
        </PlToastProvider>
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await expect.element(screen.getByText('Deleted')).toBeInTheDocument();

      expect(screen.getByRole('button', { name: 'Undo' }).query()).toBeNull();
    });
  });

  describe('the glyph', () => {
    it('draws the severity glyph for the toast’s own colour', async () => {
      const screen = await render(
        <PlToastProvider>
          <Raise title="Failed" timeout={0} color="danger" />
        </PlToastProvider>
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await expect.element(screen.getByText('Failed')).toBeInTheDocument();

      expect(document.querySelectorAll('[role="dialog"] svg').length).toBeGreaterThan(1);
    });

    it('draws none when `icon` is false', async () => {
      const screen = await render(
        <PlToastProvider>
          <Raise title="Quiet" timeout={0} icon={false} />
        </PlToastProvider>
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await expect.element(screen.getByText('Quiet')).toBeInTheDocument();

      // Only the close button's × is left.
      expect(document.querySelectorAll('[role="dialog"] svg')).toHaveLength(1);
    });
  });

  describe('updating one', () => {
    it('replaces a toast in place when the id is reused', async () => {
      function Flow() {
        const toast = usePlToast();

        return (
          <button
            type="button"
            onClick={() => {
              toast.add({ id: 'upload', title: 'Uploading', timeout: 0 });
              toast.update('upload', { id: 'upload', title: 'Uploaded', timeout: 0 });
            }}
          >
            Upload
          </button>
        );
      }

      const screen = await render(
        <PlToastProvider>
          <Flow />
        </PlToastProvider>
      );

      await screen.getByRole('button', { name: 'Upload' }).click();

      await expect.element(screen.getByText('Uploaded')).toBeInTheDocument();
      expect(screen.getByText('Uploading').query()).toBeNull();
    });
  });
});
