import { useState } from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlTextField } from 'plass-ui';

describe('PlTextField', () => {
  describe('rendering', () => {
    it('renders a native input by default', async () => {
      const screen = await render(<PlTextField label="Email" />);
      const element = screen.getByRole('textbox', { name: 'Email' }).element();

      expect(element.tagName).toBe('INPUT');
      expect(element).toHaveAttribute('type', 'text');
      expect(element).toBeEnabled();
    });

    it('associates the label with the control', async () => {
      const screen = await render(<PlTextField label="Email" />);
      const input = screen.getByRole('textbox', { name: 'Email' }).element();

      const label = document.querySelector('label');
      expect(label?.getAttribute('for')).toBe(input.id);
      expect(input.id).not.toBe('');
    });

    it('renders without a label', async () => {
      const screen = await render(<PlTextField placeholder="Search" />);

      await expect.element(screen.getByPlaceholder('Search')).toBeInTheDocument();
      expect(document.querySelector('label')).toBeNull();
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<PlTextField label="Before" />);

      await screen.rerender(<PlTextField label="After" />);

      await expect.element(screen.getByRole('textbox', { name: 'After' })).toBeInTheDocument();
      expect(screen.getByRole('textbox', { name: 'Before' }).query()).toBeNull();
    });

    it('keeps caller-supplied class names on the root alongside its own', async () => {
      const screen = await render(<PlTextField label="Email" className="my-own-class" />);
      const root = screen.getByRole('textbox').element().closest('div');

      expect(root).toHaveClass('my-own-class');
      expect(root).toHaveClass('inline-flex');
    });

    it('forwards unknown props to the control', async () => {
      const screen = await render(<PlTextField type="email" maxLength={5} name="email" />);
      const element = screen.getByRole('textbox').element();

      expect(element).toHaveAttribute('type', 'email');
      expect(element).toHaveAttribute('maxlength', '5');
      expect(element).toHaveAttribute('name', 'email');
    });

    it('renders the description and the error under the control', async () => {
      const screen = await render(
        <PlTextField label="Email" description="We never share it." error="Not a valid address." />
      );

      await expect.element(screen.getByText('We never share it.')).toBeInTheDocument();
      await expect.element(screen.getByText('Not a valid address.')).toBeInTheDocument();
    });

    it('describes the control with both the description and the error', async () => {
      const screen = await render(
        <PlTextField label="Email" description="We never share it." error="Not a valid address." />
      );
      const input = screen.getByRole('textbox').element();

      const described = (input.getAttribute('aria-describedby') ?? '')
        .split(/\s+/)
        .filter(Boolean)
        .map((id) => document.getElementById(id)?.textContent);

      expect(described).toContain('We never share it.');
      expect(described).toContain('Not a valid address.');
    });
  });

  describe('multiline', () => {
    it('renders a textarea when multiline is set', async () => {
      const screen = await render(<PlTextField multiline label="Bio" />);
      const element = screen.getByRole('textbox', { name: 'Bio' }).element();

      expect(element.tagName).toBe('TEXTAREA');
      // `type` is meaningless on a textarea and must not leak onto it.
      expect(element).not.toHaveAttribute('type');
    });

    it('switches between input and textarea on re-render', async () => {
      const screen = await render(<PlTextField label="Bio" />);

      expect(screen.getByRole('textbox').element().tagName).toBe('INPUT');

      await screen.rerender(<PlTextField multiline label="Bio" />);

      expect(screen.getByRole('textbox').element().tagName).toBe('TEXTAREA');
    });

    it('passes rows through to the textarea', async () => {
      const screen = await render(<PlTextField multiline rows={6} />);

      expect(screen.getByRole('textbox').element()).toHaveAttribute('rows', '6');
    });

    it('resizes vertically by default and honours the resize prop', async () => {
      const screen = await render(<PlTextField multiline />);
      const element = screen.getByRole('textbox').element();

      expect(element).toHaveClass('resize-y');

      await screen.rerender(<PlTextField multiline resize="none" />);

      expect(element).toHaveClass('resize-none');
      expect(element).not.toHaveClass('resize-y');
    });

    it('trades the fixed height for a minimum so rows decide the height', async () => {
      const screen = await render(<PlTextField size="md" />);
      const shell = screen.getByRole('textbox').element().parentElement;

      expect(shell).toHaveClass('h-10');

      await screen.rerender(<PlTextField size="md" multiline />);

      expect(shell).toHaveClass('min-h-10');
      expect(shell).not.toHaveClass('h-10');
    });

    // The parity itself is arithmetic in the stylesheet — the multiline padding
    // is (height - border - line-height) / 2 — and no Tailwind is loaded here,
    // so measuring the two boxes would only compare the browser's own defaults
    // for an input against a textarea. What the test run can see is the input to
    // that arithmetic: both modes take their line height from `size` and never
    // from `density`.
    it('drives a one-row textarea from the same size as the single-line field', async () => {
      const screen = await render(<PlTextField size="md" density="compact" />);
      const shell = () => screen.getByRole('textbox').element().parentElement!;

      expect(shell()).toHaveClass('text-[0.875rem]/[1.25rem]');

      await screen.rerender(<PlTextField size="md" density="compact" multiline rows={1} />);

      expect(shell()).toHaveClass('text-[0.875rem]/[1.25rem]');
      expect(shell()).toHaveClass('py-[9px]');
    });

    it('accepts typed text that spans lines', async () => {
      const screen = await render(<PlTextField multiline label="Bio" />);
      const locator = screen.getByRole('textbox');

      await locator.fill('first\nsecond');

      expect((locator.element() as HTMLTextAreaElement).value).toBe('first\nsecond');
    });
  });

  describe('style props', () => {
    it('maps color onto the token slots the styles read from', async () => {
      const screen = await render(<PlTextField color="success" />);
      const root = screen.getByRole('textbox').element().closest('div') as HTMLElement;

      expect(root.style.getPropertyValue('--p-accent')).toBe('var(--plass-success-accent)');
      expect(root.style.getPropertyValue('--p-ring')).toBe('var(--plass-success-ring)');
    });

    it('leaves the glass undyed whatever the color is', async () => {
      const screen = await render(<PlTextField color="success" />);
      const root = screen.getByRole('textbox').element().closest('div') as HTMLElement;

      // What a field holds is user data, so there is no fill slot at all here —
      // the family reaches the hairline, the ring and the caret and stops.
      expect(root.style.getPropertyValue('--p-fill')).toBe('');
      expect(root.style.getPropertyValue('--p-lift')).toBe('');

      await screen.rerender(<PlTextField color="danger" />);

      expect(root.style.getPropertyValue('--p-fill')).toBe('');
      expect(root.style.getPropertyValue('--p-ring')).toBe('var(--plass-danger-ring)');
    });

    it('defaults to the primary color', async () => {
      const screen = await render(<PlTextField />);
      const root = screen.getByRole('textbox').element().closest('div') as HTMLElement;

      expect(root.style.getPropertyValue('--p-accent')).toBe('var(--plass-primary-accent)');
    });

    it('changes height with size but not with density', async () => {
      const screen = await render(<PlTextField size="lg" />);
      const shell = screen.getByRole('textbox').element().parentElement;

      expect(shell).toHaveClass('h-12');

      await screen.rerender(<PlTextField size="lg" density="compact" />);

      expect(shell).toHaveClass('h-12');
    });

    it('changes horizontal padding with density', async () => {
      const screen = await render(<PlTextField size="lg" />);
      const shell = screen.getByRole('textbox').element().parentElement;

      expect(shell).toHaveClass('px-6');

      await screen.rerender(<PlTextField size="lg" density="compact" />);

      expect(shell).toHaveClass('px-3.5');
      expect(shell).not.toHaveClass('px-6');
    });

    it('keeps the vertical padding of a multiline field out of density', async () => {
      const screen = await render(<PlTextField size="md" multiline />);
      const shell = screen.getByRole('textbox').element().parentElement;

      expect(shell).toHaveClass('py-[9px]');

      await screen.rerender(<PlTextField size="md" multiline density="compact" />);

      expect(shell).toHaveClass('py-[9px]');
    });

    it('is flat by default and maps elevation onto the shadow scale', async () => {
      const screen = await render(<PlTextField />);
      const root = screen.getByRole('textbox').element().closest('div') as HTMLElement;

      // A field is a well cut into the sheet, not a key resting on it.
      expect(root.style.getPropertyValue('--p-elev')).toBe('var(--plass-shadow-0)');

      await screen.rerender(<PlTextField elevation={2} />);

      expect(root.style.getPropertyValue('--p-elev')).toBe('var(--plass-shadow-2)');
    });

    it('draws a border for the glass variant only', async () => {
      const screen = await render(<PlTextField variant="glass" />);
      const shell = screen.getByRole('textbox').element().parentElement;

      expect(shell).toHaveClass('border');

      await screen.rerender(<PlTextField variant="ghost" />);
      expect(shell).not.toHaveClass('border');

      await screen.rerender(<PlTextField variant="solid" />);
      expect(shell).not.toHaveClass('border');
    });

    it('cuts a well rather than moulding a key for the solid variant', async () => {
      // The one shadow in the library that points inward. A gradient fill under
      // a caret, a selection and a placeholder is not legible, so `solid` on a
      // field means "the deepest glass", never "the plastic".
      const screen = await render(<PlTextField variant="solid" />);
      const shell = screen.getByRole('textbox').element().parentElement;

      expect(shell).toHaveClass('[box-shadow:var(--p-elev),var(--plass-well)]');
      expect(shell).not.toHaveClass('[background-image:var(--p-fill)]');
    });

    it('never applies a transform, so nothing in the field can move', async () => {
      const screen = await render(<PlTextField label="Email" elevation={3} />);
      const root = screen.getByRole('textbox').element().closest('div') as HTMLElement;

      expect(root.outerHTML).not.toContain('scale');
      expect(root.outerHTML).not.toContain('translate');
    });

    it('stretches to the container when fullWidth is set', async () => {
      const screen = await render(<PlTextField fullWidth />);
      const root = screen.getByRole('textbox').element().closest('div');

      expect(root).toHaveClass('w-full');
      expect(root).not.toHaveClass('inline-flex');
    });
  });

  describe('icons', () => {
    it('places startIcon before and endIcon after the control', async () => {
      const screen = await render(
        <PlTextField startIcon={<span>[</span>} endIcon={<span>]</span>} />
      );
      const shell = screen.getByRole('textbox').element().parentElement;

      expect(shell?.textContent).toBe('[]');
      expect(shell?.firstElementChild?.textContent).toBe('[');
      expect(shell?.lastElementChild?.textContent).toBe(']');
    });
  });

  describe('value', () => {
    it('reflects text typed into an uncontrolled field', async () => {
      const screen = await render(<PlTextField label="Email" />);
      const locator = screen.getByRole('textbox');

      await locator.fill('a@b.com');

      expect((locator.element() as HTMLInputElement).value).toBe('a@b.com');
    });

    it('fires onChange with the typed value', async () => {
      const onChange = vi.fn();
      const screen = await render(<PlTextField label="Email" onChange={onChange} />);

      await screen.getByRole('textbox').fill('hi');

      expect(onChange).toHaveBeenCalled();
      const last = onChange.mock.lastCall?.[0] as React.ChangeEvent<HTMLInputElement>;
      expect(last.target.value).toBe('hi');
    });

    it('renders a controlled value and updates it as state changes', async () => {
      function Controlled() {
        const [value, setValue] = useState('');
        return (
          <PlTextField
            label="Email"
            value={value}
            onChange={(event) => setValue(event.target.value)}
          />
        );
      }

      const screen = await render(<Controlled />);
      const locator = screen.getByRole('textbox');

      await locator.fill('typed');

      expect((locator.element() as HTMLInputElement).value).toBe('typed');
    });

    it('focuses the control when the shell padding is clicked', async () => {
      const screen = await render(<PlTextField size="xl" label="Email" />);
      const input = screen.getByRole('textbox').element();
      const shell = input.parentElement as HTMLElement;

      const box = shell.getBoundingClientRect();
      shell.dispatchEvent(
        new PointerEvent('pointerdown', {
          bubbles: true,
          clientX: box.left + 2,
          clientY: box.top + box.height / 2
        })
      );

      expect(document.activeElement).toBe(input);
    });
  });

  describe('states', () => {
    it('disables the control and lets the page through the sheet', async () => {
      const screen = await render(<PlTextField label="Email" disabled />);
      const input = screen.getByRole('textbox').element();

      expect(input).toBeDisabled();
      expect(input.parentElement).toHaveClass('opacity-50');
      expect(input.parentElement).toHaveClass('shadow-none');
    });

    it('stays focusable and editable-looking but rejects input when read-only', async () => {
      const screen = await render(<PlTextField label="Email" readOnly defaultValue="fixed" />);
      const input = screen.getByRole('textbox').element() as HTMLInputElement;

      expect(input).toHaveAttribute('readonly');
      expect(input.hasAttribute('disabled')).toBe(false);

      input.focus();
      expect(document.activeElement).toBe(input);
      expect(input.value).toBe('fixed');
    });

    it('keeps its colour but goes flat and desaturated when read-only', async () => {
      const screen = await render(<PlTextField elevation={2} />);
      const shell = screen.getByRole('textbox').element().parentElement;

      expect(shell).toHaveClass('[box-shadow:var(--p-elev),var(--plass-gloss-glass)]');
      expect(shell).not.toHaveClass('saturate-[0.55]');

      await screen.rerender(<PlTextField elevation={2} readOnly />);

      expect(shell).toHaveClass('[box-shadow:var(--plass-gloss-glass)]');
      expect(shell).not.toHaveClass('[box-shadow:var(--p-elev),var(--plass-gloss-glass)]');
      expect(shell).toHaveClass('saturate-[0.55]');
    });

    it('marks itself busy and shows a spinner while loading, without blocking typing', async () => {
      const screen = await render(<PlTextField loading label="Email" />);
      const locator = screen.getByRole('textbox');
      const input = locator.element();

      expect(input).toHaveAttribute('aria-busy', 'true');
      expect(input.parentElement?.querySelector('svg')).not.toBeNull();
      expect(input.hasAttribute('disabled')).toBe(false);

      await locator.fill('still typable');

      expect((input as HTMLInputElement).value).toBe('still typable');
    });

    it('replaces endIcon with the spinner while loading', async () => {
      const screen = await render(<PlTextField loading endIcon={<span>ICON</span>} />);
      const shell = screen.getByRole('textbox').element().parentElement;

      expect(shell?.textContent).toBe('');
    });
  });

  describe('validity', () => {
    it('turns the whole slot family over to danger when invalid', async () => {
      const screen = await render(<PlTextField label="Email" />);
      const root = screen.getByRole('textbox').element().closest('div') as HTMLElement;

      expect(root.style.getPropertyValue('--p-ring')).toBe('var(--plass-primary-ring)');

      await screen.rerender(<PlTextField label="Email" error="Required." />);

      expect(root.style.getPropertyValue('--p-ring')).toBe('var(--plass-danger-ring)');
      expect(root.style.getPropertyValue('--p-line')).toBe('var(--plass-danger-line)');
    });

    it('marks the control invalid for assistive technology', async () => {
      const screen = await render(<PlTextField label="Email" error="Required." />);

      expect(screen.getByRole('textbox').element()).toHaveAttribute('aria-invalid', 'true');
    });

    it('can be invalid without a message', async () => {
      const screen = await render(<PlTextField label="Email" invalid />);
      const root = screen.getByRole('textbox').element().closest('div') as HTMLElement;

      expect(root.style.getPropertyValue('--p-ring')).toBe('var(--plass-danger-ring)');
      expect(screen.getByRole('textbox').element()).toHaveAttribute('aria-invalid', 'true');
    });

    it('can carry a message without being invalid when told so explicitly', async () => {
      const screen = await render(<PlTextField label="Email" error="Heads up." invalid={false} />);
      const root = screen.getByRole('textbox').element().closest('div') as HTMLElement;

      expect(root.style.getPropertyValue('--p-ring')).toBe('var(--plass-primary-ring)');
      await expect.element(screen.getByText('Heads up.')).toBeInTheDocument();
    });

    it('overrides the color prop while invalid', async () => {
      const screen = await render(<PlTextField color="info" error="Required." />);
      const root = screen.getByRole('textbox').element().closest('div') as HTMLElement;

      expect(root.style.getPropertyValue('--p-accent')).toBe('var(--plass-danger-accent)');
    });
  });
});
