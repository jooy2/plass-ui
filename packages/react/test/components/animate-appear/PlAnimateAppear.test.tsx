import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateAppear } from 'plass-ui';

describe('PlAnimateAppear', () => {
  it('names the effect it is running', async () => {
    await render(
      <PlAnimateAppear className="appear-under-test">
        <p>One</p>
      </PlAnimateAppear>
    );

    expect(document.querySelector('.appear-under-test')).toHaveAttribute(
      'data-plass-animation',
      'appear'
    );
  });

  it('writes the animation onto the children rather than onto wrappers', async () => {
    await render(
      <PlAnimateAppear className="appear-under-test">
        <li>One</li>
        <li>Two</li>
      </PlAnimateAppear>
    );

    const children = document.querySelectorAll('.appear-under-test > *');

    expect(children).toHaveLength(2);
    expect(children[0].tagName).toBe('LI');
    expect(children[0]).toHaveClass('plass-anim');
    expect(children[0]).toHaveClass('plass-anim-slide');
  });

  it('wraps a bare string, which has no element to write onto', async () => {
    await render(<PlAnimateAppear className="appear-under-test">Just words</PlAnimateAppear>);

    const child = document.querySelector('.appear-under-test > *');

    expect(child?.tagName).toBe('SPAN');
    expect(child).toHaveClass('plass-anim');
  });

  describe('stagger', () => {
    it('holds each child back by its own position', async () => {
      await render(
        <PlAnimateAppear className="appear-under-test" stagger={100}>
          <p>One</p>
          <p>Two</p>
          <p>Three</p>
        </PlAnimateAppear>
      );

      const children = document.querySelectorAll<HTMLElement>('.appear-under-test > *');

      expect(children[0].style.getPropertyValue('--p-anim-delay')).toBe('0ms');
      expect(children[1].style.getPropertyValue('--p-anim-delay')).toBe('100ms');
      expect(children[2].style.getPropertyValue('--p-anim-delay')).toBe('200ms');
    });

    it('adds the shared delay before the first step', async () => {
      await render(
        <PlAnimateAppear className="appear-under-test" stagger={100} delay={250}>
          <p>One</p>
          <p>Two</p>
        </PlAnimateAppear>
      );

      const children = document.querySelectorAll<HTMLElement>('.appear-under-test > *');

      expect(children[0].style.getPropertyValue('--p-anim-delay')).toBe('250ms');
      expect(children[1].style.getPropertyValue('--p-anim-delay')).toBe('350ms');
    });

    it('runs the list backwards when asked', async () => {
      await render(
        <PlAnimateAppear className="appear-under-test" stagger={100} reverse>
          <p>One</p>
          <p>Two</p>
          <p>Three</p>
        </PlAnimateAppear>
      );

      const children = document.querySelectorAll<HTMLElement>('.appear-under-test > *');

      expect(children[0].style.getPropertyValue('--p-anim-delay')).toBe('200ms');
      expect(children[2].style.getPropertyValue('--p-anim-delay')).toBe('0ms');
    });

    it('counts children rather than leaves, so a group is one step', async () => {
      await render(
        <PlAnimateAppear className="appear-under-test" stagger={100}>
          <div>
            <p>One</p>
            <p>Two</p>
          </div>
          <p>Three</p>
        </PlAnimateAppear>
      );

      const children = document.querySelectorAll<HTMLElement>('.appear-under-test > *');

      expect(children).toHaveLength(2);
      expect(children[1].style.getPropertyValue('--p-anim-delay')).toBe('100ms');
    });
  });

  it('drifts up from below over a short distance by default', async () => {
    await render(
      <PlAnimateAppear className="appear-under-test">
        <p>One</p>
      </PlAnimateAppear>
    );

    const child = document.querySelector<HTMLElement>('.appear-under-test > *');

    expect(child?.style.getPropertyValue('--p-anim-y')).toBe('0.75rem');
    expect(child?.style.getPropertyValue('--p-anim-x')).toBe('0px');
  });

  it('keeps a child class and a child style beside its own', async () => {
    await render(
      <PlAnimateAppear className="appear-under-test">
        <p className="mine" style={{ color: 'red' }}>
          One
        </p>
      </PlAnimateAppear>
    );

    const child = document.querySelector<HTMLElement>('.appear-under-test > *');

    expect(child).toHaveClass('mine');
    expect(child).toHaveClass('plass-anim');
    expect(child?.style.color).toBe('red');
  });

  it('holds the whole set where it is when paused', async () => {
    await render(
      <PlAnimateAppear className="appear-under-test" paused>
        <p>One</p>
      </PlAnimateAppear>
    );

    const root = document.querySelector('.appear-under-test') as HTMLElement;

    expect(root).toHaveAttribute('data-state', 'paused');
    expect(root.style.getPropertyValue('--p-anim-state')).toBe('paused');
  });

  it('renders something else entirely when asked', async () => {
    await render(
      <PlAnimateAppear className="appear-under-test" render={<ul />}>
        <li>One</li>
      </PlAnimateAppear>
    );

    expect(document.querySelector('.appear-under-test')?.tagName).toBe('UL');
  });
});
