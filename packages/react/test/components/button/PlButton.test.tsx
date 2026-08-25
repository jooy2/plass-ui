import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton } from 'plass-ui';

describe('PlButton', () => {
  describe('rendering', () => {
    it('renders its children as the accessible name', async () => {
      const screen = await render(<PlButton>Save</PlButton>);

      await expect.element(screen.getByRole('button', { name: 'Save' })).toBeInTheDocument();
    });

    it('renders an interactive native button rather than a generic element', async () => {
      const screen = await render(<PlButton>Save</PlButton>);
      const element = screen.getByRole('button').element();

      expect(element.tagName).toBe('BUTTON');
      expect(element).toBeEnabled();
    });

    it('reflects changed children on re-render', async () => {
      const screen = await render(<PlButton>Before</PlButton>);

      await screen.rerender(<PlButton>After</PlButton>);

      await expect.element(screen.getByRole('button', { name: 'After' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Before' }).query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<PlButton className="my-own-class">Save</PlButton>);

      expect(screen.getByRole('button').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the underlying button', async () => {
      const screen = await render(<PlButton type="submit">Save</PlButton>);

      expect(screen.getByRole('button').element()).toHaveAttribute('type', 'submit');
    });

    it('renders as another element when `render` says so', async () => {
      const screen = await render(<PlButton render={<a href="/pricing" />}>Pricing</PlButton>);
      const element = screen.getByRole('link', { name: 'Pricing' }).element();

      expect(element.tagName).toBe('A');
      expect(element).toHaveAttribute('href', '/pricing');
      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('keeps its own surface when rendered as something else', async () => {
      const screen = await render(
        <PlButton render={<a href="/pricing" />} variant="glass" size="lg">
          Pricing
        </PlButton>
      );
      const element = screen.getByRole('link').element();

      // The same two things every `glass` PlButton at `lg` carries: the sheet's
      // hairline and the control height off the shared ladder.
      expect(element).toHaveClass('[border-color:var(--plass-glass-line)]');
      expect(element).toHaveClass('h-12');
    });
  });

  describe('style props', () => {
    it('maps color onto the token slots the styles read from', async () => {
      const screen = await render(<PlButton color="danger">Delete</PlButton>);
      const element = screen.getByRole('button').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-fill')).toBe('var(--plass-danger-fill)');
      expect(element.style.getPropertyValue('--p-tint')).toBe('var(--plass-danger-tint)');
      expect(element.style.getPropertyValue('--p-accent')).toBe('var(--plass-danger-accent)');
    });

    it('defaults to the primary color', async () => {
      const screen = await render(<PlButton>Save</PlButton>);
      const element = screen.getByRole('button').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-fill')).toBe('var(--plass-primary-fill)');
    });

    it('changes height with size but not with density', async () => {
      const screen = await render(<PlButton size="md">Save</PlButton>);
      const element = screen.getByRole('button').element();

      expect(element).toHaveClass('h-10');

      await screen.rerender(
        <PlButton size="md" density="compact">
          Save
        </PlButton>
      );

      expect(element).toHaveClass('h-10');
    });

    it('changes horizontal padding with density', async () => {
      const screen = await render(<PlButton size="lg">Save</PlButton>);
      const element = screen.getByRole('button').element();

      expect(element).toHaveClass('px-6');

      await screen.rerender(
        <PlButton size="lg" density="compact">
          Save
        </PlButton>
      );

      expect(element).toHaveClass('px-3.5');
      expect(element).not.toHaveClass('px-6');
    });

    it('rests one level off the sheet by default and presses back down onto it', async () => {
      const screen = await render(<PlButton>Save</PlButton>);
      const element = screen.getByRole('button').element() as HTMLElement;

      // A key rests *on* the sheet, so the default is 1 and not 0 — and one
      // level down from there is flush, which is what a press looks like.
      expect(element.style.getPropertyValue('--p-elev')).toBe('var(--plass-shadow-1)');
      expect(element.style.getPropertyValue('--p-elev-hover')).toBe('var(--plass-shadow-2)');
      expect(element.style.getPropertyValue('--p-elev-press')).toBe('var(--plass-shadow-0)');

      await screen.rerender(<PlButton elevation={3}>Save</PlButton>);

      expect(element.style.getPropertyValue('--p-elev')).toBe('var(--plass-shadow-3)');
      expect(element.style.getPropertyValue('--p-elev-hover')).toBe('var(--plass-shadow-4)');
      expect(element.style.getPropertyValue('--p-elev-press')).toBe('var(--plass-shadow-2)');
    });

    it('switches the interaction light with the variant, not with the colour', async () => {
      // White light on a near-white sheet is invisible, so only a filled
      // surface gets the white bloom; everything else takes its own soft tint.
      const screen = await render(<PlButton color="danger">Delete</PlButton>);
      const element = screen.getByRole('button').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-glow')).toBe('var(--plass-glow-on-fill)');
      expect(element.style.getPropertyValue('--p-flash')).toBe('var(--plass-flash-on-fill)');

      await screen.rerender(
        <PlButton color="danger" variant="glass">
          Delete
        </PlButton>
      );

      expect(element.style.getPropertyValue('--p-glow')).toBe('var(--plass-danger-soft)');
      expect(element.style.getPropertyValue('--p-flash')).toBe('var(--plass-danger-soft-hover)');
    });

    it('keeps the tinted lift out of the elevation ladder', async () => {
      // The lift says what the surface is made of; elevation says how far off
      // the page it is. A `danger` button one level higher is not a redder
      // piece of glass, so the two do not move together.
      const screen = await render(<PlButton>Save</PlButton>);
      const element = screen.getByRole('button').element() as HTMLElement;
      const lift = element.style.getPropertyValue('--p-lift');

      expect(lift).toContain('var(--p-tint)');

      await screen.rerender(<PlButton elevation={3}>Save</PlButton>);

      expect(element.style.getPropertyValue('--p-lift')).toBe(lift);
    });

    it('carries the interaction light on every variant that can be pressed', async () => {
      const screen = await render(<PlButton>Save</PlButton>);
      const element = screen.getByRole('button').element();

      expect(element).toHaveClass('plass-glow');

      // It is about where the pointer is, not about what the surface is made
      // of, so the variant does not take it away.
      await screen.rerender(<PlButton variant="glass">Save</PlButton>);
      expect(element).toHaveClass('plass-glow');

      await screen.rerender(<PlButton variant="ghost">Save</PlButton>);
      expect(element).toHaveClass('plass-glow');

      await screen.rerender(<PlButton disabled>Save</PlButton>);
      expect(element).not.toHaveClass('plass-glow');

      await screen.rerender(<PlButton readOnly>Save</PlButton>);
      expect(element).not.toHaveClass('plass-glow');

      await screen.rerender(<PlButton loading>Save</PlButton>);
      expect(element).not.toHaveClass('plass-glow');
    });

    it('writes the pointer position onto the element without re-rendering', async () => {
      const screen = await render(<PlButton size="xl">Save</PlButton>);
      const locator = screen.getByRole('button');
      const element = locator.element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-mx')).toBe('');

      await locator.hover();

      expect(element.style.getPropertyValue('--p-mx')).toMatch(/^[\d.]+px$/);
      expect(element.style.getPropertyValue('--p-my')).toMatch(/^[\d.]+px$/);
    });

    it('draws no highlight over a filled surface', async () => {
      // A filled control's box-shadow is the elevation and the tint and nothing
      // else. An inset white edge on a coloured surface is what reads as
      // lacquer, and the gradient is doing that job instead.
      const screen = await render(<PlButton>Save</PlButton>);
      const element = screen.getByRole('button').element();

      expect(element).toHaveClass('[box-shadow:var(--p-elev),var(--p-lift)]');
      expect(element.className).not.toContain('gloss');

      // The hairline is glass's, because glass has a real cut edge.
      await screen.rerender(<PlButton variant="glass">Save</PlButton>);

      expect(element).toHaveClass('[box-shadow:var(--p-elev),var(--plass-gloss-glass)]');
    });

    it('never applies a transform, so the label cannot move', async () => {
      const screen = await render(<PlButton elevation={3}>Save</PlButton>);
      const className = screen.getByRole('button').element().className;

      expect(className).not.toContain('scale');
      expect(className).not.toContain('translate');
    });

    it('draws a border for the glass variant only', async () => {
      const screen = await render(<PlButton variant="glass">Save</PlButton>);
      const element = screen.getByRole('button').element();

      expect(element).toHaveClass('border');

      await screen.rerender(<PlButton variant="ghost">Save</PlButton>);

      expect(element).not.toHaveClass('border');
    });

    it('fills only the solid variant with the gradient', async () => {
      const screen = await render(<PlButton variant="solid">Save</PlButton>);
      const element = screen.getByRole('button').element();

      expect(element).toHaveClass('[background-image:var(--p-fill)]');

      await screen.rerender(<PlButton variant="glass">Save</PlButton>);

      expect(element).not.toHaveClass('[background-image:var(--p-fill)]');
    });

    it('stretches to the container when fullWidth is set', async () => {
      const screen = await render(<PlButton fullWidth>Save</PlButton>);

      expect(screen.getByRole('button').element()).toHaveClass('w-full');
    });

    it('renders as a square when there is no label', async () => {
      const screen = await render(<PlButton size="md" aria-label="Add" startIcon={<svg />} />);
      const element = screen.getByRole('button', { name: 'Add' }).element();

      expect(element).toHaveClass('w-10');
      expect(element).toHaveClass('px-0');
    });
  });

  describe('icons', () => {
    it('places startIcon before and endIcon after the label', async () => {
      const screen = await render(
        <PlButton startIcon={<span>[</span>} endIcon={<span>]</span>}>
          Save
        </PlButton>
      );

      expect(screen.getByRole('button').element().textContent).toBe('[Save]');
    });
  });

  describe('states', () => {
    it('fires onClick when idle', async () => {
      const onClick = vi.fn();
      const screen = await render(<PlButton onClick={onClick}>Save</PlButton>);

      await screen.getByRole('button').click();

      expect(onClick).toHaveBeenCalledTimes(1);
    });

    it('lets click events reach a parent handler', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <div onClick={onClick}>
          <PlButton>Click me</PlButton>
        </div>
      );

      await screen.getByRole('button', { name: 'Click me' }).click();

      expect(onClick).toHaveBeenCalledTimes(1);
    });

    it('does not fire onClick when disabled', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <PlButton disabled onClick={onClick}>
          Save
        </PlButton>
      );
      const element = screen.getByRole('button').element();

      expect(element).toBeDisabled();

      await screen.getByRole('button').click({ force: true });

      expect(onClick).not.toHaveBeenCalled();
    });

    it('lets the page through a disabled key rather than greying it', async () => {
      const screen = await render(<PlButton disabled>Save</PlButton>);
      const element = screen.getByRole('button').element();

      expect(element).toHaveClass('opacity-50');
      expect(element).toHaveClass('saturate-[0.35]');
      // It keeps its shape and its colour; what it loses is the light.
      expect(element).toHaveClass('[background-image:var(--p-fill)]');
      expect(element).toHaveClass('shadow-none');
    });

    it('marks itself busy and swaps in a spinner while loading', async () => {
      const screen = await render(<PlButton loading>Save</PlButton>);
      const element = screen.getByRole('button').element();

      expect(element).toHaveAttribute('aria-busy', 'true');
      expect(element).toHaveAttribute('aria-disabled', 'true');
      expect(element.querySelector('svg')).not.toBeNull();
    });

    it('replaces startIcon with the spinner while loading', async () => {
      const screen = await render(
        <PlButton loading startIcon={<span>ICON</span>}>
          Save
        </PlButton>
      );

      expect(screen.getByRole('button').element().textContent).toBe('Save');
    });

    it('stays focusable but does not fire onClick while loading', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <PlButton loading onClick={onClick}>
          Save
        </PlButton>
      );
      const element = screen.getByRole('button').element();

      // Not natively disabled, so it keeps its place in the tab order.
      expect(element.hasAttribute('disabled')).toBe(false);

      // `force` because the driver refuses to click an `aria-disabled` element;
      // the point of the test is that our own handler is what blocks it.
      await screen.getByRole('button').click({ force: true });

      expect(onClick).not.toHaveBeenCalled();
    });

    it('does not fire onClick when read-only', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <PlButton readOnly onClick={onClick}>
          Save
        </PlButton>
      );
      const element = screen.getByRole('button').element();

      expect(element).toHaveAttribute('aria-disabled', 'true');
      expect(element).not.toHaveAttribute('aria-busy');

      await screen.getByRole('button').click({ force: true });

      expect(onClick).not.toHaveBeenCalled();
    });

    it('keeps its colour but goes flat and desaturated when read-only', async () => {
      const screen = await render(<PlButton elevation={2}>Save</PlButton>);
      const element = screen.getByRole('button').element() as HTMLElement;

      expect(element).toHaveClass('[box-shadow:var(--p-elev),var(--p-lift)]');
      expect(element).not.toHaveClass('saturate-[0.55]');

      await screen.rerender(
        <PlButton elevation={2} readOnly>
          Save
        </PlButton>
      );

      // Still the same family and still the same gradient...
      expect(element.style.getPropertyValue('--p-fill')).toBe('var(--plass-primary-fill)');
      // ...but no elevation, no tinted lift, and most of the saturation gone.
      expect(element).toHaveClass('shadow-none');
      expect(element).not.toHaveClass('[box-shadow:var(--p-elev),var(--p-lift)]');
      expect(element).toHaveClass('saturate-[0.55]');
    });

    it('does not let a read-only click reach a parent handler', async () => {
      const onParentClick = vi.fn();
      const screen = await render(
        <div onClick={onParentClick}>
          <PlButton readOnly>Save</PlButton>
        </div>
      );

      await screen.getByRole('button').click({ force: true });

      expect(onParentClick).not.toHaveBeenCalled();
    });
  });
});
