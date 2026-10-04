import { act, type ReactElement } from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlEmpty } from 'plass-ui';

const box = (className: string) => document.querySelector(`.${className}`)!;

/**
 * A server's markup, read by the parser a browser reads a page with, and then
 * hydrated. A paragraph cannot hold a heading, a list or another paragraph, so
 * a `p` around one is closed where the block starts, leaving the block beside
 * an empty paragraph and the tree no longer matching what React hydrates.
 *
 * Returns the parts of `.empty-under-test` as the parser left them, and whether
 * hydration found a tree it did not expect.
 */
async function serverRendered(
  element: ReactElement
): Promise<{ parsed: Element[]; mismatched: boolean }> {
  const host = document.createElement('div');
  const onRecoverableError = vi.fn();

  host.innerHTML = renderToString(element);

  const parsed = Array.from(host.querySelector('.empty-under-test')!.children);

  document.body.append(host);

  const root = await act(async () => hydrateRoot(host, element, { onRecoverableError }));

  try {
    return { parsed, mismatched: onRecoverableError.mock.calls.length > 0 };
  } finally {
    await act(async () => root.unmount());
    host.remove();
  }
}

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
      const { parsed, mismatched } = await serverRendered(
        <PlEmpty title={<h2>No projects yet</h2>} className="empty-under-test" />
      );

      expect(parsed).toHaveLength(1);
      expect(parsed[0].querySelector('h2')).toHaveTextContent('No projects yet');
      expect(mismatched).toBe(false);
    });

    it('holds a list passed as the description, in server markup too', async () => {
      const { parsed, mismatched } = await serverRendered(
        <PlEmpty
          title="No results"
          description={
            <ul>
              <li>Check the spelling</li>
              <li>Try fewer words</li>
            </ul>
          }
          className="empty-under-test"
        />
      );

      expect(parsed).toHaveLength(2);
      expect(parsed[1].querySelectorAll('li')).toHaveLength(2);
      expect(mismatched).toBe(false);
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
