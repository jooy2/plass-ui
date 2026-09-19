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

/** Drags a batch onto the zone and leaves it there. */
function dragEnter(picker: string, selector = 'button') {
  const target = document.querySelector(`${picker} ${selector}`) as Element;
  const dataTransfer = new DataTransfer();

  dataTransfer.items.add(file('dragged.txt'));
  target.dispatchEvent(
    new DragEvent('dragenter', { bubbles: true, cancelable: true, dataTransfer })
  );
}

/** And takes it away again. */
function dragLeave(picker: string, selector = 'button') {
  const target = document.querySelector(`${picker} ${selector}`) as Element;

  target.dispatchEvent(new DragEvent('dragleave', { bubbles: true, cancelable: true }));
}

/** The zone's own class list, which is where every state is written. */
function zoneClasses(picker: string): string[] {
  return (document.querySelector(`${picker} button`) as HTMLElement).className.split(' ');
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

    it('names the browse button after its label, then its own words', async () => {
      const screen = await render(
        <>
          <PlFilePicker label="Resume" />
          <PlFilePicker label="Cover letter" hint="PDF only" />
        </>
      );

      // Two pickers on one screen would otherwise be read out the same.
      await expect
        .element(
          screen.getByRole('button', {
            name: 'Resume Drop files here, or click to browse',
            exact: true
          })
        )
        .toBeInTheDocument();
      await expect
        .element(screen.getByRole('button', { name: /^Cover letter Drop files here.*PDF only$/ }))
        .toBeInTheDocument();
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

    it('submits the list with a form, not the last pick from the dialog', async () => {
      const screen = await render(
        <form className="form-under-test">
          <PlFilePicker className="picker-under-test" name="attachments" multiple maxSize={2000} />
        </form>
      );

      const input = document.querySelector<HTMLInputElement>(
        '.picker-under-test input[type="file"]'
      )!;
      const submitted = () =>
        new FormData(document.querySelector<HTMLFormElement>('.form-under-test')!)
          .getAll('attachments')
          .map((entry) => (entry as File).name);

      // A pick from the dialog, which is the one thing the input held before.
      const picked = new DataTransfer();
      picked.items.add(file('picked.txt'));
      input.files = picked.files;
      input.dispatchEvent(new Event('change', { bubbles: true }));
      await expect.element(screen.getByText('picked.txt')).toBeInTheDocument();

      // A drop, which the input never saw.
      drop('.picker-under-test', [file('dropped.txt')]);
      await expect.element(screen.getByText('dropped.txt')).toBeInTheDocument();
      await expect.poll(submitted).toEqual(['picked.txt', 'dropped.txt']);

      // A removal, which the input kept.
      await screen.getByRole('button', { name: 'Remove picked.txt' }).click();
      await expect.poll(submitted).toEqual(['dropped.txt']);

      // A pick turned away for its size, which the input took anyway.
      const tooBig = new DataTransfer();
      tooBig.items.add(file('huge.txt', 'text/plain', 5000));
      input.files = tooBig.files;
      input.dispatchEvent(new Event('change', { bubbles: true }));
      await expect.poll(submitted).toEqual(['dropped.txt']);
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

  describe('saying what was turned away', () => {
    it('says why, grouped by reason and counted', async () => {
      const screen = await render(
        <PlFilePicker className="picker-under-test" multiple accept=".txt" maxSize={2000} />
      );

      drop('.picker-under-test', [
        file('a.png', 'image/png'),
        file('b.png', 'image/png'),
        file('c.txt', 'text/plain', 5000)
      ]);

      // One line per reason rather than one per file: a folder dropped on a
      // picker with a `maxFiles` of five is ninety-five lines of the same
      // sentence.
      await expect.element(screen.getByText('2 files are not an accepted type')).toBeVisible();
      await expect.element(screen.getByText('1 file is too large')).toBeVisible();
    });

    it('says so about the count as well', async () => {
      const screen = await render(
        <PlFilePicker className="picker-under-test" multiple maxFiles={1} />
      );

      drop('.picker-under-test', [file('a.txt'), file('b.txt'), file('c.txt')]);

      await expect.element(screen.getByText('2 files did not fit')).toBeVisible();
    });

    it('announces it politely rather than interrupting', async () => {
      const screen = await render(<PlFilePicker className="picker-under-test" accept=".txt" />);

      drop('.picker-under-test', [file('a.png', 'image/png')]);

      await expect.element(screen.getByRole('status')).toBeVisible();
      // The value is not wrong — what was turned away never reached it.
      expect(screen.getByRole('button').element()).not.toHaveAttribute('aria-invalid');
    });

    it('drops the message once the reader does something else', async () => {
      const screen = await render(
        <PlFilePicker className="picker-under-test" multiple accept=".txt" />
      );

      drop('.picker-under-test', [file('a.png', 'image/png'), file('b.txt')]);
      await expect.element(screen.getByText('1 file is not an accepted type')).toBeVisible();

      await screen.getByRole('button', { name: 'Remove b.txt' }).click();

      expect(screen.getByText('1 file is not an accepted type').query()).toBeNull();
    });

    it('says nothing when the batch was taken whole', async () => {
      const screen = await render(<PlFilePicker className="picker-under-test" />);

      drop('.picker-under-test', [file('notes.txt')]);

      await expect.element(screen.getByText('notes.txt')).toBeVisible();
      expect(screen.getByRole('status').query()).toBeNull();
    });

    it('can be told to leave it to `onReject`', async () => {
      const onReject = vi.fn();
      const screen = await render(
        <PlFilePicker
          className="picker-under-test"
          accept=".txt"
          showRejections={false}
          onReject={onReject}
        />
      );

      drop('.picker-under-test', [file('a.png', 'image/png')]);

      await vi.waitFor(() => expect(onReject).toHaveBeenCalledTimes(1));
      expect(screen.getByRole('status').query()).toBeNull();
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

  describe('a file being dragged over the box', () => {
    it('takes the family wash, the ring edge and a halo, and gives up the resting ones', async () => {
      await render(<PlFilePicker className="picker-under-test" />);

      expect(zoneClasses('.picker-under-test')).toContain('bg-(--plass-glass)');

      dragEnter('.picker-under-test');
      await vi.waitFor(() =>
        expect(zoneClasses('.picker-under-test')).toContain('bg-(--p-soft-hover)')
      );

      const lit = zoneClasses('.picker-under-test');

      expect(lit).toContain('[border-color:var(--p-ring)]');
      expect(lit).toContain(
        '[box-shadow:var(--p-elev),var(--plass-gloss-glass),0_0_0_4px_var(--p-soft)]'
      );
      // The point of the whole arrangement. Left in place, the resting fill and
      // the resting edge are one class each, exactly as these are, and the
      // stylesheet decides between them — which is why the state used to do
      // nothing at all.
      expect(lit).not.toContain('bg-(--plass-glass)');
      expect(lit).not.toContain('[border-color:var(--plass-border)]');
      expect(lit).not.toContain('hover:bg-(--plass-glass-hover)');
    });

    it('goes back to resting when the file leaves', async () => {
      await render(<PlFilePicker className="picker-under-test" />);

      dragEnter('.picker-under-test');
      await vi.waitFor(() =>
        expect(zoneClasses('.picker-under-test')).toContain('bg-(--p-soft-hover)')
      );

      dragLeave('.picker-under-test');
      await vi.waitFor(() =>
        expect(zoneClasses('.picker-under-test')).toContain('bg-(--plass-glass)')
      );
    });

    it('goes back to resting once the file is dropped', async () => {
      const screen = await render(<PlFilePicker className="picker-under-test" />);

      dragEnter('.picker-under-test');
      drop('.picker-under-test', [file('notes.txt')]);

      await expect.element(screen.getByText('notes.txt')).toBeInTheDocument();
      expect(zoneClasses('.picker-under-test')).toContain('bg-(--plass-glass)');
    });

    it('marks the notched edge as well', async () => {
      await render(
        <PlFilePicker className="picker-under-test" label="Attachments" labelPlacement="notch" />
      );

      dragEnter('.picker-under-test');

      await vi.waitFor(() => {
        const edge = (document.querySelector('fieldset') as HTMLElement).className.split(' ');

        expect(edge).toContain('[border-color:var(--p-ring)]');
        expect(edge).not.toContain('[border-color:var(--plass-border)]');
      });
    });

    it('answers a file dragged over the list under the box, which is the same drop area', async () => {
      await render(
        <PlFilePicker className="picker-under-test" multiple defaultValue={[file('held.txt')]} />
      );

      dragEnter('.picker-under-test', 'ul');

      await vi.waitFor(() =>
        expect(zoneClasses('.picker-under-test')).toContain('bg-(--p-soft-hover)')
      );
    });

    it('takes a file dropped on that list', async () => {
      const screen = await render(
        <PlFilePicker className="picker-under-test" multiple defaultValue={[file('held.txt')]} />
      );

      const list = document.querySelector('.picker-under-test ul') as Element;
      const dataTransfer = new DataTransfer();

      dataTransfer.items.add(file('dropped.txt'));
      list.dispatchEvent(new DragEvent('drop', { bubbles: true, cancelable: true, dataTransfer }));

      await expect.element(screen.getByText('dropped.txt')).toBeInTheDocument();
    });

    it('stays put while it is read-only', async () => {
      const screen = await render(<PlFilePicker className="picker-under-test" readOnly />);

      dragEnter('.picker-under-test');
      // Nothing is expected to happen, so there is no state to wait for. A
      // render the component does answer is what proves the queue was drained.
      await screen.rerender(<PlFilePicker className="picker-under-test" readOnly />);

      expect(zoneClasses('.picker-under-test')).not.toContain('bg-(--p-soft-hover)');
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

  describe('labelPlacement', () => {
    it("puts the label in the zone's edge when notched", async () => {
      const screen = await render(<PlFilePicker label="Attachments" labelPlacement="notch" />);
      const zone = screen.getByRole('button', { name: /Attachments/ }).element() as HTMLElement;
      const legend = document.querySelector('legend');

      expect(legend?.textContent).toBe('Attachments');
      // The zone is named by `aria-labelledby`, so the span it points at has to
      // be the one in the notch and not a second copy of the word.
      expect(zone.getAttribute('aria-labelledby')?.split(' ')).toContain(
        legend?.firstElementChild?.id
      );
      expect(zone.style.borderColor).toBe('transparent');
    });

    it('draws the same edge the zone would have drawn itself', async () => {
      const screen = await render(<PlFilePicker label="Attachments" />);
      const stacked = screen.getByRole('button', { name: /Attachments/ }).element().className;

      await screen.rerender(<PlFilePicker label="Attachments" labelPlacement="notch" />);
      const edge = (document.querySelector('fieldset') as HTMLElement).className;

      // A drop zone's edge is 2px and dashed in every variant, and the notch is
      // cut into that rather than into a field's hairline. The two are written
      // out twice in the source, so this is what keeps them the same line.
      for (const rule of ['border-2', 'border-dashed', '[border-color:var(--plass-border)]']) {
        expect(stacked.split(' ')).toContain(rule);
        expect(edge.split(' ')).toContain(rule);
      }
    });
  });
});
