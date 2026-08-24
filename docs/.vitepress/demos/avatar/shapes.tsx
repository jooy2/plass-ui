import { PlAvatar } from 'plass-ui';

export default function AvatarShapes() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      <PlAvatar size="lg" name="Ada Lovelace" src="/portrait-2.svg" />
      <PlAvatar size="lg" shape="square" name="Ada Lovelace" src="/portrait-2.svg" />
    </div>
  );
}
