import { PlAvatar } from 'plass-ui';

export default function AvatarHero() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      <PlAvatar size="lg" name="Ada Lovelace" src="/portrait-1.svg" />
      <PlAvatar size="lg" name="Jane Doe" />
      <PlAvatar size="lg" name="홍길동" variant="solid" color="info" />
      <PlAvatar size="lg" shape="square" variant="glass" name="Plass UI">
        <img src="/logo.svg" alt="" />
      </PlAvatar>
      <PlAvatar size="lg" />
    </div>
  );
}
