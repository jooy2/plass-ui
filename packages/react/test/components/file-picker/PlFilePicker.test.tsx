import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlFilePicker, formatFileSize } from 'plass-ui';

function file(name: string, type = 'text/plain', size = 1200): File {
  const blob = new File(['x'.repeat(size)], name, { type });

  return blob;
}

/**
 * Drops a batch on the zone, which is the one gesture a click cannot stand in
 * for.
 *
 * The event is dispatched on the browse button rather than on the wrapper,
 * because the drag listeners sit on the element *between* the two — an event
 * fired on an ancestor never reaches a descendant's handler.
 */
function drop(picker: string, files: File[]) {
  const target = document.querySelector(`${picker} button`) as Element;
  const dataTransfer = new DataTransfer();

  for (const item of files) {
    dataTransfer.items.add(item);
  }

  target.dispatchEvent(new DragEvent('drop', { bubbles: true, cancelable: true, dataTransfer }));
}

describe('PlFilePicker', () => {
  describe('rendering', () => {
    it('renders a browse button with the default line on it', async () => {
      const screen = await render(<PlFilePicker />);

      await expect
        .element(screen.getByRole('button', { name: /Drop files here/ }))
        .toBeInTheDocument();
    });

    it('renders the title, the hint, the label and the description', async () => {
      const screen = await render(
        <PlFilePicker
          label="Attachments"
          title="Drop a PDF"
          hint="Up to 5 MB"
          description="Invoices only."
        />
      );

      await expect.element(screen.getByText('Attachments')).toBeInTheDocument();
      await expect.element(screen.getByText('Drop a PDF')).toBeInTheDocument();
      await expect.element(screen.getByText('Up to 5 MB')).toBeInTheDocument();
      await expect.element(screen.getByText('Invoices only.')).toBeInTheDocument();
    });

    it('marks the zone invalid when there is an error', async () => {
      const screen = await render(<PlFilePicker error="Pick a file." />);

      expect(screen.getByRole('button').element()).toHaveAttribute('aria-invalid', 'true');
      await expect.element(screen.getByText('Pick a file.')).toBeInTheDocument();
    });

    it('keeps a real file input in the DOM rather than hiding it', async () => {
      await render(<PlFilePicker className="picker-under-test" accept="image/*" multiple />);
      const input = document.querySelector(
        '.picker-under-test input[type=file]'
      ) as HTMLInputElement;

      expect(input).not.toBeNull();
      expect(input).toHaveAttribute('accept', 'image/*');
      expect(input.multiple).toBe(true);
      // Off-screen, not `display: none` — the latter is unfocusable in some
      // browsers and would take it out of form validation.
      expect(getComputedStyle(input).display).not.toBe('none');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlFilePicker className="my-own-class" />);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });
  });

  describe('choosing files', () => {
    it('takes a dropped file and lists it', async () => {
      const onFilesChange = vi.fn();
      const screen = await render(
        <PlFilePicker className="picker-under-test" onFilesChange={onFilesChange} />
      );

      drop('.picker-under-test', [file('notes.txt')]);

      await expect.element(screen.getByText('notes.txt')).toBeInTheDocument();
      expect(onFilesChange).toHaveBeenCalledTimes(1);
    });

    it('replaces the held file when it is not `multiple`', async () => {
      const screen = await render(<PlFilePicker className="picker-under-test" />);
      drop('.picker-under-test', [file('first.txt')]);
      await expect.element(screen.getByText('first.txt')).toBeInTheDocument();

      drop('.picker-under-test', [file('second.txt')]);

      await expect.element(screen.getByText('second.txt')).toBeInTheDocument();
      expect(screen.getByText('first.txt').query()).toBeNull();
    });

    it('accumulates files when it is `multiple`', async () => {
      const screen = await render(<PlFilePicker className="picker-under-test" multiple />);
      drop('.picker-under-test', [file('a.txt')]);
      // Waited on: the second drop reads the list the first one produced, and
      // two drops in the same tick would both see the empty one.
      await expect.element(screen.getByText('a.txt')).toBeInTheDocument();

      drop('.picker-under-test', [file('b.txt')]);

      await expect.element(screen.getByText('b.txt')).toBeInTheDocument();
      await expect.element(screen.getByText('a.txt')).toBeInTheDocument();
    });

    it('removes a file from the list', async () => {
      const screen = await render(<PlFilePicker className="picker-under-test" />);

      drop('.picker-under-test', [file('notes.txt')]);
      await expect.element(screen.getByText('notes.txt')).toBeInTheDocument();

      await screen.getByRole('button', { name: 'Remove notes.txt' }).click();

      expect(screen.getByText('notes.txt').query()).toBeNull();
    });

    it('hides the list when `showList` is off', async () => {
      const screen = await render(<PlFilePicker className="picker-under-test" showList={false} />);

      drop('.picker-under-test', [file('notes.txt')]);

      await expect.element(screen.getByRole('button', { name: /Drop files/ })).toBeInTheDocument();
      expect(screen.getByText('notes.txt').query()).toBeNull();
    });
  });

  describe('turning files away', () => {
    it('rejects a file the `accept` list does not match', async () => {
      const onReject = vi.fn();
      const screen = await render(
        <PlFilePicker className="picker-under-test" accept="image/*" onReject={onReject} />
      );

      drop('.picker-under-test', [file('notes.txt')]);

      expect(onReject).toHaveBeenCalledWith([expect.objectContaining({ reason: 'type' })]);
      expect(screen.getByText('notes.txt').query()).toBeNull();
    });

    it('rejects a file bigger than `maxSize`', async () => {
      const onReject = vi.fn();
      await render(
        <PlFilePicker className="picker-under-test" maxSize={100} onReject={onReject} />
      );

      drop('.picker-under-test', [file('big.txt', 'text/plain', 5000)]);

      expect(onReject).toHaveBeenCalledWith([expect.objectContaining({ reason: 'size' })]);
    });

    it('counts `maxFiles` against what is already held', async () => {
      const onReject = vi.fn();
      const screen = await render(
        <PlFilePicker className="picker-under-test" multiple maxFiles={2} onReject={onReject} />
      );
      drop('.picker-under-test', [file('a.txt'), file('b.txt')]);
      await expect.element(screen.getByText('b.txt')).toBeInTheDocument();

      drop('.picker-under-test', [file('c.txt')]);

      expect(onReject).toHaveBeenCalledWith([expect.objectContaining({ reason: 'count' })]);
      expect(screen.getByText('c.txt').query()).toBeNull();
    });
  });

  describe('states', () => {
    it('disables the browse button', async () => {
      const screen = await render(<PlFilePicker disabled />);

      expect(screen.getByRole('button').element()).toBeDisabled();
    });

    it('ignores a drop when read-only', async () => {
      const screen = await render(
        <PlFilePicker className="picker-under-test" readOnly defaultValue={[file('held.txt')]} />
      );

      drop('.picker-under-test', [file('new.txt')]);

      await expect.element(screen.getByText('held.txt')).toBeInTheDocument();
      expect(screen.getByText('new.txt').query()).toBeNull();
    });

    it('offers no remove button when read-only', async () => {
      const screen = await render(<PlFilePicker readOnly defaultValue={[file('held.txt')]} />);

      expect(screen.getByRole('button', { name: 'Remove held.txt' }).query()).toBeNull();
    });
  });

  describe('formatFileSize', () => {
    it('reports bytes below a kilobyte', () => {
      expect(formatFileSize(999)).toBe('999 B');
    });

    it('steps up through the base-1000 units the OS uses', () => {
      expect(formatFileSize(1000)).toBe('1.0 kB');
      expect(formatFileSize(1_400_000)).toBe('1.4 MB');
      expect(formatFileSize(2_000_000_000)).toBe('2.0 GB');
    });

    it('drops the decimal past ten of a unit', () => {
      expect(formatFileSize(12_000)).toBe('12 kB');
    });
  });
});
