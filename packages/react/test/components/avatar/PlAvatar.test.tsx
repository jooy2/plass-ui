import { act } from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAvatar } from 'plass-ui';

/** A picture that really loads, so the image branch is exercised rather than the fallback. */
const PIXEL =
  'data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%221%22%20height%3D%221%22%2F%3E';

/** A picture that never decodes. */
const BROKEN = 'data:image/png;base64,AAAA';

const image = (className: string) => document.querySelector<HTMLImageElement>(`.${className} img`);

describe('PlAvatar', () => {
  describe('the fallback', () => {
    it('draws a silhouette when it is given nothing at all', async () => {
      await render(<PlAvatar className="avatar-under-test" />);

      expect(document.querySelector('.avatar-under-test svg')).not.toBeNull();
    });

    it('derives the initials from a two-word name', async () => {
      const screen = await render(<PlAvatar name="Jane Doe" />);

      await expect.element(screen.getByText('JD')).toBeInTheDocument();
    });

    it('takes one character from a single-token name', async () => {
      const screen = await render(<PlAvatar name="홍길동" />);

      await expect.element(screen.getByText('홍', { exact: true })).toBeInTheDocument();
    });

    it('uses the first and last word of a longer name', async () => {
      const screen = await render(<PlAvatar name="Ada Byron Lovelace" />);

      await expect.element(screen.getByText('AL')).toBeInTheDocument();
    });

    it('prefers written-out initials to the derived ones', async () => {
      const screen = await render(<PlAvatar name="Jane Doe" initials="JX" />);

      await expect.element(screen.getByText('JX')).toBeInTheDocument();
      expect(screen.getByText('JD').query()).toBeNull();
    });

    it('prefers children to either', async () => {
      const screen = await render(<PlAvatar name="Jane Doe">🐈</PlAvatar>);

      await expect.element(screen.getByText('🐈')).toBeInTheDocument();
      expect(screen.getByText('JD').query()).toBeNull();
    });

    it('reflects a changed name on re-render', async () => {
      const screen = await render(<PlAvatar name="Jane Doe" />);

      await screen.rerender(<PlAvatar name="Ada Lovelace" />);

      await expect.element(screen.getByText('AL')).toBeInTheDocument();
      expect(screen.getByText('JD').query()).toBeNull();
    });
  });

  describe('the accessible name', () => {
    it('reads the name rather than the initials', async () => {
      const screen = await render(<PlAvatar name="Jane Doe" />);

      await expect.element(screen.getByText('Jane Doe')).toBeInTheDocument();
    });

    it('prefers `alt` to `name` for it', async () => {
      const screen = await render(<PlAvatar name="Jane Doe" alt="Jane Doe’s profile photo" />);

      await expect.element(screen.getByText('Jane Doe’s profile photo')).toBeInTheDocument();
    });

    it('says nothing beside a silhouette', async () => {
      const screen = await render(<PlAvatar />);

      expect(screen.getByText('Jane Doe').query()).toBeNull();
    });
  });

  describe('the picture', () => {
    it('renders an image when `src` is given', async () => {
      const screen = await render(<PlAvatar src={PIXEL} name="Plass" />);

      await expect.element(screen.getByRole('img', { name: 'Plass' })).toBeInTheDocument();
    });

    it('renders no image without one', async () => {
      const screen = await render(<PlAvatar name="Plass" />);

      expect(screen.getByRole('img').query()).toBeNull();
    });

    it('is in the server markup, so the browser fetches it before hydration', async () => {
      const avatar = <PlAvatar src={PIXEL} name="Plass" className="avatar-under-test" />;
      const host = document.createElement('div');
      const onRecoverableError = vi.fn();

      host.innerHTML = renderToString(avatar);

      // Until it has loaded, the fallback is what is seen and what is heard.
      const served = host.querySelector('img');

      expect(served).toHaveAttribute('src', PIXEL);
      expect(served).toHaveAttribute('aria-hidden', 'true');
      expect(served).toHaveClass('invisible', 'absolute');

      document.body.append(host);

      const root = await act(async () => hydrateRoot(host, avatar, { onRecoverableError }));

      try {
        await expect
          .poll(() => image('avatar-under-test')?.hasAttribute('aria-hidden'))
          .toBe(false);
        expect(image('avatar-under-test')).not.toHaveClass('invisible');
        // The fallback is gone, as it was when the picture was mounted on load.
        expect(host.querySelector('.avatar-under-test')!.children).toHaveLength(1);
        expect(onRecoverableError).not.toHaveBeenCalled();
      } finally {
        await act(async () => root.unmount());
        host.remove();
      }
    });

    it('keeps a picture that fails out of sight, out of the flow and unheard', async () => {
      const screen = await render(
        <PlAvatar src={BROKEN} name="Jane Doe" className="avatar-under-test" />
      );

      await expect.poll(() => image('avatar-under-test')?.hasAttribute('data-error')).toBe(true);

      expect(image('avatar-under-test')).toHaveClass('invisible', 'absolute');
      expect(screen.getByRole('img').query()).toBeNull();
      await expect.element(screen.getByText('JD')).toBeInTheDocument();
      await expect.element(screen.getByText('Jane Doe')).toBeInTheDocument();
    });

    it('lets a class in `imageProps` replace the crop, loaded or not', async () => {
      await render(
        <PlAvatar
          src={BROKEN}
          name="Jane Doe"
          className="avatar-under-test"
          imageProps={{ className: 'own-crop' }}
        />
      );

      await expect.poll(() => image('avatar-under-test')?.hasAttribute('data-error')).toBe(true);
      expect(image('avatar-under-test')).toHaveClass('own-crop', 'invisible');
      expect(image('avatar-under-test')).not.toHaveClass('object-cover');
    });
  });

  describe('rendering', () => {
    it('crops to a circle by default and to the fillet when squared', async () => {
      const screen = await render(<PlAvatar name="Jane Doe" className="avatar-under-test" />);

      expect(screen.getByText('JD').element().closest('.avatar-under-test')).toHaveClass(
        'rounded-full'
      );

      await screen.rerender(
        <PlAvatar name="Jane Doe" shape="square" className="avatar-under-test" />
      );

      expect(screen.getByText('JD').element().closest('.avatar-under-test')).not.toHaveClass(
        'rounded-full'
      );
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlAvatar name="Jane Doe" className="my-own-class" />);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });

    it('forwards unknown props to the element', async () => {
      const screen = await render(<PlAvatar name="Jane Doe" data-testid="who" />);

      expect(screen.getByTestId('who').element()).toBeInTheDocument();
    });
  });
});
