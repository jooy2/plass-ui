import { act } from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAccordion, PlAccordionItem } from 'plass-ui';

/** Two sections, which is the smallest accordion that can close one to open another. */
function TwoSections(props: React.ComponentProps<typeof PlAccordion>) {
  return (
    <PlAccordion {...props}>
      <PlAccordionItem value="billing" title="Billing">
        Invoices and payment methods.
      </PlAccordionItem>
      <PlAccordionItem value="team" title="Team">
        Members and their roles.
      </PlAccordionItem>
    </PlAccordion>
  );
}

describe('PlAccordion', () => {
  describe('rendering', () => {
    it('renders one button per section, named by its title', async () => {
      const screen = await render(<TwoSections />);

      await expect.element(screen.getByRole('button', { name: 'Billing' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Team' })).toBeInTheDocument();
    });

    it('starts with every section closed', async () => {
      const screen = await render(<TwoSections />);

      expect(screen.getByRole('button', { name: 'Billing' }).element()).toHaveAttribute(
        'aria-expanded',
        'false'
      );
    });

    it('lets a title longer than the header wrap rather than ellipsing it', async () => {
      const screen = await render(
        <PlAccordion>
          <PlAccordionItem value="q" title="A question long enough to need a second line">
            Body
          </PlAccordionItem>
        </PlAccordion>
      );

      const title = screen.getByText('A question long enough to need a second line').element();

      expect(title).not.toHaveClass('truncate');
    });

    it('holds the title and the subtitle to one line with `truncate`', async () => {
      const screen = await render(
        <PlAccordion>
          <PlAccordionItem value="q" title="Billing" subtitle="Cards and invoices" truncate>
            Body
          </PlAccordionItem>
        </PlAccordion>
      );

      expect(screen.getByText('Billing').element()).toHaveClass('truncate');
      expect(screen.getByText('Cards and invoices').element()).toHaveClass('truncate');
    });

    it('keeps `truncate` off the rendered section', async () => {
      const screen = await render(
        <PlAccordion>
          <PlAccordionItem value="q" title="Billing" truncate data-testid="section">
            Body
          </PlAccordionItem>
        </PlAccordion>
      );

      expect(screen.getByTestId('section').element()).not.toHaveAttribute('truncate');
    });

    it('renders the subtitle under the title, inside the same trigger', async () => {
      const screen = await render(
        <PlAccordion>
          <PlAccordionItem value="billing" title="Billing" subtitle="Cards and invoices">
            Body
          </PlAccordionItem>
        </PlAccordion>
      );

      const trigger = screen.getByRole('button', { name: /Billing/ }).element();

      expect(trigger.textContent).toContain('Billing');
      expect(trigger.textContent).toContain('Cards and invoices');
    });

    it('reflects a changed title on re-render', async () => {
      const screen = await render(
        <PlAccordion>
          <PlAccordionItem value="a" title="Before">
            Body
          </PlAccordionItem>
        </PlAccordion>
      );

      await screen.rerender(
        <PlAccordion>
          <PlAccordionItem value="a" title="After">
            Body
          </PlAccordionItem>
        </PlAccordion>
      );

      await expect.element(screen.getByRole('button', { name: 'After' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Before' }).query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<TwoSections className="my-own-class" />);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });

    it('renders `action` outside the trigger, so the header holds two controls', async () => {
      const screen = await render(
        <PlAccordion>
          <PlAccordionItem value="a" title="Billing" action={<button type="button">Edit</button>}>
            Body
          </PlAccordionItem>
        </PlAccordion>
      );

      const trigger = screen.getByRole('button', { name: 'Billing' }).element();
      const action = screen.getByRole('button', { name: 'Edit' }).element();

      expect(action).not.toBeNull();
      expect(trigger.contains(action)).toBe(false);
    });
  });

  describe('opening and closing', () => {
    it('opens the section that was clicked', async () => {
      const screen = await render(<TwoSections />);
      const trigger = screen.getByRole('button', { name: 'Billing' });

      await trigger.click();

      await expect.element(trigger).toHaveAttribute('aria-expanded', 'true');
      await expect.element(screen.getByText('Invoices and payment methods.')).toBeVisible();
    });

    it('closes the open section when another is opened', async () => {
      const screen = await render(<TwoSections />);

      await screen.getByRole('button', { name: 'Billing' }).click();
      await screen.getByRole('button', { name: 'Team' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Billing' }))
        .toHaveAttribute('aria-expanded', 'false');
      await expect
        .element(screen.getByRole('button', { name: 'Team' }))
        .toHaveAttribute('aria-expanded', 'true');
    });

    it('leaves both open when `multiple` is set', async () => {
      const screen = await render(<TwoSections multiple />);

      await screen.getByRole('button', { name: 'Billing' }).click();
      await screen.getByRole('button', { name: 'Team' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Billing' }))
        .toHaveAttribute('aria-expanded', 'true');
      await expect
        .element(screen.getByRole('button', { name: 'Team' }))
        .toHaveAttribute('aria-expanded', 'true');
    });

    it('opens whatever `defaultValue` names', async () => {
      const screen = await render(<TwoSections defaultValue={['team']} />);

      await expect
        .element(screen.getByRole('button', { name: 'Team' }))
        .toHaveAttribute('aria-expanded', 'true');
    });

    it('reports the new open set to `onValueChange`', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<TwoSections onValueChange={onValueChange} />);

      await screen.getByRole('button', { name: 'Team' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalledWith(['team']));
    });

    it('obeys `value` rather than the click when controlled', async () => {
      const screen = await render(<TwoSections value={['billing']} onValueChange={() => {}} />);

      await screen.getByRole('button', { name: 'Team' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Team' }))
        .toHaveAttribute('aria-expanded', 'false');
      await expect
        .element(screen.getByRole('button', { name: 'Billing' }))
        .toHaveAttribute('aria-expanded', 'true');
    });
  });

  describe('states', () => {
    it('disables every trigger when the accordion is disabled', async () => {
      const screen = await render(<TwoSections disabled />);

      expect(screen.getByRole('button', { name: 'Billing' }).element()).toBeDisabled();
      expect(screen.getByRole('button', { name: 'Team' }).element()).toBeDisabled();
    });

    it('disables one section without touching the rest', async () => {
      const screen = await render(
        <PlAccordion>
          <PlAccordionItem value="billing" title="Billing" disabled>
            Body
          </PlAccordionItem>
          <PlAccordionItem value="team" title="Team">
            Body
          </PlAccordionItem>
        </PlAccordion>
      );

      expect(screen.getByRole('button', { name: 'Billing' }).element()).toBeDisabled();
      expect(screen.getByRole('button', { name: 'Team' }).element()).toBeEnabled();
    });
  });

  describe('closed panels', () => {
    it('builds no closed panel by default', async () => {
      await render(<TwoSections />);

      expect(document.body.textContent).not.toContain('Invoices and payment methods.');
    });

    it('keeps closed panels in the DOM, hidden, with keepMounted', async () => {
      const screen = await render(<TwoSections keepMounted />);

      expect(
        screen.getByText('Invoices and payment methods.').element().closest('[hidden]')
      ).not.toBeNull();
    });

    it('keeps every closed panel as `hidden="until-found"` with hiddenUntilFound, and Base UI says nothing', async () => {
      // Base UI warns once per message, so this has to be the first render
      // with `hiddenUntilFound` in the file for the check to mean anything.
      const warn = vi.spyOn(console, 'warn');
      const error = vi.spyOn(console, 'error');

      try {
        const screen = await render(<TwoSections hiddenUntilFound />);

        for (const text of ['Invoices and payment methods.', 'Members and their roles.']) {
          expect(screen.getByText(text).element().closest('[hidden]')?.getAttribute('hidden')).toBe(
            'until-found'
          );
        }
        expect([...warn.mock.calls, ...error.mock.calls].flat().join('\n')).not.toContain(
          'keepMounted'
        );
      } finally {
        warn.mockRestore();
        error.mockRestore();
      }
    });

    it('puts the closed panels into the server HTML with hiddenUntilFound, and hydrates it as it is', async () => {
      const tree = <TwoSections hiddenUntilFound />;
      const host = document.createElement('div');
      const onRecoverableError = vi.fn();

      host.innerHTML = renderToString(tree);
      document.body.append(host);

      // What a search engine reads: the answer is there before any script runs.
      expect(host.textContent).toContain('Members and their roles.');

      const root = await act(async () => hydrateRoot(host, tree, { onRecoverableError }));

      try {
        expect(onRecoverableError).not.toHaveBeenCalled();
        expect(host.querySelectorAll('[hidden="until-found"]')).toHaveLength(2);
      } finally {
        await act(async () => root.unmount());
        host.remove();
      }
    });
  });

  describe('accessibility', () => {
    it('points each trigger at the region it controls', async () => {
      const screen = await render(<TwoSections defaultValue={['billing']} />);
      const trigger = screen.getByRole('button', { name: 'Billing' }).element();
      const panelId = trigger.getAttribute('aria-controls');

      expect(panelId).toBeTruthy();
      expect(document.getElementById(panelId as string)).not.toBeNull();
    });

    it('makes every header a level-3 heading by default', async () => {
      const screen = await render(<TwoSections />);

      await expect
        .element(screen.getByRole('heading', { level: 3, name: 'Billing' }))
        .toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 3 }).all()).toHaveLength(2);
    });

    it('puts every header at the level headingLevel names, and follows it on re-render', async () => {
      const screen = await render(<TwoSections headingLevel={2} />);

      // An FAQ straight under the page's `<h1>`: its questions are the `<h2>`s,
      // or the outline skips a level.
      await expect
        .element(screen.getByRole('heading', { level: 2, name: 'Team' }))
        .toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 2 }).all()).toHaveLength(2);
      expect(screen.getByRole('heading', { level: 3 }).query()).toBeNull();

      await screen.rerender(<TwoSections headingLevel={4} />);

      expect(screen.getByRole('heading', { level: 4 }).all()).toHaveLength(2);
      // Still the one button inside it, named by the title.
      await expect.element(screen.getByRole('button', { name: 'Team' })).toBeInTheDocument();
    });

    it('falls back to level 3 for a level no heading has', async () => {
      const screen = await render(<TwoSections headingLevel={7 as 3} />);

      expect(screen.getByRole('heading', { level: 3 }).all()).toHaveLength(2);
    });
  });
});
