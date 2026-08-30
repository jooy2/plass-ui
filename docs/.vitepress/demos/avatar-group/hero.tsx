import { PlAvatar, PlAvatarGroup } from 'plass-ui';

export default function AvatarGroupHero() {
  return (
    <PlAvatarGroup size="lg" max={4} total={11}>
      <PlAvatar name="Ada Lovelace" src="/portrait-1.svg" />
      <PlAvatar name="Grace Hopper" src="/portrait-2.svg" />
      <PlAvatar name="Katherine Johnson" />
      <PlAvatar name="홍길동" />
      <PlAvatar name="Alan Turing" />
    </PlAvatarGroup>
  );
}
