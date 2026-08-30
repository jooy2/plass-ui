import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAvatar, PlAvatarGroup } from 'plass-ui';

describe('PlAvatarGroup', () => {
  describe('rendering', () => {
    it('draws every avatar it was given', async () => {
      const screen = await render(
        <PlAvatarGroup>
          <PlAvatar name="Ada Lovelace" />
          <PlAvatar name="Grace Hopper" />
          <PlAvatar name="Alan Turing" />
        </PlAvatarGroup>
      );

      await expect.element(screen.getByText('AL', { exact: true })).toBeInTheDocument();
      await expect.element(screen.getByText('GH', { exact: true })).toBeInTheDocument();
      await expect.element(screen.getByText('AT', { exact: true })).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <PlAvatarGroup className="my-own-class" aria-label="Team">
          <PlAvatar name="Ada Lovelace" />
        </PlAvatarGroup>
      );

      expect(screen.getByLabelText('Team').element()).toHaveClass('my-own-class');
      expect(screen.getByLabelText('Team').element()).toHaveClass('isolate');
    });
  });

  describe('the overlap', () => {
    it('is a fraction of the size when nothing was said', async () => {
      const screen = await render(
        <PlAvatarGroup aria-label="Team" size="xl">
          <PlAvatar name="Ada Lovelace" />
        </PlAvatarGroup>
      );

      expect(screen.getByLabelText('Team').element().getAttribute('style')).toContain(
        '--p-overlap: 1.25rem'
      );
    });

    it('takes a number as pixels and a string as it is', async () => {
      const screen = await render(
        <PlAvatarGroup aria-label="Team" overlap={4}>
          <PlAvatar name="Ada Lovelace" />
        </PlAvatarGroup>
      );

      expect(screen.getByLabelText('Team').element().getAttribute('style')).toContain(
        '--p-overlap: 4px'
      );

      await screen.rerender(
        <PlAvatarGroup aria-label="Team" overlap="1.5rem">
          <PlAvatar name="Ada Lovelace" />
        </PlAvatarGroup>
      );

      expect(screen.getByLabelText('Team').element().getAttribute('style')).toContain(
        '--p-overlap: 1.5rem'
      );
    });
  });

  describe('the count', () => {
    it('draws the ones that did not fit as a count', async () => {
      const screen = await render(
        <PlAvatarGroup max={2}>
          <PlAvatar name="Ada Lovelace" />
          <PlAvatar name="Grace Hopper" />
          <PlAvatar name="Alan Turing" />
          <PlAvatar name="Edsger Dijkstra" />
        </PlAvatarGroup>
      );

      await expect.element(screen.getByText('GH', { exact: true })).toBeInTheDocument();
      expect(screen.getByText('AT', { exact: true }).query()).toBeNull();
      await expect.element(screen.getByText('+2', { exact: true })).toBeInTheDocument();
    });

    it('counts against total when it was handed only the first few', async () => {
      const screen = await render(
        <PlAvatarGroup max={2} total={40}>
          <PlAvatar name="Ada Lovelace" />
          <PlAvatar name="Grace Hopper" />
        </PlAvatarGroup>
      );

      await expect.element(screen.getByText('+38', { exact: true })).toBeInTheDocument();
    });

    it('draws no count when everything fits', async () => {
      const screen = await render(
        <PlAvatarGroup max={4}>
          <PlAvatar name="Ada Lovelace" />
          <PlAvatar name="Grace Hopper" />
        </PlAvatarGroup>
      );

      expect(screen.getByText('+0', { exact: true }).query()).toBeNull();
    });

    it('reflects a changed max on re-render', async () => {
      const screen = await render(
        <PlAvatarGroup max={1}>
          <PlAvatar name="Ada Lovelace" />
          <PlAvatar name="Grace Hopper" />
          <PlAvatar name="Alan Turing" />
        </PlAvatarGroup>
      );

      await expect.element(screen.getByText('+2', { exact: true })).toBeInTheDocument();

      await screen.rerender(
        <PlAvatarGroup max={2}>
          <PlAvatar name="Ada Lovelace" />
          <PlAvatar name="Grace Hopper" />
          <PlAvatar name="Alan Turing" />
        </PlAvatarGroup>
      );

      await expect.element(screen.getByText('+1', { exact: true })).toBeInTheDocument();
    });
  });

  describe('inheritance', () => {
    it('hands its size, shape, variant and color to every avatar', async () => {
      const screen = await render(
        <PlAvatarGroup size="lg" shape="square" variant="solid" color="danger">
          <PlAvatar name="Ada Lovelace" />
        </PlAvatarGroup>
      );

      const avatar = screen.getByText('AL', { exact: true }).element().closest('.h-12')!;

      expect(avatar).not.toBeNull();
      expect(avatar).not.toHaveClass('rounded-full');
      expect(avatar.getAttribute('style')).toContain('--plass-danger-fill');
    });

    it('lets an avatar override what the group said', async () => {
      const screen = await render(
        <PlAvatarGroup size="lg">
          <PlAvatar name="Ada Lovelace" />
          <PlAvatar name="Grace Hopper" size="sm" />
        </PlAvatarGroup>
      );

      expect(screen.getByText('AL', { exact: true }).element().closest('.h-12')).not.toBeNull();
      expect(screen.getByText('GH', { exact: true }).element().closest('.h-8')).not.toBeNull();
    });

    it('leaves an avatar on its own defaults when the group says nothing', async () => {
      const screen = await render(
        <PlAvatarGroup>
          <PlAvatar name="Ada Lovelace" />
        </PlAvatarGroup>
      );

      expect(screen.getByText('AL', { exact: true }).element().closest('.h-10')).not.toBeNull();
    });

    it('reaches an avatar that is not a direct child', async () => {
      const screen = await render(
        <PlAvatarGroup size="xl">
          <span>
            <PlAvatar name="Ada Lovelace" />
          </span>
        </PlAvatarGroup>
      );

      expect(screen.getByText('AL', { exact: true }).element().closest('.h-14')).not.toBeNull();
    });

    it('reflects a changed group prop on re-render', async () => {
      const screen = await render(
        <PlAvatarGroup size="sm">
          <PlAvatar name="Ada Lovelace" />
        </PlAvatarGroup>
      );

      expect(screen.getByText('AL', { exact: true }).element().closest('.h-8')).not.toBeNull();

      await screen.rerender(
        <PlAvatarGroup size="xl">
          <PlAvatar name="Ada Lovelace" />
        </PlAvatarGroup>
      );

      expect(screen.getByText('AL', { exact: true }).element().closest('.h-14')).not.toBeNull();
    });
  });
});
