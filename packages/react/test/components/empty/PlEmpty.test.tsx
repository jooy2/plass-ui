import { act } from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlEmpty } from 'plass-ui';

const box = (className: string) => document.querySelector(`.${className}`)!;

describe('PlEmpty', () => {
  describe('the four parts', () => {
    it('draws the title', async () => {
      const screen = await render(<PlEmpty title="No projects yet" />);

      await expect.element(screen.getByText('No projects yet')).toBeInTheDocument();
    });

    it('draws the description', async () => {
      const screen = await render(
        <PlEmpty title="No projects yet" description="Start one and it will show up here." />
      );

      await expect.element(screen.getByText('Start one and it will show up here.')).toBeVisible();
    });

    it('draws the actions', async () => {
      const screen = await render(
        <PlEmpty title="No projects yet" actions={<PlButton>New project</PlButton>} />
      );

      await expect.element(screen.getByRole('button', { name: 'New project' })).toBeInTheDocument();
    });

    it('draws its own children between the description and the actions', async () => {
      const screen = await render(
        <PlEmpty title="No projects yet">
          <span>Anything else</span>
        </PlEmpty>
      );

      await expect.element(screen.getByText('Anything else')).toBeInTheDocument();
    });

    it('leaves out what it was not given', async () => {
      await render(<PlEmpty title="No projects yet" className="empty-under-test" />);

      expect(box('empty-under-test').children).toHaveLength(1);
    });

    it('holds a heading passed as the title, in server markup too', async () => {
      const empty = <PlEmpty title={<h2>No projects yet</h2>} className="empty-under-test" />;
      const host = document.createElement('div');
      const onRecoverableError = vi.fn();

      // A server's markup, read by the parser a browser reads a page with. A
      // paragraph cannot hold a heading, so a `p` around the title would be
      // closed at the `h2`, leaving the heading beside an empty title and the
      // tree no longer matching what React hydrates.
      host.innerHTML = renderToString(empty);

      const parsed = host.querySelector('.empty-under-test')!.children;

      expect(parsed).toHaveLength(1);
      expect(parsed[0].querySelector('h2')).toHaveTextContent('No projects yet');

      document.body.append(host);

      const root = await act(async () => hydrateRoot(host, empty, { onRecoverableError }));

      try {
        expect(onRecoverableError).not.toHaveBeenCalled();
      } finally {
        await act(async () => root.unmount());
        host.remove();
      }
    });
  });

  describe('the glyph', () => {
    it('is hidden from a screen reader', async () => {
      await render(<PlEmpty icon={<span>📭</span>} title="No mail" className="empty-under-test" />);

      // The title says what the glyph says, and a reader should not be told
      // twice.
      expect(box('empty-under-test').querySelector('[aria-hidden="true"]')).toBeTruthy();
    });

    it('is not drawn when there is none', async () => {
      await render(<PlEmpty title="No mail" className="empty-under-test" />);

      expect(box('empty-under-test').querySelector('[aria-hidden="true"]')).toBeNull();
    });
  });

  describe('the surface', () => {
    it('draws none', async () => {
      await render(<PlEmpty title="No projects yet" className="empty-under-test" />);

      // An empty state is always inside something, and a sheet inside a sheet
      // is two sheets.
      const classes = box('empty-under-test').className;

      expect(classes).not.toContain('backdrop-filter');
      expect(classes).not.toContain('border');
    });
  });

  describe('caller styling', () => {
    it('keeps a caller-supplied class alongside its own', async () => {
      await render(<PlEmpty title="No projects yet" className="my-own-class" />);

      expect(box('my-own-class')).toHaveClass('flex');
    });

    it('applies a caller style over the tokens it sets', async () => {
      await render(
        <PlEmpty
          title="No projects yet"
          className="empty-under-test"
          style={{ minHeight: '200px' }}
        />
      );

      expect((box('empty-under-test') as HTMLElement).style.minHeight).toBe('200px');
    });

    it('passes native attributes through', async () => {
      await render(<PlEmpty title="No projects yet" id="nothing-here" role="status" />);

      expect(document.getElementById('nothing-here')).toHaveAttribute('role', 'status');
    });
  });
});
