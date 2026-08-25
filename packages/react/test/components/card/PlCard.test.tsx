import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlCard } from 'plass-ui';

describe('PlCard', () => {
  describe('rendering', () => {
    it('renders its children', async () => {
      const screen = await render(<PlCard>Seats remaining: 3</PlCard>);

      await expect.element(screen.getByText('Seats remaining: 3')).toBeInTheDocument();
    });

    it('renders a plain div by default', async () => {
      const screen = await render(<PlCard>Body</PlCard>);

      expect(screen.getByText('Body').element().closest('div[class]')).not.toBeNull();
    });

    it('renders the title, the subtitle and the header action', async () => {
      const screen = await render(
        <PlCard
          title="Billing"
          subtitle="Visa ending 4242"
          headerAction={<button type="button">Change</button>}
        >
          Body
        </PlCard>
      );

      await expect.element(screen.getByText('Billing')).toBeInTheDocument();
      await expect.element(screen.getByText('Visa ending 4242')).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Change' })).toBeInTheDocument();
    });

    it('keeps a heading passed as `title` a heading', async () => {
      const screen = await render(<PlCard title={<h2>Billing</h2>}>Body</PlCard>);

      await expect
        .element(screen.getByRole('heading', { level: 2, name: 'Billing' }))
        .toBeInTheDocument();
    });

    it('renders the footer', async () => {
      const screen = await render(
        <PlCard footer={<button type="button">Save</button>}>Body</PlCard>
      );

      await expect.element(screen.getByRole('button', { name: 'Save' })).toBeInTheDocument();
    });

    it('draws no header section when no header slot is filled', async () => {
      await render(<PlCard className="card-under-test">Body</PlCard>);
      const card = document.querySelector('.card-under-test') as HTMLElement;

      // Body only: one section, and it is the one holding the children.
      expect(card.children).toHaveLength(1);
      expect(card.textContent).toBe('Body');
    });

    it('reflects a changed title on re-render', async () => {
      const screen = await render(<PlCard title="Before">Body</PlCard>);

      await screen.rerender(<PlCard title="After">Body</PlCard>);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlCard className="my-own-class">Body</PlCard>);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });

    it('forwards unknown props to the underlying element', async () => {
      await render(
        <PlCard className="card-under-test" data-testid="pricing">
          Body
        </PlCard>
      );

      expect(document.querySelector('.card-under-test')).toHaveAttribute('data-testid', 'pricing');
    });

    it('renders as another element when `render` says so', async () => {
      const screen = await render(<PlCard render={<a href="/pricing" />}>Pricing</PlCard>);
      const element = screen.getByRole('link', { name: 'Pricing' }).element();

      expect(element.tagName).toBe('A');
      expect(element).toHaveAttribute('href', '/pricing');
    });
  });

  describe('layout', () => {
    it('scores the sections with a hairline when `dividers` is set', async () => {
      await render(
        <PlCard className="card-under-test" dividers title="Billing" footer={<span>Footer</span>}>
          Body
        </PlCard>
      );
      const card = document.querySelector('.card-under-test') as HTMLElement;

      // Three sections; the two after the first carry the rule.
      expect(card.children).toHaveLength(3);
      expect(card.children[0].className).not.toContain('border-t');
      expect(card.children[1].className).toContain('border-t');
      expect(card.children[2].className).toContain('border-t');
    });

    it('drops the inner padding when `padded` is off', async () => {
      await render(
        <PlCard className="card-under-test" padded={false}>
          Body
        </PlCard>
      );
      const card = document.querySelector('.card-under-test') as HTMLElement;

      expect(card.className).not.toMatch(/\bpy-/);
      expect((card.children[0] as HTMLElement).className).not.toMatch(/\bpx-/);
    });

    it('takes the padding off the sheet and onto the sections when scored', async () => {
      await render(
        <PlCard className="card-under-test" dividers title="Billing">
          Body
        </PlCard>
      );
      const card = document.querySelector('.card-under-test') as HTMLElement;

      expect(card.className).not.toMatch(/\bpy-/);
      expect((card.children[0] as HTMLElement).className).toMatch(/\bpy-/);
    });
  });

  describe('interactive', () => {
    it('is not focusable on its own', async () => {
      await render(
        <PlCard className="card-under-test" interactive>
          Body
        </PlCard>
      );

      expect(document.querySelector('.card-under-test')).not.toHaveAttribute('tabindex');
    });

    it('is focusable when rendered as a real element', async () => {
      const screen = await render(
        <PlCard interactive render={<a href="/pricing" />}>
          Pricing
        </PlCard>
      );
      const link = screen.getByRole('link', { name: 'Pricing' }).element() as HTMLElement;

      link.focus();

      expect(document.activeElement).toBe(link);
    });
  });
});
