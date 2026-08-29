import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateHeadline } from 'plass-ui';

describe('PlAnimateHeadline', () => {
  it('names the effect it is running', async () => {
    await render(
      <PlAnimateHeadline className="headline-under-test">
        <span>faster</span>
        <span>simpler</span>
      </PlAnimateHeadline>
    );

    expect(document.querySelector('.headline-under-test')).toHaveAttribute(
      'data-plass-animation',
      'headline'
    );
  });

  it('keeps every line in the document, in one cell', async () => {
    await render(
      <PlAnimateHeadline className="headline-under-test">
        <span>faster</span>
        <span>simpler</span>
        <span>cheaper</span>
      </PlAnimateHeadline>
    );

    const lines = document.querySelectorAll('.headline-under-test > *');

    expect(lines).toHaveLength(3);
    expect(lines[0]).toHaveClass('plass-headline-item');
  });

  it('wraps a bare string, which has no element to mark', async () => {
    await render(<PlAnimateHeadline className="headline-under-test">faster</PlAnimateHeadline>);

    const line = document.querySelector('.headline-under-test > *');

    expect(line?.tagName).toBe('SPAN');
    expect(line).toHaveClass('plass-headline-item');
  });

  it('shows the first line and no other', async () => {
    await render(
      <PlAnimateHeadline className="headline-under-test">
        <span>faster</span>
        <span>simpler</span>
      </PlAnimateHeadline>
    );

    const lines = document.querySelectorAll('.headline-under-test > *');

    expect(lines[0]).toHaveAttribute('data-state', 'active');
    expect(lines[1]).not.toHaveAttribute('data-state');
  });

  it('starts an uncontrolled reel wherever it was told to', async () => {
    await render(
      <PlAnimateHeadline className="headline-under-test" defaultIndex={1}>
        <span>faster</span>
        <span>simpler</span>
      </PlAnimateHeadline>
    );

    const lines = document.querySelectorAll('.headline-under-test > *');

    expect(lines[1]).toHaveAttribute('data-state', 'active');
  });

  describe('controlled', () => {
    it('shows whichever line the caller says', async () => {
      const screen = await render(
        <PlAnimateHeadline className="headline-under-test" index={0}>
          <span>faster</span>
          <span>simpler</span>
        </PlAnimateHeadline>
      );

      await screen.rerender(
        <PlAnimateHeadline className="headline-under-test" index={1}>
          <span>faster</span>
          <span>simpler</span>
        </PlAnimateHeadline>
      );

      const lines = document.querySelectorAll('.headline-under-test > *');

      expect(lines[1]).toHaveAttribute('data-state', 'active');
      await expect.element(screen.getByText('faster')).toHaveAttribute('data-state', 'leaving');
    });

    it('clamps an index past the end onto the last line', async () => {
      await render(
        <PlAnimateHeadline className="headline-under-test" index={9}>
          <span>faster</span>
          <span>simpler</span>
        </PlAnimateHeadline>
      );

      const lines = document.querySelectorAll('.headline-under-test > *');

      expect(lines[1]).toHaveAttribute('data-state', 'active');
    });

    it('does not run a timer of its own, which would fight the caller', async () => {
      const onIndexChange = vi.fn();

      await render(
        <PlAnimateHeadline
          className="headline-under-test"
          index={0}
          interval={10}
          onIndexChange={onIndexChange}
        >
          <span>faster</span>
          <span>simpler</span>
        </PlAnimateHeadline>
      );

      await new Promise((resolve) => setTimeout(resolve, 80));

      expect(onIndexChange).not.toHaveBeenCalled();
    });
  });

  describe('uncontrolled', () => {
    it('turns on its own and reports each line as it comes up', async () => {
      const onIndexChange = vi.fn();

      const screen = await render(
        <PlAnimateHeadline
          className="headline-under-test"
          interval={20}
          duration={10}
          onIndexChange={onIndexChange}
        >
          <span>faster</span>
          <span>simpler</span>
        </PlAnimateHeadline>
      );

      await expect.element(screen.getByText('simpler')).toHaveAttribute('data-state', 'active');
      expect(onIndexChange).toHaveBeenCalledWith(1);
    });

    it('stops on the last line when it is not looping', async () => {
      await render(
        <PlAnimateHeadline className="headline-under-test" interval={20} duration={10} loop={false}>
          <span>faster</span>
          <span>simpler</span>
        </PlAnimateHeadline>
      );

      await new Promise((resolve) => setTimeout(resolve, 150));

      const lines = document.querySelectorAll('.headline-under-test > *');

      expect(lines[1]).toHaveAttribute('data-state', 'active');
    });

    it('holds still while it is paused', async () => {
      await render(
        <PlAnimateHeadline className="headline-under-test" interval={20} paused>
          <span>faster</span>
          <span>simpler</span>
        </PlAnimateHeadline>
      );

      await new Promise((resolve) => setTimeout(resolve, 120));

      const lines = document.querySelectorAll('.headline-under-test > *');

      expect(lines[0]).toHaveAttribute('data-state', 'active');
    });
  });

  it('writes the travel and the duration into its own slots', async () => {
    await render(
      <PlAnimateHeadline className="headline-under-test" rise={28} duration={700}>
        <span>faster</span>
      </PlAnimateHeadline>
    );

    const root = document.querySelector('.headline-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-rise')).toBe('28px');
    expect(root.style.getPropertyValue('--p-anim-duration')).toBe('700ms');
  });
});
