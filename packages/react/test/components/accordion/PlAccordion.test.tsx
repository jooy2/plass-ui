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

  describe('accessibility', () => {
    it('points each trigger at the region it controls', async () => {
      const screen = await render(<TwoSections defaultValue={['billing']} />);
      const trigger = screen.getByRole('button', { name: 'Billing' }).element();
      const panelId = trigger.getAttribute('aria-controls');

      expect(panelId).toBeTruthy();
      expect(document.getElementById(panelId as string)).not.toBeNull();
    });
  });
});
