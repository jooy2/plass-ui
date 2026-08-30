import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlPageLayout } from 'plass-ui';

describe('PlPageLayout', () => {
  describe('the landmarks', () => {
    it('puts its children inside a <main>', async () => {
      const screen = await render(
        <PlPageLayout>
          <p>The page</p>
        </PlPageLayout>
      );

      await expect.element(screen.getByRole('main')).toHaveTextContent('The page');
    });

    it('gives the main the id the skip link jumps to', async () => {
      const screen = await render(<PlPageLayout>Body</PlPageLayout>);

      const link = screen.getByRole('link', { name: 'Skip to content' });

      await expect.element(link).toHaveAttribute('href', '#main');
      await expect.element(screen.getByRole('main')).toHaveAttribute('id', 'main');
    });

    it('renames both halves of that pair together', async () => {
      const screen = await render(<PlPageLayout mainId="content">Body</PlPageLayout>);

      await expect
        .element(screen.getByRole('link', { name: 'Skip to content' }))
        .toHaveAttribute('href', '#content');
      await expect.element(screen.getByRole('main')).toHaveAttribute('id', 'content');
    });

    it('takes a label for the skip link', async () => {
      const screen = await render(<PlPageLayout skipLabel="본문으로 건너뛰기">Body</PlPageLayout>);

      await expect.element(screen.getByRole('link', { name: '본문으로 건너뛰기' })).toBeVisible();
    });

    it('leaves the link out when it is turned off', async () => {
      const screen = await render(<PlPageLayout skipLink={false}>Body</PlPageLayout>);

      expect(screen.getByRole('link').query()).toBeNull();
    });

    it('passes anything else through to the main', async () => {
      const screen = await render(
        <PlPageLayout mainProps={{ 'aria-label': 'Report', className: 'p-6' }}>Body</PlPageLayout>
      );

      const main = screen.getByRole('main').element();

      expect(main).toHaveAttribute('aria-label', 'Report');
      expect(main).toHaveClass('p-6');
    });
  });

  describe('the slots', () => {
    it('draws the header, the sidebars and the footer around the content', async () => {
      const screen = await render(
        <PlPageLayout
          data-testid="layout"
          header={<div>Header</div>}
          sidebar={<div>Nav</div>}
          endSidebar={<div>Aside</div>}
          footer={<div>Footer</div>}
        >
          Body
        </PlPageLayout>
      );

      expect(screen.getByTestId('layout').element().textContent).toBe(
        'Skip to contentHeaderNavBodyAsideFooter'
      );
    });

    it('draws nothing for a slot nobody filled', async () => {
      const screen = await render(
        <PlPageLayout data-testid="layout" header={null} footer={false}>
          Body
        </PlPageLayout>
      );

      expect(screen.getByTestId('layout').element().textContent).toBe('Skip to contentBody');
    });

    it('moves the header between the sidebars on a content span', async () => {
      const screen = await render(
        <PlPageLayout
          data-testid="layout"
          headerSpan="content"
          header={<div>Header</div>}
          sidebar={<div>Nav</div>}
        >
          Body
        </PlPageLayout>
      );

      expect(screen.getByTestId('layout').element().textContent).toBe(
        'Skip to contentNavHeaderBody'
      );
    });

    it('answers the same question for the footer separately', async () => {
      const screen = await render(
        <PlPageLayout
          data-testid="layout"
          footerSpan="content"
          footer={<div>Footer</div>}
          sidebar={<div>Nav</div>}
        >
          Body
        </PlPageLayout>
      );

      expect(screen.getByTestId('layout').element().textContent).toBe(
        'Skip to contentNavBodyFooter'
      );
    });
  });

  describe('height and scroll', () => {
    it('is a floor while the page scrolls and an exact height while the content does', async () => {
      const screen = await render(<PlPageLayout data-testid="layout">Body</PlPageLayout>);

      expect(screen.getByTestId('layout').element()).toHaveClass('min-h-dvh');

      await screen.rerender(
        <PlPageLayout data-testid="layout" scroll="content">
          Body
        </PlPageLayout>
      );

      const element = screen.getByTestId('layout').element();

      expect(element).toHaveClass('h-dvh');
      expect(element).toHaveClass('overflow-hidden');
    });

    it('hands the scrolling to the main when only the content scrolls', async () => {
      const screen = await render(
        <PlPageLayout scroll="content">
          <p>Body</p>
        </PlPageLayout>
      );

      await expect.element(screen.getByRole('main')).toHaveClass('overflow-y-auto');
    });

    it('takes its parent height instead of the window s', async () => {
      const screen = await render(
        <PlPageLayout data-testid="layout" height="auto">
          Body
        </PlPageLayout>
      );

      expect(screen.getByTestId('layout').element()).toHaveClass('min-h-full');
    });

    it('takes a length, as a number of pixels or as written', async () => {
      const screen = await render(
        <PlPageLayout data-testid="layout" height={480}>
          Body
        </PlPageLayout>
      );

      expect(screen.getByTestId('layout').element().style.minHeight).toBe('480px');

      await screen.rerender(
        <PlPageLayout data-testid="layout" height="30rem" scroll="content">
          Body
        </PlPageLayout>
      );

      expect(screen.getByTestId('layout').element().style.height).toBe('30rem');
    });
  });

  describe('measurement', () => {
    it('writes a zero for a slot that is empty', async () => {
      const screen = await render(<PlPageLayout data-testid="layout">Body</PlPageLayout>);

      const element = screen.getByTestId('layout').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-layout-header')).toBe('0px');
      expect(element.style.getPropertyValue('--p-layout-footer-inset')).toBe('0px');
    });

    it('leaves a bar that never registered itself at zero', async () => {
      // The measurement is a contract, not a `querySelector`: the layout writes
      // what a slot told it and nothing else, so a caller's own bar is measured
      // exactly when it opts in. `PlHeader` and `PlFooter` do.
      const screen = await render(
        <PlPageLayout
          data-testid="layout"
          header={<header style={{ position: 'sticky', top: 0, height: 64 }}>Header</header>}
        >
          Body
        </PlPageLayout>
      );

      const element = screen.getByTestId('layout').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-layout-header')).toBe('0px');
      expect(element.style.getPropertyValue('--p-layout-header-inset')).toBe('0px');
    });
  });

  describe('the root', () => {
    it('keeps the class name and the style it is given', async () => {
      const screen = await render(
        <PlPageLayout data-testid="layout" className="bg-white" style={{ color: 'red' }}>
          Body
        </PlPageLayout>
      );

      const element = screen.getByTestId('layout').element() as HTMLElement;

      expect(element).toHaveClass('bg-white');
      expect(element.style.color).toBe('red');
    });
  });
});
