import { PlAvatar, PlAvatarGroup } from 'plass-ui';

export default function AvatarGroupVariants() {
  return (
    <PlAvatarGroup variant="glass" color="info">
      <PlAvatar name="Ada Lovelace" />
      <PlAvatar name="Grace Hopper" />
      <PlAvatar name="On call" variant="solid" color="danger" />
      <PlAvatar name="Katherine Johnson" />
    </PlAvatarGroup>
  );
}
