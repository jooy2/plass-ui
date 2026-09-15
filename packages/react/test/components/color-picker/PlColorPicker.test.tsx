import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlColorPicker } from 'plass-ui';

describe('PlColorPicker', () => {
  describe('the trigger', () => {
    it('shows the colour it is holding', async () => {
      const screen = await render(<PlColorPicker defaultValue="#ff0000" />);

      await expect.element(screen.getByText('#ff0000')).toBeVisible();
    });

    it('says so when there is nothing to show', async () => {
      const screen = await render(<PlColorPicker value="" />);

      await expect.element(screen.getByText('Pick a colour')).toBeVisible();
    });

    it('takes its own word for that', async () => {
      const screen = await render(<PlColorPicker value="" labels={{ empty: 'No colour yet' }} />);

      await expect.element(screen.getByText('No colour yet')).toBeVisible();
    });

    it('submits under a name, in the format it was asked for', async () => {
      const screen = await render(
        <PlColorPicker data-testid="picker" name="brand" defaultValue="#ff0000" format="rgb" />
      );

      const hidden = screen
        .getByTestId('picker')
        .element()
        .querySelector<HTMLInputElement>('input[name="brand"]');

      expect(hidden?.value).toBe('rgb(255, 0, 0)');
    });
  });

  describe('the panel', () => {
    it('is drawn in the page when it is inline, with no trigger', async () => {
      const screen = await render(<PlColorPicker inline defaultValue="#ff0000" />);

      await expect
        .element(screen.getByRole('slider', { name: 'Saturation and brightness' }))
        .toBeVisible();
      expect(screen.getByRole('button', { name: /Pick a colour/ }).query()).toBeNull();
    });

    it('groups an inline panel under its label, described by the description and the error', async () => {
      const screen = await render(
        <>
          <PlColorPicker
            inline
            label="Accent"
            description="Links and focus rings."
            error="Too light to read."
            defaultValue="#ff0000"
          />
          <PlColorPicker inline label="Background" defaultValue="#ffffff" />
        </>
      );

      // Two inline pickers are otherwise two sets of sliders called "Hue".
      const accent = screen.getByRole('group', { name: 'Accent', exact: true });

      await expect.element(accent).toBeInTheDocument();
      await expect
        .element(accent)
        .toHaveAccessibleDescription('Links and focus rings. Too light to read.');
      await expect
        .element(screen.getByRole('group', { name: 'Background', exact: true }))
        .toBeInTheDocument();

      const hues = screen.getByRole('slider', { name: 'Hue' }).elements();

      expect(hues[0]).toHaveAttribute('aria-invalid', 'true');
      expect(hues[1]).not.toHaveAttribute('aria-invalid');
    });

    it('names the parts that have no text on them', async () => {
      const screen = await render(<PlColorPicker inline alpha defaultValue="#ff0000" />);

      await expect.element(screen.getByRole('slider', { name: 'Hue' })).toBeVisible();
      await expect.element(screen.getByRole('slider', { name: 'Opacity' })).toBeVisible();
      await expect.element(screen.getByRole('textbox', { name: 'Colour value' })).toBeVisible();
    });

    it('offers no opacity rail unless it is asked for', async () => {
      const screen = await render(<PlColorPicker inline defaultValue="#ff0000" />);

      expect(screen.getByRole('slider', { name: 'Opacity' }).query()).toBeNull();
    });

    it('reports the square s two channels together', async () => {
      const screen = await render(<PlColorPicker inline defaultValue="#ff0000" />);

      const area = screen.getByRole('slider', { name: 'Saturation and brightness' }).element();

      expect(area).toHaveAttribute('aria-valuenow', '100');
      expect(area).toHaveAttribute('aria-valuetext', '100%, 100%');
    });

    it('reports the hue in degrees', async () => {
      const screen = await render(<PlColorPicker inline defaultValue="#00ff00" />);

      expect(screen.getByRole('slider', { name: 'Hue' }).element()).toHaveAttribute(
        'aria-valuenow',
        '120'
      );
    });
  });

  describe('the keyboard', () => {
    it('moves the square with the arrow keys', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlColorPicker inline defaultValue="#ff0000" onValueChange={onValueChange} />
      );

      const area = screen.getByRole('slider', { name: 'Saturation and brightness' }).element();

      area.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowLeft', bubbles: true }));

      await expect.poll(() => onValueChange.mock.calls.length).toBeGreaterThan(0);
      // One step off full saturation.
      expect(onValueChange).toHaveBeenLastCalledWith('#ff0303');
    });

    it('takes ten steps at a time with Shift', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlColorPicker inline defaultValue="#ff0000" onValueChange={onValueChange} />
      );

      screen
        .getByRole('slider', { name: 'Saturation and brightness' })
        .element()
        .dispatchEvent(
          new KeyboardEvent('keydown', { key: 'ArrowLeft', shiftKey: true, bubbles: true })
        );

      await expect.poll(() => onValueChange.mock.calls.length).toBeGreaterThan(0);
      expect(onValueChange).toHaveBeenLastCalledWith('#ff1919');
    });

    it('walks the hue round rather than stopping at the ends', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlColorPicker inline defaultValue="#ff0000" onValueChange={onValueChange} />
      );

      // Red is 0°, and a step back is 358° rather than 0°.
      screen
        .getByRole('slider', { name: 'Hue' })
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowLeft', bubbles: true }));

      await expect.poll(() => onValueChange.mock.calls.length).toBeGreaterThan(0);
      expect(onValueChange).toHaveBeenLastCalledWith('#ff0008');
    });

    it('moves the rails with the vertical keys and Home and End too', async () => {
      const screen = await render(<PlColorPicker inline alpha defaultValue="#ff0000" />);
      const hue = screen.getByRole('slider', { name: 'Hue' });
      const opacity = screen.getByRole('slider', { name: 'Opacity' });
      const key = (slider: typeof hue, name: string) =>
        slider.element().dispatchEvent(new KeyboardEvent('keydown', { key: name, bubbles: true }));

      // The same keys every other slider answers: up is more, down is less, and
      // Home and End are the two ends.
      key(hue, 'ArrowUp');
      await expect.element(hue).toHaveAttribute('aria-valuenow', '2');
      key(hue, 'ArrowDown');
      await expect.element(hue).toHaveAttribute('aria-valuenow', '0');
      key(hue, 'End');
      await expect.element(hue).toHaveAttribute('aria-valuenow', '360');
      key(hue, 'Home');
      await expect.element(hue).toHaveAttribute('aria-valuenow', '0');

      key(opacity, 'ArrowDown');
      await expect.element(opacity).toHaveAttribute('aria-valuenow', '99');
      key(opacity, 'Home');
      await expect.element(opacity).toHaveAttribute('aria-valuenow', '0');
      key(opacity, 'ArrowUp');
      await expect.element(opacity).toHaveAttribute('aria-valuenow', '1');
      key(opacity, 'End');
      await expect.element(opacity).toHaveAttribute('aria-valuenow', '100');
    });

    it('leaves a key it does not answer to alone', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlColorPicker inline defaultValue="#ff0000" onValueChange={onValueChange} />
      );

      screen
        .getByRole('slider', { name: 'Hue' })
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'Tab', bubbles: true }));

      expect(onValueChange).not.toHaveBeenCalled();
    });
  });

  describe('the value', () => {
    it('writes hex, rgb or hsl on the way out', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlColorPicker inline defaultValue="#ff0000" format="rgb" onValueChange={onValueChange} />
      );

      await screen.getByRole('button', { name: '#22c55e' }).click();

      expect(onValueChange).toHaveBeenLastCalledWith('rgb(34, 197, 94)');
    });

    it('carries a fourth channel only when alpha is on', async () => {
      const screen = await render(
        <PlColorPicker inline alpha defaultValue="rgba(255, 0, 0, 0.5)" format="rgb" />
      );

      await expect
        .element(screen.getByRole('textbox', { name: 'Colour value' }))
        .toHaveValue('rgba(255, 0, 0, 0.5)');
    });

    it('takes a colour typed into the field', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlColorPicker inline defaultValue="#ff0000" onValueChange={onValueChange} />
      );

      await screen.getByRole('textbox', { name: 'Colour value' }).fill('#00ff00');

      expect(onValueChange).toHaveBeenLastCalledWith('#00ff00');
    });

    it('shows what was typed and changes nothing while it is not a colour', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlColorPicker inline defaultValue="#ff0000" onValueChange={onValueChange} />
      );

      const field = screen.getByRole('textbox', { name: 'Colour value' });

      await field.fill('not a colour');

      await expect.element(field).toHaveValue('not a colour');
      expect(onValueChange).not.toHaveBeenCalled();
      // The panel stayed where it was.
      expect(
        screen.getByRole('slider', { name: 'Hue' }).element().getAttribute('aria-valuenow')
      ).toBe('0');
    });

    it('answers with what a controlled picker is given', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlColorPicker inline value="#ff0000" onValueChange={onValueChange} />
      );

      await screen.getByRole('button', { name: '#22c55e' }).click();

      expect(onValueChange).toHaveBeenLastCalledWith('#22c55e');
      // Still red: the value is the caller's now.
      expect(
        screen.getByRole('slider', { name: 'Hue' }).element().getAttribute('aria-valuenow')
      ).toBe('0');
    });
  });

  describe('the swatches', () => {
    it('draws the built-in set and marks the one that is chosen', async () => {
      const screen = await render(<PlColorPicker inline defaultValue="#22c55e" />);

      const swatch = screen.getByRole('button', { name: '#22c55e' });

      await expect.element(swatch).toHaveAttribute('aria-pressed', 'true');
      await expect
        .element(screen.getByRole('button', { name: '#ef4444' }))
        .toHaveAttribute('aria-pressed', 'false');
    });

    it('takes a set of its own, and draws none at all when told', async () => {
      const screen = await render(
        <PlColorPicker inline defaultValue="#ff0000" swatches={['#123456']} />
      );

      await expect.element(screen.getByRole('button', { name: '#123456' })).toBeVisible();

      await screen.rerender(<PlColorPicker inline defaultValue="#ff0000" swatches={false} />);

      expect(screen.getByRole('group', { name: 'Swatches' }).query()).toBeNull();
    });

    it('leaves out a swatch it cannot read, and paints the rest from what it read', async () => {
      const screen = await render(
        <PlColorPicker inline defaultValue="#123456" swatches={['red', 'ff0000']} />
      );

      const swatch = screen.getByRole('button', { name: 'ff0000' });

      // A bare hex is a colour to the picker and not to CSS, so the button is
      // only red when it is painted from the parsed value.
      await expect.element(swatch).toBeVisible();
      expect(swatch.element().style.backgroundColor).toBe('rgb(255, 0, 0)');
      expect(screen.getByRole('button', { name: 'red' }).query()).toBeNull();
    });

    it('changes the colour and the opacity together', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlColorPicker
          inline
          alpha
          format="rgb"
          defaultValue="rgba(255, 0, 0, 0.2)"
          swatches={['#22c55e']}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: '#22c55e' }).click();

      // Both channels in one update: the swatch is opaque, so the old 0.2 goes.
      expect(onValueChange).toHaveBeenLastCalledWith('rgb(34, 197, 94)');
    });
  });

  describe('states', () => {
    it('takes nothing while it is read-only or disabled', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlColorPicker inline readOnly defaultValue="#ff0000" onValueChange={onValueChange} />
      );

      screen
        .getByRole('slider', { name: 'Hue' })
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

      expect(onValueChange).not.toHaveBeenCalled();
      await expect
        .element(screen.getByRole('slider', { name: 'Hue' }))
        .toHaveAttribute('aria-disabled', 'true');
    });

    it('takes nothing inside a disabled fieldset, until the fieldset is enabled', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <fieldset data-testid="fieldset" disabled>
          <PlColorPicker inline defaultValue="#ff0000" onValueChange={onValueChange} />
        </fieldset>
      );

      const hue = screen.getByRole('slider', { name: 'Hue' });

      await expect.element(hue).toHaveAttribute('aria-disabled', 'true');
      await expect.element(hue).toHaveAttribute('tabindex', '-1');

      hue
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

      expect(onValueChange).not.toHaveBeenCalled();

      // Turned off outside React, as a script or another library would.
      (screen.getByTestId('fieldset').element() as HTMLFieldSetElement).disabled = false;

      await expect.element(hue).not.toHaveAttribute('aria-disabled');
      await expect.element(hue).toHaveAttribute('tabindex', '0');
    });

    it('turns the family over to danger on an error', async () => {
      const screen = await render(
        <PlColorPicker data-testid="picker" inline error="Pick something" defaultValue="#ff0000" />
      );

      const style = screen.getByTestId('picker').element().getAttribute('style') ?? '';

      expect(style).toContain('--plass-danger-accent');
      await expect.element(screen.getByText('Pick something')).toBeVisible();
    });
  });
});
