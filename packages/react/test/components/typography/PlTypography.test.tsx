import { describe, expect, expectTypeOf, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlTypography, type PlassHeadingLevel, type PlTypographyProps } from 'plass-ui';

describe('PlTypography', () => {
  describe('the element', () => {
    it('renders a paragraph by default', async () => {
      const screen = await render(<PlTypography>Body copy.</PlTypography>);

      expect(screen.getByText('Body copy.').element().tagName).toBe('P');
    });

    it('renders the matching heading for a heading level', async () => {
      const screen = await render(<PlTypography level="h2">A heading</PlTypography>);

      await expect.element(screen.getByRole('heading', { level: 2 })).toBeInTheDocument();
    });

    it('renders a span for the two quiet levels', async () => {
      const screen = await render(<PlTypography level="caption">A caption</PlTypography>);

      expect(screen.getByText('A caption').element().tagName).toBe('SPAN');
    });

    it('takes a different element without changing the scale', async () => {
      const screen = await render(
        <PlTypography level="h3" render={<p />}>
          Looks like a heading, is not one
        </PlTypography>
      );

      expect(screen.getByText('Looks like a heading, is not one').element().tagName).toBe('P');
      expect(screen.getByRole('heading').query()).toBeNull();
    });

    it('reflects a changed level on re-render', async () => {
      const screen = await render(<PlTypography level="h2">Title</PlTypography>);

      await screen.rerender(<PlTypography level="h4">Title</PlTypography>);

      await expect.element(screen.getByRole('heading', { level: 4 })).toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 2 }).query()).toBeNull();
    });
  });

  describe('headingLevel', () => {
    it('leaves a heading level at its own heading unless it is told otherwise', async () => {
      const screen = await render(<PlTypography level="h3">Title</PlTypography>);

      await expect
        .element(screen.getByRole('heading', { level: 3, name: 'Title' }))
        .toBeInTheDocument();
    });

    it('moves the heading to the level it names and keeps the scale', async () => {
      const screen = await render(
        <>
          <PlTypography level="h3">Plain</PlTypography>
          <PlTypography level="h3" headingLevel={2}>
            Moved
          </PlTypography>
        </>
      );
      const moved = screen.getByRole('heading', { level: 2, name: 'Moved' });

      await expect.element(moved).toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 3, name: 'Moved' }).query()).toBeNull();
      // The classes the `h3` would have had, so the size, the weight and the
      // colour all stay where the level put them.
      expect(moved.element().className).toBe(screen.getByText('Plain').element().className);
    });

    it('follows a changed heading level on re-render', async () => {
      const screen = await render(
        <PlTypography level="h3" headingLevel={2}>
          Title
        </PlTypography>
      );

      await screen.rerender(
        <PlTypography level="h3" headingLevel={4}>
          Title
        </PlTypography>
      );

      await expect
        .element(screen.getByRole('heading', { level: 4, name: 'Title' }))
        .toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 2 }).query()).toBeNull();
    });

    it('makes a level that is not a heading into one, at its own scale', async () => {
      const screen = await render(
        <>
          <PlTypography>Plain</PlTypography>
          <PlTypography headingLevel={2}>A real h2 set at body size</PlTypography>
        </>
      );
      const heading = screen.getByRole('heading', { level: 2 });

      await expect.element(heading).toHaveAccessibleName('A real h2 set at body size');
      expect(heading.element().className).toBe(screen.getByText('Plain').element().className);
    });

    it('gives way to render when both are given', async () => {
      const screen = await render(
        <PlTypography level="h3" headingLevel={2} render={<p />}>
          Looks like a heading, is not one
        </PlTypography>
      );

      expect(screen.getByText('Looks like a heading, is not one').element().tagName).toBe('P');
      expect(screen.getByRole('heading').query()).toBeNull();
    });

    it('ignores a level no heading has', async () => {
      const screen = await render(
        <>
          <PlTypography level="h3" headingLevel={7 as 2}>
            Title
          </PlTypography>
          <PlTypography headingLevel={0 as 2}>Body</PlTypography>
        </>
      );

      await expect
        .element(screen.getByRole('heading', { level: 3, name: 'Title' }))
        .toBeInTheDocument();
      expect(screen.getByText('Body').element().tagName).toBe('P');
      expect(screen.getByRole('heading').all()).toHaveLength(1);
    });

    it('takes the shared heading level', () => {
      // Checked by `npm run typecheck`, not by this run.
      expectTypeOf<PlTypographyProps['headingLevel']>().toEqualTypeOf<
        PlassHeadingLevel | undefined
      >();
    });
  });

  describe('the type', () => {
    it('gives a heading its own weight', async () => {
      const screen = await render(<PlTypography level="h1">Title</PlTypography>);

      expect(screen.getByRole('heading').element()).toHaveClass('font-semibold');
    });

    it('emits exactly one weight class when overridden', async () => {
      const screen = await render(
        <PlTypography level="h1" weight="regular">
          Title
        </PlTypography>
      );
      const element = screen.getByRole('heading').element();

      expect(element).toHaveClass('font-normal');
      expect(element).not.toHaveClass('font-semibold');
    });

    it('takes an alignment', async () => {
      const screen = await render(<PlTypography align="center">Centred</PlTypography>);

      expect(screen.getByText('Centred').element()).toHaveClass('text-center');
    });

    it('truncates a single line and clamps several', async () => {
      const screen = await render(<PlTypography lines={1}>Long</PlTypography>);

      expect(screen.getByText('Long').element()).toHaveClass('truncate');

      await screen.rerender(<PlTypography lines={3}>Long</PlTypography>);

      expect(screen.getByText('Long').element()).toHaveClass('line-clamp-(--p-lines)');
      expect(screen.getByText('Long').element().style.getPropertyValue('--p-lines')).toBe('3');

      // Past the six a class per number would have stopped at.
      await screen.rerender(<PlTypography lines={8}>Long</PlTypography>);

      expect(screen.getByText('Long').element().style.getPropertyValue('--p-lines')).toBe('8');
    });

    it('gives a one-line caption a box to cut the line at', async () => {
      const screen = await render(
        <PlTypography level="caption" lines={1}>
          Long
        </PlTypography>
      );

      expect(screen.getByText('Long').element()).toHaveClass('block', 'truncate');
    });

    it('adds no margin unless asked', async () => {
      const screen = await render(<PlTypography>Body</PlTypography>);

      expect(screen.getByText('Body').element()).not.toHaveClass('mb-3');

      await screen.rerender(<PlTypography gutter>Body</PlTypography>);

      expect(screen.getByText('Body').element()).toHaveClass('mb-3');
    });
  });

  describe('colour', () => {
    it('takes the page’s own foreground by default', async () => {
      const screen = await render(<PlTypography>Body</PlTypography>);
      const element = screen.getByText('Body').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-accent')).toBe('');
    });

    it('mutes the two quiet levels', async () => {
      const screen = await render(<PlTypography level="overline">Section</PlTypography>);

      expect(screen.getByText('Section').element()).toHaveClass('text-(--plass-muted-fg)');
    });

    it('takes the family it is given', async () => {
      const screen = await render(<PlTypography color="danger">Body</PlTypography>);
      const element = screen.getByText('Body').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-accent')).toBe('var(--plass-danger-accent)');
    });
  });

  describe('rendering', () => {
    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<PlTypography className="my-own-class">Body</PlTypography>);

      expect(screen.getByText('Body').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the element', async () => {
      const screen = await render(<PlTypography data-testid="prose">Body</PlTypography>);

      expect(screen.getByTestId('prose').element()).toBeInTheDocument();
    });
  });
});
