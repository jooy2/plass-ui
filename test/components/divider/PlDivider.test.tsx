import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlDivider } from 'plass-ui';

describe('PlDivider', () => {
  describe('rendering', () => {
    it('renders a separator', async () => {
      const screen = await render(<PlDivider />);

      await expect.element(screen.getByRole('separator')).toBeInTheDocument();
    });

    it('is horizontal by default', async () => {
      const screen = await render(<PlDivider />);

      expect(screen.getByRole('separator').element()).toHaveAttribute(
        'aria-orientation',
        'horizontal'
      );
    });

    it('turns with `orientation`', async () => {
      const screen = await render(<PlDivider orientation="vertical" />);

      expect(screen.getByRole('separator').element()).toHaveAttribute(
        'aria-orientation',
        'vertical'
      );
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<PlDivider className="my-own-class" />);

      expect(screen.getByRole('separator').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the element', async () => {
      const screen = await render(<PlDivider data-testid="rule" />);

      expect(screen.getByRole('separator').element()).toHaveAttribute('data-testid', 'rule');
    });
  });

  describe('the label', () => {
    it('draws the label between two stubs of the line', async () => {
      const screen = await render(<PlDivider>OR</PlDivider>);

      await expect.element(screen.getByText('OR')).toBeInTheDocument();
    });

    it('names the separator after a string label', async () => {
      const screen = await render(<PlDivider>OR</PlDivider>);

      expect(screen.getByRole('separator').element()).toHaveAttribute('aria-label', 'OR');
    });

    it('leaves a non-string label to the caller to name', async () => {
      const screen = await render(
        <PlDivider>
          <span>OR</span>
        </PlDivider>
      );

      expect(screen.getByRole('separator').element()).not.toHaveAttribute('aria-label');
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<PlDivider>OR</PlDivider>);

      await screen.rerender(<PlDivider>AND</PlDivider>);

      await expect.element(screen.getByText('AND')).toBeInTheDocument();
      expect(screen.getByText('OR').query()).toBeNull();
    });
  });

  describe('length and thickness', () => {
    it('takes a number as pixels', async () => {
      const screen = await render(<PlDivider length={120} thickness={2} />);
      const element = screen.getByRole('separator').element() as HTMLElement;

      expect(element.style.width).toBe('120px');
      expect(element.style.getPropertyValue('--p-rule')).toBe('2px');
    });

    it('takes a string as any CSS length', async () => {
      const screen = await render(<PlDivider length="50%" thickness="0.25rem" />);
      const element = screen.getByRole('separator').element() as HTMLElement;

      expect(element.style.width).toBe('50%');
      expect(element.style.getPropertyValue('--p-rule')).toBe('0.25rem');
    });

    it('puts a vertical divider’s length on its height', async () => {
      const screen = await render(<PlDivider orientation="vertical" length={40} />);

      expect((screen.getByRole('separator').element() as HTMLElement).style.height).toBe('40px');
    });
  });

  describe('colour', () => {
    it('draws the neutral hairline when no family is asked for', async () => {
      const screen = await render(<PlDivider />);
      const element = screen.getByRole('separator').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-rule-color')).toBe('var(--plass-border)');
    });

    it('tints the rule with the family it is given', async () => {
      const screen = await render(<PlDivider color="danger" />);
      const element = screen.getByRole('separator').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-rule-color')).toBe('var(--plass-danger-line)');
    });
  });
});
